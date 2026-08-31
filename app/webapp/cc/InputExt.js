sap.ui.define(
  ["sap/m/Input", "sap/m/InputRenderer", "z2ui5/core/Lib"],
  (Input, InputRenderer, Lib) => {
    "use strict";

    // A sap.m.Input that carries the HTML `inputmode` of its inner <input> as
    // a bindable PROPERTY. It is a sap.m.Input in every other respect: the
    // renderer is sap.m.InputRenderer unchanged, and with the property empty
    // the control writes nothing at all, so value binding, suggestions, value
    // state, events and the rendered DOM are the ones the app already knows.
    //
    // `inputmode` asks the on-screen keyboard for a layout without changing
    // what the field IS - `numeric` gives a digit pad on a field that still
    // takes any text, and `none` keeps the soft keyboard DOWN while the field
    // goes on taking input, which is what a barcode scanner needs. UI5 has no
    // property for it, so the only other way to set it is to write the
    // attribute onto the DOM - and every re-render throws that DOM away. Here
    // the mode is part of what the control IS: it is written on every
    // rendering, so nothing can lose it and no follow-up action has to arrive
    // in the right order.

    // The complete inputmode keyword list of the HTML standard. An unknown
    // value is refused rather than written, because a browser silently falls
    // back to its default for a keyword it does not know - which on screen
    // looks exactly like the property having had no effect at all.
    const HTML_MODES = new Set([
      "decimal",
      "email",
      "none",
      "numeric",
      "search",
      "tel",
      "text",
      "url",
    ]);

    return Input.extend("z2ui5.cc.InputExt", {
      metadata: {
        properties: {
          // The HTML inputmode: "none" hides the soft keyboard, "numeric",
          // "decimal", "tel", ... restore it with that layout. Empty leaves
          // the field exactly as sap.m.Input rendered it - so a BOUND mode can
          // switch the behaviour off again without the app having to restore
          // anything, and that is the point of the property: "keyboard on/off"
          // is a plain model update, with no action travelling at all.
          inputMode: {
            type: "string",
            defaultValue: "",
          },
        },
      },

      // Written WITHOUT invalidating: the mode is one DOM attribute and UI5
      // renders nothing from it, so a bound mode must not cost a re-render of
      // the input (and of its suggestion popup) on every toggle. The write
      // below reaches the live DOM directly; onAfterRendering covers the case
      // where there is no DOM yet.
      setInputMode(val) {
        this.setProperty("inputMode", val, true);
        this._applyInputMode();
        return this;
      },

      onAfterRendering(...args) {
        Input.prototype.onAfterRendering.apply(this, args);
        // What sap.m.Input rendered on the fresh DOM, remembered per
        // rendering. Today it renders no inputmode, so clearing the property
        // takes the attribute off; should a release start rendering one, an
        // empty property still leaves that release's own field behind rather
        // than a field this control stripped an attribute from.
        const dom = this.getFocusDomRef();
        this._renderedMode = dom ? dom.getAttribute("inputmode") : null;
        this._applyInputMode();
      },

      // the mode to write, "" when unset; an unknown one is logged once and
      // treated as unset
      _htmlMode() {
        const raw = this.getInputMode();
        if (!raw) return "";
        // HTML compares the attribute case-insensitively and an ABAP caller
        // writes `NUMERIC` as readily as `numeric`, so normalize before the
        // lookup rather than refuse a value the browser would have taken.
        const mode = String(raw).trim().toLowerCase();
        if (HTML_MODES.has(mode)) return mode;
        // _applyInputMode runs on every rendering, and a bad mode must not
        // fill the log with the same line
        if (this._refusedMode !== mode) {
          this._refusedMode = mode;
          Lib.logError(
            `InputExt: inputMode "${raw}" is not an HTML inputmode keyword - ` +
              `ignored`,
          );
        }
        return "";
      },

      _applyInputMode() {
        // the inner <input>, which is what carries the attribute - not the
        // control's outer DOM root
        const dom = this.getFocusDomRef();
        if (!dom) return;
        const mode = this._htmlMode();
        if (mode) {
          dom.setAttribute("inputmode", mode);
        } else if (this._renderedMode) {
          dom.setAttribute("inputmode", this._renderedMode);
        } else {
          dom.removeAttribute("inputmode");
        }
      },

      renderer: InputRenderer,
    });
  },
);
