sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";
    // Invisible control that restores the keyboard focus (and the cursor
    // selection range) to the control given by focusId after a rerender -
    // the backend uses it to keep the focus stable across roundtrips.
    return Control.extend("z2ui5.cc.Focus", {
      metadata: {
        properties: {
          setUpdate: {
            type: "boolean",
            defaultValue: true,
          },
          focusId: {
            type: "string",
          },
          selectionStart: {
            type: "string",
            defaultValue: "0",
          },
          selectionEnd: {
            type: "string",
            defaultValue: "0",
          },
        },
      },
      setFocusId(val) {
        try {
          this.setProperty("focusId", val);
          const oElement = ViewSlots.byIdOfOwner(this, val);
          if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());
        } catch (e) {
          Lib.logError("Focus.setFocusId failed", e);
        }
      },
      onAfterRendering() {
        if (!this._pendingFocus) return;
        this._pendingFocus = false;
        const oElement = ViewSlots.byIdOfOwner(
          this,
          this.getProperty("focusId"),
        );
        if (!oElement) return;
        try {
          // Merge the additional selection info into the existing focus info,
          // then apply both at once.
          const info = oElement.getFocusInfo();
          let start = Number(this.getProperty("selectionStart"));
          let end = Number(this.getProperty("selectionEnd"));

          const input = this._textInput(oElement);
          if (input) {
            // The caret position was captured before the roundtrip; the field
            // value may have changed since (e.g. it was cleared). Clamp to the
            // current length so an out-of-range range does not make the browser
            // snap the caret to 0.
            const len = (input.value ?? "").length;
            start = Math.min(Math.max(start, 0), len);
            end = Math.min(Math.max(end, 0), len);

            // Race guard: while the roundtrip was in flight the user may have
            // kept typing (e.g. clear "X" then Backspace). The field already
            // holds text and its live caret sits past the restored position.
            // Re-applying the stale, smaller position would yank the caret to
            // the left over text the user just entered - keep the live caret
            // in that case and only re-assert focus.
            if (input === document.activeElement && len > 0) {
              const liveStart = input.selectionStart;
              const liveEnd = input.selectionEnd;
              if (liveStart != null && (liveStart > start || liveEnd > end)) {
                input.focus();
                return;
              }
            }
          }

          info.selectionStart = start;
          info.selectionEnd = end;
          oElement.applyFocusInfo(info);
        } catch (e) {
          Lib.logError("Focus.onAfterRendering: applyFocusInfo failed", e);
        }
      },

      // The <input>/<textarea> that carries the caret for the focused control,
      // or null for controls without a text field (the selection clamp and
      // race guard only apply to real text fields).
      _textInput(oElement) {
        try {
          const ref = oElement.getFocusDomRef?.();
          if (ref && (ref.tagName === "INPUT" || ref.tagName === "TEXTAREA")) {
            return ref;
          }
          const root = oElement.getDomRef?.();
          return root?.querySelector?.("input, textarea") || null;
        } catch {
          return null;
        }
      },
      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          oRm.openStart("span", oControl);
          oRm.style("display", "none");
          oRm.openEnd();
          oRm.close("span");
          if (!oControl.getProperty("setUpdate")) return;
          oControl.setProperty("setUpdate", false, true);
          oControl._pendingFocus = true;
        },
      },
    });
  },
);
