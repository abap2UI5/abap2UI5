CLASS z2ui5_cl_app_focus_js DEFINITION
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


CLASS z2ui5_cl_app_focus_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],` && |\n| &&
             `  (Control, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    // Invisible control that restores the keyboard focus (and the cursor` && |\n| &&
             `    // selection range) to the control given by focusId after a rerender -` && |\n| &&
             `    // the backend uses it to keep the focus stable across roundtrips.` && |\n| &&
             `    return Control.extend("z2ui5.cc.Focus", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          setUpdate: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          focusId: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `          },` && |\n| &&
             `          selectionStart: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "0",` && |\n| &&
             `          },` && |\n| &&
             `          selectionEnd: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "0",` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      setFocusId(val) {` && |\n| &&
             `        try {` && |\n| &&
             `          this.setProperty("focusId", val);` && |\n| &&
             `          const oElement = ViewSlots.byIdOfOwner(this, val);` && |\n| &&
             `          if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Focus.setFocusId failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (!this._pendingFocus) return;` && |\n| &&
             `        this._pendingFocus = false;` && |\n| &&
             `        const oElement = ViewSlots.byIdOfOwner(` && |\n| &&
             `          this,` && |\n| &&
             `          this.getProperty("focusId"),` && |\n| &&
             `        );` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        try {` && |\n| &&
             `          // Merge the additional selection info into the existing focus info,` && |\n| &&
             `          // then apply both at once.` && |\n| &&
             `          const info = oElement.getFocusInfo();` && |\n| &&
             `          let start = Number(this.getProperty("selectionStart"));` && |\n| &&
             `          let end = Number(this.getProperty("selectionEnd"));` && |\n| &&
             `` && |\n| &&
             `          const input = this._textInput(oElement);` && |\n| &&
             `          if (input) {` && |\n| &&
             `            // The caret position was captured before the roundtrip; the field` && |\n| &&
             `            // value may have changed since (e.g. it was cleared). Clamp to the` && |\n| &&
             `            // current length so an out-of-range range does not make the browser` && |\n| &&
             `            // snap the caret to 0.` && |\n| &&
             `            const len = (input.value ?? "").length;` && |\n| &&
             `            start = Math.min(Math.max(start, 0), len);` && |\n| &&
             `            end = Math.min(Math.max(end, 0), len);` && |\n| &&
             `` && |\n| &&
             `            // Race guard: while the roundtrip was in flight the user may have` && |\n| &&
             `            // kept typing (e.g. clear "X" then Backspace). The field already` && |\n| &&
             `            // holds text and its live caret sits past the restored position.` && |\n| &&
             `            // Re-applying the stale, smaller position would yank the caret to` && |\n| &&
             `            // the left over text the user just entered - keep the live caret` && |\n| &&
             `            // in that case and only re-assert focus.` && |\n| &&
             `            if (input === document.activeElement && len > 0) {` && |\n| &&
             `              const liveStart = input.selectionStart;` && |\n| &&
             `              const liveEnd = input.selectionEnd;` && |\n| &&
             `              if (liveStart != null && (liveStart > start || liveEnd > end)) {` && |\n| &&
             `                input.focus();` && |\n| &&
             `                return;` && |\n| &&
             `              }` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          info.selectionStart = start;` && |\n| &&
             `          info.selectionEnd = end;` && |\n| &&
             `          oElement.applyFocusInfo(info);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Focus.onAfterRendering: applyFocusInfo failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // The <input>/<textarea> that carries the caret for the focused control,` && |\n| &&
             `      // or null for controls without a text field (the selection clamp and` && |\n| &&
             `      // race guard only apply to real text fields).` && |\n| &&
             `      _textInput(oElement) {` && |\n| &&
             `        try {` && |\n| &&
             `          const ref = oElement.getFocusDomRef?.();` && |\n| &&
             `          if (ref && (ref.tagName === "INPUT" || ref.tagName === "TEXTAREA")) {` && |\n| &&
             `            return ref;` && |\n| &&
             `          }` && |\n| &&
             `          const root = oElement.getDomRef?.();` && |\n| &&
             `          return root?.querySelector?.("input, textarea") || null;` && |\n| &&
             `        } catch {` && |\n| &&
             `          return null;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          oRm.openStart("span", oControl);` && |\n| &&
             `          oRm.style("display", "none");` && |\n| &&
             `          oRm.openEnd();` && |\n| &&
             `          oRm.close("span");` && |\n| &&
             `          if (!oControl.getProperty("setUpdate")) return;` && |\n| &&
             `          oControl.setProperty("setUpdate", false, true);` && |\n| &&
             `          oControl._pendingFocus = true;` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
