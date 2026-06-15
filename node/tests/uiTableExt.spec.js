// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/cc/UITableExt.js. The control reads the active
// filters/sorters of a sap.ui.table before a roundtrip (onBeforeRoundtrip)
// and re-applies them afterwards (onAfterRoundtrip), so a view rebuild does
// not drop the column filter/sort state.
//
// Two behaviors are pinned here:
//   1. Preservation: when the table binding was replaced (e.g. a fresh view
//      build produced a new, unfiltered binding) the stored filters/sorters
//      are re-applied to the new binding and reflected on the columns.
//   2. Redundancy guard: when the binding is still the exact object the
//      state was read from, re-applying is skipped - it already carries the
//      filters/sorters and re-running binding.filter()/sort() would
//      re-evaluate the whole client dataset for an identical result.

// Minimal Control.extend stub: returns a constructor whose prototype carries
// the control's methods, so the specs can instantiate it and call them.
function controlStub() {
  return {
    extend(_name, def) {
      function Ctrl() {}
      Object.assign(Ctrl.prototype, def);
      return Ctrl;
    },
  };
}

function load() {
  const errors = [];
  const callbacks = { onBeforeRoundtrip: [], onAfterRoundtrip: [] };
  const z2ui5 = {};
  // The currently resolvable MAIN-view table; tests set it via setTable.
  let currentTable = null;

  const Lib = {
    toText: (v) => (v == null ? "" : String(v)),
    logError: (m) => errors.push(m),
    registerCallback: (name, fn) => {
      (callbacks[name] = callbacks[name] || []).push(fn);
    },
    unregisterCallback: (name, fn) => {
      if (callbacks[name]) callbacks[name] = callbacks[name].filter((f) => f !== fn);
    },
    // Simulate an already-rendered control: run the work immediately.
    whenRendered: (_control, _owner, fn) => fn(),
  };

  const ViewSlots = {
    byId: (key) => (key === "MAIN" ? currentTable : undefined),
  };

  const { module: Ext } = loadModule("cc/UITableExt.js", {
    deps: {
      "sap/ui/core/Control": controlStub(),
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
    },
    sandbox: { z2ui5 },
  });

  return {
    Ext,
    errors,
    callbacks,
    setTable: (t) => {
      currentTable = t;
    },
  };
}

function makeExt(env) {
  const ext = new env.Ext();
  ext.getProperty = (name) => (name === "tableId" ? "TABLE1" : undefined);
  return ext;
}

// A fake sap.ui.table column that records the indicator setters the control
// calls on it.
function makeColumn(prop) {
  const state = {};
  return {
    state,
    getFilterProperty: () => prop,
    getSortProperty: () => prop,
    setFilterValue: (v) => (state.filterValue = v),
    setFiltered: (v) => (state.filtered = v),
    setSorted: (v) => (state.sorted = v),
    setSortOrder: (v) => (state.sortOrder = v),
    setSortIndex: (v) => (state.sortIndex = v),
  };
}

// A fake ListBinding that records filter()/sort() invocations.
function makeBinding({ filters = [], sorters = [] } = {}) {
  const calls = { filter: 0, sort: 0, lastFilters: null, lastSorters: null };
  return {
    aSorters: sorters,
    getFilters: () => filters,
    filter(f) {
      calls.filter++;
      calls.lastFilters = f;
    },
    sort(s) {
      calls.sort++;
      calls.lastSorters = s;
    },
    calls,
  };
}

// A fake table whose binding can be swapped (table._binding) to simulate a
// view rebuild that produced a fresh binding.
function makeTable(binding, columns) {
  const t = { _binding: binding, getColumns: () => columns };
  t.getBinding = () => t._binding;
  return t;
}

test.describe("callback registration", () => {
  test("init registers and exit unregisters the roundtrip hooks", () => {
    const env = load();
    const ext = makeExt(env);
    ext.init();
    expect(env.callbacks.onBeforeRoundtrip).toHaveLength(1);
    expect(env.callbacks.onAfterRoundtrip).toHaveLength(1);
    ext.exit();
    expect(env.callbacks.onBeforeRoundtrip).toHaveLength(0);
    expect(env.callbacks.onAfterRoundtrip).toHaveLength(0);
  });
});

test.describe("filter preservation across a binding rebuild", () => {
  test("re-applies stored filters to a fresh binding and flags the column", () => {
    const env = load();
    const ext = makeExt(env);
    const col = makeColumn("NAME");
    const b0 = makeBinding({
      filters: [{ sPath: "NAME", sOperator: "EQ", oValue1: "Bob" }],
    });
    const table = makeTable(b0, [col]);
    env.setTable(table);

    ext.readFilter();
    // Simulate a full view rebuild: a new, unfiltered binding takes over.
    const b1 = makeBinding({ filters: [] });
    table._binding = b1;
    ext.setFilter();

    expect(b1.calls.filter).toBe(1);
    expect(b1.calls.lastFilters).toEqual([
      { sPath: "NAME", sOperator: "EQ", oValue1: "Bob" },
    ]);
    expect(col.state.filterValue).toBe("Bob");
    expect(col.state.filtered).toBe(true);
  });

  const displayCases = [
    { name: "EQ", filter: { sPath: "C", sOperator: "EQ", oValue1: "Bob" }, display: "Bob" },
    { name: "NE", filter: { sPath: "C", sOperator: "NE", oValue1: "Bob" }, display: "!Bob" },
    { name: "GT", filter: { sPath: "C", sOperator: "GT", oValue1: "5" }, display: ">5" },
    { name: "Contains", filter: { sPath: "C", sOperator: "Contains", oValue1: "ab" }, display: "*ab*" },
    { name: "StartsWith", filter: { sPath: "C", sOperator: "StartsWith", oValue1: "ab" }, display: "^ab" },
    { name: "EndsWith", filter: { sPath: "C", sOperator: "EndsWith", oValue1: "ab" }, display: "ab$" },
    { name: "BT", filter: { sPath: "C", sOperator: "BT", oValue1: "1", oValue2: "9" }, display: "1...9" },
  ];

  for (const { name, filter, display } of displayCases) {
    test(`formats the ${name} column header as "${display}"`, () => {
      const env = load();
      const ext = makeExt(env);
      const col = makeColumn("C");
      const table = makeTable(makeBinding({ filters: [filter] }), [col]);
      env.setTable(table);

      ext.readFilter();
      table._binding = makeBinding({ filters: [] });
      ext.setFilter();

      expect(col.state.filterValue).toBe(display);
      expect(col.state.filtered).toBe(true);
    });
  }

  test("resolves path and value from the inner filter of a multi-filter", () => {
    const env = load();
    const ext = makeExt(env);
    const col = makeColumn("NAME");
    const multi = {
      aFilters: [{ sPath: "NAME", sOperator: "Contains", oValue1: "x" }],
    };
    const table = makeTable(makeBinding({ filters: [multi] }), [col]);
    env.setTable(table);

    ext.readFilter();
    table._binding = makeBinding({ filters: [] });
    ext.setFilter();

    // The operator is read from the outer (multi) filter, which has none, so
    // the value is shown verbatim - this pins the current behavior.
    expect(col.state.filterValue).toBe("x");
    expect(col.state.filtered).toBe(true);
  });
});

test.describe("sort preservation across a binding rebuild", () => {
  test("re-applies stored sorters to a fresh binding and flags the column", () => {
    const env = load();
    const ext = makeExt(env);
    const col = makeColumn("AGE");
    const b0 = makeBinding({ sorters: [{ sPath: "AGE", bDescending: true }] });
    const table = makeTable(b0, [col]);
    env.setTable(table);

    ext.readSort();
    const b1 = makeBinding({ sorters: [] });
    table._binding = b1;
    ext.setSort();

    expect(b1.calls.sort).toBe(1);
    expect(col.state.sorted).toBe(true);
    expect(col.state.sortOrder).toBe("Descending");
    expect(col.state.sortIndex).toBe(0);
  });
});

test.describe("redundancy guard: binding unchanged since read", () => {
  test("does not re-run binding.filter() and leaves columns untouched", () => {
    const env = load();
    const ext = makeExt(env);
    const col = makeColumn("NAME");
    const b0 = makeBinding({
      filters: [{ sPath: "NAME", sOperator: "EQ", oValue1: "Bob" }],
    });
    const table = makeTable(b0, [col]);
    env.setTable(table);

    ext.readFilter();
    ext.setFilter(); // binding is still b0 -> redundant, must skip

    expect(b0.calls.filter).toBe(0);
    expect(col.state.filterValue).toBeUndefined();
    expect(col.state.filtered).toBeUndefined();
  });

  test("does not re-run binding.sort() when the binding is unchanged", () => {
    const env = load();
    const ext = makeExt(env);
    const col = makeColumn("AGE");
    const b0 = makeBinding({ sorters: [{ sPath: "AGE", bDescending: false }] });
    const table = makeTable(b0, [col]);
    env.setTable(table);

    ext.readSort();
    ext.setSort(); // binding is still b0 -> redundant, must skip

    expect(b0.calls.sort).toBe(0);
    expect(col.state.sorted).toBeUndefined();
  });
});
