CLASS z2ui5_cl_app_lptitle_js DEFINITION
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


CLASS z2ui5_cl_app_lptitle_js IMPLEMENTATION.

  METHOD get.

    result = `// Invisible control that sets the Launchpad shell title and the` && |\n| &&
             `// full-width mode when the app runs inside the FLP; does nothing when` && |\n| &&
             `// running standalone.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/AppState"],` && |\n| &&
             `  (Control, Lib, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return Control.extend("z2ui5.cc.LPTitle", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          title: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          ApplicationFullWidth: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      setTitle(val) {` && |\n| &&
             `        this.setProperty("title", val);` && |\n| &&
             `        try {` && |\n| &&
             `          const shell = AppState.state.oLaunchpad?.ShellUIService;` && |\n| &&
             `          if (!shell?.setTitle) return;` && |\n| &&
             `          // Same normalization as the SET_TITLE_LAUNCHPAD frontend action:` && |\n| &&
             `          // never hand undefined/null to the shell service.` && |\n| &&
             `          const result = shell.setTitle(Lib.toText(val));` && |\n| &&
             `          // setTitle may return a Promise; report any async failure.` && |\n| &&
             `          if (result?.catch) {` && |\n| &&
             `            result.catch((e) =>` && |\n| &&
             `              Lib.logError("LPTitle: Launchpad Service setTitle failed", e),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("LPTitle: Launchpad Service setTitle failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      setApplicationFullWidth(val) {` && |\n| &&
             `        this.setProperty("ApplicationFullWidth", val);` && |\n| &&
             `        try {` && |\n| &&
             `          const config = AppState.state.oLaunchpad?.AppConfiguration;` && |\n| &&
             `          if (config?.setApplicationFullWidth) {` && |\n| &&
             `            config.setApplicationFullWidth(val);` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("LPTitle: setApplicationFullWidth failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
