CLASS z2ui5_cl_app_models_js DEFINITION
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


CLASS z2ui5_cl_app_models_js IMPLEMENTATION.

  METHOD get.

    result =              `sap.ui.define([` && |\n|  &&
             `    "sap/ui/model/json/JSONModel",` && |\n|  &&
             `    "sap/ui/Device"` && |\n|  &&
             `],` && |\n|  &&
             `function (JSONModel, Device) {` && |\n|  &&
             `    "use strict";` && |\n|  &&
             `` && |\n|  &&
             `    return {` && |\n|  &&
             `        /**` && |\n|  &&
             `         * Provides runtime info for the device the UI5 app is running on as JSONModel` && |\n|  &&
             `         */` && |\n|  &&
             `        createDeviceModel: function () {` && |\n|  &&
             `            var oModel = new JSONModel(Device);` && |\n|  &&
             `            oModel.setDefaultBindingMode("OneWay");` && |\n|  &&
             `            return oModel;` && |\n|  &&
             `        }` && |\n|  &&
             `    };` && |\n|  &&
             `` && |\n|  &&
             `});` && |\n|  &&
              ``.

  ENDMETHOD.

ENDCLASS.
