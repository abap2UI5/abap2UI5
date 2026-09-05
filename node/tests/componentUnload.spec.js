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
// re-launch. The OData clients the framework created for MAIN are module
// state like the timers and the device model: a model is no aggregation, so
// the view's destroy never reaches them, and AppState.reset() only drops the
// inventory - every open client leaked across the re-launch.
function loadForExit(appState) {
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
  });
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
  const appState = {
    state: {
      timers: {},
      shortcuts: {},
      oDeviceModel: null,
      odataClients: new Set([bad, good]),
      oLaunchpad: null,
    },
    reset: () => {},
  };
  const { module: def, sandbox } = loadForExit(appState);
  sandbox.removeEventListener = () => {};
  sandbox.document = { removeEventListener: () => {} };

  const inst = Object.create(def);
  inst._unloadEvent = "pagehide";
  inst._boundUnload = () => {};
  inst._boundScroll = () => {};
  inst._launchpad = null;
  inst.exit();

  // both were asked to go, the failing one did not stop the other
  expect(destroyed).toEqual(["bad", "good"]);
  expect(appState.state.odataClients.size).toBe(0);
});
