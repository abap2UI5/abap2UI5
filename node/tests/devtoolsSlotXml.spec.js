// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { specContext } = require("./loadLibModule");

// Tests the real implementation shipped in app/webapp/devtools/SlotXml.js
// - the one reader of a slot's view XML that the tab registry, the
// registry inspector and the control picker share. Pinned: the live
// view's own XML wins over the recorded source, the fallback to the
// recorded source, and that the read never goes through getProperty
// (#2318 switched to it and broke the View tab).

// Mimics the relevant shape of a real sap.ui.core.mvc.XMLView: the raw XML
// string is kept as a pseudo property in mProperties, but is NOT declared
// in the control metadata - getProperty("viewContent") therefore throws.
function fakeXmlView(viewContent) {
  return {
    mProperties: viewContent === undefined ? {} : { viewContent },
    getProperty(name) {
      throw new Error(`Property "${name}" does not exist in Element`);
    },
  };
}

// The slots belong to a component context (core/Context.js), so the reader
// takes it first; the registry stub answers for the one spec context.
function loadSlotXml({ views = {}, slotXml = {} } = {}) {
  const ctx = specContext();
  const { module } = loadModule("devtools/SlotXml.js", {
    deps: {
      "z2ui5/core/ViewSlots": {
        getView: (_ctx, key) => views[key],
        getViewXml: (_ctx, key) => slotXml[key],
      },
    },
  });
  return { SlotXml: module, ctx };
}

test.describe("slotXml", () => {
  test("prefers the live view's own XML", () => {
    const { SlotXml, ctx } = loadSlotXml({
      views: { MAIN: fakeXmlView("<View id='live'/>") },
      slotXml: { MAIN: "<View id='recorded'/>" },
    });
    expect(SlotXml.slotXml(ctx, "MAIN")).toBe("<View id='live'/>");
  });

  test("falls back to the source the slot was filled with", () => {
    // a fragment or a `definition`-built view keeps no viewContent
    const { SlotXml, ctx } = loadSlotXml({
      views: { POPUP: fakeXmlView(undefined) },
      slotXml: { POPUP: "<Dialog/>" },
    });
    expect(SlotXml.slotXml(ctx, "POPUP")).toBe("<Dialog/>");
  });

  test("is empty for an empty slot, an unknown slot and no slot at all", () => {
    const { SlotXml, ctx } = loadSlotXml();
    expect(SlotXml.slotXml(ctx, "MAIN")).toBe("");
    expect(SlotXml.slotXml(ctx, "NOPE")).toBe("");
    // a picked control outside every slot asks with no key
    expect(SlotXml.slotXml(ctx, undefined)).toBe("");
    expect(SlotXml.slotXml(ctx, "")).toBe("");
  });

  test("reads the pseudo property, never getProperty", () => {
    const { SlotXml, ctx } = loadSlotXml({ views: { MAIN: fakeXmlView("<View/>") } });
    expect(SlotXml.viewContent(fakeXmlView("<View/>"))).toBe("<View/>");
    expect(SlotXml.viewContent(undefined)).toBeUndefined();
    expect(() => SlotXml.slotXml(ctx, "MAIN")).not.toThrow();
  });
});
