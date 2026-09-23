// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

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

function loadSlotXml({ views = {}, slotXml = {} } = {}) {
  const { module } = loadModule("devtools/SlotXml.js", {
    deps: {
      "z2ui5/core/ViewSlots": {
        getView: (key) => views[key],
        getViewXml: (key) => slotXml[key],
      },
    },
  });
  return module;
}

test.describe("slotXml", () => {
  test("prefers the live view's own XML", () => {
    const SlotXml = loadSlotXml({
      views: { MAIN: fakeXmlView("<View id='live'/>") },
      slotXml: { MAIN: "<View id='recorded'/>" },
    });
    expect(SlotXml.slotXml("MAIN")).toBe("<View id='live'/>");
  });

  test("falls back to the source the slot was filled with", () => {
    // a fragment or a `definition`-built view keeps no viewContent
    const SlotXml = loadSlotXml({
      views: { POPUP: fakeXmlView(undefined) },
      slotXml: { POPUP: "<Dialog/>" },
    });
    expect(SlotXml.slotXml("POPUP")).toBe("<Dialog/>");
  });

  test("is empty for an empty slot, an unknown slot and no slot at all", () => {
    const SlotXml = loadSlotXml();
    expect(SlotXml.slotXml("MAIN")).toBe("");
    expect(SlotXml.slotXml("NOPE")).toBe("");
    // a picked control outside every slot asks with no key
    expect(SlotXml.slotXml(undefined)).toBe("");
    expect(SlotXml.slotXml("")).toBe("");
  });

  test("reads the pseudo property, never getProperty", () => {
    const SlotXml = loadSlotXml({ views: { MAIN: fakeXmlView("<View/>") } });
    expect(SlotXml.viewContent(fakeXmlView("<View/>"))).toBe("<View/>");
    expect(SlotXml.viewContent(undefined)).toBeUndefined();
    expect(() => SlotXml.slotXml("MAIN")).not.toThrow();
  });
});
