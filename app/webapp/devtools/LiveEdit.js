// Live view-XML editing of the developer tools.
//
// Takes the XML currently shown in a developer-tools view tab, re-renders
// the slot with it and keeps the slot's model - so a layout change can be
// tried out in the running app WITHOUT an ABAP roundtrip and without
// activating anything. The next real roundtrip overwrites it again, which
// is the intended lifetime: this is an experiment surface, not a way to
// patch an app.
//
// Outside the framework like the rest of devtools/: it drives the
// same public slot-display entry point (core/actions/Slots.action) the
// backend's VIEW_SLOTS action uses, and adds nothing to it.
sap.ui.define(
  [
    "z2ui5/core/actions/Slots",
    "z2ui5/core/AppState",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
  ],
  (Slots, AppState, Lib, ViewSlots) => {
    "use strict";

    // Which developer-tools tab edits which view slot. Only the tabs that
    // show a slot's own XML can be applied; the model / response / history
    // tabs have no slot to render into.
    const TAB_TO_SLOT = {
      VIEW: "MAIN",
      POPUP: "POPUP",
      POPOVER: "POPOVER",
      NEST1: "NEST",
      NEST2: "NEST2",
    };

    function slotOfTab(tabKey) {
      return TAB_TO_SLOT[tabKey];
    }

    // True when the given tab can be applied right now: it maps to a slot
    // and that slot actually holds something to replace.
    function canApply(tabKey) {
      const slotKey = slotOfTab(tabKey);
      if (!slotKey) return false;
      return Boolean(ViewSlots.getView(slotKey));
    }

    // Re-render `tabKey`'s slot with `xml`. Returns a short result message
    // for the dialog to show. Never throws: a typo in the edited XML is the
    // expected case, and it must leave the app alive.
    //
    // The model is carried over explicitly for the standalone slots: a
    // display builds a FRESH JSONModel from the response's model data, so
    // without this a popup re-rendered from the editor would come back
    // bound to whatever the last response carried rather than to what the
    // user currently sees.
    async function apply(tabKey, xml) {
      const slotKey = slotOfTab(tabKey);
      if (!slotKey) return "This tab shows no view slot - nothing to apply.";
      if (!xml || !xml.trim()) return "The editor is empty - nothing to apply.";

      const oldView = ViewSlots.getView(slotKey);
      if (!oldView) return `Slot ${slotKey} is not filled - nothing to apply.`;
      const oldModel = oldView.getModel?.();
      const modelData = oldModel?.getData?.();

      try {
        // seq undefined: this display belongs to no roundtrip, so the
        // superseded-request guard must not discard it (Slots.isSuperseded
        // treats undefined as "not superseded"). MAIN reuses the options of
        // its last real display (switch-mode OData default model included) -
        // an empty {} stripped them and broke the preview of exactly those
        // apps.
        const options =
          slotKey === "MAIN" ? AppState.state.lastMainDisplayOptions || {} : {};
        await Slots.action("display", slotKey, xml, options, undefined);
      } catch (e) {
        Lib.logError("DevTools LiveEdit: applying the edited XML failed", e);
        return `Could not build the view: ${e?.message || e}`;
      }

      // Restore what the user was looking at. Only for the slots that own
      // their model - MAIN's rebuild already reads the current model data,
      // and the nested slots inherit MAIN's by propagation.
      try {
        const newView = ViewSlots.getView(slotKey);
        const newModel = newView?.getModel?.();
        if (modelData && newModel?.setData && slotKey !== "MAIN") {
          newModel.setData(modelData);
        }
      } catch (e) {
        Lib.logError("DevTools LiveEdit: restoring the model failed", e);
      }

      return (
        `Applied to slot ${slotKey}. This is a LOCAL preview - the backend ` +
        `knows nothing about it, and the next roundtrip replaces it.`
      );
    }

    // The XML the slot currently holds, so the editor can be reset to the
    // version the backend actually sent.
    function originalXml(tabKey) {
      const slotKey = slotOfTab(tabKey);
      if (!slotKey) return "";
      return (
        ViewSlots.getView(slotKey)?.mProperties?.viewContent ||
        ViewSlots.getViewXml(slotKey) ||
        ""
      );
    }

    // True while a roundtrip is running - applying then would race the
    // response's own display of the same slot.
    function isBusy() {
      return Boolean(AppState.state.isBusy);
    }

    return { apply, canApply, slotOfTab, originalXml, isBusy };
  },
);
