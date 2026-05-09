sap.ui.define(['sap/ui/model/json/JSONModel', 'sap/ui/Device'], (JSONModel, Device) => {
  'use strict';

  return {
    /**
     * Wraps sap.ui.Device into a one-way JSONModel.
     * One-way binding because the device data is read-only — UI changes must not write back.
     */
    createDeviceModel() {
      const oModel = new JSONModel(Device);
      oModel.setDefaultBindingMode('OneWay');
      return oModel;
    },
  };
});
