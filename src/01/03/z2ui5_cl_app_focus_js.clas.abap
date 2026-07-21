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
             `    // OBSOLETE: replaced by the frontend event cs_event-set_focus - kept for backward compatibility.` && |\n| &&
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
             `      onBeforeRendering() {` && |\n| &&
             `        // Snapshot the caret of whatever text field currently holds focus,` && |\n| &&
             `        // taken before UI5 replaces or patches the DOM in this render cycle.` && |\n| &&
             `        // With parallel requests the user keeps typing while a roundtrip is in` && |\n| &&
             `        // flight; when the response re-renders the view the focused field is` && |\n| &&
             `        // often re-created, so by the time onAfterRendering runs its live caret` && |\n| &&
             `        // is already gone and the race guard below could no longer tell that` && |\n| &&
             `        // the user had typed past the (stale) captured position. Reading it` && |\n| &&
             `        // here - while the old, still-focused element is in the DOM - keeps the` && |\n| &&
             `        // guard working across a full view rebuild, not only an in-place patch.` && |\n| &&
             `        this._liveCaret = null;` && |\n| &&
             `        try {` && |\n| &&
             `          const active = document.activeElement;` && |\n| &&
             `          if (` && |\n| &&
             `            active &&` && |\n| &&
             `            (active.tagName === "INPUT" || active.tagName === "TEXTAREA")` && |\n| &&
             `          ) {` && |\n| &&
             `            const s = active.selectionStart;` && |\n| &&
             `            const e = active.selectionEnd;` && |\n| &&
             `            if (s != null && e != null) {` && |\n| &&
             `              this._liveCaret = { start: s, end: e };` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        } catch {` && |\n| &&
             `          this._liveCaret = null;` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        const liveCaret = this._liveCaret;` && |\n| &&
             `        this._liveCaret = null;` && |\n| &&
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
             `            // Race guard: while the roundtrip was in flight the user kept` && |\n| &&
             `            // typing, so the live caret sits past the restored position.` && |\n| &&
             `            // Re-applying the stale, smaller position would yank the caret to` && |\n| &&
             `            // the left over text the user just entered - keep the live caret.` && |\n| &&
             `            //` && |\n| &&
             `            // The field is still the active element only when UI5 patched it in` && |\n| &&
             `            // place; a full view rebuild replaces it, so its live caret is gone` && |\n| &&
             `            // and we fall back to the pre-render snapshot (same logical field -` && |\n| &&
             `            // it is the focus target the backend asked to restore).` && |\n| &&
             `            if (len > 0) {` && |\n| &&
             `              let liveStart = null;` && |\n| &&
             `              let liveEnd = null;` && |\n| &&
             `              if (input === document.activeElement) {` && |\n| &&
             `                liveStart = input.selectionStart;` && |\n| &&
             `                liveEnd = input.selectionEnd;` && |\n| &&
             `              } else if (liveCaret) {` && |\n| &&
             `                liveStart = liveCaret.start;` && |\n| &&
             `                liveEnd = liveCaret.end;` && |\n| &&
             `              }` && |\n| &&
             `              if (liveStart != null && (liveStart > start || liveEnd > end)) {` && |\n| &&
             `                // Clamp the kept caret too: the re-rendered value may be` && |\n| &&
             `                // shorter than the snapshot was taken against.` && |\n| &&
             `                start = Math.min(Math.max(liveStart, 0), len);` && |\n| &&
             `                end = Math.min(Math.max(liveEnd, 0), len);` && |\n| &&
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
             `          Lib.renderInvisibleSpan(oRm, oControl);` && |\n| &&
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
