// @ts-check
const { test, expect } = require("@playwright/test");
const { loadLib } = require("./loadLibModule");

// Tests the shared size-limit helpers in app/webapp/core/Lib.js. They encode
// the nested-views model architecture: MAIN, NEST and NEST2 share ONE root
// JSON model (the nested views inherit MAIN's default model via UI5 model
// propagation), so a per-view size limit collapses onto that single model and
// the largest requested limit across the three wins. Popup/popover are
// standalone and keep their own limit.

test.describe("isRootModelSlot", () => {
  const { Lib } = loadLib();

  test("MAIN and the two nested slots share the root model", () => {
    expect(Lib.isRootModelSlot("MAIN")).toBe(true);
    expect(Lib.isRootModelSlot("NEST")).toBe(true);
    expect(Lib.isRootModelSlot("NEST2")).toBe(true);
  });

  test("popup and popover do not", () => {
    expect(Lib.isRootModelSlot("POPUP")).toBe(false);
    expect(Lib.isRootModelSlot("POPOVER")).toBe(false);
    expect(Lib.isRootModelSlot("UNKNOWN")).toBe(false);
  });
});

test.describe("effectiveSizeLimit", () => {
  const { Lib } = loadLib();

  test("returns undefined for a root slot when nothing is stored", () => {
    expect(Lib.effectiveSizeLimit({}, "MAIN")).toBeUndefined();
    expect(Lib.effectiveSizeLimit({}, "NEST")).toBeUndefined();
  });

  test("a root slot gets the max limit across MAIN/NEST/NEST2", () => {
    const limits = { MAIN: 100, NEST: 500, NEST2: 200 };
    expect(Lib.effectiveSizeLimit(limits, "MAIN")).toBe(500);
    expect(Lib.effectiveSizeLimit(limits, "NEST")).toBe(500);
    expect(Lib.effectiveSizeLimit(limits, "NEST2")).toBe(500);
  });

  test("ignores unset root slots when taking the max", () => {
    expect(Lib.effectiveSizeLimit({ NEST: 300 }, "MAIN")).toBe(300);
    expect(Lib.effectiveSizeLimit({ MAIN: 100, NEST2: 50 }, "NEST")).toBe(100);
  });

  test("a standalone slot keeps its own limit, not the root max", () => {
    const limits = { MAIN: 999, POPUP: 100, POPOVER: 250 };
    expect(Lib.effectiveSizeLimit(limits, "POPUP")).toBe(100);
    expect(Lib.effectiveSizeLimit(limits, "POPOVER")).toBe(250);
  });

  test("a standalone slot with no stored limit returns undefined", () => {
    expect(Lib.effectiveSizeLimit({ MAIN: 500 }, "POPUP")).toBeUndefined();
  });
});
