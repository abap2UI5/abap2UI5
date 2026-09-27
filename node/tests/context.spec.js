// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/Context.js - one context per
// z2ui5.Component, and how a module finds it (Context.of): a controller
// carries it, the component maps to it, a control resolves it through its
// owner component or its parent chain up to a slot view. Two contexts on
// one page share nothing; a destroyed one reads dead and holds nothing.

function load({ owners = new Map() } = {}) {
  // sap.ui.require answers the Component module lazily (no define
  // dependency, so this spec needs no stub for the module load itself);
  // `owners` is the registry Component.getOwnerComponentFor reads
  const Component = {
    getOwnerComponentFor: (control) => owners.get(control) || null,
  };
  const { module: Context } = loadModule("core/Context.js", {
    // core/AppState.js (createState) loads for real
    autoLoad: true,
    sandbox: {
      sap: { ui: { require: (id) => (id === "sap/ui/core/Component" ? Component : null) } },
    },
  });
  return { Context, owners };
}

function component(id) {
  return { getId: () => id, runAsOwner: (fn) => fn() };
}

test.describe("create", () => {
  test("two components get two contexts that share no state", () => {
    const { Context } = load();
    const a = Context.create(component("a"));
    const b = Context.create(component("b"));
    expect(a).not.toBe(b);
    expect(a.id).toBe("a");
    expect(b.id).toBe("b");
    a.state.isBusy = true;
    a.state.timers.TICK = 1;
    a.server.requestSeq = 5;
    expect(b.state.isBusy).toBe(false);
    expect(b.state.timers).toEqual({});
    expect(b.server.requestSeq).toBe(0);
    expect(a.alive).toBe(true);
  });

  test("carries every per-module record with its defaults", () => {
    const { Context } = load();
    const ctx = Context.create(component("a"));
    expect(ctx.server).toEqual({ requestSeq: 0, inflight: new Set(), viewBuild: null });
    expect(ctx.session).toEqual({
      configSent: false,
      liveSent: "",
      pending: null,
      locationSent: false,
    });
    expect(ctx.router).toEqual({ navigate: null, hashListener: null });
    expect(ctx.shortcuts).toEqual({ listener: null });
    expect(ctx.variants).toEqual({ activeInits: new Set() });
    expect(ctx.scroll).toEqual({ target: undefined, ui5El: undefined, slotKey: undefined });
    expect(ctx.errorView).toEqual({ title: "", details: "", options: {}, dialog: null });
    expect(ctx.devtools).toEqual({});
  });

  test("works without a component (the specs, a bare bootstrap)", () => {
    const { Context } = load();
    const ctx = Context.create(undefined);
    expect(ctx.component).toBeNull();
    expect(ctx.id).toBe("");
    expect(ctx.state.oView).toBeNull();
  });
});

test.describe("of", () => {
  test("a controller carries the context", () => {
    const { Context } = load();
    const ctx = Context.create(component("a"));
    const controller = { ctx };
    expect(Context.of(controller)).toBe(ctx);
  });

  test("the component maps to its own context", () => {
    const { Context } = load();
    const comp = component("a");
    const ctx = Context.create(comp);
    expect(Context.of(comp)).toBe(ctx);
  });

  test("a control resolves through its owner component", () => {
    const { Context, owners } = load();
    const comp = component("a");
    const ctx = Context.create(comp);
    const control = { getParent: () => null };
    owners.set(control, comp);
    expect(Context.of(control)).toBe(ctx);
  });

  test("a control without an owner walks its parents up to a slot view", () => {
    const { Context } = load();
    const ctx = Context.create(component("a"));
    const view = { getParent: () => null };
    Context.registerView(ctx, view);
    const box = { getParent: () => view };
    const control = { getParent: () => box };
    expect(Context.of(control)).toBe(ctx);
  });

  test("answers null for nothing, a primitive, and a control in no component", () => {
    const { Context } = load();
    Context.create(component("a"));
    expect(Context.of(null)).toBeNull();
    expect(Context.of(undefined)).toBeNull();
    expect(Context.of("id")).toBeNull();
    expect(Context.of({ getParent: () => null })).toBeNull();
  });

  test("never loops on a cyclic parent chain", () => {
    const { Context } = load();
    const a = { getParent: () => b };
    const b = { getParent: () => a };
    expect(Context.of(a)).toBeNull();
  });

  test("an owner the registry does not know falls through to the parent walk", () => {
    const { Context, owners } = load();
    const ctx = Context.create(component("a"));
    const view = { getParent: () => null };
    Context.registerView(ctx, view);
    const control = { getParent: () => view };
    owners.set(control, component("stranger"));
    expect(Context.of(control)).toBe(ctx);
  });
});

test.describe("destroy", () => {
  test("marks the context dead, rebuilds its state and unmaps the component", () => {
    const { Context } = load();
    const comp = component("a");
    const ctx = Context.create(comp);
    const controller = { ctx };
    ctx.state.oController = controller;
    ctx.state.oView = { destroyed: false };

    Context.destroy(ctx);

    expect(ctx.alive).toBe(false);
    expect(ctx.state.oController).toBeNull();
    expect(ctx.state.oView).toBeNull();
    expect(Context.of(comp)).toBeNull();
    // the controller still points at the (dead) context - which is what
    // Lib.isControllerAlive reads as "dead"
    expect(Context.of(controller)).toBe(ctx);
  });

  test("tolerates nothing to destroy", () => {
    const { Context } = load();
    expect(() => Context.destroy(null)).not.toThrow();
  });

  test("a component relaunched after its teardown gets a fresh context", () => {
    const { Context } = load();
    const comp = component("a");
    const first = Context.create(comp);
    Context.destroy(first);
    const second = Context.create(comp);
    expect(second).not.toBe(first);
    expect(Context.of(comp)).toBe(second);
  });
});

test.describe("runAsOwner", () => {
  test("runs the function under the component as owner", () => {
    const { Context } = load();
    const ran = [];
    const comp = {
      getId: () => "a",
      runAsOwner: (fn) => {
        ran.push("owner");
        return fn();
      },
    };
    const ctx = Context.create(comp);
    expect(Context.runAsOwner(ctx, () => "built")).toBe("built");
    expect(ran).toEqual(["owner"]);
  });

  test("runs the function plainly without a component", () => {
    const { Context } = load();
    const ctx = Context.create(undefined);
    expect(Context.runAsOwner(ctx, () => "built")).toBe("built");
    expect(Context.runAsOwner(null, () => "built")).toBe("built");
  });
});
