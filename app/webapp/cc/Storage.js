// Invisible control that reads a value from browser storage
// (session/local, see sap.ui.util.Storage) into its `value` property
// and fires `finished` when the stored value differs from the current
// one. The write side is handled by the STORE_DATA frontend action.
sap.ui.define(
  ["sap/ui/core/Control", "sap/ui/util/Storage", "z2ui5/core/Lib"],
  (Control, Storage, Lib) => {
    "use strict";

    // Value equality for the stored payload. `value` is typed `any`: a plain
    // string for the common case, a structure or a table once an app binds
    // one. A reference comparison reports EVERY object as different, because
    // sap/ui/util/Storage JSON-round-trips what it stores and therefore hands
    // back a fresh object on every read - the control would fire `finished`
    // on each render, the backend would answer with a re-render, and that
    // fires again: an endless round-trip loop that made a structured value
    // unusable. Compare by value instead. Key order is not significant (the
    // stored copy went through JSON, the bound one comes from the model), and
    // the payload is JSON by construction, so this covers every shape that
    // can reach the property.
    function isSameValue(a, b) {
      if (a === b) return true;
      if (a === null || b === null) return false;
      if (typeof a !== "object" || typeof b !== "object") return false;
      if (Array.isArray(a) !== Array.isArray(b)) return false;
      if (Array.isArray(a)) {
        return a.length === b.length && a.every((v, i) => isSameValue(v, b[i]));
      }
      const keys = Object.keys(a);
      if (keys.length !== Object.keys(b).length) return false;
      return keys.every(
        (k) =>
          Object.prototype.hasOwnProperty.call(b, k) && isSameValue(a[k], b[k]),
      );
    }

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
        if (!isSameValue(stored, value)) {
          this.setProperty("value", stored, true);
          this.fireFinished({ type, prefix, key, value: stored });
        }
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          Lib.renderInvisibleSpan(oRm, oControl);
          oControl._pendingRead = true;
        },
      },
    });
  },
);
