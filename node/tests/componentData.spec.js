// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Component.init splits the frontend settings off the component data: what
// the backend GET page passes (checkLocal, ccResourceRoot, cccResourceRoot)
// and what a host app embedding the component passes (endpoint). They
// configure the frontend, so they land in the state and never travel to the
// backend with the rest of the component data (oConfig.ComponentData).
// Everything else init() does is stubbed away - its listeners and services
// have specs of their own.
function init(componentData, { globalsDropped = [] } = {}) {
  const noop = () => {};
  const state = { oConfig: {} };
  const ctx = { state };
  const { module: def } = loadModule("Component.js", {
    deps: {
      "sap/ui/core/UIComponent": {
        extend: (_name, d) => d,
        prototype: { init: noop },
      },
      "z2ui5/model/models": { createDeviceModel: () => ({}) },
      "z2ui5/core/Server": {},
      "z2ui5/core/Session": {},
      "sap/ui/VersionInfo": {},
      "z2ui5/devtools/DevTools": { install: noop },
      "z2ui5/core/Lib": {},
      "z2ui5/core/Env": {
        hasMessagingModule: () => false,
        ownClass: (Class) => Class,
        dropClassGlobals: () => globalsDropped.push(true),
      },
      "z2ui5/core/Context": { create: () => ctx },
      "z2ui5/core/Router": {},
      "z2ui5/core/ScrollFocus": {},
      "z2ui5/core/ViewSlots": {},
      "z2ui5/core/actions/Shortcuts": {},
    },
    sandbox: { sap: { ui: { loader: { config: noop } } } },
  });

  const inst = Object.create(def);
  inst.getComponentData = () => componentData;
  inst.setModel = noop;
  inst._initLaunchpad = noop;
  inst._initVersionInfo = noop;
  inst._installUnloadListener = noop;
  inst._installScrollListener = noop;
  inst._installRouterListener = noop;
  inst.init();
  return state;
}

test("a host's endpoint lands in the state, not in the data sent to the backend", () => {
  const state = init({
    endpoint: "/sap/bc/z2ui5_other",
    startupParameters: { app_start: ["ZCL_APP"] },
  });

  expect(state.endpoint).toBe("/sap/bc/z2ui5_other");
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { app_start: ["ZCL_APP"] },
  });
});

test("an endpoint alone leaves no empty ComponentData behind", () => {
  const state = init({ endpoint: "/sap/bc/z2ui5_other" });

  expect(state.oConfig.ComponentData).toBeUndefined();
});

test("the endpoint is trimmed; blank or not a string means none", () => {
  expect(init({ endpoint: "  /sap/bc/x  " }).endpoint).toBe("/sap/bc/x");
  expect(init({ endpoint: "   " }).endpoint).toBeNull();
  expect(init({ endpoint: 42 }).endpoint).toBeNull();
  expect(init({}).endpoint).toBeNull();
  expect(init(undefined).endpoint).toBeNull();
});

// In the launchpad the URL's parameters arrive as startupParameters - a link
// must not be able to send the roundtrips to another server.
test("an endpoint among the launchpad startup parameters is not taken", () => {
  const state = init({
    startupParameters: { endpoint: ["https://evil.example/"] },
  });

  expect(state.endpoint).toBeNull();
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { endpoint: ["https://evil.example/"] },
  });
});

test("the GET page settings are still split off as before", () => {
  const state = init({
    checkLocal: true,
    ccResourceRoot: "/cci/",
    cccResourceRoot: "/ccc/",
  });

  expect(state.checkLocal).toBe(true);
  expect(state.ccResourceRoot).toBe("/cci/");
  expect(state.cccResourceRoot).toBe("/ccc/");
  expect(state.endpoint).toBeNull();
  expect(state.oConfig.ComponentData).toBeUndefined();
});

// ?z2ui5-bundle's z2ui5/embed module passes embedded: a page that loads the
// frontend that way embeds it, and its URL is the host's (core/Router.js,
// core/Server.js). A setting like the endpoint - never app data.
test("an embedding page's flag lands in the state, not in the data sent to the backend", () => {
  const state = init({
    embedded: true,
    endpoint: "/sap/bc/z2ui5",
    startupParameters: { app_start: ["ZCL_APP"], customer: ["4711"] },
  });

  expect(state.embedded).toBe(true);
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { app_start: ["ZCL_APP"], customer: ["4711"] },
  });
});

test("only a boolean true embeds - the page and the launchpad do not", () => {
  expect(init({ embedded: "true" }).embedded).toBe(false);
  expect(init({ embedded: 1 }).embedded).toBe(false);
  expect(init({}).embedded).toBe(false);
  expect(init(undefined).embedded).toBe(false);
  // a launchpad link cannot switch it on either: startup parameters are app
  // data, and they stay where they are
  const state = init({ startupParameters: { embedded: ["true"] } });
  expect(state.embedded).toBe(false);
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { embedded: ["true"] },
  });
});

// UI5 1.x exports every class it creates as a global - window.z2ui5.Component
// and the rest (core/Env.js ownClass). An embedded component runs on a HOST's
// page, whose window is not the frontend's: its init takes them off. A page
// of the app's own keeps them - 1.71 looks a base class up by that name when
// something extends one of ours.
test("an embedded component takes the frontend's class globals off", () => {
  const embedded = [];
  init({ embedded: true }, { globalsDropped: embedded });
  expect(embedded).toEqual([true]);

  const own = [];
  init({ checkLocal: true }, { globalsDropped: own });
  init({}, { globalsDropped: own });
  expect(own).toEqual([]);
});
