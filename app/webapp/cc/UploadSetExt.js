sap.ui.define(
  [
    "sap/ui/core/Control",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (Control, Lib, ViewSlots, AppState) => {
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
        this._queue = [];
        this._reading = false;
      },
      exit() {
        this._unhook();
        this._queue = [];
        if (this._afterRoundtrip) {
          Lib.unregisterCallback("onAfterRendering", this._afterRoundtrip);
          this._afterRoundtrip = null;
        }
      },

      // The properties hold ONE file, and each change starts one roundtrip.
      // UploadSet fires afterItemAdded once per file of a multi-select, in
      // one synchronous loop: every reader used to start at once, each
      // onload overwrote the properties and fired change, and the busy guard
      // (View1.eB) dropped every change but the first - three files picked,
      // one arrived. So the files queue up and go one at a time, the next
      // read only once the roundtrip of the previous change has landed.
      _readFile(file) {
        this._queue.push(file);
        if (!this._reading) this._readNext();
      },

      _readNext() {
        const file = this._queue.shift();
        if (!file) {
          this._reading = false;
          return;
        }
        this._reading = true;
        Lib.readFileAsDataURL(
          file,
          this,
          (result) => {
            this.setProperty("fileData", result);
            this.setProperty("fileName", file.name);
            this.setProperty("mediaType", file.type);
            this.setProperty("fileSize", String(file.size));
            this.fireChange();
            this._whenRoundtripLanded(() => this._readNext());
          },
          "UploadSetExt",
        );
      },

      // Runs `fn` once the roundtrip the change just started has landed -
      // right away when it started none (no event bound to change), which
      // is what state.isBusy says synchronously after fireChange.
      _whenRoundtripLanded(fn) {
        if (!AppState.state.isBusy) {
          fn();
          return;
        }
        const once = () => {
          Lib.unregisterCallback("onAfterRendering", once);
          this._afterRoundtrip = null;
          if (Lib.isDestroyed(this)) return;
          fn();
        };
        this._afterRoundtrip = once;
        Lib.registerCallback("onAfterRendering", once);
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
          uploadSet.attachAfterItemAdded(this.onItemAdded.bind(this));
          // afterItemRemoved is @since 1.83; below that, adds keep working
          // and the gap is reported instead of failing the whole setup
          // (beforeItemRemoved is no substitute - it fires before the
          // confirm dialog and would report cancelled removals)
          if (uploadSet.attachAfterItemRemoved) {
            uploadSet.attachAfterItemRemoved(this.onItemRemoved.bind(this));
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
