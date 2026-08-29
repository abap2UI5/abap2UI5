// Invisible control that marks the session as having unsaved changes:
// inside the Launchpad via the FLP dirty flag, standalone via the
// browser's "leave page?" confirmation prompt.
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/AppState"],
  (Control, Lib, AppState) => {
    "use strict";

    // Every live Dirty instance that is currently dirty. The FLP dirty flag
    // and the browser's onbeforeunload are single global slots, so the guard
    // must reflect whether ANY instance is dirty - one instance clearing its
    // own flag (or being destroyed) must not wipe another instance's unsaved
    // guard (e.g. a main-view form plus a form in a dialog).
    const dirtyControls = new Set();

    function syncUnloadPrompt(anyDirty) {
      window.onbeforeunload = anyDirty
        ? (e) => {
            e.preventDefault();
            e.returnValue = "";
          }
        : null;
    }

    return Control.extend("z2ui5.cc.Dirty", {
      metadata: {
        properties: {
          isDirty: {
            type: "boolean",
            defaultValue: false,
          },
        },
      },
      setIsDirty(val) {
        // Empty renderer -> suppress the no-op invalidation; the effect below
        // (applying the dirty state) is what actually matters.
        this.setProperty("isDirty", val, true);
        if (val) {
          dirtyControls.add(this);
        } else {
          dirtyControls.delete(this);
        }
        this._applyDirtyState();
      },

      // Apply the AGGREGATE dirty state (any instance dirty) to whichever
      // mechanism is active: the FLP dirty flag inside the Launchpad (SAPUI5
      // only), else the browser unload prompt.
      _applyDirtyState() {
        const anyDirty = dirtyControls.size > 0;
        try {
          const launchpad = AppState.state.oLaunchpad;
          const hasFlpDirtyFlag =
            launchpad?.Container?.setDirtyFlag && launchpad.ShellUIService;
          if (hasFlpDirtyFlag) {
            launchpad.Container.setDirtyFlag(anyDirty);
            // the branch is decided PER CALL, and ShellUIService arrives
            // asynchronously (Component._initLaunchpad): a setIsDirty(true)
            // before it resolved took the else branch and set the unload
            // prompt - clear it here, or the FLP user keeps answering a
            // "leave page?" dialog for a dirty state that is long gone
            syncUnloadPrompt(false);
          } else {
            syncUnloadPrompt(anyDirty);
          }
        } catch (e) {
          Lib.logError("Dirty._applyDirtyState: setDirtyFlag failed", e);
          syncUnloadPrompt(anyDirty);
        }
      },
      exit() {
        dirtyControls.delete(this);
        this._applyDirtyState();
      },
      renderer: Lib.EMPTY_RENDERER,
    });
  },
);
