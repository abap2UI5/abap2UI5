CLASS z2ui5_cl_app_smartmultiinpu_js DEFINITION
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


CLASS z2ui5_cl_app_smartmultiinpu_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],` && |\n| &&
             `  (Control, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Invisible companion control for a SmartMultiInput (referenced via` && |\n| &&
             `    // multiInputId): mirrors token updates and the select-option style` && |\n| &&
             `    // range data into bindable properties so the backend can read and` && |\n| &&
             `    // restore the input's state across roundtrips.` && |\n| &&
             `    return Control.extend("z2ui5.cc.SmartMultiInputExt", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          multiInputId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          addedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `          removedTokens: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `          },` && |\n| &&
             `          rangeData: {` && |\n| &&
             `            type: "object",` && |\n| &&
             `            defaultValue: [],` && |\n| &&
             `          },` && |\n| &&
             `          checkInit: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: false,` && |\n| &&
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
             `        this._oInput = null;` && |\n| &&
             `        this._oPendingInnerControlsCreated = null;` && |\n| &&
             `        this._bInnerControlsCreated = false;` && |\n| &&
             `        Lib.registerCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        Lib.unregisterCallback("onAfterRendering", this._setControlBound);` && |\n| &&
             `        // Resolve any still-pending promise so awaiters don't hang.` && |\n| &&
             `        if (this._oPendingInnerControlsCreated) {` && |\n| &&
             `          this._oPendingInnerControlsCreated(null);` && |\n| &&
             `        }` && |\n| &&
             `        this._oPendingInnerControlsCreated = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onTokenUpdate(oEvent) {` && |\n| &&
             `        Lib.applyTokenUpdate(this, oEvent);` && |\n| &&
             `` && |\n| &&
             `        // Mirror each range entry with the visible token text + long key` && |\n| &&
             `        // so the backend has enough info to re-render the input later.` && |\n| &&
             `        const source = oEvent.getSource();` && |\n| &&
             `        const tokens = source.getTokens();` && |\n| &&
             `        const rangeData = source.getRangeData() || [];` && |\n| &&
             `        const enrichedRanges = rangeData.map((oRangeData, index) => {` && |\n| &&
             `          const token = tokens[index];` && |\n| &&
             `          oRangeData.tokenText = token?.getText() ?? "";` && |\n| &&
             `          oRangeData.tokenLongKey = token?.data("longKey");` && |\n| &&
             `          return oRangeData;` && |\n| &&
             `        });` && |\n| &&
             `        this.setProperty("rangeData", enrichedRanges);` && |\n| &&
             `        this.fireChange();` && |\n| &&
             `      },` && |\n| &&
             `      async setRangeData(aRangeData) {` && |\n| &&
             `        this.setProperty("rangeData", aRangeData);` && |\n| &&
             `        try {` && |\n| &&
             `          const input = await this.inputInitialized();` && |\n| &&
             `          if (Lib.isDestroyed(this) || !input) return;` && |\n| &&
             `` && |\n| &&
             `          // Convert the ABAP-style uppercase keys to the camelCase property` && |\n| &&
             `          // names the smart multi input expects. "keyField" needs its capital` && |\n| &&
             `          // F preserved.` && |\n| &&
             `          const normalizedRangeData = aRangeData.map((oRangeData) => {` && |\n| &&
             `            const out = {};` && |\n| &&
             `            for (const [key, value] of Object.entries(oRangeData)) {` && |\n| &&
             `              const lower = key.toLowerCase();` && |\n| &&
             `              const finalKey = lower === "keyfield" ? "keyField" : lower;` && |\n| &&
             `              out[finalKey] = value;` && |\n| &&
             `            }` && |\n| &&
             `            return out;` && |\n| &&
             `          });` && |\n| &&
             `          input.setRangeData(normalizedRangeData);` && |\n| &&
             `` && |\n| &&
             `          // We need to set token text explicitly, as setRangeData does no` && |\n| &&
             `          // recalculation.` && |\n| &&
             `          const inputTokens = input.getTokens() || [];` && |\n| &&
             `          for (const [index, token] of inputTokens.entries()) {` && |\n| &&
             `            const rangeItem = aRangeData[index];` && |\n| &&
             `            if (!rangeItem) continue;` && |\n| &&
             `            const { TOKENLONGKEY, TOKENTEXT } = rangeItem;` && |\n| &&
             `            token.data("longKey", TOKENLONGKEY);` && |\n| &&
             `            token.data("range", null);` && |\n| &&
             `            if (TOKENTEXT) token.setText(TOKENTEXT);` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("SmartMultiInputExt.setRangeData failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      renderer: { apiVersion: 2, render() {} },` && |\n| &&
             `      setControl() {` && |\n| &&
             `        const input = ViewSlots.byId("MAIN", this.getProperty("multiInputId"));` && |\n| &&
             `        if (!input || this.getProperty("checkInit")) return;` && |\n| &&
             `        this.setProperty("checkInit", true);` && |\n| &&
             `        try {` && |\n| &&
             `          input.attachTokenUpdate(this.onTokenUpdate.bind(this));` && |\n| &&
             `          input.attachInnerControlsCreated(` && |\n| &&
             `            this.onInnerControlsCreated.bind(this),` && |\n| &&
             `          );` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("SmartMultiInputExt.setControl: setup failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      // Returns a Promise that resolves once the smart multi input's inner` && |\n| &&
             `      // controls exist - they are created lazily on first interaction.` && |\n| &&
             `      inputInitialized() {` && |\n| &&
             `        return new Promise((resolve) => {` && |\n| &&
             `          if (this._bInnerControlsCreated) {` && |\n| &&
             `            resolve(this._oInput);` && |\n| &&
             `          } else {` && |\n| &&
             `            this._oPendingInnerControlsCreated = resolve;` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `      onInnerControlsCreated(oEvent) {` && |\n| &&
             `        this._oInput = oEvent.getSource();` && |\n| &&
             `        if (this._oPendingInnerControlsCreated) {` && |\n| &&
             `          this._oPendingInnerControlsCreated(this._oInput);` && |\n| &&
             `        }` && |\n| &&
             `        this._oPendingInnerControlsCreated = null;` && |\n| &&
             `        this._bInnerControlsCreated = true;` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
