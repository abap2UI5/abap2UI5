sap.ui.define(
  [
    "sap/m/ComboBox",
    "sap/ui/core/Item",
    "sap/m/ComboBoxRenderer",
    "z2ui5/core/Lib",
  ],
  (ComboBox, Item, ComboBoxRenderer, Lib) => {
    "use strict";
    // ComboBox pre-filled with the device's cameras (video inputs) so the
    // user can pick which one the CameraPicture control should use.
    return ComboBox.extend("z2ui5.cc.CameraSelector", {
      // init() is a UI5 lifecycle listener and must not return a value, so it
      // cannot be async - kick off the (async) device enumeration separately.
      init() {
        ComboBox.prototype.init.call(this);
        this._loadCameras();
      },

      async _loadCameras() {
        try {
          const md = navigator.mediaDevices;
          if (!md?.enumerateDevices) return;
          const devices = await md.enumerateDevices();
          // The ComboBox may have been destroyed during the await.
          if (!devices || Lib.isDestroyed(this)) return;
          for (const device of devices) {
            // Only video inputs are relevant.
            if (device.kind !== "videoinput") continue;
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
