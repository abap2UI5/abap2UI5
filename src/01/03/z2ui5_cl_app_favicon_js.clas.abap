CLASS z2ui5_cl_app_favicon_js DEFINITION
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


CLASS z2ui5_cl_app_favicon_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(["sap/ui/core/Control"], (Control) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.cc.Favicon", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        favicon: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setFavicon(val) {` && |\n| &&
             `      this.setProperty("favicon", val);` && |\n| &&
             `      const existing = document.head.querySelector('link[rel="shortcut icon"]');` && |\n| &&
             `      if (existing) {` && |\n| &&
             `        existing.href = val;` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const link = document.createElement("link");` && |\n| &&
             `      link.rel = "shortcut icon";` && |\n| &&
             `      link.href = val;` && |\n| &&
             `      document.head.appendChild(link);` && |\n| &&
             `    },` && |\n| &&
             `    renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
