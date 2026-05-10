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
