sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";

    // Invisible companion control for a SmartMultiInput (referenced via
    // multiInputId): mirrors token updates and the select-option style
    // range data into bindable properties so the backend can read and
    // restore the input's state across roundtrips.
    return Control.extend("z2ui5.cc.SmartMultiInputExt", {
      metadata: {
        properties: {
          multiInputId: {
            type: "string",
          },
          addedTokens: {
            type: "object",
          },
          removedTokens: {
            type: "object",
          },
          rangeData: {
            type: "object",
            defaultValue: [],
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
        },
      },

      init() {
        this._setControlBound = this.setControl.bind(this);
        this._oInput = null;
        this._aPendingInnerControlsCreated = [];
        this._bInnerControlsCreated = false;
        Lib.registerCallback("onAfterRendering", this._setControlBound);
      },
      exit() {
        Lib.unregisterCallback("onAfterRendering", this._setControlBound);
        // Resolve any still-pending promises so awaiters don't hang.
        this._aPendingInnerControlsCreated.forEach((resolve) => resolve(null));
        this._aPendingInnerControlsCreated = [];
      },

      onTokenUpdate(oEvent) {
        Lib.applyTokenUpdate(this, oEvent);

        // Mirror each range entry with the visible token text + long key
        // so the backend has enough info to re-render the input later.
        const source = oEvent.getSource();
        const tokens = source.getTokens();
        const rangeData = source.getRangeData() || [];
        const enrichedRanges = rangeData.map((oRangeData, index) => {
          const token = tokens[index];
          oRangeData.tokenText = token?.getText() ?? "";
          oRangeData.tokenLongKey = token?.data("longKey");
          return oRangeData;
        });
        this.setProperty("rangeData", enrichedRanges);
        this.fireChange();
      },
      async setRangeData(aRangeData) {
        this.setProperty("rangeData", aRangeData);
        try {
          const input = await this.inputInitialized();
          if (Lib.isDestroyed(this) || !input) return;

          // Convert the ABAP-style uppercase keys to the camelCase property
          // names the smart multi input expects. "keyField" needs its capital
          // F preserved.
          const normalizedRangeData = aRangeData.map((oRangeData) => {
            const out = {};
            for (const [key, value] of Object.entries(oRangeData)) {
              const lower = key.toLowerCase();
              const finalKey = lower === "keyfield" ? "keyField" : lower;
              out[finalKey] = value;
            }
            return out;
          });
          input.setRangeData(normalizedRangeData);

          // We need to set token text explicitly, as setRangeData does no
          // recalculation.
          const inputTokens = input.getTokens() || [];
          for (const [index, token] of inputTokens.entries()) {
            const rangeItem = aRangeData[index];
            if (!rangeItem) continue;
            const { TOKENLONGKEY, TOKENTEXT } = rangeItem;
            token.data("longKey", TOKENLONGKEY);
            token.data("range", null);
            if (TOKENTEXT) token.setText(TOKENTEXT);
          }
        } catch (e) {
          Lib.logError("SmartMultiInputExt.setRangeData failed", e);
        }
      },
      renderer: { apiVersion: 2, render() {} },
      setControl() {
        const input = ViewSlots.byId("MAIN", this.getProperty("multiInputId"));
        if (!input || this.getProperty("checkInit")) return;
        this.setProperty("checkInit", true);
        try {
          input.attachTokenUpdate(this.onTokenUpdate.bind(this));
          input.attachInnerControlsCreated(
            this.onInnerControlsCreated.bind(this),
          );
        } catch (e) {
          Lib.logError("SmartMultiInputExt.setControl: setup failed", e);
        }
      },
      // Returns a Promise that resolves once the smart multi input's inner
      // controls exist - they are created lazily on first interaction.
      inputInitialized() {
        return new Promise((resolve) => {
          if (this._bInnerControlsCreated) {
            resolve(this._oInput);
          } else {
            this._aPendingInnerControlsCreated.push(resolve);
          }
        });
      },
      onInnerControlsCreated(oEvent) {
        this._oInput = oEvent.getSource();
        this._bInnerControlsCreated = true;
        this._aPendingInnerControlsCreated.forEach((resolve) =>
          resolve(this._oInput),
        );
        this._aPendingInnerControlsCreated = [];
      },
    });
  },
);
