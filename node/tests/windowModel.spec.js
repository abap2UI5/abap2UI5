// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { classEnv } = require("./loadLibModule");

// core/WindowModel.js: the list binding of a windowed table. The UI5 base
// classes are stood in for by the few members the module overrides or
// reads - a JSONListBinding that holds the array behind its path and hands
// out its rows as contexts - so what is pinned is the module's own part:
// which binding a path gets, when the app is asked for rows, and what
// a sort or a filter sends. The browser half (growing, sap.ui.table, the
// real UI5 classes on 1.71 and today) is the `window` e2e.

function extend(_name, def) {
  const Base = this;
  const Class = Object.prototype.hasOwnProperty.call(def, "constructor")
    ? def.constructor
    : function (...args) {
        Base.apply(this, args);
      };
  Class.prototype = Object.create(Base.prototype);
  for (const [key, value] of Object.entries(def)) {
    if (key !== "constructor") Class.prototype[key] = value;
  }
  Class.extend = extend;
  return Class;
}

function FakeModel(data) {
  this.data = data;
}
FakeModel.prototype.getProperty = function (path) {
  return path
    .split("/")
    .filter(Boolean)
    .reduce((node, key) => (node == null ? undefined : node[key]), this.data);
};
FakeModel.prototype.bindList = function (path) {
  return { plain: path };
};
FakeModel.extend = extend;

function FakeListBinding(oModel, sPath, oContext, aSorters, aFilters) {
  this.oModel = oModel;
  this.sPath = sPath;
  this.aSorters = aSorters || [];
  this.aFilters = aFilters || [];
  this.aApplicationFilters = [];
  this.baseCalls = [];
  this.update();
}
FakeListBinding.prototype.update = function () {
  const list = this.oModel.getProperty(this.sPath) || [];
  this.aIndices = list.map((_row, i) => i);
  this.applyFilter();
  this.applySort();
  this.iLength = this.aIndices.length;
};
FakeListBinding.prototype.applyFilter = function () {
  this.baseCalls.push("applyFilter");
};
FakeListBinding.prototype.applySort = function () {
  this.baseCalls.push("applySort");
};
FakeListBinding.prototype.getLength = function () {
  return this.iLength;
};
FakeListBinding.prototype.getContexts = function (start = 0, length) {
  return this.aIndices.slice(start, start + (length ?? this.iLength));
};
FakeListBinding.prototype.sort = function () {
  this.baseCalls.push("sort");
  return this;
};
FakeListBinding.prototype.filter = function () {
  this.baseCalls.push("filter");
  return this;
};
FakeListBinding.extend = extend;

function load() {
  const { module } = loadModule("core/WindowModel.js", {
    deps: {
      "sap/ui/model/json/JSONModel": FakeModel,
      "sap/ui/model/json/JSONListBinding": FakeListBinding,
      "z2ui5/core/Lib": { logError: () => {} },
      "z2ui5/core/Env": classEnv,
    },
  });
  return module;
}

function rows(n) {
  return Array.from({ length: n }, (_v, i) => ({ ID: i + 1 }));
}

function windowed(WindowModel, { loaded = 50, total = 250, size = 50 } = {}) {
  const model = new WindowModel({
    MT_ROWS: rows(loaded),
    __WINDOW: {
      MT_ROWS: { TOTAL: total, COUNT: loaded, SIZE: size, EVENT: "ROWS" },
    },
  });
  const sent = [];
  model._z2ui5WindowSend = (args, noBusy) => sent.push({ args, noBusy });
  const binding = model.bindList("/MT_ROWS");
  return { model, binding, sent };
}

// filters and sorters the way UI5 shapes them: the members the module reads
function filter(sPath, sOperator, oValue1, oValue2) {
  return { sPath, sOperator, oValue1, oValue2 };
}
function multi(aFilters, bAnd) {
  return { aFilters, bAnd };
}

test("a path without a window state keeps the plain binding", () => {
  const WindowModel = load();
  const model = new WindowModel({ MT_ROWS: rows(3) });
  expect(model.bindList("/MT_ROWS")).toEqual({ plain: "/MT_ROWS" });
  // a deeper path is a window when its own state is there - the state of
  // another path with the same last segment does not count
  const deep = new WindowModel({ __WINDOW: { A: { TOTAL: 1 } }, S: { A: [] } });
  expect(deep.bindList("/S/A")).toEqual({ plain: "/S/A" });
});

test("a table behind a data reference is windowed under its own path", () => {
  const WindowModel = load();
  const model = new WindowModel({
    MR_TAB: { "*": rows(10) },
    __WINDOW: {
      MR_TAB: { "*": { TOTAL: 40, COUNT: 10, SIZE: 10, EVENT: "TAB" } },
    },
  });
  const sent = [];
  model._z2ui5WindowSend = (args) => sent.push(args);
  const binding = model.bindList("/MR_TAB/*");
  expect(binding.getLength()).toBe(40);
  binding.getContexts(0, 15);
  expect(sent[0]).toEqual(["/MR_TAB/*", "TAB", "MORE", "10", "10"]);
});

test("a windowed list counts the rows the app reports, not the ones it holds", () => {
  const { binding } = windowed(load());
  expect(binding.getLength()).toBe(250);
  expect(binding.isLengthFinal()).toBe(true);
  // the browser neither filters nor sorts what the app ordered
  expect(binding.baseCalls).toEqual([]);
});

test("contexts past the loaded rows ask the app for whole windows, once", () => {
  const { binding, sent } = windowed(load());
  expect(binding.getContexts(0, 40)).toHaveLength(40);
  expect(sent).toEqual([]);

  expect(binding.getContexts(0, 60)).toHaveLength(50);
  expect(sent).toHaveLength(1);
  // the app's event, MORE, skip = the rows loaded, top = one window
  expect(sent[0].args).toEqual(["/MT_ROWS", "ROWS", "MORE", "50", "50"]);
  // growing is no reason for the busy overlay
  expect(sent[0].noBusy).toBe(true);

  // asked already - the same need does not go out again
  binding.getContexts(0, 80);
  expect(sent).toHaveLength(1);

  // a threshold counts as needed rows; never past the total
  binding.getContexts(200, 40, 100);
  expect(sent).toHaveLength(2);
  expect(sent[1].args.slice(2)).toEqual(["MORE", "50", "200"]);
});

test("a model push lets the binding ask again", () => {
  const { model, binding, sent } = windowed(load());
  binding.getContexts(0, 60);
  model.data.MT_ROWS = rows(100);
  model.data.__WINDOW.MT_ROWS.COUNT = 100;
  binding.update();
  expect(binding.getContexts(0, 60)).toHaveLength(60);
  binding.getContexts(0, 120);
  expect(sent.map((s) => s.args.slice(3))).toEqual([
    ["50", "50"],
    ["100", "50"],
  ]);
});

test("nothing is asked when the table holds all rows", () => {
  const { binding, sent } = windowed(load(), { loaded: 30, total: 30 });
  binding.getContexts(0, 100);
  expect(sent).toEqual([]);
});

test("nothing is sent without the app's event", () => {
  const { model, binding, sent } = windowed(load());
  model.data.__WINDOW.MT_ROWS.EVENT = "";
  binding.getContexts(0, 60);
  binding.sort([{ sPath: "ID" }]);
  expect(sent).toEqual([]);
});

test("a sort asks the app for the first window, with sorters and filters", () => {
  const { binding, sent } = windowed(load());
  binding.getContexts(0, 60);
  binding.filter([filter("NAME", "Contains", "a")], "Control");
  binding.sort([{ sPath: "PRICE", bDescending: true }, { sPath: "ID" }]);
  expect(binding.baseCalls).toEqual([]);
  const last = sent[sent.length - 1];
  expect(last.noBusy).toBe(false);
  expect(last.args.slice(0, 5)).toEqual(["/MT_ROWS", "ROWS", "SORT", "0", "50"]);
  expect(JSON.parse(last.args[5])).toEqual([
    { PATH: "PRICE", DESCENDING: true },
    { PATH: "ID", DESCENDING: false },
  ]);
  // the column filter comes along: the app gets the whole state at once
  expect(JSON.parse(last.args[6])).toEqual([[["NAME", "Contains", "a", null]]]);
});

test("a filter asks the app for the first window, with filters and sorters", () => {
  const { binding, sent } = windowed(load());
  binding.sort([{ sPath: "ID" }]);
  binding.filter([], "Control");
  expect(sent[1].args).toEqual([
    "/MT_ROWS",
    "ROWS",
    "FILTER",
    "0",
    "50",
    '[{"PATH":"ID","DESCENDING":false}]',
    "[]",
  ]);
});

test("more rows do not replace a sort or a filter kept behind a roundtrip", () => {
  const { keepRestart } = load();
  const sort = ["/MT_ROWS", "ROWS", "SORT", "0", "50", "[]", "[]"];
  const more = ["/MT_ROWS", "ROWS", "MORE", "50", "50"];
  // the restart loads from the first row anyway - the MORE counts old rows
  expect(keepRestart(more, sort)).toBe(sort);
  // a later sort or filter carries the whole state: it wins
  const filter = ["/MT_ROWS", "ROWS", "FILTER", "0", "50", "[]", "[]"];
  expect(keepRestart(filter, sort)).toBe(filter);
  expect(keepRestart(sort, more)).toBe(sort);
  // nothing kept, more after more, another table: the request as it is
  expect(keepRestart(more, undefined)).toBe(more);
  expect(keepRestart(more, ["/MT_ROWS", "ROWS", "MORE", "0", "50"])).toBe(more);
  expect(keepRestart(more, ["/MT_GRID", "GRID", "SORT", "0", "50"])).toBe(more);
});

test("filters: one path ORed, the paths ANDed, control and application ANDed", () => {
  const { binding, sent } = windowed(load());
  binding.filter(
    [
      filter("NAME", "Contains", "ab"),
      filter("NAME", "Contains", "cd"),
      filter("PRICE", "GT", 10),
    ],
    "Control",
  );
  binding.filter([filter("ID", "LE", 100)], "Application");
  expect(JSON.parse(sent[1].args[6])).toEqual([
    [
      ["NAME", "Contains", "ab", null],
      ["NAME", "Contains", "cd", null],
    ],
    [["PRICE", "GT", 10, null]],
    [["ID", "LE", 100, null]],
  ]);
  // the sorters come along, empty - the binding has none
  expect(sent[1].args[5]).toBe("[]");
});

test("multi-filters of the shapes the wire has", () => {
  const { binding, sent } = windowed(load());
  binding.filter([
    multi(
      [
        filter("A", "EQ", 1),
        multi([filter("B", "EQ", 2), filter("B", "EQ", 3)], false),
      ],
      true,
    ),
    multi([filter("C", "StartsWith", "x"), filter("D", "EQ", "y")], false),
  ]);
  expect(JSON.parse(sent[0].args[6])).toEqual([
    [["A", "EQ", 1, null]],
    [
      ["B", "EQ", 2, null],
      ["B", "EQ", 3, null],
    ],
    [
      ["C", "StartsWith", "x", null],
      ["D", "EQ", "y", null],
    ],
  ]);
});

test("a filter of no wire form is left out, a Date goes as the model's date", () => {
  const { binding, sent } = windowed(load());
  binding.filter([
    { sPath: "X", sOperator: "EQ", fnTest: () => true },
    filter("DATE", "BT", new Date(2026, 0, 5), new Date(2026, 1, 28)),
  ]);
  expect(JSON.parse(sent[0].args[6])).toEqual([
    [["DATE", "BT", "2026-01-05", "2026-02-28"]],
  ]);
});

test("a list that is no window filters and sorts the UI5 way", () => {
  const WindowModel = load();
  const model = new WindowModel({ MT_ROWS: rows(3) });
  // a binding of the window class on a path that lost its state
  model.data.__WINDOW = { MT_ROWS: { TOTAL: 3, SIZE: 1 } };
  const binding = model.bindList("/MT_ROWS");
  delete model.data.__WINDOW;
  binding.sort([]);
  binding.filter([]);
  binding.update();
  expect(binding.baseCalls).toEqual([
    "sort",
    "filter",
    "applyFilter",
    "applySort",
  ]);
});
