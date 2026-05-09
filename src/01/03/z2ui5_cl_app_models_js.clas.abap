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

    result = `sap.ui.define(['sap/ui/model/json/JSONModel', 'sap/ui/Device'], (JSONModel, Device) => {` && |\n| &&
             `  'use strict';` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    /**` && |\n| &&
             `     * Wraps sap.ui.Device into a one-way JSONModel.` && |\n| &&
             `     * One-way binding because the device data is read-only — UI changes must not write back.` && |\n| &&
             `     */` && |\n| &&
             `    createDeviceModel() {` && |\n| &&
             `      const oModel = new JSONModel(Device);` && |\n| &&
             `      oModel.setDefaultBindingMode('OneWay');` && |\n| &&
             `      return oModel;` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
