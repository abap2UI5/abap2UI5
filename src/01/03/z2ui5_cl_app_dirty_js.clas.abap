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
             `        this.setProperty("isDirty", val);` && |\n| &&
             `` && |\n| &&
             `        // Fallback for non-launchpad scenarios: ask the browser to confirm` && |\n| &&
             `        // before leaving the page when something is unsaved.` && |\n| &&
             `        const fallback = () => {` && |\n| &&
             `          if (val) {` && |\n| &&
             `            window.onbeforeunload = (e) => {` && |\n| &&
             `              e.preventDefault();` && |\n| &&
             `              e.returnValue = "";` && |\n| &&
             `            };` && |\n| &&
             `          } else {` && |\n| &&
             `            window.onbeforeunload = null;` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `` && |\n| &&
             `        // Use the FLP dirty flag when running inside the Launchpad (SAPUI5` && |\n| &&
             `        // only); otherwise fall back to the browser unload prompt.` && |\n| &&
             `        try {` && |\n| &&
             `          const launchpad = AppState.state.oLaunchpad;` && |\n| &&
             `          const hasFlpDirtyFlag =` && |\n| &&
             `            launchpad?.Container?.setDirtyFlag && launchpad.ShellUIService;` && |\n| &&
             `          if (hasFlpDirtyFlag) {` && |\n| &&
             `            launchpad.Container.setDirtyFlag(val);` && |\n| &&
             `          } else {` && |\n| &&
             `            fallback();` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Dirty.setIsDirty: setDirtyFlag failed", e);` && |\n| &&
             `          fallback();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        window.onbeforeunload = null;` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
