CLASS z2ui5_cl_app_mode_models_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_mode_models_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define([` &&
             `    "sap/ui/model/json/JSONModel",` &&
             `    "sap/ui/Device"` &&
             `], ` &&
             `function (JSONModel, Device) {` &&
             `    "use strict";` &&
             `` &&
             `    return {` &&
             `        /**` &&
             `         * Provides runtime info for the device the UI5 app is running on as JSONModel` &&
             `         */` &&
             `        createDeviceModel: function () {` &&
             `            var oModel = new JSONModel(Device);` &&
             `            oModel.setDefaultBindingMode("OneWay");` &&
             `            return oModel;` &&
             `        }` &&
             `    };` &&
             `` &&
             `});` &&
              ``.

  ENDMETHOD.

ENDCLASS.
