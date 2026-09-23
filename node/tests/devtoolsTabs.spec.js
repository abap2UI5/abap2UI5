// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// Tests the real registry shipped in app/webapp/devtools/Tabs.js - the ONE
// table that says what a developer-tools tab is.
//
// It exists because that fact used to be written down four times (a source
// table, a list of the tabs with their own render branch, the search's scan
// list and the export's section list) and they drifted: the search never
// looked at the Model Diff or the picked control, and the export's section
// titles named tabs that do not exist. The specs below pin the properties
// that made that drift possible - every tab reachable, searchable and
// exportable from the same table. What a tab shows is the state of one
// component context (core/Context.js), which every probe takes first.

// Mimics the relevant shape of a real sap.ui.core.mvc.XMLView: the raw XML
// string is kept as a pseudo property in mProperties, but is NOT declared
// in the control metadata - getProperty("viewContent") therefore throws.
function fakeXmlView(viewContent, data) {
  return {
    mProperties: viewContent === undefined ? {} : { viewContent },
    getProperty(name) {
      throw new Error(`Property "${name}" does not exist in Element`);
    },
    getModel: () => (data ? { getData: () => data } : undefined),
  };
}

function loadTabs({
  views = {},
  slotXml = {},
  responseData = null,
  oBody = null,
  lastError = null,
  recording = false,
  pickReport = "",
  inspect = {},
} = {}) {
  const ctx = specContext({ responseData, oBody, lastError });
  const { module } = loadModule("devtools/Tabs.js", {
    autoLoad: true,
    deps: {
      "z2ui5/core/ViewSlots": {
        getView: (_ctx, key) => views[key],
        getViewXml: (_ctx, key) => slotXml[key],
        // the shipped resolver, byte for byte (core/ViewSlots.js): the
        // framework model is the DEFAULT one, or the named "http" one once
        // SWITCH_DEFAULT_MODEL_PATH moved OData into the default slot
        trackedModel: (owner) => {
          const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
          if (!owner?.getModel) return undefined;
          return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
        },
      },
      "z2ui5/devtools/Inspect": {
        formatOverview: () => "OVERVIEW REPORT",
        formatError: () => "ERROR REPORT",
        formatLog: () => "LOG REPORT",
        formatActions: () => "ACTIONS REPORT",
        formatRegistry: () => "REGISTRY REPORT",
        formatEnvironment: () => "ENV REPORT",
        formatBindings: (_ctx, slot) => `BINDINGS REPORT ${slot || "(all)"}`,
        ...inspect,
      },
      "z2ui5/devtools/Picker": { lastReport: () => pickReport },
      "z2ui5/devtools/Recorder": {
        isRecordingPayloads: () => recording,
        formatHistory: () => "HISTORY REPORT",
        formatModelDiff: () => "MODEL DIFF REPORT",
        formatViewDiff: () => "VIEW DIFF REPORT",
      },
    },
    sandbox: {
      // devtools/Format.js is loaded for real; with these stubs
      // prettifyXml degrades to the identity function, which is exactly
      // its documented fallback.
      XMLSerializer: class {
        serializeToString() {
          return "";
        }
      },
      DOMParser: class {
        parseFromString() {
          return {};
        }
      },
      XSLTProcessor: class {
        importStylesheet() {}
        transformToDocument() {
          return null;
        }
      },
    },
  });
  return { Tabs: module, ctx };
}

// A MAIN view built with switch_default_model_path: the DEFAULT model is the
// app's OData client - which carries no getData( ) at all - and the framework
// JSON model sits under the name "http", carrying the tracker marker.
function fakeSwitchModeView(viewContent, data) {
  const odata = { isA: () => true };
  const json = { _z2ui5Tracked: true, getData: () => data };
  return {
    mProperties: { viewContent },
    getProperty(name) {
      throw new Error(`Property "${name}" does not exist in Element`);
    },
    getModel: (name) => (name === "http" ? json : odata),
  };
}

test.describe("Groups", () => {
  test("six groups, in the order a debugging session runs", () => {
    const { Tabs } = loadTabs();
    expect(Tabs.GROUPS.map((g) => g.key)).toEqual([
      "OVERVIEW",
      "PROBLEMS",
      "ROUNDTRIPS",
      "VIEWDATA",
      "SYSTEM",
      "SEARCH",
    ]);
  });

  test("every tab belongs to a declared group", () => {
    const { Tabs } = loadTabs();
    const known = new Set(Tabs.GROUPS.map((g) => g.key));
    for (const tab of Tabs._internals.TABS) {
      expect(known.has(tab.group), `${tab.key} -> ${tab.group}`).toBe(true);
    }
  });

  test("the tools land on the Overview, not on raw response JSON", () => {
    const { Tabs, ctx } = loadTabs();
    expect(Tabs.DEFAULT_GROUP).toBe("OVERVIEW");
    expect(Tabs.firstTabOf(ctx, "OVERVIEW")).toBe("OVERVIEW");
  });
});

test.describe("Tab keys are a compatibility surface", () => {
  // "?z2ui5-devtools=<KEY>" and the remembered last tab in sessionStorage
  // both store these. A key that stopped resolving would silently reopen
  // somewhere else, which is exactly the kind of drift this table exists
  // to prevent - so the whole pre-regrouping key space is pinned here.
  for (const key of [
    "ERROR",
    "LOG",
    "HISTORY",
    "DIFF",
    "VIEWDIFF",
    "ACTIONS",
    "BINDINGS",
    "PICK",
    "REGISTRY",
    "ENV",
    "REQUEST",
    "PLAIN",
    "SOURCE",
    "VIEW",
    "MODEL",
    "POPUP",
    "POPUP_MODEL",
    "POPOVER",
    "POPOVER_MODEL",
    "NEST1",
    "NEST2",
  ]) {
    test(`${key} still resolves`, () => {
      expect(loadTabs().Tabs.isKnown(key)).toBe(true);
    });
  }

  test("an unknown key does not", () => {
    expect(loadTabs().Tabs.isKnown("MESSAGES")).toBe(false);
    expect(loadTabs().Tabs.isKnown("")).toBe(false);
  });
});

test.describe("Availability", () => {
  test("the Error tab is offered only once something failed", () => {
    const { Tabs, ctx } = loadTabs();
    expect(Tabs.isEnabled(ctx, Tabs.get("ERROR"))).toBe(false);
    const withError = loadTabs({ lastError: { title: "x", text: "y" } });
    expect(
      withError.Tabs.isEnabled(withError.ctx, withError.Tabs.get("ERROR")),
    ).toBe(true);
  });

  test("an empty slot is offered no sub-view at all", () => {
    const { Tabs, ctx } = loadTabs();
    expect(Tabs.isEnabled(ctx, Tabs.get("POPUP"))).toBe(false);
    expect(Tabs.enabledSlots(ctx)).toEqual([]);
  });

  test("a filled slot brings its XML", () => {
    const { Tabs, ctx } = loadTabs({ slotXml: { POPUP: "<Dialog/>" } });
    expect(Tabs.isEnabled(ctx, Tabs.get("POPUP"))).toBe(true);
    expect(Tabs.enabledSlots(ctx).map((s) => s.key)).toEqual(["POPUP"]);
  });

  test("a model sub-view needs the model to carry data", () => {
    const empty = loadTabs({ views: { MAIN: fakeXmlView("<View/>", {}) } });
    expect(empty.Tabs.isEnabled(empty.ctx, empty.Tabs.get("MODEL"))).toBe(
      false,
    );
    const filled = loadTabs({
      views: { MAIN: fakeXmlView("<View/>", { NAME: "x" }) },
    });
    expect(filled.Tabs.isEnabled(filled.ctx, filled.Tabs.get("MODEL"))).toBe(
      true,
    );
  });

  // With OData in the default slot the framework model is the named "http"
  // one. Reading the DEFAULT model here answered the OData client, which has
  // no getData( ) - so both the Model and the Bindings sub-view of a
  // switch-mode app were hidden, while the bindings renderer next door
  // resolved the model correctly and had plenty to show.
  test("switch mode: the model sub-views follow the framework model", () => {
    const { Tabs, ctx } = loadTabs({
      views: { MAIN: fakeSwitchModeView("<View/>", { NAME: "x" }) },
    });
    expect(Tabs.isEnabled(ctx, Tabs.get("MODEL"))).toBe(true);
    expect(Tabs.isEnabled(ctx, Tabs.get("BINDINGS"))).toBe(true);
    expect(Tabs.render(ctx, "MODEL")).toContain("NAME");
  });

  test("a source that throws while deciding hides its tab rather than the strip", () => {
    const { Tabs, ctx } = loadTabs();
    expect(
      Tabs.isEnabled(ctx, {
        key: "X",
        label: "X",
        enabled: () => {
          throw new Error("boom");
        },
      }),
    ).toBe(false);
  });
});

test.describe("View & Data - slot x aspect", () => {
  const filled = () =>
    loadTabs({
      views: {
        MAIN: fakeXmlView("<mvc:View/>", { NAME: "x" }),
        POPUP: fakeXmlView("<Dialog/>", { PNAME: "y" }),
        NEST: fakeXmlView("<core:View/>"),
      },
    });

  test("the slot selector offers only the filled slots, in order", () => {
    const { Tabs, ctx } = filled();
    expect(Tabs.enabledSlots(ctx).map((s) => s.key)).toEqual([
      "MAIN",
      "POPUP",
      "NEST",
    ]);
  });

  test("a slot with a model offers all three aspects", () => {
    const { Tabs, ctx } = filled();
    expect(Tabs.aspectsOfSlot(ctx, "MAIN").map((t) => t.aspect)).toEqual([
      "XML",
      "MODEL",
      "BINDINGS",
    ]);
  });

  test("a nested slot offers only its XML - it inherits MAIN's model", () => {
    const { Tabs, ctx } = filled();
    expect(Tabs.aspectsOfSlot(ctx, "NEST").map((t) => t.key)).toEqual([
      "NEST1",
    ]);
  });

  test("switching slot keeps the aspect where the new slot has it", () => {
    const { Tabs, ctx } = filled();
    expect(Tabs.tabFor(ctx, "POPUP", "BINDINGS")).toBe("POPUP_BINDINGS");
    expect(Tabs.tabFor(ctx, "POPUP", "MODEL")).toBe("POPUP_MODEL");
  });

  test("and falls back to the slot's first aspect where it does not", () => {
    // going from Main/Bindings to a nested view has to land somewhere
    const { Tabs, ctx } = filled();
    expect(Tabs.tabFor(ctx, "NEST", "BINDINGS")).toBe("NEST1");
  });

  test("the picked control is in the group but is not about a slot", () => {
    const { Tabs } = filled();
    expect(Tabs.get("PICK").group).toBe("VIEWDATA");
    expect(Tabs.get("PICK").slot).toBe(undefined);
  });
});

test.describe("Rendering", () => {
  test("renders a tab through its own producer", () => {
    const { Tabs, ctx } = loadTabs();
    expect(Tabs.render(ctx, "LOG")).toBe("LOG REPORT");
  });

  test("the bindings tab is scoped to its slot", () => {
    const { Tabs, ctx } = loadTabs({
      views: { POPUP: fakeXmlView("<Dialog/>", { A: 1 }) },
    });
    expect(Tabs.render(ctx, "POPUP_BINDINGS")).toBe("BINDINGS REPORT POPUP");
  });

  test("a throwing producer names the tab instead of blanking the dialog", () => {
    const { Tabs, ctx } = loadTabs({
      inspect: {
        formatLog: () => {
          throw new Error("inspector broke");
        },
      },
    });
    const out = Tabs.render(ctx, "LOG");
    expect(out).toContain("Log could not be rendered");
    expect(out).toContain("inspector broke");
  });

  test("an unknown key renders nothing rather than throwing", () => {
    const { Tabs, ctx } = loadTabs();
    expect(Tabs.render(ctx, "NOPE")).toBe("");
  });
});

test.describe("Cross-tab search", () => {
  // one search over a fresh harness whose slots carry the term
  const searchable = (term) => {
    const { Tabs, ctx } = loadTabs({
      views: { MAIN: fakeXmlView('<Input value="{/CUSTOMER}"/>', { A: 1 }) },
      responseData: { MODEL: { CUSTOMER: "Miller AG" } },
      inspect: { formatBindings: () => "/CUSTOMER  string  Miller AG" },
    });
    return Tabs.search(ctx, term);
  };

  test("reports every tab that contains the term", () => {
    const out = searchable("CUSTOMER");
    expect(out).toContain("View & Data > Main > XML");
    expect(out).toContain("View & Data > Main > Bindings");
    expect(out).toContain("hit(s)");
  });

  // The regression this whole module was written for: three slots have a
  // sub-view called "XML", so a bare "[XML] 4 hits" says nothing about
  // where to look.
  test("names the group and slot, not just the sub-view", () => {
    const { Tabs, ctx } = loadTabs({ slotXml: { POPUP: '<Input value="{/HIT}"/>' } });
    expect(Tabs.search(ctx, "HIT")).toContain("View & Data > Popup > XML");
  });

  test("is case-insensitive and shows the line number", () => {
    const out = searchable("customer");
    expect(out).toContain("View & Data > Main > XML");
    expect(out).toMatch(/\d+: /);
  });

  test("says so when nothing matches", () => {
    expect(searchable("zzz-nothing")).toContain("no hit");
  });

  test("an empty term asks for one instead of listing everything", () => {
    expect(searchable("")).toContain("enter a search term");
  });

  test("a throwing source does not blank the whole result", () => {
    const { Tabs, ctx } = loadTabs({
      views: { MAIN: fakeXmlView("<Input value='{/NEEDLE}'/>") },
      inspect: {
        formatEnvironment: () => {
          throw new Error("inspector broke");
        },
      },
    });
    expect(Tabs.search(ctx, "NEEDLE")).toContain("View & Data > Main > XML");
  });

  // Both of these were invisible to the old hand-written scan list.
  test("searches the model diff", () => {
    const { Tabs, ctx } = loadTabs({ recording: true });
    expect(Tabs.search(ctx, "MODEL DIFF")).toContain("Roundtrips > Model Diff");
  });

  test("searches the picked control", () => {
    const { Tabs, ctx } = loadTabs({ pickReport: "Control sap.m.Input NEEDLE" });
    expect(Tabs.search(ctx, "NEEDLE")).toContain("View & Data > Picked Control");
  });

  // The search lives on a tab of its own now; scanning that tab would
  // report the previous result as a hit, and exporting it would ship a
  // stale result nobody asked for.
  test("the Search tab is reachable but never scanned or exported", () => {
    const { Tabs, ctx } = loadTabs();
    expect(Tabs.isKnown("SEARCH")).toBe(true);
    expect(Tabs.firstTabOf(ctx, "SEARCH")).toBe("SEARCH");
    expect(Tabs.searchableTabs(ctx).map((t) => t.key)).not.toContain("SEARCH");
    expect(Tabs.exportTabs(ctx).map((t) => t.key)).not.toContain("SEARCH");
  });
});

test.describe("Export set", () => {
  test("is ordered by exportOrder, environment first", () => {
    const { Tabs, ctx } = loadTabs();
    const titles = Tabs.exportTabs(ctx).map((t) => t.exportTitle || t.label);
    expect(titles[0]).toBe("Environment");
  });

  test("every exported tab has a title and they are unique", () => {
    // The old export invented its own titles ("ROUNDTRIP HISTORY") and
    // told the reader to open a tab of that name - which does not exist.
    const { Tabs, ctx } = loadTabs({
      views: { MAIN: fakeXmlView("<View/>", { A: 1 }) },
      slotXml: { POPUP: "<Dialog/>" },
      lastError: { title: "x", text: "y" },
      recording: true,
    });
    const titles = Tabs.exportTabs(ctx).map((tab) => Tabs.exportTitle(tab));
    expect(titles.length).toBeGreaterThan(5);
    for (const title of titles) expect(title).toBeTruthy();
    expect(new Set(titles).size).toBe(titles.length);
  });

  // Every slot has a sub-view called "XML", so the label alone is not a
  // section title: three slots would export three sections called "XML"
  // and the reader could not tell which popup a block belonged to.
  test("a slot's sections name the slot", () => {
    const { Tabs, ctx } = loadTabs({
      views: {
        MAIN: fakeXmlView("<mvc:View/>", { A: 1 }),
        POPUP: fakeXmlView("<Dialog/>", { B: 2 }),
        POPOVER: fakeXmlView("<Popover/>"),
        NEST: fakeXmlView("<core:View/>"),
        NEST2: fakeXmlView("<core:View/>"),
      },
    });
    for (const tab of Tabs.exportTabs(ctx)) {
      if (!tab.slot) continue;
      expect(tab.exportTitle, `${tab.key} needs an explicit export title`).
        toBeTruthy();
    }
    const titles = Tabs.exportTabs(ctx).map((tab) => Tabs.exportTitle(tab));
    expect(titles).toContain("POPUP");
    expect(titles).toContain("NEST1");
    expect(new Set(titles).size).toBe(titles.length);
  });

  test("the diffs only travel when payloads were actually recorded", () => {
    const exported = (options) => {
      const { Tabs, ctx } = loadTabs(options);
      return Tabs.exportTabs(ctx).map((t) => t.key);
    };
    expect(exported()).not.toContain("DIFF");
    expect(exported({ recording: true })).toContain("DIFF");
  });

  test("an empty slot exports nothing for that slot", () => {
    const { Tabs, ctx } = loadTabs();
    const keys = Tabs.exportTabs(ctx).map((t) => t.key);
    expect(keys).not.toContain("POPUP");
    expect(keys).not.toContain("POPUP_MODEL");
  });
});
