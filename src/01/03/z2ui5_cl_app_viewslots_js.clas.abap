CLASS z2ui5_cl_app_viewslots_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_viewslots_js IMPLEMENTATION.

  METHOD get.

    result = `// Access layer for the five view slots of the multi-view architecture` && |\n| &&
             `// (main view, two nested views, popup, popover). The live view and` && |\n| &&
             `// controller instances are internal z2ui5 state owned by core/AppState;` && |\n| &&
             `// this module is the one place that knows which slot is which - lookups,` && |\n| &&
             `// in-slot control resolution (byId) and teardown go through here instead` && |\n| &&
             `// of touching z2ui5.oView / oViewPopup / ... directly.` && |\n| &&
             `sap.ui.define(["sap/ui/core/Fragment", "z2ui5/core/Lib"], (Fragment, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // ``key``    short slot name used in frontend events and S_FRONT.VIEW` && |\n| &&
             `  // ``param``  key of the slot in the backend response PARAMS` && |\n| &&
             `  // ``prop`` / ``controllerProp``  z2ui5 fields holding the live instances` && |\n| &&
             `  // ``fragmentId``  only on the fragment-based slots (popup/popover): the` && |\n| &&
             `  //               id their inner controls are registered under, and the` && |\n| &&
             `  //               marker that the slot must be close()d before destroy` && |\n| &&
             `  const slots = [` && |\n| &&
             `    {` && |\n| &&
             `      key: "MAIN",` && |\n| &&
             `      param: "S_VIEW",` && |\n| &&
             `      prop: "oView",` && |\n| &&
             `      controllerProp: "oController",` && |\n| &&
             `    },` && |\n| &&
             `    {` && |\n| &&
             `      key: "NEST",` && |\n| &&
             `      param: "S_VIEW_NEST",` && |\n| &&
             `      prop: "oViewNest",` && |\n| &&
             `      controllerProp: "oControllerNest",` && |\n| &&
             `    },` && |\n| &&
             `    {` && |\n| &&
             `      key: "NEST2",` && |\n| &&
             `      param: "S_VIEW_NEST2",` && |\n| &&
             `      prop: "oViewNest2",` && |\n| &&
             `      controllerProp: "oControllerNest2",` && |\n| &&
             `    },` && |\n| &&
             `    {` && |\n| &&
             `      key: "POPUP",` && |\n| &&
             `      param: "S_POPUP",` && |\n| &&
             `      prop: "oViewPopup",` && |\n| &&
             `      controllerProp: "oControllerPopup",` && |\n| &&
             `      fragmentId: "popupId",` && |\n| &&
             `    },` && |\n| &&
             `    {` && |\n| &&
             `      key: "POPOVER",` && |\n| &&
             `      param: "S_POPOVER",` && |\n| &&
             `      prop: "oViewPopover",` && |\n| &&
             `      controllerProp: "oControllerPopover",` && |\n| &&
             `      fragmentId: "popoverId",` && |\n| &&
             `    },` && |\n| &&
             `  ];` && |\n| &&
             `` && |\n| &&
             `  // Constant-time lookups for the frequently used resolutions (byId,` && |\n| &&
             `  // getView, paramByKey run on every roundtrip and scroll/focus capture)` && |\n| &&
             `  // instead of a linear find() per call.` && |\n| &&
             `  const slotsByKey = new Map(slots.map((s) => [s.key, s]));` && |\n| &&
             `  const slotsByParam = new Map(slots.map((s) => [s.param, s]));` && |\n| &&
             `` && |\n| &&
             `  function byKey(key) {` && |\n| &&
             `    return slotsByKey.get(key);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Live view (or fragment) instance of a slot, undefined when not open.` && |\n| &&
             `  function getView(key) {` && |\n| &&
             `    const slot = byKey(key);` && |\n| &&
             `    return slot ? z2ui5[slot.prop] : undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function setView(key, view) {` && |\n| &&
             `    const slot = byKey(key);` && |\n| &&
             `    if (slot) z2ui5[slot.prop] = view;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Controller instance serving a slot (created once in App.controller).` && |\n| &&
             `  function getController(key) {` && |\n| &&
             `    const slot = byKey(key);` && |\n| &&
             `    return slot ? z2ui5[slot.controllerProp] : undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns the slot key for a response param key ("S_VIEW" -> "MAIN").` && |\n| &&
             `  function keyByParam(param) {` && |\n| &&
             `    return slotsByParam.get(param)?.key;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns the response param key for a slot key ("MAIN" -> "S_VIEW").` && |\n| &&
             `  function paramByKey(key) {` && |\n| &&
             `    const slot = byKey(key);` && |\n| &&
             `    return slot ? slot.param : undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns the key of the slot whose controller is ``controller`` -` && |\n| &&
             `  // i.e. which slot an event handler was invoked for.` && |\n| &&
             `  function keyOfController(controller) {` && |\n| &&
             `    if (!controller) return undefined;` && |\n| &&
             `    const slot = slots.find((s) => z2ui5[s.controllerProp] === controller);` && |\n| &&
             `    return slot ? slot.key : undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Resolve a control id inside a slot: views resolve via view.byId, the` && |\n| &&
             `  // fragment slots via their fragment id. Returns undefined when the slot` && |\n| &&
             `  // is not open or the id is unknown there.` && |\n| &&
             `  function byId(key, id) {` && |\n| &&
             `    const slot = byKey(key);` && |\n| &&
             `    if (!slot) return undefined;` && |\n| &&
             `    const view = z2ui5[slot.prop];` && |\n| &&
             `    if (!view) return undefined;` && |\n| &&
             `    if (slot.fragmentId) return Fragment.byId(slot.fragmentId, id);` && |\n| &&
             `    return view.byId(id);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns the key of the slot a UI5 element belongs to, by walking up` && |\n| &&
             `  // the control tree until a live slot view is hit (innermost slot wins,` && |\n| &&
             `  // e.g. nested views). Undefined when the element is in no slot.` && |\n| &&
             `  function containingSlotKey(element) {` && |\n| &&
             `    let current = element;` && |\n| &&
             `    while (current) {` && |\n| &&
             `      for (const slot of slots) {` && |\n| &&
             `        if (z2ui5[slot.prop] === current) return slot.key;` && |\n| &&
             `      }` && |\n| &&
             `      current = current.getParent?.();` && |\n| &&
             `    }` && |\n| &&
             `    return undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Shared teardown: close (popup/popover only), destroy and clear the` && |\n| &&
             `  // slot. Safe to call for slots that are not open.` && |\n| &&
             `  function destroy(key) {` && |\n| &&
             `    const slot = byKey(key);` && |\n| &&
             `    if (!slot) return;` && |\n| &&
             `    const view = z2ui5[slot.prop];` && |\n| &&
             `    if (!view) return;` && |\n| &&
             `    if (slot.fragmentId) {` && |\n| &&
             `      try {` && |\n| &&
             `        if (view.close) view.close();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``ViewSlots.destroy: view.close() failed for ${key}``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `    try {` && |\n| &&
             `      view.destroy();` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      Lib.logError(``ViewSlots.destroy: view.destroy() failed for ${key}``, e);` && |\n| &&
             `    }` && |\n| &&
             `    z2ui5[slot.prop] = null;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    slots,` && |\n| &&
             `    getView,` && |\n| &&
             `    setView,` && |\n| &&
             `    getController,` && |\n| &&
             `    keyByParam,` && |\n| &&
             `    paramByKey,` && |\n| &&
             `    keyOfController,` && |\n| &&
             `    byId,` && |\n| &&
             `    containingSlotKey,` && |\n| &&
             `    destroy,` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
