// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/LPTitle.js (obsolete, kept for backward compatibility): sets the FLP
// shell title / full-width mode when running inside the Launchpad, does
// nothing standalone. Under test: the standalone no-op, the toText
// normalization handed to the shell service, async + sync failure logging
// ("log, never throw"), and the suppressed invalidation of the property
// writes (the control renders nothing).
function load({ oLaunchpad = null } = {}) {
  const { Lib } = loadLib();
  const errors = [];
  Lib.logError = (m) => errors.push(m);

  const { module: LPTitleDef } = loadModule("cc/LPTitle.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/AppState": { state: { oLaunchpad } },
    },
  });

  function makeInstance() {
    const inst = Object.create(LPTitleDef);
    inst.propertyWrites = [];
    inst.setProperty = (...args) => inst.propertyWrites.push(args);
    return inst;
  }

  return { makeInstance, errors };
}

const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

test("standalone (no launchpad) both setters are silent no-ops", () => {
  const { makeInstance, errors } = load({ oLaunchpad: null });
  const inst = makeInstance();

  inst.setTitle("My App");
  inst.setApplicationFullWidth(true);

  expect(errors).toHaveLength(0);
  // empty renderer -> the property writes suppress the invalidation
  expect(inst.propertyWrites).toEqual([
    ["title", "My App", true],
    ["ApplicationFullWidth", true, true],
  ]);
});

test("inside the FLP the shell title is set, normalized via toText", () => {
  const titles = [];
  const { makeInstance } = load({
    oLaunchpad: { ShellUIService: { setTitle: (t) => titles.push(t) } },
  });
  const inst = makeInstance();

  inst.setTitle("Orders");
  // never hand undefined/null to the shell service
  inst.setTitle(undefined);
  inst.setTitle(null);

  expect(titles).toEqual(["Orders", "", ""]);
});

test("a shell service without setTitle is tolerated", () => {
  const { makeInstance, errors } = load({
    oLaunchpad: { ShellUIService: {} },
  });
  makeInstance().setTitle("x");

  expect(errors).toHaveLength(0);
});

test("an async setTitle rejection is logged, never unhandled", async () => {
  const { makeInstance, errors } = load({
    oLaunchpad: {
      ShellUIService: { setTitle: () => Promise.reject(new Error("nope")) },
    },
  });
  makeInstance().setTitle("x");
  await tick();

  expect(errors.some((m) => m.includes("setTitle failed"))).toBe(true);
});

test("a synchronously throwing setTitle is logged, never thrown", () => {
  const { makeInstance, errors } = load({
    oLaunchpad: {
      ShellUIService: {
        setTitle: () => {
          throw new Error("shell gone");
        },
      },
    },
  });
  makeInstance().setTitle("x");

  expect(errors.some((m) => m.includes("setTitle failed"))).toBe(true);
});

test("setApplicationFullWidth delegates to the FLP AppConfiguration", () => {
  const widths = [];
  const { makeInstance } = load({
    oLaunchpad: {
      AppConfiguration: { setApplicationFullWidth: (v) => widths.push(v) },
    },
  });
  const inst = makeInstance();

  inst.setApplicationFullWidth(true);
  inst.setApplicationFullWidth(false);

  expect(widths).toEqual([true, false]);
});

test("a throwing AppConfiguration is logged, never thrown", () => {
  const { makeInstance, errors } = load({
    oLaunchpad: {
      AppConfiguration: {
        setApplicationFullWidth: () => {
          throw new Error("no config");
        },
      },
    },
  });
  makeInstance().setApplicationFullWidth(true);

  expect(errors.some((m) => m.includes("setApplicationFullWidth"))).toBe(true);
});
