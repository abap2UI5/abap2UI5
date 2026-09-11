// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// The rendering and timer helpers of app/webapp/core/Lib.js that the
// frontend actions share: onNextRendering / whenRendered (one pending
// delegate per control and key), usesXmlTemplating (whether a view build
// pays for the XMLPreprocessor at all) and cancelTimer (a slot that holds a
// setTimeout handle OR an afterRoundtrip cancel).

// A control stub with a live delegate list and a switchable DOM.
function control({ rendered = false } = {}) {
  const delegates = [];
  return {
    delegates,
    rendered,
    getDomRef() {
      return this.rendered ? {} : null;
    },
    addEventDelegate: (d) => delegates.push(d),
    removeEventDelegate: (d) => {
      const i = delegates.indexOf(d);
      if (i >= 0) delegates.splice(i, 1);
    },
    render() {
      this.rendered = true;
      for (const d of [...delegates]) d.onAfterRendering();
    },
  };
}

test.describe("onNextRendering", () => {
  test("runs once after the next rendering and removes itself", () => {
    const { Lib } = loadLib();
    const c = control();
    let runs = 0;
    Lib.onNextRendering(c, () => runs++);
    expect(c.delegates).toHaveLength(1);
    c.render();
    expect(runs).toBe(1);
    expect(c.delegates).toEqual([]);
    c.render();
    expect(runs).toBe(1);
  });

  test("a keyed call replaces the pending delegate of the same key", () => {
    // a poll-driven app asks for the focus on every tick; with the control
    // never re-rendering, every tick used to add a delegate, and the
    // first rendering fired them all
    const { Lib } = loadLib();
    const c = control();
    const fired = [];
    for (let i = 0; i < 5; i++) {
      Lib.onNextRendering(c, () => fired.push(i), "focus");
    }
    expect(c.delegates).toHaveLength(1);
    c.render();
    expect(fired).toEqual([4]);
    expect(c.delegates).toEqual([]);
  });

  test("different keys and unkeyed calls stay independent", () => {
    const { Lib } = loadLib();
    const c = control();
    const fired = [];
    Lib.onNextRendering(c, () => fired.push("focus"), "focus");
    Lib.onNextRendering(c, () => fired.push("open"), "open");
    Lib.onNextRendering(c, () => fired.push("plain"));
    Lib.onNextRendering(c, () => fired.push("plain2"));
    expect(c.delegates).toHaveLength(4);
    c.render();
    expect(fired.sort()).toEqual(["focus", "open", "plain", "plain2"]);
  });

  test("a key fired and asked again is pending again", () => {
    const { Lib } = loadLib();
    const c = control();
    const fired = [];
    Lib.onNextRendering(c, () => fired.push(1), "focus");
    c.render();
    Lib.onNextRendering(c, () => fired.push(2), "focus");
    expect(c.delegates).toHaveLength(1);
    c.render();
    expect(fired).toEqual([1, 2]);
  });
});

test.describe("whenRendered", () => {
  test("runs now for a rendered control, keyed-deferred otherwise", () => {
    const { Lib } = loadLib();
    const owner = { isDestroyed: () => false };
    const done = control({ rendered: true });
    const fired = [];
    Lib.whenRendered(done, owner, () => fired.push("now"), "open");
    expect(fired).toEqual(["now"]);
    expect(done.delegates).toEqual([]);

    const later = control();
    Lib.whenRendered(later, owner, () => fired.push("a"), "open");
    Lib.whenRendered(later, owner, () => fired.push("b"), "open");
    expect(later.delegates).toHaveLength(1);
    later.render();
    expect(fired).toEqual(["now", "b"]);
  });

  test("a deferred callback is dropped when its owner died meanwhile", () => {
    const { Lib } = loadLib();
    let dead = false;
    const owner = { isDestroyed: () => dead };
    const c = control();
    let runs = 0;
    Lib.whenRendered(c, owner, () => runs++);
    dead = true;
    c.render();
    expect(runs).toBe(0);
    expect(c.delegates).toEqual([]);
  });
});

test.describe("usesXmlTemplating", () => {
  test("is true for the templating namespace under any prefix", () => {
    const { Lib } = loadLib();
    expect(
      Lib.usesXmlTemplating(
        '<mvc:View xmlns:template="http://schemas.sap.com/sapui5/extension/sap.ui.core.template/1"/>',
      ),
    ).toBe(true);
    expect(
      Lib.usesXmlTemplating(
        '<mvc:View xmlns:t="http://schemas.sap.com/sapui5/extension/sap.ui.core.template/1"><t:if test="{template>/x}"/></mvc:View>',
      ),
    ).toBe(true);
  });

  test("is true for a template> binding", () => {
    const { Lib } = loadLib();
    expect(Lib.usesXmlTemplating('<Text text="{template>/title}"/>')).toBe(true);
    expect(Lib.usesXmlTemplating('<Text text="{ template>/title }"/>')).toBe(
      true,
    );
  });

  test("is false for an ordinary view, and for no view at all", () => {
    const { Lib } = loadLib();
    expect(
      Lib.usesXmlTemplating(
        '<mvc:View xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc"><Input value="{/NAME}"/><Text text="{path: \'/X\', formatter: \'.f\'}"/></mvc:View>',
      ),
    ).toBe(false);
    expect(Lib.usesXmlTemplating("")).toBe(false);
    expect(Lib.usesXmlTemplating(undefined)).toBe(false);
  });
});

test.describe("cancelTimer / cancelPendingTimers", () => {
  test("clears a handle and runs a cancel function alike", () => {
    const cleared = [];
    const { Lib, sandbox } = loadLib({
      clearTimeout: (h) => cleared.push(h),
    });
    let cancelled = 0;
    Lib.cancelTimer(7);
    Lib.cancelTimer(() => cancelled++);
    expect(cleared).toEqual([7]);
    expect(cancelled).toBe(1);

    sandbox.z2ui5.timers = { A: 11, B: () => cancelled++ };
    Lib.cancelPendingTimers();
    expect(cleared).toEqual([7, 11]);
    expect(cancelled).toBe(2);
    expect(sandbox.z2ui5.timers).toEqual({});
  });
});
