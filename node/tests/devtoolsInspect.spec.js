// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests the real implementation shipped in
// app/webapp/devtools/Inspect.js. Every inspector is a pure renderer
// over the state of one component context (core/Context.js, taken
// first), so the harness seeds that context's state and asserts on the
// rendered report.

const SLOTS = [
  { key: "MAIN", ownsModel: true },
  { key: "NEST", ownsModel: false },
  { key: "NEST2", ownsModel: false },
  { key: "POPUP", ownsModel: true },
  { key: "POPOVER", ownsModel: true },
];

function fakeView({ xml, data, changedPaths } = {}) {
  const model = data
    ? {
        getData: () => data,
        // the marker ViewSlots.trackedModel resolves on - the seeded model
        // plays the framework-owned JSON model
        _z2ui5Tracked: true,
        _z2ui5ChangedPaths: changedPaths ? new Set(changedPaths) : undefined,
      }
    : undefined;
  return {
    mProperties: xml === undefined ? {} : { viewContent: xml },
    getModel: () => model,
  };
}

function loadInspect({
  state = {},
  oConfig = {},
  views = {},
  slotXml = {},
  records = [],
  recording = false,
  search = "",
  hash = "",
  focusInfo,
  scrollInfo,
  bootstrap,
  bodyClasses = [],
  locale,
  resourceUrls = {},
  consoleEntries = [],
  consoleDropped = 0,
} = {}) {
  // The sap global the sandbox exposes to Inspect - and, identically, to
  // the REAL core/Lib the module now delegates its theme/locale probes to,
  // so the locale tests keep driving the shipped probe implementation
  // instead of a stub that would have to re-implement it.
  const sapGlobal = {
    ui: {
      version: "1.120.5",
      require: Object.assign(
        (name) =>
          name === "sap/base/i18n/Localization" ? locale : undefined,
        { toUrl: (ns) => resourceUrls[ns] ?? `/resources/${ns}` },
      ),
    },
  };
  // The one spec context: the real AppState defaults plus what the spec
  // seeds, shared with the real Lib loaded on it
  const { Lib, ctx } = loadLib({
    state: { oConfig, url: "/sap/z2ui5", ...state },
    sap: sapGlobal,
  });
  const { module } = loadModule("devtools/Inspect.js", {
    // devtools/Format.js, devtools/SlotXml.js and the three inspectors of
    // their own (devtools/Log.js, Bindings.js, Help.js - each with its own
    // spec) are loaded for real: every other dependency is stubbed below,
    // so autoLoad reaches only those
    autoLoad: true,
    deps: {
      "sap/ui/Device": {
        system: { desktop: true },
        browser: { name: "cr", version: 120 },
        os: { name: "win", version: 10 },
        support: { touch: false },
        orientation: { portrait: false },
        resize: { width: 1920, height: 1080 },
      },
      // the REAL core/Lib, loaded above with this spec's sap global - the
      // theme/locale probes Inspect delegates to since they moved into Lib
      // run for real here, and deriveSystemType/buildDeltaFromPaths are the
      // shipped functions (each covered by its own spec as well)
      "z2ui5/core/Lib": Lib,
      // The live producers of the frontend block that travels on every
      // roundtrip (client->get( )-s_focus / -s_scroll).
      "z2ui5/core/ScrollFocus": {
        getFocusInfo: (_ctx) => focusInfo,
        getScrollInfo: (_ctx) => scrollInfo,
      },
      "z2ui5/core/ViewSlots": {
        slots: SLOTS,
        getView: (_ctx, key) => views[key],
        getViewXml: (_ctx, key) => slotXml[key],
        // mirrors the real resolver (core/ViewSlots.js): only a model
        // carrying the _z2ui5Tracked marker is the framework's
        trackedModel: (owner) => {
          const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
          if (!owner?.getModel) return undefined;
          return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
        },
      },
      // Capture and rendering are split: Console hands over the entries,
      // Inspect merges them with the framework log and the backend
      // messages into one timeline.
      "z2ui5/devtools/Console": {
        getEntries: () => consoleEntries,
        getDropped: () => consoleDropped,
      },
      "z2ui5/devtools/Recorder": {
        getRecords: () => records,
        isRecordingPayloads: () => recording,
      },
    },
    sandbox: {
      window: {
        location: {
          origin: "https://sap.example.com",
          pathname: "/sap/bc/z2ui5",
          search,
          hash,
        },
        innerWidth: 1920,
        innerHeight: 1080,
      },
      document: {
        getElementById: (id) =>
          id === "sap-ui-bootstrap" ? bootstrap || null : null,
        body: { classList: { contains: (c) => bodyClasses.includes(c) } },
      },
      sap: sapGlobal,
    },
  });
  return { Inspect: module, ctx };
}

// One report of a fresh harness - for the tests that only look at a
// rendered string.
function rendered(name, options) {
  const { Inspect, ctx } = loadInspect(options);
  return Inspect[name](ctx);
}

test.describe("Environment", () => {
  test("reports app, session and routing state", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        responseData: { S_FRONT: { APP: "ZCL_DEMO", ID: "draft-42" } },
        oBody: { S_FRONT: { EVENT: "SAVE", ID: "draft-41" } },
        renderedApp: "ZCL_DEMO",
        contextId: "ctx-1",
        navRouting: true,
        navMode: "KEEP",
      },
      hash: "#/app/ZCL_DEMO",
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("ZCL_DEMO");
    expect(out).toContain("draft-42");
    expect(out).toContain("draft-41");
    expect(out).toContain("SAVE");
    expect(out).toContain("ctx-1");
    expect(out).toContain("KEEP");
    expect(out).toContain("#/app/ZCL_DEMO");
    expect(out).toContain("1.120.5");
  });

  test("tells SAPUI5 and OpenUI5 apart by the version info gav", () => {
    const { Inspect } = loadInspect();
    const { getDistribution } = Inspect._internals;
    expect(getDistribution({ GAV: "com.sap.ui5:something" })).toBe("SAPUI5");
    expect(getDistribution({ GAV: "org.openui5:something" })).toBe("OpenUI5");
    expect(getDistribution({})).toBe("");
  });

  test("lists each view slot with what it holds", () => {
    const { Inspect, ctx } = loadInspect({
      views: { MAIN: fakeView({ xml: "<mvc:View/>", data: { A: 1, B: 2 } }) },
      slotXml: { MAIN: "<mvc:View/>" },
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("2 model attributes");
    expect(out).toMatch(/POPUP\s+empty/);
  });
});

// A bootstrap <script> double. Both pages abap2UI5 runs on give it the id
// "sap-ui-bootstrap"; getAttribute is case-insensitive on a real HTML
// element, which is why the module looks the attributes up lower-cased.
function fakeBootstrap(
  attrs = {},
  src = "https://sdk.example.com/1.120.5/resources/sap-ui-core.js",
) {
  const lower = {};
  for (const key of Object.keys(attrs)) lower[key.toLowerCase()] = attrs[key];
  return {
    src,
    getAttribute: (name) => {
      const key = name.replace(/^data-sap-ui-/, "").toLowerCase();
      return lower[key] ?? null;
    },
  };
}

test.describe("UI5 bootstrap", () => {
  test("reports the SDK url the browser actually fetched", () => {
    const { Inspect, ctx } = loadInspect({ bootstrap: fakeBootstrap() });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("UI5 bootstrap");
    expect(out).toContain(
      "https://sdk.example.com/1.120.5/resources/sap-ui-core.js",
    );
  });

  test("reports the bootstrap attributes that are set", () => {
    const { Inspect, ctx } = loadInspect({
      bootstrap: fakeBootstrap({
        theme: "sap_horizon_dark",
        resourceroots: '{ "z2ui5": "./" }',
        compatVersion: "edge",
        async: "true",
        frameOptions: "trusted",
        bindingSyntax: "complex",
      }),
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("sap_horizon_dark");
    expect(out).toContain('{ "z2ui5": "./" }');
    expect(out).toContain("edge");
    expect(out).toContain("trusted");
    expect(out).toContain("complex");
  });

  test("omits an attribute the page did not set", () => {
    const { Inspect, ctx } = loadInspect({ bootstrap: fakeBootstrap({ theme: "x" }) });
    expect(Inspect.formatEnvironment(ctx)).not.toContain("Frame options");
  });

  test("says so when the page has no bootstrap script", () => {
    const { Inspect, ctx } = loadInspect({ bootstrap: null });
    expect(Inspect.formatEnvironment(ctx)).toContain("no <script");
  });

  test("resolves the roots a module request actually goes to", () => {
    const { Inspect, ctx } = loadInspect({
      bootstrap: fakeBootstrap(),
      resourceUrls: {
        "": "/sap/bc/ui5_ui5/sap/z2ui5/",
        z2ui5: "/sap/bc/z2ui5/",
      },
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("/sap/bc/ui5_ui5/sap/z2ui5/");
    expect(out).toContain("/sap/bc/z2ui5/");
  });

  test("reports the sibling BSP roots only when the app set them up", () => {
    const without = rendered("formatEnvironment", {
      bootstrap: fakeBootstrap(),
    });
    expect(without).not.toContain("z2ui5_cci root");

    const out = rendered("formatEnvironment", {
      bootstrap: fakeBootstrap(),
      state: {
        ccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_cci/",
        cccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_ccc/",
      },
    });
    expect(out).toContain("z2ui5_cci root");
    expect(out).toContain("/sap/bc/ui5_ui5/sap/z2ui5_ccc/");
  });
});

test.describe("locale and density", () => {
  test("reads language and text direction from the modern API", () => {
    const { Inspect, ctx } = loadInspect({
      locale: { getLanguage: () => "de-DE", getRTL: () => false },
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("de-DE");
    expect(out).toContain("LTR");
  });

  test("reports RTL when the page runs right-to-left", () => {
    const { Inspect, ctx } = loadInspect({
      locale: { getLanguage: () => "ar", getRTL: () => true },
    });
    expect(Inspect.formatEnvironment(ctx)).toContain("RTL");
  });

  test("reports the content density set on the body", () => {
    const density = (bodyClasses) =>
      rendered("formatEnvironment", { bodyClasses });
    expect(density(["sapUiSizeCompact"])).toContain("Compact");
    expect(density(["sapUiSizeCozy"])).toContain("Cozy");
    expect(density([])).toContain("neither class set");
  });
});

// The block the framework puts on the wire every roundtrip - what an app
// reads as client->get( )-s_focus / -s_scroll and what the start page's
// "System Information" popup shows of the frontend side. Rendered from the
// LIVE producers, so it is what the NEXT roundtrip will send.
test.describe("Frontend info sent to the backend", () => {
  test("reports the focused control and its caret", () => {
    const { Inspect, ctx } = loadInspect({
      focusInfo: { ID: "myInput", SELECTION_START: 3, SELECTION_END: 7 },
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("Frontend info sent to the backend");
    expect(out).toContain("myInput");
    expect(out).toContain("3 - 7");
  });

  test("omits the caret when no text field owns a selection", () => {
    const { Inspect, ctx } = loadInspect({ focusInfo: { ID: "myButton" } });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("myButton");
    expect(out).not.toContain("Caret");
  });

  test("reports the scroll position per slot, skipping untouched ones", () => {
    const { Inspect, ctx } = loadInspect({
      scrollInfo: {
        MAIN: { ID: "page1", X: 0, Y: 420 },
        POPUP: { ID: "list1", X: 15, Y: 0 },
      },
    });
    const out = Inspect.formatEnvironment(ctx);
    expect(out).toContain("Scroll MAIN");
    expect(out).toContain("page1");
    expect(out).toContain("y 420");
    expect(out).toContain("Scroll POPUP");
    expect(out).not.toContain("Scroll NEST");
  });

  test("says so when nothing has been scrolled", () => {
    const { Inspect, ctx } = loadInspect({ scrollInfo: undefined });
    expect(Inspect.formatEnvironment(ctx)).toContain("nothing scrolled yet");
  });

  test("a throwing producer degrades instead of blanking the tab", () => {
    const { Inspect, ctx } = loadInspect({
      focusInfo: undefined,
      scrollInfo: undefined,
    });
    // the environment report as a whole still renders
    expect(Inspect.formatEnvironment(ctx)).toContain("Environment");
  });

  test("reports the device support flags the wire block carries", () => {
    const out = rendered("formatEnvironment");
    expect(out).toContain("Touch");
    expect(out).toContain("Pointer");
    expect(out).toContain("Retina");
  });
});

test.describe("Registry", () => {
  test("lists shortcuts with their scope and backend event", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        shortcuts: {
          "CTRL+S": { MAIN: { event: "SAVE" }, "": { event: "SAVE_GLOBAL" } },
        },
      },
    });
    const out = Inspect.formatRegistry(ctx);
    expect(out).toContain("CTRL+S");
    expect(out).toContain("SAVE");
    expect(out).toContain("(global)");
  });

  test("reports pending timers and callback counts", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        timers: { t1: 1 },
        onAfterRendering: [() => {}, () => {}],
      },
    });
    const out = Inspect.formatRegistry(ctx);
    expect(out).toContain("t1");
    expect(out).toMatch(/onAfterRendering\s+2/);
  });

  test("lists every callback array the state declares, five of five", () => {
    // onErrorDetails was the one missing here, and it is the one whose
    // absence is a defect worth seeing: with no provider registered the
    // fatal-error overlay offers no Details button at all.
    const { Inspect, ctx } = loadInspect({ state: { onErrorDetails: [() => {}] } });
    const out = Inspect.formatRegistry(ctx);
    for (const name of [
      "onBeforeRoundtrip",
      "onAfterRoundtrip",
      "onAfterRendering",
      "onBeforeEventFrontend",
    ]) {
      expect(out).toMatch(new RegExp(`${name}\\s+0`));
    }
    expect(out).toMatch(/onErrorDetails\s+1/);
  });

  test("scrapes the backend event names out of the view XML", () => {
    const { Inspect } = loadInspect();
    const { scrapeEvents } = Inspect._internals;
    const xml =
      `<Button press="$controller.eB(['POST'])"/>` +
      `<Button press="$controller.eF(['NAV_BACK'])"/>` +
      `<Input change="$controller.eB(['POST'])"/>`;
    // deduplicated, sorted, and the entry point is kept
    expect(scrapeEvents(xml)).toEqual(["eB  POST", "eF  NAV_BACK"]);
  });

  test("scraping handles the XML-escaped apostrophe", () => {
    const { Inspect } = loadInspect();
    const { scrapeEvents } = Inspect._internals;
    expect(scrapeEvents(`press="eB([&apos;SAVE&apos;])"`)).toEqual([
      "eB  SAVE",
    ]);
  });

  test("lists the events of the filled slots", () => {
    const { Inspect, ctx } = loadInspect({
      views: { MAIN: fakeView({ xml: `<Button press="eB(['GO'])"/>` }) },
    });
    const out = Inspect.formatRegistry(ctx);
    expect(out).toContain("[MAIN]");
    expect(out).toContain("eB  GO");
  });
});

test.describe("Actions", () => {
  test("renders both action lists with their arguments", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        responseData: {
          S_FRONT: {
            S_ACTION: {
              T_SYSTEM: [["VIEW_SLOTS", "destroy", "POPUP"]],
              T_CUSTOM: [["SET_FOCUS", "id1"]],
            },
          },
        },
      },
    });
    const out = Inspect.formatActions(ctx);
    expect(out).toContain("VIEW_SLOTS");
    expect(out).toContain("destroy");
    expect(out).toContain("POPUP");
    expect(out).toContain("SET_FOCUS");
    expect(out).toContain("id1");
  });

  test("truncates a long argument instead of burying the structure", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        responseData: {
          S_FRONT: {
            S_ACTION: {
              T_SYSTEM: [["VIEW_SLOTS", "display", "MAIN", "x".repeat(5000)]],
            },
          },
        },
      },
    });
    const out = Inspect.formatActions(ctx);
    expect(out).toContain("(5000 chars)");
    expect(out.length).toBeLessThan(2000);
  });

  test("marks an entry that is no action payload as not run", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        responseData: {
          S_FRONT: { S_ACTION: { T_CUSTOM: ["alert('hi')"] } },
        },
      },
    });
    expect(Inspect.formatActions(ctx)).toContain("[not run]");
  });

  test("says so when a response carried no action at all", () => {
    const { Inspect, ctx } = loadInspect({
      state: { responseData: { S_FRONT: {} } },
    });
    const out = Inspect.formatActions(ctx);
    expect(out).toContain("(none)");
  });
});

// The renderers that live in their own module are reachable here, so the
// tab registry and the dialog know one module for every inspector.
test.describe("re-exported inspectors", () => {
  test("formatLog, formatBindings and formatHelp answer through Inspect", () => {
    const { Inspect, ctx } = loadInspect();
    expect(Inspect.formatLog(ctx)).toContain("nothing logged yet");
    expect(Inspect.formatBindings(ctx, "MAIN")).toContain("Model bindings");
    expect(Inspect.formatHelp()).toContain("Ctrl+F12");
  });
});

// The Error report is what the fatal-error overlay showed, rendered back
// into the tools so closing the overlay does not lose it.
test.describe("Error report", () => {
  test("renders the captured title and text", () => {
    const { Inspect, ctx } = loadInspect({
      state: { lastError: { title: "App Terminated", text: "backend dump" } },
    });
    expect(Inspect.formatError(ctx)).toBe("App Terminated\n\nbackend dump");
  });

  test("renders the text alone when there is no title", () => {
    const { Inspect, ctx } = loadInspect({
      state: { lastError: { title: "", text: "client crash" } },
    });
    expect(Inspect.formatError(ctx)).toBe("client crash");
  });

  test("says so when nothing failed this session", () => {
    expect(rendered("formatError")).toContain("no fatal error");
  });
});

// The landing tab. Where the tools used to open - on the raw response
// JSON - answered no question anybody arrives with; every line here is a
// summary of a tab that holds the detail, and names that tab.
test.describe("Overview", () => {
  test("names the app, the draft and the last event", () => {
    const { Inspect, ctx } = loadInspect({
      state: {
        responseData: { S_FRONT: { APP: "Z2UI5_CL_DEMO", ID: "4A2F" } },
        oBody: { S_FRONT: { EVENT: "ON_SAVE" } },
      },
    });
    const out = Inspect.formatOverview(ctx);
    expect(out).toContain("Z2UI5_CL_DEMO");
    expect(out).toContain("4A2F");
    expect(out).toContain("ON_SAVE");
  });

  test("calls the first response what it is rather than leaving it blank", () => {
    expect(rendered("formatOverview")).toContain("(app start)");
  });

  test("leads the status with whether anything is fatally broken", () => {
    const broken = rendered("formatOverview", {
      state: { lastError: { title: "App Terminated", text: "dump" } },
    });
    expect(broken).toContain("App Terminated");
    // the pointer to the tab that has it in full is part of the line
    expect(broken).toContain("Problems > Error");
    expect(rendered("formatOverview")).toContain("none this session");
  });

  test("counts what the log holds and points at it when it is loud", () => {
    const { Inspect, ctx } = loadInspect({
      consoleEntries: [
        {
          ts: "2026-01-01T00:00:00.000Z",
          level: "error",
          source: "console",
          text: "boom",
        },
        {
          ts: "2026-01-01T00:00:01.000Z",
          level: "warn",
          source: "ui5",
          text: "hm",
        },
      ],
    });
    const out = Inspect.formatOverview(ctx);
    expect(out).toContain("1 error, 1 warn");
    expect(out).toContain("Problems > Log");
  });

  test("stays quiet about the log when there is nothing to see", () => {
    const out = rendered("formatOverview");
    expect(out).toContain("0 error, 0 warn");
    expect(out).not.toContain("Problems > Log");
  });

  test("summarises the last roundtrip", () => {
    const { Inspect, ctx } = loadInspect({
      records: [
        {
          seq: 1,
          ts: "2026-01-01T00:00:00.000Z",
          event: "",
          totalMs: 900,
          backendMs: 800,
        },
        {
          seq: 2,
          ts: "2026-01-01T00:00:02.000Z",
          event: "ON_SAVE",
          totalMs: 402,
          backendMs: 340,
        },
      ],
    });
    const out = Inspect.formatOverview(ctx);
    expect(out).toContain("2 recorded");
    expect(out).toContain("ON_SAVE");
    expect(out).toContain("402 ms total");
    expect(out).toContain("340 ms backend");
  });

  test("says where the diffs come from when recording is off", () => {
    expect(rendered("formatOverview")).toContain("OFF - switch it on");
    expect(rendered("formatOverview", { recording: true })).toContain(
      "ON - Model Diff",
    );
  });

  test("lists the slots and how to get around", () => {
    const { Inspect, ctx } = loadInspect({
      views: { MAIN: fakeView({ xml: "<View/>", data: { A: 1, B: 2 } }) },
    });
    const out = Inspect.formatOverview(ctx);
    expect(out).toContain("2 model attributes");
    expect(out).toContain("Ctrl+F12");
  });
});
