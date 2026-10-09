sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/m/Token",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/Env",
  ],
  (Control, Token, Lib, ViewSlots, Env) => {
    "use strict";

    // A Token from RAW text - a cell's or an item's getText( ). Handed over
    // in the settings object, a string is read as binding syntax:
    // "Pump {X}" became a binding to path X, "A{1" threw out of MultiInput's
    // validator (no token, no change event), and a backslash vanished. The
    // setters take the value as it is. (The free-text branch first takes the
    // escaping off that some releases put on args.text - see freeText.)
    function plainToken(key, text) {
      const token = new Token();
      token.setKey(key);
      token.setText(text);
      return token;
    }

    // The text a user TYPED, from the free-text validator's args.text.
    // Whether MultiInput escaped it for the Token settings object
    // (ManagedObject.escapeSettingsValue: a backslash before every \, { and })
    // depends on the patch, not the minor - 1.71, 1.96 and 1.114.10 hand it
    // over raw, 1.108.30 and 1.117 on escaped - so neither the settings form
    // (raw "{a}" became a binding to /a, a backslash vanished) nor a setter
    // (escaped "\{a\}" was shown with its backslashes) is right on every
    // release. Decided per call instead: a text without those characters is
    // the same either way; one equal to the input's value is raw, one equal
    // to the escaped value is escaped; a pasted piece (no value to compare)
    // counts as escaped when it reads as a complete escape sequence.
    const SETTINGS_CHARS = /[\\{}]/;
    function freeText(text, input) {
      const given = Lib.toText(text);
      if (!SETTINGS_CHARS.test(given)) return given;
      let value = "";
      try {
        value = Lib.toText(input?.getValue?.()).trim();
      } catch (e) {
        Lib.logError("MultiInputExt: reading the input value failed", e);
      }
      if (value === given) return given;
      if (value && value.replace(/[\\{}]/g, "\\$&") === given) return value;
      return /^(?:[^\\{}]|\\[\\{}])*$/.test(given)
        ? given.replace(/\\([\\{}])/g, "$1")
        : given;
    }

    // Invisible companion control for a sap.m.MultiInput (referenced via
    // MultiInputId): mirrors added/removed tokens into the bindable
    // addedTokens/removedTokens properties and fires `change` so the
    // backend sees every token update. Also installs the validator
    // MultiInput.addValidator takes: free-text entries always become tokens,
    // and a picked suggestion ROW becomes one too once TokenKeyCell /
    // TokenTextCells say which cells to build it from (tabular suggestions
    // have no default token at all).
    const MultiInputExt = Control.extend("z2ui5.cc.MultiInputExt", {
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
        this._unhook = Lib.hookCallback(this, "onAfterRendering", "setControl");
      },
      exit() {
        this._unhook();
        this._detach();
      },

      // The handlers setControl put on the TARGET input, taken off again:
      // a companion destroyed while its target survives (a nested-view
      // rebuild that leaves the MAIN input in place) used to leave them on
      // the target for good. Every detach is optional-chained - the target
      // may be gone already, or a double that has no detach.
      _detach() {
        const input = this._target;
        this._target = null;
        if (!input || Lib.isDestroyed(input)) return;
        if (this._onTokenUpdate) {
          input.detachTokenUpdate?.(this._onTokenUpdate);
        }
        if (this._validator) input.removeValidator?.(this._validator);
        this._onTokenUpdate = null;
        this._validator = null;
      },

      onTokenUpdate(oEvent) {
        Lib.applyTokenUpdate(this, oEvent);
        this.fireChange();
      },
      renderer: Lib.EMPTY_RENDERER,
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
        return plainToken(key, rest.length ? `${key}(${rest.join(" ")})` : key);
      },
      setControl() {
        // Once claimed there is nothing left to do - skip the target lookup
        // (byIdOfOwner walks the parent chain on every roundtrip) entirely.
        if (this.getProperty("checkInit")) return;
        const input = ViewSlots.byIdOfOwner(
          this,
          this.getProperty("MultiInputId"),
        );
        if (!Lib.claimOnce(this, input)) return;
        try {
          // the bound handlers are kept for exit( )'s detach - see _detach
          this._target = input;
          this._onTokenUpdate = this.onTokenUpdate.bind(this);
          input.attachTokenUpdate(this._onTokenUpdate);
          // Custom validator: a picked suggestion ROW becomes a Token built
          // from its cells (only when TokenKeyCell says which one), any
          // free-text entry becomes a Token whose key and visible text are
          // both the input string.
          this._validator = (args) => {
            const picked = args?.suggestionObject;
            if (picked && typeof picked.getCells === "function") {
              // a tabular suggestion ROW: a Token only once TokenKeyCell
              // says which cell; an unconfigured instance stays inert
              return this.tokenFromRow(picked);
            }
            if (picked) {
              // a plain suggestionItems pick (a sap.ui.core.Item): MultiInput
              // hands it over together with the Token it already built from
              // the item's key and text (suggestedToken, 1.71 and 1.120
              // alike). It used to go through tokenFromRow like a row and
              // came back null - no token, no change event, the pick simply
              // vanished. Return that Token; build it from the item when a
              // release hands over none.
              if (args.suggestedToken) return args.suggestedToken;
              return plainToken(
                typeof picked.getKey === "function"
                  ? picked.getKey()
                  : args.text,
                typeof picked.getText === "function"
                  ? picked.getText()
                  : args.text,
              );
            }
            const text = freeText(args.text, input);
            return plainToken(text, text);
          };
          input.addValidator(this._validator);
        } catch (e) {
          Lib.logError("MultiInputExt.setControl: setup failed", e);
        }
      },
    });
    return Env.ownClass(MultiInputExt);
  },
);
