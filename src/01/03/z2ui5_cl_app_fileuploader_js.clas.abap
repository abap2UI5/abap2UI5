CLASS z2ui5_cl_app_fileuploader_js DEFINITION
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


CLASS z2ui5_cl_app_fileuploader_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "sap/m/Button",` && |\n| &&
             `    "sap/ui/unified/FileUploader",` && |\n| &&
             `    "sap/m/HBox",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Button, FileUploader, HBox, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // File picker: wraps sap.ui.unified.FileUploader plus an optional` && |\n| &&
             `    // Upload button. The chosen file is read as a base64 data URL into` && |\n| &&
             `    // ``value`` and handed to the backend via the ``upload`` event - either` && |\n| &&
             `    // when the button is pressed or, with checkDirectUpload, right after` && |\n| &&
             `    // the file was selected.` && |\n| &&
             `    return Control.extend("z2ui5.cc.FileUploader", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          value: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          path: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          tooltip: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          fileType: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          placeholder: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          buttonText: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          style: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          uploadButtonText: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "Upload",` && |\n| &&
             `          },` && |\n| &&
             `          enabled: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          icon: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "sap-icon://browse-folder",` && |\n| &&
             `          },` && |\n| &&
             `          iconOnly: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          buttonOnly: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          multiple: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          visible: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          checkDirectUpload: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `` && |\n| &&
             `        events: {` && |\n| &&
             `          upload: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _readFile(file) {` && |\n| &&
             `        Lib.readFileAsDataURL(` && |\n| &&
             `          file,` && |\n| &&
             `          this,` && |\n| &&
             `          (result) => {` && |\n| &&
             `            this.setProperty("value", result);` && |\n| &&
             `            this.fireUpload();` && |\n| &&
             `          },` && |\n| &&
             `          "FileUploader",` && |\n| &&
             `        );` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        if (this._oHBox) this._oHBox.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          const directUpload = oControl.getProperty("checkDirectUpload");` && |\n| &&
             `          const path = oControl.getProperty("path");` && |\n| &&
             `` && |\n| &&
             `          // Clean up controls from a previous render pass.` && |\n| &&
             `          if (oControl._oHBox) oControl._oHBox.destroy();` && |\n| &&
             `          oControl._oHBox = null;` && |\n| &&
             `          oControl.oUploadButton = null;` && |\n| &&
             `          oControl.oFileUploader = null;` && |\n| &&
             `` && |\n| &&
             `          if (!directUpload) {` && |\n| &&
             `            oControl.oUploadButton = new Button({` && |\n| &&
             `              text: oControl.getProperty("uploadButtonText"),` && |\n| &&
             `              enabled: path !== "",` && |\n| &&
             `              press: () => {` && |\n| &&
             `                oControl.setProperty(` && |\n| &&
             `                  "path",` && |\n| &&
             `                  oControl.oFileUploader.getProperty("value"),` && |\n| &&
             `                );` && |\n| &&
             `                if (oControl._pendingFile) {` && |\n| &&
             `                  oControl._readFile(oControl._pendingFile);` && |\n| &&
             `                }` && |\n| &&
             `              },` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          oControl.oFileUploader = new FileUploader({` && |\n| &&
             `            tooltip: oControl.getProperty("tooltip"),` && |\n| &&
             `            icon: oControl.getProperty("icon"),` && |\n| &&
             `            iconOnly: oControl.getProperty("iconOnly"),` && |\n| &&
             `            buttonOnly: oControl.getProperty("buttonOnly"),` && |\n| &&
             `            buttonText: oControl.getProperty("buttonText"),` && |\n| &&
             `            style: oControl.getProperty("style"),` && |\n| &&
             `            fileType: oControl.getProperty("fileType"),` && |\n| &&
             `            visible: oControl.getProperty("visible"),` && |\n| &&
             `            uploadOnChange: directUpload,` && |\n| &&
             `            multiple: oControl.getProperty("multiple"),` && |\n| &&
             `            enabled: oControl.getProperty("enabled"),` && |\n| &&
             `            value: path,` && |\n| &&
             `            placeholder: oControl.getProperty("placeholder"),` && |\n| &&
             `            change: (oEvent) => {` && |\n| &&
             `              // Remember the selected file from the event's public "files"` && |\n| &&
             `              // parameter (the inner file input is private API). It is` && |\n| &&
             `              // consumed by the upload button press or, in direct-upload` && |\n| &&
             `              // mode, by uploadComplete below.` && |\n| &&
             `              const files = oEvent.getParameter("files");` && |\n| &&
             `              oControl._pendingFile = files?.[0];` && |\n| &&
             `              if (directUpload) return;` && |\n| &&
             `              const value = oEvent.getSource().getProperty("value");` && |\n| &&
             `              oControl.setProperty("path", value);` && |\n| &&
             `              if (oControl.oUploadButton) {` && |\n| &&
             `                oControl.oUploadButton.setEnabled(Boolean(value));` && |\n| &&
             `              }` && |\n| &&
             `            },` && |\n| &&
             `            uploadComplete: (oEvent) => {` && |\n| &&
             `              if (!directUpload) return;` && |\n| &&
             `              const source = oEvent.getSource();` && |\n| &&
             `              oControl.setProperty("path", source.getProperty("value"));` && |\n| &&
             `              if (oControl._pendingFile) {` && |\n| &&
             `                oControl._readFile(oControl._pendingFile);` && |\n| &&
             `              }` && |\n| &&
             `            },` && |\n| &&
             `          });` && |\n| &&
             `` && |\n| &&
             `          oControl._oHBox = new HBox().addItem(oControl.oFileUploader);` && |\n| &&
             `          if (oControl.oUploadButton) {` && |\n| &&
             `            oControl._oHBox.addItem(oControl.oUploadButton);` && |\n| &&
             `          }` && |\n| &&
             `          oRm.renderControl(oControl._oHBox);` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
