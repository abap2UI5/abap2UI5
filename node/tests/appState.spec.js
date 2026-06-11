// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/AppState.js: global bootstrapping,
// the transitional accessors on the z2ui5 global and reset behavior.
// `window` is the sandbox global itself (see loadModule.js), exactly
// like in a browser - so window.z2ui5 and the bare z2ui5 global are
// the same thing.

function load(sandbox = {}) {
  const { module, sandbox: ctx } = loadModule("core/AppState.js", {
    sandbox,
  });
  return { AppState: module, ctx };
}

test.describe("initGlobal", () => {
  test("creates the global with a fresh oConfig when none exists", () => {
    const { AppState, ctx } = load();
    AppState.initGlobal();
    expect(ctx.z2ui5).toBeDefined();
    expect(ctx.z2ui5.oConfig).toEqual({});
  });

  test("installs the defaults for the internal fields", () => {
    const { AppState, ctx } = load();
    AppState.initGlobal();
    expect(ctx.z2ui5.isBusy).toBe(false);
    expect(ctx.z2ui5.checkNestAfter).toBe(false);
    expect(ctx.z2ui5.oView).toBeNull();
    expect(ctx.z2ui5.errors).toEqual([]);
    expect(ctx.z2ui5.timers).toEqual({});
    expect(ctx.z2ui5.viewSizeLimits).toEqual({});
    expect(ctx.z2ui5.onBeforeRoundtrip).toEqual([]);
    expect(ctx.z2ui5.xxChangedPaths.size).toBe(0);
  });

  test("keeps an existing global object", () => {
    const existing = { checkLocal: true };
    const { AppState, ctx } = load({ z2ui5: existing });
    AppState.initGlobal();
    expect(ctx.z2ui5).toBe(existing);
  });

  test("starts from a clean object when checkLocal === false", () => {
    const existing = { checkLocal: false, custom: "x" };
    const { AppState, ctx } = load({ z2ui5: existing });
    AppState.initGlobal();
    expect(ctx.z2ui5).not.toBe(existing);
    expect(ctx.z2ui5.custom).toBeUndefined();
  });

  test("preserves a pre-existing plain value of an internal field", () => {
    const { AppState, ctx } = load({ z2ui5: { search: "?keep=1" } });
    AppState.initGlobal();
    expect(ctx.z2ui5.search).toBe("?keep=1");
  });

  test("does not touch public fields", () => {
    const util = { marker: true };
    const { AppState, ctx } = load({
      z2ui5: { Util: util, requestTimeoutMs: 5000 },
    });
    AppState.initGlobal();
    expect(ctx.z2ui5.Util).toBe(util);
    expect(ctx.z2ui5.requestTimeoutMs).toBe(5000);
  });

  test("a re-init resets internal fields but keeps public ones", () => {
    const { AppState, ctx } = load();
    AppState.initGlobal();
    ctx.z2ui5.contextId = "abc";
    ctx.z2ui5.Util = "public";
    AppState.initGlobal();
    expect(ctx.z2ui5.contextId).toBeNull();
    expect(ctx.z2ui5.Util).toBe("public");
  });
});

test.describe("accessors and reset", () => {
  test("accessor writes go through to the internal state", () => {
    const { AppState, ctx } = load();
    AppState.initGlobal();
    ctx.z2ui5.isBusy = true;
    ctx.z2ui5.errors.push("entry");
    expect(ctx.z2ui5.isBusy).toBe(true);
    expect(ctx.z2ui5.errors).toEqual(["entry"]);
  });

  test("reset restores the defaults and is visible on the global", () => {
    const { AppState, ctx } = load();
    AppState.initGlobal();
    ctx.z2ui5.isBusy = true;
    ctx.z2ui5.errors.push("entry");
    const timersBefore = ctx.z2ui5.timers;
    AppState.reset();
    expect(ctx.z2ui5.isBusy).toBe(false);
    expect(ctx.z2ui5.errors).toEqual([]);
    // Collections are fresh containers, not cleared old ones.
    expect(ctx.z2ui5.timers).not.toBe(timersBefore);
  });
});
