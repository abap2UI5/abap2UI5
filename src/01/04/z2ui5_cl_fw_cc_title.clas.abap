CLASS z2ui5_cl_fw_cc_title DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_cc_title IMPLEMENTATION.

  METHOD get_js.

    result = `sap.ui.define("z2ui5/Title" , ["sap/ui/core/Control"], (Control)=>{` && |\n| &&
             `        "use strict";` && |\n| &&
             `        return Control.extend("z2ui5.Title", {` && |\n| &&
             `            metadata: {` && |\n| &&
             `                properties: {` && |\n| &&
             `                    title: {` && |\n| &&
             `                        type: "string"` && |\n| &&
             `                    },` && |\n| &&
             `                }` && |\n| &&
             `            },` && |\n| &&
             `            setTitle(val) {` && |\n| &&
             `                this.setProperty("title", val);` && |\n| &&
             `                document.title = val;` && |\n| &&
             `            },` && |\n| &&
             `            renderer(oRm, oControl) {}` && |\n| &&
             `        });` && |\n| &&
             `  });`.

  ENDMETHOD.

ENDCLASS.
