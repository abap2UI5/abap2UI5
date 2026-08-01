// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server._runCustomJs - the follow-up-action path. A backend snippet is
// a JSON array ["EVENT", ...args] (the structured form every framework
// follow-up action travels in - serialized and escaped entirely in ABAP by
// z2ui5_cl_core_srv_event=>get_event_client_json), a legacy eF( ) call whose
// argument list is parsed WITHOUT eval so it runs under a strict CSP, or a
// raw expression. The legacy argument parser has to be the exact counterpart
// of the backend's escaping (z2ui5_cl_core_srv_event=>escape_js_string),
// which escapes backslash, the single quote AND the line breaks it rewrites
// to \n / \r.

function loadServer() {
  return loadModule("core/Server.js", {}).module;
}

// Collects the arguments a snippet dispatches to eF( ).
function controllerStub() {
  const calls = [];
  return { calls, eF: (...args) => calls.push(args) };
}

test.describe("Server._runCustomJs structured JSON actions", () => {
  test("dispatches a JSON array as an eF event", () => {
    const Server = loadServer();
    const oController = controllerStub();

    // the structured form the backend emits for framework follow-up actions
    // (z2ui5_cl_core_srv_event=>get_event_client_json): pure data, one
    // JSON.parse, no code parsing
    Server._runCustomJs('["SET_FOCUS","myInput"]', oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("keeps embedded objects and positional empties intact", () => {
    const Server = loadServer();
    const oController = controllerStub();

    Server._runCustomJs(
      '["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]',
      oController,
    );

    expect(oController.calls).toEqual([
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
    ]);
  });

  test("special characters survive the JSON round trip", () => {
    const Server = loadServer();
    const oController = controllerStub();

    // the backend JSON-escapes quotes, backslashes and line breaks - they
    // must arrive as the original characters, decoded by JSON.parse alone
    Server._runCustomJs(
      '["CLIPBOARD_COPY","line1\\nline2 \\"quoted\\" C:\\\\dir"]',
      oController,
    );

    expect(oController.calls).toEqual([
      ["CLIPBOARD_COPY", 'line1\nline2 "quoted" C:\\dir'],
    ]);
  });

  test("a raw JS expression starting with [ is not misread as an action", () => {
    const Server = loadServer();
    const oController = controllerStub();

    // not a JSON array - JSON.parse fails, so the snippet takes the raw-JS
    // path (Format C) instead of being dispatched as a structured action
    Server._runCustomJs("[1, 2].concat([3]).length", oController);

    expect(oController.calls).toEqual([]);
  });
});

test.describe("Server._runCustomJs argument parsing", () => {
  test("passes a plain quoted argument through", () => {
    const Server = loadServer();
    const oController = controllerStub();

    Server._runCustomJs("eF('SET_FOCUS','myInput')", oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("decodes the escaped line breaks the backend emits", () => {
    const Server = loadServer();
    const oController = controllerStub();

    // escape_js_string turns a CR+LF / LF into the two characters \ n - a raw
    // newline would be a syntax error inside a JS string literal, so a
    // multi-line argument only ever travels escaped. It must arrive as a real
    // line break, not as a literal backslash-n.
    Server._runCustomJs(
      "eF('CLIPBOARD_COPY','line1\\nline2\\rline3')",
      oController,
    );

    expect(oController.calls).toEqual([
      ["CLIPBOARD_COPY", "line1\nline2\rline3"],
    ]);
  });

  test("keeps an escaped backslash a backslash", () => {
    const Server = loadServer();
    const oController = controllerStub();

    // On the wire: \\ n - an escaped backslash followed by a plain "n". The
    // backslash must survive and the "n" must NOT be swallowed into a newline.
    Server._runCustomJs("eF('CLIPBOARD_COPY','C:\\\\new')", oController);

    expect(oController.calls).toEqual([["CLIPBOARD_COPY", "C:\\new"]]);
  });

  test("keeps an escaped quote inside the argument", () => {
    const Server = loadServer();
    const oController = controllerStub();

    Server._runCustomJs("eF('CLIPBOARD_COPY','it\\'s here')", oController);

    expect(oController.calls).toEqual([["CLIPBOARD_COPY", "it's here"]]);
  });

  test("keeps object, number and boolean arguments intact", () => {
    const Server = loadServer();
    const oController = controllerStub();

    Server._runCustomJs(
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
