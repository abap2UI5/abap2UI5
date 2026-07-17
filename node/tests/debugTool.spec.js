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

function loadDebugTool({ views = {}, oResponse = null, errors } = {}) {
  const AppState = {
    state: { oResponse, responseData: null, oBody: null, errors },
    getGlobal: () => undefined,
  };
  const ViewSlots = { getView: (key) => views[key] };
  // Control.extend returns the class spec itself; the spec's methods are
  // then invoked with the spec as `this`, close enough to the UI5 runtime
  // for these prototype methods.
  const Control = { extend: (_name, spec) => spec };
  const { module } = loadModule("core/DebugTool.js", {
    deps: {
      "sap/ui/core/Control": Control,
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": AppState,
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
