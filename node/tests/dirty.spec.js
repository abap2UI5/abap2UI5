// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/Dirty.js: the FLP dirty flag and the browser's beforeunload prompt are
// single global slots shared by every instance - the guard must reflect
// whether ANY instance is dirty.
// The prompt is a beforeunload LISTENER (added and removed, never assigned
// to window.onbeforeunload, which would overwrite a host page's handler);
// `listeners` is what the page has installed, `adds`/`removes` count the
// calls so a spec can see that one listener serves every instance.
function load({ oLaunchpad = null } = {}) {
  const listeners = new Set();
  const adds = [];
  const removes = [];
  const { module: Dirty, sandbox } = loadModule("cc/Dirty.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": { logError() {} },
      "z2ui5/core/AppState": { state: { oLaunchpad } },
    },
    sandbox: {
      addEventListener: (type, fn) => {
        adds.push(type);
        listeners.add(fn);
      },
      removeEventListener: (type, fn) => {
        removes.push(type);
        listeners.delete(fn);
      },
    },
  });
  const instance = () => {
    const inst = Object.create(Dirty);
    inst.setProperty = () => {};
    return inst;
  };
  // the prompt is armed while exactly one listener is installed
  const armed = () => listeners.size;
  const prompt = () => [...listeners][0];
  return { Dirty, instance, sandbox, armed, prompt, adds, removes };
}

test("standalone: prompt stays while ANY instance is dirty", () => {
  const { instance, armed, prompt } = load();
  const a = instance();
  const b = instance();

  a.setIsDirty(true);
  b.setIsDirty(true);
  expect(armed()).toBe(1);

  a.setIsDirty(false);
  expect(armed()).toBe(1);

  b.setIsDirty(false);
  expect(armed()).toBe(0);
});

test("standalone: the prompt handler cancels the event", () => {
  const { instance, armed, prompt } = load();
  instance().setIsDirty(true);

  let prevented = 0;
  const event = { preventDefault: () => prevented++, returnValue: "x" };
  prompt()(event);
  expect(prevented).toBe(1);
  expect(event.returnValue).toBe("");
});

test("exit() clears only this instance's dirty mark", () => {
  const { instance, armed, prompt } = load();
  const a = instance();
  const b = instance();
  a.setIsDirty(true);
  b.setIsDirty(true);

  a.exit();
  expect(armed()).toBe(1);

  b.exit();
  expect(armed()).toBe(0);
});

test("FLP: uses setDirtyFlag when Container AND ShellUIService exist", () => {
  const calls = [];
  const { instance, armed, prompt } = load({
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
  expect(armed()).toBe(0);

  inst.setIsDirty(false);
  expect(calls).toEqual([true, false]);
});

test("FLP: falls back to the browser prompt when setDirtyFlag throws", () => {
  const { instance, armed, prompt } = load({
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
  expect(armed()).toBe(1);
});

// The set is module state and an instance only leaves it through its own
// exit( ) - which a control inside a popup/popover never runs, because no
// teardown path destroys those slots. Component.exit calls this so the
// unload prompt cannot outlive the app that raised it.
test("reset() drops every mark and the prompt with it", () => {
  const { Dirty, instance, armed } = load();
  // the instance a popup carries: nothing ever destroys it, so its own
  // exit( ) never runs
  instance().setIsDirty(true);
  expect(armed()).toBe(1);

  Dirty.reset();

  expect(armed()).toBe(0);
  // a fresh instance starts from an empty set, not from the old mark
  instance().setIsDirty(false);
  expect(armed()).toBe(0);
});

// One listener per page, not one per dirty transition: the flag in the
// control keeps a second add (and a stray remove) off the event target, and
// the listener is REMOVED - never replaced by an assignment of null, which
// would take a host page's own beforeunload handler down with it.
test("standalone: one listener is added once and removed once", () => {
  const { instance, adds, removes, armed } = load();
  const a = instance();
  const b = instance();

  a.setIsDirty(true);
  b.setIsDirty(true);
  a.setIsDirty(true);
  expect(adds).toEqual(["beforeunload"]);
  expect(removes).toEqual([]);

  a.setIsDirty(false);
  b.setIsDirty(false);
  b.setIsDirty(false);
  expect(removes).toEqual(["beforeunload"]);
  expect(armed()).toBe(0);
});
