// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, specContext } = require("./loadLibModule");

// Tests the real implementation shipped in
// app/webapp/devtools/DevTools.js - the lifecycle facade that is the
// ONLY entry point the framework calls into the developer tools. What it
// owns (shortcut, instance, recorder install, auto open, the error-details
// provider) used to be spread over Component.js, AppState.js and
// ErrorView.js; these specs are what keeps it from drifting back.
//
// Everything it owns is PER COMPONENT CONTEXT (core/Context.js) and lives
// on `ctx.devtools`: install(ctx) fills it, exit(ctx) empties it, and a
// second context on the same page gets a record, a dialog and listeners of
// its own. The console capture is the one page-wide part, use-counted.

function loadDevTools({ search = "" } = {}) {
  const listeners = [];
  const recorderCalls = [];
  const instances = [];
  const errorSubscribers = new Set();
  const consoleUsers = { count: 0 };

  // The real core/Lib: the error-details hook lands on the context's
  // own callback array through the shipped registerCallback, which is
  // what makes "two contexts, two hooks" observable.
  const { Lib, ctx } = loadLib();

  // A DeveloperTools double: the facade only ever creates it, hands it
  // its context, toggles / shows it and destroys it.
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

  const { module } = loadModule("devtools/DevTools.js", {
    deps: {
      "z2ui5/core/Lib": Lib,
      // page-wide and use-counted (devtools/Console.js): the facade takes
      // one use per install and gives it back per exit
      "z2ui5/devtools/Console": {
        install: () => {
          consoleUsers.count += 1;
          recorderCalls.push("console:install");
        },
        uninstall: () => {
          consoleUsers.count -= 1;
          recorderCalls.push("console:uninstall");
        },
        // Console owns the "open on error" setting and only announces an
        // error when it is on, so the facade's handler is unconditional.
        addOnError: (fn) => errorSubscribers.add(fn),
        removeOnError: (fn) => errorSubscribers.delete(fn),
      },
      "z2ui5/devtools/DeveloperTools": DeveloperTools,
      // exit() stops a pick that may still be running (its capture
      // listeners would survive the teardown otherwise)
      "z2ui5/devtools/Picker": {
        stop: (c) => recorderCalls.push(`picker:stop:${c === ctx ? "own" : "other"}`),
      },
      "z2ui5/devtools/Recorder": {
        install: (c) => recorderCalls.push(`install:${c === ctx ? "own" : "other"}`),
        uninstall: (c) =>
          recorderCalls.push(`uninstall:${c === ctx ? "own" : "other"}`),
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
    ctx,
    listeners,
    // the details providers of a context, off its own state
    hooks: (c = ctx) => c.state.onErrorDetails,
    recorderCalls,
    instances,
    consoleUsers,
    raiseError: () => {
      for (const fn of errorSubscribers) fn();
    },
    press: (init) => {
      for (const l of listeners.filter((x) => x.type === "keydown")) l.fn(init);
    },
  };
}

const CTRL_F12 = { ctrlKey: true, key: "F12" };

test.describe("install", () => {
  test("starts the recorder, the shortcut and the error-details provider", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    expect(h.recorderCalls).toEqual(["install:own", "console:install"]);
    expect(h.listeners.filter((l) => l.type === "keydown").length).toBe(1);
    expect(h.hooks().length).toBe(1);
    // ... all of it on the context's own record
    expect(h.ctx.devtools.keydown).toBe(h.listeners[0].fn);
    expect(h.ctx.devtools.errorDetailsHook).toBe(h.hooks()[0]);
    expect(h.ctx.devtools.console).toBe(true);
  });

  test("is idempotent", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.DevTools.install(h.ctx);
    expect(h.listeners.length).toBe(1);
    expect(h.recorderCalls).toEqual(["install:own", "console:install"]);
  });

  test("creates no dialog until it is actually needed", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    // installing must not cost a control - the tools are opened rarely
    expect(h.instances.length).toBe(0);
    expect(h.ctx.devtools.tools).toBe(undefined);
  });

  test("does nothing without a context", () => {
    const h = loadDevTools();
    h.DevTools.install(null);
    h.DevTools.install(undefined);
    expect(h.listeners.length).toBe(0);
    expect(h.recorderCalls).toEqual([]);
  });
});

test.describe("Ctrl+F12", () => {
  test("creates the dialog on first press, with its context, and toggles it after", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(1);
    // the dialog reads everything off `this.ctx`
    expect(h.instances[0].ctx).toBe(h.ctx);
    expect(h.ctx.devtools.tools).toBe(h.instances[0]);
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(2);
  });

  test("ignores other keys", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press({ ctrlKey: true, key: "F11" });
    h.press({ ctrlKey: false, key: "F12" });
    expect(h.instances.length).toBe(0);
  });
});

test.describe("auto open", () => {
  test("stays closed without the parameter", () => {
    const h = loadDevTools({ search: "?app_start=ZCL_X" });
    expect(h.DevTools.isAutoOpenRequested()).toBe(false);
    h.DevTools.install(h.ctx);
    expect(h.instances.length).toBe(0);
  });

  test("=1 opens the default tab", () => {
    const h = loadDevTools({ search: "?z2ui5-devtools=1" });
    expect(h.DevTools.isAutoOpenRequested()).toBe(true);
    expect(h.DevTools.autoOpenTab()).toBe("");
    h.DevTools.install(h.ctx);
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual([undefined]);
  });

  test("a tab key opens that tab, case-insensitively", () => {
    const h = loadDevTools({ search: "?z2ui5-devtools=history" });
    expect(h.DevTools.autoOpenTab()).toBe("HISTORY");
    h.DevTools.install(h.ctx);
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
    h.DevTools.install(h.ctx);
    h.hooks()[0]();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual(["ERROR"]);
    expect(h.instances[0].ctx).toBe(h.ctx);
    // closing the dialog must land the user back on the error popup, not
    // on the dismissed, broken app
    expect(h.instances[0].reopenErrorOnClose).toBe(true);
  });
});

test.describe("open on error", () => {
  // Console only announces an error when its own "open on error" setting
  // is on, so the facade's job is just to open - and to stay out of the
  // way when the dialog is already there.
  test("opens on the merged Log tab when the capture announces an error", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.raiseError();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual(["LOG"]);
  });

  test("does not fight the user for an already open dialog", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    const dialog = h.instances[0];
    dialog.oDialog = { isOpen: () => true };
    h.raiseError();
    expect(dialog.shown).toEqual([]);
  });
});

test.describe("exit", () => {
  test("removes the shortcut, the provider, the dialog and the recorder", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    const dialog = h.instances[0];

    h.DevTools.exit(h.ctx);
    expect(h.listeners.length).toBe(0);
    expect(h.hooks().length).toBe(0);
    expect(dialog.destroyed).toBe(true);
    // picker:stop is part of the teardown: a pick still running at exit
    // would leave its document capture listeners behind - and it is THIS
    // context's pick that is stopped
    expect(h.recorderCalls).toEqual([
      "install:own",
      "console:install",
      "console:uninstall",
      "uninstall:own",
      "picker:stop:own",
    ]);
    // the record is empty again
    expect(h.ctx.devtools.keydown).toBe(null);
    expect(h.ctx.devtools.errorDetailsHook).toBe(null);
    expect(h.ctx.devtools.onConsoleError).toBe(null);
    expect(h.ctx.devtools.tools).toBe(null);
    expect(h.ctx.devtools.console).toBe(false);
  });

  test("a subscriber that left no longer opens the dialog", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.DevTools.exit(h.ctx);
    h.raiseError();
    expect(h.instances.length).toBe(0);
  });

  test("a re-install after exit starts from a fresh dialog", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    h.DevTools.exit(h.ctx);
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(2);
    expect(h.instances[0].destroyed).toBe(true);
    expect(h.instances[1].destroyed).toBe(false);
  });

  test("exit without install is harmless and takes nothing from the console", () => {
    const h = loadDevTools();
    h.DevTools.exit(h.ctx);
    // the per-context teardown is unconditional - the recorder's uninstall
    // is idempotent, so a partially failed install still gets cleaned up -
    // but a use of the page-wide console capture this context never took
    // is not given back either, or it would un-patch it under another
    // context's install
    expect(h.recorderCalls).toEqual(["uninstall:own", "picker:stop:own"]);
    expect(h.consoleUsers.count).toBe(0);
    expect(h.listeners.length).toBe(0);
  });

  test("exit without a context is harmless", () => {
    const h = loadDevTools();
    expect(() => h.DevTools.exit(null)).not.toThrow();
    expect(h.recorderCalls).toEqual([]);
  });
});

test.describe("two components on one page", () => {
  test("each context gets its own tools, and exit of one leaves the other's in place", () => {
    const h = loadDevTools();
    const other = specContext();
    h.DevTools.install(h.ctx);
    h.DevTools.install(other);

    // two shortcuts, two providers, two recorders - each on its own record
    expect(h.listeners.filter((l) => l.type === "keydown").length).toBe(2);
    expect(h.hooks().length).toBe(1);
    expect(h.hooks(other).length).toBe(1);
    expect(h.hooks()[0]).not.toBe(h.hooks(other)[0]);
    expect(h.recorderCalls).toEqual([
      "install:own",
      "console:install",
      "install:other",
      "console:install",
    ]);
    // the page-wide capture is held twice
    expect(h.consoleUsers.count).toBe(2);

    // Ctrl+F12 reaches both, and each gets a dialog of its own context
    h.press(CTRL_F12);
    expect(h.instances.length).toBe(2);
    expect(h.instances.map((i) => i.ctx)).toEqual([h.ctx, other]);
    expect(h.ctx.devtools.tools).toBe(h.instances[0]);
    expect(other.devtools.tools).toBe(h.instances[1]);
    // the Details action of one context opens THAT context's dialog
    h.hooks(other)[0]();
    expect(h.instances[1].shown).toEqual(["ERROR"]);
    expect(h.instances[0].shown).toEqual([]);

    // exit of the second tears down only its own
    h.DevTools.exit(other);
    expect(h.listeners.filter((l) => l.type === "keydown").length).toBe(1);
    expect(h.listeners[0].fn).toBe(h.ctx.devtools.keydown);
    expect(h.hooks().length).toBe(1);
    expect(h.hooks(other).length).toBe(0);
    expect(h.instances[1].destroyed).toBe(true);
    expect(h.instances[0].destroyed).toBe(false);
    expect(h.ctx.devtools.tools).toBe(h.instances[0]);
    expect(other.devtools.tools).toBe(null);
    expect(h.recorderCalls.slice(4)).toEqual([
      "console:uninstall",
      "uninstall:other",
      "picker:stop:other",
    ]);
    // ... and the first still holds its use of the console capture
    expect(h.consoleUsers.count).toBe(1);

    // the first context keeps working
    h.press(CTRL_F12);
    expect(h.instances[0].toggled).toBe(2);
    expect(h.instances.length).toBe(2);
  });
});
