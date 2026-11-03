// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { classEnv } = require("./loadLibModule");

// core/WindowModel.js: the list binding of a windowed table. The UI5 base
// classes are stood in for by the few members the module overrides or
// reads - a JSONListBinding that holds the array behind its path and hands
// out its rows as contexts - so what is pinned is the module's own part:
// which binding a path gets, when the backend is asked for rows, and what
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
    __WINDOW: { MT_ROWS: { TOTAL: total, COUNT: loaded, SIZE: size } },
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
    __WINDOW: { MR_TAB: { "*": { TOTAL: 40, COUNT: 10, SIZE: 10 } } },
  });
  const sent = [];
  model._z2ui5WindowSend = (args) => sent.push(args);
  const binding = model.bindList("/MR_TAB/*");
  expect(binding.getLength()).toBe(40);
  binding.getContexts(0, 15);
  expect(sent[0].slice(0, 2)).toEqual(["/MR_TAB/*", "20"]);
});

test("a windowed list counts the rows of the server, not the ones it holds", () => {
  const { binding } = windowed(load());
  expect(binding.getLength()).toBe(250);
  expect(binding.isLengthFinal()).toBe(true);
  // the browser neither filters nor sorts what the server ordered
  expect(binding.baseCalls).toEqual([]);
});

test("contexts past the window ask for whole windows, once", () => {
  const { binding, sent } = windowed(load());
  expect(binding.getContexts(0, 40)).toHaveLength(40);
  expect(sent).toEqual([]);

  expect(binding.getContexts(0, 60)).toHaveLength(50);
  expect(sent).toHaveLength(1);
  expect(sent[0].args.slice(0, 2)).toEqual(["/MT_ROWS", "100"]);
  // growing is no reason for the busy overlay
  expect(sent[0].noBusy).toBe(true);

  // asked already - the same need does not go out again
  binding.getContexts(0, 80);
  expect(sent).toHaveLength(1);

  // a threshold counts as needed rows; never past the total
  binding.getContexts(200, 40, 100);
  expect(sent).toHaveLength(2);
  expect(sent[1].args[1]).toBe("250");
});

test("a model push lets the binding ask again", () => {
  const { model, binding, sent } = windowed(load());
  binding.getContexts(0, 60);
  model.data.MT_ROWS = rows(100);
  model.data.__WINDOW.MT_ROWS.COUNT = 100;
  binding.update();
  expect(binding.getContexts(0, 60)).toHaveLength(60);
  binding.getContexts(0, 120);
  expect(sent.map((s) => s.args[1])).toEqual(["100", "150"]);
});

test("nothing is asked when the table holds all rows", () => {
  const { binding, sent } = windowed(load(), { loaded: 30, total: 30 });
  binding.getContexts(0, 100);
  expect(sent).toEqual([]);
});

test("a sort goes to the server and starts over with one window", () => {
  const { binding, sent } = windowed(load());
  binding.getContexts(0, 60);
  binding.sort([{ sPath: "PRICE", bDescending: true }, { sPath: "ID" }]);
  expect(binding.baseCalls).toEqual([]);
  const last = sent[sent.length - 1];
  expect(last.noBusy).toBe(false);
  expect(last.args[1]).toBe("50");
  expect(JSON.parse(last.args[2])).toEqual([
    { PATH: "PRICE", DESCENDING: true },
    { PATH: "ID", DESCENDING: false },
  ]);
  expect(JSON.parse(last.args[3])).toEqual([]);
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
  expect(JSON.parse(sent[1].args[3])).toEqual([
    [
      ["NAME", "Contains", "ab", null],
      ["NAME", "Contains", "cd", null],
    ],
    [["PRICE", "GT", 10, null]],
    [["ID", "LE", 100, null]],
  ]);
  // the sort stays what it was
  expect(JSON.parse(sent[1].args[2])).toEqual([]);
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
  expect(JSON.parse(sent[0].args[3])).toEqual([
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
  expect(JSON.parse(sent[0].args[3])).toEqual([
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
