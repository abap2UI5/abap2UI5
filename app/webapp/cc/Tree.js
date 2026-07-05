sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible control that preserves the expand/collapse state of a
    // sap.m.Tree (referenced via tree_id) across roundtrips - a rebuilt
    // binding would otherwise start fully collapsed.
    return Control.extend("z2ui5.cc.Tree", {
      metadata: {
        properties: {
          tree_id: {
            type: "string",
          },
        },
      },

      _getTreeBinding() {
        const treeControl = ViewSlots.byId("MAIN", this.getProperty("tree_id"));
        return treeControl?.getBinding("items");
      },

      setBackend() {
        try {
          const binding = this._getTreeBinding();
          z2ui5.treeState = binding ? binding.getCurrentTreeState() : undefined;
        } catch (e) {
          Lib.logError("Tree.setBackend: failed", e);
        }
      },

      init() {
        this._setBackendBound = this.setBackend.bind(this);
        Lib.registerCallback("onBeforeRoundtrip", this._setBackendBound);
      },

      exit() {
        Lib.unregisterCallback("onBeforeRoundtrip", this._setBackendBound);
      },

      onAfterRendering() {
        if (!this._pendingTreeState) return;
        this._pendingTreeState = false;
        try {
          const binding = this._getTreeBinding();
          if (binding) binding.setTreeState(z2ui5.treeState);
        } catch (e) {
          Lib.logError("Tree.onAfterRendering: setTreeState failed", e);
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oRm.openStart("span", oControl);
          oRm.style("display", "none");
          oRm.openEnd();
          oRm.close("span");
          if (!z2ui5.treeState) return;
          oControl._pendingTreeState = true;
        },
      },
    });
  },
);
