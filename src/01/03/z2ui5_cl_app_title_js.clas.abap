CLASS z2ui5_cl_app_title_js DEFINITION
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


CLASS z2ui5_cl_app_title_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.Title", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        title: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setTitle(val) {` && |\n| &&
             `      this.setProperty("title", val);` && |\n| &&
             `      document.title = val == null ? "" : String(val);` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
