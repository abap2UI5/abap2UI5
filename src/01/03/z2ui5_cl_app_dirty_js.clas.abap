CLASS z2ui5_cl_app_dirty_js DEFINITION
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


CLASS z2ui5_cl_app_dirty_js IMPLEMENTATION.

  METHOD get.

    result = `// Invisible control that marks the session as having unsaved changes:` && |\n| &&
             `// inside the Launchpad via the FLP dirty flag, standalone via the` && |\n| &&
             `// browser's "leave page?" confirmation prompt.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/AppState"],` && |\n| &&
             `  (Control, Lib, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Every live Dirty instance that is currently dirty. The FLP dirty flag` && |\n| &&
             `    // and the browser's onbeforeunload are single global slots, so the guard` && |\n| &&
             `    // must reflect whether ANY instance is dirty - one instance clearing its` && |\n| &&
             `    // own flag (or being destroyed) must not wipe another instance's unsaved` && |\n| &&
             `    // guard (e.g. a main-view form plus a form in a dialog).` && |\n| &&
             `    const dirtyControls = new Set();` && |\n| &&
             `` && |\n| &&
             `    function syncUnloadPrompt(anyDirty) {` && |\n| &&
             `      window.onbeforeunload = anyDirty` && |\n| &&
             `        ? (e) => {` && |\n| &&
             `            e.preventDefault();` && |\n| &&
             `            e.returnValue = "";` && |\n| &&
             `          }` && |\n| &&
             `        : null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.cc.Dirty", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          isDirty: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      setIsDirty(val) {` && |\n| &&
             `        // Empty renderer -> suppress the no-op invalidation; the dirty state` && |\n| &&
             `        // is applied explicitly below.` && |\n| &&
             `        this.setProperty("isDirty", val, true);` && |\n| &&
             `        if (val) {` && |\n| &&
             `          dirtyControls.add(this);` && |\n| &&
             `        } else {` && |\n| &&
             `          dirtyControls.delete(this);` && |\n| &&
             `        }` && |\n| &&
             `        this._applyDirtyState();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Apply the AGGREGATE dirty state (any instance dirty) to whichever` && |\n| &&
             `      // mechanism is active: the FLP dirty flag inside the Launchpad (SAPUI5` && |\n| &&
             `      // only), else the browser unload prompt.` && |\n| &&
             `      _applyDirtyState() {` && |\n| &&
             `        const anyDirty = dirtyControls.size > 0;` && |\n| &&
             `        try {` && |\n| &&
             `          const launchpad = AppState.state.oLaunchpad;` && |\n| &&
             `          const hasFlpDirtyFlag =` && |\n| &&
             `            launchpad?.Container?.setDirtyFlag && launchpad.ShellUIService;` && |\n| &&
             `          if (hasFlpDirtyFlag) {` && |\n| &&
             `            launchpad.Container.setDirtyFlag(anyDirty);` && |\n| &&
             `          } else {` && |\n| &&
             `            syncUnloadPrompt(anyDirty);` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Dirty.setIsDirty: setDirtyFlag failed", e);` && |\n| &&
             `          syncUnloadPrompt(anyDirty);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        dirtyControls.delete(this);` && |\n| &&
             `        this._applyDirtyState();` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
