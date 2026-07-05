sap.ui.define(
  ["sap/ui/core/Control", "sap/ui/util/Storage", "z2ui5/core/Lib"],
  (Control, Storage, Lib) => {
    "use strict";

    // Invisible control that reads a value from browser storage
    // (session/local, see sap.ui.util.Storage) into its `value` property
    // and fires `finished` when the stored value differs from the current
    // one. The write side is handled by the STORE_DATA frontend action.
    return Control.extend("z2ui5.cc.Storage", {
      metadata: {
        properties: {
          type: {
            type: "string",
            defaultValue: "session",
          },
          prefix: {
            type: "string",
            defaultValue: "",
          },
          key: {
            type: "string",
            defaultValue: "",
          },
          value: {
            type: "any",
            defaultValue: "",
          },
        },
        events: {
          finished: {
            parameters: {
              type: {
                type: "string",
              },
              prefix: {
                type: "string",
              },
              key: {
                type: "string",
              },
              value: {
                type: "any",
              },
            },
          },
        },
      },

      // Follows the shared rendering pattern (see core/Lib.js): the renderer
      // only marks the work, onAfterRendering reads the storage and fires
      // the event.
      onAfterRendering() {
        if (!this._pendingRead) return;
        this._pendingRead = false;

        const type = this.getProperty("type");
        const prefix = this.getProperty("prefix");
        const key = this.getProperty("key");
        const value = this.getProperty("value");

        let stored;
        try {
          const storageType = Storage.Type[type] || Storage.Type.session;
          const storage = new Storage(storageType, prefix);
          stored = storage.get(key) ?? "";
        } catch (e) {
          Lib.logError(`Storage: read failed for key '${key}'`, e);
          return;
        }

        // Only fire "finished" when the stored value differs from the
        // current property to avoid feedback loops.
        if (stored !== value) {
          this.setProperty("value", stored, true);
          this.fireFinished({ type, prefix, key, value: stored });
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oRm.openStart("span", oControl);
          oRm.style("display", "none");
          oRm.openEnd();
          oRm.close("span");
          oControl._pendingRead = true;
        },
      },
    });
  },
);
