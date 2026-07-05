CLASS z2ui5_cl_app_uploadsetext_js DEFINITION
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


CLASS z2ui5_cl_app_uploadsetext_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],` && |\n| &&
             `  (Control, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible companion control for a sap.m.upload.UploadSet (referenced` && |\n| &&
             `    // via uploadSetId): reads every added file as a base64 data URL into` && |\n| &&
             `    // the bindable fileData/fileName/... properties and reports removals,` && |\n| &&
             `    // so the backend receives the file content without an upload endpoint.` && |\n| &&
             `    return Control.extend("z2ui5.cc.UploadSetExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          uploadSetId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          fileData: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          fileName: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          mediaType: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          fileSize: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          removedFileName: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          checkInit: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          change: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `          remove: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._setControlBound = this.setControl.bind(this);` && |\n| &&
             `        Lib.registerCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _readFile(file) {` && |\n| &&
             `        Lib.readFileAsDataURL(` && |\n| &&
             `          file,` && |\n| &&
             `          this,` && |\n| &&
             `          (result) => {` && |\n| &&
             `            this.setProperty("fileData", result);` && |\n| &&
             `            this.setProperty("fileName", file.name);` && |\n| &&
             `            this.setProperty("mediaType", file.type);` && |\n| &&
             `            this.setProperty("fileSize", String(file.size));` && |\n| &&
             `            this.fireChange();` && |\n| &&
             `          },` && |\n| &&
             `          "UploadSetExt",` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onItemAdded(oEvent) {` && |\n| &&
             `        const file = oEvent.getParameter("item")?.getFileObject?.();` && |\n| &&
             `        if (file) this._readFile(file);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onItemRemoved(oEvent) {` && |\n| &&
             `        const name = oEvent.getParameter("item")?.getFileName?.() ?? "";` && |\n| &&
             `        this.setProperty("removedFileName", name);` && |\n| &&
             `        this.fireRemove();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `      setControl() {` && |\n| &&
             `        const uploadSet = ViewSlots.byId(` && |\n| &&
             `          "MAIN",` && |\n| &&
             `          this.getProperty("uploadSetId"),` && |\n| &&
             `        );` && |\n| &&
             `        if (!uploadSet || this.getProperty("checkInit")) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        try {` && |\n| &&
             `          uploadSet.attachAfterItemAdded(this.onItemAdded.bind(this));` && |\n| &&
             `          uploadSet.attachAfterItemRemoved(this.onItemRemoved.bind(this));` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("UploadSetExt.setControl: setup failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
