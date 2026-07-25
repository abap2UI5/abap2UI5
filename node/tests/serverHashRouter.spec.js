// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the hash-based app router (UI5 Router style):
//  - Lib.routeForApp / Lib.appOfRoute build and parse the "#/app/<CLASS>" route
//  - Server.onHashChange starts a different app when the hash route changes,
//    is a no-op for the echo of the current app, non-routes, and while routing
//    is disabled (opt-in via set_nav_routing).

function loadLib() {
  const { module: Lib } = loadModule("core/Lib.js", {
    deps: { "z2ui5/core/AppState": { state: {} }, "sap/ui/core/Element": {} },
  });
  return Lib;
}

test("routeForApp / appOfRoute round-trip", () => {
  const Lib = loadLib();
  expect(Lib.routeForApp("Z2UI5_CL_X")).toBe("/app/Z2UI5_CL_X");
  expect(Lib.appOfRoute("/app/Z2UI5_CL_X")).toBe("Z2UI5_CL_X");
  expect(Lib.appOfRoute("#/app/Z2UI5_CL_X")).toBe("Z2UI5_CL_X");
  expect(Lib.appOfRoute("app/Z2UI5_CL_X")).toBe("Z2UI5_CL_X");
});

test("appOfRoute ignores non-app hashes (e.g. an app's own set_push_state)", () => {
  const Lib = loadLib();
  expect(Lib.appOfRoute("")).toBe("");
  expect(Lib.appOfRoute("/head/pos/42")).toBe("");
  expect(Lib.appOfRoute("#/z2ui5-xapp-state=abc")).toBe("");
});

function loadServer(stateOverrides = {}) {
  const roundtrips = [];
  const state = {
    navRouting: true,
    currentApp: "Z2UI5_CL_HOME",
    ...stateOverrides,
  };
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "z2ui5/core/Lib": {
        appOfRoute: (h) =>
          h && h.replace(/^#/, "").replace(/^\//, "").startsWith("app/")
            ? h.replace(/^#/, "").replace(/^\//, "").slice(4).split(/[/&?]/)[0]
            : "",
      },
      "z2ui5/core/AppState": { state },
    },
  });
  // roundtrip is a real method on Server; stub it to record calls.
  Server.roundtrip = (body) => roundtrips.push(body);
  return { Server, state, roundtrips };
}

test("a different app route triggers a fresh roundtrip", () => {
  const { Server, roundtrips } = loadServer();
  Server.onHashChange("/app/Z2UI5_CL_DETAIL");
  expect(roundtrips).toEqual([{}]);
});

test("the echo of the current app route is ignored (no loop)", () => {
  const { Server, roundtrips } = loadServer({ currentApp: "Z2UI5_CL_DETAIL" });
  Server.onHashChange("/app/Z2UI5_CL_DETAIL");
  expect(roundtrips).toEqual([]);
});

test("a non-app hash is ignored", () => {
  const { Server, roundtrips } = loadServer();
  Server.onHashChange("/head/pos/42");
  expect(roundtrips).toEqual([]);
});

test("routing disabled: the router does nothing", () => {
  const { Server, roundtrips } = loadServer({ navRouting: false });
  Server.onHashChange("/app/Z2UI5_CL_DETAIL");
  expect(roundtrips).toEqual([]);
});
