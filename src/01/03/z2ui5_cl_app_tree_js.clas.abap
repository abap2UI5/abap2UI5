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

    result = `sap.ui.define(["sap/ui/core/Control", "z2ui5/cc/Lib"], (Control, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.Tree", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        tree_id: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    _getTreeBinding() {` && |\n| &&
             `      if (!z2ui5.oView) return undefined;` && |\n| &&
             `      const treeControl = z2ui5.oView.byId(this.getProperty("tree_id"));` && |\n| &&
             `      if (!treeControl) return undefined;` && |\n| &&
             `      return treeControl.getBinding("items");` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    setBackend() {` && |\n| &&
             `      try {` && |\n| &&
             `        const binding = this._getTreeBinding();` && |\n| &&
             `        z2ui5.treeState = binding ? binding.getCurrentTreeState() : undefined;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("Tree.setBackend: failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    init() {` && |\n| &&
             `      this._setBackendBound = this.setBackend.bind(this);` && |\n| &&
             `      Lib.registerCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    exit() {` && |\n| &&
             `      Lib.unregisterCallback("onBeforeRoundtrip", this._setBackendBound);` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingTreeState) return;` && |\n| &&
             `      this._pendingTreeState = false;` && |\n| &&
             `      try {` && |\n| &&
             `        const binding = this._getTreeBinding();` && |\n| &&
             `        if (binding) binding.setTreeState(z2ui5.treeState);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("Tree.onAfterRendering: setTreeState failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `        if (!z2ui5.treeState) return;` && |\n| &&
             `        oControl._pendingTreeState = true;` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
