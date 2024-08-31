CLASS z2ui5_cl_cc_dirty DEFINITION
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



CLASS z2ui5_cl_cc_dirty IMPLEMENTATION.

  METHOD get_js.

    result = `if (!z2ui5.Dirty) { sap.ui.define("z2ui5/Dirty" , ["sap/ui/core/Control"], (Control)=>{` && |\n| &&
             `        "use strict";` && |\n| &&
             `        return Control.extend("z2ui5.Dirty", {` && |\n| &&
             `            metadata: {` && |\n| &&
             `                properties: {` && |\n| &&
             `                    isDirty: {` && |\n| &&
             `                        type: "string"` && |\n| &&
             `                    },` && |\n| &&
             `                }` && |\n| &&
             `            },` && |\n| &&
             `            setIsDirty(val) {` && |\n| &&
                `         //  var dirty = !!sap.z2ui5.oResponse.PARAMS?.DIRTY;` && |\n| &&
               `            if (sap.ushell?.Container) {` && |\n| &&
               `                sap.ushell.Container.setDirtyFlag(val);` && |\n| &&
               `            } else {` && |\n| &&
               `                window.onbeforeunload = function (e) { ` && |\n| &&
               `                    if (val) {` && |\n| &&
               `                        e.preventDefault();    ` && |\n| &&
               `                    }                ` && |\n| &&
               `                }        ` && |\n| &&
               `            }` && |\n| &&
             `            },` && |\n| &&
             `            renderer(oRm, oControl) {}` && |\n| &&
             `        });` && |\n| &&
             `  }); }`.

  ENDMETHOD.

ENDCLASS.
