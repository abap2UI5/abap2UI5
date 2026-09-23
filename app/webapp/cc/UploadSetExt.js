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
        this._unhook = Lib.hookCallback(this, "onAfterRendering", "setControl");
      },
      exit() {
        this._unhook();
        this._detach();
        if (this._reader) this._reader.cancel();
      },

      // The handlers setControl put on the TARGET upload set, taken off
      // again: a companion destroyed while its target survives used to
      // leave them on the target for good (cc/MultiInputExt has the same
      // pair). Optional-chained: the removal handler is only attached on
      // UI5 >= 1.83, and the target may be gone already.
      _detach() {
        const uploadSet = this._target;
        this._target = null;
        if (!uploadSet || Lib.isDestroyed(uploadSet)) return;
        if (this._onItemAdded) {
          uploadSet.detachAfterItemAdded?.(this._onItemAdded);
        }
        if (this._onItemRemoved) {
          uploadSet.detachAfterItemRemoved?.(this._onItemRemoved);
        }
        this._onItemAdded = null;
        this._onItemRemoved = null;
      },

      // The properties hold ONE file, and each change starts one roundtrip.
      // UploadSet fires afterItemAdded once per file of a multi-select, in
      // one synchronous loop: every reader used to start at once, each
      // onload overwrote the properties and fired change, and the busy guard
      // (View1.eB) dropped every change but the first - three files picked,
      // one arrived. Lib.readFilesInTurn owns that queue (cc/FileUploader
      // uses the same one); what stays here is only what one finished file
      // does to the bindable properties.
      _readFile(file) {
        if (!this._reader) {
          this._reader = Lib.readFilesInTurn(
            this,
            "UploadSetExt",
            (f, result) => {
              // suppressed invalidation: the control renders nothing, and
              // the binding write the backend reads happens either way
              this.setProperty("fileData", result, true);
              this.setProperty("fileName", f.name, true);
              this.setProperty("mediaType", f.type, true);
              this.setProperty("fileSize", String(f.size), true);
              this.fireChange();
            },
          );
        }
        this._reader.add([file]);
      },

      onItemAdded(oEvent) {
        const file = oEvent.getParameter("item")?.getFileObject?.();
        if (file) this._readFile(file);
      },

      onItemRemoved(oEvent) {
        const name = oEvent.getParameter("item")?.getFileName?.() ?? "";
        this.setProperty("removedFileName", name, true);
        this.fireRemove();
      },

      renderer: Lib.EMPTY_RENDERER,
      setControl() {
        // Once claimed there is nothing left to do - skip the target lookup
        // (byIdOfOwner walks the parent chain on every roundtrip) entirely.
        if (this.getProperty("checkInit")) return;
        const uploadSet = ViewSlots.byIdOfOwner(
          this,
          this.getProperty("uploadSetId"),
        );
        if (!Lib.claimOnce(this, uploadSet)) return;
        try {
          // the bound handlers are kept for exit( )'s detach - see _detach
          this._target = uploadSet;
          this._onItemAdded = this.onItemAdded.bind(this);
          uploadSet.attachAfterItemAdded(this._onItemAdded);
          // afterItemRemoved is @since 1.83; below that, adds keep working
          // and the gap is reported instead of failing the whole setup
          // (beforeItemRemoved is no substitute - it fires before the
          // confirm dialog and would report cancelled removals)
          if (uploadSet.attachAfterItemRemoved) {
            this._onItemRemoved = this.onItemRemoved.bind(this);
            uploadSet.attachAfterItemRemoved(this._onItemRemoved);
          } else {
            Lib.logError(
              "UploadSetExt: afterItemRemoved needs UI5 >= 1.83, removals will not be reported",
            );
          }
        } catch (e) {
          Lib.logError("UploadSetExt.setControl: setup failed", e);
        }
      },
    });
  },
);
