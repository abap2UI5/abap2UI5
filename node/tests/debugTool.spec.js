// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/core/DebugTool.js
// (loaded via a stubbed sap.ui.define) instead of a local copy that could
// drift. The browser XML APIs used at module scope are stubbed minimally;
// prettifyXml degrades to the identity function with these stubs, which is
// exactly its documented fallback behavior.

// Mimics the relevant shape of a real sap.ui.core.mvc.XMLView: the raw XML
// string is kept as a pseudo property in mProperties, but is NOT declared
// in the control metadata - getProperty("viewContent") throws. Regression
// guard: the debug tool must never call getProperty for it (#2318 switched
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

function loadDebugTool({
  views = {},
  oResponse = null,
  errors,
  lastError = null,
  logoutCalls,
  fragment,
} = {}) {
  const AppState = {
    state: { oResponse, responseData: null, oBody: null, errors, lastError },
    getGlobal: () => undefined,
  };
  const ViewSlots = { getView: (key) => views[key] };
  const ErrorView = {
    handleLogout: () => logoutCalls?.push(true),
  };
  // Control.extend returns the class spec itself; the spec's methods are
  // then invoked with the spec as `this`, close enough to the UI5 runtime
  // for these prototype methods.
  const Control = { extend: (_name, spec) => spec };
  const { module } = loadModule("core/DebugTool.js", {
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
    },
  });
  return { DebugTool: module };
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
    const { DebugTool } = loadDebugTool({
      views: { MAIN: fakeXmlView("<mvc:View/>") },
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("<mvc:View/>");
    expect(modelData.type).toBe("xml");
    expect(modelData.editor_visible).toBe(true);
  });

  test("falls back to the last response XML when the view keeps none", () => {
    const { DebugTool } = loadDebugTool({
      views: { MAIN: fakeXmlView(undefined) },
      oResponse: { PARAMS: { S_VIEW: { XML: "<Page/>" } } },
    });
    const { oEvent, modelData } = fakeSelectEvent("VIEW");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("<Page/>");
    expect(modelData.type).toBe("xml");
  });
});

test.describe("Log tab", () => {
  test("dumps the error log as minimal ts + message lines", () => {
    const { DebugTool } = loadDebugTool({
      errors: [
        { message: "boom", ts: "2026-01-01T00:00:00.000Z" },
        { message: "bang", ts: "2026-01-01T00:00:01.000Z" },
      ],
    });
    const { oEvent, modelData } = fakeSelectEvent("LOG");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe(
      "2026-01-01T00:00:00.000Z  boom\n2026-01-01T00:00:01.000Z  bang",
    );
    expect(modelData.type).toBe("text");
    expect(modelData.editor_visible).toBe(true);
  });

  test("shows a placeholder when the log is empty", () => {
    const { DebugTool } = loadDebugTool();
    const { oEvent, modelData } = fakeSelectEvent("LOG");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("(log is empty)");
    expect(modelData.type).toBe("text");
  });
});

test.describe("Error tab", () => {
  test("shows the captured fatal error title + text and the action bar", () => {
    const { DebugTool } = loadDebugTool({
      lastError: {
        title: "App Terminated",
        text: "backend dump...",
        onRetry: () => {},
      },
    });
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("App Terminated\n\nbackend dump...");
    expect(modelData.type).toBe("text");
    expect(modelData.hasRetry).toBe(true);
  });

  test("hides Retry when the fatal error carried no retry action", () => {
    const { DebugTool } = loadDebugTool({
      lastError: { title: "", text: "client crash", onRetry: null },
    });
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("client crash");
    expect(modelData.hasRetry).toBe(false);
  });

  test("placeholder when no fatal error was captured", () => {
    const { DebugTool } = loadDebugTool();
    const { oEvent, modelData } = fakeSelectEvent("ERROR");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("(no fatal error captured this session)");
    expect(modelData.type).toBe("text");
  });

  test("onErrorRetry runs the captured retry action", () => {
    let retried = 0;
    const { DebugTool } = loadDebugTool({
      lastError: { title: "x", text: "y", onRetry: () => (retried += 1) },
    });
    DebugTool.onErrorRetry();
    expect(retried).toBe(1);
  });

  test("onErrorLogout delegates to ErrorView.handleLogout", () => {
    const logoutCalls = [];
    const { DebugTool } = loadDebugTool({
      lastError: { title: "x", text: "y", onRetry: null },
      logoutCalls,
    });
    DebugTool.onErrorLogout();
    expect(logoutCalls).toEqual([true]);
  });

  test("renderTab('ERROR') opens the tab directly (show initial tab path)", () => {
    const { DebugTool } = loadDebugTool({
      lastError: { title: "App Terminated", text: "boom", onRetry: () => {} },
    });
    const modelData = {};
    const oModel = { getData: () => modelData, refresh() {} };
    DebugTool.renderTab("ERROR", oModel);
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
    const { DebugTool } = loadDebugTool({ fragment });
    DebugTool.foldSystemTab();
    // Root (level 0) and its direct children (level 1) stay open; the
    // level-2 object and the level-2 array entry are folded.
    expect(foldedStarts).toEqual([2, 8]);
  });

  test("is a no-op (no throw) when the editor instance does not exist yet", () => {
    const fragment = { byId: () => null };
    const { DebugTool } = loadDebugTool({ fragment });
    expect(() => DebugTool.foldSystemTab(0)).not.toThrow();
  });
});

test.describe("Nest tabs", () => {
  test("show the nested view's XML without touching getProperty", () => {
    const { DebugTool } = loadDebugTool({
      views: { NEST: fakeXmlView("<core:View/>") },
    });
    const { oEvent, modelData } = fakeSelectEvent("NEST1");
    DebugTool.onItemSelect(oEvent);
    expect(modelData.value).toBe("<core:View/>");
    expect(modelData.type).toBe("xml");
  });
});
