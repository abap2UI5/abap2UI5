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

      // `value` holds ONE file and every upload event is one roundtrip. With
      // `multiple` the inner control hands over every selected file, and only
      // files[0] was ever read - the rest were dropped without a word. The
      // sequential read queue is Lib.readFilesInTurn (cc/UploadSetExt uses
      // the same one): all this control keeps is what to do with a file that
      // finished reading.
      _readFiles(files) {
        if (!this._reader) {
          this._reader = Lib.readFilesInTurn(
            this,
            "FileUploader",
            (_, result) => {
              this.setProperty("value", result);
              this.fireUpload();
            },
          );
        }
        this._reader.add(files);
      },

      // Hand the remembered selection to the queue and FORGET it: the same
      // set must only be read once. Pressing Upload a second time without
      // picking a new file queued it again (and so did a second
      // uploadComplete of the direct-upload path), so every file reached the
      // backend twice.
      _uploadPendingFiles() {
        const files = this._pendingFiles;
        this._pendingFiles = null;
        if (files?.length) this._readFiles(files);
      },

      exit() {
        if (this._oHBox) this._oHBox.destroy();
        if (this._reader) this._reader.cancel();
      },

      // Build the inner controls ONCE and update their properties per
      // render - the renderer used to create (and destroy) all three on
      // every pass, which violates the "renderers stay cheap and free of
      // visible side effects" rule (core/Lib.js) and threw away the inner
      // file input's selection and focus on every roundtrip that re-
      // rendered the view. Create-once is the cc/CameraPicture pattern.
      // checkDirectUpload changes the STRUCTURE (upload button yes/no,
      // uploadOnChange is init-only on the inner control), so a toggle of
      // it is the one case that rebuilds.
      _ensureControls(directUpload) {
        if (this._oHBox && this._builtDirectUpload === directUpload) return;
        if (this._oHBox) this._oHBox.destroy();
        this._builtDirectUpload = directUpload;
        this.oUploadButton = null;

        if (!directUpload) {
          this.oUploadButton = new Button({
            text: this.getProperty("uploadButtonText"),
            enabled: this.getProperty("path") !== "",
            press: () => {
              this.setProperty("path", this.oFileUploader.getProperty("value"));
              this._uploadPendingFiles();
            },
          });
        }

        this.oFileUploader = new FileUploader({
          uploadOnChange: directUpload,
          change: (oEvent) => {
            // Remember the selected files from the event's public "files"
            // parameter (the inner file input is private API). They are
            // consumed by the upload button press or, in direct-upload
            // mode, by uploadComplete below.
            const files = oEvent.getParameter("files");
            this._pendingFiles = files ? Array.from(files) : [];
            if (directUpload) return;
            const value = oEvent.getSource().getProperty("value");
            this.setProperty("path", value);
            if (this.oUploadButton) {
              this.oUploadButton.setEnabled(Boolean(value));
            }
          },
          uploadComplete: (oEvent) => {
            if (!directUpload) return;
            const source = oEvent.getSource();
            this.setProperty("path", source.getProperty("value"));
            this._uploadPendingFiles();
          },
        });

        this._oHBox = new HBox().addItem(this.oFileUploader);
        if (this.oUploadButton) {
          this._oHBox.addItem(this.oUploadButton);
        }
      },

      // Push the current property values into the inner controls - cheap,
      // and UI5 only invalidates them when a value actually changed.
      _syncControls() {
        const u = this.oFileUploader;
        u.setTooltip(this.getProperty("tooltip"));
        u.setIcon(this.getProperty("icon"));
        u.setIconOnly(this.getProperty("iconOnly"));
        u.setButtonOnly(this.getProperty("buttonOnly"));
        u.setButtonText(this.getProperty("buttonText"));
        u.setStyle(this.getProperty("style"));
        u.setFileType(this.getProperty("fileType"));
        u.setVisible(this.getProperty("visible"));
        u.setMultiple(this.getProperty("multiple"));
        u.setEnabled(this.getProperty("enabled"));
        u.setValue(this.getProperty("path"));
        u.setPlaceholder(this.getProperty("placeholder"));
        if (this.oUploadButton) {
          this.oUploadButton.setText(this.getProperty("uploadButtonText"));
          this.oUploadButton.setEnabled(this.getProperty("path") !== "");
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oControl._ensureControls(oControl.getProperty("checkDirectUpload"));
          oControl._syncControls();
          oRm.renderControl(oControl._oHBox);
        },
      },
    });
  },
);
