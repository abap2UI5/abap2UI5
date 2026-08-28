sap.ui.define(
  ["sap/m/Input", "sap/m/InputRenderer", "z2ui5/core/Lib"],
  (Input, InputRenderer, Lib) => {
    "use strict";

    // A sap.m.Input that carries the HTML `type` of its inner <input> as a
    // bindable PROPERTY - the control is a sap.m.Input in every other respect.
    //
    // sap.m.Input does have a `type` property, but it is the sap.m.InputType
    // ENUM (Text, Password, Number, Email, Tel, Url and the date/time members)
    // and the control derives its own behaviour from it. The HTML5 types
    // outside that enum - color, range, search, month, week, datetime-local -
    // cannot be reached through it at all. `inputType` writes the attribute
    // and nothing else, so the browser renders the field the app asked for
    // while value binding, suggestions, value state and events stay the
    // sap.m.Input the app already knows.

    // The HTML types a sap.m.Input stays a working field with. The eight left
    // out (button, checkbox, file, hidden, image, radio, reset, submit) are
    // not text-entry fields: writing a value into a `file` field THROWS,
    // `hidden` removes the field the control renders its label and value
    // state around, and the rest ignore the value entirely.
    // An unknown value is refused rather than written, because a browser
    // silently falls back to `text` for a type it does not know - which on
    // screen looks exactly like the property having had no effect at all.
    const HTML_TYPES = new Set([
      "color",
      "date",
      "datetime-local",
      "email",
      "month",
      "number",
      "password",
      "range",
      "search",
      "tel",
      "text",
      "time",
      "url",
      "week",
    ]);

    return Input.extend("z2ui5.cc.InputExt", {
      metadata: {
        properties: {
          // The HTML input type: "color", "range", "search", "month", ...
          // Empty leaves the field exactly as sap.m.Input rendered it, which
          // makes this control a plain sap.m.Input - so a BOUND type can
          // switch the override off again without the app having to restore
          // anything, and that is the point of the property: "render this as
          // a colour picker now" is a plain model update, no action travels.
          inputType: {
            type: "string",
            defaultValue: "",
          },
        },
      },

      // Written WITHOUT invalidating: the type is one DOM attribute and UI5
      // renders nothing else from it, so a bound type must not cost a
      // re-render of the input (and of its suggestion popup) on every change.
      // The write below reaches the live DOM directly; onAfterRendering
      // covers the case where there is no DOM yet.
      setInputType(val) {
        this.setProperty("inputType", val, true);
        this._applyInputType();
        return this;
      },

      onAfterRendering(...args) {
        Input.prototype.onAfterRendering.apply(this, args);
        // The fresh DOM carries the type sap.m.Input rendered from its own
        // `type` property. Remembered per rendering so that clearing
        // inputType puts THAT back - removing the attribute would silently
        // turn a Password field into a visible text one.
        const dom = this.getFocusDomRef();
        this._renderedType = dom ? dom.getAttribute("type") : null;
        this._applyInputType();
      },

      // the type to write, "" when unset; an unknown one is logged once and
      // treated as unset
      _htmlType() {
        const raw = this.getInputType();
        if (!raw) return "";
        // HTML compares the attribute case-insensitively and an ABAP caller
        // writes `COLOR` as readily as `color`, so normalize before the
        // lookup rather than refuse a value the browser would have taken.
        const type = String(raw).trim().toLowerCase();
        if (HTML_TYPES.has(type)) return type;
        // once per distinct value: _applyInputType runs on every rendering,
        // and a bad type must not fill the log with the same line
        if (this._refusedType !== type) {
          this._refusedType = type;
          Lib.logError(
            `InputExt: inputType "${raw}" is not an HTML input type a text ` +
              `field supports - ignored`,
          );
        }
        return "";
      },

      _applyInputType() {
        // the inner <input>, which is what carries the attribute - not the
        // control's outer DOM root
        const dom = this.getFocusDomRef();
        if (!dom) return;
        const type = this._htmlType();
        if (type) {
          dom.setAttribute("type", type);
        } else if (this._renderedType) {
          dom.setAttribute("type", this._renderedType);
        } else {
          dom.removeAttribute("type");
        }
      },

      renderer: InputRenderer,
    });
  },
);
