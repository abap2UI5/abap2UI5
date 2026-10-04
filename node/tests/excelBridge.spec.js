// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, classEnv } = require("./loadLibModule");

// cc/ExcelBridge.js: the bridge between an app in an Excel add-in's task
// pane and the workbook, through the Office.js the add-in's host page loads.
// The contract under test:
//   - "delegate, never decide" (AGENTS.md rule 10): write( ) puts what the
//     bindings hold into the sheet and fires OnWritten, read( ) puts the
//     selection into `selection` and fires OnRead; every failure - no Excel,
//     too many cells, an invalid target, a protected sheet - is OnError with
//     a message and a code, never thrown, no UI.
//   - types: strings are written as text (number format @), numbers as
//     numbers, ISO dates as Excel dates; a read gives date cells back as ISO.
//   - outside Excel the control is an invisible placeholder and never
//     touches Office.
//   - selectionChange subscribes only while on, debounced, and unsubscribes.

// ---- a stubbed Office.js -------------------------------------------------

function colName(n) {
  let s = "";
  let i = n + 1;
  while (i) {
    const m = (i - 1) % 26;
    s = String.fromCharCode(65 + m) + s;
    i = Math.floor((i - 1) / 26);
  }
  return s;
}

function parseCell(a) {
  const m = /^\$?([A-Z]+)\$?(\d+)$/i.exec(a);
  if (!m) throw new Error(`bad address ${a}`);
  let c = 0;
  for (const ch of m[1].toUpperCase()) c = c * 26 + (ch.charCodeAt(0) - 64);
  return { row: Number(m[2]) - 1, col: c - 1 };
}

function fakeOffice({
  host = "Excel",
  selection = { sheet: "Sheet1", row: 0, col: 0, rows: 1, cols: 1 },
  used,
  syncError,
  sheets = ["Sheet1"],
} = {}) {
  const log = [];
  const handlers = [];
  let removed = 0;
  let runs = 0;

  function makeSheet(name) {
    const sheet = {
      name,
      getRange: (addr) => {
        const { row, col } = parseCell(addr);
        return makeRange({ sheet: name, row, col, rows: 1, cols: 1 });
      },
      tables: {
        add: (range, hasHeaders) =>
          log.push(["table", range.address, hasHeaders]),
      },
      activate: () => log.push(["activate", name]),
    };
    return sheet;
  }

  function makeRange(spec) {
    const r = {
      ...spec,
      get address() {
        const end =
          r.rows === 1 && r.cols === 1
            ? ""
            : `:${colName(r.col + r.cols - 1)}${r.row + r.rows}`;
        return `${r.sheet}!${colName(r.col)}${r.row + 1}${end}`;
      },
      get rowCount() {
        return r.rows;
      },
      get columnCount() {
        return r.cols;
      },
      get worksheet() {
        return makeSheet(r.sheet);
      },
      isNullObject: false,
      load: (what) => log.push(["load", what]),
      getCell: (dr, dc) =>
        makeRange({
          sheet: r.sheet,
          row: r.row + dr,
          col: r.col + dc,
          rows: 1,
          cols: 1,
        }),
      getResizedRange: (dr, dc) =>
        makeRange({ ...spec, rows: r.rows + dr, cols: r.cols + dc }),
      getUsedRangeOrNullObject: (valuesOnly) => {
        log.push(["usedRange", valuesOnly]);
        if (!used) return { isNullObject: true, load: () => {} };
        return makeRange(used);
      },
      format: { autofitColumns: () => log.push(["autofit", r.address]) },
      set values(v) {
        log.push(["values", r.address, v]);
      },
      get values() {
        return spec.values;
      },
      set numberFormat(v) {
        log.push(["numberFormat", r.address, v]);
      },
      get numberFormat() {
        return spec.numberFormat;
      },
      get text() {
        return spec.text;
      },
    };
    return r;
  }

  const context = {
    workbook: {
      worksheets: {
        getActiveWorksheet: () => makeSheet("Sheet1"),
        getItem: (name) => {
          log.push(["getItem", name]);
          return makeSheet(name);
        },
        add: (name) => {
          log.push(["addSheet", name]);
          return makeSheet(name || "Sheet2");
        },
      },
      getSelectedRange: () => makeRange(selection),
      onSelectionChanged: {
        add: (fn) => {
          handlers.push(fn);
          return { context, remove: () => removed++ };
        },
      },
    },
    sync: () => (syncError ? Promise.reject(syncError) : Promise.resolve()),
  };

  const Excel = {
    run: (a, b) => {
      runs++;
      const fn = typeof a === "function" ? a : b;
      return Promise.resolve().then(() => fn(context));
    },
  };
  const Office = {
    HostType: { Excel: "Excel", Word: "Word" },
    context: { host },
    onReady: () => Promise.resolve({ host, platform: "PC" }),
  };
  return {
    Office,
    Excel,
    log,
    handlers,
    sheets,
    get removed() {
      return removed;
    },
    get runs() {
      return runs;
    },
  };
}

// ---- the control in a sandbox --------------------------------------------

function load({ office } = {}) {
  const errors = [];
  const Lib = { ...loadLib().Lib, logError: (m) => errors.push(m) };

  // a hand-driven clock for the selection debounce
  const timers = new Map();
  let nextTimer = 1;
  const win = office ? { Office: office.Office, Excel: office.Excel } : {};

  const { module: ExcelBridge } = loadModule("cc/ExcelBridge.js", {
    deps: {
      "z2ui5/core/Env": classEnv,
      "sap/ui/core/Control": {
        extend(_name, def) {
          function Ctrl() {}
          Object.assign(Ctrl.prototype, def);
          Ctrl.renderer = def.renderer;
          Ctrl.metadata = def.metadata;
          return Ctrl;
        },
      },
      "z2ui5/core/Lib": Lib,
    },
    sandbox: {
      window: win,
      setTimeout: (fn) => {
        const id = nextTimer++;
        timers.set(id, fn);
        return id;
      },
      clearTimeout: (id) => timers.delete(id),
    },
  });

  function tick() {
    const due = [...timers.values()];
    timers.clear();
    due.forEach((fn) => fn());
  }

  function makeInstance(props = {}) {
    const inst = new ExcelBridge();
    const defaults = {};
    for (const [k, v] of Object.entries(ExcelBridge.metadata.properties)) {
      defaults[k] = v.defaultValue;
    }
    inst._props = { ...defaults, ...props };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.events = [];
    for (const name of ["OnWritten", "OnRead", "OnSelectionChange", "OnError"]) {
      inst[`fire${name}`] = (p) => inst.events.push([name, p]);
    }
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    inst.init();
    return inst;
  }

  function render(inst) {
    const out = [];
    const rm = {
      openStart: (tag) => out.push(`open:${tag}`),
      style: () => {},
      openEnd: () => {},
      close: (tag) => out.push(`close:${tag}`),
    };
    ExcelBridge.renderer.render(rm, inst);
    return out;
  }

  return { ExcelBridge, makeInstance, render, errors, tick, timers };
}

// lets the promise chains of the control settle
async function flush() {
  for (let i = 0; i < 20; i++) await new Promise((r) => setImmediate(r));
}

const ROWS = [
  { MATNR: "000123", MAKTX: "Bolt", MENGE: 12.5, ERDAT: "2024-01-15" },
  { MATNR: "000456", MAKTX: "=HYPERLINK(1)", MENGE: 3, ERDAT: "" },
];

function written(office) {
  return office.log.filter((l) => l[0] === "values" || l[0] === "numberFormat");
}

// ---- write ---------------------------------------------------------------

test("write puts the rows as an Excel table at A1 and fires OnWritten", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: ROWS });

  await inst.write();

  const [formats, values] = written(office);
  expect(formats[0]).toBe("numberFormat");
  expect(values[0]).toBe("values");
  expect(values[1]).toBe("Sheet1!A1:D3");
  expect(values[2]).toEqual([
    ["MATNR", "MAKTX", "MENGE", "ERDAT"],
    ["000123", "Bolt", 12.5, 45306],
    ["000456", "=HYPERLINK(1)", 3, ""],
  ]);
  expect(office.log).toContainEqual(["table", "Sheet1!A1:D3", true]);
  expect(inst.events).toEqual([
    ["OnWritten", { address: "Sheet1!A1:D3", rowCount: 3, columnCount: 4 }],
  ]);
});

test("strings are written as text, numbers as numbers, ISO dates as dates", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: ROWS });

  await inst.write();

  const formats = written(office)[0][2];
  // header row text, then: leading zeros and the formula stay text (@)
  expect(formats[0]).toEqual(["@", "@", "@", "@"]);
  expect(formats[1]).toEqual(["@", "@", "General", "yyyy-mm-dd"]);
  expect(formats[2]).toEqual(["@", "@", "General", "@"]);
});

test("columns pick, order and label the fields; numberFormats apply", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({
    rows: ROWS,
    columns: [
      { KEY: "menge", HEADER: "Quantity", NUMBER_FORMAT: "#,##0.00" },
      { KEY: "MATNR", HEADER: "Material" },
    ],
    asTable: false,
  });

  await inst.write();

  const [formats, values] = written(office);
  expect(values[2]).toEqual([
    ["Quantity", "Material"],
    [12.5, "000123"],
    [3, "000456"],
  ]);
  expect(formats[2][1]).toEqual(["#,##0.00", "@"]);
  // a plain range: no table
  expect(office.log.some((l) => l[0] === "table")).toBe(false);
});

test("columns as a comma-separated string, numberFormats as an object", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({
    rows: ROWS,
    columns: "ERDAT, MATNR",
    numberFormats: { ERDAT: "dd.mm.yyyy" },
  });

  await inst.write();

  const [formats, values] = written(office);
  expect(values[2][0]).toEqual(["ERDAT", "MATNR"]);
  expect(formats[2][1]).toEqual(["dd.mm.yyyy", "@"]);
});

test("a plain range without header writes the rows only", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({
    rows: [{ A: 1 }, { A: 2 }],
    asTable: false,
    header: false,
    target: "C5",
  });

  await inst.write();

  const values = written(office)[1];
  expect(values[1]).toBe("Sheet1!C5:C6");
  expect(values[2]).toEqual([[1], [2]]);
});

test("target selection anchors at the selection's top-left cell", async () => {
  const office = fakeOffice({
    selection: { sheet: "Data", row: 4, col: 2, rows: 9, cols: 9 },
  });
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: [{ A: 1 }], target: "selection" });

  await inst.write();

  expect(written(office)[1][1]).toBe("Data!C5:C6");
});

test("target newSheet adds and activates a sheet with the given name", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({
    rows: [{ A: 1 }],
    target: "newSheet",
    sheetName: "Export",
  });

  await inst.write();

  expect(office.log).toContainEqual(["addSheet", "Export"]);
  expect(office.log).toContainEqual(["activate", "Export"]);
  expect(written(office)[1][1]).toBe("Export!A1:A2");
});

test("an address with a sheetName goes to that sheet", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: [{ A: 1 }], target: "$B$2", sheetName: "Plan" });

  await inst.write();

  expect(office.log).toContainEqual(["getItem", "Plan"]);
  expect(written(office)[1][1]).toBe("Plan!B2:B3");
});

test("too many cells are refused before anything reaches Excel", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const rows = Array.from({ length: 100 }, (_v, i) => ({ A: i, B: i }));
  const inst = makeInstance({ rows, maxCells: 50 });

  await inst.write();

  expect(office.runs).toBe(0);
  expect(inst.events).toEqual([
    ["OnError", { message: "202 cells exceed the limit of 50", code: "TooLarge" }],
  ]);
});

test("maxCells cannot lift the hard ceiling", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const rows = Array.from({ length: 60000 }, (_v, i) => ({ A: i, B: i }));
  const inst = makeInstance({ rows, maxCells: 10000000, asTable: false, header: false });

  await inst.write();

  expect(office.runs).toBe(0);
  expect(inst.events[0][1].code).toBe("TooLarge");
  expect(inst.events[0][1].message).toContain("limit of 100000");
});

test("an invalid target is refused", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  for (const target of ["A1:B2", "Sheet1!A1", "A0", "=A1", "selectionx"]) {
    const inst = makeInstance({ rows: [{ A: 1 }], target });
    await inst.write();
    expect(inst.events).toEqual([
      ["OnError", { message: `invalid target '${target}'`, code: "InvalidTarget" }],
    ]);
  }
  expect(office.runs).toBe(0);
});

test("nothing to write is an error, not an empty write", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: [] });

  await inst.write();

  expect(inst.events).toEqual([["OnError", { message: "nothing to write", code: "NoData" }]]);
});

test("a protected sheet fails as OnError with Excel's code - logged, never thrown", async () => {
  const office = fakeOffice({
    syncError: { code: "AccessDenied", message: "The sheet is protected." },
  });
  const { makeInstance, errors } = load({ office });
  const inst = makeInstance({ rows: [{ A: 1 }] });

  await inst.write();

  expect(inst.events).toEqual([
    ["OnError", { message: "The sheet is protected.", code: "AccessDenied" }],
  ]);
  expect(errors.some((m) => m.includes("protected"))).toBe(true);
});

test("operations run one after the other, each with the bindings of its call", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: [{ A: 1 }] });

  const first = inst.write();
  inst._props.rows = [{ A: 2 }, { A: 3 }];
  const second = inst.write();
  await Promise.all([first, second]);

  const values = office.log.filter((l) => l[0] === "values").map((l) => l[2]);
  expect(values).toEqual([
    [["A"], [1]],
    [["A"], [2], [3]],
  ]);
  expect(inst.events.map((e) => e[1].rowCount)).toEqual([2, 3]);
});

test("a write settling after teardown fires nothing", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: [{ A: 1 }] });

  const done = inst.write();
  inst._destroyed = true;
  await done;

  expect(inst.events).toEqual([]);
});

// ---- read ----------------------------------------------------------------

test("read puts the selection into selection as COL rows and fires OnRead", async () => {
  const office = fakeOffice({
    selection: {
      sheet: "Sheet1",
      row: 1,
      col: 0,
      rows: 2,
      cols: 3,
      values: [
        ["000123", 4711, 45306],
        ["000456", "", 45306.5],
      ],
      numberFormat: [
        ["@", "General", "dd.mm.yyyy"],
        ["@", "General", "yyyy-mm-dd hh:mm"],
      ],
    },
  });
  const { makeInstance } = load({ office });
  const inst = makeInstance();

  await inst.read();

  expect(inst._props.selection).toEqual([
    { COL1: "000123", COL2: 4711, COL3: "2024-01-15" },
    { COL1: "000456", COL2: "", COL3: "2024-01-15T12:00:00" },
  ]);
  expect(inst._props.selectionAddress).toBe("Sheet1!A2:C3");
  expect(inst.events).toEqual([
    ["OnRead", { address: "Sheet1!A2:C3", rowCount: 2, columnCount: 3 }],
  ]);
});

test("readText reads what the cells show", async () => {
  const office = fakeOffice({
    selection: {
      sheet: "Sheet1",
      row: 0,
      col: 0,
      rows: 1,
      cols: 1,
      text: [["15.01.2024"]],
    },
  });
  const { makeInstance } = load({ office });
  const inst = makeInstance({ readText: true });

  await inst.read();

  expect(inst._props.selection).toEqual([{ COL1: "15.01.2024" }]);
  expect(office.log).toContainEqual(["load", "text"]);
});

test("a whole column selected is read as its used part", async () => {
  const office = fakeOffice({
    selection: { sheet: "Sheet1", row: 0, col: 0, rows: 1048576, cols: 1 },
    used: {
      sheet: "Sheet1",
      row: 0,
      col: 0,
      rows: 2,
      cols: 1,
      values: [["A"], ["B"]],
      numberFormat: [["General"], ["General"]],
    },
  });
  const { makeInstance } = load({ office });
  const inst = makeInstance();

  await inst.read();

  expect(office.log).toContainEqual(["usedRange", true]);
  expect(inst._props.selection).toEqual([{ COL1: "A" }, { COL1: "B" }]);
  expect(inst.events[0][1].address).toBe("Sheet1!A1:A2");
});

test("an empty selection reads as no rows", async () => {
  const office = fakeOffice({
    selection: { sheet: "Sheet1", row: 0, col: 0, rows: 1048576, cols: 1 },
  });
  const { makeInstance } = load({ office });
  const inst = makeInstance({ selection: [{ COL1: "old" }] });

  await inst.read();

  expect(inst._props.selection).toEqual([]);
  expect(inst.events).toEqual([["OnRead", { address: "", rowCount: 0, columnCount: 0 }]]);
});

test("a selection over the limit is refused, nothing read", async () => {
  const big = { sheet: "Sheet1", row: 0, col: 0, rows: 300, cols: 100 };
  const office = fakeOffice({ selection: big, used: big });
  const { makeInstance } = load({ office });
  const inst = makeInstance({ selection: [{ COL1: "old" }] });

  await inst.read();

  expect(inst.events).toEqual([
    ["OnError", { message: "30000 cells exceed the limit of 20000", code: "TooLarge" }],
  ]);
  expect(inst._props.selection).toEqual([{ COL1: "old" }]);
  expect(office.log.some((l) => l[0] === "load" && l[1].includes("values"))).toBe(false);
});

// ---- outside Excel -------------------------------------------------------

test("without Office.js the control is an invisible no-op and write/read fire OnError", async () => {
  const { makeInstance, render } = load();
  const inst = makeInstance({ rows: [{ A: 1 }], selectionChange: true });

  expect(render(inst)).toEqual(["open:span", "close:span"]);
  inst.onAfterRendering();
  await inst.write();
  await inst.read();
  await flush();

  expect(inst._props.available).toBe(false);
  expect(inst.events).toEqual([
    ["OnError", { message: "Excel not available", code: "NotAvailable" }],
    ["OnError", { message: "Excel not available", code: "NotAvailable" }],
  ]);
});

test("Office.js in another host (Word) is not Excel", async () => {
  const office = fakeOffice({ host: "Word" });
  const { makeInstance } = load({ office });
  const inst = makeInstance({ rows: [{ A: 1 }] });

  inst.onAfterRendering();
  await inst.write();

  expect(office.runs).toBe(0);
  expect(inst._props.available).toBe(false);
  expect(inst.events[0][1].code).toBe("NotAvailable");
});

test("inside Excel available turns true after the first render", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance();

  inst.onAfterRendering();
  await flush();

  expect(inst._props.available).toBe(true);
  expect(inst.events).toEqual([]);
});

test("the setters write without invalidating", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const calls = [];
  inst.setProperty = (k, v, quiet) => calls.push([k, v, quiet]);

  expect(inst.setRows([{ A: 1 }])).toBe(inst);
  expect(inst.setTarget("B2")).toBe(inst);
  expect(calls).toEqual([
    ["rows", [{ A: 1 }], true],
    ["target", "B2", true],
  ]);
});

// ---- selectionChange -----------------------------------------------------

test("selectionChange is off by default - no subscription", async () => {
  const office = fakeOffice();
  const { makeInstance } = load({ office });
  const inst = makeInstance();

  inst.onAfterRendering();
  await flush();

  expect(office.handlers.length).toBe(0);
});

test("selectionChange subscribes, reports the settled address once, and unsubscribes", async () => {
  const office = fakeOffice({
    selection: { sheet: "Sheet1", row: 2, col: 1, rows: 3, cols: 1 },
  });
  const { makeInstance, tick } = load({ office });
  const inst = makeInstance({ selectionChange: true });

  inst.onAfterRendering();
  inst.onAfterRendering();
  await flush();
  expect(office.handlers.length).toBe(1);

  // a drag: three changes, one report
  office.handlers[0]();
  office.handlers[0]();
  office.handlers[0]();
  tick();
  await flush();
  // the same address again is no news
  office.handlers[0]();
  tick();
  await flush();
  expect(inst.events).toEqual([["OnSelectionChange", { address: "Sheet1!B3:B5" }]]);

  inst.setSelectionChange(false);
  await flush();
  expect(office.removed).toBe(1);
});

test("exit removes the subscription and the pending report", async () => {
  const office = fakeOffice();
  const { makeInstance, timers } = load({ office });
  const inst = makeInstance({ selectionChange: true });

  inst.onAfterRendering();
  await flush();
  office.handlers[0]();
  expect(timers.size).toBe(1);

  inst.exit();
  await flush();
  expect(timers.size).toBe(0);
  expect(office.removed).toBe(1);
});

// ---- the pure helpers ----------------------------------------------------

test("rows as arrays are written by position", () => {
  const { ExcelBridge } = load();
  const m = ExcelBridge._buildMatrix({
    rows: [
      ["a", 1],
      ["b", 2],
    ],
    columns: null,
    numberFormats: null,
    header: false,
  });
  expect(m.values).toEqual([
    ["a", 1],
    ["b", 2],
  ]);
  expect(m.columns).toBe(2);
});

test("an empty HEADER is labelled by the key, array rows by COLn", () => {
  const { ExcelBridge } = load();
  const byKey = ExcelBridge._buildMatrix({
    rows: [{ MATNR: "1" }],
    columns: [{ KEY: "MATNR", HEADER: "", NUMBER_FORMAT: "" }],
    numberFormats: null,
    header: true,
  });
  expect(byKey.values[0]).toEqual(["MATNR"]);
  const byPosition = ExcelBridge._buildMatrix({
    rows: [["a", 1]],
    columns: null,
    numberFormats: null,
    header: true,
  });
  expect(byPosition.values[0]).toEqual(["COL1", "COL2"]);
});

test("an impossible ISO date and the ABAP initial date stay text", () => {
  const { ExcelBridge } = load();
  const m = ExcelBridge._buildMatrix({
    rows: [{ D: "2024-02-31" }, { D: "0000-00-00" }, { D: "2024-01-15T12:30:00Z" }],
    columns: null,
    numberFormats: null,
    header: false,
  });
  expect(m.values[0]).toEqual(["2024-02-31"]);
  expect(m.values[1]).toEqual(["0000-00-00"]);
  expect(m.values[2][0]).toBeCloseTo(45306.520833, 5);
  expect(m.formats[2]).toEqual(["yyyy-mm-dd hh:mm:ss"]);
});
