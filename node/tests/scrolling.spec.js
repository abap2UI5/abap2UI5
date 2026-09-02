// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/Scrolling.js (obsolete, kept for backward compatibility): saves the
// scroll positions of the listed controls into the model before each
// roundtrip and restores them after rendering. Under test: the capture path
// (delegate preferred over DOM, changed entries marked dirty on the
// control's own model), the restore path (scrollTo preferred over DOM), and
// the "log, never throw" guards.
function load({ controls = {}, domElements = {} } = {}) {
  const { Lib, sandbox } = loadLib();
  const errors = [];
  Lib.logError = (m) => errors.push(m);

  const { module: ScrollingDef } = loadModule("cc/Scrolling.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": {
        byIdOfOwner: (_owner, id) => controls[id] ?? null,
        // mirrors the real resolver (core/ViewSlots.js): only a model
        // carrying the _z2ui5Tracked marker is the framework's
        trackedModel: (owner) => {
          const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
          if (!owner?.getModel) return undefined;
          return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
        },
      },
    },
    sandbox: {
      document: { getElementById: (id) => domElements[id] || null },
    },
  });

  function makeInstance(props = {}) {
    const inst = Object.create(ScrollingDef);
    inst._props = { setUpdate: true, items: null, ...props };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    return inst;
  }

  return { makeInstance, errors, state: sandbox.z2ui5 };
}

test("init registers the onBeforeRoundtrip hook, exit removes it", () => {
  const { makeInstance, state } = load();
  const inst = makeInstance();

  inst.init();
  expect(state.onBeforeRoundtrip).toHaveLength(1);

  inst.exit();
  expect(state.onBeforeRoundtrip).toHaveLength(0);
});

test("setBackend captures via the scroll delegate and marks the delta path", () => {
  const { makeInstance } = load({
    controls: {
      tbl: { getScrollDelegate: () => ({ getScrollTop: () => 42 }) },
    },
  });
  const items = [{ N: "tbl", V: 0 }];
  const changed = new Set();
  const inst = makeInstance({ items });
  inst.getBindingInfo = () => ({ path: "/SCROLL" });
  inst.getModel = () => ({ _z2ui5Tracked: true, _z2ui5ChangedPaths: changed });

  inst.setBackend();

  expect(items[0].V).toBe(42);
  expect([...changed]).toEqual(["/SCROLL/0/V"]);
});

test("an unchanged position is not marked dirty", () => {
  const { makeInstance } = load({
    controls: {
      tbl: { getScrollDelegate: () => ({ getScrollTop: () => 10 }) },
    },
  });
  const changed = new Set();
  const inst = makeInstance({ items: [{ N: "tbl", V: 10 }] });
  inst.getBindingInfo = () => ({ path: "/SCROLL" });
  inst.getModel = () => ({ _z2ui5Tracked: true, _z2ui5ChangedPaths: changed });

  inst.setBackend();

  expect(changed.size).toBe(0);
});

test("without a delegate the -inner DOM element is read", () => {
  const { makeInstance } = load({
    controls: { box: { getId: () => "box" } },
    domElements: { "box-inner": { scrollTop: 7 } },
  });
  const items = [{ N: "box", V: 0 }];
  const inst = makeInstance({ items });
  inst.getBindingInfo = () => undefined;
  inst.getModel = () => undefined;

  inst.setBackend();

  expect(items[0].V).toBe(7);
});

test("an unresolvable control captures 0; no items is a no-op", () => {
  const { makeInstance } = load();
  const items = [{ N: "gone", V: 5 }];
  const inst = makeInstance({ items });
  inst.getBindingInfo = () => undefined;
  inst.getModel = () => undefined;

  inst.setBackend();
  expect(items[0].V).toBe(0);

  makeInstance({ items: null }).setBackend();
});

test("a throwing delegate is logged and captured as 0, never thrown", () => {
  const { makeInstance, errors } = load({
    controls: {
      bad: {
        getScrollDelegate: () => {
          throw new Error("gone");
        },
      },
    },
  });
  const items = [{ N: "bad", V: 3 }];
  const inst = makeInstance({ items });
  inst.getBindingInfo = () => undefined;
  inst.getModel = () => undefined;

  inst.setBackend();

  expect(items[0].V).toBe(0);
  expect(errors.some((m) => m.includes("_getScrollTop"))).toBe(true);
});

test("the renderer arms one restore pass and disarms setUpdate", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const oRm = {
    openStart: () => oRm,
    style: () => oRm,
    openEnd: () => oRm,
    close: () => oRm,
  };

  ScrollingRendererOf(inst).render(oRm, inst);

  expect(inst._pendingScroll).toBe(true);
  expect(inst._props.setUpdate).toBe(false);

  // second render with setUpdate=false must not re-arm
  inst._pendingScroll = false;
  ScrollingRendererOf(inst).render(oRm, inst);
  expect(inst._pendingScroll).toBe(false);

  function ScrollingRendererOf(instance) {
    return Object.getPrototypeOf(instance).renderer;
  }
});

test("a control with a scroll delegate is restored through it, both axes", () => {
  // sap.m.ScrollContainer.scrollTo(x, y) - the vertical position handed
  // in as x scrolled the container sideways; the delegate (which is also
  // where the position was read) takes x and y explicitly
  const calls = [];
  const delegate = {
    getScrollTop: () => 0,
    getScrollLeft: () => 17,
    scrollTo: (x, y) => calls.push([x, y]),
  };
  const { makeInstance } = load({
    controls: {
      box: {
        getScrollDelegate: () => delegate,
        scrollTo: (x) => calls.push(["control", x]),
        getDomRef: () => ({}),
        getId: () => "box",
      },
    },
  });
  const inst = makeInstance({ items: [{ N: "box", V: 300 }] });
  inst._pendingScroll = true;
  inst.onAfterRendering();
  expect(calls).toEqual([[17, 300]]);
});

test("onAfterRendering restores via scrollTo when available, else the DOM", () => {
  const scrolled = [];
  const { makeInstance } = load({
    controls: {
      tbl: {
        scrollTo: (v) => scrolled.push(v),
        getDomRef: () => ({}),
        getId: () => "tbl",
      },
      box: { getDomRef: () => ({}), getId: () => "box" },
    },
    domElements: { "box-inner": { scrollTop: 0 } },
  });
  const inst = makeInstance({
    items: [
      { N: "tbl", V: 42 },
      { N: "box", V: 9 },
    ],
  });
  inst._pendingScroll = true;

  inst.onAfterRendering();

  expect(scrolled).toEqual([42]);
  // second pass without a new render is a no-op
  inst.onAfterRendering();
  expect(scrolled).toEqual([42]);
});

test("restore skips unresolvable controls and survives throwing ones", () => {
  const { makeInstance, errors } = load({
    controls: {
      bad: {
        getDomRef: () => ({}),
        scrollTo() {
          throw new Error("detached");
        },
        getId: () => "bad",
      },
    },
  });
  const inst = makeInstance({
    items: [
      { N: "gone", V: 1 },
      { N: "bad", V: 2 },
    ],
  });
  inst._pendingScroll = true;

  inst.onAfterRendering();

  expect(errors.some((m) => m.includes("_restoreScrollPosition"))).toBe(true);
});
