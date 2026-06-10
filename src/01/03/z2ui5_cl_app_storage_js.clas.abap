CLASS z2ui5_cl_app_storage_js DEFINITION
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


CLASS z2ui5_cl_app_storage_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "sap/ui/util/Storage", "z2ui5/cc/Lib"],` && |\n| &&
             `  (Control, Storage, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.Storage", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          type: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "session",` && |\n| &&
             `          },` && |\n| &&
             `          prefix: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          key: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          value: {` && |\n| &&
             `            type: "any",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          finished: {` && |\n| &&
             `            parameters: {` && |\n| &&
             `              type: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `              prefix: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `              key: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `              value: {` && |\n| &&
             `                type: "any",` && |\n| &&
             `              },` && |\n| &&
             `            },` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(_, oControl) {` && |\n| &&
             `          const type = oControl.getProperty("type");` && |\n| &&
             `          const prefix = oControl.getProperty("prefix");` && |\n| &&
             `          const key = oControl.getProperty("key");` && |\n| &&
             `          const value = oControl.getProperty("value");` && |\n| &&
             `` && |\n| &&
             `          let stored;` && |\n| &&
             `          try {` && |\n| &&
             `            const storageType = Storage.Type[type] || Storage.Type.session;` && |\n| &&
             `            const storage = new Storage(storageType, prefix);` && |\n| &&
             `            const read = storage.get(key);` && |\n| &&
             `            stored = read == null ? "" : read;` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            Lib.logError(``Storage: read failed for key '${key}'``, e);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Only fire "finished" when the stored value differs from the` && |\n| &&
             `          // current property to avoid feedback loops.` && |\n| &&
             `          if (stored !== value) {` && |\n| &&
             `            oControl.setProperty("value", stored, true);` && |\n| &&
             `            oControl.fireFinished({` && |\n| &&
             `              type: type,` && |\n| &&
             `              prefix: prefix,` && |\n| &&
             `              key: key,` && |\n| &&
             `              value: stored,` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
