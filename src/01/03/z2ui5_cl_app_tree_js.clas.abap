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
             `        // Resolve the tree in the companion's OWN slot (main, popup,` && |\n| &&
             `        // popover, nested): byIdOfOwner works next to a tree in a dialog,` && |\n| &&
             `        // and unlike resolveById it never picks a same-id tree from another` && |\n| &&
             `        // open slot.` && |\n| &&
             `        const treeControl = ViewSlots.byIdOfOwner(` && |\n| &&
             `          this,` && |\n| &&
             `          this.getProperty("tree_id"),` && |\n| &&
             `        );` && |\n| &&
             `        return treeControl?.getBinding("items");` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Snapshots are keyed by tree_id so several trees on one page (e.g. a` && |\n| &&
             `      // main-view tree plus a tree in a popup) keep independent state - a` && |\n| &&
             `      // single shared slot would let one companion overwrite another's.` && |\n| &&
             `      setBackend() {` && |\n| &&
             `        try {` && |\n| &&
             `          const binding = this._getTreeBinding();` && |\n| &&
             `          const id = this.getProperty("tree_id");` && |\n| &&
             `          if (!id) return;` && |\n| &&
             `          // Only overwrite the snapshot when the binding is actually` && |\n| &&
             `          // resolvable - a momentarily missing binding must not wipe a` && |\n| &&
             `          // still-valid snapshot for this id.` && |\n| &&
             `          if (binding) {` && |\n| &&
             `            AppState.state.treeStates[id] = binding.getCurrentTreeState();` && |\n| &&
             `          }` && |\n| &&
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
             `        try {` && |\n| &&
             `          const id = this.getProperty("tree_id");` && |\n| &&
             `          const snapshot = id && AppState.state.treeStates[id];` && |\n| &&
             `          if (!snapshot) return;` && |\n| &&
             `          const binding = this._getTreeBinding();` && |\n| &&
             `          if (!binding) return;` && |\n| &&
             `          // Restore exactly once per (snapshot, binding) pair. setBackend` && |\n| &&
             `          // creates a fresh snapshot object each roundtrip, so a new` && |\n| &&
             `          // snapshot or a rebuilt binding is what triggers a restore -` && |\n| &&
             `          // NOT an incidental re-render (theme/density/parent` && |\n| &&
             `          // invalidation), which would otherwise force a spurious` && |\n| &&
             `          // refresh(true) and collapse the user's expansions back to the` && |\n| &&
             `          // last roundtrip snapshot.` && |\n| &&
             `          if (` && |\n| &&
             `            this._appliedSnapshot === snapshot &&` && |\n| &&
             `            this._appliedBinding === binding` && |\n| &&
             `          ) {` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          this._appliedSnapshot = snapshot;` && |\n| &&
             `          this._appliedBinding = binding;` && |\n| &&
             `          // setTreeState only stores an INITIAL tree state - the binding` && |\n| &&
             `          // adapter consumes it while creating its nodes, which already` && |\n| &&
             `          // happened during this rendering cycle. Force a rebuild so the` && |\n| &&
             `          // snapshot actually gets applied (headless-verified: without the` && |\n| &&
             `          // refresh the tree stays collapsed).` && |\n| &&
             `          binding.setTreeState(snapshot);` && |\n| &&
             `          binding.refresh(true);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Tree.onAfterRendering: setTreeState failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          Lib.renderInvisibleSpan(oRm, oControl);` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
