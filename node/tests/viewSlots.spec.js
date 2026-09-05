// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real app/webapp/core/ViewSlots.js against a stubbed AppState
// state object, a recording Fragment stub and a recording Lib.logError
// stub. The state stub is returned as `z2ui5` because in the app the
// same fields are also visible on the z2ui5 global via the AppState
// accessors.

function load() {
  const fragmentCalls = [];
  const errors = [];
  const z2ui5 = {};
  // Global UI5 registry stub behind Lib.getElementById - the fallback path
  // resolveById() takes when no open slot owns the id.
  const globalElements = {};
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
        getElementById: (id) => globalElements[id] || null,
        getMessaging: () => ({
          getMessageModel: () => messageModel,
          registerObject: (view, bind) => registerCalls.push([view, bind]),
          unregisterObject: (view) => unregisterCalls.push(view),
        }),
      },
      "z2ui5/core/AppState": { state: z2ui5 },
    },
  });
  const unregisterCalls = [];
  const registerCalls = [];
  const messageModel = { id: "messageModel" };
  return {
    ViewSlots: module,
    z2ui5,
    fragmentCalls,
    errors,
    globalElements,
    unregisterCalls,
    registerCalls,
    messageModel,
  };
}

test.describe("slot table", () => {
  test("exactly MAIN, POPUP and POPOVER carry a model of their own", () => {
    // NEST and NEST2 are inserted into the MAIN control tree and inherit its
    // model by UI5 propagation - giving them one of their own would detach
    // them from the data every other view binds against
    const { ViewSlots } = load();
    expect(
      ViewSlots.slots.filter((s) => s.ownsModel).map((s) => s.key),
    ).toEqual(["MAIN", "POPUP", "POPOVER"]);
  });
});

test.describe("view and controller access", () => {
  test("setView/getView write and read the slot's z2ui5 field", () => {
    const { ViewSlots, z2ui5 } = load();
    const view = { setModel() {} };
    ViewSlots.setView("NEST", view);
    expect(z2ui5.oViewNest).toBe(view);
    expect(ViewSlots.getView("NEST")).toBe(view);
    expect(ViewSlots.getView("POPUP")).toBeUndefined();
    expect(ViewSlots.getView("UNKNOWN")).toBeUndefined();
  });

  test("setView attaches the shared device + message models and registers", () => {
    const { ViewSlots, z2ui5, registerCalls, messageModel } = load();
    const models = [];
    const deviceModel = { id: "deviceModel" };
    z2ui5.oDeviceModel = deviceModel;
    const view = { setModel: (m, name) => models.push([name, m]) };
    ViewSlots.setView("MAIN", view);
    expect(models).toEqual([
      ["device", deviceModel],
      ["message", messageModel],
    ]);
    expect(registerCalls).toEqual([[view, true]]);
  });

  test("setView records the XML the slot was filled with", () => {
    const { ViewSlots } = load();
    ViewSlots.setView("POPUP", { setModel() {} }, "<Dialog/>");
    expect(ViewSlots.getViewXml("POPUP")).toBe("<Dialog/>");
    expect(ViewSlots.getViewXml("POPOVER")).toBeUndefined();
  });

  test("setView records the app that filled the slot", () => {
    // A response carries the model of exactly one app, and the open slots
    // need not all come from that one - an app called only to open a dialog
    // leaves MAIN on the caller's view. This record is what says so
    // (actions/Slots.updateModelIfRequired).
    const { ViewSlots, z2ui5 } = load();
    z2ui5.oResponse = { APP: "ZCL_LIST" };
    ViewSlots.setView("MAIN", { setModel() {} }, "<mvc:View/>");
    z2ui5.oResponse = { APP: "ZCL_LIST_POPUP" };
    ViewSlots.setView("POPUP", { setModel() {} }, "<Dialog/>");

    expect(ViewSlots.getViewApp("MAIN")).toBe("ZCL_LIST");
    expect(ViewSlots.getViewApp("POPUP")).toBe("ZCL_LIST_POPUP");
    expect(ViewSlots.getViewApp("POPOVER")).toBeUndefined();
  });

  test("a re-display moves the slot to the app that displayed it", () => {
    // a called app that takes the screen displays MAIN itself; when the
    // caller comes back (nav_app_leave) it displays MAIN again. The record
    // follows each display, so the model push (actions/Slots) follows the
    // app on screen and not the one that filled the slot first
    const { ViewSlots, z2ui5 } = load();
    z2ui5.oResponse = { APP: "ZCL_LIST" };
    ViewSlots.setView("MAIN", { setModel() {} }, "<mvc:View/>");
    z2ui5.oResponse = { APP: "ZCL_DETAIL" };
    ViewSlots.setView("MAIN", { setModel() {} }, "<mvc:View/>");
    expect(ViewSlots.getViewApp("MAIN")).toBe("ZCL_DETAIL");
    z2ui5.oResponse = { APP: "ZCL_LIST" };
    ViewSlots.setView("MAIN", { setModel() {} }, "<mvc:View/>");
    expect(ViewSlots.getViewApp("MAIN")).toBe("ZCL_LIST");
  });

  test("a slot filled before any response named an app has no owner", () => {
    // the pre-response fill (a view built at bootstrap) keeps the
    // unconditional push - the guard only acts on a recorded owner
    const { ViewSlots, z2ui5 } = load();
    z2ui5.oResponse = undefined;
    ViewSlots.setView("MAIN", { setModel() {} }, "<mvc:View/>");
    expect(ViewSlots.getViewApp("MAIN")).toBeUndefined();
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

test.describe("byIdOfOwner", () => {
  test("resolves the id in the owner's own slot, not a same-id in MAIN", () => {
    const { ViewSlots, z2ui5 } = load();
    // Same local id "tree" exists in MAIN and in the open popup.
    z2ui5.oView = { byId: (id) => (id === "tree" ? "main-tree" : undefined) };
    const popupControl = {};
    z2ui5.oViewPopup = popupControl;
    // The owner (a companion) lives in the popup; walking up hits oViewPopup.
    const owner = { getParent: () => popupControl };
    // Fragment.byId is stubbed as `${fragmentId}--${id}` for popup slots.
    expect(ViewSlots.byIdOfOwner(owner, "tree")).toBe("popupId--tree");
  });

  test("falls back to MAIN when the owner is in no slot", () => {
    const { ViewSlots, z2ui5 } = load();
    z2ui5.oView = { byId: (id) => `main-${id}` };
    const owner = { getParent: () => undefined };
    expect(ViewSlots.byIdOfOwner(owner, "btn")).toBe("main-btn");
  });
});

test.describe("resolveById", () => {
  test("finds a control in an open slot before hitting the registry", () => {
    const { ViewSlots, z2ui5, globalElements } = load();
    z2ui5.oView = { byId: (id) => (id === "btn" ? "main-btn" : undefined) };
    globalElements.btn = "global-btn";
    // The slot match wins over the global registry entry of the same id.
    expect(ViewSlots.resolveById("btn")).toBe("main-btn");
  });

  test("falls back to the global registry when no slot owns the id", () => {
    const { ViewSlots, z2ui5, globalElements } = load();
    z2ui5.oView = { byId: () => undefined };
    globalElements["mainView--btn"] = "global-btn";
    expect(ViewSlots.resolveById("mainView--btn")).toBe("global-btn");
  });

  test("returns null for an empty or unresolvable id", () => {
    const { ViewSlots } = load();
    expect(ViewSlots.resolveById("")).toBeNull();
    expect(ViewSlots.resolveById("missing")).toBeNull();
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

  test("drops the recorded XML, whoever triggered the teardown", () => {
    // The backend's ["VIEW_SLOTS","destroy","POPUP"] action and the
    // roundtrip-free frontend close (cs_event-popup_close, which the backend
    // formats as that same action) both land here - so the record cannot
    // survive one of them and not the other.
    const { ViewSlots } = load();
    ViewSlots.setView("POPUP", { setModel() {}, destroy() {} }, "<Dialog/>");
    ViewSlots.destroy("POPUP");
    expect(ViewSlots.getViewXml("POPUP")).toBeUndefined();
  });

  test("drops the recorded app alongside the XML", () => {
    const { ViewSlots, z2ui5 } = load();
    z2ui5.oResponse = { APP: "ZCL_LIST_POPUP" };
    ViewSlots.setView("POPUP", { setModel() {}, destroy() {} }, "<Dialog/>");
    ViewSlots.destroy("POPUP");
    expect(ViewSlots.getViewApp("POPUP")).toBeUndefined();
  });

  test("drops the recorded XML of a slot whose view is already gone", () => {
    // A fragment load that failed after recording, or a state reset that
    // nulled the live instances: the record must not outlive the slot.
    const { ViewSlots, z2ui5 } = load();
    ViewSlots.setView("POPOVER", { setModel() {} }, "<Popover/>");
    z2ui5.oViewPopover = null;
    ViewSlots.destroy("POPOVER");
    expect(ViewSlots.getViewXml("POPOVER")).toBeUndefined();
  });

  test("MAIN teardown drops the nests' recorded XML too", () => {
    const { ViewSlots } = load();
    ViewSlots.setView("MAIN", { setModel() {}, destroy() {} }, "<Page/>");
    ViewSlots.setView("NEST", { setModel() {}, destroy() {} }, "<Nest/>");
    ViewSlots.destroy("MAIN");
    expect(ViewSlots.getViewXml("MAIN")).toBeUndefined();
    expect(ViewSlots.getViewXml("NEST")).toBeUndefined();
  });

  test("unregisters the view from the messaging facade before destroy", () => {
    const { ViewSlots, z2ui5, unregisterCalls } = load();
    const view = { destroy: () => {} };
    z2ui5.oView = view;
    ViewSlots.destroy("MAIN");
    expect(unregisterCalls).toEqual([view]);
  });

  test("MAIN teardown also destroys, unregisters and clears the nests", () => {
    // The nested views sit inside the MAIN control tree - UI5 would destroy
    // their controls with MAIN either way, but the slot references and the
    // messaging registrations must not stay behind (an app switch replaces
    // MAIN without an explicit nest destroy from the backend).
    const { ViewSlots, z2ui5, unregisterCalls } = load();
    const calls = [];
    const mainView = { destroy: () => calls.push("MAIN") };
    const nestView = { destroy: () => calls.push("NEST") };
    const nest2View = { destroy: () => calls.push("NEST2") };
    z2ui5.oView = mainView;
    z2ui5.oViewNest = nestView;
    z2ui5.oViewNest2 = nest2View;
    ViewSlots.destroy("MAIN");
    // nests leave first - their unregister needs the live view
    expect(calls).toEqual(["NEST", "NEST2", "MAIN"]);
    expect(z2ui5.oViewNest).toBeNull();
    expect(z2ui5.oViewNest2).toBeNull();
    expect(z2ui5.oView).toBeNull();
    expect(unregisterCalls).toEqual([nestView, nest2View, mainView]);
  });

  test("clears a stale nest reference even when MAIN is already gone", () => {
    const { ViewSlots, z2ui5 } = load();
    const calls = [];
    z2ui5.oViewNest = { destroy: () => calls.push("NEST") };
    ViewSlots.destroy("MAIN");
    expect(calls).toEqual(["NEST"]);
    expect(z2ui5.oViewNest).toBeNull();
  });

  test("destroying a nest directly leaves MAIN and the other nest alone", () => {
    const { ViewSlots, z2ui5 } = load();
    const calls = [];
    const mainView = { destroy: () => calls.push("MAIN") };
    const nest2View = { destroy: () => calls.push("NEST2") };
    z2ui5.oView = mainView;
    z2ui5.oViewNest = { destroy: () => calls.push("NEST") };
    z2ui5.oViewNest2 = nest2View;
    ViewSlots.destroy("NEST");
    expect(calls).toEqual(["NEST"]);
    expect(z2ui5.oViewNest).toBeNull();
    expect(z2ui5.oView).toBe(mainView);
    expect(z2ui5.oViewNest2).toBe(nest2View);
  });
});

// core/Lib.js carries the list of AppState controller fields
// (isControllerAlive) and this registry names one per slot; the two are the
// same column written twice, so a slot added to one and not the other would
// make its controller read as dead. Pinned here, with both real modules on
// one state.
test("every slot's controller field is one Lib.isControllerAlive knows", () => {
  const state = {};
  const appState = { state };
  const { module: Lib } = loadModule("core/Lib.js", {
    deps: {
      "z2ui5/core/AppState": appState,
      "sap/ui/core/Element": {},
    },
  });
  const { module: ViewSlots } = loadModule("core/ViewSlots.js", {
    deps: {
      "sap/ui/core/Fragment": {},
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/AppState": appState,
    },
  });
  expect(ViewSlots.slots.length).toBeGreaterThan(0);
  for (const slot of ViewSlots.slots) {
    const marker = { slot: slot.key };
    state[slot.controllerProp] = marker;
    expect(Lib.isControllerAlive(marker)).toBe(true);
  }
});
