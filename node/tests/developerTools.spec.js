// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/core/DeveloperTools.js
// (loaded via a stubbed sap.ui.define) instead of a local copy that could
// drift. The browser XML APIs used at module scope are stubbed minimally;
// prettifyXml degrades to the identity function with these stubs, which is
// exactly its documented fallback behavior.

// Mimics the relevant shape of a real sap.ui.core.mvc.XMLView: the raw XML
// string is kept as a pseudo property in mProperties, but is NOT declared
// in the control metadata - getProperty("viewContent") throws. Regression
// guard: the developer tools must never call getProperty for it (#2318 switched
// to getProperty and broke the View tab).
function fakeXmlView(viewContent) {
  return {
    mProperties: viewContent === undefined ? {} : { viewContent },
    getProperty(name) {
      throw new Error(`Property "${name}" does not exist in Element`);
    },
    getModel: () => undefined,
  };
}

function loadDeveloperTools({
  views = {},
  slotXml = {},
  oResponse = null,
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
} = {}) {
  const AppState = {
    state: { oResponse, responseData, oBody, errors, lastError },
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
  // The roundtrip recorder owns the History / Model Diff tabs; the dialog
  // only renders the text it returns. Its own behaviour is covered by
  // devtoolsRecorder.spec.js, so a flat stub is enough here.
  const Recorder = recorder || {
    isRecordingPayloads: () => false,
    setRecordingPayloads() {},
    formatHistory: () => "(no roundtrip recorded yet)",
    formatModelDiff: () => "(diff needs payload recording)",
    formatViewDiff: () => "(view diff needs payload recording)",
    exportJson: () => "{}",
  };
  // The inspectors, the control picker and the live view editing each own
  // their behaviour (and their own specs); the dialog only routes to them.
  const Inspect = inspect || {
    formatHelp: () => "(help)",
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
  const Picker = picker || { start() {}, stop() {} };
  const LiveEdit = liveEdit || {
    apply: () => Promise.resolve("applied"),
    canApply: () => false,
    slotOfTab: () => undefined,
    originalXml: () => "",
    isBusy: () => false,
  };
  // Control.extend returns the class spec itself; the spec's methods are
  // then invoked with the spec as `this`, close enough to the UI5 runtime
  // for these prototype methods.
  const Control = { extend: (_name, spec) => spec };
  const { module } = loadModule("core/devtools/DeveloperTools.js", {
    deps: {
      "sap/ui/core/Control": Control,
      "sap/ui/core/Fragment": fragment,
      // Default Lib stub: the async paths (Apply, Pick, show) guard their
      // continuations with Lib.isDestroyed. The show() tests override it
      // via extraDeps, which is spread after this.
      "z2ui5/core/Lib": { isDestroyed: () => false, logError() {} },
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": AppState,
      "z2ui5/core/ErrorView": ErrorView,
      "z2ui5/core/devtools/Console": Console,
      "z2ui5/core/devtools/Recorder": Recorder,
      "z2ui5/core/devtools/Inspect": Inspect,
      "z2ui5/core/devtools/Picker": Picker,
      "z2ui5/core/devtools/LiveEdit": LiveEdit,
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
      },
      ...extraSandbox,
    },
  });
  return { DeveloperTools: module };
}

// Fake IconTabHeader select event carrying the dialog's JSON model.
function fakeSelectEvent(selectedKey) {
  const modelData = {};
  const oEvent = {
    getSource: () => ({
      getSelectedKey: () => selectedKey,
      getModel: () => ({
        getData: () => modelData,
        refresh() {},
      }),
    }),
  };
  return { oEvent, modelData };
}

test.describe("View tab", () => {
  test("shows the XML kept in the view's mProperties", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView("<mvc:View/>") },
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("<mvc:View/>");
    expect(modelData.type).toBe("xml");
    expect(modelData.editor_visible).toBe(true);
  });

  test("falls back to the XML the slot was filled with", () => {
    // A view built from a `definition` keeps no viewContent - ViewSlots
    // recorded the source when it filled the slot.
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView(undefined) },
      slotXml: { MAIN: "<Page/>" },
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("<Page/>");
    expect(modelData.type).toBe("xml");
  });
});

test.describe("popup / popover tabs", () => {
  // Regression guard: the tabs used to be derived from the last response's
  // ["VIEW_SLOTS","display","POPUP",...] action. A frontend close
  // (cs_event-popup_close) does no roundtrip, so that response stayed the
  // current one and the developer tools kept showing a popup that was long
  // destroyed. They read the slot itself now, so both close paths - the
  // backend's destroy action and the roundtrip-free one - look the same.
  test("show the fragment XML while the slot is filled", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { POPUP: fakeXmlView(undefined) },
      slotXml: { POPUP: "<Dialog/>" },
    });
    const { oEvent, modelData } = fakeSelectEvent("POPUP");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("<Dialog/>");
    expect(modelData.type).toBe("xml");
  });

  test("are empty once the slot was torn down without a roundtrip", () => {
    // ViewSlots.destroy cleared both the live view and the recorded XML,
    // while oResponse still carries the display action that opened it
    const { DeveloperTools } = loadDeveloperTools({
      views: {},
      slotXml: {},
      oResponse: {
        S_ACTION: {
          T_SYSTEM: [
            ["CONTROL_GLOBAL", "VIEW_SLOTS", "display", "POPUP", "<Dialog/>"],
          ],
        },
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("POPUP");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("");
    const exported = DeveloperTools.buildExport("");
    expect(exported).not.toContain("POPUP");
  });
});

test.describe("Error tab", () => {
  test("shows the captured fatal error title + text and the action bar", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: {
        title: "App Terminated",
        text: "backend dump...",
        onRetry: () => {},
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("App Terminated\n\nbackend dump...");
    expect(modelData.type).toBe("text");
    expect(modelData.hasRetry).toBe(true);
  });

  test("hides Retry when the fatal error carried no retry action", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "", text: "client crash", onRetry: null },
    });
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("client crash");
    expect(modelData.hasRetry).toBe(false);
  });

  test("placeholder when no fatal error was captured", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("(no fatal error captured this session)");
    expect(modelData.type).toBe("text");
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

  test("renderTab('ERROR') opens the tab directly (show initial tab path)", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "App Terminated", text: "boom", onRetry: () => {} },
    });
    const modelData = {};
    const oModel = { getData: () => modelData, refresh() {} };
    DeveloperTools.renderTab("ERROR", oModel);
    expect(modelData.value).toBe("App Terminated\n\nboom");
    expect(modelData.hasRetry).toBe(true);
  });
});

test.describe("Export", () => {
  test("buildExport concatenates the available (non-empty) sections", () => {
    const { DeveloperTools } = loadDeveloperTools({
      lastError: { title: "App Terminated", text: "backend dump", onRetry: null },
      errors: [{ message: "boom", ts: "2026-01-01T00:00:00.000Z" }],
    });
    const out = DeveloperTools.buildExport();
    expect(out).toContain("===== ERROR =====");
    expect(out).toContain("App Terminated");
    expect(out).toContain("backend dump");
    // the LOG section now carries the merged timeline the inspector
    // renders; its content is covered by devtoolsInspect.spec.js
    expect(out).toContain("===== LOG =====");
  });

  test("omits the ERROR section when no fatal error was captured", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const out = DeveloperTools.buildExport();
    expect(out).not.toContain("===== ERROR =====");
    expect(out).toContain("===== LOG =====");
  });

  test("includes the ABAP SOURCE section when a class source is passed", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const out = DeveloperTools.buildExport("CLASS zcl_demo DEFINITION.");
    expect(out).toContain("===== ABAP SOURCE =====");
    expect(out).toContain("CLASS zcl_demo DEFINITION.");
  });

  test("omits the ABAP SOURCE section when the source could not be fetched", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const out = DeveloperTools.buildExport("");
    expect(out).not.toContain("===== ABAP SOURCE =====");
  });
});

test.describe("Recorder tabs", () => {
  test("the History tab renders what the recorder hands over", () => {
    const { DeveloperTools } = loadDeveloperTools({
      recorder: {
        isRecordingPayloads: () => false,
        setRecordingPayloads() {},
        formatHistory: () => "ROUNDTRIP TABLE",
        formatModelDiff: () => "",
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("HISTORY");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("ROUNDTRIP TABLE");
    expect(modelData.type).toBe("text");
    expect(modelData.editor_visible).toBe(true);
  });

  test("the Model Diff tab renders what the recorder hands over", () => {
    const { DeveloperTools } = loadDeveloperTools({
      recorder: {
        isRecordingPayloads: () => true,
        setRecordingPayloads() {},
        formatHistory: () => "",
        formatModelDiff: () => "~ /NAME",
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("DIFF");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("~ /NAME");
    expect(modelData.type).toBe("text");
  });

  test("the export carries the roundtrip history", () => {
    const { DeveloperTools } = loadDeveloperTools({
      recorder: {
        isRecordingPayloads: () => false,
        setRecordingPayloads() {},
        formatHistory: () => "ROUNDTRIP TABLE",
        formatModelDiff: () => "",
      },
    });
    const out = DeveloperTools.buildExport("");
    expect(out).toContain("===== ROUNDTRIP HISTORY =====");
    expect(out).toContain("ROUNDTRIP TABLE");
    // the diff only travels when payloads were actually recorded
    expect(out).not.toContain("===== MODEL DIFF =====");
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
        formatHistory: () => (recording ? "ON" : "OFF"),
        formatModelDiff: () => "",
      },
    });
    const modelData = { selectedTab: "HISTORY" };
    const oModel = { getData: () => modelData, refresh() {} };
    DeveloperTools.onToggleRecordPayloads({
      getSource: () => ({ getPressed: () => true, getModel: () => oModel }),
    });
    expect(calls).toEqual([true]);
    expect(modelData.recordPayloads).toBe(true);
    // the open tab reports the flag, so it is re-rendered after the switch
    expect(modelData.value).toBe("ON");
  });
});

test.describe("Inspector tabs", () => {
  const inspect = {
    formatHelp: () => "HELP REPORT",
    formatEnvironment: () => "ENV REPORT",
    formatRegistry: () => "REGISTRY REPORT",
    formatActions: () => "ACTIONS REPORT",
    formatLog: () => "LOG REPORT",
    formatBindings: () => "BINDINGS REPORT",
    findEventLine: () => 0,
  };

  for (const [key, expected] of [
    ["HELP", "HELP REPORT"],
    ["ENV", "ENV REPORT"],
    ["REGISTRY", "REGISTRY REPORT"],
    ["ACTIONS", "ACTIONS REPORT"],
    ["LOG", "LOG REPORT"],
    ["BINDINGS", "BINDINGS REPORT"],
  ]) {
    test(`the ${key} tab renders its inspector`, () => {
      const { DeveloperTools } = loadDeveloperTools({ inspect });
      const { oEvent, modelData } = fakeSelectEvent(key);
      DeveloperTools.onItemSelect(oEvent);
      expect(modelData.value).toBe(expected);
      expect(modelData.type).toBe("text");
    });
  }

  test("the picked-control tab explains itself before the first pick", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("PICK");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toContain("No control picked yet");
  });
});

test.describe("Live view editing", () => {
  test("a view tab offers Apply, other tabs do not", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView("<mvc:View/>") },
      liveEdit: {
        apply: () => Promise.resolve("ok"),
        canApply: (tab) => tab === "VIEW",
        slotOfTab: () => "MAIN",
        originalXml: () => "<mvc:View/>",
        isBusy: () => false,
      },
    });
    const view = fakeSelectEvent("VIEW");
    DeveloperTools.onItemSelect(view.oEvent);
    expect(view.modelData.canApply).toBe(true);

    const log = fakeSelectEvent("LOG");
    DeveloperTools.onItemSelect(log.oEvent);
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
        originalXml: () => "",
        isBusy: () => false,
      },
    });
    const modelData = { selectedTab: "VIEW", value: "<mvc:View edited=\"1\"/>" };
    const oModel = { getData: () => modelData, refresh() {} };
    await DeveloperTools.onApplyXml({ getSource: () => ({ getModel: () => oModel }) });
    expect(applied).toEqual([
      { tab: "VIEW", xml: '<mvc:View edited="1"/>' },
    ]);
    expect(modelData.applyResult).toContain("Applied to slot MAIN");
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
        originalXml: () => "",
        isBusy: () => true,
      },
    });
    const modelData = { selectedTab: "VIEW", value: "<x/>" };
    const oModel = { getData: () => modelData, refresh() {} };
    await DeveloperTools.onApplyXml({ getSource: () => ({ getModel: () => oModel }) });
    expect(applied.length).toBe(0);
    expect(modelData.applyResult).toContain("roundtrip is running");
  });

  test("Reset puts the backend's original XML back", () => {
    const { DeveloperTools } = loadDeveloperTools({
      liveEdit: {
        apply: () => Promise.resolve("ok"),
        canApply: () => true,
        slotOfTab: () => "MAIN",
        originalXml: () => "<mvc:View original=\"1\"/>",
        isBusy: () => false,
      },
    });
    const modelData = { selectedTab: "VIEW", value: "<edited/>", applyResult: "x" };
    const oModel = { getData: () => modelData, refresh() {} };
    DeveloperTools.onResetXml({ getSource: () => ({ getModel: () => oModel }) });
    expect(modelData.value).toBe('<mvc:View original="1"/>');
    expect(modelData.applyResult).toBe("");
  });
});

test.describe("Copy Tab", () => {
  test("copies the current tab's content and confirms on the button", () => {
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
    let label = "Copy Tab";
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

  test("an empty tab copies an empty string rather than undefined", () => {
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
        getText: () => "Copy Tab",
        setText() {},
      }),
    });
    expect(copied).toEqual([""]);
  });
});

test.describe("ADT deep link", () => {
  const appResponse = { S_FRONT: { APP: "ZCL_DEMO" } };

  test("plain class url without a cached source", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: appResponse,
    });
    DeveloperTools._abapSourceCache = null;
    expect(DeveloperTools.getAbapAdtUrl()).toBe(
      "https://sap.example.com/sap/bc/adt/oo/classes/ZCL_DEMO/source/main",
    );
  });

  // The inspector resolves the line; the dialog only has to turn it into
  // the anchor the ADT source endpoint understands.
  const inspectAtLine = (lineNumber) => ({
    formatEnvironment: () => "",
    formatRegistry: () => "",
    formatActions: () => "",
    formatLog: () => "",
    formatBindings: () => "",
    findEventLine: () => lineNumber,
  });

  test("deep links at the event's line once the source is cached", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: appResponse,
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      inspect: inspectAtLine(17),
    });
    DeveloperTools._abapSourceCache = { app: "ZCL_DEMO", source: "..." };
    expect(DeveloperTools.getAbapAdtUrl()).toBe(
      "https://sap.example.com/sap/bc/adt/oo/classes/ZCL_DEMO/source/main" +
        "#start=17,1",
    );
  });

  test("stays on the plain url when the event name is not found", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: appResponse,
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      inspect: inspectAtLine(0),
    });
    DeveloperTools._abapSourceCache = { app: "ZCL_DEMO", source: "..." };
    expect(DeveloperTools.getAbapAdtUrl()).not.toContain("#start=");
  });

  test("ignores a source cached for a different app class", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: appResponse,
      oBody: { S_FRONT: { EVENT: "SAVE" } },
      inspect: inspectAtLine(17),
    });
    DeveloperTools._abapSourceCache = { app: "ZCL_OTHER", source: "..." };
    expect(DeveloperTools.getAbapAdtUrl()).not.toContain("#start=");
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

test.describe("Dialog title names the running app", () => {
  const APP = "Z2UI5_CL_MY_APP";

  // The fragment binds the title to /appName, so show() must seed it - the
  // tools are opened over whatever app is running, and every tab shows that
  // app's data.
  const openTools = async (responseData) => {
    const models = [];
    const { DeveloperTools } = loadDeveloperTools({
      responseData,
      fragment: { load: async () => ({ setModel: (m) => models.push(m), open() {} }) },
      extraDeps: {
        "z2ui5/core/Lib": { isDestroyed: () => false, logError() {} },
        "sap/ui/model/json/JSONModel": class {
          constructor(data) {
            this.data = data;
          }
          getData() {
            return this.data;
          }
        },
      },
      extraSandbox: { sap: { ui: { require: (_mods, resolve) => resolve() } } },
    });
    await DeveloperTools.show();
    return models[0]?.getData();
  };

  test("show() seeds the app class name into the model", async () => {
    expect((await openTools({ S_FRONT: { APP: APP } })).appName).toBe(APP);
  });

  test("show() leaves it empty before the first response", async () => {
    expect((await openTools({ S_FRONT: {} })).appName).toBe("");
  });
});

test.describe("Source Code tab / ADT jump", () => {
  const APP = "Z2UI5_CL_MY_APP";
  const EXPECTED_URL =
    "https://sap.example.com/sap/bc/adt/oo/classes/Z2UI5_CL_MY_APP/source/main";

  test("getAbapSourceUrl builds the ADT source endpoint for the running app", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: APP } },
    });
    expect(DeveloperTools.getAbapSourceUrl()).toBe(EXPECTED_URL);
  });

  test("getAbapSourceUrl is empty when the app class name is unknown", () => {
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: {} },
    });
    expect(DeveloperTools.getAbapSourceUrl()).toBe("");
  });

  test("onOpenAbapInAdt opens the source top-level in a new tab", () => {
    const opened = [];
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: APP } },
      windowStub: {
        location: { origin: "https://sap.example.com" },
        open: (url, target, features) => opened.push({ url, target, features }),
      },
    });
    DeveloperTools.onOpenAbapInAdt();
    expect(opened).toEqual([
      {
        url: EXPECTED_URL,
        target: "_blank",
        features: "noopener,noreferrer",
      },
    ]);
  });

  test("onOpenAbapInAdt does nothing when the app class name is unknown", () => {
    const opened = [];
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: {} },
      windowStub: {
        location: { origin: "https://sap.example.com" },
        open: (url) => opened.push(url),
      },
    });
    DeveloperTools.onOpenAbapInAdt();
    expect(opened).toEqual([]);
  });

  test("showAbapSource frames the source for the inline preview", () => {
    let content = null;
    const fragment = {
      byId: () => ({
        setContent: (html) => (content = html),
      }),
    };
    const { DeveloperTools } = loadDeveloperTools({
      responseData: { S_FRONT: { APP: APP } },
      fragment,
    });
    const modelData = {};
    DeveloperTools.showAbapSource({ getData: () => modelData, refresh() {} });
    expect(content).toContain(`src="${EXPECTED_URL}"`);
    expect(modelData.source_visible).toBe(true);
    expect(modelData.editor_visible).toBe(false);
  });
});

test.describe("Nest tabs", () => {
  test("show the nested view's XML without touching getProperty", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { NEST: fakeXmlView("<core:View/>") },
    });
    const { oEvent, modelData } = fakeSelectEvent("NEST1");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("<core:View/>");
    expect(modelData.type).toBe("xml");
  });
});

test.describe("Search across all tabs", () => {
  const searchable = () =>
    loadDeveloperTools({
      views: { MAIN: fakeXmlView('<Input value="{/CUSTOMER}"/>') },
      responseData: { S_FRONT: { ID: "x" }, MODEL: { CUSTOMER: "Miller AG" } },
      inspect: {
        formatHelp: () => "(help)",
        formatEnvironment: () => "(environment)",
        formatRegistry: () => "(registry)",
        formatActions: () => "(actions)",
        formatLog: () => "(log)",
        formatBindings: () => "/CUSTOMER  string  Miller AG",
        findEventLine: () => 0,
      },
    });

  test("reports every tab that contains the term", () => {
    const { DeveloperTools } = searchable();
    const out = DeveloperTools.searchAllTabs("CUSTOMER");
    expect(out).toContain("[VIEW]");
    expect(out).toContain("[BINDINGS]");
    expect(out).toContain("hit(s)");
  });

  test("is case-insensitive and shows the line number", () => {
    const { DeveloperTools } = searchable();
    const out = DeveloperTools.searchAllTabs("customer");
    expect(out).toContain("[VIEW]");
    expect(out).toMatch(/\d+: /);
  });

  test("says so when nothing matches", () => {
    const { DeveloperTools } = searchable();
    expect(DeveloperTools.searchAllTabs("zzz-nothing")).toContain("no hit");
  });

  test("an empty term asks for one instead of listing everything", () => {
    const { DeveloperTools } = searchable();
    expect(DeveloperTools.searchAllTabs("")).toContain("enter a search term");
  });

  test("a throwing source does not blank the whole result", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView("<Input value='{/NEEDLE}'/>") },
      inspect: {
        formatHelp: () => "(help)",
        formatEnvironment: () => {
          throw new Error("inspector broke");
        },
        formatRegistry: () => "(registry)",
        formatActions: () => "(actions)",
        formatLog: () => "(log)",
        formatBindings: () => "(bindings)",
        findEventLine: () => 0,
      },
    });
    const out = DeveloperTools.searchAllTabs("NEEDLE");
    expect(out).toContain("[VIEW]");
  });

  test("onSearch renders the result and selects the Search tab", () => {
    const { DeveloperTools } = searchable();
    const modelData = {};
    const oModel = { getData: () => modelData, refresh() {} };
    DeveloperTools.onSearch({
      getSource: () => ({ getValue: () => "CUSTOMER", getModel: () => oModel }),
    });
    expect(modelData.selectedTab).toBe("SEARCH");
    expect(modelData.searchTerm).toBe("CUSTOMER");
    expect(modelData.value).toContain("[VIEW]");
  });
});

test.describe("Markdown export", () => {
  test("wraps each section in a collapsed details block", () => {
    const { DeveloperTools } = loadDeveloperTools({
      errors: [{ message: "boom", ts: "2026-01-01T00:00:00.000Z" }],
    });
    const md = DeveloperTools.buildMarkdown("");
    expect(md).toContain("## abap2UI5 - Developer Tools export");
    expect(md).toContain("<summary>LOG</summary>");
    expect(md).toContain("```text");
    expect(md).toContain("</details>");
  });

  test("leaves the environment section open - it is read first", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const md = DeveloperTools.buildMarkdown("");
    expect(md).toContain("<details open>");
    expect(md).toContain("<summary>ENVIRONMENT</summary>");
  });

  test("fences the ABAP source as abap", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const md = DeveloperTools.buildMarkdown("CLASS zcl_demo DEFINITION.");
    expect(md).toContain("<summary>ABAP SOURCE</summary>");
    expect(md).toContain("```abap");
  });
});

test.describe("Open on error toggle", () => {
  test("forwards to the console capture, which owns the setting", () => {
    const calls = [];
    let on = false;
    const { DeveloperTools } = loadDeveloperTools({
      consoleCapture: {
        format: () => "(console)",
        isAlertOnError: () => on,
        setAlertOnError: (value) => {
          calls.push(value);
          on = value;
        },
      },
    });
    const modelData = {};
    const oModel = { getData: () => modelData, refresh() {} };
    DeveloperTools.onToggleOpenOnError({
      getSource: () => ({ getPressed: () => true, getModel: () => oModel }),
    });
    expect(calls).toEqual([true]);
    expect(modelData.openOnError).toBe(true);
  });
});
