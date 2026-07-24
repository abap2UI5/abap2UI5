// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/ErrorView.js (loaded via a stubbed
// sap.ui.define). Focus: the friendly UI5 error dialog shown first, its
// Details / Restart actions, that Escape does NOT dismiss it, and the
// fallback to the raw-DOM overlay when UI5 cannot render the dialog. The raw
// overlay itself is exercised in the browser by
// node/tests/e2e/error-view.spec.js.

function load({ ui5 = true } = {}) {
  const state = { developerTools: null, lastError: null };
  const AppState = { state };
  const reloads = [];
  const created = { dialogs: [] };
  // Records the text passed to the async clipboard fallback so the Copy
  // button test can assert what would be copied.
  const clipboardWrites = [];
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
      // The stubbed DOM has no execCommand, so copyToClipboard falls back to
      // the async clipboard API - capture what it would write.
      navigator: {
        clipboard: {
          writeText: (v) => {
            clipboardWrites.push(v);
            return Promise.resolve();
          },
        },
      },
      // The Copy button restores its label on a timer; keep it a no-op so the
      // "Copied" feedback state stays observable in the test.
      setTimeout: () => 0,
    },
  });

  // A control constructor stub: returns a plain object carrying the settings
  // so tests can inspect the built dialog / buttons and trigger their presses.
  const makeCtor = (kind) =>
    function (settings) {
      const inst = { kind, settings: settings || {}, destroyed: false };
      inst.open = () => (inst.open_called = true);
      inst.close = () => {
        inst.open_called = false;
        if (inst.settings.afterClose) inst.settings.afterClose();
      };
      inst.destroy = () => (inst.destroyed = true);
      inst.focus = () => {};
      // The Copy button flips its label via setText; mirror it into settings so
      // tests can observe the "Copied" feedback.
      inst.setText = (t) => (inst.settings.text = t);
      if (kind === "Dialog") created.dialogs.push(inst);
      return inst;
    };

  // ui5 === true    -> the controls are already loaded: the synchronous
  //                    (string) require resolves them, so the friendly dialog
  //                    renders on the first try.
  // ui5 === "async" -> the controls are NOT loaded yet: the synchronous require
  //                    returns undefined (friendly dialog skipped), but the
  //                    asynchronous (array) require loads them and the retry
  //                    renders the dialog. This models the first fatal error of
  //                    a session, e.g. a popover fragment that fails to render
  //                    before any Dialog was used.
  // ui5 === false   -> the controls can never be loaded (broken core): both the
  //                    sync require and the async errback fail, so the raw-DOM
  //                    overlay is the only display.
  const haveModules = ui5 !== false;
  const asyncOnly = ui5 === "async";
  const modules = haveModules
    ? {
        "sap/m/Dialog": makeCtor("Dialog"),
        "sap/m/Button": makeCtor("Button"),
        "sap/m/Text": makeCtor("Text"),
      }
    : {};
  // Augment the loader-provided sap.ui (which already carries define) with a
  // require that resolves the lazily-required controls to the stubs above. It
  // emulates the two sap.ui.require signatures: the synchronous string form
  // (returns the module or undefined) and the asynchronous array form (invokes
  // the callback with the resolved modules, or the errback when unavailable).
  // Loaded synchronously from the start only when the controls are already
  // present (ui5 === true). In asyncOnly mode the sync require sees them as
  // not-yet-loaded until the async (array) require pulls them in - after which
  // the sync require resolves them, exactly like the real UI5 loader.
  let loaded = haveModules && !asyncOnly;
  sandbox.sap.ui.require = (name, callback, errback) => {
    if (Array.isArray(name)) {
      if (haveModules) {
        loaded = true;
        callback?.(...name.map((n) => modules[n]));
      } else {
        errback?.(new Error("module not loaded"));
      }
      return undefined;
    }
    return loaded ? modules[name] : undefined;
  };
  return { ErrorView: module, state, reloads, created, clipboardWrites };
}

test.describe("ErrorView friendly dialog", () => {
  test("records the fatal error for the DeveloperTools Error tab", () => {
    const { ErrorView, state } = load();
    const onRetry = () => {};
    ErrorView.show("Boom happened", "My Title", { onRetry });
    expect(state.lastError.title).toBe("My Title");
    expect(state.lastError.text).toBe("Boom happened");
    expect(state.lastError.onRetry).toBe(onRetry);
  });

  test("shows a dialog with Details + Copy + Restart and only the error text", () => {
    const { ErrorView, created } = load();
    ErrorView.show("some backend dump");
    expect(created.dialogs).toHaveLength(1);
    const dlg = created.dialogs[0].settings;
    // No "An unexpected error occurred" prefix - just the error text.
    expect(dlg.content[0].settings.text).toBe("some backend dump");
    // The footer uses the `buttons` aggregation: Details / Copy / Restart.
    const [detailsButton, copyButton, restartButton] = dlg.buttons;
    expect(detailsButton.settings.text).toBe("Details");
    expect(copyButton.settings.text).toBe("Copy");
    expect(restartButton.settings.text).toBe("Restart");
    // Restart is emphasized and gets the initial focus.
    expect(restartButton.settings.type).toBe("Emphasized");
    expect(dlg.initialFocus).toBe(restartButton);
    expect(created.dialogs[0].open_called).toBe(true);
  });

  test("Copy copies the full error text to the clipboard", () => {
    const { ErrorView, created, clipboardWrites } = load();
    ErrorView.show("full backend dump");
    const copyButton = created.dialogs[0].settings.buttons[1];
    expect(copyButton.settings.text).toBe("Copy");
    copyButton.settings.press();
    // execCommand is unavailable in the stubbed DOM, so it falls back to the
    // async clipboard API with the full (untruncated) error text.
    expect(clipboardWrites).toEqual(["full backend dump"]);
    // The label flips to "Copied" as feedback.
    expect(copyButton.settings.text).toBe("Copied");
  });

  test("Escape does not dismiss the fatal-error popup", () => {
    const { ErrorView, created } = load();
    ErrorView.show("dump");
    const rejected = [];
    const resolved = [];
    created.dialogs[0].settings.escapeHandler({
      reject: () => rejected.push(true),
      resolve: () => resolved.push(true),
    });
    // The escape promise is rejected (dialog stays open) and never resolved.
    expect(rejected).toEqual([true]);
    expect(resolved).toEqual([]);
  });

  test("extracts just the error message from a SAP server error page", () => {
    const { ErrorView, created } = load();
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
    const message = created.dialogs[0].settings.content[0].settings.text;
    // Only the header + the real message survive, joined with " - ".
    expect(message).toBe("500 Internal Server Error - Division by zero");
    // Noise is gone: page title, clock, copyright, styles, scripts, tags.
    expect(message).not.toContain("Application Server Error");
    expect(message).not.toContain("Server time");
    expect(message).not.toContain("SAP SE");
    expect(message).not.toContain("color: red");
    expect(message).not.toContain("20260719");
    expect(message).not.toContain("<");
  });

  test("truncates a long preview but keeps the full text for the Error tab", () => {
    const { ErrorView, state, created } = load();
    const long = "x".repeat(2000);
    ErrorView.show(long);
    const message = created.dialogs[0].settings.content[0].settings.text;
    expect(message).toContain("...");
    expect(message.length).toBeLessThan(long.length);
    // The DeveloperTools Error tab still gets the untruncated text.
    expect(state.lastError.text).toBe(long);
  });

  test("Details closes the popup and opens the DeveloperTools on the Error tab", () => {
    const { ErrorView, state, created } = load();
    const showCalls = [];
    state.developerTools = { show: (tab) => showCalls.push(tab) };
    ErrorView.show("dump");
    const dialog = created.dialogs[0];
    dialog.settings.buttons[0].settings.press(); // Details
    expect(dialog.open_called).toBe(false); // dialog was closed
    expect(state.developerTools.reopenErrorOnClose).toBe(true);
    expect(showCalls).toEqual(["ERROR"]);
  });

  test("Restart reloads the page", () => {
    const { ErrorView, reloads, created } = load();
    ErrorView.show("dump");
    created.dialogs[0].settings.buttons[2].settings.press(); // Restart
    expect(reloads).toEqual([true]);
  });

  test("reopenErrorDialog re-shows the popup with the last error", () => {
    const { ErrorView, created } = load();
    ErrorView.show("first dump", "First Title");
    expect(created.dialogs).toHaveLength(1);
    // Closing (e.g. the DeveloperTools reopen flow) and reopening builds a
    // fresh dialog carrying the same title and text.
    created.dialogs[0].close();
    ErrorView.reopenErrorDialog();
    expect(created.dialogs).toHaveLength(2);
    expect(created.dialogs[1].settings.title).toBe("First Title");
    expect(created.dialogs[1].settings.content[0].settings.text).toBe(
      "first dump",
    );
  });

  test("a second fatal error does not stack two popups", () => {
    const { ErrorView, created } = load();
    ErrorView.show("first");
    ErrorView.show("second");
    // The first dialog is destroyed before the second opens.
    expect(created.dialogs[0].destroyed).toBe(true);
    expect(created.dialogs[1].destroyed).toBe(false);
    expect(created.dialogs[1].open_called).toBe(true);
  });

  test("loads the dialog modules asynchronously and still shows the popup", () => {
    // ui5:"async" -> the synchronous require returns undefined (Dialog not
    // loaded yet, e.g. a popover fragment that fails to render on the first
    // roundtrip), but the async require loads the controls and the retry
    // renders the friendly popup - it must NOT drop to the raw-DOM overlay.
    const { ErrorView, created } = load({ ui5: "async" });
    ErrorView.show(
      "popover dump",
      "Unexpected Error Occurred - App Terminated",
    );
    expect(created.dialogs).toHaveLength(1);
    expect(created.dialogs[0].open_called).toBe(true);
    expect(created.dialogs[0].settings.content[0].settings.text).toBe(
      "popover dump",
    );
  });

  test("falls back to the raw overlay when UI5 cannot render a dialog", () => {
    // ui5:false -> sap.ui.require returns undefined for the controls (sync) and
    // the async errback fires -> the friendly dialog is skipped and the raw-DOM
    // overlay path runs without throwing (records lastError either way).
    const { ErrorView, state, created } = load({ ui5: false });
    expect(() => ErrorView.show("dump", "T")).not.toThrow();
    expect(created.dialogs).toHaveLength(0);
    expect(state.lastError.text).toBe("dump");
  });
});
