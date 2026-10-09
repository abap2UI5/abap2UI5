// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// Lib.normalizeEventArgs: marshals control-valued event arguments into plain,
// serializable data. A UI5 event parameter is often a control or an array of
// controls (ViewSettingsDialog.confirm -> filterItems, Menu.itemSelected ->
// item, SinglePlanningCalendar.selectedDatesChange -> DateRange list), and
// JSON.stringify throws on a ManagedObject's circular parent/aggregation
// graph. A binding context is just as circular and becomes { PATH, OBJECT };
// a plain object or array is walked for both. Everything else - and every
// array or object with nothing inside to project - passes through untouched.

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

test("a bare Date argument travels as its LOCAL day too", () => {
  // ${$parameters>/startDate} of SinglePlanningCalendar.cellPress, or the
  // `from` of DateRangeSelection.change - a Date, not a control holding one
  const [top, list] = Lib.normalizeEventArgs([
    new Date(2018, 6, 9),
    [new Date(2018, 6, 10, 8, 30)],
  ]);
  expect(top).toEqual("2018-07-09T00:00:00");
  expect(list).toEqual(["2018-07-10T08:30:00"]);
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

// A sap.ui.model.Context stand-in: `isA`, getPath, getObject, and the model
// behind it, whose bindings point back at the context - the cycle that made
// JSON.stringify throw on `${$parameters>/rowContext}`.
function context(path, object, { objectThrows = false } = {}) {
  const model = { bindings: [] };
  const self = {
    isA: (type) => type === "sap.ui.model.Context",
    getPath: () => path,
    getObject: () => {
      if (objectThrows) throw new Error("not loaded");
      return object;
    },
    getModel: () => model,
    oModel: model,
  };
  model.bindings.push({ context: self, model });
  return self;
}

test.describe("binding contexts", () => {
  test("a context becomes its PATH and the OBJECT at that path", () => {
    const row = { NAME: "Alpha", QTY: 3 };
    const ctxArg = context("/T_TAB/3", row);
    expect(() => JSON.stringify(ctxArg)).toThrow();

    const [out] = Lib.normalizeEventArgs([ctxArg]);
    expect(out).toEqual({ PATH: "/T_TAB/3", OBJECT: row });
    expect(JSON.parse(JSON.stringify(out))).toEqual({
      PATH: "/T_TAB/3",
      OBJECT: { NAME: "Alpha", QTY: 3 },
    });
  });

  test("an array of contexts - selectedContexts - becomes an array of them", () => {
    const [out] = Lib.normalizeEventArgs([
      [context("/T/0", { K: "A" }), context("/T/1", { K: "B" })],
    ]);
    expect(out).toEqual([
      { PATH: "/T/0", OBJECT: { K: "A" } },
      { PATH: "/T/1", OBJECT: { K: "B" } },
    ]);
  });

  test("an OBJECT that throws is left out, the PATH still travels", () => {
    const [out] = Lib.normalizeEventArgs([
      context("/T/0", null, { objectThrows: true }),
    ]);
    expect(out).toEqual({ PATH: "/T/0" });
  });

  test("a Date inside the OBJECT is its local day, as everywhere else", () => {
    const [out] = Lib.normalizeEventArgs([
      context("/T/0", { D: new Date(2018, 6, 9) }),
    ]);
    expect(out.OBJECT.D).toEqual("2018-07-09T00:00:00");
  });
});

test.describe("plain objects", () => {
  test("a control or context inside one is projected, the rest kept", () => {
    // ${$parameters>/} - the whole parameter map of an event
    const params = {
      id: "tab",
      rowIndex: 3,
      listItem: control("__item3", { title: "Row" }),
      rowContext: context("/T/3", { K: "C" }),
      nested: { deep: [control("__d", { key: "D" })] },
    };
    expect(() => JSON.stringify(params)).toThrow();

    const [out] = Lib.normalizeEventArgs([params]);
    expect(out).toEqual({
      id: "tab",
      rowIndex: 3,
      listItem: { ID: "__item3", title: "Row" },
      rowContext: { PATH: "/T/3", OBJECT: { K: "C" } },
      nested: { deep: [{ ID: "__d", key: "D" }] },
    });
    expect(() => JSON.stringify(out)).not.toThrow();
    // the caller's object is not rewritten - a copy carries the projection
    expect(params.listItem.getId()).toBe("__item3");
  });

  test("plain data keeps its identity at every level", () => {
    const inner = { A: [1, 2], B: { C: "x" } };
    const arr = [inner, "y"];
    const [out] = Lib.normalizeEventArgs([arr]);
    expect(out).toBe(arr);
    expect(out[0]).toBe(inner);
  });

  test("a reference back to an ancestor - a cycle - becomes null", () => {
    const loop = { NAME: "a", item: control("__i", { key: "K" }) };
    loop.self = loop;
    const [out] = Lib.normalizeEventArgs([loop]);
    expect(out).toEqual({
      NAME: "a",
      item: { ID: "__i", key: "K" },
      self: null,
    });
    expect(() => JSON.stringify(out)).not.toThrow();
  });

  test("the same object reached twice is shared data, not a cycle", () => {
    const shared = { K: "S" };
    const [out] = Lib.normalizeEventArgs([
      { a: shared, b: shared, c: control("__c", {}) },
    ]);
    expect(out.a).toBe(shared);
    expect(out.b).toBe(shared);
  });

  test("a class instance that is no control or context is handed through", () => {
    class Thing {
      constructor() {
        this.x = 1;
      }
    }
    const thing = new Thing();
    const [out] = Lib.normalizeEventArgs([{ t: thing }]);
    expect(out.t).toBe(thing);
  });
});

// A bare `$event` in t_arg hands the UI5 event object itself to eB. It holds
// its source control - the same circular graph - so the whole request failed
// to serialize. The ABAP side documents `$event` as "a field of the UI5 event
// itself"; the event as a whole arrives as its ID, its SOURCE control's id
// and its PARAMETERS, normalized like any other value.
test.describe("the UI5 event itself ($event)", () => {
  function uiEvent(id, source, parameters, { throwOn = null } = {}) {
    const guard = (name, fn) => () => {
      if (name === throwOn) throw new Error(`${name} exploded`);
      return fn();
    };
    const ev = {
      isA: (type) => type === "sap.ui.base.Event",
      getId: guard("getId", () => id),
      getSource: guard("getSource", () => source),
      getParameters: guard("getParameters", () => parameters),
    };
    // the real Event keeps its source in a field, and the control tree leads
    // back to it - modelled as a direct back reference
    ev.oSource = { control: source, event: ev };
    return ev;
  }

  test("becomes its ID, its SOURCE id and its PARAMETERS", () => {
    const btn = control("__button0", { text: "Go" });
    const ev = uiEvent("press", btn, {});
    expect(() => JSON.stringify(ev)).toThrow();

    const [out] = Lib.normalizeEventArgs([ev]);
    expect(out).toEqual({ ID: "press", SOURCE: "__button0", PARAMETERS: {} });
    expect(JSON.parse(JSON.stringify(out))).toEqual(out);
  });

  test("a control among the parameters is projected like everywhere else", () => {
    const item = control("__item3", { title: "Row 3", selected: true });
    const ev = uiEvent("selectionChange", control("list", {}), {
      listItem: item,
      selected: true,
    });
    const [out] = Lib.normalizeEventArgs([ev]);
    expect(out.PARAMETERS).toEqual({
      listItem: { ID: "__item3", title: "Row 3", selected: true },
      selected: true,
    });
  });

  test("a getter that throws leaves its part out, the rest still travels", () => {
    const ev = uiEvent("change", control("in", {}), { value: "x" }, {
      throwOn: "getSource",
    });
    const [out] = Lib.normalizeEventArgs([ev]);
    expect(out).toEqual({ ID: "change", PARAMETERS: { value: "x" } });
  });

  test("an event without a source reports no SOURCE", () => {
    const [out] = Lib.normalizeEventArgs([uiEvent("tick", null, { n: 1 })]);
    expect(out).toEqual({ ID: "tick", PARAMETERS: { n: 1 } });
  });
});
