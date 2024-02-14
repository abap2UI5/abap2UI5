CLASS z2ui5_cl_fw_cc_favicon DEFINITION
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



CLASS z2ui5_cl_fw_cc_favicon IMPLEMENTATION.


  METHOD get_js.

    result = `sap.ui.define("z2ui5/Favicon" , ["sap/ui/core/Control"], (Control)=>{` && |\n| &&
             `        "use strict";` && |\n| &&
             `        return Control.extend("z2ui5.Favicon", {` && |\n| &&
             `            metadata: {` && |\n| &&
             `                properties: {` && |\n| &&
             `                    favicon: {` && |\n| &&
             `                        type: "string"` && |\n| &&
             `                    },` && |\n| &&
             `                }` && |\n| &&
             `            },` && |\n| &&
             `            setFavicon(val) {` && |\n| &&
             `                this.setProperty("favicon", val);` && |\n| &&
             `                let headTitle = document.querySelector('head');` && |\n| &&
             `                let setFavicon = document.createElement('link');` && |\n| &&
             `                setFavicon.setAttribute('rel','shortcut icon');` && |\n| &&
             `                setFavicon.setAttribute('href',val);` && |\n| &&
             `                headTitle.appendChild(setFavicon);` && |\n| &&
             `            },` && |\n| &&
             `            renderer(oRm, oControl) {}` && |\n| &&
             `        });` && |\n| &&
             `  });`.

  ENDMETHOD.
ENDCLASS.
