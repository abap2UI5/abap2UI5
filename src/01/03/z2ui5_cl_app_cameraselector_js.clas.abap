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
             `    "z2ui5/cc/Lib",` && |\n| &&
             `  ],` && |\n| &&
             `  (ComboBox, Item, ComboBoxRenderer, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    return ComboBox.extend("z2ui5.CameraSelector", {` && |\n| &&
             `      async init() {` && |\n| &&
             `        ComboBox.prototype.init.call(this);` && |\n| &&
             `        try {` && |\n| &&
             `          const md = navigator.mediaDevices;` && |\n| &&
             `          if (!md || !md.enumerateDevices) return;` && |\n| &&
             `          const devices = await md.enumerateDevices();` && |\n| &&
             `          if (!devices) return;` && |\n| &&
             `          for (const device of devices) {` && |\n| &&
             `            // Only video inputs are relevant; also stop adding items when the` && |\n| &&
             `            // ComboBox has been destroyed during the await.` && |\n| &&
             `            if (device.kind !== "videoinput") continue;` && |\n| &&
             `            if (Lib.isDestroyed(this)) return;` && |\n| &&
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
