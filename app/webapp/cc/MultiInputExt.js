sap.ui.define(
  ["sap/ui/core/Control", "sap/m/Token", "z2ui5/core/Lib"],
  (Control, Token, Lib) => {
    "use strict";

    return Control.extend("z2ui5.cc.MultiInputExt", {
      metadata: {
        properties: {
          MultiInputId: {
            type: "string",
          },
          MultiInputName: {
            type: "string",
          },
          addedTokens: {
            type: "object",
          },
          checkInit: {
            type: "boolean",
            defaultValue: false,
          },
          removedTokens: {
            type: "object",
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
        Lib.registerCallback("onAfterRendering", this._setControlBound);
      },
      exit() {
        Lib.unregisterCallback("onAfterRendering", this._setControlBound);
      },

      onTokenUpdate(oEvent) {
        Lib.applyTokenUpdate(this, oEvent);
        this.fireChange();
      },
      renderer: { apiVersion: 2, render() {} },
      setControl() {
        const table = z2ui5.oView?.byId(this.getProperty("MultiInputId"));
        if (!table || this.getProperty("checkInit")) return;
        this.setProperty("checkInit", true);
        try {
          table.attachTokenUpdate(this.onTokenUpdate.bind(this));
          // Custom validator: turn any free-text entry into a Token where
          // both key and visible text equal the input string.
          table.addValidator(({ text }) => new Token({ key: text, text }));
        } catch (e) {
          Lib.logError("MultiInputExt.setControl: setup failed", e);
        }
      },
    });
  },
);
