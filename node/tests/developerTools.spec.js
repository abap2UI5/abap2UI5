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
  oResponse = null,
  responseData = null,
  errors,
  lastError = null,
  logoutCalls,
  reopenCalls,
  fragment,
  windowStub,
} = {}) {
  const AppState = {
    state: { oResponse, responseData, oBody: null, errors, lastError },
    getGlobal: () => undefined,
  };
  const ViewSlots = { getView: (key) => views[key] };
  const ErrorView = {
    handleLogout: () => logoutCalls?.push(true),
    reopenErrorDialog: () => reopenCalls?.push(true),
  };
  // Control.extend returns the class spec itself; the spec's methods are
  // then invoked with the spec as `this`, close enough to the UI5 runtime
  // for these prototype methods.
  const Control = { extend: (_name, spec) => spec };
  const { module } = loadModule("core/DeveloperTools.js", {
    deps: {
      "sap/ui/core/Control": Control,
      "sap/ui/core/Fragment": fragment,
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": AppState,
      "z2ui5/core/ErrorView": ErrorView,
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
      window: windowStub || {
        location: { origin: "https://sap.example.com" },
        open() {},
      },
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

  test("falls back to the last response XML when the view keeps none", () => {
    const { DeveloperTools } = loadDeveloperTools({
      views: { MAIN: fakeXmlView(undefined) },
      oResponse: { PARAMS: { S_VIEW: { XML: "<Page/>" } } },
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("<Page/>");
    expect(modelData.type).toBe("xml");
  });
});

test.describe("Log tab", () => {
  test("dumps the error log as minimal ts + message lines", () => {
    const { DeveloperTools } = loadDeveloperTools({
      errors: [
        { message: "boom", ts: "2026-01-01T00:00:00.000Z" },
        { message: "bang", ts: "2026-01-01T00:00:01.000Z" },
      ],
    });
    const { oEvent, modelData } = fakeSelectEvent("LOG");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe(
      "2026-01-01T00:00:00.000Z  boom\n2026-01-01T00:00:01.000Z  bang",
    );
    expect(modelData.type).toBe("text");
    expect(modelData.editor_visible).toBe(true);
  });

  test("shows a placeholder when the log is empty", () => {
    const { DeveloperTools } = loadDeveloperTools();
    const { oEvent, modelData } = fakeSelectEvent("LOG");
    DeveloperTools.onItemSelect(oEvent);
    expect(modelData.value).toBe("(log is empty)");
    expect(modelData.type).toBe("text");
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

test.describe("System tab folding", () => {
  // Drives foldSystemTab against a fake ACE edit session built from a table of
  // pretty-printed JSON rows ({ line, start, end }), recording which foldable
  // blocks get collapsed.
  function foldHarness(rows) {
    const foldedStarts = [];
    const session = {
      unfold() {},
      getLength: () => rows.length,
      getLine: (r) => rows[r].line,
      getFoldWidget: (r) => (rows[r].start ? "start" : ""),
      getFoldWidgetRange: (r) => ({
        start: { row: r },
        end: { row: rows[r].end },
        isMultiLine: () => rows[r].end > r,
      }),
      addFold: (_placeholder, range) => foldedStarts.push(range.start.row),
    };
    const editor = { getSession: () => session };
    const fragment = {
      byId: () => ({ getInternalEditorInstance: () => editor }),
    };
    return { fragment, foldedStarts };
  }

  test("folds level-2 blocks and deeper, leaving the first two levels open", () => {
    // {  "a": { "b": {...}, "d": 2 },  "e": [ {...} ]  } - 3-space indent.
    const rows = [
      { line: "{", start: true, end: 12 },
      { line: '   "a": {', start: true, end: 6 },
      { line: '      "b": {', start: true, end: 4 },
      { line: '         "c": 1', start: false },
      { line: "      },", start: false },
      { line: '      "d": 2', start: false },
      { line: "   },", start: false },
      { line: '   "e": [', start: true, end: 11 },
      { line: "      {", start: true, end: 10 },
      { line: '         "f": 3', start: false },
      { line: "      }", start: false },
      { line: "   ]", start: false },
      { line: "}", start: false },
    ];
    const { fragment, foldedStarts } = foldHarness(rows);
    const { DeveloperTools } = loadDeveloperTools({ fragment });
    DeveloperTools.foldSystemTab();
    // Root (level 0) and its direct children (level 1) stay open; the
    // level-2 object and the level-2 array entry are folded.
    expect(foldedStarts).toEqual([2, 8]);
  });

  test("is a no-op (no throw) when the editor instance does not exist yet", () => {
    const fragment = { byId: () => null };
    const { DeveloperTools } = loadDeveloperTools({ fragment });
    expect(() => DeveloperTools.foldSystemTab(0)).not.toThrow();
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
    expect(out).toContain("===== LOG =====");
    expect(out).toContain("2026-01-01T00:00:00.000Z  boom");
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
