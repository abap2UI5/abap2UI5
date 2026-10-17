// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests the real implementation shipped in
// app/webapp/devtools/Journey.js (loaded via a stubbed sap.ui.define): a
// click-through recorded as steps, exported as an ABAP Unit test class
// that replays it on z2ui5_cl_frontend_simulator.
//
// The recorder observes the framework from the outside - through the
// onAfterRendering callback array of its component context - so the
// harness builds one spec context with the real core/Lib on it and plays
// the roundtrips by seeding the request and response the way
// Server.readHttp parks them, then running the callbacks the way
// View1._processAfterRendering does. devtools/Recorder.js is loaded for
// real: its two response readers are what the steps are built from.

function loadJourney() {
  const { Lib, ctx, state } = loadLib({
    state: { responseData: null, oBody: null, url: "/sap/z2ui5" },
  });
  const { module } = loadModule("devtools/Journey.js", {
    autoLoad: true,
    deps: { "z2ui5/core/Lib": Lib },
    sandbox: {
      window: { location: { href: "https://sap.example.com/ui5/" } },
      performance: { now: () => 0, timeOrigin: 0 },
    },
  });

  // One roundtrip: the request body and the response, then the render.
  function roundtrip({ event = "", args, model, response }) {
    const body = { S_FRONT: { ID: "draft", EVENT: event } };
    if (args) body.S_FRONT.T_EVENT_ARG = args;
    if (model !== undefined) body.MODEL = model;
    state.oBody = body;
    state.responseData = response;
    for (const fn of state.onAfterRendering || []) fn();
  }

  return { Journey: module, ctx, state, roundtrip, logged: Lib.errors };
}

// A response as the backend sends it: the views it displays, the slots it
// destroys, the messages it shows.
function response({
  app = "ZCL_APP",
  main,
  popup,
  popover,
  nest,
  destroy = [],
  toast,
  box,
  model,
} = {}) {
  const system = [];
  if (main) system.push(["VIEW_SLOTS", "display", "MAIN", main]);
  if (nest) system.push(["VIEW_SLOTS", "display", "NEST", nest]);
  if (popup) system.push(["VIEW_SLOTS", "display", "POPUP", popup]);
  if (popover) system.push(["VIEW_SLOTS", "display", "POPOVER", popover]);
  for (const slot of destroy) system.push(["VIEW_SLOTS", "destroy", slot]);
  const custom = [];
  if (toast) custom.push(["MESSAGE_TOAST", "show", toast]);
  if (box) custom.push(["CONTROL_GLOBAL", "MESSAGE_BOX", "error", box]);
  const out = {
    S_FRONT: {
      ID: "draft-new",
      APP: app,
      S_ACTION: { T_SYSTEM: system, T_CUSTOM: custom },
    },
  };
  if (model !== undefined) out.MODEL = model;
  return out;
}

const MAIN_XML =
  '<mvc:View xmlns="sap.m"><Page title="Example"><Input id="inputName" width="100%" value="{/MV_NAME}"/>' +
  '<Button text="Greet" press=".eB([&apos;GREET&apos;])"/>' +
  '<Button text="Clear" press=".eB([&apos;CLEAR&apos;])"/></Page></mvc:View>';
const MAIN_NO_IDS =
  '<mvc:View xmlns="sap.m"><Button text="Open" press=".eB([&apos;POPUP_OPEN&apos;])"/>' +
  '<Button text="Row" press=".eBP($event,true,[&apos;ROW&apos;],$event.oSource.getBindingContext())"/></mvc:View>';
const POPUP_XML =
  '<core:FragmentDefinition><Dialog id="dlg"><Button text="Ok" press=".eB([&apos;POPUP_CONFIRM&apos;])"/></Dialog></core:FragmentDefinition>';

// The whole flow the README of the headless frontend shows, recorded from
// the start screen.
function recordGreeting(h) {
  h.state.oBody = { S_FRONT: { ID: "", EVENT: "" } };
  h.state.responseData = response({ main: MAIN_XML });
  h.Journey.start(h.ctx);
  h.roundtrip({
    event: "GREET",
    model: { MV_NAME: "World" },
    response: response({
      toast: "Hello World!",
      model: { MV_NAME: "World", MV_GREETING: "Hello World!" },
    }),
  });
  h.Journey.stop(h.ctx);
}

test.describe("recording", () => {
  test("start takes the current screen as step 1 and every roundtrip after it", () => {
    const h = loadJourney();
    expect(h.Journey.isRecording(h.ctx)).toBe(false);
    recordGreeting(h);

    const journeys = h.Journey.getJourneys(h.ctx);
    expect(journeys).toHaveLength(1);
    expect(journeys[0].app).toBe("ZCL_APP");
    const [first, second] = journeys[0].steps;
    expect(first.seq).toBe(1);
    expect(first.event).toBe("");
    expect(first.views).toEqual([
      { slot: "MAIN", ids: ["inputName"], events: ["GREET", "CLEAR"] },
    ]);
    expect(second.seq).toBe(2);
    expect(second.event).toBe("GREET");
    expect(second.delta).toEqual({ value: { MV_NAME: "World" } });
    expect(second.messages).toEqual(["Hello World!"]);
    expect(second.views).toEqual([]);
    expect(h.Journey.stepCount(h.ctx)).toBe(2);
  });

  test("a roundtrip after stop is not recorded, and the hook is gone", () => {
    const h = loadJourney();
    recordGreeting(h);
    expect(h.state.onAfterRendering).toHaveLength(0);
    h.roundtrip({ event: "CLEAR", response: response() });
    expect(h.Journey.stepCount(h.ctx)).toBe(2);
  });

  test("a second recording is a second journey; Clear drops both", () => {
    const h = loadJourney();
    recordGreeting(h);
    h.Journey.start(h.ctx);
    h.roundtrip({ event: "CLEAR", response: response() });
    expect(h.Journey.getJourneys(h.ctx)).toHaveLength(2);
    expect(h.Journey.isRecording(h.ctx)).toBe(true);
    h.Journey.clear(h.ctx);
    expect(h.Journey.getJourneys(h.ctx)).toEqual([]);
    expect(h.Journey.isRecording(h.ctx)).toBe(false);
    expect(h.state.onAfterRendering).toHaveLength(0);
  });

  test("a recording that saw no roundtrip is no journey", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    h.Journey.stop(h.ctx);
    expect(h.Journey.getJourneys(h.ctx)).toEqual([]);
  });

  test("the delta is copied, not referenced - the live model moves on", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    const model = { MT_ROW: { __delta: { 0: { QTY: "3" } } } };
    h.roundtrip({ event: "SAVE", model, response: response() });
    model.MT_ROW.__delta[0].QTY = "changed";
    expect(h.Journey.getJourneys(h.ctx)[0].steps[0].delta).toEqual({
      value: { MT_ROW: { __delta: { 0: { QTY: "3" } } } },
    });
  });

  test("a delta over the size cap is dropped with a reason, the step kept", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    h.roundtrip({
      event: "SAVE",
      model: { MT_BIG: "x".repeat(h.Journey._internals.MAX_DELTA_CHARS) },
      response: response(),
    });
    const step = h.Journey.getJourneys(h.ctx)[0].steps[0];
    expect(step.event).toBe("SAVE");
    expect(step.delta.dropped).toContain("characters");
    expect(h.Journey.buildAbapUnit(h.ctx)).toContain(
      '" model changes not replayed',
    );
  });

  test("the step cap stops the recording from growing, and the export says so", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    for (let i = 0; i < h.Journey._internals.MAX_STEPS + 3; i++) {
      h.roundtrip({ event: "NEXT", response: response() });
    }
    const journey = h.Journey.getJourneys(h.ctx)[0];
    expect(journey.steps).toHaveLength(h.Journey._internals.MAX_STEPS);
    expect(journey.overflow).toBe(true);
    expect(h.Journey.buildAbapUnit(h.ctx)).toContain("stopped taking steps");
  });

  test("a malformed roundtrip is taken as it is and never reaches the app", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    // a response whose action list is not an array of arrays, and a
    // request that is not an object
    h.state.oBody = "garbage";
    h.state.responseData = {
      S_FRONT: { S_ACTION: { T_SYSTEM: 42, T_CUSTOM: "x" } },
    };
    expect(() => {
      for (const fn of h.state.onAfterRendering) fn();
    }).not.toThrow();
    expect(h.Journey.stepCount(h.ctx)).toBe(1);
  });
});

test.describe("the exported ABAP Unit class", () => {
  test("replays the greeting flow: start, set_value, click, the toast", () => {
    const h = loadJourney();
    recordGreeting(h);
    const abap = h.Journey.buildAbapUnit(h.ctx);
    expect(abap).toBe(
      [
        '" Journey of ZCL_APP, recorded with the abap2UI5 developer tools (Ctrl+F12, Roundtrips > Journey).',
        '" Replays it on z2ui5_cl_frontend_simulator - https://github.com/abap2UI5/headless-frontend -',
        "\" in the app's test include: no browser, no HTTP, the real handler and the real main( ).",
        '" The test starts the app fresh and replays what the user typed (set_value / set_json / set_cell)',
        '" and pressed (click); the assertions name the messages, layers, ids and events the screens showed.',
        '" What never reached the backend is not here: a popup closed in the browser alone, a frontend action.',
        '" DANGEROUS because a draft-based app writes Z2UI5_T_01 - install the in-memory store the',
        '" headless-frontend README shows to make it HARMLESS.',
        "CLASS ltcl_journey DEFINITION FINAL",
        "  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.",
        "",
        "  PRIVATE SECTION.",
        "    METHODS journey_1 FOR TESTING RAISING cx_static_check.",
        "ENDCLASS.",
        "",
        "",
        "CLASS ltcl_journey IMPLEMENTATION.",
        "",
        "  METHOD journey_1.",
        "",
        "    DATA(sim) = z2ui5_cl_frontend_simulator=>start( `ZCL_APP` ).",
        "    cl_abap_unit_assert=>assert_equals( exp = `MAIN`",
        "                                        act = sim->get_layer( ) ).",
        "    cl_abap_unit_assert=>assert_true( sim->check_id_exists( `inputName` ) ).",
        "",
        '    " step 2: GREET',
        "    sim->set_value( name  = `MV_NAME`",
        "                    value = `World` ).",
        "    sim->click( `GREET` ).",
        "    cl_abap_unit_assert=>assert_equals( exp = `Hello World!`",
        "                                        act = sim->get_message( ) ).",
        "",
        "  ENDMETHOD.",
        "",
        "ENDCLASS.",
      ].join("\n"),
    );
  });

  test("a view without ids is asserted by its events, a popup by its layer, a close by get_popup", () => {
    const h = loadJourney();
    h.state.responseData = response({ main: MAIN_NO_IDS });
    h.Journey.start(h.ctx);
    h.roundtrip({
      event: "POPUP_OPEN",
      response: response({ popup: POPUP_XML }),
    });
    h.roundtrip({
      event: "POPUP_CONFIRM",
      model: { MV_POPUP_TEXT: "Bea" },
      response: response({ destroy: ["POPUP"], box: "Saved" }),
    });
    h.Journey.stop(h.ctx);
    const abap = h.Journey.buildAbapUnit(h.ctx);
    // the start screen: no ids, so the events it wires - the prevent-default
    // wire (.eBP) included
    expect(abap).toContain(
      "cl_abap_unit_assert=>assert_true( sim->check_event_exists( `POPUP_OPEN` ) ).",
    );
    expect(abap).toContain(
      "cl_abap_unit_assert=>assert_true( sim->check_event_exists( `ROW` ) ).",
    );
    // the popup: its layer and its id
    expect(abap).toContain(
      "    sim->click( `POPUP_OPEN` ).\n" +
        "    cl_abap_unit_assert=>assert_equals( exp = `POPUP`\n" +
        "                                        act = sim->get_layer( ) ).\n" +
        "    cl_abap_unit_assert=>assert_true( sim->check_id_exists( `dlg` ) ).",
    );
    // the close: the message box text, then the popup gone
    expect(abap).toContain(
      "    sim->click( `POPUP_CONFIRM` ).\n" +
        "    cl_abap_unit_assert=>assert_equals( exp = `Saved`\n" +
        "                                        act = sim->get_message( ) ).\n" +
        "    cl_abap_unit_assert=>assert_initial( sim->get_popup( ) ).",
    );
  });

  test("event arguments travel as t_arg, a changed app is asserted", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    h.roundtrip({
      event: "ROW",
      args: ["2", { PATH: "/MT_ROW/1" }],
      response: response({ app: "ZCL_DETAIL", main: MAIN_XML }),
    });
    h.Journey.stop(h.ctx);
    const abap = h.Journey.buildAbapUnit(h.ctx);
    // started with the app of the first step
    expect(abap).toContain(
      "z2ui5_cl_frontend_simulator=>start( `ZCL_DETAIL` )",
    );
    expect(abap).toContain(
      "the recording began after roundtrips this test does not replay",
    );
    expect(abap).toContain(
      "    sim->click( event = `ROW`\n" +
        "                t_arg = VALUE #( ( `2` )\n" +
        '                                 ( `{"PATH":"/MT_ROW/1"}` ) ) ).',
    );
    // the app did not change between the first step and this one - the
    // first step IS this one - so no get_app( ) assertion
    expect(abap).not.toContain("get_app");
    expect(abap).toContain("assert_equals( exp = `MAIN`");
  });

  test("an app switch mid-journey asserts get_app( )", () => {
    const h = loadJourney();
    h.state.responseData = response({ app: "ZCL_A", main: MAIN_XML });
    h.Journey.start(h.ctx);
    h.roundtrip({
      event: "CALL",
      response: response({ app: "ZCL_B", main: MAIN_NO_IDS }),
    });
    h.Journey.stop(h.ctx);
    expect(h.Journey.buildAbapUnit(h.ctx)).toContain(
      "    cl_abap_unit_assert=>assert_equals( exp = `ZCL_B`\n" +
        "                                        act = sim->get_app( ) ).",
    );
  });

  test("a roundtrip without an event after the first is a comment, not a click", () => {
    const h = loadJourney();
    h.state.responseData = response({ main: MAIN_XML });
    h.Journey.start(h.ctx);
    h.roundtrip({ event: "", response: response({ main: MAIN_XML }) });
    h.Journey.stop(h.ctx);
    const abap = h.Journey.buildAbapUnit(h.ctx);
    expect(abap).toContain(
      '" step 2: a roundtrip without an event (reload, navigation) - not replayed',
    );
    expect(abap.match(/sim->click/g)).toBeNull();
  });

  test("two journeys are two test methods; none is a class with a hint", () => {
    const h = loadJourney();
    expect(h.Journey.buildAbapUnit(h.ctx)).toContain(
      '" no journey recorded yet',
    );
    recordGreeting(h);
    h.Journey.start(h.ctx);
    h.roundtrip({ event: "CLEAR", response: response() });
    h.Journey.stop(h.ctx);
    const abap = h.Journey.buildAbapUnit(h.ctx);
    expect(abap).toContain(
      "    METHODS journey_1 FOR TESTING RAISING cx_static_check.",
    );
    expect(abap).toContain(
      "    METHODS journey_2 FOR TESTING RAISING cx_static_check.",
    );
    expect(abap).toContain("  METHOD journey_2.");
    expect(h.Journey.exportFileName(h.ctx)).toBe(
      "zcl_app_journey.clas.testclasses.abap",
    );
  });

  test("no line of the export is longer than an ABAP line", () => {
    const h = loadJourney();
    h.Journey.start(h.ctx);
    h.roundtrip({
      event: "SAVE",
      model: {
        MV_LONG: "word ".repeat(80),
        MT_ROW: { __delta: { 2: { NOTE: "note ".repeat(60) } } },
      },
      response: response({ toast: "t".repeat(400) }),
    });
    h.Journey.stop(h.ctx);
    const abap = h.Journey.buildAbapUnit(h.ctx);
    for (const line of abap.split("\n"))
      expect(line.length).toBeLessThanOrEqual(255);
    // the long value is one literal split with &&
    expect(abap).toContain("` &&\n");
  });

  test("a long literal is never cut inside a doubled backtick", () => {
    const h = loadJourney();
    const { literal } = h.Journey._internals;
    // the cut at 100 falls between two pairs, at 99 inside one, at 101 after
    // a pair that starts at 100 - every chunk must hold whole pairs
    for (const value of [
      "a".repeat(98) + "``" + "b".repeat(20),
      "a".repeat(99) + "`" + "b".repeat(20),
      "a".repeat(100) + "`" + "b".repeat(20),
    ]) {
      const chunks = literal(value, 4).split(" &&\n    ");
      for (const chunk of chunks) {
        const inner = chunk.slice(1, -1);
        expect(chunk[0]).toBe("`");
        expect(chunk[chunk.length - 1]).toBe("`");
        for (const run of inner.match(/`+/g) || [])
          expect(run.length % 2).toBe(0);
      }
      const joined = chunks.map((c) => c.slice(1, -1)).join("");
      expect(joined).toBe(value.replace(/`/g, "``"));
    }
  });
});

test.describe("the setters for a model delta", () => {
  test("every shape of the frontend's delta has its simulator call", () => {
    const h = loadJourney();
    const lines = h.Journey._internals.editStatements(
      {
        value: {
          MV_TEXT: "plain",
          MV_TICK: "it`s",
          MV_FLAG: true,
          MV_OFF: false,
          MV_NUM: 42,
          MT_KEYS: ["A", "C"],
          MS_HEAD: { NAME: "Max", QTY: 3 },
          MV_MULTI: "line one\nline two",
          MT_ROW: {
            __delta: {
              0: { QTY: "3", SELKZ: true },
              2: { NAME: "Pen", T_SUB: { __delta: { 1: { COL: "x", N: 7 } } } },
            },
          },
        },
      },
      4,
    );
    expect(lines).toEqual([
      "    sim->set_value( name  = `MV_TEXT`",
      "                    value = `plain` ).",
      "    sim->set_value( name  = `MV_TICK`",
      "                    value = `it``s` ).",
      "    sim->set_bool( name  = `MV_FLAG`",
      "                   value = abap_true ).",
      "    sim->set_bool( name  = `MV_OFF`",
      "                   value = abap_false ).",
      "    sim->set_json( path = `/MV_NUM`",
      "                   json = `42` ).",
      "    sim->set_json( path = `/MT_KEYS`",
      '                   json = `["A","C"]` ).',
      "    sim->set_json( path = `/MS_HEAD`",
      '                   json = `{"NAME":"Max","QTY":3}` ).',
      "    sim->set_json( path = `/MV_MULTI`",
      '                   json = `"line one\\nline two"` ).',
      "    sim->set_cell( table  = `MT_ROW`",
      "                   row    = 1",
      "                   column = `QTY`",
      "                   value  = `3` ).",
      "    sim->set_json( path = `/MT_ROW/0/SELKZ`",
      "                   json = `true` ).",
      "    sim->set_cell( table  = `MT_ROW`",
      "                   row    = 3",
      "                   column = `NAME`",
      "                   value  = `Pen` ).",
      "    sim->set_json( path = `/MT_ROW/2/T_SUB/1/COL`",
      '                   json = `"x"` ).',
      "    sim->set_json( path = `/MT_ROW/2/T_SUB/1/N`",
      "                   json = `7` ).",
    ]);
  });

  test("the two XML readers match the simulator's: ids by attribute, events by wire", () => {
    const h = loadJourney();
    const { idsOf, eventsOf } = h.Journey._internals;
    expect(idsOf(MAIN_XML)).toEqual(["inputName"]);
    expect(
      idsOf(
        '<A id="x"/><B tooltipId="no" width="100%" id="x"/><C id="a&amp;b"/>',
      ),
    ).toEqual(["x", "a&b"]);
    expect(eventsOf(MAIN_XML)).toEqual(["GREET", "CLEAR"]);
    expect(eventsOf(MAIN_NO_IDS)).toEqual(["POPUP_OPEN", "ROW"]);
    expect(eventsOf("")).toEqual([]);
  });
});

test.describe("the tab", () => {
  test("renders the state, the hint and every step", () => {
    const h = loadJourney();
    expect(h.Journey.formatJourney(h.ctx)).toContain(
      "(no journey recorded yet)",
    );
    recordGreeting(h);
    const text = h.Journey.formatJourney(h.ctx);
    expect(text).toContain(
      "Journey recorder - OFF (2 step(s) in 1 journey(s))",
    );
    expect(text).toContain("Journey 1 - ZCL_APP - 2 step(s)");
    expect(text).toContain("#1   (start)");
    expect(text).toContain("screen: MAIN ids: inputName");
    expect(text).toContain("#2   GREET");
    expect(text).toContain('typed:  MV_NAME = "World"');
    expect(text).toContain('message "Hello World!"');
    h.Journey.start(h.ctx);
    expect(h.Journey.formatJourney(h.ctx)).toContain("RECORDING");
  });
});
