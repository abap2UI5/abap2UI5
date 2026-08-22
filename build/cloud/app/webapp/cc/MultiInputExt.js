sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/m/Token",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
  ],
  (Control, Token, Lib, ViewSlots) => {
    "use strict";

    // Invisible companion control for a sap.m.MultiInput (referenced via
    // MultiInputId): mirrors added/removed tokens into the bindable
    // addedTokens/removedTokens properties and fires `change` so the
    // backend sees every token update. Also installs the validator
    // MultiInput.addValidator takes: free-text entries always become tokens,
    // and a picked suggestion ROW becomes one too once TokenKeyCell /
    // TokenTextCells say which cells to build it from (tabular suggestions
    // have no default token at all).
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
          // Suggestion-ROW validator (optional). MultiInput.addValidator's
          // callback gets `suggestionObject` when the user picked a suggestion
          // ROW rather than typing free text, and with tabular suggestions
          // there is no default token at all - without a validator, picking a
          // row produces nothing. TokenKeyCell names the cell whose text
          // becomes the token key; TokenTextCells names the cells composing
          // the rest, rendered as `key(a b)` - the demo kit's own shape.
          // Both unset: the free-text branch below behaves exactly as before.
          TokenKeyCell: {
            type: "int",
            defaultValue: -1,
          },
          // comma-separated cell indices ("2,3"): an XML attribute is a
          // string, and a typed int[] cannot be written from a view
          TokenTextCells: {
            type: "string",
            defaultValue: "",
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
      // one suggestion row -> one Token, or null when this instance was not
      // configured for rows (which is what MultiInput expects for "no token")
      tokenFromRow(row) {
        const keyIdx = this.getProperty("TokenKeyCell");
        if (!(keyIdx >= 0)) return null;
        const cells = typeof row.getCells === "function" ? row.getCells() : [];
        const cellText = (i) => {
          const c = cells[i];
          return c && typeof c.getText === "function" ? c.getText() : undefined;
        };
        const key = cellText(keyIdx);
        if (key === undefined) {
          Lib.logError(
            `MultiInputExt: TokenKeyCell ${keyIdx} is not a text cell of the picked row`,
          );
          return null;
        }
        const rest = String(this.getProperty("TokenTextCells") || "")
          .split(",")
          .map((s) => s.trim())
          .filter((s) => s !== "")
          .map(Number)
          .map((i) => {
            const v = cellText(i);
            if (v === undefined) {
              Lib.logError(
                `MultiInputExt: TokenTextCells entry ${i} is not a text cell of the picked row`,
              );
            }
            return v;
          })
          .filter((v) => v !== undefined && v !== "");
        return new Token({
          key,
          text: rest.length ? `${key}(${rest.join(" ")})` : key,
        });
      },
      setControl() {
        const input = ViewSlots.byIdOfOwner(
          this,
          this.getProperty("MultiInputId"),
        );
        if (!Lib.claimOnce(this, input)) return;
        try {
          input.attachTokenUpdate(this.onTokenUpdate.bind(this));
          // Custom validator: a picked suggestion ROW becomes a Token built
          // from its cells (only when TokenKeyCell says which one), any
          // free-text entry becomes a Token whose key and visible text are
          // both the input string.
          input.addValidator((args) => {
            const row = args && args.suggestionObject;
            if (row) return this.tokenFromRow(row);
            return new Token({ key: args.text, text: args.text });
          });
        } catch (e) {
          Lib.logError("MultiInputExt.setControl: setup failed", e);
        }
      },
    });
  },
);
