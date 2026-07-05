sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible companion control for a sap.m.upload.UploadSet (referenced
    // via uploadSetId): reads every added file as a base64 data URL into
    // the bindable fileData/fileName/... properties and reports removals,
    // so the backend receives the file content without an upload endpoint.
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
        const file = oEvent.getParameter("item")?.getFileObject?.();
        if (file) this._readFile(file);
      },

      onItemRemoved(oEvent) {
        const name = oEvent.getParameter("item")?.getFileName?.() ?? "";
        this.setProperty("removedFileName", name);
        this.fireRemove();
      },

      renderer: { apiVersion: 2, render() {} },
      setControl() {
        const uploadSet = ViewSlots.byId(
          "MAIN",
          this.getProperty("uploadSetId"),
        );
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
  },
);
