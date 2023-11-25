CLASS z2ui5_cl_cc_timer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        view TYPE REF TO z2ui5_cl_xml_view optional.

    METHODS control
      IMPORTING
        finished      TYPE clike OPTIONAL
        delayms       TYPE clike OPTIONAL
        checkrepeat   TYPE clike OPTIONAL
          PREFERRED PARAMETER finished
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS get_js
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
    DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_CC_TIMER IMPLEMENTATION.


  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.


  METHOD control.

    result = mo_view.
    mo_view->_generic( name   = `Timer`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `delayMS`  v = delayms )
                                ( n = `finished`  v = finished )
                                ( n = `checkRepeat`  v = z2ui5_cl_fw_utility=>boolean_abap_2_json( checkrepeat ) )
              ) ).

  ENDMETHOD.


  METHOD get_js.

    result = ` jQuery.sap.declare("z2ui5.Timer");` && |\n| &&
    `sap.ui.require([` && |\n|  &&
    `   "sap/ui/core/Control"` && |\n|  &&
    `], (Control) => {` && |\n|  &&
    `   "use strict";` && |\n|  &&
    |\n|  &&
    `   return Control.extend("z2ui5.Timer", {` && |\n|  &&
    `       metadata : {` && |\n|  &&
    `           properties: {` && |\n|  &&
    `                delayMS: {` && |\n|  &&
    `                    type: "string",` && |\n|  &&
    `                    defaultValue: ""` && |\n|  &&
    `                },` && |\n|  &&
    `                checkRepeat: {` && |\n|  &&
    `                    type: "boolean",` && |\n|  &&
    `                    defaultValue: false` && |\n|  &&
    `                },` && |\n|  &&
    `            },` && |\n|  &&
    `            events: {` && |\n|  &&
    `                 "finished": { ` && |\n|  &&
    `                        allowPreventDefault: true,` && |\n|  &&
    `                        parameters: {},` && |\n|  &&
    `                 }` && |\n|  &&
    `            }` && |\n|  &&
    `       },` && |\n|  &&
    `       onAfterRendering() {` && |\n|  &&
    `       },` && |\n|  &&
    `       delayedCall( oControl){` && |\n|  &&
    `           ` && |\n|  &&
    `            setTimeout((oControl) => {` && |\n|  &&
    `                oControl.fireFinished();` && |\n|  &&
    `              if ( oControl.getProperty( "checkRepeat" ) ) { oControl.delayedCall( oControl ); }  ` && |\n|  &&
    `              }, parseInt( oControl.getProperty("delayMS") ), oControl );` && |\n|  &&
    `       },` && |\n|  &&
    `       renderer(oRm, oControl) {` && |\n|  &&
    `        oControl.delayedCall( oControl );` && |\n|  &&
    `        }` && |\n|  &&
    `   });` && |\n|  &&
    `});`.

  ENDMETHOD.
ENDCLASS.
