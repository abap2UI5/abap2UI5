sap.ui.define(
  ["sap/ui/core/Control", "sap/ui/util/Storage", "z2ui5/cc/Lib"],
  (Control, Storage, Lib) => {
    "use strict";

    return Control.extend("z2ui5.Storage", {
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

      renderer: {
        apiVersion: 2,
        render(_, oControl) {
          const type = oControl.getProperty("type");
          const prefix = oControl.getProperty("prefix");
          const key = oControl.getProperty("key");
          const value = oControl.getProperty("value");

          let stored;
          try {
            const storageType = Storage.Type[type] || Storage.Type.session;
            const storage = new Storage(storageType, prefix);
            const read = storage.get(key);
            stored = read == null ? "" : read;
          } catch (e) {
            Lib.logError(`Storage: read failed for key '${key}'`, e);
            return;
          }

          // Only fire "finished" when the stored value differs from the
          // current property to avoid feedback loops.
          if (stored !== value) {
            oControl.setProperty("value", stored, true);
            oControl.fireFinished({
              type: type,
              prefix: prefix,
              key: key,
              value: stored,
            });
          }
        },
      },
    });
  },
);
