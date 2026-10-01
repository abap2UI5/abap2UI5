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
function init(componentData, options) {
  return initContext(componentData, options).state;
}

function initContext(componentData, { globalsDropped = [] } = {}) {
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
  return ctx;
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
// ... and its Restart restarts the app in place instead of reloading the
// host's page (core/ErrorView.js restart, Component._restartApp)
test("only an embedded component offers the in-place restart", () => {
  const embedded = initContext({ embedded: true });
  expect(typeof embedded.restart).toBe("function");
  expect(initContext({}).restart ?? null).toBe(null);
  expect(initContext({ checkLocal: true }).restart ?? null).toBe(null);
});

test("an embedded component takes the frontend's class globals off", () => {
  const embedded = [];
  init({ embedded: true }, { globalsDropped: embedded });
  expect(embedded).toEqual([true]);

  const own = [];
  init({ checkLocal: true }, { globalsDropped: own });
  init({}, { globalsDropped: own });
  expect(own).toEqual([]);
});

// The z2ui5/embed module of ?z2ui5-bundle names the sibling BSPs as the
// system has them and the node the bundle was requested under (nodePath). A
// host that reaches the system through a proxy with a prefix of its own -
// SAP Build Work Zone's destination proxy, an approuter route with a prefix
// - has that prefix in front of the node in its endpoint: the roots take
// it, so a custom control from z2ui5_cci is requested where the host's
// origin reaches it.
test("a host's prefix in front of the node goes in front of the sibling BSP roots", () => {
  const state = init({
    embedded: true,
    nodePath: "/sap/bc/z2ui5",
    ccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_cci",
    cccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_ccc",
    endpoint: "https://host.example/dynamic_dest/ABAP2UI5/sap/bc/z2ui5",
    startupParameters: { app_start: ["ZCL_APP"] },
  });

  expect(state.ccResourceRoot).toBe(
    "/dynamic_dest/ABAP2UI5/sap/bc/ui5_ui5/sap/z2ui5_cci",
  );
  expect(state.cccResourceRoot).toBe(
    "/dynamic_dest/ABAP2UI5/sap/bc/ui5_ui5/sap/z2ui5_ccc",
  );
  // a setting of the frontend, never app data
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { app_start: ["ZCL_APP"] },
  });
});

test("an endpoint on the node itself, in any spelling, adds no prefix", () => {
  for (const endpoint of [
    "/sap/bc/z2ui5",
    "/sap/bc/z2ui5/",
    "https://host.example/sap/bc/z2ui5?sap-client=100",
    "https://host.example:44300/sap/bc/z2ui5#top",
  ]) {
    const state = init({
      nodePath: "/sap/bc/z2ui5/",
      ccResourceRoot: "/cci",
      endpoint,
    });
    expect(state.ccResourceRoot, endpoint).toBe("/cci");
  }
});

// a rewriting proxy, a node of another name: nothing to go by
test("an endpoint that does not end with the node leaves the roots as they are", () => {
  for (const endpoint of ["/backend/z2ui5", "/sap/bc/z2ui5_other", "/xsap/bc/z2ui5"]) {
    const state = init({
      nodePath: "/sap/bc/z2ui5",
      ccResourceRoot: "/cci",
      endpoint,
    });
    expect(state.ccResourceRoot, endpoint).toBe("/cci");
  }
});

test("without an endpoint, a node or a root there is nothing to prefix", () => {
  const root = (data) => init(data).ccResourceRoot;
  const prefixed = { endpoint: "/x/sap/bc/z2ui5", nodePath: "/sap/bc/z2ui5" };
  // the page passes the roots and no node; a bundle without a path says ""
  expect(root({ nodePath: "/sap/bc/z2ui5", ccResourceRoot: "/cci" })).toBe("/cci");
  expect(root({ endpoint: "/x/sap/bc/z2ui5", ccResourceRoot: "/cci" })).toBe("/cci");
  expect(root({ ...prefixed, nodePath: "", ccResourceRoot: "/cci" })).toBe("/cci");
  expect(root({ ...prefixed, nodePath: 42, ccResourceRoot: "/cci" })).toBe("/cci");
  expect(root(prefixed)).toBeNull();
  // a root that is no absolute path is not the system's: left alone
  expect(root({ ...prefixed, ccResourceRoot: "../z2ui5_cci/" })).toBe("../z2ui5_cci/");
  // a node among the launchpad's startup parameters is app data, no node
  const state = init({
    endpoint: "/x/sap/bc/z2ui5",
    ccResourceRoot: "/cci",
    startupParameters: { nodePath: ["/sap/bc/z2ui5"] },
  });
  expect(state.ccResourceRoot).toBe("/cci");
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { nodePath: ["/sap/bc/z2ui5"] },
  });
});
