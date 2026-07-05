CLASS z2ui5_cl_app_cameraselector_js DEFINITION
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


CLASS z2ui5_cl_app_cameraselector_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/m/ComboBox",` && |\n| &&
             `    "sap/ui/core/Item",` && |\n| &&
             `    "sap/m/ComboBoxRenderer",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `  ],` && |\n| &&
             `  (ComboBox, Item, ComboBoxRenderer, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    // ComboBox pre-filled with the device's cameras (video inputs) so the` && |\n| &&
             `    // user can pick which one the CameraPicture control should use.` && |\n| &&
             `    return ComboBox.extend("z2ui5.cc.CameraSelector", {` && |\n| &&
             `      async init() {` && |\n| &&
             `        ComboBox.prototype.init.call(this);` && |\n| &&
             `        try {` && |\n| &&
             `          const md = navigator.mediaDevices;` && |\n| &&
             `          if (!md?.enumerateDevices) return;` && |\n| &&
             `          const devices = await md.enumerateDevices();` && |\n| &&
             `          // The ComboBox may have been destroyed during the await.` && |\n| &&
             `          if (!devices || Lib.isDestroyed(this)) return;` && |\n| &&
             `          for (const device of devices) {` && |\n| &&
             `            // Only video inputs are relevant.` && |\n| &&
             `            if (device.kind !== "videoinput") continue;` && |\n| &&
             `            this.addItem(` && |\n| &&
             `              new Item({ key: device.deviceId, text: device.label }),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        } catch (err) {` && |\n| &&
             `          Lib.logError("CameraDeviceList: enumerateDevices failed", err);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: ComboBoxRenderer,` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
