sap.ui.define(
  [
    "sap/ui/core/Control",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (Control, Lib, ViewSlots, AppState) => {
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
        // Resolve across every open view slot (main, popup, popover,
        // nested) - the companion may sit next to a tree in a dialog, not
        // only in the main view.
        const treeControl = ViewSlots.resolveById(this.getProperty("tree_id"));
        return treeControl?.getBinding("items");
      },

      setBackend() {
        try {
          const binding = this._getTreeBinding();
          AppState.state.treeState = binding
            ? binding.getCurrentTreeState()
            : undefined;
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
          if (!binding) return;
          // setTreeState only stores an INITIAL tree state - the binding
          // adapter consumes it while creating its nodes, which already
          // happened during this rendering cycle. Force a rebuild so the
          // snapshot actually gets applied (headless-verified: without the
          // refresh the tree stays collapsed).
          binding.setTreeState(AppState.state.treeState);
          binding.refresh(true);
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
          if (!AppState.state.treeState) return;
          oControl._pendingTreeState = true;
        },
      },
    });
  },
);
