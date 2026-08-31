// Access layer for the five view slots of the multi-view architecture
// (main view, two nested views, popup, popover). The live view and
// controller instances are internal state owned by core/AppState; this
// module is the one place that knows which slot is which - lookups,
// in-slot control resolution (byId) and teardown go through here instead
// of touching AppState.state.oView / oViewPopup / ... directly.
sap.ui.define(
  ["sap/ui/core/Fragment", "z2ui5/core/Lib", "z2ui5/core/AppState"],
  (Fragment, Lib, AppState) => {
    "use strict";

    // `key`    short slot name used in frontend event args and as the
    //           request's S_SCROLL keys
    // `prop` / `controllerProp`  AppState fields holding the live instances
    // `fragmentId`  only on the fragment-based slots (popup/popover): the
    //               id their inner controls are registered under, and the
    //               marker that the slot must be close()d before destroy
    const slots = [
      {
        key: "MAIN",
        // holds its own JSON model - NEST/NEST2 are inserted into
        // the MAIN control tree and inherit theirs by UI5 propagation
        ownsModel: true,
        // ...and they die with it: destroy() routes these through the same
        // teardown before MAIN goes down (see there)
        dependentSlots: ["NEST", "NEST2"],
        prop: "oView",
        controllerProp: "oController",
      },
      {
        key: "NEST",
        prop: "oViewNest",
        controllerProp: "oControllerNest",
      },
      {
        key: "NEST2",
        prop: "oViewNest2",
        controllerProp: "oControllerNest2",
      },
      {
        key: "POPUP",
        // holds its own JSON model - opened standalone, outside the MAIN
        // control tree
        ownsModel: true,
        prop: "oViewPopup",
        controllerProp: "oControllerPopup",
        fragmentId: "popupId",
      },
      {
        key: "POPOVER",
        // holds its own JSON model - opened standalone, outside the MAIN
        // control tree
        ownsModel: true,
        prop: "oViewPopover",
        controllerProp: "oControllerPopover",
        fragmentId: "popoverId",
      },
    ];

    // Constant-time lookups for the frequently used resolutions (byId,
    // getView run on every roundtrip and scroll/focus capture)
    // instead of a linear find() per call.
    const slotsByKey = new Map(slots.map((s) => [s.key, s]));

    function byKey(key) {
      return slotsByKey.get(key);
    }

    // Live view (or fragment) instance of a slot, undefined when not open.
    function getView(key) {
      const slot = byKey(key);
      return slot ? AppState.state[slot.prop] : undefined;
    }

    // Fill a slot. `xml` is the view XML the slot was built from; it is
    // recorded next to the live instance because neither a Fragment nor an
    // XMLView created from a `definition` keeps its source (mProperties.
    // viewContent stays empty), and the developer tools have no other way
    // back to it. Recorded HERE and dropped in destroy(), so the record
    // follows the slot itself - not the response that happened to fill it.
    function setView(key, view, xml) {
      const slot = byKey(key);
      if (!slot) return;
      AppState.state[slot.prop] = view;
      slotXmlStore()[key] = xml;
      attachSharedModels(view);
    }

    // The XML a slot currently holds, undefined once it was torn down.
    function getViewXml(key) {
      return slotXmlStore()[key];
    }

    // The record lives on AppState (so an app restart resets it with
    // everything else); create it on first use so a state object that
    // predates the field still works.
    function slotXmlStore() {
      if (!AppState.state.slotXml) AppState.state.slotXml = {};
      return AppState.state.slotXml;
    }

    // Attach the models every slot shares: the one device model (created
    // once in Component.js, never destroyed) and the central UI5 message
    // model, plus register the view for automatic validation-message
    // collection (handleValidation). Done HERE - the single funnel every
    // successful display path goes through, and the module that also owns
    // destroy() - so attach and the unregister in destroy() stay symmetric:
    // a display path that destroys a view on an error guard never reached
    // setView, so nothing was registered and nothing leaks.
    function attachSharedModels(view) {
      if (!view) return;
      if (AppState.state.oDeviceModel) {
        view.setModel(AppState.state.oDeviceModel, "device");
      }
      const messaging = Lib.getMessaging?.();
      if (messaging) {
        view.setModel(messaging.getMessageModel(), "message");
        messaging.registerObject(view, true);
      }
    }

    // Controller instance serving a slot (created once in App.controller).
    function getController(key) {
      const slot = byKey(key);
      return slot ? AppState.state[slot.controllerProp] : undefined;
    }

    // Returns the key of the slot whose controller is `controller` -
    // i.e. which slot an event handler was invoked for.
    function keyOfController(controller) {
      if (!controller) return undefined;
      const slot = slots.find(
        (s) => AppState.state[s.controllerProp] === controller,
      );
      return slot ? slot.key : undefined;
    }

    // Resolve a control id inside a slot: views resolve via view.byId, the
    // fragment slots via their fragment id. Returns undefined when the slot
    // is not open or the id is unknown there.
    function byId(key, id) {
      const slot = byKey(key);
      if (!slot) return undefined;
      const view = AppState.state[slot.prop];
      if (!view) return undefined;
      if (slot.fragmentId) return Fragment.byId(slot.fragmentId, id);
      return view.byId(id);
    }

    // Resolve a control id the backend named (popover openBy, message box
    // dependentOn) to its control: search every open slot first - the ids
    // apps use are the local ids they wrote in the XML, which resolve inside
    // their view/fragment - then fall back to the global UI5 registry for a
    // fully-qualified id. Returns null when nothing matches.
    function resolveById(id) {
      if (!id) return null;
      for (const slot of slots) {
        const found = byId(slot.key, id);
        if (found) return found;
      }
      return Lib.getElementById(id);
    }

    // The framework-owned JSON model as seen from a view or control: the
    // DEFAULT model normally, the NAMED "http" model when the app switched
    // the default slot to OData (SWITCH_DEFAULT_MODEL_PATH). Undefined when
    // neither carries the _z2ui5Tracked marker. THE one resolver - five
    // call sites used to answer "which model is the framework's" five
    // different ways, and four of them silently picked the OData model in
    // switch mode (SET_SIZE_LIMIT, scroll dirty-marking, the devtools
    // bindings tab).
    function trackedModel(owner) {
      const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
      if (!owner?.getModel) return undefined;
      return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
    }

    // Returns the key of the slot a UI5 element belongs to, by walking up
    // the control tree until a live slot view is hit (innermost slot wins,
    // e.g. nested views). Undefined when the element is in no slot.
    function containingSlotKey(element) {
      let current = element;
      while (current) {
        for (const slot of slots) {
          if (AppState.state[slot.prop] === current) return slot.key;
        }
        current = current.getParent?.();
      }
      return undefined;
    }

    // Resolve a control id in the SAME slot as `owner` - an invisible
    // companion control (Tree, Focus, Scrolling, MultiInputExt, ...) authored
    // in that slot's view next to the control it drives. Preferred over
    // resolveById for companions: it resolves the target in the companion's
    // own slot, so a same local id in another open slot (e.g. a dialog) is
    // never picked by accident, and it works when the companion sits in a
    // popup/popover/nested view - not only in MAIN. Falls back to MAIN when
    // the owner is not attached to a slot yet.
    function byIdOfOwner(owner, id) {
      return byId(containingSlotKey(owner) ?? "MAIN", id);
    }

    // Shared teardown: close (popup/popover only), destroy and clear the
    // slot. Safe to call for slots that are not open.
    function destroy(key) {
      const slot = byKey(key);
      if (!slot) return;
      // The nested views live INSIDE the MAIN control tree, so MAIN's
      // view.destroy() below would cascade to their controls anyway - but
      // the slot references and the messaging registration would stay
      // behind, leaving getView("NEST") truthy long after an app switch
      // (stale shortcut slot scopes, developer tools showing the previous
      // app's nest XML). Route the dependent slots through this same
      // teardown first, BEFORE the open-check: it keeps unregisterObject
      // symmetric to attachSharedModels and clears a stale nest reference
      // even when MAIN itself is already gone.
      for (const dep of slot.dependentSlots ?? []) destroy(dep);
      // Drop the recorded XML BEFORE the empty-slot exit below: a slot whose
      // live instance is already gone (an app restart reset AppState, a
      // fragment load that failed after recording) must not keep a stale
      // source behind - the developer tools read "is this slot filled" off
      // this record.
      delete slotXmlStore()[key];
      const view = AppState.state[slot.prop];
      if (!view) return;
      if (slot.fragmentId) {
        try {
          if (view.close) view.close();
        } catch (e) {
          Lib.logError(`ViewSlots.destroy: view.close() failed for ${key}`, e);
        }
      }
      try {
        // Drop the validation registration attachSharedModels added, so
        // the messaging facade holds no stale entry for the destroyed view.
        Lib.getMessaging?.()?.unregisterObject(view);
      } catch (e) {
        Lib.logError(
          `ViewSlots.destroy: unregisterObject failed for ${key}`,
          e,
        );
      }
      try {
        view.destroy();
      } catch (e) {
        Lib.logError(`ViewSlots.destroy: view.destroy() failed for ${key}`, e);
      }
      AppState.state[slot.prop] = null;
    }

    return {
      slots,
      getView,
      getViewXml,
      setView,
      getController,
      keyOfController,
      byId,
      byIdOfOwner,
      resolveById,
      containingSlotKey,
      trackedModel,
      destroy,
    };
  },
);
