CLASS z2ui5_cl_app_multiinputext_js DEFINITION
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


CLASS z2ui5_cl_app_multiinputext_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "sap/m/Token", "z2ui5/cc/Lib"],` && |\n| &&
             `  (Control, Token, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.MultiInputExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          MultiInputId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          MultiInputName: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          addedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `          checkInit: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
             `          },` && |\n| &&
             `          removedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          change: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      init() {` && |\n| &&
             `        this._setControlBound = this.setControl.bind(this);` && |\n| &&
             `        Lib.registerCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onTokenUpdate(oEvent) {` && |\n| &&
             `        Lib.applyTokenUpdate(this, oEvent);` && |\n| &&
             `        this.fireChange();` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `      setControl() {` && |\n| &&
             `        const table = z2ui5.oView?.byId(this.getProperty("MultiInputId"));` && |\n| &&
             `        if (!table || this.getProperty("checkInit")) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        try {` && |\n| &&
             `          table.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `          // Custom validator: turn any free-text entry into a Token where` && |\n| &&
             `          // both key and visible text equal the input string.` && |\n| &&
             `          table.addValidator(({ text }) => new Token({ key: text, text }));` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("MultiInputExt.setControl: setup failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
