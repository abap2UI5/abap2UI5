// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/devtools/Report.js -
// the bug report the developer tools produce, assembled from the tab
// registry (loaded for real here, so the two are tested as they ship).
//
// The regression that motivated the rebuild: the export used to carry its
// own hand-written section list, in its own order, with its own titles -
// "ROUNDTRIP HISTORY", "PREVIOUS REQUEST" - none of which named a tab. Its
// own truncation hint then told the reader to "open the ROUNDTRIP HISTORY
// tab", which does not exist. Section titles now come from the registry.

function fakeXmlView(viewContent, data) {
  return {
    mProperties: viewContent === undefined ? {} : { viewContent },
    getProperty(name) {
      throw new Error(`Property "${name}" does not exist in Element`);
    },
    getModel: () => (data ? { getData: () => data } : undefined),
  };
}

function loadReport({
  views = {},
  slotXml = {},
  responseData = null,
  oBody = null,
  lastError = null,
  recording = false,
  copied = [],
  logged = [],
} = {}) {
  const { module } = loadModule("devtools/Report.js", {
    autoLoad: true,
    deps: {
      "z2ui5/core/Lib": {
        copyToClipboard: (text) => copied.push(text),
        logError: (message, e) => logged.push({ message, e }),
      },
      "z2ui5/core/AppState": {
        state: { responseData, oBody, lastError },
        getGlobal: () => undefined,
      },
      "z2ui5/core/ViewSlots": {
        getView: (key) => views[key],
        getViewXml: (key) => slotXml[key],
      },
      "z2ui5/devtools/Inspect": {
        formatOverview: () => "OVERVIEW REPORT",
        formatError: () =>
          lastError
            ? `${lastError.title}\n\n${lastError.text}`
            : "(no fatal error captured this session)",
        formatLog: () => "LOG REPORT",
        formatActions: () => "ACTIONS REPORT",
        formatRegistry: () => "REGISTRY REPORT",
        formatEnvironment: () => "ENV REPORT",
        formatBindings: () => "BINDINGS REPORT",
      },
      "z2ui5/devtools/Picker": { lastReport: () => "" },
      "z2ui5/devtools/Recorder": {
        isRecordingPayloads: () => recording,
        formatHistory: () => "ROUNDTRIP TABLE",
        formatModelDiff: () => "~ /NAME",
        formatViewDiff: () => "~ <Input/>",
        exportJson: () => "{}",
      },
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
      XSLTProcessor: class {
        importStylesheet() {}
        transformToDocument() {
          return null;
        }
      },
    },
  });
  return { Report: module, copied, logged };
}

test.describe("buildExport", () => {
  test("concatenates the available (non-empty) sections", () => {
    const { Report } = loadReport({
      lastError: { title: "App Terminated", text: "backend dump" },
    });
    const out = Report.buildExport();
    expect(out).toContain("===== ERROR =====");
    expect(out).toContain("App Terminated");
    expect(out).toContain("backend dump");
    expect(out).toContain("===== LOG =====");
  });

  test("omits the ERROR section when no fatal error was captured", () => {
    const { Report } = loadReport();
    const out = Report.buildExport();
    expect(out).not.toContain("===== ERROR =====");
    expect(out).toContain("===== LOG =====");
  });

  test("leads with the environment - it is what a reader needs first", () => {
    const { Report } = loadReport({
      lastError: { title: "x", text: "y" },
    });
    const out = Report.buildExport();
    expect(out.indexOf("===== ENVIRONMENT =====")).toBe(0);
    expect(out.indexOf("===== ENVIRONMENT =====")).toBeLessThan(
      out.indexOf("===== ERROR ====="),
    );
  });

  test("carries the roundtrip history under the name of its tab", () => {
    // Not "ROUNDTRIP HISTORY": the section title is the tab's, so the
    // truncation hint ("open the ... tab") points at something real.
    const { Report } = loadReport();
    const out = Report.buildExport("");
    expect(out).toContain("===== HISTORY =====");
    expect(out).toContain("ROUNDTRIP TABLE");
  });

  test("the diffs only travel when payloads were actually recorded", () => {
    expect(loadReport().Report.buildExport("")).not.toContain(
      "===== MODEL DIFF =====",
    );
    const on = loadReport({ recording: true }).Report.buildExport("");
    expect(on).toContain("===== MODEL DIFF =====");
    expect(on).toContain("~ /NAME");
  });

  test("includes the ABAP SOURCE section when a class source is passed", () => {
    const { Report } = loadReport();
    const out = Report.buildExport("CLASS zcl_demo DEFINITION.");
    expect(out).toContain("===== ABAP SOURCE =====");
    expect(out).toContain("CLASS zcl_demo DEFINITION.");
  });

  test("omits it when the source could not be fetched", () => {
    expect(loadReport().Report.buildExport("")).not.toContain(
      "===== ABAP SOURCE =====",
    );
  });

  test("a slot torn down without a roundtrip exports nothing for it", () => {
    // ViewSlots.destroy cleared both the live view and the recorded XML
    const { Report } = loadReport({ views: {}, slotXml: {} });
    expect(Report.buildExport("")).not.toContain("POPUP");
  });

  test("a filled popup exports its XML and its model", () => {
    const { Report } = loadReport({
      views: { POPUP: fakeXmlView("<Dialog/>", { PNAME: "y" }) },
    });
    const out = Report.buildExport("");
    expect(out).toContain("===== POPUP =====");
    expect(out).toContain("===== POPUP MODEL =====");
  });

  test("truncates a huge section and names it as the section it is", () => {
    // The hint names the SECTION, not a tab: for a View & Data sub-view a
    // section title is "POPUP MODEL" or "VIEW BINDINGS" - a slot plus an
    // aspect, which no tab is called.
    const { Report } = loadReport({
      lastError: { title: "T", text: "x".repeat(150000) },
    });
    const out = Report.buildExport();
    expect(out).toContain(
      "more characters - the developer tools show the full ERROR content",
    );
  });
});

test.describe("buildMarkdown", () => {
  test("wraps each section in a collapsed details block", () => {
    const { Report } = loadReport();
    const md = Report.buildMarkdown("");
    expect(md).toContain("## abap2UI5 - Developer Tools export");
    expect(md).toContain("<summary>LOG</summary>");
    expect(md).toContain("```text");
    expect(md).toContain("</details>");
  });

  test("leaves the environment section open - it is read first", () => {
    const { Report } = loadReport();
    const md = Report.buildMarkdown("");
    expect(md).toContain("<details open>");
    expect(md).toContain("<summary>ENVIRONMENT</summary>");
  });

  test("fences the ABAP source as abap", () => {
    const { Report } = loadReport();
    const md = Report.buildMarkdown("CLASS zcl_demo DEFINITION.");
    expect(md).toContain("<summary>ABAP SOURCE</summary>");
    expect(md).toContain("```abap");
  });
});

test.describe("copyMarkdown", () => {
  // The one-click path from the dialog footer: an issue body on the
  // clipboard without going through the export popup first.
  test("puts the markdown report on the clipboard and reports success", () => {
    const { Report, copied } = loadReport();
    const result = Report.copyMarkdown("");
    expect(copied.length).toBe(1);
    expect(copied[0]).toContain("<summary>ENVIRONMENT</summary>");
    expect(result).toContain("Markdown");
  });

  test("a clipboard failure is reported rather than thrown", () => {
    const { module: Report } = loadModule("devtools/Report.js", {
      deps: {
        "z2ui5/core/Lib": {
          copyToClipboard: () => {
            throw new Error("no clipboard");
          },
          logError() {},
        },
        "z2ui5/devtools/Recorder": {},
        "z2ui5/devtools/Tabs": { exportTabs: () => [], exportTitle: () => "" },
      },
    });
    expect(Report.copyMarkdown("")).toContain("no clipboard");
  });
});

test.describe("exportFileName", () => {
  test("names the file after the app class", () => {
    const { Report } = loadReport();
    expect(Report.exportFileName("ZCL_DEMO", "txt")).toMatch(
      /^ZCL_DEMO_[\d-]+T[\d-]+Z\.txt$/,
    );
  });

  test("falls back when the class is unknown", () => {
    const { Report } = loadReport();
    expect(Report.exportFileName("", "json")).toMatch(/^abap2ui5_.*\.json$/);
  });
});
