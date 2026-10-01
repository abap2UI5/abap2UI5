// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/AppState.js: the SHAPE of a component's
// state - createState( ) and its defaults. The instance lives on the
// component's context (core/Context.js, context.spec.js); this module keeps
// no state of its own and puts nothing on the global object. `window` is
// the sandbox global itself (see loadModule.js), exactly like in a browser.

function load(sandbox = {}) {
  const { module, sandbox: ctx } = loadModule("core/AppState.js", {
    sandbox,
  });
  return { AppState: module, ctx };
}

test.describe("createState", () => {
  test("installs the defaults for every field", () => {
    const { AppState } = load();
    const state = AppState.createState();
    expect(state.checkLocal).toBe(false);
    expect(state.endpoint).toBeNull();
    expect(state.url).toBeNull();
    expect(state.oConfig).toEqual({});
    expect(state.ccResourceRoot).toBeNull();
    expect(state.cccResourceRoot).toBeNull();
    expect(state.nodePath).toBeNull();
    expect(state.isBusy).toBe(false);
    expect(state.oView).toBeNull();
    expect(state.timers).toEqual({});
    expect(state.viewSizeLimits).toEqual({});
    expect(state.slotXml).toEqual({});
    expect(state.slotApp).toEqual({});
    expect(state.onBeforeRoundtrip).toEqual([]);
    expect(state.oSentModel).toBeNull();
  });

  test("every call answers fresh containers, never shared ones", () => {
    // Context.destroy rebuilds a dead context's state from here: a container
    // shared between two calls would let the old state leak into the new
    const { AppState } = load();
    const a = AppState.createState();
    const b = AppState.createState();
    a.errors?.push?.("x");
    a.timers.TICK = 1;
    a.odataClients.add({});
    expect(b.timers).toEqual({});
    expect(b.odataClients.size).toBe(0);
    expect(b.onAfterRendering).not.toBe(a.onAfterRendering);
  });

  test("the records keyed off the wire are prototype-less", () => {
    // a timer key, a shortcut combo, a view key or a tree id that spells a
    // property Object.prototype carries must be a miss, not a wrong answer
    const { AppState } = load();
    const state = AppState.createState();
    for (const name of ["timers", "shortcuts", "viewSizeLimits", "treeStates"]) {
      expect(Object.getPrototypeOf(state[name])).toBeNull();
      expect(state[name]["constructor"]).toBeUndefined();
    }
  });

  test("the error log is not a state field - it is Lib's page-wide ring", () => {
    const { AppState } = load();
    expect("errors" in AppState.createState()).toBe(false);
  });

  test("exposes the shape and no state of its own", () => {
    const { AppState } = load();
    // createState, and for the in-place restart of an embedded app
    // resetApp with the fields it keeps - no state object among them
    expect(Object.keys(AppState)).toEqual([
      "createState",
      "resetApp",
      "COMPONENT_FIELDS",
    ]);
  });

  test("puts no z2ui5 object on the global", () => {
    const { AppState, ctx } = load();
    AppState.createState().url = "/sap/z2ui5";
    expect(ctx.z2ui5).toBeUndefined();
  });
});

// The restart of an embedded app in place (Context.resetApp): every field of
// the APP back at its default, in the SAME state object every module holds;
// the component's own - configuration, the shell's UI5 objects, the
// callback arrays other modules registered into - stay.
test("resetApp resets the app's fields in place and keeps the component's", () => {
  const { module: AppState } = loadModule("core/AppState.js");
  const state = AppState.createState();
  const hook = () => {};
  Object.assign(state, {
    embedded: true,
    url: "/sap/bc/z2ui5",
    oConfig: { ComponentData: { startupParameters: {} } },
    oApp: { id: "app" },
    oController: { old: true },
    oView: { id: "mainView" },
    oResponse: { ID: "draft" },
    contextId: "SID:ANON:x",
    renderedApp: "ZCL_APP",
    lastError: { title: "t" },
  });
  state.onErrorDetails.push(hook);
  state.timers.poll = 1;

  AppState.resetApp(state);

  expect(state.embedded).toBe(true);
  expect(state.url).toBe("/sap/bc/z2ui5");
  expect(state.oConfig.ComponentData).toEqual({ startupParameters: {} });
  expect(state.oApp).toEqual({ id: "app" });
  expect(state.onErrorDetails).toEqual([hook]);
  // the app's
  expect(state.oController).toBe(null);
  expect(state.oView).toBe(null);
  expect(state.oResponse).toBe(null);
  expect(state.contextId).toBe(null);
  expect(state.renderedApp).toBe(null);
  expect(state.lastError).toBe(null);
  expect(Object.keys(state.timers)).toEqual([]);
  // every field it keeps exists in the state - a renamed field cannot
  // silently turn into one that restarts with the app
  for (const field of AppState.COMPONENT_FIELDS) {
    expect(field in AppState.createState()).toBe(true);
  }
});
