// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext, contextStub } = require("./loadLibModule");

// cc/Dirty.js: the FLP dirty flag and the browser's beforeunload prompt are
// single global slots shared by every instance - the guard must reflect
// whether ANY instance is dirty, across every component on the page.
// The prompt is a beforeunload LISTENER (added and removed, never assigned
// to window.onbeforeunload, which would overwrite a host page's handler);
// `listeners` is what the page has installed, `adds`/`removes` count the
// calls so a spec can see that one listener serves every instance.
// The launchpad record is read from the instance's own component context
// (Context.of): `ctx` is the spec's component, and an instance answers it
// unless it was created with a context of its own - another component's
// (specContext( )), or null for a control in no component at all.
function load({ oLaunchpad = null } = {}) {
  const listeners = new Set();
  const adds = [];
  const removes = [];
  const ctx = specContext({ oLaunchpad });
  const Context = {
    ...contextStub(ctx),
    of: (inst) => ("ctx" in inst ? inst.ctx : ctx),
  };
  const { module: Dirty, sandbox } = loadModule("cc/Dirty.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": { logError() {} },
      "z2ui5/core/Context": Context,
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
  // `own`: the instance's context when it is not the spec's - another
  // component's, or null for "in no component"
  const instance = (own) => {
    const inst = Object.create(Dirty);
    inst.setProperty = () => {};
    if (own !== undefined) inst.ctx = own;
    return inst;
  };
  // the prompt is armed while exactly one listener is installed
  const armed = () => listeners.size;
  const prompt = () => [...listeners][0];
  return { Dirty, instance, sandbox, armed, prompt, adds, removes, ctx };
}

test("standalone: prompt stays while ANY instance is dirty", () => {
  const { instance, armed } = load();
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
  const { instance, prompt } = load();
  instance().setIsDirty(true);

  let prevented = 0;
  const event = { preventDefault: () => prevented++, returnValue: "x" };
  prompt()(event);
  expect(prevented).toBe(1);
  expect(event.returnValue).toBe("");
});

test("exit() clears only this instance's dirty mark", () => {
  const { instance, armed } = load();
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
  const { instance, armed } = load({
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
  const { instance, armed } = load({
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
// teardown path destroys those slots. Component.exit calls this with its
// context so the unload prompt cannot outlive the app that raised it.
test("reset(ctx) drops every mark of that context and the prompt with it", () => {
  const { Dirty, instance, armed, ctx } = load();
  // the instance a popup carries: nothing ever destroys it, so its own
  // exit( ) never runs
  instance().setIsDirty(true);
  expect(armed()).toBe(1);

  Dirty.reset(ctx);

  expect(armed()).toBe(0);
  // a fresh instance starts from an empty set, not from the old mark
  instance().setIsDirty(false);
  expect(armed()).toBe(0);
});

// Two components on one page (a launchpad in keep-alive mode): the
// teardown of one must not wipe the unsaved-changes guard of the other.
test("reset(ctx) leaves another component's instance alone", () => {
  const { Dirty, instance, armed, ctx } = load();
  const other = specContext();
  instance().setIsDirty(true);
  instance(other).setIsDirty(true);

  Dirty.reset(ctx);
  expect(armed()).toBe(1);

  Dirty.reset(other);
  expect(armed()).toBe(0);
});

test("reset(ctx) re-syncs the FLP flag from what remains", () => {
  const calls = [];
  const oLaunchpad = {
    Container: { setDirtyFlag: (v) => calls.push(v) },
    ShellUIService: {},
  };
  const { Dirty, instance, ctx } = load({ oLaunchpad });
  // the FLP container is a page singleton - the second component sees
  // the same one
  const other = specContext({ oLaunchpad });
  instance().setIsDirty(true);
  instance(other).setIsDirty(true);
  expect(calls).toEqual([true, true]);

  // the other component's mark keeps the flag up ...
  Dirty.reset(ctx);
  expect(calls).toEqual([true, true, true]);

  // ... and only the last one down takes it down
  Dirty.reset(other);
  expect(calls).toEqual([true, true, true, false]);
});

// A control in no component (Context.of answers null) knows of no
// launchpad and takes the browser prompt: the standalone behaviour, even
// while a component on the page runs inside the FLP.
test("an instance in no component takes the browser prompt", () => {
  const calls = [];
  const { instance, armed } = load({
    oLaunchpad: {
      Container: { setDirtyFlag: (v) => calls.push(v) },
      ShellUIService: {},
    },
  });

  instance(null).setIsDirty(true);

  expect(armed()).toBe(1);
  expect(calls).toEqual([]);
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
