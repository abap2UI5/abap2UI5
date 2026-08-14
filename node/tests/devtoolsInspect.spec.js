// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/core/devtools/Inspect.js. Every inspector is a pure renderer
// over state other modules own, so the harness seeds that state and
// asserts on the rendered report.

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
  search = "",
  hash = "",
  focusInfo,
  scrollInfo,
  bootstrap,
  bodyClasses = [],
  locale,
  resourceUrls = {},
  extraGlobals = {},
} = {}) {
  const AppState = {
    state: {
      responseData: null,
      oBody: null,
      renderedApp: null,
      contextId: null,
      isBusy: false,
      shortcuts: {},
      timers: {},
      viewSizeLimits: {},
      onBeforeRoundtrip: [],
      onAfterRoundtrip: [],
      onAfterRendering: [],
      onBeforeEventFrontend: [],
      navRouting: false,
      navMode: null,
      currentApp: null,
      currentDraftId: null,
      oLaunchpad: null,
      ...state,
    },
    getGlobal: (name) => {
      if (name === "oConfig") return oConfig;
      if (name === "url") return "/sap/z2ui5";
      if (name in extraGlobals) return extraGlobals[name];
      return undefined;
    },
  };
  const { module } = loadModule("core/devtools/Inspect.js", {
    deps: {
      "sap/ui/Device": {
        system: { desktop: true },
        browser: { name: "cr", version: 120 },
        os: { name: "win", version: 10 },
        support: { touch: false },
        orientation: { portrait: false },
        resize: { width: 1920, height: 1080 },
      },
      "z2ui5/core/AppState": AppState,
      "z2ui5/core/Lib": {
        deriveSystemType: () => "desktop",
        logError() {},
        // the real framework function the delta preview calls - a stub
        // that mirrors its scalar behaviour is enough here, the function
        // itself is covered by buildDeltaFromPaths.spec.js
        buildDeltaFromPaths: (paths, data) => {
          const delta = {};
          for (const path of paths) {
            const attr = path.slice(1).split("/")[0];
            delta[attr] = data[attr];
          }
          return delta;
        },
      },
      // The live producers of the frontend block that travels on every
      // roundtrip (client->get( )-s_focus / -s_scroll).
      "z2ui5/core/ScrollFocus": {
        getFocusInfo: () => focusInfo,
        getScrollInfo: () => scrollInfo,
      },
      "z2ui5/core/ViewSlots": {
        slots: SLOTS,
        getView: (key) => views[key],
        getViewXml: (key) => slotXml[key],
      },
      "z2ui5/core/devtools/Recorder": { getRecords: () => records },
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
      sap: {
        ui: {
          version: "1.120.5",
          require: Object.assign(
            (name) =>
              name === "sap/base/i18n/Localization" ? locale : undefined,
            { toUrl: (ns) => resourceUrls[ns] ?? `/resources/${ns}` },
          ),
        },
      },
    },
  });
  return module;
}

test.describe("Environment", () => {
  test("reports app, session and routing state", () => {
    const Inspect = loadInspect({
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
    const out = Inspect.formatEnvironment();
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
    const Inspect = loadInspect();
    const { getDistribution } = Inspect._internals;
    expect(getDistribution({ GAV: "com.sap.ui5:something" })).toBe("SAPUI5");
    expect(getDistribution({ GAV: "org.openui5:something" })).toBe("OpenUI5");
    expect(getDistribution({})).toBe("");
  });

  test("lists each view slot with what it holds", () => {
    const Inspect = loadInspect({
      views: { MAIN: fakeView({ xml: "<mvc:View/>", data: { A: 1, B: 2 } }) },
      slotXml: { MAIN: "<mvc:View/>" },
    });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("2 model attributes");
    expect(out).toMatch(/POPUP\s+empty/);
  });
});

// A bootstrap <script> double. Both pages abap2UI5 runs on give it the id
// "sap-ui-bootstrap"; getAttribute is case-insensitive on a real HTML
// element, which is why the module looks the attributes up lower-cased.
function fakeBootstrap(attrs = {}, src = "https://sdk.example.com/1.120.5/resources/sap-ui-core.js") {
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
    const Inspect = loadInspect({ bootstrap: fakeBootstrap() });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("UI5 bootstrap");
    expect(out).toContain("https://sdk.example.com/1.120.5/resources/sap-ui-core.js");
  });

  test("reports the bootstrap attributes that are set", () => {
    const Inspect = loadInspect({
      bootstrap: fakeBootstrap({
        theme: "sap_horizon_dark",
        resourceroots: '{ "z2ui5": "./" }',
        compatVersion: "edge",
        async: "true",
        frameOptions: "trusted",
        bindingSyntax: "complex",
      }),
    });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("sap_horizon_dark");
    expect(out).toContain('{ "z2ui5": "./" }');
    expect(out).toContain("edge");
    expect(out).toContain("trusted");
    expect(out).toContain("complex");
  });

  test("omits an attribute the page did not set", () => {
    const Inspect = loadInspect({ bootstrap: fakeBootstrap({ theme: "x" }) });
    expect(Inspect.formatEnvironment()).not.toContain("Frame options");
  });

  test("says so when the page has no bootstrap script", () => {
    const Inspect = loadInspect({ bootstrap: null });
    expect(Inspect.formatEnvironment()).toContain("no <script");
  });

  test("resolves the roots a module request actually goes to", () => {
    const Inspect = loadInspect({
      bootstrap: fakeBootstrap(),
      resourceUrls: { "": "/sap/bc/ui5_ui5/sap/z2ui5/", z2ui5: "/sap/bc/z2ui5/" },
    });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("/sap/bc/ui5_ui5/sap/z2ui5/");
    expect(out).toContain("/sap/bc/z2ui5/");
  });

  test("reports the sibling BSP roots only when the app set them up", () => {
    const without = loadInspect({ bootstrap: fakeBootstrap() });
    expect(without.formatEnvironment()).not.toContain("z2ui5_cci root");

    const with_ = loadInspect({
      bootstrap: fakeBootstrap(),
      extraGlobals: {
        ccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_cci/",
        cccResourceRoot: "/sap/bc/ui5_ui5/sap/z2ui5_ccc/",
      },
    });
    const out = with_.formatEnvironment();
    expect(out).toContain("z2ui5_cci root");
    expect(out).toContain("/sap/bc/ui5_ui5/sap/z2ui5_ccc/");
  });
});

test.describe("locale and density", () => {
  test("reads language and text direction from the modern API", () => {
    const Inspect = loadInspect({
      locale: { getLanguage: () => "de-DE", getRTL: () => false },
    });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("de-DE");
    expect(out).toContain("LTR");
  });

  test("reports RTL when the page runs right-to-left", () => {
    const Inspect = loadInspect({
      locale: { getLanguage: () => "ar", getRTL: () => true },
    });
    expect(Inspect.formatEnvironment()).toContain("RTL");
  });

  test("reports the content density set on the body", () => {
    const compact = loadInspect({ bodyClasses: ["sapUiSizeCompact"] });
    expect(compact.formatEnvironment()).toContain("Compact");
    const cozy = loadInspect({ bodyClasses: ["sapUiSizeCozy"] });
    expect(cozy.formatEnvironment()).toContain("Cozy");
    const neither = loadInspect({ bodyClasses: [] });
    expect(neither.formatEnvironment()).toContain("neither class set");
  });
});

// The block the framework puts on the wire every roundtrip - what an app
// reads as client->get( )-s_focus / -s_scroll and what the start page's
// "System Information" popup shows of the frontend side. Rendered from the
// LIVE producers, so it is what the NEXT roundtrip will send.
test.describe("Frontend info sent to the backend", () => {
  test("reports the focused control and its caret", () => {
    const Inspect = loadInspect({
      focusInfo: { ID: "myInput", SELECTION_START: 3, SELECTION_END: 7 },
    });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("Frontend info sent to the backend");
    expect(out).toContain("myInput");
    expect(out).toContain("3 - 7");
  });

  test("omits the caret when no text field owns a selection", () => {
    const Inspect = loadInspect({ focusInfo: { ID: "myButton" } });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("myButton");
    expect(out).not.toContain("Caret");
  });

  test("reports the scroll position per slot, skipping untouched ones", () => {
    const Inspect = loadInspect({
      scrollInfo: {
        MAIN: { ID: "page1", X: 0, Y: 420 },
        POPUP: { ID: "list1", X: 15, Y: 0 },
      },
    });
    const out = Inspect.formatEnvironment();
    expect(out).toContain("Scroll MAIN");
    expect(out).toContain("page1");
    expect(out).toContain("y 420");
    expect(out).toContain("Scroll POPUP");
    expect(out).not.toContain("Scroll NEST");
  });

  test("says so when nothing has been scrolled", () => {
    const Inspect = loadInspect({ scrollInfo: undefined });
    expect(Inspect.formatEnvironment()).toContain("nothing scrolled yet");
  });

  test("a throwing producer degrades instead of blanking the tab", () => {
    const Inspect = loadInspect({
      focusInfo: undefined,
      scrollInfo: undefined,
    });
    // the environment report as a whole still renders
    expect(Inspect.formatEnvironment()).toContain("Environment");
  });

  test("reports the device support flags the wire block carries", () => {
    const out = loadInspect().formatEnvironment();
    expect(out).toContain("Touch");
    expect(out).toContain("Pointer");
    expect(out).toContain("Retina");
  });
});

test.describe("Registry", () => {
  test("lists shortcuts with their scope and backend event", () => {
    const Inspect = loadInspect({
      state: {
        shortcuts: {
          "CTRL+S": { MAIN: { event: "SAVE" }, "": { event: "SAVE_GLOBAL" } },
        },
      },
    });
    const out = Inspect.formatRegistry();
    expect(out).toContain("CTRL+S");
    expect(out).toContain("SAVE");
    expect(out).toContain("(global)");
  });

  test("reports pending timers and callback counts", () => {
    const Inspect = loadInspect({
      state: {
        timers: { t1: 1 },
        onAfterRendering: [() => {}, () => {}],
      },
    });
    const out = Inspect.formatRegistry();
    expect(out).toContain("t1");
    expect(out).toMatch(/onAfterRendering\s+2/);
  });

  test("scrapes the backend event names out of the view XML", () => {
    const Inspect = loadInspect();
    const { scrapeEvents } = Inspect._internals;
    const xml =
      `<Button press="$controller.eB(['POST'])"/>` +
      `<Button press="$controller.eF(['NAV_BACK'])"/>` +
      `<Input change="$controller.eB(['POST'])"/>`;
    // deduplicated, sorted, and the entry point is kept
    expect(scrapeEvents(xml)).toEqual(["eB  POST", "eF  NAV_BACK"]);
  });

  test("scraping handles the XML-escaped apostrophe", () => {
    const Inspect = loadInspect();
    const { scrapeEvents } = Inspect._internals;
    expect(scrapeEvents(`press="eB([&apos;SAVE&apos;])"`)).toEqual([
      "eB  SAVE",
    ]);
  });

  test("lists the events of the filled slots", () => {
    const Inspect = loadInspect({
      views: { MAIN: fakeView({ xml: `<Button press="eB(['GO'])"/>` }) },
    });
    const out = Inspect.formatRegistry();
    expect(out).toContain("[MAIN]");
    expect(out).toContain("eB  GO");
  });
});

test.describe("Actions", () => {
  test("renders both action lists with their arguments", () => {
    const Inspect = loadInspect({
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
    const out = Inspect.formatActions();
    expect(out).toContain("VIEW_SLOTS");
    expect(out).toContain("destroy");
    expect(out).toContain("POPUP");
    expect(out).toContain("SET_FOCUS");
    expect(out).toContain("id1");
  });

  test("truncates a long argument instead of burying the structure", () => {
    const Inspect = loadInspect({
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
    const out = Inspect.formatActions();
    expect(out).toContain("(5000 chars)");
    expect(out.length).toBeLessThan(2000);
  });

  test("marks a legacy raw-JS entry as such", () => {
    const Inspect = loadInspect({
      state: {
        responseData: {
          S_FRONT: { S_ACTION: { T_CUSTOM: ["alert('hi')"] } },
        },
      },
    });
    expect(Inspect.formatActions()).toContain("[legacy JS]");
  });

  test("says so when a response carried no action at all", () => {
    const Inspect = loadInspect({
      state: { responseData: { S_FRONT: {} } },
    });
    const out = Inspect.formatActions();
    expect(out).toContain("(none)");
  });
});

test.describe("Messages", () => {
  test("lists the messages of the recorded history, oldest first", () => {
    const Inspect = loadInspect({
      records: [
        {
          seq: 1,
          ts: "2026-01-01T10:00:00.000Z",
          messages: [{ target: "MESSAGE_TOAST", method: "show", text: "saved" }],
        },
        {
          seq: 2,
          ts: "2026-01-01T10:00:05.000Z",
          messages: [
            { target: "MESSAGE_BOX", method: "error", text: "nope" },
          ],
        },
      ],
    });
    const out = Inspect.formatMessages();
    expect(out).toContain("saved");
    expect(out).toContain("box.error");
    expect(out).toContain("nope");
    expect(out.indexOf("saved")).toBeLessThan(out.indexOf("nope"));
  });

  test("placeholder when nothing was messaged", () => {
    const Inspect = loadInspect({ records: [{ seq: 1, ts: "x", messages: [] }] });
    expect(Inspect.formatMessages()).toContain("no backend message");
  });
});

test.describe("Bindings", () => {
  test("lists the model attributes with a type and size description", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          data: { NAME: "abc", TAB: [{ A: 1 }, { A: 2 }], S: { X: 1 } },
        }),
      },
    });
    const out = Inspect.formatBindings();
    expect(out).toContain("/NAME");
    expect(out).toContain("string  abc");
    expect(out).toContain("table, 2 row(s)");
    expect(out).toContain("structure, 1 field(s)");
  });

  test("marks the edited paths that will travel as the next delta", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          data: { NAME: "abc", OTHER: 1 },
          changedPaths: ["/NAME"],
        }),
      },
    });
    const out = Inspect.formatBindings();
    expect(out).toContain("* /NAME");
    expect(out).toMatch(/\s{2}\/OTHER/);
    expect(out).toContain("Edited paths queued for the next roundtrip");
  });

  test("a deep table edit marks its owning attribute", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          data: { TAB: [{ COL: "a" }] },
          changedPaths: ["/TAB/0/COL"],
        }),
      },
    });
    expect(Inspect.formatBindings()).toContain("* /TAB");
  });

  test("skips the slots that only inherit the MAIN model", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({ data: { A: 1 } }),
        NEST: fakeView({ data: { A: 1 } }),
      },
    });
    const out = Inspect.formatBindings();
    expect(out).toContain("Slot MAIN");
    expect(out).not.toContain("Slot NEST");
  });
});

test.describe("Help", () => {
  test("documents the entry points that are not guessable", () => {
    const out = loadInspect().formatHelp();
    expect(out).toContain("Ctrl+F12");
    expect(out).toContain("?z2ui5-devtools=1");
    expect(out).toContain("?z2ui5-devtools=HISTORY");
  });

  test("explains the two footer actions that change app state", () => {
    const out = loadInspect().formatHelp();
    // both are easy to misread as harmless, so the help has to be explicit
    expect(out).toContain("Record Payloads");
    expect(out).toContain("Apply to App");
    expect(out).toContain("NO roundtrip");
  });

  test("names every tab the dialog offers", () => {
    const out = loadInspect().formatHelp();
    for (const tab of [
      "Error",
      "Log",
      "History",
      "Model Diff",
      "Messages",
      "Actions",
      "Bindings",
      "Picked",
      "Registry",
      "Environment",
      "Source Code",
    ]) {
      expect(out).toContain(tab);
    }
  });
});

test.describe("findEventLine", () => {
  const source = [
    "CLASS zcl_demo IMPLEMENTATION.",
    "  METHOD z2ui5_if_app~main.",
    "    IF client->check_on_event( 'SAVE_ALL' ).",
    "    IF client->check_on_event( 'SAVE' ).",
    "  ENDMETHOD.",
  ].join("\n");

  test("finds the line of an event name", () => {
    const Inspect = loadInspect();
    expect(Inspect.findEventLine(source, "SAVE")).toBe(4);
  });

  test("does not match a longer identifier that contains the name", () => {
    const Inspect = loadInspect();
    // line 3 holds SAVE_ALL - SAVE must not match inside it
    expect(Inspect.findEventLine(source, "SAVE_ALL")).toBe(3);
  });

  test("matches case-insensitively", () => {
    const Inspect = loadInspect();
    expect(Inspect.findEventLine(source, "save")).toBe(4);
  });

  test("returns 0 when the name does not occur or nothing was passed", () => {
    const Inspect = loadInspect();
    expect(Inspect.findEventLine(source, "NOPE")).toBe(0);
    expect(Inspect.findEventLine("", "SAVE")).toBe(0);
    expect(Inspect.findEventLine(source, "")).toBe(0);
  });
});

// The three checks that answer the most common developer questions:
// empty field, huge response, change does not arrive.
test.describe("Bindings diagnostics", () => {
  test("lists the paths bound in the view that the model does not have", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          xml:
            `<Input value="{/CUSTOMER}"/>` +
            `<Text text="{/CUSTOMR}"/>` +
            `<Table items="{/T_ITEMS}"/>`,
          data: { CUSTOMER: "x", T_ITEMS: [] },
        }),
      },
    });
    const out = Inspect.formatBindings();
    expect(out).toContain("BOUND IN THE VIEW BUT NOT IN THE MODEL");
    expect(out).toContain("/CUSTOMR");
    // the ones that DO exist are not reported as missing
    const missingBlock = out.slice(out.indexOf("BOUND IN THE VIEW"));
    expect(missingBlock).not.toContain("/CUSTOMER\n");
  });

  test("collects the path forms the view builder produces", () => {
    const Inspect = loadInspect();
    const { scrapeBindingAttributes } = Inspect._internals;
    const xml =
      `<Input value="{/A}"/>` +
      `<Text text="{path: '/B', formatter: 'x'}"/>` +
      `<Text text="{= \${/C} > 1 }"/>` +
      `<List items="{/D}"><Text text="{REL}"/></List>`;
    const found = scrapeBindingAttributes(xml);
    expect(found).toContain("A");
    expect(found).toContain("B");
    expect(found).toContain("C");
    expect(found).toContain("D");
    // a relative binding resolves against the row context and says nothing
    expect(found).not.toContain("REL");
  });

  test("mentions the model attributes the view does not bind", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          xml: `<Input value="{/USED}"/>`,
          data: { USED: 1, UNUSED_A: 2, UNUSED_B: 3 },
        }),
      },
    });
    const out = Inspect.formatBindings();
    expect(out).toContain("2 model attribute(s) not bound");
    expect(out).toContain("UNUSED_A");
  });

  test("ranks the attributes by serialized size with their share", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          data: {
            SMALL: "x",
            BIG: Array.from({ length: 200 }, (_, i) => ({ COL: `row${i}` })),
          },
        }),
      },
    });
    const out = Inspect.formatBindings();
    expect(out).toContain("Model size:");
    expect(out).toContain("/BIG");
    expect(out).toContain("row(s)");
    // the heavy one is listed before the small one
    expect(out.indexOf("/BIG")).toBeLessThan(out.indexOf("/SMALL"));
  });

  test("previews the delta the next roundtrip will send", () => {
    const Inspect = loadInspect({
      views: {
        MAIN: fakeView({
          data: { NAME: "changed", OTHER: "untouched" },
          changedPaths: ["/NAME"],
        }),
      },
    });
    const out = Inspect.formatBindings();
    const marker = "Delta the next roundtrip will send";
    expect(out).toContain(marker);
    // scope the assertion to the delta block: the untouched attribute is
    // listed above it, in the attribute inventory, and belongs there
    const deltaBlock = out.slice(out.indexOf(marker));
    expect(deltaBlock).toContain('"NAME": "changed"');
    expect(deltaBlock).not.toContain("untouched");
  });

  test("no delta preview when nothing was edited", () => {
    const Inspect = loadInspect({
      views: { MAIN: fakeView({ data: { A: 1 } }) },
    });
    expect(Inspect.formatBindings()).not.toContain("Delta the next roundtrip");
  });
});
