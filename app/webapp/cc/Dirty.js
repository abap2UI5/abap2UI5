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
        this.setProperty("isDirty", val);
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
          } else {
            syncUnloadPrompt(anyDirty);
          }
        } catch (e) {
          Lib.logError("Dirty.setIsDirty: setDirtyFlag failed", e);
          syncUnloadPrompt(anyDirty);
        }
      },
      exit() {
        dirtyControls.delete(this);
        this._applyDirtyState();
      },
      renderer: { apiVersion: 2, render() {} },
    });
  },
);
