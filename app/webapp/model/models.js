sap.ui.define(
  ["sap/ui/model/json/JSONModel", "sap/ui/Device"],
  (JSONModel, Device) => {
    "use strict";

    return {
      // Creates a read-only JSON model that exposes the current device info
      // (phone / tablet / desktop, orientation, ...) to the views.
      createDeviceModel() {
        const oModel = new JSONModel(Device);
        oModel.setDefaultBindingMode("OneWay");
        return oModel;
      },
    };
  },
);
