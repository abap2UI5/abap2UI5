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
// re-launch, and ONLY what AppState.reset() cannot do itself: reset rebuilds
// the whole state object, so the plain fields are back at their defaults by
// then - but a pending timeout keeps firing, a device model keeps its
// handlers on the Device singleton, and an OData client the framework
// created for MAIN is no aggregation either, so the view's destroy never
// reaches it (every open client leaked across the re-launch).
function loadForExit(appState, { modules = {} } = {}) {
  const noop = () => {};
  return loadModule("Component.js", {
    deps: {
      "sap/ui/core/UIComponent": { extend: (_name, def) => def, prototype: {} },
      "sap/ui/VersionInfo": {},
      "z2ui5/model/models": {},
      "z2ui5/core/Server": { endSession: noop, reset: noop },
      "z2ui5/devtools/DevTools": { exit: noop },
      "z2ui5/core/Lib": { logError: noop },
      "z2ui5/core/AppState": appState,
      "z2ui5/Util": {},
      "z2ui5/model/formatter": {},
      "z2ui5/core/Router": { exit: noop },
      "z2ui5/core/ScrollFocus": { reset: noop },
    },
    // exit() probes for the loaded custom controls that keep module state
    // (cc/Dirty) instead of depending on them - an app that never used one
    // has not loaded it.
    sandbox: { sap: { ui: { require: (name) => modules[name] } } },
  });
}

// The state fields exit() touches, at the defaults AppState.createState()
// gives them - the stub's reset() rebuilds them the way the real one does.
function freshState() {
  return {
    timers: {},
    shortcuts: {},
    oDeviceModel: null,
    odataClients: new Set(),
    oLaunchpad: null,
  };
}

function fakeAppState(overrides = {}) {
  const appState = {
    state: { ...freshState(), ...overrides },
    resets: 0,
    reset() {
      appState.resets += 1;
      appState.state = freshState();
    },
  };
  return appState;
}

function runExit(appState, options) {
  const { module: def, sandbox } = loadForExit(appState, options);
  sandbox.removeEventListener = () => {};
  sandbox.document = { removeEventListener: () => {} };
  const cleared = [];
  sandbox.clearTimeout = (handle) => cleared.push(handle);

  const inst = Object.create(def);
  inst._unloadEvent = "pagehide";
  inst._boundUnload = () => {};
  inst._boundScroll = () => {};
  inst._launchpad = null;
  inst.exit();
  return { inst, cleared };
}

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
  // and the inventory is empty afterwards - through the state rebuild, not
  // through a hand-clear next to it
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

  // what AppState.reset() cannot do: a handle it drops keeps firing, and a
  // device model it drops keeps its handlers on the Device singleton
  expect(cleared.sort()).toEqual([11, 22]);
  expect(destroyed).toEqual(["device"]);
  // ...and what it does do is left to it - the fields are back at their
  // defaults because the state was rebuilt
  expect(appState.state.timers).toEqual({});
  expect(appState.state.shortcuts).toEqual({});
  expect(appState.state.oDeviceModel).toBe(null);
});

test("exit() resets the cc/Dirty unsaved-changes guard when it is loaded", () => {
  // Module state of a custom control: a Dirty instance inside a popup is
  // never destroyed (no teardown path destroys that slot), so its entry -
  // and with it window.onbeforeunload - would survive the component.
  const resets = [];
  runExit(fakeAppState(), {
    modules: { "z2ui5/cc/Dirty": { reset: () => resets.push(true) } },
  });
  expect(resets).toEqual([true]);
});

test("exit() works when no custom control with module state was loaded", () => {
  // sap.ui.require answers undefined for a module the app never used
  const appState = fakeAppState();
  expect(() => runExit(appState)).not.toThrow();
  expect(appState.resets).toBe(1);
});
