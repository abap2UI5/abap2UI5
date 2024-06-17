CLASS z2ui5_cl_cc_lp_title DEFINITION
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



CLASS z2ui5_cl_cc_lp_title IMPLEMENTATION.

  METHOD get_js.

    result = `if (!z2ui5.LPTitle) { sap.ui.define("z2ui5/LPTitle" , ["sap/ui/core/Control"], (Control)=>{` && |\n| &&
             `        "use strict";` && |\n| &&
             `        return Control.extend("z2ui5.LPTitle", {` && |\n| &&
             `            metadata: {` && |\n| &&
             `                properties: {` && |\n| &&
             `                    title: {` && |\n| &&
             `                        type: "string"` && |\n| &&
             `                    },` && |\n| &&
             `                }` && |\n| &&
             `            },` && |\n| &&
             `            setTitle(val) {` && |\n| &&
             `                try { ` && |\n| &&
             `                this.setProperty("title", val);` && |\n| &&
             `                sap.z2ui5.oLaunchpadService.setTitle( val );` && |\n| &&
             `               } catch (e) { console.error("Launchpad Service to set Title not found");  }` && |\n| &&
             `            },` && |\n| &&
             `            renderer(oRm, oControl) {}` && |\n| &&
             `        });` && |\n| &&
             `  }); }`.

  ENDMETHOD.

ENDCLASS.
