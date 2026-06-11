sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";

  return Control.extend("z2ui5.cc.UploadSetExt", {
    metadata: {
      properties: {
        uploadSetId: {
          type: "string",
        },
        fileData: {
          type: "string",
          defaultValue: "",
        },
        fileName: {
          type: "string",
          defaultValue: "",
        },
        mediaType: {
          type: "string",
          defaultValue: "",
        },
        fileSize: {
          type: "string",
          defaultValue: "",
        },
        removedFileName: {
          type: "string",
          defaultValue: "",
        },
        checkInit: {
          type: "boolean",
          defaultValue: false,
        },
      },
      events: {
        change: {
          allowPreventDefault: true,
          parameters: {},
        },
        remove: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },

    init() {
      this._setControlBound = this.setControl.bind(this);
      Lib.registerCallback("onAfterRendering", this._setControlBound);
    },
    exit() {
      Lib.unregisterCallback("onAfterRendering", this._setControlBound);
    },

    _readFile(file) {
      Lib.readFileAsDataURL(
        file,
        this,
        (result) => {
          this.setProperty("fileData", result);
          this.setProperty("fileName", file.name);
          this.setProperty("mediaType", file.type);
          this.setProperty("fileSize", String(file.size));
          this.fireChange();
        },
        "UploadSetExt",
      );
    },

    onItemAdded(oEvent) {
      const item = oEvent.getParameter("item");
      const file = item?.getFileObject ? item.getFileObject() : null;
      if (file) this._readFile(file);
    },

    onItemRemoved(oEvent) {
      const item = oEvent.getParameter("item");
      const name = item?.getFileName ? item.getFileName() : "";
      this.setProperty("removedFileName", name);
      this.fireRemove();
    },

    renderer: { apiVersion: 2, render() {} },
    setControl() {
      const uploadSet = z2ui5.oView?.byId(this.getProperty("uploadSetId"));
      if (!uploadSet || this.getProperty("checkInit")) return;
      this.setProperty("checkInit", true);
      try {
        uploadSet.attachAfterItemAdded(this.onItemAdded.bind(this));
        uploadSet.attachAfterItemRemoved(this.onItemRemoved.bind(this));
      } catch (e) {
        Lib.logError("UploadSetExt.setControl: setup failed", e);
      }
    },
  });
});
