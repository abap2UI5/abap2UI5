CLASS z2ui5_cl_cc_timer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view.

    METHODS control
      IMPORTING
        finished TYPE clike OPTIONAL
        delayMS  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS load_cc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

  PROTECTED SECTION.
      DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_cc_timer IMPLEMENTATION.

  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.

method control.

 result = mo_view.
    mo_view->_generic( name   = `CCTimer`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `delayMS`  v = delayMS )
                                ( n = `finished`  v = finished )
              ) ).

ENDMETHOD.

  METHOD load_cc.

    DATA(js) = ` jQuery.sap.declare("z2ui5.CCTimer");` && |\n| &&
    `sap.ui.require([` && |\n|  &&
    `   "sap/ui/core/Control"` && |\n|  &&
    `], (Control) => {` && |\n|  &&
    `   "use strict";` && |\n|  &&
    |\n|  &&
    `   return Control.extend("z2ui5.CCTimer", {` && |\n|  &&
    `       metadata : {` && |\n|  &&
    `           properties: {` && |\n|  &&
    `                delayMS: {` && |\n|  &&
    `                    type: "string",` && |\n|  &&
    `                    defaultValue: ""` && |\n|  &&
    `                },` && |\n|  &&
    `            },` && |\n|  &&
    `            events: {` && |\n|  &&
    `                 "finished": { ` && |\n|  &&
    `                        allowPreventDefault: true,` && |\n|  &&
    `                        parameters: {},` && |\n|  &&
    `                 }` && |\n|  &&
    `            }` && |\n|  &&
    `       },` && |\n|  &&
    |\n|  &&
    `       init () {` && |\n|  &&
    |\n|  &&
    `       },` && |\n|  &&
    |\n|  &&
    `       onAfterRendering() {` && |\n|  &&
    |\n|  &&
    `       },` && |\n|  &&
    `       ` && |\n|  &&
    `       renderer(oRm, oControl) {` && |\n|  &&
    |\n|  &&
    `            setTimeout((oControl) => {` && |\n|  &&
    `                oControl.fireFinished();` && |\n|  &&
    `              }, parseInt( oControl.getProperty("delayMS") ), oControl );` && |\n|  &&
    `        }` && |\n|  &&
    `   });` && |\n|  &&
    `});`.

    result = mo_view->_cc_plain_xml( `<html:script>` && js && `</html:script>` ).

  ENDMETHOD.

ENDCLASS.
