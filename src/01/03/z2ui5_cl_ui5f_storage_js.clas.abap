* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_storage_js DEFINITION
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


CLASS z2ui5_cl_ui5f_storage_js IMPLEMENTATION.

  METHOD get.

    result = `// Invisible control that reads a value from browser storage` && |\n| &&
             `// (session/local, see sap.ui.util.Storage) into its ``value`` property` && |\n| &&
             `// and fires ``finished`` when the stored value differs from the current` && |\n| &&
             `// one. The write side is handled by the STORE_DATA frontend action.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "sap/ui/util/Storage", "z2ui5/core/Lib"],` && |\n| &&
             `  (Control, Storage, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Value equality for the stored payload. ``value`` is typed ``any``: a plain` && |\n| &&
             `    // string for the common case, a structure or a table once an app binds` && |\n| &&
             `    // one. A reference comparison reports EVERY object as different, because` && |\n| &&
             `    // sap/ui/util/Storage JSON-round-trips what it stores and therefore hands` && |\n| &&
             `    // back a fresh object on every read - the control would fire ``finished``` && |\n| &&
             `    // on each render, the backend would answer with a re-render, and that` && |\n| &&
             `    // fires again: an endless round-trip loop that made a structured value` && |\n| &&
             `    // unusable. Compare by value instead. Key order is not significant (the` && |\n| &&
             `    // stored copy went through JSON, the bound one comes from the model), and` && |\n| &&
             `    // the payload is JSON by construction, so this covers every shape that` && |\n| &&
             `    // can reach the property.` && |\n| &&
             `    function isSameValue(a, b) {` && |\n| &&
             `      if (a === b) return true;` && |\n| &&
             `      if (a === null || b === null) return false;` && |\n| &&
             `      if (typeof a !== "object" || typeof b !== "object") return false;` && |\n| &&
             `      if (Array.isArray(a) !== Array.isArray(b)) return false;` && |\n| &&
             `      if (Array.isArray(a)) {` && |\n| &&
             `        return a.length === b.length && a.every((v, i) => isSameValue(v, b[i]));` && |\n| &&
             `      }` && |\n| &&
             `      const keys = Object.keys(a);` && |\n| &&
             `      if (keys.length !== Object.keys(b).length) return false;` && |\n| &&
             `      return keys.every(` && |\n| &&
             `        (k) =>` && |\n| &&
             `          Object.prototype.hasOwnProperty.call(b, k) && isSameValue(a[k], b[k]),` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
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
             `          stored = storage.get(key);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``Storage: read failed for key '${key}'``, e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A key that holds nothing must leave the bound field ALONE. Reporting` && |\n| &&
             `        // the empty string for it used to overwrite whatever the app had -` && |\n| &&
             `        // and, worse, its TYPE: an app binding a structure got a plain "" on` && |\n| &&
             `        // the very first render, which the next roundtrip could not parse back` && |\n| &&
             `        // ("JSON_PARSING_ERROR ... Unsupported target for value [v]", because` && |\n| &&
             `        // a string cannot land on a deep ABAP target). "Nothing is stored" is` && |\n| &&
             `        // not a value, so there is nothing to report.` && |\n| &&
             `        if (stored === null || stored === undefined) return;` && |\n| &&
             `` && |\n| &&
             `        // Only fire "finished" when the stored value differs from the` && |\n| &&
             `        // current property to avoid feedback loops.` && |\n| &&
             `        if (!isSameValue(stored, value)) {` && |\n| &&
             `          this.setProperty("value", stored, true);` && |\n| &&
             `          this.fireFinished({ type, prefix, key, value: stored });` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          Lib.renderInvisibleSpan(oRm, oControl);` && |\n| &&
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
