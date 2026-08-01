// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests Server._runCustomJs - the follow-up-action path. A backend snippet is
// either an eF( ) call, whose argument list is parsed WITHOUT eval so it runs
// under a strict CSP, or a raw expression. The argument parser has to be the
// exact counterpart of the backend's escaping
// (z2ui5_cl_core_srv_event=>escape_js_string), which escapes backslash, the
// single quote AND the line breaks it rewrites to \n / \r.

function loadServer() {
  return loadModule("core/Server.js", {}).module;
}

// Collects the arguments a snippet dispatches to eF( ).
function controllerStub() {
  const calls = [];
  return { calls, eF: (...args) => calls.push(args) };
}

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
