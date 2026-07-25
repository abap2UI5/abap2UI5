// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server.onPopstate - the native browser Back/Forward handler that
// couples the browser history to the server-side app stack. A Back press pops
// one app-stack level via a nav_app_leave roundtrip (eB), but only for
// sessions that actually pushed app-stack entries (navDepth > 0). Self-caused
// popstates (navIgnorePopstate) are swallowed.

const NAV_APP_LEAVE_EVENT = "___ZZZ_NAL";

function load(stateOverrides = {}) {
  const ebCalls = [];
  const state = {
    navDepth: 0,
    navFromPopstate: false,
    navIgnorePopstate: false,
    oController: { eB: (args) => ebCalls.push(args) },
    ...stateOverrides,
  };
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": {
        NAV_APP_LEAVE_EVENT,
        isDestroyed: (o) => Boolean(o?.isDestroyed && o.isDestroyed()),
      },
      "z2ui5/core/AppState": { state },
    },
  });
  return { Server, state, ebCalls };
}

test("Back with a pushed app-stack level fires nav_app_leave and decrements navDepth", () => {
  const { Server, state, ebCalls } = load({ navDepth: 2 });
  Server.onPopstate();
  expect(state.navDepth).toBe(1);
  expect(state.navFromPopstate).toBe(true);
  expect(ebCalls).toEqual([[NAV_APP_LEAVE_EVENT]]);
});

test("Back with no app-stack level of ours is ignored (browser navigates normally)", () => {
  const { Server, state, ebCalls } = load({ navDepth: 0 });
  Server.onPopstate();
  expect(state.navDepth).toBe(0);
  expect(state.navFromPopstate).toBe(false);
  expect(ebCalls).toEqual([]);
});

test("a self-caused popstate (navIgnorePopstate) is swallowed once", () => {
  const { Server, state, ebCalls } = load({
    navDepth: 1,
    navIgnorePopstate: true,
  });
  Server.onPopstate();
  expect(state.navIgnorePopstate).toBe(false);
  expect(state.navDepth).toBe(1); // untouched
  expect(ebCalls).toEqual([]);
});

test("a destroyed controller aborts without touching the nav state", () => {
  const { Server, state, ebCalls } = load({
    navDepth: 1,
    oController: { isDestroyed: () => true, eB: () => ebCalls.push("x") },
  });
  Server.onPopstate();
  expect(state.navDepth).toBe(1);
  expect(ebCalls).toEqual([]);
});
