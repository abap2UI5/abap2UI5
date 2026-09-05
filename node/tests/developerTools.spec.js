// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/devtools/DeveloperTools.js - the dialog - composed with the
// real devtools/Tabs.js, Format.js, Report.js and AbapSource.js, so what
// is exercised here is the composition that ships. Only the leaf modules
// that own their own behaviour (and their own specs) are stubbed.
//
// What the dialog is responsible for, and what these specs pin: six
// groups instead of twenty-two flat tabs, the two selectors of View &
// Data, and getting the right string into the editor. What a tab IS lives
// in Tabs.js (devtoolsTabs.spec.js), the report in Report.js
// (devtoolsReport.spec.js), the ABAP class in AbapSource.js
// (devtoolsAbapSource.spec.js).
//
// The browser XML APIs used at module scope are stubbed minimally;
// prettifyXml degrades to the identity function with these stubs, which is
// exactly its documented fallback behavior.

// Mimics the relevant shape of a real sap.ui.core.mvc.XMLView: the raw XML
// string is kept as a pseudo property in mProperties, but is NOT declared
// in the control metadata - getProperty("viewContent") therefore throws.
// Regression guard: the developer tools must never call getProperty for it
// (#2318 switched to getProperty and broke the View tab).
function fakeXmlView(viewContent, data) {
  return {
    mProperties: viewContent === undefined ? {} : { viewContent },
    getProperty(name) {
      throw new Error(`Property "${name}" does not exist in Element`);
    },
    getModel: () => (data ? { getData: () => data } : undefined),
  };
}

function loadDeveloperTools({
  views = {},
  slotXml = {},
  responseData = null,
  oBody = null,
  errors,
  lastError = null,
  logoutCalls,
  reopenCalls,
  fragment,
  windowStub,
  recorder,
  consoleCapture,
  inspect,
  picker,
  liveEdit,
  // extra sap.ui.define dependencies / sandbox globals - only show() needs
  // them (JSONModel, Lib, sap.ui.require), every other test runs without
  extraDeps = {},
  extraSandbox = {},
  storage = {},
} = {}) {
  const AppState = {
    state: { responseData, oBody, errors, lastError },
    getGlobal: () => undefined,
  };
  // The slot registry is the developer tools' only source for what a slot
  // holds: the live instance and the XML it was filled with.
  const ViewSlots = {
    getView: (key) => views[key],
    getViewXml: (key) => slotXml[key],
  };
  const ErrorView = {
    handleLogout: () => logoutCalls?.push(true),
    reopenErrorDialog: () => reopenCalls?.push(true),
  };
  // The roundtrip recorder owns the History / diff views; the registry
  // only renders the text it returns. Its own behaviour is covered by
  // devtoolsRecorder.spec.js, so a flat stub is enough here.
  const Recorder = recorder || {
    isRecordingPayloads: () => false,
    setRecordingPayloads() {},
    getRecords: () => [],
    formatHistory: () => "(no roundtrip recorded yet)",
    formatModelDiff: () => "(diff needs payload recording)",
    formatViewDiff: () => "(view diff needs payload recording)",
    exportJson: () => "{}",
  };
  // The inspectors, the control picker and the live view editing each own
  // their behaviour (and their own specs); the dialog only routes to them.
  const Inspect = inspect || {
    formatHelp: () => "(help)",
    formatOverview: () => "(overview)",
    formatError: () =>
      lastError
        ? `${lastError.title}\n\n${lastError.text}`
        : "(no fatal error captured this session)",
    formatEnvironment: () => "(environment)",
    formatRegistry: () => "(registry)",
    formatActions: () => "(actions)",
    formatLog: () => "(log)",
    formatBindings: () => "(bindings)",
    findEventLine: () => 0,
  };
  const Console = consoleCapture || {
    isAlertOnError: () => false,
    setAlertOnError() {},
  };
  const Picker = picker || { start() {}, stop() {}, lastReport: () => "" };
  const LiveEdit = liveEdit || {
    apply: () => Promise.resolve("applied"),
    canApply: () => false,
    slotOfTab: () => undefined,
    isBusy: () => false,
  };
  // Control.extend returns the class spec itself; the spec's methods are
  // then invoked with the spec as `this`, close enough to the UI5 runtime
  // for these prototype methods.
  const Control = { extend: (_name, spec) => spec };
  const { module } = loadModule("devtools/DeveloperTools.js", {
    // devtools/Tabs.js, Format.js, Report.js and AbapSource.js are loaded
    // for real - the grouping and the rendering are what these specs are
    // about, and a stub of the registry would test nothing.
    autoLoad: true,
    deps: {
      "sap/ui/core/Control": Control,
      "sap/ui/core/Fragment": fragment,
      // Default Lib stub: the async paths (Apply, Pick, show) guard their
      // continuations with Lib.isDestroyed. The show() tests override it
      // via extraDeps, which is spread after this.
      "z2ui5/core/Lib": {
        isDestroyed: () => false,
        logError() {},
        copyToClipboard() {},
      },
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": AppState,
      "z2ui5/core/ErrorView": ErrorView,
      "z2ui5/devtools/Console": Console,
      "z2ui5/devtools/Recorder": Recorder,
      "z2ui5/devtools/Inspect": Inspect,
      "z2ui5/devtools/Picker": Picker,
      "z2ui5/devtools/LiveEdit": LiveEdit,
      ...extraDeps,
    },
    sandbox: {
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
      // transformToDocument returning a falsy document makes prettifyXml
      // return its input unchanged.
      XSLTProcessor: class {
        importStylesheet() {}
        transformToDocument() {
          return null;
        }
      },
      URLSearchParams,
      window: windowStub || {
        location: { origin: "https://sap.example.com", search: "" },
        open() {},
        // the last-opened sub-view is remembered here
        sessionStorage: {
          getItem: (k) => (k in storage ? storage[k] : null),
          setItem: (k, v) => {
            storage[k] = v;
          },
          removeItem: (k) => {
            delete storage[k];
          },
        },
      },
      ...extraSandbox,
    },
  });
  return { DeveloperTools: module, storage };
}

// A dialog model double. renderTab reads and writes it exactly like the
// JSONModel the fragment is bound to.
function fakeModel(seed = {}) {
  const data = { selectedSlot: "MAIN", ...seed };
  return { model: { getData: () => data, refresh() {} }, data };
}

// Fake selection event (IconTabHeader select / SegmentedButton
// selectionChange - both carry the key on the source).
function fakeSelectEvent(selectedKey, seed) {
  const { model, data } = fakeModel(seed);
  return {
    oEvent: {
      getSource: () => ({
        getSelectedKey: () => selectedKey,
        getModel: () => model,
      }),
    },
    modelData: data,
    oModel: model,
  };
}

test.describe("Groups", () => {
  test("selecting a group opens its first available sub-view", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("ROUNDTRIPS");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.selectedGroup).toBe("ROUNDTRIPS");
    expect(modelData.selectedTab).toBe("HISTORY");
    expect(modelData.isRoundtrips).toBe(true);
  });

  test("a group whose first sub-view is unavailable skips to the next", () => {
    // Problems leads with Error, which only exists once something failed
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("PROBLEMS");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.selectedTab).toBe("LOG");
  });

  test("and opens on it once there is an error", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "App Terminated", text: "boom", onRetry: () => {} },
    });
    const { oEvent, modelData } = fakeSelectEvent("PROBLEMS");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.selectedTab).toBe("ERROR");
    expect(modelData.value).toBe("App Terminated\n\nboom");
  });

  test("renderTab sets the group from the sub-view, not the other way round", () => {
    // the error popup's Details action names ERROR and nothing else
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "x", text: "y" },
    });
    const { model, data } = fakeModel();
    DeveloperTools.renderTab("ERROR", model);
    expect(data.selectedGroup).toBe("PROBLEMS");
    expect(data.isErrorView).toBe(true);
  });
});

test.describe("Sub-views", () => {
  test("the sub-view selector lists the group's available views", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("ROUNDTRIPS");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.views.map((v) => v.key)).toEqual([
      "HISTORY",
      "REQUEST",
      "PLAIN",
      "ACTIONS",
      "DIFF",
      "VIEWDIFF",
    ]);
    expect(modelData.showViewBar).toBe(true);
  });

  test("a group with a single view hides the selector", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("OVERVIEW");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.showViewBar).toBe(false);
    expect(modelData.isOverview).toBe(true);
  });

  test("picking one renders it", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("ACTIONS");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.selectedTab).toBe("ACTIONS");
    expect(modelData.value).toBe("(actions)");
    expect(modelData.type).toBe("text");
    expect(modelData.editor_visible).toBe(true);
  });
});

test.describe("View & Data - the two selectors", () => {
  const filled = (extra = {}) =>
    loadDeveloperTools({
      views: {
        MAIN: fakeXmlView("<mvc:View/>", { NAME: "x" }),
        POPUP: fakeXmlView("<Dialog/>", { PNAME: "y" }),
        NEST: fakeXmlView("<core:View/>"),
      },
      ...extra,
    });

  test("the slot selector offers only the filled slots", () => {
    const { DeveloperTools } = filled();
    const { oEvent, modelData } = fakeSelectEvent("VIEWDATA");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.slots.map((s) => s.key)).toEqual([
      "MAIN",
      "POPUP",
      "NEST",
    ]);
    expect(modelData.showSlotBar).toBe(true);
    expect(modelData.isViewData).toBe(true);
  });

  test("the aspect selector is scoped to the selected slot", () => {
    const { DeveloperTools } = filled();
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(oEvent);
    // the three aspects of MAIN, plus the picked control, which belongs
    // to the group rather than to a slot
    expect(modelData.views.map((v) => v.key)).toEqual([
      "VIEW",
      "MODEL",
      "BINDINGS",
      "PICK",
    ]);
  });

  test("switching slot keeps the aspect", () => {
    const { DeveloperTools } = filled();
    const bindings = fakeSelectEvent("BINDINGS");
    DeveloperTools.onViewSelect(bindings.oEvent);

    const oSource = {
      getSelectedKey: () => "POPUP",
      getModel: () => bindings.oModel,
    };
    DeveloperTools.onSlotSelect({ getSource: () => oSource });
    expect(bindings.modelData.selectedTab).toBe("POPUP_BINDINGS");
    expect(bindings.modelData.selectedSlot).toBe("POPUP");
  });

  test("and falls back when the new slot has no such aspect", () => {
    const { DeveloperTools } = filled();
    const model = fakeSelectEvent("MODEL");
    DeveloperTools.onViewSelect(model.oEvent);
    DeveloperTools.onSlotSelect({
      getSource: () => ({
        getSelectedKey: () => "NEST",
        getModel: () => model.oModel,
      }),
    });
    // a nested slot inherits MAIN's model, so it has only its XML
    expect(model.modelData.selectedTab).toBe("NEST1");
  });

  test("the picked control hides the slot selector", () => {
    const { DeveloperTools } = filled();
    const { oEvent, modelData } = fakeSelectEvent("PICK");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.showSlotBar).toBe(false);
    expect(modelData.value).toContain("No control picked yet");
  });

  // The aspect bar is the aspects of ONE slot. Rendering every tab of the
  // group instead would put all five slots' aspects in a single row and
  // bring back the flat list this regrouping exists to remove.
  test("the aspect bar never spills other slots into the row", () => {
    const { DeveloperTools } = filled();
    const { oEvent, modelData } = fakeSelectEvent("PICK", {
      selectedSlot: "MAIN",
    });
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.views.map((v) => v.key)).toEqual([
      "VIEW",
      "MODEL",
      "BINDINGS",
      "PICK",
    ]);
  });

  test("and keeps the slot the user was on while picking", () => {
    const { DeveloperTools } = filled();
    const popup = fakeSelectEvent("POPUP");
    DeveloperTools.onViewSelect(popup.oEvent);
    DeveloperTools.renderTab("PICK", popup.oModel);
    expect(popup.modelData.selectedSlot).toBe("POPUP");
    expect(popup.modelData.views.map((v) => v.key)).toEqual([
      "POPUP",
      "POPUP_MODEL",
      "POPUP_BINDINGS",
      "PICK",
    ]);
  });

  test("shows the XML kept in the view's mProperties", () => {
    const { DeveloperTools } = filled();
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.value).toBe("<mvc:View/>");
    expect(modelData.type).toBe("xml");
  });

  test("falls back to the XML the slot was filled with", () => {
    // A view built from a `definition` keeps no viewContent - ViewSlots
    // recorded the source when it filled the slot.
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView(undefined) },
      slotXml: { MAIN: "<Page/>" },
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.value).toBe("<Page/>");
  });

  test("a popup torn down without a roundtrip is not offered at all", () => {
    // Regression guard: the tabs used to be derived from the last
    // response's ["VIEW_SLOTS","display","POPUP",...] action. A frontend
    // close (cs_event-popup_close) does no roundtrip, so that response
    // stayed the current one and the developer tools kept showing a popup
    // that was long destroyed. They read the slot itself now.
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView("<mvc:View/>", { A: 1 }) },
      slotXml: {},
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEWDATA");
    DeveloperTools.onGroupSelect(oEvent);
    expect(modelData.slots.map((s) => s.key)).toEqual(["MAIN"]);
    // a single slot needs no selector
    expect(modelData.showSlotBar).toBe(false);
  });
});

test.describe("Error view", () => {
  test("shows the captured fatal error and offers Retry", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: {
        title: "App Terminated",
        text: "backend dump...",
        onRetry: () => {},
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.value).toBe("App Terminated\n\nbackend dump...");
    expect(modelData.type).toBe("text");
    expect(modelData.hasRetry).toBe(true);
    expect(modelData.isErrorView).toBe(true);
  });

  test("hides Retry when the fatal error carried no retry action", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "", text: "client crash", onRetry: null },
    });
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.hasRetry).toBe(false);
  });

  // These used to sit in the footer, offered on all twenty-two tabs
  // including the twenty-one with no error to retry.
  test("the error actions are offered only on the error view", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "x", text: "y", onRetry: () => {} },
    });
    const { oEvent, modelData } = fakeSelectEvent("LOG");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.isErrorView).toBe(false);
    expect(modelData.hasRetry).toBe(false);
  });

  test("onErrorRetry runs the captured retry action", () => {
    let retried = 0;
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "x", text: "y", onRetry: () => (retried += 1) },
    });
    DeveloperTools.onErrorRetry();
    expect(retried).toBe(1);
  });

  test("onErrorLogout delegates to ErrorView.handleLogout", () => {
    const logoutCalls = [];
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "x", text: "y", onRetry: null },
      logoutCalls,
    });
    DeveloperTools.onErrorLogout();
    expect(logoutCalls).toEqual([true]);
  });
});

test.describe("Recorder views", () => {
  test("the History view renders what the recorder hands over", () => {
    const { DeveloperTools } = loadDeveloperTools({
      recorder: {
        isRecordingPayloads: () => false,
        setRecordingPayloads() {},
        getRecords: () => [],
        formatHistory: () => "ROUNDTRIP TABLE",
        formatModelDiff: () => "",
        formatViewDiff: () => "",
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("HISTORY");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.value).toBe("ROUNDTRIP TABLE");
    expect(modelData.type).toBe("text");
  });

  test("the payload toggle forwards to the recorder and re-renders", () => {
    const calls = [];
    let recording = false;
    const { DeveloperTools } = loadDeveloperTools({
      recorder: {
        isRecordingPayloads: () => recording,
        setRecordingPayloads(on) {
          calls.push(on);
          recording = on;
        },
        getRecords: () => [],
        formatHistory: () => (recording ? "ON" : "OFF"),
        formatModelDiff: () => "",
        formatViewDiff: () => "",
      },
    });
    const { model, data } = fakeModel({ selectedTab: "HISTORY" });
    DeveloperTools.onToggleRecordPayloads({
      getSource: () => ({ getPressed: () => true, getModel: () => model }),
    });
    expect(calls).toEqual([true]);
    expect(data.recordPayloads).toBe(true);
    // the open view reports the flag, so it is re-rendered after the switch
    expect(data.value).toBe("ON");
  });
});

test.describe("Inspector views", () => {
  for (const [key, expected] of [
    ["OVERVIEW", "(overview)"],
    ["ENV", "(environment)"],
    ["REGISTRY", "(registry)"],
    ["ACTIONS", "(actions)"],
    ["LOG", "(log)"],
  ]) {
    test(`the ${key} view renders its inspector`, () => {
      const { DeveloperTools } = loadDeveloperTools();
      const { oEvent, modelData } = fakeSelectEvent(key);
      DeveloperTools.onViewSelect(oEvent);
      expect(modelData.value).toBe(expected);
      expect(modelData.type).toBe("text");
    });
  }

  test("the picked-control view explains itself before the first pick", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("PICK");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.value).toContain("No control picked yet");
  });

  test("and shows the report once one was picked", () => {
    const { DeveloperTools } = loadDeveloperTools({
      picker: {
        start() {},
        stop() {},
        lastReport: () => "sap.m.Input  /CUSTOMER  Miller AG",
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("PICK");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.value).toBe("sap.m.Input  /CUSTOMER  Miller AG");
  });
});

test.describe("Live view editing", () => {
  test("a view sub-view offers Apply, other views do not", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView("<mvc:View/>", { A: 1 }) },
      liveEdit: {
        apply: () => Promise.resolve("ok"),
        canApply: (tab) => tab === "VIEW",
        slotOfTab: () => "MAIN",
        isBusy: () => false,
      },
    });
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(view.oEvent);
    expect(view.modelData.canApply).toBe(true);

    const log = fakeSelectEvent("LOG");
    DeveloperTools.onViewSelect(log.oEvent);
    expect(log.modelData.canApply).toBe(false);
  });

  test("Apply forwards the edited XML and reports the result", async () => {
    const applied = [];
    const { DeveloperTools } = loadDeveloperTools({
      liveEdit: {
        apply: (tab, xml) => {
          applied.push({ tab, xml });
          return Promise.resolve("Applied to slot MAIN.");
        },
        canApply: () => true,
        slotOfTab: () => "MAIN",
        isBusy: () => false,
      },
    });
    const { model, data } = fakeModel({
      selectedTab: "VIEW",
      value: '<mvc:View edited="1"/>',
    });
    await DeveloperTools.onApplyXml({ getSource: () => ({ getModel: () => model }) });
    expect(applied).toEqual([{ tab: "VIEW", xml: '<mvc:View edited="1"/>' }]);
    expect(data.statusText).toContain("Applied to slot MAIN");
    expect(data.hasStatusText).toBe(true);
    DeveloperTools.exit();
  });

  test("Apply is refused while a roundtrip is running", async () => {
    const applied = [];
    const { DeveloperTools } = loadDeveloperTools({
      liveEdit: {
        apply: () => {
          applied.push(1);
          return Promise.resolve("ok");
        },
        canApply: () => true,
        slotOfTab: () => "MAIN",
        isBusy: () => true,
      },
    });
    const { model, data } = fakeModel({ selectedTab: "VIEW", value: "<x/>" });
    await DeveloperTools.onApplyXml({ getSource: () => ({ getModel: () => model }) });
    expect(applied.length).toBe(0);
    expect(data.statusText).toContain("roundtrip is running");
    DeveloperTools.exit();
  });

  test("Reset puts the backend's original XML back", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView('<mvc:View original="1"/>') },
    });
    const { model, data } = fakeModel({
      selectedTab: "VIEW",
      value: "<edited/>",
      statusText: "x",
      hasStatusText: true,
    });
    DeveloperTools.onResetXml({ getSource: () => ({ getModel: () => model }) });
    expect(data.value).toBe('<mvc:View original="1"/>');
    expect(data.hasStatusText).toBe(false);
  });

  // Apply re-renders the SLOT from the editor, so from the first Apply on
  // the slot itself carries the edit - reading it back for Reset handed the
  // developer their own edit and called it the original.
  const applying = () => {
    const views = { MAIN: fakeXmlView('<mvc:View original="1"/>') };
    const { DeveloperTools } = loadDeveloperTools({
      views,
      liveEdit: {
        // what LiveEdit.apply really does: the slot ends up holding the XML
        // that was applied to it
        apply: (_tab, xml) => {
          views.MAIN = fakeXmlView(xml);
          return Promise.resolve("Applied to slot MAIN.");
        },
        canApply: () => true,
        slotOfTab: () => "MAIN",
        isBusy: () => false,
      },
    });
    return { DeveloperTools, views };
  };

  const applyAndReset = async (DeveloperTools, model, between) => {
    const oEvent = { getSource: () => ({ getModel: () => model }) };
    await DeveloperTools.onApplyXml(oEvent);
    if (between) between();
    DeveloperTools.onResetXml(oEvent);
  };

  test("Reset after Apply restores the backend's XML, not the edit", async () => {
    const { DeveloperTools } = applying();
    const { model, data } = fakeModel({
      selectedTab: "VIEW",
      value: '<mvc:View edited="1"/>',
    });
    await applyAndReset(DeveloperTools, model);
    expect(data.value).toBe('<mvc:View original="1"/>');
    expect(data.previousValue).toBe('<mvc:View original="1"/>');
    DeveloperTools.exit();
  });

  test("a second Apply does not turn the first edit into the original", async () => {
    const { DeveloperTools } = applying();
    const { model, data } = fakeModel({
      selectedTab: "VIEW",
      value: '<mvc:View edited="1"/>',
    });
    const oEvent = { getSource: () => ({ getModel: () => model }) };
    await DeveloperTools.onApplyXml(oEvent);
    data.value = '<mvc:View edited="2"/>';
    await applyAndReset(DeveloperTools, model);
    expect(data.value).toBe('<mvc:View original="1"/>');
    DeveloperTools.exit();
  });

  test("once a roundtrip replaced the view, Reset restores what IT delivered", async () => {
    // the recorded original is only good while the slot still holds what
    // Apply put there - a response has its own original
    const { DeveloperTools, views } = applying();
    const { model, data } = fakeModel({
      selectedTab: "VIEW",
      value: '<mvc:View edited="1"/>',
    });
    await applyAndReset(DeveloperTools, model, () => {
      views.MAIN = fakeXmlView('<mvc:View fromBackend="2"/>');
    });
    expect(data.value).toBe('<mvc:View fromBackend="2"/>');
    DeveloperTools.exit();
  });
});

test.describe("After Templating toggle", () => {
  // A view whose post-templating DOM records every time it is serialized:
  // producing that variant means walking and prettifying the whole rendered
  // view, and the toggle it feeds is offered only for a templated view.
  const templated = () => {
    const rendered = [];
    const view = fakeXmlView('<mvc:View xmlns:template="x"/>', { A: 1 });
    view._xContent = {
      get outerHTML() {
        rendered.push(1);
        return "<div>after templating</div>";
      },
    };
    const { DeveloperTools } = loadDeveloperTools({ views: { MAIN: view } });
    return { DeveloperTools, rendered };
  };

  const press = (DeveloperTools, oModel, pressed) =>
    DeveloperTools.onTemplatingPress({
      getSource: () => ({ getPressed: () => pressed, getModel: () => oModel }),
    });

  test("selecting a sub-view does not compute the post-templating XML", () => {
    const { DeveloperTools, rendered } = templated();
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(view.oEvent);
    // the toggle is offered...
    expect(view.modelData.isTemplating).toBe(true);
    // ...but nothing was serialized for it yet
    expect(rendered).toHaveLength(0);
    expect(view.modelData.xContent).toBe("");
  });

  test("the first press computes it, the next one reuses it", () => {
    const { DeveloperTools, rendered } = templated();
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(view.oEvent);
    const original = view.modelData.value;

    press(DeveloperTools, view.oModel, true);
    expect(view.modelData.value).toBe("<div>after templating</div>");
    expect(rendered).toHaveLength(1);

    press(DeveloperTools, view.oModel, false);
    expect(view.modelData.value).toBe(original);

    press(DeveloperTools, view.oModel, true);
    expect(view.modelData.value).toBe("<div>after templating</div>");
    // computed once, then kept in the model
    expect(rendered).toHaveLength(1);
  });

  test("moving to another sub-view drops it instead of showing a stale one", () => {
    const { DeveloperTools, rendered } = templated();
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(view.oEvent);
    press(DeveloperTools, view.oModel, true);

    DeveloperTools.renderTab("LOG", view.oModel);
    expect(view.modelData.xContent).toBe("");

    DeveloperTools.renderTab("VIEW", view.oModel);
    press(DeveloperTools, view.oModel, true);
    expect(rendered).toHaveLength(2);
  });
});

test.describe("Search", () => {
  const searchable = () =>
    loadDeveloperTools({
      views: { MAIN: fakeXmlView('<Input value="{/CUSTOMER}"/>', { A: 1 }) },
      responseData: { S_FRONT: { ID: "x" }, MODEL: { CUSTOMER: "Miller AG" } },
    });

  test("searching renders the result on the Search tab", () => {
    const { DeveloperTools } = searchable();
    const { model, data } = fakeModel();
    DeveloperTools.onSearch({
      getSource: () => ({ getValue: () => "CUSTOMER", getModel: () => model }),
    });
    expect(data.searchTerm).toBe("CUSTOMER");
    expect(data.selectedTab).toBe("SEARCH");
    expect(data.selectedGroup).toBe("SEARCH");
    expect(data.isSearch).toBe(true);
    expect(data.value).toContain("View & Data > Main > XML");
    expect(data.type).toBe("text");
  });

  test("opening the Search tab without a term asks for one", () => {
    const { DeveloperTools } = searchable();
    const { model, data } = fakeModel({ searchTerm: "" });
    DeveloperTools.renderTab("SEARCH", model);
    expect(data.value).toContain("enter a search term");
    expect(data.isSearch).toBe(true);
  });

  // The search is a tab again, so leaving and returning is plain
  // navigation - the term stays in the model and the result comes back.
  test("returning to the Search tab re-renders the kept term", () => {
    const { DeveloperTools } = searchable();
    const { model, data } = fakeModel();
    DeveloperTools.onSearch({
      getSource: () => ({ getValue: () => "CUSTOMER", getModel: () => model }),
    });
    DeveloperTools.renderTab("LOG", model);
    expect(data.isSearch).toBe(false);
    expect(data.value).toBe("(log)");
    DeveloperTools.renderTab("SEARCH", model);
    expect(data.value).toContain("View & Data > Main > XML");
  });

  test("a hit inside a templated view offers no templating toggle", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView('<mvc:View xmlns:template="x"/>', { A: 1 }) },
    });
    const { model, data } = fakeModel();
    DeveloperTools.onSearch({
      getSource: () => ({ getValue: () => "template", getModel: () => model }),
    });
    expect(data.value).toContain("hit(s)");
    expect(data.isTemplating).toBe(false);
  });

  test("a search result is never applyable", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView("<mvc:View/>", { A: 1 }) },
      liveEdit: {
        apply: () => Promise.resolve("ok"),
        canApply: () => true,
        slotOfTab: () => "MAIN",
        isBusy: () => false,
      },
    });
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(view.oEvent);
    expect(view.modelData.canApply).toBe(true);
    DeveloperTools.onSearch({
      getSource: () => ({ getValue: () => "View", getModel: () => view.oModel }),
    });
    expect(view.modelData.canApply).toBe(false);
  });
});

test.describe("Copy", () => {
  test("copies what is shown and confirms on the button", () => {
    const copied = [];
    const { DeveloperTools } = loadDeveloperTools({
      extraDeps: {
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          logError() {},
          copyToClipboard: (text) => copied.push(text),
        },
      },
    });
    let label = "Copy";
    const oSource = {
      getModel: () => ({ getData: () => ({ value: "REPORT BODY" }) }),
      getText: () => label,
      setText: (t) => {
        label = t;
      },
    };
    DeveloperTools.onCopyTab({ getSource: () => oSource });
    expect(copied).toEqual(["REPORT BODY"]);
    expect(label).toBe("Copied");
  });

  test("on the ABAP Source view it copies the class, not the previous tab", async () => {
    // that view frames the class and never goes through displayEditor, so
    // `value` still held the sub-view opened before it - Copy put THAT on
    // the clipboard and confirmed "Copied"
    const copied = [];
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: "Z2UI5_CL_MY_APP" } },
      extraDeps: {
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          logError() {},
          copyToClipboard: (text) => copied.push(text),
        },
      },
      extraSandbox: {
        fetch: async () => ({ ok: true, text: async () => "CLASS zcl." }),
      },
    });
    let label = "Copy";
    const oSource = {
      getModel: () => ({
        getData: () => ({ isSourceView: true, value: "PREVIOUS TAB" }),
      }),
      getText: () => label,
      setText: (t) => {
        label = t;
      },
    };
    await DeveloperTools.onCopyTab({ getSource: () => oSource });
    expect(copied).toEqual(["CLASS zcl."]);
    expect(label).toBe("Copied");
  });

  test("an empty view copies an empty string rather than undefined", () => {
    const copied = [];
    const { DeveloperTools } = loadDeveloperTools({
      extraDeps: {
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          logError() {},
          copyToClipboard: (text) => copied.push(text),
        },
      },
    });
    DeveloperTools.onCopyTab({
      getSource: () => ({
        getModel: () => ({ getData: () => ({}) }),
        getText: () => "Copy",
        setText() {},
      }),
    });
    expect(copied).toEqual([""]);
  });
});

test.describe("Report a Bug", () => {
  // The most common reason the tools are opened at all, so it is one
  // press from the footer rather than three through the export popup.
  test("copies the markdown report and says so", async () => {
    const copied = [];
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: {} },
      extraDeps: {
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          logError() {},
          copyToClipboard: (text) => copied.push(text),
        },
      },
    });
    const { model, data } = fakeModel();
    await DeveloperTools.onReportBug({
      getSource: () => ({ getModel: () => model }),
    });
    expect(copied.length).toBe(1);
    expect(copied[0]).toContain("## abap2UI5 - Developer Tools export");
    expect(data.statusText).toContain("Markdown");
    DeveloperTools.exit();
  });
});

test.describe("ABAP Source view", () => {
  test("frames the source and switches the content area over", () => {
    let content = null;
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: "Z2UI5_CL_MY_APP" } },
      fragment: { byId: () => ({ setContent: (html) => (content = html) }) },
      extraSandbox: { fetch: async () => ({ ok: false }) },
    });
    const { oEvent, modelData } = fakeSelectEvent("SOURCE");
    DeveloperTools.onViewSelect(oEvent);
    expect(content).toContain(
      'src="https://sap.example.com/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main"',
    );
    expect(modelData.source_visible).toBe(true);
    expect(modelData.editor_visible).toBe(false);
    // the ADT button is offered here and nowhere else
    expect(modelData.isSourceView).toBe(true);
  });

  // This branch does not go through displayEditor, so the editor-only
  // controls have to be cleared here too - arriving from a view tab left
  // Apply / Reset on screen over a framed ABAP class.
  test("arriving from a view tab drops Apply and the templating toggle", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: "Z" } },
      views: { MAIN: fakeXmlView('<mvc:View xmlns:template="x"/>', { A: 1 }) },
      fragment: { byId: () => ({ setContent() {} }) },
      liveEdit: {
        apply: () => Promise.resolve("ok"),
        canApply: (tab) => tab === "VIEW",
        slotOfTab: () => "MAIN",
        isBusy: () => false,
      },
      extraSandbox: { fetch: async () => ({ ok: false }) },
    });
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onViewSelect(view.oEvent);
    expect(view.modelData.canApply).toBe(true);
    expect(view.modelData.isTemplating).toBe(true);

    DeveloperTools.renderTab("SOURCE", view.oModel);
    expect(view.modelData.canApply).toBe(false);
    expect(view.modelData.isTemplating).toBe(false);
  });

  test("a missing HTML control does not take the selection down", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: "Z" } },
      fragment: { byId: () => undefined },
      extraSandbox: { fetch: async () => ({ ok: false }) },
    });
    const { oEvent, modelData } = fakeSelectEvent("SOURCE");
    DeveloperTools.onViewSelect(oEvent);
    expect(modelData.source_visible).toBe(true);
  });
});

test.describe("Open on error toggle", () => {
  test("forwards to the console capture, which owns the setting", () => {
    const calls = [];
    let on = false;
    const { DeveloperTools } = loadDeveloperTools({
      consoleCapture: {
        isAlertOnError: () => on,
        setAlertOnError: (value) => {
          calls.push(value);
          on = value;
        },
      },
    });
    const { model, data } = fakeModel();
    DeveloperTools.onToggleOpenOnError({
      getSource: () => ({ getPressed: () => true, getModel: () => model }),
    });
    expect(calls).toEqual([true]);
    expect(data.openOnError).toBe(true);
  });
});

test.describe("Pick control", () => {
  test("closes the dialog for the pick and reopens on the result", () => {
    let started = null;
    const shown = [];
    const { DeveloperTools } = loadDeveloperTools({
      picker: {
        start: (cb) => (started = cb),
        stop() {},
        lastReport: () => "",
      },
    });
    DeveloperTools.show = (tab) => shown.push(tab);
    DeveloperTools.oDialog = {
      isOpen: () => true,
      close() {},
      getModel: () => ({ getData: () => ({ selectedTab: "LOG" }) }),
    };
    DeveloperTools.onPickControl();
    started("a report");
    expect(shown).toEqual(["PICK"]);
  });

  test("a cancelled pick returns to the view the user came from", () => {
    let started = null;
    const shown = [];
    const { DeveloperTools } = loadDeveloperTools({
      picker: {
        start: (cb) => (started = cb),
        stop() {},
        lastReport: () => "",
      },
    });
    DeveloperTools.show = (tab) => shown.push(tab);
    DeveloperTools.oDialog = {
      isOpen: () => true,
      close() {},
      getModel: () => ({ getData: () => ({ selectedTab: "HISTORY" }) }),
    };
    DeveloperTools.onPickControl();
    started(null);
    expect(shown).toEqual(["HISTORY"]);
  });
});

test.describe("Help", () => {
  test("opens the inspector's help in a dialog of its own", () => {
    const opened = [];
    const { DeveloperTools } = loadDeveloperTools({
      inspect: {
        formatHelp: () => "HELP TEXT",
        formatOverview: () => "",
        formatError: () => "",
        formatEnvironment: () => "",
        formatRegistry: () => "",
        formatActions: () => "",
        formatLog: () => "",
        formatBindings: () => "",
        findEventLine: () => 0,
      },
      extraSandbox: {
        sap: {
          ui: {
            require: (_names, cb) =>
              cb(
                class {
                  constructor(settings) {
                    opened.push(settings);
                  }
                  open() {}
                },
                class {
                  setValue(v) {
                    opened.push(v);
                  }
                },
                class {},
              ),
          },
        },
      },
    });
    DeveloperTools.onShowHelp();
    expect(opened).toContain("HELP TEXT");
  });
});

test.describe("Close / Escape returns to the error popup", () => {
  // The dialog is loaded once and reused across open/close (destroying and
  // re-loading its fragment each time raced the close animation on UI5 1.71
  // and threw "duplicate id ...developerToolsEditor"), so close() only closes
  // the still-open dialog and keeps the instance; exit() destroys it.
  const openDialog = () => {
    let closed = false;
    return {
      isOpen: () => !closed,
      close() {
        closed = true;
      },
      destroy() {},
    };
  };

  test("closing after Details re-shows the error popup", () => {
    const reopenCalls = [];
    const { DeveloperTools } = loadDeveloperTools({ reopenCalls });
    const oDialog = openDialog();
    DeveloperTools.oDialog = oDialog;
    DeveloperTools.reopenErrorOnClose = true;
    DeveloperTools.close();
    expect(reopenCalls).toEqual([true]);
    // Reused, not destroyed: the instance stays for the next show().
    expect(DeveloperTools.oDialog).toBe(oDialog);
    expect(oDialog.isOpen()).toBe(false);
  });

  test("a normal close does not re-show the error popup", () => {
    const reopenCalls = [];
    const { DeveloperTools } = loadDeveloperTools({ reopenCalls });
    DeveloperTools.oDialog = openDialog();
    DeveloperTools.close();
    expect(reopenCalls).toEqual([]);
  });

  test("close on an already-closed dialog is a no-op", () => {
    const reopenCalls = [];
    const { DeveloperTools } = loadDeveloperTools({ reopenCalls });
    const oDialog = openDialog();
    oDialog.close(); // already closed
    DeveloperTools.oDialog = oDialog;
    DeveloperTools.reopenErrorOnClose = true;
    DeveloperTools.close();
    expect(reopenCalls).toEqual([]);
  });

  test("Escape rejects the default close and behaves like Close", () => {
    const reopenCalls = [];
    const { DeveloperTools } = loadDeveloperTools({ reopenCalls });
    DeveloperTools.oDialog = openDialog();
    DeveloperTools.reopenErrorOnClose = true;
    let rejected = false;
    DeveloperTools.onEscape({ reject: () => (rejected = true), resolve() {} });
    expect(rejected).toBe(true);
    expect(reopenCalls).toEqual([true]);
  });

  test("exit() closes and destroys the reused dialog", () => {
    const reopenCalls = [];
    const { DeveloperTools } = loadDeveloperTools({ reopenCalls });
    let destroyed = false;
    const oDialog = openDialog();
    oDialog.destroy = () => (destroyed = true);
    DeveloperTools.oDialog = oDialog;
    // A pending reopen must not fire while the app itself is torn down.
    DeveloperTools.reopenErrorOnClose = true;
    DeveloperTools.exit();
    expect(destroyed).toBe(true);
    expect(DeveloperTools.oDialog).toBe(null);
    expect(reopenCalls).toEqual([]);
  });
});

test.describe("show()", () => {
  const openTools = async ({
    storage = {},
    initialTab,
    responseData = { S_FRONT: {} },
    errors,
    lastError,
    views,
  } = {}) => {
    const models = [];
    const { DeveloperTools } = loadDeveloperTools({
      storage,
      responseData,
      errors,
      lastError,
      views,
      fragment: {
        load: async () => ({ setModel: (m) => models.push(m), open() {} }),
        byId: () => ({ setContent() {} }),
      },
      extraDeps: {
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          logError() {},
          copyToClipboard() {},
        },
        "sap/ui/model/json/JSONModel": class {
          constructor(data) {
            this.data = data;
          }
          getData() {
            return this.data;
          }
          refresh() {}
        },
      },
      extraSandbox: {
        sap: { ui: { require: (_mods, resolve) => resolve() } },
        fetch: async () => ({ ok: false }),
      },
    });
    await DeveloperTools.show(initialTab);
    return { data: models[0]?.getData(), storage, DeveloperTools };
  };

  test("seeds the app class name into the dialog title", async () => {
    // The fragment binds the title to a plain /title property - never an
    // expression binding, which is compiled with eval (AGENTS.md rule 13).
    const { data } = await openTools({
      responseData: { S_FRONT: { APP: "Z2UI5_CL_MY_APP" } },
    });
    expect(data.title).toBe("abap2UI5 - Developer Tools - Z2UI5_CL_MY_APP");
  });

  test("leaves the title generic before the first response", async () => {
    const { data } = await openTools();
    expect(data.title).toBe("abap2UI5 - Developer Tools");
  });

  test("lands on the Overview rather than on raw response JSON", async () => {
    const { data } = await openTools();
    expect(data.selectedTab).toBe("OVERVIEW");
    expect(data.selectedGroup).toBe("OVERVIEW");
  });

  test("badges the Problems tab with the error count", async () => {
    const { data } = await openTools({
      errors: [{ message: "boom", ts: "2026-01-01T00:00:00.000Z" }],
      lastError: { title: "x", text: "y" },
    });
    expect(data.problemCount).toBe("2");
  });

  test("and shows no badge when nothing failed", async () => {
    // IconTabFilter renders a "0" otherwise, which reads as a problem
    expect((await openTools()).data.problemCount).toBe("");
  });

  test("the badge is refreshed per selection, not frozen at open", () => {
    // a timer or a late rejection can log while the dialog stands open
    const errors = [];
    const { DeveloperTools } = loadDeveloperTools({ errors });
    const { model, data } = fakeModel();
    DeveloperTools.renderTab("LOG", model);
    expect(data.problemCount).toBe("");
    errors.push({ message: "boom", ts: "2026-01-01T00:00:00.000Z" });
    DeveloperTools.renderTab("LOG", model);
    expect(data.problemCount).toBe("1");
  });

  test("a caller-named view wins over the remembered one", async () => {
    // the error popup's Details action jumps to ERROR regardless
    const { data } = await openTools({
      storage: { "z2ui5.devtools.lastTab": "HISTORY" },
      initialTab: "ERROR",
      lastError: { title: "x", text: "y" },
    });
    expect(data.selectedTab).toBe("ERROR");
  });
});

test.describe("Reopening where the developer left off", () => {
  // Landing on the same place after every close means re-navigating on
  // every open; the tools are meant to be lived in during a session.
  const openOn = async (lastTab, extra = {}) => {
    const models = [];
    const storage = lastTab ? { "z2ui5.devtools.lastTab": lastTab } : {};
    const { DeveloperTools } = loadDeveloperTools({
      storage,
      responseData: { S_FRONT: {} },
      fragment: {
        load: async () => ({ setModel: (m) => models.push(m), open() {} }),
        byId: () => ({ setContent() {} }),
      },
      extraDeps: {
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          logError() {},
          copyToClipboard() {},
        },
        "sap/ui/model/json/JSONModel": class {
          constructor(data) {
            this.data = data;
          }
          getData() {
            return this.data;
          }
          refresh() {}
        },
      },
      extraSandbox: {
        sap: { ui: { require: (_mods, resolve) => resolve() } },
        fetch: async () => ({ ok: false }),
      },
      ...extra,
    });
    await DeveloperTools.show();
    return { data: models[0]?.getData(), storage };
  };

  test("remembers the view the user selected", () => {
    const { DeveloperTools, storage } = loadDeveloperTools();
    const { oEvent } = fakeSelectEvent("REGISTRY");
    DeveloperTools.onViewSelect(oEvent);
    expect(storage["z2ui5.devtools.lastTab"]).toBe("REGISTRY");
  });

  // The whole pre-regrouping key space still resolves: these are stored
  // in sessionStorage and accepted from "?z2ui5-devtools=<KEY>".
  for (const tab of [
    "HISTORY",
    "DIFF",
    "VIEWDIFF",
    "LOG",
    "ACTIONS",
    "REGISTRY",
    "ENV",
    "REQUEST",
    "PLAIN",
    "PICK",
    "SOURCE",
  ]) {
    test(`reopens on ${tab}`, async () => {
      expect((await openOn(tab)).data.selectedTab).toBe(tab);
    });
  }

  test("a view whose slot has since gone falls back within its group", async () => {
    // POPUP was remembered, but the popup closed while the tools were shut
    const { data } = await openOn("POPUP", {
      views: { MAIN: fakeXmlView("<mvc:View/>", { A: 1 }) },
    });
    expect(data.selectedGroup).toBe("VIEWDATA");
    expect(data.selectedTab).toBe("VIEW");
  });

  test("ignores a remembered view that no longer exists", async () => {
    // e.g. "HELP", stored before that tab was removed - selecting it
    // would leave the header with nothing selected
    expect((await openOn("HELP")).data.selectedTab).toBe("OVERVIEW");
  });

  test("reopens on the Search tab - the key resolves again", async () => {
    // SEARCH was a tab, then a sub-header field, and is a tab again; a
    // remembered SEARCH lands there (with the term reset per open).
    expect((await openOn("SEARCH")).data.selectedTab).toBe("SEARCH");
  });

  test("opening also records it, so a close/open pair stays put", async () => {
    const { storage } = await openOn("REGISTRY");
    expect(storage["z2ui5.devtools.lastTab"]).toBe("REGISTRY");
  });
});
