sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (Control, Lib, ViewSlots) => {
    "use strict";
    // Invisible control that restores the keyboard focus (and the cursor
    // selection range) to the control given by focusId after a rerender -
    // the backend uses it to keep the focus stable across roundtrips.
    // OBSOLETE: replaced by the frontend event cs_event-set_focus - kept for backward compatibility.
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
      onBeforeRendering() {
        // Snapshot the caret of whatever text field currently holds focus,
        // taken before UI5 replaces or patches the DOM in this render cycle.
        // With parallel requests the user keeps typing while a roundtrip is in
        // flight; when the response re-renders the view the focused field is
        // often re-created, so by the time onAfterRendering runs its live caret
        // is already gone and the race guard below could no longer tell that
        // the user had typed past the (stale) captured position. Reading it
        // here - while the old, still-focused element is in the DOM - keeps the
        // guard working across a full view rebuild, not only an in-place patch.
        this._liveCaret = null;
        try {
          const active = document.activeElement;
          if (
            active &&
            (active.tagName === "INPUT" || active.tagName === "TEXTAREA")
          ) {
            const s = active.selectionStart;
            const e = active.selectionEnd;
            if (s != null && e != null) {
              this._liveCaret = { start: s, end: e };
            }
          }
        } catch {
          this._liveCaret = null;
        }
      },
      onAfterRendering() {
        const liveCaret = this._liveCaret;
        this._liveCaret = null;
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

            // Race guard: while the roundtrip was in flight the user kept
            // typing, so the live caret sits past the restored position.
            // Re-applying the stale, smaller position would yank the caret to
            // the left over text the user just entered - keep the live caret.
            //
            // The field is still the active element only when UI5 patched it in
            // place; a full view rebuild replaces it, so its live caret is gone
            // and we fall back to the pre-render snapshot (same logical field -
            // it is the focus target the backend asked to restore).
            if (len > 0) {
              let liveStart = null;
              let liveEnd = null;
              if (input === document.activeElement) {
                liveStart = input.selectionStart;
                liveEnd = input.selectionEnd;
              } else if (liveCaret) {
                liveStart = liveCaret.start;
                liveEnd = liveCaret.end;
              }
              if (liveStart != null && (liveStart > start || liveEnd > end)) {
                // Clamp the kept caret too: the re-rendered value may be
                // shorter than the snapshot was taken against.
                start = Math.min(Math.max(liveStart, 0), len);
                end = Math.min(Math.max(liveEnd, 0), len);
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
          Lib.renderInvisibleSpan(oRm, oControl);
          if (!oControl.getProperty("setUpdate")) return;
          oControl.setProperty("setUpdate", false, true);
          oControl._pendingFocus = true;
        },
      },
    });
  },
);
