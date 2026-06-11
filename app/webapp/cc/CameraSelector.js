sap.ui.define(
  [
    "sap/m/ComboBox",
    "sap/ui/core/Item",
    "sap/m/ComboBoxRenderer",
    "z2ui5/core/Lib",
  ],
  (ComboBox, Item, ComboBoxRenderer, Lib) => {
    "use strict";
    return ComboBox.extend("z2ui5.cc.CameraSelector", {
      async init() {
        ComboBox.prototype.init.call(this);
        try {
          const md = navigator.mediaDevices;
          if (!md || !md.enumerateDevices) return;
          const devices = await md.enumerateDevices();
          if (!devices) return;
          for (const device of devices) {
            // Only video inputs are relevant; also stop adding items when the
            // ComboBox has been destroyed during the await.
            if (device.kind !== "videoinput") continue;
            if (Lib.isDestroyed(this)) return;
            this.addItem(
              new Item({ key: device.deviceId, text: device.label }),
            );
          }
        } catch (err) {
          Lib.logError("CameraDeviceList: enumerateDevices failed", err);
        }
      },

      renderer: ComboBoxRenderer,
    });
  },
);
