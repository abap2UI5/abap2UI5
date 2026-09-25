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

  test("exposes nothing but createState, and no state of its own", () => {
    const { AppState } = load();
    expect(Object.keys(AppState)).toEqual(["createState"]);
  });

  test("puts no z2ui5 object on the global", () => {
    const { AppState, ctx } = load();
    AppState.createState().url = "/sap/z2ui5";
    expect(ctx.z2ui5).toBeUndefined();
  });
});
