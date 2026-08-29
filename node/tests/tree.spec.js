// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// cc/Tree.js: keeps a sap.m.Tree's expand/collapse state across roundtrips.
// A rebuilt binding starts fully collapsed, so the companion snapshots the
// tree state before every roundtrip and restores it after the next render.
//
// The state lives in AppState.state.treeStates, keyed by tree_id, and that
// is where every rule this spec pins comes from:
//
//  - keyed by tree_id, so a main-view tree and a tree in a popup keep
//    independent snapshots instead of overwriting each other;
//  - a snapshot is only overwritten when the binding is actually resolvable,
//    so a momentarily missing binding cannot wipe a still-valid one;
//  - a restore happens once per (snapshot, binding) pair, because
//    onAfterRendering also runs for a theme or density change and a restore
//    on one of those would collapse the user's own expansions back to the
//    last roundtrip;
//  - setTreeState only seeds an INITIAL state, so refresh(true) is what
//    actually applies it;
//  - resolution goes through ViewSlots.byIdOfOwner, not resolveById, so a
//    same-id tree in another open slot is never picked up;
//  - and every entry point logs rather than throws (AGENTS.md rule 10).
function load({ trees = {}, treeStates = {} } = {}) {
  const errors = [];
  const callbacks = {};
  const lookups = [];

  const { module: TreeDef } = loadModule("cc/Tree.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": {
        logError: (m, e) => errors.push([m, e]),
        renderInvisibleSpan: () => {},
        registerCallback: (name, fn) => {
          (callbacks[name] ??= []).push(fn);
        },
        unregisterCallback: (name, fn) => {
          const list = callbacks[name] ?? [];
          const at = list.indexOf(fn);
          if (at !== -1) list.splice(at, 1);
        },
        hookCallback(owner, name, method) {
          const bound = owner[method].bind(owner);
          this.registerCallback(name, bound);
          return () => this.unregisterCallback(name, bound);
        },
      },
      "z2ui5/core/ViewSlots": {
        byIdOfOwner: (owner, id) => {
          lookups.push([owner, id]);
          return trees[id] ?? null;
        },
      },
      "z2ui5/core/AppState": { state: { treeStates } },
    },
  });

  function instance(tree_id) {
    const inst = Object.create(TreeDef);
    inst._props = { tree_id };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    return inst;
  }

  return { instance, errors, callbacks, treeStates, lookups };
}

// A tree binding recording what was done to it, and the sap.m.Tree that
// exposes it under the "items" aggregation.
function makeBinding(state = null) {
  const calls = [];
  return {
    calls,
    getCurrentTreeState: () => ({ of: state }),
    setTreeState: (s) => calls.push(["setTreeState", s]),
    refresh: (force) => calls.push(["refresh", force]),
  };
}

function makeTree(binding) {
  return { getBinding: (name) => (name === "items" ? binding : null) };
}

test("init registers the onBeforeRoundtrip hook, exit removes it", () => {
  const { instance, callbacks } = load();
  const inst = instance("tree1");

  inst.init();
  expect(callbacks.onBeforeRoundtrip).toHaveLength(1);

  inst.exit();
  expect(callbacks.onBeforeRoundtrip).toHaveLength(0);
});

test("exit removes only this instance's hook", () => {
  const { instance, callbacks } = load();
  const a = instance("t1");
  const b = instance("t2");

  a.init();
  b.init();
  a.exit();

  expect(callbacks.onBeforeRoundtrip).toHaveLength(1);
});

test("setBackend snapshots the tree state under the tree_id", () => {
  const l = load({ trees: { tbl: makeTree(makeBinding("expanded")) } });

  l.instance("tbl").setBackend();

  expect(Object.keys(l.treeStates)).toEqual(["tbl"]);
  expect(l.treeStates.tbl).toEqual({ of: "expanded" });
});

// Two companions on one page must not share one slot.
test("two trees keep independent snapshots", () => {
  const l = load({
    trees: { a: makeTree(makeBinding("one")), b: makeTree(makeBinding("two")) },
  });

  l.instance("a").setBackend();
  l.instance("b").setBackend();

  expect(l.treeStates.a.of).toBe("one");
  expect(l.treeStates.b.of).toBe("two");
});

// byIdOfOwner and not resolveById: the companion has to resolve the tree in
// its OWN slot, or a dialog's tree and a main-view tree sharing an id would
// resolve to whichever slot answered first.
test("the tree is looked up in the companion's own slot", () => {
  const l = load({ trees: { tbl: makeTree(makeBinding()) } });
  const inst = l.instance("tbl");

  inst.setBackend();

  expect(l.lookups).toEqual([[inst, "tbl"]]);
});

test("an unresolvable binding leaves a still-valid snapshot alone", () => {
  const l = load({ trees: {}, treeStates: { tbl: { kept: true } } });

  l.instance("tbl").setBackend();

  expect(l.treeStates.tbl).toEqual({ kept: true });
});

test("an empty tree_id snapshots nothing", () => {
  const l = load({ treeStates: {} });

  l.instance("").setBackend();

  expect(l.treeStates).toEqual({});
});

test("a throwing binding is logged, not propagated", () => {
  const boom = new Error("gone");
  const tree = {
    getBinding: () => ({
      getCurrentTreeState: () => {
        throw boom;
      },
    }),
  };
  const l = load({ trees: { tbl: tree } });

  expect(() => l.instance("tbl").setBackend()).not.toThrow();
  expect(l.errors[0][0]).toContain("Tree.setBackend");
  expect(l.errors[0][1]).toBe(boom);
});

test("onAfterRendering seeds the snapshot and forces a rebuild", () => {
  const binding = makeBinding();
  const snapshot = { expanded: [1, 2] };
  const l = load({ trees: { tbl: makeTree(binding) }, treeStates: { tbl: snapshot } });

  l.instance("tbl").onAfterRendering();

  // setTreeState only stores an INITIAL state - the adapter has already
  // built its nodes by now, so refresh(true) is what applies it.
  expect(binding.calls).toEqual([
    ["setTreeState", snapshot],
    ["refresh", true],
  ]);
});

// A theme change, a density change or a parent invalidation all re-render
// this control. Restoring on one of those would throw away every expansion
// the user made since the last roundtrip.
test("a second rendering with the same snapshot and binding restores nothing", () => {
  const binding = makeBinding();
  const l = load({ trees: { tbl: makeTree(binding) }, treeStates: { tbl: { a: 1 } } });
  const inst = l.instance("tbl");

  inst.onAfterRendering();
  const after = binding.calls.length;
  inst.onAfterRendering();

  expect(binding.calls).toHaveLength(after);
});

test("a fresh snapshot restores again", () => {
  const binding = makeBinding();
  const l = load({ trees: { tbl: makeTree(binding) }, treeStates: { tbl: { a: 1 } } });
  const inst = l.instance("tbl");

  inst.onAfterRendering();
  // setBackend builds a NEW object every roundtrip, which is what makes a
  // roundtrip distinguishable from a re-render.
  l.treeStates.tbl = { a: 2 };
  inst.onAfterRendering();

  expect(binding.calls).toHaveLength(4);
  expect(binding.calls[2]).toEqual(["setTreeState", { a: 2 }]);
});

test("a rebuilt binding restores again, even with the same snapshot", () => {
  const snapshot = { a: 1 };
  const trees = { tbl: makeTree(makeBinding()) };
  const l = load({ trees, treeStates: { tbl: snapshot } });
  const inst = l.instance("tbl");

  inst.onAfterRendering();
  const second = makeBinding();
  trees.tbl = makeTree(second);
  inst.onAfterRendering();

  expect(second.calls).toEqual([
    ["setTreeState", snapshot],
    ["refresh", true],
  ]);
});

test("no snapshot, no binding, no tree_id: nothing happens and nothing throws", () => {
  const binding = makeBinding();

  // no snapshot for this id
  const a = load({ trees: { tbl: makeTree(binding) }, treeStates: {} });
  a.instance("tbl").onAfterRendering();
  expect(binding.calls).toEqual([]);

  // snapshot but no resolvable binding
  const b = load({ trees: {}, treeStates: { tbl: { a: 1 } } });
  expect(() => b.instance("tbl").onAfterRendering()).not.toThrow();
  expect(b.errors).toEqual([]);

  // no tree_id at all
  const c = load({ trees: {}, treeStates: { tbl: { a: 1 } } });
  expect(() => c.instance("").onAfterRendering()).not.toThrow();
});

test("a throwing setTreeState is logged, not propagated", () => {
  const boom = new Error("no adapter");
  const tree = {
    getBinding: () => ({
      setTreeState: () => {
        throw boom;
      },
    }),
  };
  const l = load({ trees: { tbl: tree }, treeStates: { tbl: { a: 1 } } });

  expect(() => l.instance("tbl").onAfterRendering()).not.toThrow();
  expect(l.errors[0][0]).toContain("Tree.onAfterRendering");
  expect(l.errors[0][1]).toBe(boom);
});
