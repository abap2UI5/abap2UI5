sap.ui.define(
  [
    "sap/ui/core/Control",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/Context",
  ],
  (Control, Lib, ViewSlots, Context) => {
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
        // Resolve the tree in the companion's OWN slot (main, popup,
        // popover, nested): byIdOfOwner works next to a tree in a dialog,
        // and unlike resolveById it never picks a same-id tree from another
        // open slot.
        const treeControl = ViewSlots.byIdOfOwner(
          this,
          this.getProperty("tree_id"),
        );
        return treeControl?.getBinding("items");
      },

      // The snapshot store of the companion's component (state.treeStates
      // of its context). Null for a companion in no component (Context.of
      // answers null): there is nowhere to keep a snapshot, and nothing to
      // restore from - logged ONCE per instance (onAfterRendering runs on
      // every re-render) and the control keeps rendering, it just does
      // not preserve anything.
      _treeStates(where) {
        const states = Context.of(this)?.state.treeStates;
        if (states) return states;
        if (!this._noContextLogged) {
          this._noContextLogged = true;
          Lib.logError(
            `Tree.${where}: no component context, tree state not preserved`,
          );
        }
        return null;
      },

      // Snapshots are keyed by tree_id so several trees on one page (e.g. a
      // main-view tree plus a tree in a popup) keep independent state - a
      // single shared slot would let one companion overwrite another's.
      setBackend() {
        try {
          const id = this.getProperty("tree_id");
          if (!id) return;
          const treeStates = this._treeStates("setBackend");
          if (!treeStates) return;
          const binding = this._getTreeBinding();
          // Only overwrite the snapshot when the binding is actually
          // resolvable - a momentarily missing binding must not wipe a
          // still-valid snapshot for this id.
          if (binding) {
            treeStates[id] = binding.getCurrentTreeState();
          }
        } catch (e) {
          Lib.logError("Tree.setBackend: failed", e);
        }
      },

      init() {
        this._unhook = Lib.hookCallback(
          this,
          "onBeforeRoundtrip",
          "setBackend",
        );
      },

      exit() {
        this._unhook();
        // The snapshot under treeStates[tree_id] deliberately outlives this
        // instance: a view rebuild destroys the old Tree BEFORE the new one
        // renders, and the new one restores its expansion from exactly that
        // snapshot (onAfterRendering below). It goes with the app switch
        // (View1._processAfterRendering) and the component teardown
        // (Context.destroy rebuilds the state), not here.
      },

      onAfterRendering() {
        try {
          const id = this.getProperty("tree_id");
          if (!id) return;
          const snapshot = this._treeStates("onAfterRendering")?.[id];
          if (!snapshot) return;
          const binding = this._getTreeBinding();
          if (!binding) return;
          // Restore exactly once per (snapshot, binding) pair. setBackend
          // creates a fresh snapshot object each roundtrip, so a new
          // snapshot or a rebuilt binding is what triggers a restore -
          // NOT an incidental re-render (theme/density/parent
          // invalidation), which would otherwise force a spurious
          // refresh(true) and collapse the user's expansions back to the
          // last roundtrip snapshot.
          if (
            this._appliedSnapshot === snapshot &&
            this._appliedBinding === binding
          ) {
            return;
          }
          this._appliedSnapshot = snapshot;
          this._appliedBinding = binding;
          // setTreeState only stores an INITIAL tree state - the binding
          // adapter consumes it while creating its nodes, which already
          // happened during this rendering cycle. Force a rebuild so the
          // snapshot actually gets applied (headless-verified: without the
          // refresh the tree stays collapsed).
          binding.setTreeState(snapshot);
          binding.refresh(true);
        } catch (e) {
          Lib.logError("Tree.onAfterRendering: setTreeState failed", e);
        }
      },

      renderer: { apiVersion: 2, render: Lib.renderInvisibleSpan },
    });
  },
);
