CLASS z2ui5_cl_cc_history DEFINITION
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



CLASS Z2UI5_CL_CC_HISTORY IMPLEMENTATION.


  METHOD get_js.

    result = `jQuery.sap.declare("z2ui5.History");` && |\n|  &&
             `sap.ui.require(["sap/ui/core/Control"], (Control)=>{` && |\n|  &&
             `        "use strict";` && |\n|  &&
             `        return Control.extend("z2ui5.History", {` && |\n|  &&
             `            metadata: {` && |\n|  &&
             `                properties: {` && |\n|  &&
             `                    search: {` && |\n|  &&
             `                        type: "string"` && |\n|  &&
             `                    },` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            setSearch(val) {` && |\n|  &&
             `                this.setProperty("search", val);` && |\n|  &&
             `                history.replaceState(null, null, window.location.pathname + val );` && |\n|  &&
             `            },` && |\n|  &&
             `            renderer(oRm, oControl) {}` && |\n|  &&
             `        });` && |\n|  &&
             `  });`.

  ENDMETHOD.

ENDCLASS.
