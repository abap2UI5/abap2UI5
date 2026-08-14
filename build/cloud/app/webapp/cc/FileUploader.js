sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/m/Button",
    "sap/ui/unified/FileUploader",
    "sap/m/HBox",
    "z2ui5/core/Lib",
  ],
  (Control, Button, FileUploader, HBox, Lib) => {
    "use strict";

    // File picker: wraps sap.ui.unified.FileUploader plus an optional
    // Upload button. The chosen file is read as a base64 data URL into
    // `value` and handed to the backend via the `upload` event - either
    // when the button is pressed or, with checkDirectUpload, right after
    // the file was selected.
    return Control.extend("z2ui5.cc.FileUploader", {
      metadata: {
        properties: {
          value: {
            type: "string",
            defaultValue: "",
          },
          path: {
            type: "string",
            defaultValue: "",
          },
          tooltip: {
            type: "string",
            defaultValue: "",
          },
          fileType: {
            type: "string",
            defaultValue: "",
          },
          placeholder: {
            type: "string",
            defaultValue: "",
          },
          buttonText: {
            type: "string",
            defaultValue: "",
          },
          style: {
            type: "string",
            defaultValue: "",
          },
          uploadButtonText: {
            type: "string",
            defaultValue: "Upload",
          },
          enabled: {
            type: "boolean",
            defaultValue: true,
          },
          icon: {
            type: "string",
            defaultValue: "sap-icon://browse-folder",
          },
          iconOnly: {
            type: "boolean",
            defaultValue: false,
          },
          buttonOnly: {
            type: "boolean",
            defaultValue: false,
          },
          multiple: {
            type: "boolean",
            defaultValue: false,
          },
          visible: {
            type: "boolean",
            defaultValue: true,
          },
          checkDirectUpload: {
            type: "boolean",
            defaultValue: false,
          },
        },

        events: {
          upload: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      _readFile(file) {
        Lib.readFileAsDataURL(
          file,
          this,
          (result) => {
            this.setProperty("value", result);
            this.fireUpload();
          },
          "FileUploader",
        );
      },

      exit() {
        if (this._oHBox) this._oHBox.destroy();
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          const directUpload = oControl.getProperty("checkDirectUpload");
          const path = oControl.getProperty("path");

          // Clean up controls from a previous render pass.
          if (oControl._oHBox) oControl._oHBox.destroy();
          oControl._oHBox = null;
          oControl.oUploadButton = null;
          oControl.oFileUploader = null;

          if (!directUpload) {
            oControl.oUploadButton = new Button({
              text: oControl.getProperty("uploadButtonText"),
              enabled: path !== "",
              press: () => {
                oControl.setProperty(
                  "path",
                  oControl.oFileUploader.getProperty("value"),
                );
                if (oControl._pendingFile) {
                  oControl._readFile(oControl._pendingFile);
                }
              },
            });
          }

          oControl.oFileUploader = new FileUploader({
            tooltip: oControl.getProperty("tooltip"),
            icon: oControl.getProperty("icon"),
            iconOnly: oControl.getProperty("iconOnly"),
            buttonOnly: oControl.getProperty("buttonOnly"),
            buttonText: oControl.getProperty("buttonText"),
            style: oControl.getProperty("style"),
            fileType: oControl.getProperty("fileType"),
            visible: oControl.getProperty("visible"),
            uploadOnChange: directUpload,
            multiple: oControl.getProperty("multiple"),
            enabled: oControl.getProperty("enabled"),
            value: path,
            placeholder: oControl.getProperty("placeholder"),
            change: (oEvent) => {
              // Remember the selected file from the event's public "files"
              // parameter (the inner file input is private API). It is
              // consumed by the upload button press or, in direct-upload
              // mode, by uploadComplete below.
              const files = oEvent.getParameter("files");
              oControl._pendingFile = files?.[0];
              if (directUpload) return;
              const value = oEvent.getSource().getProperty("value");
              oControl.setProperty("path", value);
              if (oControl.oUploadButton) {
                oControl.oUploadButton.setEnabled(Boolean(value));
              }
            },
            uploadComplete: (oEvent) => {
              if (!directUpload) return;
              const source = oEvent.getSource();
              oControl.setProperty("path", source.getProperty("value"));
              if (oControl._pendingFile) {
                oControl._readFile(oControl._pendingFile);
              }
            },
          });

          oControl._oHBox = new HBox().addItem(oControl.oFileUploader);
          if (oControl.oUploadButton) {
            oControl._oHBox.addItem(oControl.oUploadButton);
          }
          oRm.renderControl(oControl._oHBox);
        },
      },
    });
  },
);
