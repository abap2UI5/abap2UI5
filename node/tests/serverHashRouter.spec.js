// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the hash-based app router (UI5 Router style). It handles both routing
// modes (z2ui5_if_client=>cs_nav_mode): KEEP routes carry the app state as a
// draft id "#/app/<CLASS>/<DRAFTID>", FRESH routes carry the class only
// "#/app/<CLASS>" (a fresh start). The router itself is mode-agnostic - it
// matches on the draft id when the route has one, otherwise on the class:
//  - Lib.routeForApp / appOfRoute / draftOfRoute build and parse the route
//  - Server.onHashChange restores a different app STATE (KEEP: different draft;
//    FRESH: different class) when the hash changes, ignores the echo of the
//    current route, non-routes, and disabled routing.

function loadLib() {
  const { module: Lib } = loadModule("core/Lib.js", {
    deps: { "z2ui5/core/AppState": { state: {} }, "sap/ui/core/Element": {} },
  });
  return Lib;
}

test("routeForApp / appOfRoute / draftOfRoute round-trip", () => {
  const Lib = loadLib();
  expect(Lib.routeForApp("Z2UI5_CL_X", "DRAFT9")).toBe("/app/Z2UI5_CL_X/DRAFT9");
  expect(Lib.routeForApp("Z2UI5_CL_X")).toBe("/app/Z2UI5_CL_X"); // no draft yet
  expect(Lib.appOfRoute("/app/Z2UI5_CL_X/DRAFT9")).toBe("Z2UI5_CL_X");
  expect(Lib.draftOfRoute("/app/Z2UI5_CL_X/DRAFT9")).toBe("DRAFT9");
  expect(Lib.draftOfRoute("#/app/Z2UI5_CL_X/DRAFT9")).toBe("DRAFT9");
  expect(Lib.draftOfRoute("/app/Z2UI5_CL_X")).toBe(""); // class only
});

test("appOfRoute/draftOfRoute ignore non-app hashes", () => {
  const Lib = loadLib();
  expect(Lib.appOfRoute("")).toBe("");
  expect(Lib.appOfRoute("/head/pos/42")).toBe("");
  expect(Lib.draftOfRoute("#/z2ui5-xapp-state=abc")).toBe("");
});

function loadServer(stateOverrides = {}) {
  const Lib = loadLib(); // use the real route parsers
  const roundtrips = [];
  const state = {
    navRouting: true,
    currentApp: "Z2UI5_CL_HOME",
    currentDraftId: "HOME1",
    navFromHash: false,
    ...stateOverrides,
  };
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": {
        appOfRoute: Lib.appOfRoute,
        draftOfRoute: Lib.draftOfRoute,
      },
      "z2ui5/core/AppState": { state },
    },
  });
  Server.roundtrip = (body) => roundtrips.push(body);
  return { Server, state, roundtrips };
}

test("a different draft (state) triggers a restore roundtrip and marks it browser-initiated", () => {
  const { Server, state, roundtrips } = loadServer();
  Server.onHashChange("/app/Z2UI5_CL_DETAIL/DRAFT2");
  expect(roundtrips).toEqual([{}]);
  // so the render skips the hash rewrite (keeps the forward history entries)
  expect(state.navFromHash).toBe(true);
});

test("the echo of the current draft is ignored (no loop)", () => {
  const { Server, roundtrips } = loadServer({
    currentApp: "Z2UI5_CL_DETAIL",
    currentDraftId: "DRAFT2",
  });
  Server.onHashChange("/app/Z2UI5_CL_DETAIL/DRAFT2");
  expect(roundtrips).toEqual([]);
});

test("same class but a different draft still restores (state changed)", () => {
  const { Server, roundtrips } = loadServer({
    currentApp: "Z2UI5_CL_DETAIL",
    currentDraftId: "DRAFT2",
  });
  Server.onHashChange("/app/Z2UI5_CL_DETAIL/DRAFT9");
  expect(roundtrips).toEqual([{}]);
});

test("a draft-less route falls back to the class guard", () => {
  const { Server, roundtrips } = loadServer({
    currentApp: "Z2UI5_CL_HOME",
    currentDraftId: "HOME1",
  });
  Server.onHashChange("/app/Z2UI5_CL_HOME"); // same class, no draft -> echo
  expect(roundtrips).toEqual([]);
});

test("FRESH mode: a draft-less route to a different class restarts it", () => {
  // FRESH routes carry no draft id (currentDraftId is null); Back/Forward
  // between class-only routes must restart the target class fresh.
  const { Server, state, roundtrips } = loadServer({
    currentApp: "Z2UI5_CL_HOME",
    currentDraftId: null,
  });
  Server.onHashChange("/app/Z2UI5_CL_DETAIL"); // different class, no draft
  expect(roundtrips).toEqual([{}]);
  expect(state.navFromHash).toBe(true);
});

test("a non-app hash is ignored", () => {
  const { Server, roundtrips } = loadServer();
  Server.onHashChange("/head/pos/42");
  expect(roundtrips).toEqual([]);
});

test("routing disabled: the router does nothing", () => {
  const { Server, roundtrips } = loadServer({ navRouting: false });
  Server.onHashChange("/app/Z2UI5_CL_DETAIL/DRAFT2");
  expect(roundtrips).toEqual([]);
});
