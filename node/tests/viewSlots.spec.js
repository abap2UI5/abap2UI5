// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/ViewSlots.js against a stubbed z2ui5
// global, a recording Fragment stub and a recording Lib.logError stub.

function load() {
  const fragmentCalls = [];
  const errors = [];
  const z2ui5 = {};
  const { module } = loadModule("core/ViewSlots.js", {
    deps: {
      "sap/ui/core/Fragment": {
        byId: (fragmentId, id) => {
          fragmentCalls.push([fragmentId, id]);
          return `${fragmentId}--${id}`;
        },
      },
      "z2ui5/core/Lib": {
        logError: (message) => errors.push(message),
      },
    },
    sandbox: { z2ui5 },
  });
  return { ViewSlots: module, z2ui5, fragmentCalls, errors };
}

test.describe("key mappings", () => {
  test("keyByParam maps response param keys to slot keys", () => {
    const { ViewSlots } = load();
    expect(ViewSlots.keyByParam("S_VIEW")).toBe("MAIN");
    expect(ViewSlots.keyByParam("S_VIEW_NEST2")).toBe("NEST2");
    expect(ViewSlots.keyByParam("S_POPUP")).toBe("POPUP");
    expect(ViewSlots.keyByParam("UNKNOWN")).toBeUndefined();
  });

  test("paramByKey is the inverse of keyByParam for all slots", () => {
    const { ViewSlots } = load();
    for (const slot of ViewSlots.slots) {
      expect(ViewSlots.paramByKey(slot.key)).toBe(slot.param);
      expect(ViewSlots.keyByParam(slot.param)).toBe(slot.key);
    }
  });
});

test.describe("view and controller access", () => {
  test("setView/getView write and read the slot's z2ui5 field", () => {
    const { ViewSlots, z2ui5 } = load();
    const view = {};
    ViewSlots.setView("NEST", view);
    expect(z2ui5.oViewNest).toBe(view);
    expect(ViewSlots.getView("NEST")).toBe(view);
    expect(ViewSlots.getView("POPUP")).toBeUndefined();
    expect(ViewSlots.getView("UNKNOWN")).toBeUndefined();
  });

  test("keyOfController finds the slot a controller serves", () => {
    const { ViewSlots, z2ui5 } = load();
    const controller = {};
    z2ui5.oControllerPopover = controller;
    expect(ViewSlots.keyOfController(controller)).toBe("POPOVER");
    expect(ViewSlots.keyOfController({})).toBeUndefined();
  });
});

test.describe("byId", () => {
  test("resolves via view.byId for the view slots", () => {
    const { ViewSlots, z2ui5 } = load();
    z2ui5.oView = { byId: (id) => `main-${id}` };
    expect(ViewSlots.byId("MAIN", "btn")).toBe("main-btn");
  });

  test("resolves via Fragment.byId for an open popup/popover", () => {
    const { ViewSlots, z2ui5, fragmentCalls } = load();
    z2ui5.oViewPopup = {};
    expect(ViewSlots.byId("POPUP", "btn")).toBe("popupId--btn");
    expect(fragmentCalls).toEqual([["popupId", "btn"]]);
  });

  test("returns undefined for closed or unknown slots", () => {
    const { ViewSlots, fragmentCalls } = load();
    expect(ViewSlots.byId("POPUP", "btn")).toBeUndefined();
    expect(ViewSlots.byId("UNKNOWN", "btn")).toBeUndefined();
    // A closed fragment slot must not hit the Fragment registry.
    expect(fragmentCalls).toEqual([]);
  });
});

test.describe("containingSlotKey", () => {
  test("walks up the control tree; the innermost slot wins", () => {
    const { ViewSlots, z2ui5 } = load();
    const mainView = { getParent: () => undefined };
    const nestView = { getParent: () => mainView };
    const control = { getParent: () => nestView };
    z2ui5.oView = mainView;
    z2ui5.oViewNest = nestView;
    expect(ViewSlots.containingSlotKey(control)).toBe("NEST");
    expect(ViewSlots.containingSlotKey(nestView)).toBe("NEST");
    expect(ViewSlots.containingSlotKey(mainView)).toBe("MAIN");
  });

  test("returns undefined for elements outside every slot", () => {
    const { ViewSlots } = load();
    const lonely = { getParent: () => undefined };
    expect(ViewSlots.containingSlotKey(lonely)).toBeUndefined();
  });
});

test.describe("destroy", () => {
  test("closes, destroys and clears a fragment slot", () => {
    const { ViewSlots, z2ui5 } = load();
    const calls = [];
    z2ui5.oViewPopup = {
      close: () => calls.push("close"),
      destroy: () => calls.push("destroy"),
    };
    ViewSlots.destroy("POPUP");
    expect(calls).toEqual(["close", "destroy"]);
    expect(z2ui5.oViewPopup).toBeNull();
  });

  test("does not close plain view slots", () => {
    const { ViewSlots, z2ui5 } = load();
    const calls = [];
    z2ui5.oView = {
      close: () => calls.push("close"),
      destroy: () => calls.push("destroy"),
    };
    ViewSlots.destroy("MAIN");
    expect(calls).toEqual(["destroy"]);
    expect(z2ui5.oView).toBeNull();
  });

  test("still destroys and clears the slot when close() throws", () => {
    const { ViewSlots, z2ui5, errors } = load();
    const calls = [];
    z2ui5.oViewPopover = {
      close: () => {
        throw new Error("boom");
      },
      destroy: () => calls.push("destroy"),
    };
    ViewSlots.destroy("POPOVER");
    expect(calls).toEqual(["destroy"]);
    expect(z2ui5.oViewPopover).toBeNull();
    expect(errors).toHaveLength(1);
  });

  test("is a no-op for closed or unknown slots", () => {
    const { ViewSlots, z2ui5 } = load();
    ViewSlots.destroy("POPUP");
    ViewSlots.destroy("UNKNOWN");
    expect(z2ui5.oViewPopup).toBeUndefined();
  });
});
