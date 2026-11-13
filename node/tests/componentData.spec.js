// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Component.init splits the frontend settings off the component data: what
// the bundle's z2ui5/embed module passes (ccResourceRoot, cccResourceRoot),
// what the z2ui5/embed module of ?z2ui5-bundle passes (nodePath)
// and what a host app embedding the component passes (endpoint). They
// configure the frontend, so they land in the state and never travel to the
// backend with the rest of the component data (oConfig.ComponentData).
// Everything else init() does is stubbed away - its listeners and services
// have specs of their own.
//  - `location`     the page's window.location (href and origin) - what a
//                   relative endpoint resolves against
//  - `loaderPaths`  collects every `paths` handed to sap.ui.loader.config
//  - `installs`     the order of DevTools.install and the unload listener
//  - `calls`        the order of sap/ui/util/Mobile.init (with its options)
//                   and UIComponent.init
function init(componentData, options) {
  return initContext(componentData, options).state;
}

function initContext(
  componentData,
  {
    globalsDropped = [],
    location,
    loaderPaths = [],
    calls = [],
    installs = [],
  } = {},
) {
  const noop = () => {};
  const state = { oConfig: {} };
  const ctx = { state };
  const { module: def } = loadModule("Component.js", {
    deps: {
      "sap/ui/core/UIComponent": {
        extend: (_name, d) => d,
        prototype: { init: () => calls.push("UIComponent.init") },
      },
      "z2ui5/model/models": { createDeviceModel: () => ({}) },
      "z2ui5/core/Server": {},
      "z2ui5/core/Session": {},
      "sap/ui/VersionInfo": {},
      "z2ui5/devtools/DevTools": {
        install: () => installs.push("DevTools.install"),
      },
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
      "sap/ui/util/Mobile": {
        init: (options) => calls.push(["Mobile.init", options]),
      },
    },
    sandbox: {
      sap: {
        ui: { loader: { config: (cfg) => loaderPaths.push(cfg.paths) } },
      },
      ...(location ? { window: { location } } : {}),
    },
  });

  const inst = Object.create(def);
  inst.getComponentData = () => componentData;
  inst.setModel = noop;
  inst._initLaunchpad = noop;
  inst._initVersionInfo = noop;
  inst._installUnloadListener = () => installs.push("unload listener");
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

test("the resource roots are still split off as before", () => {
  const state = init({
    ccResourceRoot: "/cci/",
    cccResourceRoot: "/ccc/",
  });

  expect(state.ccResourceRoot).toBe("/cci/");
  expect(state.cccResourceRoot).toBe("/ccc/");
  expect(state.endpoint).toBeNull();
  expect(state.oConfig.ComponentData).toBeUndefined();
});

// The component is always embedded since 2026-11-14: the embed control
// creates it everywhere. The flag an older control or a host of its own
// still passes is a setting like the endpoint - split off, never app data.
test("an embedding page's flag is split off, not sent to the backend", () => {
  const state = init({
    embedded: true,
    endpoint: "/sap/bc/z2ui5",
    startupParameters: { app_start: ["ZCL_APP"], customer: ["4711"] },
  });

  expect("embedded" in state).toBe(false);
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { app_start: ["ZCL_APP"], customer: ["4711"] },
  });
  // a launchpad link's parameter of that name is app data, and stays
  expect(
    init({ startupParameters: { embedded: ["true"] } }).oConfig.ComponentData,
  ).toEqual({ startupParameters: { embedded: ["true"] } });
});

// What belongs to the page - the URL hash, the title, the favicon, the
// global busy indicator, the "leave page?" prompt - is the host's, unless
// the host hands the page over with ownsPage: true (the backend's own page,
// one control filling it) or its older name ownsHash: true, which
// @abap2ui5/embed-control 0.3.0 passes. A host's setting: read on the top
// level only, a boolean true only, and never sent.
test("the page is the host's, unless handed over", () => {
  for (const data of [{}, undefined, { embedded: true }]) {
    expect(init(data).ownsPage).toBe(false);
  }

  for (const handed of [{ ownsPage: true }, { ownsHash: true }]) {
    const state = init({
      ...handed,
      startupParameters: { app_start: ["ZCL_APP"] },
    });
    expect(state.ownsPage).toBe(true);
    expect(state.oConfig.ComponentData).toEqual({
      startupParameters: { app_start: ["ZCL_APP"] },
    });
  }

  expect(init({ ownsPage: "true" }).ownsPage).toBe(false);
  const linked = init({ startupParameters: { ownsPage: ["true"] } });
  expect(linked.ownsPage).toBe(false);
});

test("only a host's boolean true hands the page over by the older name - not a launchpad link", () => {
  expect(init({ ownsHash: "true" }).ownsPage).toBe(false);
  expect(init({ ownsHash: 1 }).ownsPage).toBe(false);
  const state = init({ startupParameters: { ownsHash: ["true"] } });
  expect(state.ownsPage).toBe(false);
  expect(state.oConfig.ComponentData).toEqual({
    startupParameters: { ownsHash: ["true"] },
  });
});

// UI5 1.x exports every class it creates as a global - window.z2ui5.Component
// and the rest (core/Env.js ownClass). The component always runs on a HOST's
// page, whose window is not the frontend's: its init takes them off.
// ... and its Restart restarts the app in place instead of reloading the
// host's page (core/ErrorView.js restart, Component._restartApp)
test("every component offers the in-place restart", () => {
  expect(typeof initContext({}).restart).toBe("function");
  expect(typeof initContext({ ownsPage: true }).restart).toBe("function");
});

test("every component takes the frontend's class globals off", () => {
  const dropped = [];
  init({}, { globalsDropped: dropped });
  init({ ownsPage: true }, { globalsDropped: dropped });
  expect(dropped).toEqual([true, true]);
});

// The two roots are absolute paths on the SYSTEM. A page that reaches the
// node through a proxy with a path prefix of its own - the destination proxy
// of SAP Build Work Zone, an approuter route - loads the bundle from the
// prefixed URL, and there the system's path finds nothing. The bundle's
// z2ui5/embed module reports the path the node has on the system (nodePath,
// z2ui5_cl_ui5_http_handler=>_http_get_bundle); when the host's endpoint
// ends in it, what stands before it is the proxy's prefix, and the roots
// get it before they reach the loader.
test.describe("the sibling BSP roots behind a proxy", () => {
  const CCI = "/sap/bc/ui5_ui5/sap/z2ui5_cci";
  const CCC = "/sap/bc/ui5_ui5/sap/z2ui5_ccc";
  const roots = { ccResourceRoot: CCI, cccResourceRoot: CCC };
  const bundle = { embedded: true, nodePath: "/sap/bc/z2ui5", ...roots };
  const location = {
    href: "https://workzone.example/site/launchpad",
    origin: "https://workzone.example",
  };

  test("a prefixing proxy's prefix goes in front of both roots", () => {
    const loaderPaths = [];
    const state = init(
      {
        ...bundle,
        endpoint: "https://workzone.example/dynamic_dest/ABAP2UI5/sap/bc/z2ui5",
        startupParameters: { app_start: ["ZCL_APP"] },
      },
      { location, loaderPaths },
    );

    expect(state.ccResourceRoot).toBe(`/dynamic_dest/ABAP2UI5${CCI}`);
    expect(state.cccResourceRoot).toBe(`/dynamic_dest/ABAP2UI5${CCC}`);
    expect(state.nodePath).toBe("/sap/bc/z2ui5");
    // what the loader is told is the rebased root, in the one call
    expect(loaderPaths).toEqual([
      {
        z2ui5_cci: `/dynamic_dest/ABAP2UI5${CCI}`,
        z2ui5_ccc: `/dynamic_dest/ABAP2UI5${CCC}`,
      },
    ]);
    // nodePath is a setting like the rest - never app data
    expect(state.oConfig.ComponentData).toEqual({
      startupParameters: { app_start: ["ZCL_APP"] },
    });
  });

  test("a relative endpoint resolves against the page", () => {
    const state = init(
      { ...bundle, endpoint: "/dynamic_dest/ABAP2UI5/sap/bc/z2ui5" },
      { location },
    );
    expect(state.ccResourceRoot).toBe(`/dynamic_dest/ABAP2UI5${CCI}`);
    expect(state.cccResourceRoot).toBe(`/dynamic_dest/ABAP2UI5${CCC}`);
  });

  test("the node's own path on the page's origin leaves them as they are", () => {
    const loaderPaths = [];
    for (const endpoint of [
      "/sap/bc/z2ui5",
      "https://workzone.example/sap/bc/z2ui5",
      "/sap/bc/z2ui5?sap-client=100",
    ]) {
      const state = init({ ...bundle, endpoint }, { location, loaderPaths });
      expect(state.ccResourceRoot).toBe(CCI);
      expect(state.cccResourceRoot).toBe(CCC);
    }
    expect(loaderPaths).toEqual([
      { z2ui5_cci: CCI, z2ui5_ccc: CCC },
      { z2ui5_cci: CCI, z2ui5_ccc: CCC },
      { z2ui5_cci: CCI, z2ui5_ccc: CCC },
    ]);
  });

  test("a trailing slash on either side is the same node", () => {
    expect(
      init(
        { ...bundle, endpoint: "https://workzone.example/gw/sap/bc/z2ui5/" },
        { location },
      ).ccResourceRoot,
    ).toBe(`/gw${CCI}`);
    expect(
      init(
        { ...bundle, nodePath: "/sap/bc/z2ui5/", endpoint: "/gw/sap/bc/z2ui5" },
        { location },
      ).ccResourceRoot,
    ).toBe(`/gw${CCI}`);
  });

  // a proxy that rewrites the path: nothing says where the BSPs are, so
  // today's behaviour stands
  test("an endpoint that does not end in the node path leaves them as they are", () => {
    for (const endpoint of [
      "https://gateway.example/abap2ui5",
      "/dynamic_dest/ABAP2UI5/z2ui5",
      "/sap/bc/z2ui5_other",
      "/sap/bc/xz2ui5",
    ]) {
      const state = init({ ...bundle, endpoint }, { location });
      expect(state.ccResourceRoot).toBe(CCI);
      expect(state.cccResourceRoot).toBe(CCC);
    }
  });

  test("an endpoint on another origin puts that origin in front", () => {
    const state = init(
      { ...bundle, endpoint: "https://backend.example:44300/sap/bc/z2ui5" },
      { location },
    );
    expect(state.ccResourceRoot).toBe(`https://backend.example:44300${CCI}`);
    expect(state.cccResourceRoot).toBe(`https://backend.example:44300${CCC}`);

    const prefixed = init(
      { ...bundle, endpoint: "https://backend.example/gw/sap/bc/z2ui5" },
      { location },
    );
    expect(prefixed.ccResourceRoot).toBe(`https://backend.example/gw${CCI}`);
  });

  // the GET page passes no endpoint and no node path, a host of its own
  // ComponentContainer an endpoint but no node path, and a stack that
  // reported no path an empty one
  test("without an endpoint or a node path nothing moves", () => {
    const page = init({ ...roots }, { location });
    expect(page.ccResourceRoot).toBe(CCI);
    expect(page.cccResourceRoot).toBe(CCC);
    expect(page.nodePath).toBeNull();

    const host = init(
      { ...roots, embedded: true, endpoint: "/gw/sap/bc/z2ui5" },
      { location },
    );
    expect(host.ccResourceRoot).toBe(CCI);
    expect(host.nodePath).toBeNull();

    const blank = init(
      { ...bundle, nodePath: "", endpoint: "/gw/sap/bc/z2ui5" },
      { location },
    );
    expect(blank.ccResourceRoot).toBe(CCI);
    expect(blank.nodePath).toBeNull();

    // ... and a page without roots gets none
    const none = init(
      {
        embedded: true,
        nodePath: "/sap/bc/z2ui5",
        endpoint: "/gw/sap/bc/z2ui5",
      },
      { location },
    );
    expect(none.ccResourceRoot).toBeNull();
    expect(none.cccResourceRoot).toBeNull();
  });

  // the backend hands absolute paths over; a host that passes a URL of its
  // own for a root knows better than the prefix does
  test("a root that is not an absolute path is left alone", () => {
    const state = init(
      {
        ...bundle,
        ccResourceRoot: "https://cdn.example/cci/",
        endpoint: "/gw/sap/bc/z2ui5",
      },
      { location },
    );
    expect(state.ccResourceRoot).toBe("https://cdn.example/cci/");
    expect(state.cccResourceRoot).toBe(`/gw${CCC}`);
  });

  // an endpoint that does not parse says nothing, and neither does the top
  // level of the component data being the only place a node path is read -
  // the launchpad's startup parameters are app data
  test("a node path among the launchpad startup parameters is not taken", () => {
    const state = init(
      {
        ...roots,
        endpoint: "/gw/sap/bc/z2ui5",
        startupParameters: { nodePath: ["/sap/bc/z2ui5"] },
      },
      { location },
    );
    expect(state.nodePath).toBeNull();
    expect(state.ccResourceRoot).toBe(CCI);
    expect(state.oConfig.ComponentData).toEqual({
      startupParameters: { nodePath: ["/sap/bc/z2ui5"] },
    });
  });

  test("an endpoint that does not parse leaves them as they are", () => {
    const state = init(
      { ...bundle, endpoint: "http://[not a host]/sap/bc/z2ui5" },
      { location },
    );
    expect(state.ccResourceRoot).toBe(CCI);
  });
});

// sap/ui/util/Mobile.init( ) runs once per page, whoever calls first, and on
// a host's page that was the embedded app setting the host's page up as a
// mobile app. An embedded component's root (a sap.m.NavContainer) never
// calls it, but a sap.m.Shell or sap.m.SplitApp in the app's view does when
// it is created - so the component makes the call first, with everything
// off, before the root view exists; on a page handed to the app (ownsPage)
// the call stays sap.m.App's.
test("on a host's page the component makes the page's Mobile.init( ) call first, with everything off", () => {
  const calls = [];
  initContext({ embedded: true }, { calls });
  expect(calls).toEqual([
    [
      "Mobile.init",
      {
        viewport: false,
        hideBrowser: false,
        preventScroll: false,
        preventPhoneNumberDetection: false,
        useFullScreenHeight: false,
      },
    ],
    "UIComponent.init",
  ]);
});

test("on a page handed to the app, Mobile.init( ) is left to the app's sap.m.App", () => {
  const calls = [];
  initContext({ ownsPage: true }, { calls });
  expect(calls).toEqual(["UIComponent.init"]);
});

// The devtools persist their console and roundtrip history on "pagehide";
// the component's own pagehide listener destroys the component, whose exit
// uninstalls the devtools and takes their listeners off mid-dispatch - a
// listener removed before it ran is skipped. Installed first, theirs run
// first, and the history reaches the next page load.
test("the devtools are installed before the unload listener", () => {
  const installs = [];
  initContext({}, { installs });
  expect(installs).toEqual(["DevTools.install", "unload listener"]);
});
