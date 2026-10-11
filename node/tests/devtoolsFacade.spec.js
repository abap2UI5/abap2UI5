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
//
// The dialog's module is NOT a dependency of the facade: it is in the
// devtools bundle (?z2ui5-bundle=devtools), which the facade loads with a
// <script> element the first time the tools are opened and then reaches
// through sap.ui.require( ). The harness plays the loader: `loaded` is
// what the one-id probe answers, `scripts` the elements appended to the
// head (resolved by the spec: `loadBundle( )` registers the module and
// fires onload), and the async require answers the registered modules.
// Every open is therefore awaited.

function loadDevTools({
  search = "",
  // the dialog's module known to the loader from the start (a BSP that
  // serves it, a page where it was loaded before)
  dialogLoaded = false,
  // what the page is: the backend's own (checkLocal), an embedded
  // component, or a BSP/launchpad page (neither)
  checkLocal = true,
  embedded = false,
  url = "http://localhost:3000/sap/bc/z2ui5?app_start=ZCL_X#/x",
} = {}) {
  const listeners = [];
  const recorderCalls = [];
  const instances = [];
  const errorSubscribers = new Set();
  const consoleUsers = { count: 0 };
  // the loader's modules by id, the <script> elements appended, and the
  // async requires in flight (resolved once their modules are registered)
  const modules = new Map();
  const scripts = [];
  const requires = [];
  const pickerStops = [];

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

  if (dialogLoaded) modules.set("z2ui5/devtools/DeveloperTools", DeveloperTools);
  // the picker, once the bundle is in: exit() stops a pick that may still
  // be running (its capture listeners would survive the teardown otherwise)
  const Picker = {
    stop: (c) => pickerStops.push(`picker:stop:${c === ctx ? "own" : "other"}`),
  };
  const registerBundle = () => {
    modules.set("z2ui5/devtools/DeveloperTools", DeveloperTools);
    modules.set("z2ui5/devtools/Picker", Picker);
  };
  // an async require answers once every module it names is registered;
  // one that names an unknown module fails, the way the loader does for a
  // module the server has no file for
  const settleRequires = () => {
    for (const pending of requires.splice(0)) {
      if (pending.names.every((n) => modules.has(n))) {
        pending.onLoad(...pending.names.map((n) => modules.get(n)));
      } else {
        pending.onError(new Error(`404: ${pending.names.join(",")}`));
      }
    }
  };
  ctx.state.checkLocal = checkLocal;
  ctx.state.embedded = embedded;
  ctx.state.url = url;

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
      "z2ui5/devtools/Recorder": {
        install: (c) => recorderCalls.push(`install:${c === ctx ? "own" : "other"}`),
        uninstall: (c) =>
          recorderCalls.push(`uninstall:${c === ctx ? "own" : "other"}`),
      },
    },
    sandbox: {
      URLSearchParams,
      URL,
      window: { location: { search, href: "http://localhost:3000/sap/bc/z2ui5" } },
      sap: {
        ui: {
          // the one-id probe answers a loaded module synchronously, the
          // array form loads asynchronously
          require: (names, onLoad, onError) => {
            if (typeof names === "string") return modules.get(names);
            requires.push({ names, onLoad, onError });
            return undefined;
          },
        },
      },
      document: {
        addEventListener: (type, fn) => listeners.push({ type, fn }),
        removeEventListener: (type, fn) => {
          const i = listeners.findIndex((l) => l.type === type && l.fn === fn);
          if (i >= 0) listeners.splice(i, 1);
        },
        createElement: (tag) => ({ tag }),
        head: { appendChild: (el) => scripts.push(el) },
      },
    },
  });

  // a tick of the microtask queue, for the promise chain of an open
  const tick = () => new Promise((resolve) => setImmediate(resolve));
  // the bundle arrives: its modules are registered and the script's onload
  // fires - then the require the facade issued settles
  const loadBundle = async (index = scripts.length - 1) => {
    registerBundle();
    scripts[index].onload();
    await tick();
    settleRequires();
    await tick();
  };
  // the bundle could not be fetched
  const failBundle = async (index = scripts.length - 1) => {
    scripts[index].onerror();
    await tick();
    settleRequires();
    await tick();
  };

  return {
    DevTools: module,
    ctx,
    listeners,
    // the details providers of a context, off its own state
    hooks: (c = ctx) => c.state.onErrorDetails,
    recorderCalls,
    pickerStops,
    instances,
    consoleUsers,
    modules,
    scripts,
    requires,
    registerBundle,
    settleRequires,
    loadBundle,
    failBundle,
    tick,
    raiseError: () => {
      for (const fn of errorSubscribers) fn();
    },
    press: (init) => {
      for (const l of listeners.filter((x) => x.type === "keydown")) l.fn(init);
    },
    // Ctrl+F12 with the bundle arriving right after
    open: async () => {
      for (const l of listeners.filter((x) => x.type === "keydown")) l.fn(CTRL_F12);
      await tick();
      if (!modules.has("z2ui5/devtools/DeveloperTools")) await loadBundle();
      await tick();
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

  // An EMBEDDED component runs on a HOST's page: the page-wide capture
  // would take in the host's console output and uncaught errors - measured
  // with the embed-control's host: a host console.error and a host throw
  // landed in the app's capture, and "open on error" opened the app's tools
  // for them. Embedded, the tools install without it.
  test("an embedded component leaves the page's console and errors alone", () => {
    const h = loadDevTools();
    h.ctx.state.embedded = true;
    h.DevTools.install(h.ctx);
    expect(h.recorderCalls).toEqual(["install:own"]);
    expect(h.consoleUsers.count).toBe(0);
    expect(h.ctx.devtools.console).toBeFalsy();
    // a host error the capture would have announced opens nothing
    h.raiseError();
    expect(h.instances).toEqual([]);
    // the rest of the tools are there as on any page
    expect(h.hooks().length).toBe(1);
    expect(h.listeners.filter((l) => l.type === "keydown").length).toBe(1);
    // and the exit gives back nothing it did not take
    h.DevTools.exit(h.ctx);
    expect(h.consoleUsers.count).toBe(0);
    expect(h.recorderCalls).not.toContain("console:uninstall");
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
  test("creates the dialog on first press, with its context, and toggles it after", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    await h.open();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(1);
    // the dialog reads everything off `this.ctx`
    expect(h.instances[0].ctx).toBe(h.ctx);
    expect(h.ctx.devtools.tools).toBe(h.instances[0]);
    await h.open();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(2);
    // one bundle for the page, not one per press
    expect(h.scripts.length).toBe(1);
  });

  test("ignores other keys", () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press({ ctrlKey: true, key: "F11" });
    h.press({ ctrlKey: false, key: "F12" });
    expect(h.instances.length).toBe(0);
    expect(h.scripts.length).toBe(0);
  });
});

// The dialog, the inspectors and the picker are the DEVTOOLS BUNDLE - a
// script the backend serves on ?z2ui5-bundle=devtools, loaded the first
// time the tools are opened (the module header has the reasoning).
test.describe("the devtools bundle", () => {
  test("is loaded from the endpoint on the first open, under the page's parameters", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    expect(h.scripts.length).toBe(0);
    h.press(CTRL_F12);
    await h.tick();
    // a <script> of the backend's origin: the endpoint of the roundtrips,
    // its parameters kept (sap-client, app_start), the hash dropped
    expect(h.scripts.length).toBe(1);
    expect(h.scripts[0].tag).toBe("script");
    expect(h.scripts[0].src).toBe(
      "http://localhost:3000/sap/bc/z2ui5?app_start=ZCL_X&z2ui5-bundle=devtools",
    );
    expect(h.scripts[0].async).toBe(true);
    // nothing required before the bundle is in: on the backend's own page
    // the resource root is the node, which answers a module request with
    // the page
    expect(h.requires.length).toBe(0);
    expect(h.instances.length).toBe(0);
    await h.loadBundle();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].toggled).toBe(1);
  });

  test("a second press while the bundle is loading loads it once", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    h.press(CTRL_F12);
    await h.tick();
    expect(h.scripts.length).toBe(1);
    await h.loadBundle();
    expect(h.instances.length).toBe(1);
    // both presses reached the one dialog
    expect(h.instances[0].toggled).toBe(2);
  });

  test("a dialog module that is loaded already is used as it is", async () => {
    const h = loadDevTools({ dialogLoaded: true });
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    await h.tick();
    expect(h.scripts.length).toBe(0);
    expect(h.requires.length).toBe(0);
    expect(h.instances.length).toBe(1);
  });

  test("an embedded component loads it from its endpoint first, like the backend's page", async () => {
    const h = loadDevTools({
      checkLocal: false,
      embedded: true,
      url: "/dynamic_dest/ABAP2UI5/sap/bc/z2ui5",
    });
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    await h.tick();
    expect(h.scripts.length).toBe(1);
    expect(h.scripts[0].src).toBe(
      "http://localhost:3000/dynamic_dest/ABAP2UI5/sap/bc/z2ui5?z2ui5-bundle=devtools",
    );
    expect(h.requires.length).toBe(0);
    await h.loadBundle();
    expect(h.instances.length).toBe(1);
  });

  test("a BSP or launchpad page requires the module first, and the bundle only when that fails", async () => {
    const h = loadDevTools({ checkLocal: false, url: "/sap/bc/z2ui5" });
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    await h.tick();
    // the BSP serves the module: the require answers, no bundle
    expect(h.requires.length).toBe(1);
    expect(h.scripts.length).toBe(0);
    h.registerBundle();
    h.settleRequires();
    await h.tick();
    expect(h.instances.length).toBe(1);
    expect(h.scripts.length).toBe(0);

    // ...and a page where the module is not to be had falls back to the
    // bundle from the manifest's endpoint
    const g = loadDevTools({ checkLocal: false, url: "/sap/bc/z2ui5" });
    g.DevTools.install(g.ctx);
    g.press(CTRL_F12);
    await g.tick();
    g.settleRequires();
    await g.tick();
    expect(g.scripts.length).toBe(1);
    expect(g.scripts[0].src).toBe(
      "http://localhost:3000/sap/bc/z2ui5?z2ui5-bundle=devtools",
    );
    await g.loadBundle();
    expect(g.instances.length).toBe(1);
  });

  test("a bundle that cannot be loaded is logged, opens nothing, and the next open tries again", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    await h.tick();
    await h.failBundle();
    expect(h.instances.length).toBe(0);
    expect(h.ctx.devtools.loading).toBe(null);
    expect(
      h.ctx.state.errors.some((e) =>
        String(e.message || e).includes("loading the developer tools failed"),
      ),
    ).toBe(true);
    h.press(CTRL_F12);
    await h.tick();
    expect(h.scripts.length).toBe(2);
    await h.loadBundle();
    expect(h.instances.length).toBe(1);
  });

  test("without an endpoint there is nothing to load from - logged, never thrown", async () => {
    const h = loadDevTools({ url: null });
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    await h.tick();
    await h.tick();
    expect(h.scripts.length).toBe(0);
    expect(h.instances.length).toBe(0);
    expect(h.ctx.state.errors.length).toBe(1);
  });

  test("tools torn down while the bundle loads are not created", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.press(CTRL_F12);
    await h.tick();
    h.DevTools.exit(h.ctx);
    await h.loadBundle();
    expect(h.instances.length).toBe(0);
    expect(h.ctx.devtools.tools).toBeFalsy();
  });
});

test.describe("auto open", () => {
  test("stays closed without the parameter", () => {
    const h = loadDevTools({ search: "?app_start=ZCL_X" });
    expect(h.DevTools.isAutoOpenRequested()).toBe(false);
    h.DevTools.install(h.ctx);
    expect(h.instances.length).toBe(0);
  });

  test("=1 opens the default tab", async () => {
    const h = loadDevTools({ search: "?z2ui5-devtools=1" });
    expect(h.DevTools.isAutoOpenRequested()).toBe(true);
    expect(h.DevTools.autoOpenTab()).toBe("");
    h.DevTools.install(h.ctx);
    await h.tick();
    // the bundle is asked for on the page's own URL, with the auto-open
    // parameter still on it - the backend serves the bundle all the same
    expect(h.scripts.length).toBe(1);
    await h.loadBundle();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual([undefined]);
  });

  test("a tab key opens that tab, case-insensitively", async () => {
    const h = loadDevTools({ search: "?z2ui5-devtools=history" });
    expect(h.DevTools.autoOpenTab()).toBe("HISTORY");
    h.DevTools.install(h.ctx);
    await h.tick();
    await h.loadBundle();
    expect(h.instances[0].shown).toEqual(["HISTORY"]);
  });

  test("survives alongside other query parameters", () => {
    const h = loadDevTools({ search: "?app_start=ZCL_X&z2ui5-devtools=ENV" });
    expect(h.DevTools.autoOpenTab()).toBe("ENV");
  });
});

test.describe("error details provider", () => {
  test("opens the Error tab and arms the return to the error popup", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    const opened = h.hooks()[0]();
    await h.tick();
    await h.loadBundle();
    await opened;
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
  test("opens on the merged Log tab when the capture announces an error", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    h.raiseError();
    await h.tick();
    await h.loadBundle();
    expect(h.instances.length).toBe(1);
    expect(h.instances[0].shown).toEqual(["LOG"]);
  });

  test("does not fight the user for an already open dialog", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    await h.open();
    const dialog = h.instances[0];
    dialog.oDialog = { isOpen: () => true };
    h.raiseError();
    expect(dialog.shown).toEqual([]);
  });
});

test.describe("exit", () => {
  test("removes the shortcut, the provider, the dialog and the recorder", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    await h.open();
    const dialog = h.instances[0];

    h.DevTools.exit(h.ctx);
    expect(h.listeners.length).toBe(0);
    expect(h.hooks().length).toBe(0);
    expect(dialog.destroyed).toBe(true);
    expect(h.recorderCalls).toEqual([
      "install:own",
      "console:install",
      "console:uninstall",
      "uninstall:own",
    ]);
    // picker:stop is part of the teardown: a pick still running at exit
    // would leave its document capture listeners behind - and it is THIS
    // context's pick that is stopped. The picker is in the bundle, so it
    // is asked once the bundle is in
    expect(h.pickerStops).toEqual(["picker:stop:own"]);
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

  test("a re-install after exit starts from a fresh dialog", async () => {
    const h = loadDevTools();
    h.DevTools.install(h.ctx);
    await h.open();
    h.DevTools.exit(h.ctx);
    h.DevTools.install(h.ctx);
    await h.open();
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
    expect(h.recorderCalls).toEqual(["uninstall:own"]);
    // the picker is not loaded on a page whose tools never opened - there
    // is no pick to stop
    expect(h.pickerStops).toEqual([]);
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
  test("each context gets its own tools, and exit of one leaves the other's in place", async () => {
    const h = loadDevTools();
    const other = specContext();
    other.state.checkLocal = true;
    other.state.url = h.ctx.state.url;
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

    // Ctrl+F12 reaches both, and each gets a dialog of its own context -
    // the bundle is loaded ONCE for the page: the second context finds the
    // module loaded, or loads it in parallel with the first; here the
    // second press comes while the first load is in flight
    h.press(CTRL_F12);
    await h.tick();
    // one script per context in flight - the loader dedupes the module,
    // the second script re-registers nothing
    const inFlight = h.scripts.length;
    expect(inFlight).toBeGreaterThanOrEqual(1);
    h.registerBundle();
    for (const script of h.scripts) script.onload();
    await h.tick();
    h.settleRequires();
    await h.tick();
    expect(h.instances.length).toBe(2);
    expect(h.instances.map((i) => i.ctx)).toEqual([h.ctx, other]);
    expect(h.ctx.devtools.tools).toBe(h.instances[0]);
    expect(other.devtools.tools).toBe(h.instances[1]);
    // the Details action of one context opens THAT context's dialog
    await h.hooks(other)[0]();
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
    ]);
    expect(h.pickerStops).toEqual(["picker:stop:other"]);
    // ... and the first still holds its use of the console capture
    expect(h.consoleUsers.count).toBe(1);

    // the first context keeps working
    await h.open();
    expect(h.instances[0].toggled).toBe(2);
    expect(h.instances.length).toBe(2);
  });
});
