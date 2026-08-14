// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in
// app/webapp/core/devtools/DevTools.js - the lifecycle facade that is the
// ONLY entry point the framework calls into the developer tools. What it
// owns (shortcut, instance, recorder install, auto open, the error-details
// provider) used to be spread over Component.js, AppState.js and
// ErrorView.js; these specs are what keeps it from drifting back.

function loadDevTools({ search = "" } = {}) {
  const listeners = [];
  const globals = {};
  const callbacks = {};
  const recorderCalls = [];
  const instances = [];

  // A DeveloperTools double: the facade only ever creates it, toggles /
  // shows it and destroys it.
  class DeveloperTools {
    constructor() {
      this.shown = [];
      this.toggled = 0;
      this.destroyed = false;
      instances.push(this);
    }
    show(tab) {
      this.shown.push(tab);
    }
    toggle() {
      this.toggled += 1;
    }
    destroy() {
      this.destroyed = true;
    }
  }

  const { module } = loadModule("core/devtools/DevTools.js", {
    deps: {
      "z2ui5/core/AppState": {
        state: {},
        setGlobal: (name, value) => {
          globals[name] = value;
        },
        getGlobal: (name) => globals[name],
      },
      "z2ui5/core/ErrorView": {},
      "z2ui5/core/Lib": {
        registerCallback(name, fn) {
          if (!callbacks[name]) callbacks[name] = [];
          callbacks[name].push(fn);
        },
        unregisterCallback(name, fn) {
          if (!callbacks[name]) return;
          callbacks[name] = callbacks[name].filter((f) => f !== fn);
        },
      },
      "z2ui5/core/devtools/Console": {
        install: () => recorderCalls.push("console:install"),
        uninstall: () => recorderCalls.push("console:uninstall"),
      },
      "z2ui5/core/devtools/DeveloperTools": DeveloperTools,
      "z2ui5/core/devtools/Recorder": {
        install: () => recorderCalls.push("install"),
        uninstall: () => recorderCalls.push("uninstall"),
      },
    },
    sandbox: {
      URLSearchParams,
      window: { location: { search } },
      document: {
        addEventListener: (type, fn) => listeners.push({ type, fn }),
        removeEventListener: (type, fn) => {
          const i = listeners.findIndex((l) => l.type === type && l.fn === fn);
          if (i >= 0) listeners.splice(i, 1);
        },
      },
    },
  });

  return {
    DevTools: module,
    listeners,
    globals,
    callbacks,
    recorderCalls,
    instances,
    press: (init) => {
      for (const l of listeners.filter((x) => x.type === "keydown")) l.fn(init);
    },
  };
}

const CTRL_F12 = { ctrlKey: true, key: "F12" };

test.describe("install", () => {
  test("starts the recorder, the shortcut and the error-details provider", () => {
    const h = loadDevTools();
    h.DevTools.install();
    expect(h.recorderCalls).toEqual(["install", "console:install"]);
    expect(h.listeners.filter((l) => l.type === "keydown").length).toBe(1);
    expect(h.callbacks.onErrorDetails.length).toBe(1);
  });

  test("is idempotent", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.DevTools.install();
    expect(h.listeners.length).toBe(1);
    expect(h.recorderCalls).toEqual(["install", "console:install"]);
  });

  test("creates no dialog until it is actually needed", () => {
    const h = loadDevTools();
    h.DevTools.install();
    // installing must not cost a control - the tools are opened rarely
    expect(h.instances.length).toBe(0);
  });
});

test.describe("Ctrl+F12", () => {
  test("creates the dialog on first press and toggles it after", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(1);
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(2);
  });

  test("ignores other keys", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.press({ ctrlKey: true, key: "F11" });
    h.press({ ctrlKey: false, key: "F12" });
    expect(h.instances.length).toBe(0);
  });

  test("publishes the instance on the z2ui5 global under its old name", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.press(CTRL_F12);
    // apps could reach it there before it moved off AppState - keep working
    expect(h.globals.developerTools).toBe(h.instances[0]);
  });
});

test.describe("auto open", () => {
  test("stays closed without the parameter", () => {
    const h = loadDevTools({ search: "?app_start=ZCL_X" });
    expect(h.DevTools.isAutoOpenRequested()).toBe(false);
    h.DevTools.install();
    expect(h.instances.length).toBe(0);
  });

  test("=1 opens the default tab", () => {
    const h = loadDevTools({ search: "?z2ui5-devtools=1" });
    expect(h.DevTools.isAutoOpenRequested()).toBe(true);
    expect(h.DevTools.autoOpenTab()).toBe("");
    h.DevTools.install();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual([undefined]);
  });

  test("a tab key opens that tab, case-insensitively", () => {
    const h = loadDevTools({ search: "?z2ui5-devtools=history" });
    expect(h.DevTools.autoOpenTab()).toBe("HISTORY");
    h.DevTools.install();
    expect(h.instances[0].shown).toEqual(["HISTORY"]);
  });

  test("survives alongside other query parameters", () => {
    const h = loadDevTools({ search: "?app_start=ZCL_X&z2ui5-devtools=ENV" });
    expect(h.DevTools.autoOpenTab()).toBe("ENV");
  });
});

test.describe("error details provider", () => {
  test("opens the Error tab and arms the return to the error popup", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.callbacks.onErrorDetails[0]();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual(["ERROR"]);
    // closing the dialog must land the user back on the error popup, not
    // on the dismissed, broken app
    expect(h.instances[0].reopenErrorOnClose).toBe(true);
  });
});

test.describe("exit", () => {
  test("removes the shortcut, the provider, the dialog and the recorder", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.press(CTRL_F12);
    const dialog = h.instances[0];

    h.DevTools.exit();
    expect(h.listeners.length).toBe(0);
    expect(h.callbacks.onErrorDetails.length).toBe(0);
    expect(dialog.destroyed).toBe(true);
    expect(h.globals.developerTools).toBe(null);
    expect(h.recorderCalls).toEqual([
      "install",
      "console:install",
      "console:uninstall",
      "uninstall",
    ]);
  });

  test("a re-install after exit starts from a fresh dialog", () => {
    const h = loadDevTools();
    h.DevTools.install();
    h.press(CTRL_F12);
    h.DevTools.exit();
    h.DevTools.install();
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(2);
    expect(h.instances[0].destroyed).toBe(true);
    expect(h.instances[1].destroyed).toBe(false);
  });

  test("exit without install is harmless", () => {
    const h = loadDevTools();
    h.DevTools.exit();
    // the teardown is unconditional on purpose - both uninstalls are
    // idempotent, so a partially failed install still gets cleaned up
    expect(h.recorderCalls).toEqual(["console:uninstall", "uninstall"]);
    expect(h.listeners.length).toBe(0);
  });
});
