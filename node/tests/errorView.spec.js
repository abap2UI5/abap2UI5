// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/ErrorView.js (loaded via a stubbed
// sap.ui.define). Focus: the friendly UI5 error dialog shown first, its
// Details / Restart actions, and the fallback to the raw-DOM overlay when
// UI5 cannot render a MessageBox. The raw overlay itself is exercised in
// the browser by node/tests/e2e/error-view.spec.js.

function load({ messageBox } = {}) {
  const state = { debugTool: null, lastError: null };
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
  test("records the fatal error for the DebugTool Error tab", () => {
    const { ErrorView, state } = load({ messageBox: { error() {} } });
    const onRetry = () => {};
    ErrorView.show("Boom happened", "My Title", { onRetry });
    expect(state.lastError.title).toBe("My Title");
    expect(state.lastError.text).toBe("Boom happened");
    expect(state.lastError.onRetry).toBe(onRetry);
  });

  test("shows a MessageBox with Details + Restart actions and the error preview", () => {
    const calls = [];
    const messageBox = {
      error: (message, opts) => calls.push({ message, opts }),
    };
    const { ErrorView } = load({ messageBox });
    ErrorView.show("some backend dump");
    expect(calls).toHaveLength(1);
    expect(calls[0].message).toBe(
      "An unexpected error occurred:\n\nsome backend dump",
    );
    expect(calls[0].opts.actions).toEqual(["Details", "Restart"]);
    expect(calls[0].opts.emphasizedAction).toBe("Restart");
  });

  test("previews the meaningful text of an HTML backend dump", () => {
    const calls = [];
    const messageBox = {
      error: (message, opts) => calls.push({ message, opts }),
    };
    const { ErrorView } = load({ messageBox });
    const htmlDump = [
      "<!DOCTYPE html><html><head><style>body { color: red; }</style>",
      '<script>var d = "20260719";</script></head><body>',
      '<p class="errorTextHeader">500 Internal Server Error</p>',
      '<p class="detailText">Division by zero</p>',
      "</body></html>",
    ].join("");
    ErrorView.show(htmlDump);
    // <style>/<script> contents are dropped; the visible text survives.
    expect(calls[0].message).toContain("500 Internal Server Error");
    expect(calls[0].message).toContain("Division by zero");
    expect(calls[0].message).not.toContain("color: red");
    expect(calls[0].message).not.toContain("20260719");
    expect(calls[0].message).not.toContain("<p");
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
    // The DebugTool Error tab still gets the untruncated text.
    expect(state.lastError.text).toBe(long);
  });

  test("Details opens the DebugTool on the Error tab", () => {
    const showCalls = [];
    let onClose;
    const messageBox = {
      error: (message, opts) => (onClose = opts.onClose),
    };
    const { ErrorView, state } = load({ messageBox });
    state.debugTool = { show: (tab) => showCalls.push(tab) };
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
