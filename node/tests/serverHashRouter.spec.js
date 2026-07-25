// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the hash-based app router (UI5 Router style) with state-preserving
// routes "#/app/<CLASS>/<DRAFTID>":
//  - Lib.routeForApp / appOfRoute / draftOfRoute build and parse the route
//  - Server.onHashChange restores a different app STATE (draft) when the hash
//    changes, ignores the echo of the current draft, non-routes, and disabled
//    routing.

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

test("a different draft (state) triggers a restore roundtrip", () => {
  const { Server, roundtrips } = loadServer();
  Server.onHashChange("/app/Z2UI5_CL_DETAIL/DRAFT2");
  expect(roundtrips).toEqual([{}]);
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
