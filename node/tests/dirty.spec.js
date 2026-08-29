// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/Dirty.js: the FLP dirty flag and window.onbeforeunload are single global
// slots shared by every instance - the guard must reflect whether ANY
// instance is dirty.
function load({ oLaunchpad = null } = {}) {
  const { module: Dirty, sandbox } = loadModule("cc/Dirty.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": { logError() {} },
      "z2ui5/core/AppState": { state: { oLaunchpad } },
    },
  });
  const instance = () => {
    const inst = Object.create(Dirty);
    inst.setProperty = () => {};
    return inst;
  };
  return { instance, sandbox };
}

test("standalone: prompt stays while ANY instance is dirty", () => {
  const { instance, sandbox } = load();
  const a = instance();
  const b = instance();

  a.setIsDirty(true);
  b.setIsDirty(true);
  expect(typeof sandbox.window.onbeforeunload).toBe("function");

  a.setIsDirty(false);
  expect(typeof sandbox.window.onbeforeunload).toBe("function");

  b.setIsDirty(false);
  expect(sandbox.window.onbeforeunload).toBe(null);
});

test("standalone: the prompt handler cancels the event", () => {
  const { instance, sandbox } = load();
  instance().setIsDirty(true);

  let prevented = 0;
  const event = { preventDefault: () => prevented++, returnValue: "x" };
  sandbox.window.onbeforeunload(event);
  expect(prevented).toBe(1);
  expect(event.returnValue).toBe("");
});

test("exit() clears only this instance's dirty mark", () => {
  const { instance, sandbox } = load();
  const a = instance();
  const b = instance();
  a.setIsDirty(true);
  b.setIsDirty(true);

  a.exit();
  expect(typeof sandbox.window.onbeforeunload).toBe("function");

  b.exit();
  expect(sandbox.window.onbeforeunload).toBe(null);
});

test("FLP: uses setDirtyFlag when Container AND ShellUIService exist", () => {
  const calls = [];
  const { instance, sandbox } = load({
    oLaunchpad: {
      Container: { setDirtyFlag: (v) => calls.push(v) },
      ShellUIService: {},
    },
  });

  const inst = instance();
  inst.setIsDirty(true);
  expect(calls).toEqual([true]);
  // The FLP branch actively CLEARS the unload prompt (null, not left
  // untouched): ShellUIService arrives asynchronously, so an earlier
  // setIsDirty(true) may have taken the standalone branch and armed the
  // prompt - without the clear the FLP user keeps answering "leave page?"
  // for a dirty state that is long gone.
  expect(sandbox.window.onbeforeunload).toBe(null);

  inst.setIsDirty(false);
  expect(calls).toEqual([true, false]);
});

test("FLP: falls back to the browser prompt when setDirtyFlag throws", () => {
  const { instance, sandbox } = load({
    oLaunchpad: {
      Container: {
        setDirtyFlag: () => {
          throw new Error("shell gone");
        },
      },
      ShellUIService: {},
    },
  });

  instance().setIsDirty(true);
  expect(typeof sandbox.window.onbeforeunload).toBe("function");
});
