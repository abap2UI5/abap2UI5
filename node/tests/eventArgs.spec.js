// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// Lib.normalizeEventArgs: marshals control-valued event arguments into plain,
// serializable data. A UI5 event parameter is often a control or an array of
// controls (ViewSettingsDialog.confirm -> filterItems, Menu.itemSelected ->
// item, SinglePlanningCalendar.selectedDatesChange -> DateRange list), and
// JSON.stringify throws on a ManagedObject's circular parent/aggregation
// graph. Everything that is not a control must pass through untouched.

const { Lib } = loadLib();

// A minimal ManagedObject stand-in: `isA`, `getId`, metadata properties and a
// getProperty that reads them.
function control(id, properties, { throwOn = null } = {}) {
  const own = { ...properties };
  const parent = { child: null };
  const self = {
    isA: (type) => type === "sap.ui.base.ManagedObject",
    getId: () => id,
    getMetadata: () => ({
      getAllProperties: () =>
        Object.keys(own).reduce((acc, k) => ({ ...acc, [k]: {} }), {}),
    }),
    getProperty: (name) => {
      if (name === throwOn) throw new Error("getter exploded");
      return own[name];
    },
    // the circular reference that made JSON.stringify throw
    getParent: () => parent,
  };
  parent.child = self;
  return self;
}

test("a plain string argument is untouched", () => {
  expect(Lib.normalizeEventArgs(["A", "B"])).toEqual(["A", "B"]);
});

test("numbers, booleans and null pass through", () => {
  expect(Lib.normalizeEventArgs([1, true, null, ""])).toEqual([
    1,
    true,
    null,
    "",
  ]);
});

test("the backend event array in args[0] is untouched", () => {
  const eventArray = ["MY_EVENT", false, false, false];
  const [head] = Lib.normalizeEventArgs([eventArray, "X"]);
  expect(head).toEqual(eventArray);
});

test("a single control becomes its id plus its properties", () => {
  const result = Lib.normalizeEventArgs([
    control("__item0", { key: "K1", text: "City", selected: true }),
  ]);

  expect(result[0]).toEqual({
    ID: "__item0",
    key: "K1",
    text: "City",
    selected: true,
  });
});

test("an array of controls becomes an array of plain objects", () => {
  const result = Lib.normalizeEventArgs([
    [
      control("__i0", { key: "A", text: "Alpha" }),
      control("__i1", { key: "B", text: "Beta" }),
    ],
  ]);

  expect(result[0]).toEqual([
    { ID: "__i0", key: "A", text: "Alpha" },
    { ID: "__i1", key: "B", text: "Beta" },
  ]);
});

test("the marshalled result survives JSON.stringify", () => {
  // the whole point: the raw control throws here because of getParent
  const raw = control("__i0", { key: "A" });
  const cyclic = { c: raw, back: null };
  cyclic.back = cyclic;
  expect(() => JSON.stringify(cyclic)).toThrow();

  const result = Lib.normalizeEventArgs([[raw]]);
  expect(() => JSON.stringify(result)).not.toThrow();
  expect(JSON.parse(JSON.stringify(result))[0][0].key).toBe("A");
});

test("a property whose getter throws is skipped, the rest survives", () => {
  const result = Lib.normalizeEventArgs([
    control("__i0", { key: "A", broken: "x", text: "T" }, { throwOn: "broken" }),
  ]);

  expect(result[0]).toEqual({ ID: "__i0", key: "A", text: "T" });
});

test("an undefined property value is omitted", () => {
  const result = Lib.normalizeEventArgs([
    control("__i0", { key: "A", text: undefined }),
  ]);

  expect(result[0]).toEqual({ ID: "__i0", key: "A" });
});

test("a control with no properties still reports its id", () => {
  expect(Lib.normalizeEventArgs([control("__i0", {})])[0]).toEqual({
    ID: "__i0",
  });
});

test("a plain model object is NOT projected", () => {
  const payload = { TYPE: "local", VALUE: { FIELD1: 1 } };
  const [result] = Lib.normalizeEventArgs([payload]);
  expect(result).toBe(payload);
});

test("nested arrays of controls are marshalled at every level", () => {
  const result = Lib.normalizeEventArgs([
    [[control("__deep", { key: "D" })]],
  ]);
  expect(result[0][0][0]).toEqual({ ID: "__deep", key: "D" });
});

test("recursion stops at the depth cap instead of running away", () => {
  // build an array nested deeper than MAX_ARG_DEPTH (4); the control past the
  // cap is handed through as-is rather than recursed into forever
  let nested = control("__tooDeep", { key: "X" });
  for (let i = 0; i < 8; i++) nested = [nested];

  expect(() => Lib.normalizeEventArgs([nested])).not.toThrow();
});

test("a fresh top-level array is returned - Server.roundtrip shifts it", () => {
  const args = ["A", "B"];
  const result = Lib.normalizeEventArgs(args);

  expect(result).not.toBe(args);
  result.shift();
  expect(args).toEqual(["A", "B"]);
});
