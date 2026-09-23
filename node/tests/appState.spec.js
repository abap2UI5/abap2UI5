// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/AppState.js: the defaults, the live `state`
// export and reset behavior - and that the module puts nothing on the
// global object. `window` is the sandbox global itself (see loadModule.js),
// exactly like in a browser.

function load(sandbox = {}) {
  const { module, sandbox: ctx } = loadModule("core/AppState.js", {
    sandbox,
  });
  return { AppState: module, ctx };
}

test.describe("defaults", () => {
  test("installs the defaults for every field", () => {
    const { AppState } = load();
    const state = AppState.state;
    expect(state.checkLocal).toBe(false);
    expect(state.url).toBeNull();
    expect(state.oConfig).toEqual({});
    expect(state.ccResourceRoot).toBeNull();
    expect(state.cccResourceRoot).toBeNull();
    expect(state.isBusy).toBe(false);
    expect(state.oView).toBeNull();
    expect(state.errors).toEqual([]);
    expect(state.timers).toEqual({});
    expect(state.viewSizeLimits).toEqual({});
    expect(state.onBeforeRoundtrip).toEqual([]);
    expect(state.oSentModel).toBeNull();
  });

  test("exposes nothing but reset and state", () => {
    const { AppState } = load();
    expect(Object.keys(AppState).sort()).toEqual(["reset", "state"]);
  });

  test("puts no z2ui5 object on the global", () => {
    const { AppState, ctx } = load();
    AppState.reset();
    AppState.state.url = "/sap/z2ui5";
    expect(ctx.z2ui5).toBeUndefined();
  });
});

test.describe("reset", () => {
  test("state always returns the current object, also after reset", () => {
    const { AppState } = load();
    AppState.state.isBusy = true;
    AppState.reset();
    expect(AppState.state.isBusy).toBe(false);
  });

  test("reset restores the defaults with fresh containers", () => {
    const { AppState } = load();
    AppState.state.errors.push("entry");
    AppState.state.oConfig.S_UI5 = { VERSION: "1.71.0" };
    const timersBefore = AppState.state.timers;
    AppState.reset();
    expect(AppState.state.errors).toEqual([]);
    expect(AppState.state.oConfig).toEqual({});
    // Collections are fresh containers, not cleared old ones.
    expect(AppState.state.timers).not.toBe(timersBefore);
  });

  test("reset forgets which app filled each slot", () => {
    // a Back/Forward restore or an app switch starts from a clean slate:
    // with no recorded owner the model push is unconditional again
    // (actions/Slots.updateModelIfRequired), which is the pre-response
    // behaviour and not a stale owner from the previous screen
    const { AppState } = load();
    AppState.state.slotApp.MAIN = "ZCL_LIST";
    AppState.reset();
    expect(AppState.state.slotApp).toEqual({});
  });
});
