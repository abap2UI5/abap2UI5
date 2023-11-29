CLASS z2ui5_cl_cc_focus DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_FOCUS IMPLEMENTATION.


  METHOD get_js.

    result = `jQuery.sap.declare("z2ui5.Focus");` && |\n|  &&
             `sap.ui.require([` && |\n|  &&
             `  "sap/ui/core/Control",` && |\n|  &&
             `], (Control) => {` && |\n|  &&
             `  "use strict";` && |\n|  &&
             |\n|  &&
             `  return Control.extend("z2ui5.Focus", {` && |\n|  &&
             `      metadata: {` && |\n|  &&
             `          properties: {` && |\n|  &&
             `              setUpdate : { type: "boolean", defaultValue: true },` && |\n|  &&
             `              focusId: { type: "string" },` && |\n|  &&
             `              selectionStart: { type: "string", defaultValue: "0" },` && |\n|  &&
             `              selectionEnd: { type: "string", defaultValue: "0" },` && |\n|  &&
             `          }` && |\n|  &&
             `      },` && |\n|  &&
             |\n|  &&
             `      init() {` && |\n|  &&
             `      },` && |\n|  &&
             |\n|  &&
             `      renderer(oRm, oControl) {` && |\n|  &&
             |\n|  &&
             `        if (!oControl.getProperty("setUpdate")){ return; }` && |\n|  &&
             `            oControl.setProperty("setUpdate", false);` && |\n|  &&
             |\n|  &&
             `          setTimeout((oControl) => {` && |\n|  &&
             |\n|  &&
             `            debugger;  var oElement = sap.z2ui5.oView.byId(oControl.getProperty("focusId"));` && |\n|  &&
             `              var oFocus = oElement.getFocusInfo();` && |\n|  &&
             `              oFocus.selectionStart = parseInt(oControl.getProperty("selectionStart"));` && |\n|  &&
             `              oFocus.selectionEnd = parseInt(oControl.getProperty("selectionEnd"));` && |\n|  &&
             `              oElement.applyFocusInfo(oFocus);` && |\n|  &&
             |\n|  &&
             `          }, 100, oControl);` && |\n|  &&
             |\n|  &&
             `      }` && |\n|  &&
             `  });` && |\n|  &&
             `});`.

  ENDMETHOD.


ENDCLASS.
