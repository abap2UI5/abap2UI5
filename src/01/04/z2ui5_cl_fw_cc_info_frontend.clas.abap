CLASS z2ui5_cl_fw_cc_info_frontend DEFINITION
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



CLASS z2ui5_cl_fw_cc_info_frontend IMPLEMENTATION.


  METHOD get_js.

    result  = `sap.ui.define("z2ui5/Info",[` && |\n| &&
      `   "sap/ui/core/Control"` && |\n| &&
      `], (Control) => {` && |\n| &&
      `   "use strict";` && |\n| &&
      |\n| &&
      `   return Control.extend("z2ui5.Info", {` && |\n| &&
      `       metadata : {` && |\n| &&
      `           properties: {` && |\n| &&
      `                ui5_version: {` && |\n| &&
      `                    type: "string"` && |\n| &&
      `                },` && |\n| &&
      `                ui5_gav: {` && |\n| &&
      `                    type: "string"` && |\n| &&
      `                },` && |\n| &&
      `                ui5_theme: {` && |\n| &&
      `                    type: "string"` && |\n| &&
      `                },` && |\n| &&
      `                device_os: {` && |\n| &&
      `                    type: "string"` && |\n| &&
      `                },` && |\n| &&
      `                device_systemtype: {` && |\n| &&
      `                    type: "string"` && |\n| &&
      `                },` && |\n| &&
      `                device_browser: {` && |\n| &&
      `                    type: "string"` && |\n| &&
      `                },` && |\n| &&
      `            },` && |\n| &&
      `            events: {` && |\n| &&
      `                 "finished": { ` && |\n| &&
      `                        allowPreventDefault: true,` && |\n| &&
      `                        parameters: {},` && |\n| &&
      `                 }` && |\n| &&
      `            }` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       init () {` && |\n| &&
      |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       onAfterRendering() {` && |\n| &&
      |\n| &&
      `       },` && |\n| &&
      `       ` && |\n| &&
      `       renderer(oRm, oControl) {` && |\n| &&
      |\n| &&
      `            oControl.setProperty( "ui5_version" ,  sap.ui.version );` && |\n| &&
      `            oControl.setProperty( "ui5_gav" ,  sap.ui.getVersionInfo().gav );` && |\n| &&
      `            oControl.setProperty( "device_os" ,  sap.ui.Device.os.name );` && |\n| &&
      `          //  this.setProperty( "device_systemtype" ,  sap.ui.getVersionInfo().gav );` && |\n| &&
      `          oControl.setProperty( "device_browser" ,  sap.ui.Device.browser.name );` && |\n| &&
      `          oControl.fireFinished();` && |\n| &&
      `            ` && |\n| &&
      `        }` && |\n| &&
      `   });` && |\n| &&
      `});`.

  ENDMETHOD.

ENDCLASS.
