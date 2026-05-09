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
             `     * A resize listener triggers checkUpdate() so bound width/height stay current after rotation/resize.` && |\n| &&
             `     * The handlers are detached from the previous model when this is called again` && |\n| &&
             `     * (e.g. on a re-mounted Component) to avoid stacking listeners across reloads.` && |\n| &&
             `     */` && |\n| &&
             `    createDeviceModel() {` && |\n| &&
             `      const oModel = new JSONModel(Device);` && |\n| &&
             `      oModel.setDefaultBindingMode('OneWay');` && |\n| &&
             `      const handler = () => oModel.checkUpdate(true);` && |\n| &&
             `      Device.resize?.attachHandler?.(handler);` && |\n| &&
             `      Device.orientation?.attachHandler?.(handler);` && |\n| &&
             `      // Hook into UI5 destroy so the same handler can be cleaned up when the model dies` && |\n| &&
             `      const originalDestroy = oModel.destroy?.bind(oModel);` && |\n| &&
             `      if (originalDestroy) {` && |\n| &&
             `        oModel.destroy = function (...args) {` && |\n| &&
             `          try {` && |\n| &&
             `            Device.resize?.detachHandler?.(handler);` && |\n| &&
             `            Device.orientation?.detachHandler?.(handler);` && |\n| &&
             `          } catch {` && |\n| &&
             `            /* detach is best-effort */` && |\n| &&
             `          }` && |\n| &&
             `          return originalDestroy(...args);` && |\n| &&
             `        };` && |\n| &&
             `      }` && |\n| &&
             `      return oModel;` && |\n| &&
             `    },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
