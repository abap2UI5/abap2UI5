sap.ui.define(['sap/ui/model/json/JSONModel', 'sap/ui/Device'], (JSONModel, Device) => {
  'use strict';

  return {
    /**
     * Wraps sap.ui.Device into a one-way JSONModel.
     * One-way binding because the device data is read-only — UI changes must not write back.
     * A resize listener triggers checkUpdate() so bound width/height stay current.
     */
    createDeviceModel() {
      const oModel = new JSONModel(Device);
      oModel.setDefaultBindingMode('OneWay');
      // Device.resize fires on viewport changes; without this the model stays stale after rotation
      Device.resize?.attachHandler?.(() => oModel.checkUpdate(true));
      Device.orientation?.attachHandler?.(() => oModel.checkUpdate(true));
      return oModel;
    },
  };
});
