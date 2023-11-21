CLASS z2ui5_cl_cc_focus DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view.

    METHODS control
      IMPORTING
        focusId          TYPE clike OPTIONAL
        selectionStart   TYPE clike OPTIONAL
        selectionEnd     TYPE clike OPTIONAL
        setUpdate        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS load_cc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_cc_focus IMPLEMENTATION.

  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.

  METHOD control.

    result = mo_view.
    mo_view->_generic( name   = `Focus`
              ns     = `z2ui5`
              t_prop = VALUE #(
                ( n = `setUpdate`       v = setUpdate )
                ( n = `selectionStart`  v = selectionStart )
                ( n = `selectionEnd`    v = selectionEnd )
                ( n = `focusId`         v = focusId )
       ) ).

  ENDMETHOD.

  METHOD load_cc.

    result = mo_view->_generic( ns = `html` name = `script` )->_cc_plain_xml( get_js( ) )->get_parent( ).

  ENDMETHOD.

  METHOD get_js.

    result = `debugger; jQuery.sap.declare("z2ui5.Focus");` && |\n|  &&
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
             `  debugger;        if (!oControl.getProperty("setUpdate")){ return; }` && |\n|  &&
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
             `          }, 10, oControl);` && |\n|  &&
             |\n|  &&
             `      }` && |\n|  &&
             `  });` && |\n|  &&
             `});`.

  ENDMETHOD.

ENDCLASS.
