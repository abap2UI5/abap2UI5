// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests View1._updateBrowserHistory - the half of the hash router that WRITES
// the URL (Server.onHashChange, which reads it, is covered by
// serverHashRouter.spec.js). What matters here is which history entry each
// roundtrip touches:
//  - a plain roundtrip REPLACES the current entry with the app's latest draft
//  - a nav_app_call PUSHES the called app's route, and first repoints the
//    CALLING app's entry at the draft the backend saved for it in that same
//    roundtrip (NAV_APP_CALL_PREV_APP / _ID) - otherwise Back restores the
//    caller as it was rendered and drops every client-side change the user
//    made before navigating away (two-way bound switches, checkboxes, input).

function loadLib() {
  const { module: Lib } = loadModule("core/Lib.js", {
    deps: { "z2ui5/core/AppState": { state: {} }, "sap/ui/core/Element": {} },
  });
  return Lib;
}

const CALLER = "Z2UI5_CL_CALLER";
const CALLEE = "Z2UI5_CL_CALLEE";

function loadController(stateOverrides = {}) {
  // records every hash write plus the echo guard (currentDraftId) that was in
  // place at that moment - Server.onHashChange compares against it
  const writes = [];
  let hash = "";
  const hashChanger = {
    getHash: () => hash,
    setHash: (h) => { writes.push({ op: "set", hash: h, guard: state.currentDraftId }); hash = h; },
    replaceHash: (h) => { writes.push({ op: "replace", hash: h, guard: state.currentDraftId }); hash = h; },
  };
  const state = {
    navRouting: true,
    navMode: "KEEP",
    currentApp: CALLER,
    currentDraftId: "D1",
    navFromHash: false,
    ...stateOverrides,
  };
  const { module: ctrl } = loadModule("controller/View1.controller.js", {
    deps: {
      // Controller.extend hands back the plain methods object, so the
      // controller's own functions can be called directly
      "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
      "sap/ui/core/routing/HashChanger": { getInstance: () => hashChanger },
      "z2ui5/core/Lib": loadLib(),
      "z2ui5/core/AppState": { state },
    },
  });
  return { ctrl, state, writes, setHash: (h) => { hash = h; } };
}

// the response of the roundtrip that ran client->nav_app_call
function navCallParams() {
  return {
    CHECK_NAV_APP_CALL: true,
    NAV_APP_CALL_PREV_APP: CALLER,
    NAV_APP_CALL_PREV_ID: "D2",
  };
}

test("a plain roundtrip replaces the current entry with the newest draft", () => {
  const { ctrl, state, writes } = loadController();
  state.oResponse = { APP: CALLER };

  ctrl._updateBrowserHistory({}, "D2");

  expect(writes).toEqual([
    { op: "replace", hash: `/app/${CALLER}/D2`, guard: "D2" },
  ]);
});

test("a nav_app_call repoints the caller's entry, then pushes the called app", () => {
  const { ctrl, state, writes, setHash } = loadController();
  setHash(`/app/${CALLER}/D1`); // the entry the browser is standing on
  state.oResponse = { APP: CALLEE };

  ctrl._updateBrowserHistory(navCallParams(), "D9");

  expect(writes).toEqual([
    // the caller's entry now points at the draft that carries the user's
    // client-side changes ...
    { op: "replace", hash: `/app/${CALLER}/D2`, guard: "D2" },
    // ... and the called app gets a NEW entry, so Back returns to it
    { op: "set", hash: `/app/${CALLEE}/D9`, guard: "D9" },
  ]);
  // the state ends up on the called app (the repoint must not leak)
  expect(state.currentApp).toBe(CALLEE);
  expect(state.currentDraftId).toBe("D9");
});

test("the repoint is skipped when the caller's entry is already current", () => {
  const { ctrl, state, writes, setHash } = loadController();
  setHash(`/app/${CALLER}/D2`);
  state.oResponse = { APP: CALLEE };

  ctrl._updateBrowserHistory(navCallParams(), "D9");

  expect(writes).toEqual([{ op: "set", hash: `/app/${CALLEE}/D9`, guard: "D9" }]);
});

test("a nav_app_call without the caller info only pushes (older backend)", () => {
  const { ctrl, state, writes } = loadController();
  state.oResponse = { APP: CALLEE };

  ctrl._updateBrowserHistory({ CHECK_NAV_APP_CALL: true }, "D9");

  expect(writes).toEqual([{ op: "set", hash: `/app/${CALLEE}/D9`, guard: "D9" }]);
});

test("FRESH mode routes by class only and never repoints", () => {
  const { ctrl, state, writes } = loadController({ navMode: "FRESH", currentDraftId: null });
  state.oResponse = { APP: CALLEE };

  ctrl._updateBrowserHistory(navCallParams(), "D9");

  expect(writes).toEqual([{ op: "set", hash: `/app/${CALLEE}`, guard: null }]);
});

test("a render caused by browser Back/Forward writes no hash at all", () => {
  const { ctrl, state, writes } = loadController({ navFromHash: true });
  state.oResponse = { APP: CALLER };

  ctrl._updateBrowserHistory({}, "D2");

  expect(writes).toEqual([]);
  expect(state.navFromHash).toBe(false);
});
