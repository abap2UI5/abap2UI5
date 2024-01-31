class Z2UI5_CL_FW_CC_FAVICON definition
  public
  final
  create public .

public section.

  class-methods GET_JS
    returning
      value(RESULT) type STRING .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_CC_FAVICON IMPLEMENTATION.


  METHOD GET_JS.

    result =  `sap.ui.define("z2ui5/Favicon" , ["sap/ui/core/Control"], (Control)=>{` && |\n|  &&
             `        "use strict";` && |\n|  &&
             `        return Control.extend("z2ui5.Favicon", {` && |\n|  &&
             `            metadata: {` && |\n|  &&
             `                properties: {` && |\n|  &&
             `                    favicon: {` && |\n|  &&
             `                        type: "string"` && |\n|  &&
             `                    },` && |\n|  &&
             `                }` && |\n|  &&
             `            },` && |\n|  &&
             `            setFavicon(val) {` && |\n|  &&
             `                this.setProperty("favicon", val);` && |\n|  &&
             `                let headTitle = document.querySelector('head');` && |\n|  &&
             `                let setFavicon = document.createElement('link');` && |\n|  &&
             `                setFavicon.setAttribute('rel','shortcut icon');` && |\n|  &&
             `                setFavicon.setAttribute('href',val);` && |\n|  &&
             `                headTitle.appendChild(setFavicon);` && |\n|  &&
             `            },` && |\n|  &&
             `            renderer(oRm, oControl) {}` && |\n|  &&
             `        });` && |\n|  &&
             `  });`.

  ENDMETHOD.
ENDCLASS.
