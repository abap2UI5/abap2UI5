CLASS z2ui5_cl_cc_info DEFINITION
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
        ui5_version TYPE any OPTIONAL
        ui5_gav TYPE any OPTIONAL
        ui5_theme TYPE any OPTIONAL
        device_os TYPE any OPTIONAL
        device_systemtype TYPE any OPTIONAL
        device_browser TYPE any OPTIONAL
        preferred parameter FINISHED
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS load_cc
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS get_js
      RETURNING
        VALUE(r_js) TYPE string.

  PROTECTED SECTION.
      DATA mo_view TYPE REF TO z2ui5_cl_xml_view.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_cc_info IMPLEMENTATION.

  METHOD constructor.

    me->mo_view = view.

  ENDMETHOD.

method control.

 result = mo_view.
    mo_view->_generic( name   = `Info`
              ns     = `z2ui5`
              t_prop = VALUE #( ( n = `ui5_version`  v = ui5_version )
                                ( n = `ui5_gav`  v = ui5_gav )
                                ( n = `finished`  v = finished )
                                ( n = `ui5_theme`  v = ui5_theme )
                                ( n = `device_os`  v = device_os )
                                ( n = `device_systemtype`  v = device_systemtype )
                                ( n = `device_browser`  v = device_browser )
              ) ).

ENDMETHOD.

  METHOD load_cc.

    data(js) = get_js( ).
    result = mo_view->_generic( ns = `html` name = `script` )->_cc_plain_xml( js )->get_parent( ).

  ENDMETHOD.


  METHOD get_js.

    r_js  = ` jQuery.sap.declare("z2ui5.Info");` && |\n| &&
  `sap.ui.require([` && |\n|  &&
  `   "sap/ui/core/Control"` && |\n|  &&
  `], (Control) => {` && |\n|  &&
  `   "use strict";` && |\n|  &&
  |\n|  &&
  `   return Control.extend("z2ui5.Info", {` && |\n|  &&
  `       metadata : {` && |\n|  &&
  `           properties: {` && |\n|  &&
  `                ui5_version: {` && |\n|  &&
  `                    type: "string"` && |\n|  &&
  `                },` && |\n|  &&
  `                ui5_gav: {` && |\n|  &&
  `                    type: "string"` && |\n|  &&
  `                },` && |\n|  &&
  `                ui5_theme: {` && |\n|  &&
  `                    type: "string"` && |\n|  &&
  `                },` && |\n|  &&
  `                device_os: {` && |\n|  &&
  `                    type: "string"` && |\n|  &&
  `                },` && |\n|  &&
  `                device_systemtype: {` && |\n|  &&
  `                    type: "string"` && |\n|  &&
  `                },` && |\n|  &&
  `                device_browser: {` && |\n|  &&
  `                    type: "string"` && |\n|  &&
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
  `            oControl.setProperty( "ui5_version" ,  sap.ui.version );` && |\n|  &&
  `            oControl.setProperty( "ui5_gav" ,  sap.ui.getVersionInfo().gav );` && |\n|  &&
  `            oControl.setProperty( "device_os" ,  sap.ui.Device.os.name );` && |\n|  &&
  `          //  this.setProperty( "device_systemtype" ,  sap.ui.getVersionInfo().gav );` && |\n|  &&
  `          oControl.setProperty( "device_browser" ,  sap.ui.Device.browser.name );` && |\n|  &&
  `          oControl.fireFinished();` && |\n|  &&
  `            ` && |\n|  &&
  `        }` && |\n|  &&
  `   });` && |\n|  &&
  `});`.

  ENDMETHOD.

ENDCLASS.
