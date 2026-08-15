// @ts-check
const fs = require("fs");
const path = require("path");
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Checks app/webapp/devtools/DeveloperTools.fragment.xml against the
// control that backs it.
//
// This is the gap the other specs cannot close: a fragment is data, so a
// handler named in it that does not exist on the controller, or a bound
// property nothing ever seeds, is not a syntax error anywhere. It fails at
// runtime - as a dead button or an empty control - and only on a system
// where somebody opens that tab. Nothing in abaplint, ui5lint or the unit
// specs looks at the pair.

const FRAGMENT = fs.readFileSync(
  path.join(__dirname, "..", "..", "app", "webapp", "devtools", "DeveloperTools.fragment.xml"),
  "utf8",
);

// The markup alone. Every structural assertion below runs against this
// rather than the raw file: the comments deliberately quote the very tags
// the rules forbid (`<footer>`, `{= ... }`), because that is where the
// reasoning for not using them belongs.
const MARKUP = FRAGMENT.replace(/<!--[\s\S]*?-->/g, "");

// Attribute values are read off the raw text rather than through a DOM:
// the questions here are "which names does this file mention", and the
// answers are the same either way.
function attributeValues(name) {
  const found = new Set();
  const pattern = new RegExp(`${name}="([^"]*)"`, "g");
  let match = pattern.exec(FRAGMENT);
  while (match !== null) {
    found.add(match[1]);
    match = pattern.exec(FRAGMENT);
  }
  return Array.from(found);
}

// Every ".onSomething" a control is wired to.
function handlerNames() {
  const found = new Set();
  const pattern = /="\.(on[A-Za-z0-9_]+)"/g;
  let match = pattern.exec(FRAGMENT);
  while (match !== null) {
    found.add(match[1]);
    match = pattern.exec(FRAGMENT);
  }
  return Array.from(found);
}

// Every absolute model path the fragment binds. The relative ones inside
// the two item templates ({key}, {text}) resolve against a row context and
// are asserted separately.
function boundPaths() {
  const found = new Set();
  const pattern = /"\{\/([A-Za-z0-9_]+)\}"/g;
  let match = pattern.exec(FRAGMENT);
  while (match !== null) {
    found.add(match[1]);
    match = pattern.exec(FRAGMENT);
  }
  return Array.from(found);
}

// The dialog control, loaded with enough stubs to reach show() and walk
// every group - the model it seeds is what the fragment binds against.
function loadDialogModel() {
  const models = [];
  const views = {
    MAIN: {
      mProperties: { viewContent: "<mvc:View/>" },
      getModel: () => ({ getData: () => ({ NAME: "x" }) }),
    },
  };
  const { module: DeveloperTools } = loadModule("devtools/DeveloperTools.js", {
    autoLoad: true,
    deps: {
      "sap/ui/core/Control": { extend: (_name, spec) => spec },
      "sap/ui/core/Fragment": {
        load: async () => ({ setModel: (m) => models.push(m), open() {} }),
        byId: () => ({ setContent() {} }),
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
      "z2ui5/core/Lib": {
        isDestroyed: () => false,
        logError() {},
        copyToClipboard() {},
      },
      "z2ui5/core/ViewSlots": {
        getView: (key) => views[key],
        getViewXml: () => undefined,
      },
      "z2ui5/core/AppState": {
        state: {
          responseData: { S_FRONT: { APP: "ZCL_DEMO" } },
          oBody: null,
          errors: [],
          lastError: { title: "x", text: "y", onRetry: () => {} },
        },
        getGlobal: () => undefined,
      },
      "z2ui5/core/ErrorView": { handleLogout() {}, reopenErrorDialog() {} },
      "z2ui5/devtools/Console": {
        isAlertOnError: () => false,
        setAlertOnError() {},
      },
      "z2ui5/devtools/Recorder": {
        isRecordingPayloads: () => false,
        setRecordingPayloads() {},
        getRecords: () => [],
        formatHistory: () => "history",
        formatModelDiff: () => "diff",
        formatViewDiff: () => "viewdiff",
        exportJson: () => "{}",
      },
      "z2ui5/devtools/Inspect": {
        formatHelp: () => "help",
        formatOverview: () => "overview",
        formatError: () => "error",
        formatEnvironment: () => "env",
        formatRegistry: () => "registry",
        formatActions: () => "actions",
        formatLog: () => "log",
        formatBindings: () => "bindings",
        findEventLine: () => 0,
      },
      "z2ui5/devtools/Picker": { start() {}, stop() {}, lastReport: () => "" },
      "z2ui5/devtools/LiveEdit": {
        apply: () => Promise.resolve("ok"),
        canApply: () => true,
        slotOfTab: () => "MAIN",
        originalXml: () => "",
        isBusy: () => false,
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
      URLSearchParams,
      fetch: async () => ({ ok: false }),
      sap: { ui: { require: (_mods, resolve) => resolve() } },
      window: {
        location: { origin: "https://sap.example.com", search: "" },
        open() {},
        sessionStorage: { getItem: () => null, setItem() {} },
      },
    },
  });
  return { DeveloperTools, models };
}

test.describe("handlers", () => {
  test("every handler the fragment names exists on the control", async () => {
    const { DeveloperTools } = loadDialogModel();
    const names = handlerNames();
    // a guard on the guard: a regex that matched nothing would pass
    // vacuously and check the fragment forever without reading it
    expect(names.length).toBeGreaterThan(10);
    for (const name of names) {
      expect(typeof DeveloperTools[name], `${name} is wired but missing`).toBe(
        "function",
      );
    }
  });
});

test.describe("bindings", () => {
  test("every absolute path the fragment binds is seeded by show()", async () => {
    const { DeveloperTools, models } = loadDialogModel();
    await DeveloperTools.show();
    const data = models[0].getData();
    const paths = boundPaths();
    expect(paths.length).toBeGreaterThan(15);
    for (const path of paths) {
      expect(path in data, `/${path} is bound but never seeded`).toBe(true);
    }
  });

  test("and stays seeded after walking every group", async () => {
    // renderTab rewrites the per-view half of the model on every
    // selection; a property it forgets would leave a control bound to
    // undefined rather than to a value.
    const { DeveloperTools, models } = loadDialogModel();
    await DeveloperTools.show();
    const oModel = models[0];
    const data = oModel.getData();
    for (const key of [
      "OVERVIEW",
      "ERROR",
      "LOG",
      "HISTORY",
      "PLAIN",
      "VIEW",
      "MODEL",
      "PICK",
      "ENV",
      "SOURCE",
    ]) {
      DeveloperTools.renderTab(key, oModel);
      for (const path of boundPaths()) {
        expect(path in data, `/${path} lost on the ${key} view`).toBe(true);
      }
    }
  });

  test("the two item templates bind the keys the selectors are built from", () => {
    // renderTab fills /slots and /views with {key, text} entries
    expect(attributeValues("key")).toContain("{key}");
    expect(attributeValues("text")).toContain("{text}");
  });
});

test.describe("1.71 compatibility", () => {
  // AGENTS.md rule 13: expression binding is compiled with eval/new
  // Function, so it dies under any CSP stricter than the one shipped.
  // Framework-controlled XML must drive such state from a plain property.
  test("no expression binding", () => {
    expect(MARKUP).not.toContain("{=");
  });

  // AGENTS.md rule 15: sap.m.Dialog gained a public `footer` aggregation
  // only around 1.110; on 1.71 the tag resolves as a control class and
  // 404s with "failed to load sap/m/footer.js", killing the view.
  test("the dialog footer is the buttons aggregation", () => {
    expect(MARKUP).toContain("<buttons>");
    expect(MARKUP).not.toContain("<footer>");
  });

  // AGENTS.md rule 21b: ToolbarSpacer/ToolbarSeparator render a <div> and
  // are laid out as intended only inside a sap.m.Toolbar. Before 1.76 a
  // sap.m.Bar puts a block-level child on a new line and clips everything
  // from there on - which silently swallowed header icons on 1.71.
  test("no toolbar-only control sits in a Bar", () => {
    const bars = MARKUP.match(/<Bar[\s>][\s\S]*?<\/Bar>/g) || [];
    for (const bar of bars) {
      expect(bar).not.toContain("ToolbarSpacer");
      expect(bar).not.toContain("ToolbarSeparator");
    }
    // the sub-header is a Toolbar precisely because of the above
    expect(MARKUP).toMatch(/<subHeader>\s*<Toolbar>/);
  });

  // AGENTS.md rule 14: every frontend file is embedded verbatim into an
  // ABAP class, which abaplint checks with the 7bit_ascii rule.
  test("the fragment is 7-bit ASCII", () => {
    const nonAscii = FRAGMENT.split("").filter((c) => c.charCodeAt(0) > 127);
    expect(nonAscii).toEqual([]);
  });
});
