CLASS z2ui5_cl_app_tree_js DEFINITION
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


CLASS z2ui5_cl_app_tree_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Lib, ViewSlots, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible control that preserves the expand/collapse state of a` && |\n| &&
             `    // sap.m.Tree (referenced via tree_id) across roundtrips - a rebuilt` && |\n| &&
             `    // binding would otherwise start fully collapsed.` && |\n| &&
             `    return Control.extend("z2ui5.cc.Tree", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          tree_id: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getTreeBinding() {` && |\n| &&
             `        const treeControl = ViewSlots.byId("MAIN", this.getProperty("tree_id"));` && |\n| &&
             `        return treeControl?.getBinding("items");` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      setBackend() {` && |\n| &&
             `        try {` && |\n| &&
             `          const binding = this._getTreeBinding();` && |\n| &&
             `          AppState.state.treeState = binding` && |\n| &&
             `            ? binding.getCurrentTreeState()` && |\n| &&
             `            : undefined;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Tree.setBackend: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `        Lib.registerCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (!this._pendingTreeState) return;` && |\n| &&
             `        this._pendingTreeState = false;` && |\n| &&
             `        try {` && |\n| &&
             `          const binding = this._getTreeBinding();` && |\n| &&
             `          if (binding) binding.setTreeState(AppState.state.treeState);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Tree.onAfterRendering: setTreeState failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          oRm.openStart("span", oControl);` && |\n| &&
             `          oRm.style("display", "none");` && |\n| &&
             `          oRm.openEnd();` && |\n| &&
             `          oRm.close("span");` && |\n| &&
             `          if (!AppState.state.treeState) return;` && |\n| &&
             `          oControl._pendingTreeState = true;` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
