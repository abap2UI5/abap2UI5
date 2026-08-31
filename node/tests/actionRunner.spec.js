// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests FrontendAction.runCustom - the follow-up-action path. A backend
// snippet is a JSON array ["EVENT", ...args] (the structured form every
// framework follow-up action travels in - serialized and escaped entirely in
// ABAP by z2ui5_cl_ui5_srv_event=>get_event_client_ajson), a legacy eF( )
// call whose argument list is parsed WITHOUT eval so it runs under a strict
// CSP (core/actions/LegacyCustomJs.js), or a raw expression. The legacy
// argument parser has to be the exact counterpart of the backend's escaping
// (z2ui5_cl_ui5_srv_event=>escape_js_string), which escapes backslash, the
// single quote AND the line breaks it rewrites to \n / \r.

// Load FrontendAction with every domain handler map stubbed empty (override
// individual maps via `deps`). LegacyCustomJs - a unit under test here -
// loads for real via autoLoad.
function loadFrontendAction(deps = {}) {
  const noHandlers = { handlers: {} };
  const { module } = loadModule("core/FrontendAction.js", {
    autoLoad: true,
    deps: {
      "z2ui5/core/actions/ControlCall": noHandlers,
      "z2ui5/core/actions/Browser": noHandlers,
      "z2ui5/core/actions/Launchpad": noHandlers,
      "z2ui5/core/actions/Variants": noHandlers,
      "z2ui5/core/actions/Shortcuts": noHandlers,
      "z2ui5/core/actions/ViewOps": noHandlers,
      "z2ui5/core/Lib": { logError: () => {}, runCallbacks: () => {} },
      "z2ui5/core/AppState": { state: { onBeforeEventFrontend: [] } },
      ...deps,
    },
  });
  return module;
}

// Collects the arguments a snippet dispatches to eF( ).
function controllerStub() {
  const calls = [];
  return { calls, eF: (...args) => calls.push(args) };
}

test.describe("runSystem", () => {
  function loadWithHandler(handler) {
    return loadFrontendAction({
      "z2ui5/core/actions/ViewOps": { handlers: { TEST_ACTION: handler } },
    });
  }

  test("runs a real-array action and threads the context through", () => {
    const seen = [];
    const FrontendAction = loadWithHandler((oController, args, ctx) =>
      seen.push([oController, args, ctx]),
    );
    const oController = {};
    FrontendAction.runSystem(["TEST_ACTION", "a1"], oController, { seq: 3 });
    expect(seen).toEqual([[oController, ["TEST_ACTION", "a1"], { seq: 3 }]]);
  });

  test("still parses the stringified form of a skewed backend", () => {
    const seen = [];
    const FrontendAction = loadWithHandler((_c, args) => seen.push(args));
    FrontendAction.runSystem('["TEST_ACTION","a1"]', null, {});
    expect(seen).toEqual([["TEST_ACTION", "a1"]]);
  });
});

test.describe("runCustom structured JSON actions", () => {
  test("dispatches a REAL array as an eF event (the wire form)", () => {
    // the backend embeds framework actions into the response as real nested
    // arrays (z2ui5_cl_ui5_handler=>actions_serialize) - no parse, no escaping
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(["SET_FOCUS", "myInput"], oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("a real array keeps objects and positional empties intact", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
      oController,
    );

    expect(oController.calls).toEqual([
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
    ]);
  });

  test("dispatches a JSON array as an eF event", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // the structured form the backend emits for framework follow-up actions
    // (z2ui5_cl_ui5_srv_event=>get_event_client_ajson): pure data, one
    // JSON.parse, no code parsing
    FrontendAction.runCustom('["SET_FOCUS","myInput"]', oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("keeps embedded objects and positional empties intact", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(
      '["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]',
      oController,
    );

    expect(oController.calls).toEqual([
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
    ]);
  });

  test("special characters survive the JSON round trip", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // the backend JSON-escapes quotes, backslashes and line breaks - they
    // must arrive as the original characters, decoded by JSON.parse alone
    FrontendAction.runCustom(
      '["CLIPBOARD_COPY","line1\\nline2 \\"quoted\\" C:\\\\dir"]',
      oController,
    );

    expect(oController.calls).toEqual([
      ["CLIPBOARD_COPY", 'line1\nline2 "quoted" C:\\dir'],
    ]);
  });

  test("a raw JS expression starting with [ is not misread as an action", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // not a JSON array - JSON.parse fails, so the snippet takes the raw-JS
    // path (Format C) instead of being dispatched as a structured action
    FrontendAction.runCustom("[1, 2].concat([3]).length", oController);

    expect(oController.calls).toEqual([]);
  });
});

test.describe("runCustom legacy eF( ) argument parsing", () => {
  test("passes a plain quoted argument through", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom("eF('SET_FOCUS','myInput')", oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("decodes the escaped line breaks the backend emits", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // escape_js_string turns a CR+LF / LF into the two characters \ n - a raw
    // newline would be a syntax error inside a JS string literal, so a
    // multi-line argument only ever travels escaped. It must arrive as a real
    // line break, not as a literal backslash-n.
    FrontendAction.runCustom(
      "eF('CLIPBOARD_COPY','line1\\nline2\\rline3')",
      oController,
    );

    expect(oController.calls).toEqual([
      ["CLIPBOARD_COPY", "line1\nline2\rline3"],
    ]);
  });

  test("keeps an escaped backslash a backslash", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // On the wire: \\ n - an escaped backslash followed by a plain "n". The
    // backslash must survive and the "n" must NOT be swallowed into a newline.
    FrontendAction.runCustom("eF('CLIPBOARD_COPY','C:\\\\new')", oController);

    expect(oController.calls).toEqual([["CLIPBOARD_COPY", "C:\\new"]]);
  });

  test("keeps an escaped quote inside the argument", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom("eF('CLIPBOARD_COPY','it\\'s here')", oController);

    expect(oController.calls).toEqual([["CLIPBOARD_COPY", "it's here"]]);
  });

  test("keeps object, number and boolean arguments intact", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(
      'eF(\'CONTROL_BY_ID\',\'tab\',\'\',\'scrollToIndex\',5,true,{"A":1})',
      oController,
    );

    // the empty view slot stays an empty string, so every following argument
    // keeps its position (the backend pads it for exactly that reason)
    expect(oController.calls).toEqual([
      ["CONTROL_BY_ID", "tab", "", "scrollToIndex", 5, true, { A: 1 }],
    ]);
  });
});
