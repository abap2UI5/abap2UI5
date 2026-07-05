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
          const oElement = ViewSlots.byId("MAIN", val);
          if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());
        } catch (e) {
          Lib.logError("Focus.setFocusId failed", e);
        }
      },
      onAfterRendering() {
        if (!this._pendingFocus) return;
        this._pendingFocus = false;
        const oElement = ViewSlots.byId("MAIN", this.getProperty("focusId"));
        if (!oElement) return;
        try {
          // Merge the additional selection info into the existing focus info,
          // then apply both at once.
          const info = oElement.getFocusInfo();
          info.selectionStart = Number(this.getProperty("selectionStart"));
          info.selectionEnd = Number(this.getProperty("selectionEnd"));
          oElement.applyFocusInfo(info);
        } catch (e) {
          Lib.logError("Focus.onAfterRendering: applyFocusInfo failed", e);
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
