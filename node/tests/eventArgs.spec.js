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

/* A Date property carries a CALENDAR DAY the user picked in their own zone -
 * UI5 fills DateRange.startDate & co. with LOCAL midnight. Serialized through
 * JSON.stringify it went out as toISOString(), i.e. UTC, so east of Greenwich
 * the DAY was the previous one. These pin the local-parts projection, and the
 * DST case is in because a fixed +offset would get it wrong. */
test("a Date property travels as its LOCAL day, not as a UTC instant", () => {
  const c = control("cal", { startDate: new Date(2018, 6, 9) });
  const [out] = Lib.normalizeEventArgs([c]);
  expect(out.startDate).toEqual("2018-07-09T00:00:00");
});

test("the local time of day survives too", () => {
  const c = control("appt", { startDate: new Date(2018, 6, 9, 14, 5, 30) });
  const [out] = Lib.normalizeEventArgs([c]);
  expect(out.startDate).toEqual("2018-07-09T14:05:30");
});

test("a date on the other side of a DST change keeps its own day", () => {
  // late January and late July differ by an hour wherever DST applies; both
  // have to report the day the control holds
  const winter = control("a", { d: new Date(2018, 0, 28) });
  const summer = control("b", { d: new Date(2018, 6, 28) });
  expect(Lib.normalizeEventArgs([winter])[0].d).toEqual("2018-01-28T00:00:00");
  expect(Lib.normalizeEventArgs([summer])[0].d).toEqual("2018-07-28T00:00:00");
});

test("an INVALID Date is left to the existing path, reaching the wire as null", () => {
  // UI5 produces one for an empty optional date. The projection must not turn
  // it into the four words "Invalid Date" - it is left alone, and Date.toJSON
  // yields null for it, which is what the curated formatter's
  // DateCreateObject returns for a falsy input. Assert the WIRE, since that
  // is where the contract lives: String() on any invalid Date says
  // "Invalid Date" whether it was projected or not.
  const c = control("dp", { dateValue: new Date("") });
  const [out] = Lib.normalizeEventArgs([c]);
  expect(typeof out.dateValue).not.toEqual("string");
  expect(JSON.parse(JSON.stringify(out)).dateValue).toEqual(null);
});

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
