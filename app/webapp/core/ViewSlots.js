// Access layer for the five view slots of the multi-view architecture
// (main view, two nested views, popup, popover). The live view and
// controller instances are internal z2ui5 state owned by core/AppState;
// this module is the one place that knows which slot is which - lookups,
// in-slot control resolution (byId) and teardown go through here instead
// of touching z2ui5.oView / oViewPopup / ... directly.
sap.ui.define(["sap/ui/core/Fragment", "z2ui5/core/Lib"], (Fragment, Lib) => {
  "use strict";

  // `key`    short slot name used in frontend events and S_FRONT.VIEW
  // `param`  key of the slot in the backend response PARAMS
  // `prop` / `controllerProp`  z2ui5 fields holding the live instances
  // `fragmentId`  only on the fragment-based slots (popup/popover): the
  //               id their inner controls are registered under, and the
  //               marker that the slot must be close()d before destroy
  const slots = [
    {
      key: "MAIN",
      param: "S_VIEW",
      prop: "oView",
      controllerProp: "oController",
    },
    {
      key: "NEST",
      param: "S_VIEW_NEST",
      prop: "oViewNest",
      controllerProp: "oControllerNest",
    },
    {
      key: "NEST2",
      param: "S_VIEW_NEST2",
      prop: "oViewNest2",
      controllerProp: "oControllerNest2",
    },
    {
      key: "POPUP",
      param: "S_POPUP",
      prop: "oViewPopup",
      controllerProp: "oControllerPopup",
      fragmentId: "popupId",
    },
    {
      key: "POPOVER",
      param: "S_POPOVER",
      prop: "oViewPopover",
      controllerProp: "oControllerPopover",
      fragmentId: "popoverId",
    },
  ];

  // Constant-time lookups for the frequently used resolutions (byId,
  // getView, paramByKey run on every roundtrip and scroll/focus capture)
  // instead of a linear find() per call.
  const slotsByKey = new Map(slots.map((s) => [s.key, s]));
  const slotsByParam = new Map(slots.map((s) => [s.param, s]));

  function byKey(key) {
    return slotsByKey.get(key);
  }

  // Live view (or fragment) instance of a slot, undefined when not open.
  function getView(key) {
    const slot = byKey(key);
    return slot ? z2ui5[slot.prop] : undefined;
  }

  function setView(key, view) {
    const slot = byKey(key);
    if (slot) z2ui5[slot.prop] = view;
  }

  // Controller instance serving a slot (created once in App.controller).
  function getController(key) {
    const slot = byKey(key);
    return slot ? z2ui5[slot.controllerProp] : undefined;
  }

  // Returns the slot key for a response param key ("S_VIEW" -> "MAIN").
  function keyByParam(param) {
    return slotsByParam.get(param)?.key;
  }

  // Returns the response param key for a slot key ("MAIN" -> "S_VIEW").
  function paramByKey(key) {
    const slot = byKey(key);
    return slot ? slot.param : undefined;
  }

  // Returns the key of the slot whose controller is `controller` -
  // i.e. which slot an event handler was invoked for.
  function keyOfController(controller) {
    if (!controller) return undefined;
    const slot = slots.find((s) => z2ui5[s.controllerProp] === controller);
    return slot ? slot.key : undefined;
  }

  // Resolve a control id inside a slot: views resolve via view.byId, the
  // fragment slots via their fragment id. Returns undefined when the slot
  // is not open or the id is unknown there.
  function byId(key, id) {
    const slot = byKey(key);
    if (!slot) return undefined;
    const view = z2ui5[slot.prop];
    if (!view) return undefined;
    if (slot.fragmentId) return Fragment.byId(slot.fragmentId, id);
    return view.byId(id);
  }

  // Returns the key of the slot a UI5 element belongs to, by walking up
  // the control tree until a live slot view is hit (innermost slot wins,
  // e.g. nested views). Undefined when the element is in no slot.
  function containingSlotKey(element) {
    let current = element;
    while (current) {
      for (const slot of slots) {
        if (z2ui5[slot.prop] === current) return slot.key;
      }
      current = current.getParent?.();
    }
    return undefined;
  }

  // Shared teardown: close (popup/popover only), destroy and clear the
  // slot. Safe to call for slots that are not open.
  function destroy(key) {
    const slot = byKey(key);
    if (!slot) return;
    const view = z2ui5[slot.prop];
    if (!view) return;
    if (slot.fragmentId) {
      try {
        if (view.close) view.close();
      } catch (e) {
        Lib.logError(`ViewSlots.destroy: view.close() failed for ${key}`, e);
      }
    }
    try {
      view.destroy();
    } catch (e) {
      Lib.logError(`ViewSlots.destroy: view.destroy() failed for ${key}`, e);
    }
    z2ui5[slot.prop] = null;
  }

  return {
    slots,
    getView,
    setView,
    getController,
    keyByParam,
    paramByKey,
    keyOfController,
    byId,
    containingSlotKey,
    destroy,
  };
});
