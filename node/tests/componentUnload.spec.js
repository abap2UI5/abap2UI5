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
