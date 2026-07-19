// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/ErrorView.js (loaded via a stubbed
// sap.ui.define). Focus: the friendly UI5 error dialog shown first, its
// Details / Restart actions, and the fallback to the raw-DOM overlay when
// UI5 cannot render a MessageBox. The raw overlay itself is exercised in
// the browser by node/tests/e2e/error-view.spec.js.

function load({ messageBox } = {}) {
  const state = { developerTools: null, lastError: null };
  const AppState = { state };
  const reloads = [];
  // Minimal DOM so the raw-overlay fallback path does not throw when it runs.
  const el = () => ({
    id: "",
    style: {},
    setAttribute() {},
    appendChild() {},
    addEventListener() {},
    querySelector: () => null,
    querySelectorAll: () => [],
    focus() {},
    remove() {},
    get contentDocument() {
      return { body: { appendChild() {} }, createElement: () => el() };
    },
  });
  const document = {
    getElementById: () => null,
    createElement: () => el(),
    body: { appendChild() {} },
  };
  const { module, sandbox } = loadModule("core/ErrorView.js", {
    deps: { "z2ui5/core/AppState": AppState },
    sandbox: {
      document,
      window: { location: { reload: () => reloads.push(true) } },
    },
  });
  // Augment the loader-provided sap.ui (which already carries define) with a
  // require that resolves sap/m/MessageBox to the test stub - setting a whole
  // `sap` in the sandbox would clobber sap.ui.define and break module load.
  sandbox.sap.ui.require = () => messageBox;
  return { ErrorView: module, state, reloads };
}

test.describe("ErrorView friendly dialog", () => {
  test("records the fatal error for the DeveloperTools Error tab", () => {
    const { ErrorView, state } = load({ messageBox: { error() {} } });
    const onRetry = () => {};
    ErrorView.show("Boom happened", "My Title", { onRetry });
    expect(state.lastError.title).toBe("My Title");
    expect(state.lastError.text).toBe("Boom happened");
    expect(state.lastError.onRetry).toBe(onRetry);
  });

  test("shows a MessageBox with Details + Restart actions and only the error text", () => {
    const calls = [];
    const messageBox = {
      error: (message, opts) => calls.push({ message, opts }),
    };
    const { ErrorView } = load({ messageBox });
    ErrorView.show("some backend dump");
    expect(calls).toHaveLength(1);
    // No "An unexpected error occurred" prefix - just the error text.
    expect(calls[0].message).toBe("some backend dump");
    expect(calls[0].opts.actions).toEqual(["Details", "Restart"]);
    expect(calls[0].opts.emphasizedAction).toBe("Restart");
  });

  test("extracts just the error message from a SAP server error page", () => {
    const calls = [];
    const messageBox = {
      error: (message, opts) => calls.push({ message, opts }),
    };
    const { ErrorView } = load({ messageBox });
    const htmlDump = [
      "<!DOCTYPE html><html><head><title>Application Server Error</title>",
      "<style>body { color: red; }</style>",
      '<script>var d = "20260719";</script></head><body>',
      '<p class="errorTextHeader"> <span >500 Internal Server Error</span> </p>',
      '<p class="detailText"> <span id="msgText">Division by zero</span></p>',
      '<p class="detailText"> <span id="msgText">Server time: <script>document.write(d);</script></span> </p>',
      '<div class="footerRight"><p class="bottomText"><span>&copy;</span> 2026 SAP SE, All rights reserved.</p></div>',
      "</body></html>",
    ].join("");
    ErrorView.show(htmlDump);
    // Only the header + the real message survive, joined with " - ".
    expect(calls[0].message).toBe("500 Internal Server Error - Division by zero");
    // Noise is gone: page title, clock, copyright, styles, scripts, tags.
    expect(calls[0].message).not.toContain("Application Server Error");
    expect(calls[0].message).not.toContain("Server time");
    expect(calls[0].message).not.toContain("SAP SE");
    expect(calls[0].message).not.toContain("color: red");
    expect(calls[0].message).not.toContain("20260719");
    expect(calls[0].message).not.toContain("<");
  });

  test("truncates a long preview but keeps the full text for the Error tab", () => {
    const calls = [];
    const messageBox = {
      error: (message, opts) => calls.push({ message, opts }),
    };
    const { ErrorView, state } = load({ messageBox });
    const long = "x".repeat(2000);
    ErrorView.show(long);
    expect(calls[0].message).toContain("...");
    expect(calls[0].message.length).toBeLessThan(long.length);
    // The DeveloperTools Error tab still gets the untruncated text.
    expect(state.lastError.text).toBe(long);
  });

  test("Details opens the DeveloperTools on the Error tab", () => {
    const showCalls = [];
    let onClose;
    const messageBox = {
      error: (message, opts) => (onClose = opts.onClose),
    };
    const { ErrorView, state } = load({ messageBox });
    state.developerTools = { show: (tab) => showCalls.push(tab) };
    ErrorView.show("dump");
    onClose("Details");
    expect(showCalls).toEqual(["ERROR"]);
  });

  test("Restart reloads the page", () => {
    let onClose;
    const messageBox = {
      error: (message, opts) => (onClose = opts.onClose),
    };
    const { ErrorView, reloads } = load({ messageBox });
    ErrorView.show("dump");
    onClose("Restart");
    expect(reloads).toEqual([true]);
  });

  test("falls back to the raw overlay when no MessageBox is available", () => {
    // messageBox undefined -> sap.ui.require returns undefined -> the
    // friendly dialog is skipped and the raw-DOM overlay path runs without
    // throwing (records lastError either way).
    const { ErrorView, state } = load({ messageBox: undefined });
    expect(() => ErrorView.show("dump", "T")).not.toThrow();
    expect(state.lastError.text).toBe("dump");
  });
});
