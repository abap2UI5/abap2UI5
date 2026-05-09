sap.ui.define(['sap/ui/model/json/JSONModel', 'sap/ui/Device'], (JSONModel, Device) => {
  'use strict';

  return {
    /**
     * Wraps sap.ui.Device into a one-way JSONModel.
     * One-way binding because the device data is read-only — UI changes must not write back.
     * A resize listener triggers checkUpdate() so bound width/height stay current after rotation/resize.
     * The handlers are detached from the previous model when this is called again
     * (e.g. on a re-mounted Component) to avoid stacking listeners across reloads.
     */
    createDeviceModel() {
      const oModel = new JSONModel(Device);
      oModel.setDefaultBindingMode('OneWay');
      const handler = () => oModel.checkUpdate(true);
      Device.resize?.attachHandler?.(handler);
      Device.orientation?.attachHandler?.(handler);
      // Hook into UI5 destroy so the same handler can be cleaned up when the model dies
      const originalDestroy = oModel.destroy?.bind(oModel);
      if (originalDestroy) {
        oModel.destroy = function (...args) {
          try {
            Device.resize?.detachHandler?.(handler);
            Device.orientation?.detachHandler?.(handler);
          } catch {
            /* detach is best-effort */
          }
          return originalDestroy(...args);
        };
      }
      return oModel;
    },
  };
});
