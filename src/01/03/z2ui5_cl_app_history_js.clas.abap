CLASS z2ui5_cl_app_history_js DEFINITION
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


CLASS z2ui5_cl_app_history_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.cc.History", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        search: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setSearch(val) {` && |\n| &&
             `      this.setProperty("search", val);` && |\n| &&
             `      try {` && |\n| &&
             `        const search = Lib.toText(val);` && |\n| &&
             `        // Pass the current state object along: _processAfterRendering stores` && |\n| &&
             `        // the rendered view/model in history.state so the back button can` && |\n| &&
             `        // restore it without a roundtrip - replacing it with null would` && |\n| &&
             `        // break that popstate restore.` && |\n| &&
             `        history.replaceState(` && |\n| &&
             `          history.state,` && |\n| &&
             `          "",` && |\n| &&
             `          ``${window.location.pathname}${search}``,` && |\n| &&
             `        );` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("History.setSearch: replaceState failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
