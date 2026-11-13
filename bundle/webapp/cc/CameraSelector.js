sap.ui.define(
  [
    "sap/m/ComboBox",
    "sap/ui/core/Item",
    "sap/m/ComboBoxRenderer",
    "z2ui5/core/Lib",
    "z2ui5/core/Env",
  ],
  (ComboBox, Item, ComboBoxRenderer, Lib, Env) => {
    "use strict";
    // ComboBox pre-filled with the device's cameras (video inputs) so the
    // user can pick which one the CameraPicture control should use.
    const CameraSelector = ComboBox.extend("z2ui5.cc.CameraSelector", {
      // init() is a UI5 lifecycle listener and must not return a value, so it
      // cannot be async - kick off the (async) device enumeration separately.
      //
      // The list is read again whenever the dropdown opens (loadItems) and
      // when the browser reports a device change: before the page has the
      // camera permission, a browser lists each camera with an EMPTY id and
      // label, and granting it (CameraPicture's getUserMedia) fires no
      // devicechange in Chromium - read once in init, the selector kept
      // one blank entry for good, and picking it handed "" on as the
      // default camera.
      init() {
        ComboBox.prototype.init.call(this);
        this._onDeviceChange = () => this._loadCameras();
        navigator.mediaDevices?.addEventListener?.(
          "devicechange",
          this._onDeviceChange,
        );
        this.attachLoadItems?.(this._onDeviceChange);
        this._loadCameras();
      },

      exit() {
        navigator.mediaDevices?.removeEventListener?.(
          "devicechange",
          this._onDeviceChange,
        );
        ComboBox.prototype.exit?.call(this);
      },

      async _loadCameras() {
        try {
          const md = navigator.mediaDevices;
          if (!md?.enumerateDevices) return;
          const devices = await md.enumerateDevices();
          // The ComboBox may have been destroyed during the await.
          if (!devices || Lib.isDestroyed(this)) return;
          const selected = this.getSelectedKey?.();
          this.destroyItems?.();
          for (const device of devices) {
            // Only video inputs are relevant - and only the ones the browser
            // names: an empty id is a camera listed before the permission
            if (device.kind !== "videoinput" || !device.deviceId) continue;
            // through the setters: a label handed over as a setting is read
            // as binding syntax ("Integrated Camera {front}" lost its {front})
            const item = new Item();
            item.setKey(device.deviceId);
            item.setText(device.label || device.deviceId);
            this.addItem(item);
          }
          if (selected) this.setSelectedKey?.(selected);
        } catch (err) {
          Lib.logError("CameraSelector: enumerateDevices failed", err);
        }
      },

      renderer: ComboBoxRenderer,
    });
    return Env.ownClass(CameraSelector);
  },
);
