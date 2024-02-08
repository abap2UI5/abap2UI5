CLASS z2ui5_cl_fw_cc_geolocation DEFINITION
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



CLASS z2ui5_cl_fw_cc_geolocation IMPLEMENTATION.


  METHOD get_js.

    result  = `sap.ui.define("z2ui5/Geolocation" , [` && |\n| &&
      `   "sap/ui/core/Control"` && |\n| &&
      `], (Control) => {` && |\n| &&
      `   "use strict";` && |\n| &&
      |\n| &&
      `   return Control.extend("z2ui5.Geolocation", {` && |\n| &&
      `       metadata : {` && |\n| &&
      `           properties: {` && |\n| &&
      `                longitude: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: ""` && |\n| &&
      `                },` && |\n| &&
      `               latitude: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: ""` && |\n| &&
      `                },` && |\n| &&
      `               altitude: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: ""` && |\n| &&
      `                },` && |\n| &&
      `               accuracy: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: ""` && |\n| &&
      `                },` && |\n| &&
      `               altitudeAccuracy: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: ""` && |\n| &&
      `                },` && |\n| &&
      `               speed: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: false` && |\n| &&
      `                },` && |\n| &&
      `               heading: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: false` && |\n| &&
      `                },` && |\n| &&
      `               enableHighAccuracy: {` && |\n| &&
      `                    type: "boolean",` && |\n| &&
      `                    defaultValue: false` && |\n| &&
      `                },` && |\n| &&
      `               timeout: {` && |\n| &&
      `                    type: "string",` && |\n| &&
      `                    defaultValue: "5000"` && |\n| &&
      `                }` && |\n| &&
      `           },` && |\n| &&
      `           events: {` && |\n| &&
      `               "finished": { ` && |\n| &&
      `                      allowPreventDefault: true,` && |\n| &&
      `                      parameters: {},` && |\n| &&
      `               }` && |\n| &&
      `          }` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       callbackPosition(position){` && |\n| &&
      |\n| &&
      `           var test = position.coords.longitude` && |\n| &&
      `           this.setProperty("longitude", position.coords.longitude , true);` && |\n| &&
      `           this.setProperty("latitude", position.coords.latitude , true);` && |\n| &&
      `           this.setProperty("altitude", position.coords.altitude , true);` && |\n| &&
      `           this.setProperty("accuracy", position.coords.accuracy , true);` && |\n| &&
      `           this.setProperty("altitudeAccuracy", position.coords.altitudeAccuracy , true);` && |\n| &&
      `           this.setProperty("speed", position.coords.speed , true);` && |\n| &&
      `           this.setProperty("heading", position.coords.heading , true);` && |\n| &&
      `           this.fireFinished();` && |\n| &&
      `           //this.getParent().getParent().getModel().refresh();` && |\n| &&
      |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       async init(){` && |\n| &&
      |\n| &&
      `           navigator.geolocation.getCurrentPosition(this.callbackPosition.bind(this));` && |\n| &&
      `           //navigator.geolocation.watchPosition(this.callbackPosition.bind(this));` && |\n| &&
      `           ` && |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `        exit () {` && |\n| &&
      `           //clearWatch` && |\n| &&
      `        },` && |\n| &&
      |\n| &&
      `       onAfterRendering() {` && |\n| &&
      |\n| &&
      |\n| &&
      `       },` && |\n| &&
      |\n| &&
      `       renderer(oRm, oControl) {` && |\n| &&
      |\n| &&
      `        }` && |\n| &&
      `   });` && |\n| &&
      `});`.

  ENDMETHOD.

ENDCLASS.
