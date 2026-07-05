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
             `  ["sap/ui/core/Control", "sap/ui/util/Storage", "z2ui5/core/Lib"],` && |\n| &&
             `  (Control, Storage, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible control that reads a value from browser storage` && |\n| &&
             `    // (session/local, see sap.ui.util.Storage) into its ``value`` property` && |\n| &&
             `    // and fires ``finished`` when the stored value differs from the current` && |\n| &&
             `    // one. The write side is handled by the STORE_DATA frontend action.` && |\n| &&
             `    return Control.extend("z2ui5.cc.Storage", {` && |\n| &&
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
             `      // Follows the shared rendering pattern (see core/Lib.js): the renderer` && |\n| &&
             `      // only marks the work, onAfterRendering reads the storage and fires` && |\n| &&
             `      // the event.` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (!this._pendingRead) return;` && |\n| &&
             `        this._pendingRead = false;` && |\n| &&
             `` && |\n| &&
             `        const type = this.getProperty("type");` && |\n| &&
             `        const prefix = this.getProperty("prefix");` && |\n| &&
             `        const key = this.getProperty("key");` && |\n| &&
             `        const value = this.getProperty("value");` && |\n| &&
             `` && |\n| &&
             `        let stored;` && |\n| &&
             `        try {` && |\n| &&
             `          const storageType = Storage.Type[type] || Storage.Type.session;` && |\n| &&
             `          const storage = new Storage(storageType, prefix);` && |\n| &&
             `          stored = storage.get(key) ?? "";` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``Storage: read failed for key '${key}'``, e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Only fire "finished" when the stored value differs from the` && |\n| &&
             `        // current property to avoid feedback loops.` && |\n| &&
             `        if (stored !== value) {` && |\n| &&
             `          this.setProperty("value", stored, true);` && |\n| &&
             `          this.fireFinished({ type, prefix, key, value: stored });` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          oRm.openStart("span", oControl);` && |\n| &&
             `          oRm.style("display", "none");` && |\n| &&
             `          oRm.openEnd();` && |\n| &&
             `          oRm.close("span");` && |\n| &&
             `          oControl._pendingRead = true;` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
