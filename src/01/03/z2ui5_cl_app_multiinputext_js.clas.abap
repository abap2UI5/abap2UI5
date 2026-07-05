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
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "sap/m/Token",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Token, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible companion control for a sap.m.MultiInput (referenced via` && |\n| &&
             `    // MultiInputId): mirrors added/removed tokens into the bindable` && |\n| &&
             `    // addedTokens/removedTokens properties and fires ``change`` so the` && |\n| &&
             `    // backend sees every token update. Also installs a validator that` && |\n| &&
             `    // turns free-text entries into tokens.` && |\n| &&
             `    return Control.extend("z2ui5.cc.MultiInputExt", {` && |\n| &&
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
             `        const input = ViewSlots.byId("MAIN", this.getProperty("MultiInputId"));` && |\n| &&
             `        if (!input || this.getProperty("checkInit")) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        try {` && |\n| &&
             `          input.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `          // Custom validator: turn any free-text entry into a Token where` && |\n| &&
             `          // both key and visible text equal the input string.` && |\n| &&
             `          input.addValidator(({ text }) => new Token({ key: text, text }));` && |\n| &&
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
