CLASS z2ui5_cl_cc_timer DEFINITION
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



CLASS Z2UI5_CL_CC_TIMER IMPLEMENTATION.

  METHOD get_js.

    result = `jQuery.sap.declare("z2ui5.Timer");` && |\n| &&
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
    `                checkActive: {` && |\n|  &&
    `                    type: "boolean",` && |\n|  &&
    `                    defaultValue: true` && |\n|  &&
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
    `          if ( oControl.getProperty("checkActive") == false ){ return; }` && |\n|  &&
    `            setTimeout((oControl) => {` && |\n|  &&
    `               oControl.setProperty( "checkActive", false )` && |\n|  &&
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
