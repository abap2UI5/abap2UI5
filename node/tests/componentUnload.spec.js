// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Component.js unload wiring: the teardown must hang off "pagehide", never
// "beforeunload" - destroying the app mid-beforeunload removed the cc/Dirty
// unsaved-changes handler before the browser invoked it (no "leave page?"
// prompt), and killed the live session even when the user chose to stay.
function load() {
  return loadModule("Component.js", {
    deps: {
      "sap/ui/core/UIComponent": { extend: (_name, def) => def },
      "z2ui5/core/ViewSlots": { destroy: () => {} },
      "z2ui5/core/Context": {},
    },
  });
}

test("teardown listens on pagehide, leaving beforeunload to cc/Dirty", () => {
  const { module: def, sandbox } = load();
  const added = [];
  sandbox.addEventListener = (evt, fn) => added.push([evt, fn]);

  const inst = Object.create(def);
  inst._installUnloadListener();

  expect(inst._unloadEvent).toBe("pagehide");
  expect(added.map(([evt]) => evt)).toEqual(["pagehide"]);
});

test("pagehide into the back/forward cache keeps the app alive", () => {
  const { module: def } = load();
  let destroyed = 0;
  const inst = Object.create(def);
  inst.destroy = () => destroyed++;

  inst._onUnload({ persisted: true });
  expect(destroyed).toBe(0);

  inst._onUnload({ persisted: false });
  expect(destroyed).toBe(1);

  inst._onUnload();
  expect(destroyed).toBe(2);
});

// exit() releases what would otherwise outlive the component on an FLP
// re-launch, and ONLY what Context.destroy() cannot do itself: destroy
// rebuilds the whole state object, so the plain fields are back at their
// defaults by then - but a pending timeout keeps firing, a device model
// keeps its handlers on the Device singleton, and an OData client the
// framework created for MAIN is no aggregation either, so the view's
// destroy never reaches it (every open client leaked across the re-launch).
// `fakeContext` below is the context the component works on, with a Context
// stub whose destroy( ) rebuilds the state the way the real one does.
function loadForExit(
  fakeContext,
  {
    modules = {},
    destroyedSlots = [],
    shortcutResets = [],
    sessionResets = [],
  } = {},
) {
  const noop = () => {};
  // exit() cancels the timers through Lib.cancelPendingTimers; the stub does
  // what the shipped helper does (clear every slot) with the sandbox's
  // clearTimeout, so runExit can see which handles were cleared
  let sandboxRef = null;
  const cancelPendingTimers = (ctx) => {
    for (const key of Object.keys(ctx.state.timers)) {
      sandboxRef?.clearTimeout?.(ctx.state.timers[key]);
      delete ctx.state.timers[key];
    }
  };
  const loaded = loadModule("Component.js", {
    deps: {
      "sap/ui/core/UIComponent": { extend: (_name, def) => def, prototype: {} },
      "sap/ui/VersionInfo": {},
      "z2ui5/model/models": {},
      "z2ui5/core/Server": { endSession: noop, reset: noop },
      "z2ui5/core/Session": { reset: () => sessionResets.push(true) },
      "z2ui5/devtools/DevTools": { exit: noop },
      "z2ui5/core/Lib": {
        logError: noop,
        cancelPendingTimers,
        // the shipped isAlive, reduced to the flag a component carries
        isAlive: (obj) => Boolean(obj) && !obj.bIsDestroyed,
      },
      "z2ui5/core/Context": fakeContext.Context,
      "z2ui5/core/Router": { exit: noop },
      "z2ui5/core/ScrollFocus": { reset: noop },
      "z2ui5/core/ViewSlots": {
        destroy: (_ctx, key) => destroyedSlots.push(key),
      },
      "z2ui5/core/actions/Shortcuts": {
        handlers: {},
        reset: () => shortcutResets.push(true),
      },
    },
    // exit() probes for the loaded custom controls that keep module state
    // (cc/Dirty) instead of depending on them - an app that never used one
    // has not loaded it.
    sandbox: { sap: { ui: { require: (name) => modules[name] } } },
  });
  sandboxRef = loaded.sandbox;
  return loaded;
}

// The state fields exit() touches, at the defaults AppState.createState()
// gives them - the stub's destroy() rebuilds them the way the real one does.
function freshState() {
  return {
    timers: {},
    shortcuts: {},
    oDeviceModel: null,
    odataClients: new Set(),
    oLaunchpad: null,
  };
}

// The context the component under test works on, plus the Context stub the
// module loads: destroy( ) counts and rebuilds the state like the real one.
function fakeAppState(overrides = {}) {
  const ctx = { state: { ...freshState(), ...overrides }, alive: true };
  const fake = {
    ctx,
    get state() {
      return ctx.state;
    },
    resets: 0,
    Context: {
      create: () => ctx,
      destroy(c) {
        fake.resets += 1;
        c.alive = false;
        c.state = freshState();
      },
      of: () => ctx,
    },
  };
  return fake;
}

// `prepare(inst, def)` runs on the instance before its exit() - for the
// specs that need something claimed or installed first.
function runExit(appState, options, prepare = () => {}) {
  const destroyedSlots = [];
  const shortcutResets = [];
  const { module: def, sandbox } = loadForExit(appState, {
    ...options,
    destroyedSlots,
    shortcutResets,
  });
  sandbox.removeEventListener = () => {};
  sandbox.document = { removeEventListener: () => {} };
  const cleared = [];
  sandbox.clearTimeout = (handle) => cleared.push(handle);

  const inst = Object.create(def);
  inst.ctx = appState.ctx;
  inst._unloadEvent = "pagehide";
  inst._boundUnload = () => {};
  inst._boundScroll = () => {};
  inst._launchpad = null;
  prepare(inst, def);
  inst.exit();
  return { inst, def, cleared, destroyedSlots, shortcutResets };
}

// Two components on one page: each works on its own context, and the
// teardown of one leaves the other's state alone (the module singleton
// this used to be reset the first instance for the second).
test("exit() tears down its own context only", () => {
  const first = fakeAppState({ timers: { TICK: 1 } });
  const second = fakeAppState({ timers: { POLL: 2 } });
  runExit(first);
  expect(first.resets).toBe(1);
  expect(first.state.timers).toEqual({});
  expect(second.resets).toBe(0);
  expect(second.state.timers).toEqual({ POLL: 2 });
});

test("exit() destroys the OData clients the framework created, a throwing one included", () => {
  const destroyed = [];
  const good = { destroy: () => destroyed.push("good") };
  const bad = {
    destroy: () => {
      destroyed.push("bad");
      throw new Error("already gone");
    },
  };
  const appState = fakeAppState({ odataClients: new Set([bad, good]) });
  runExit(appState);

  // both were asked to go, the failing one did not stop the other
  expect(destroyed).toEqual(["bad", "good"]);
  // and the inventory is empty afterwards - through the state rebuild
  // (Context.destroy), not through a hand-clear next to it
  expect(appState.resets).toBe(1);
  expect(appState.state.odataClients.size).toBe(0);
});

test("exit() cancels the pending timers and destroys the device model", () => {
  const destroyed = [];
  const appState = fakeAppState({
    timers: { TICK: 11, POLL: 22 },
    shortcuts: { CTRL_S: {} },
    oDeviceModel: { destroy: () => destroyed.push("device") },
  });
  const { cleared } = runExit(appState);

  // what Context.destroy() cannot do: a handle it drops keeps firing, and a
  // device model it drops keeps its handlers on the Device singleton
  expect(cleared.sort()).toEqual([11, 22]);
  expect(destroyed).toEqual(["device"]);
  // ...and what it does do is left to it - the fields are back at their
  // defaults because the state was rebuilt
  expect(appState.state.timers).toEqual({});
  expect(appState.state.shortcuts).toEqual({});
  expect(appState.state.oDeviceModel).toBe(null);
});

// The two STANDALONE slots: a popup and a popover are opened outside the
// component's control tree, so nothing in the teardown reached them and the
// dialog of the app that just ended stayed on screen over the one that
// replaced it on an FLP re-launch - with every control inside it still alive,
// none of them having run its exit( ).
test("exit() tears the popup and popover slots down", () => {
  const { destroyedSlots } = runExit(fakeAppState());
  expect(destroyedSlots).toEqual(["POPUP", "POPOVER"]);
});

// The app's keyboard shortcuts: the REGISTRY is app-scoped and the state
// rebuild empties it, but the `document` keydown listener behind it is module
// state in core/actions/Shortcuts and used to stay installed for the life of
// the page - the one addEventListener in app/webapp with no removeEventListener
// anywhere, so on an FLP re-launch it went on running a registry lookup per
// keystroke of whatever came after, and could never be collected.
test("exit() takes the app's keyboard shortcut listener off document", () => {
  const { shortcutResets } = runExit(fakeAppState());
  expect(shortcutResets).toEqual([true]);
});

// The session block's once-per-page-load send latches are module state of
// the same kind (core/Session.js) - an FLP re-launch keeps the page alive,
// so the next app started with the previous one's send state.
test("exit() resets the session block's send latches", () => {
  const sessionResets = [];
  runExit(fakeAppState(), { sessionResets });
  expect(sessionResets).toEqual([true]);
});

test("exit() resets the cc/Dirty unsaved-changes guard when it is loaded", () => {
  // Module state of a custom control: the backstop for a Dirty instance the
  // slot teardown above does not cover - its entry, and with it
  // window.onbeforeunload, would survive the component.
  const resets = [];
  const appState = fakeAppState();
  runExit(appState, {
    modules: { "z2ui5/cc/Dirty": { reset: (ctx) => resets.push(ctx) } },
  });
  // ... and only THIS context's instances: the reset takes it
  expect(resets).toEqual([appState.ctx]);
});

test("exit() works when no custom control with module state was loaded", () => {
  // sap.ui.require answers undefined for a module the app never used
  const appState = fakeAppState();
  expect(() => runExit(appState)).not.toThrow();
  expect(appState.resets).toBe(1);
});
