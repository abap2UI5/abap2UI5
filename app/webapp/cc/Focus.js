sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
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
        const oElement = z2ui5.oView?.byId(val);
        if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());
      } catch (e) {
        Lib.logError("Focus.setFocusId failed", e);
      }
    },
    onAfterRendering() {
      if (!this._pendingFocus) return;
      this._pendingFocus = false;
      const oElement = z2ui5.oView?.byId(this.getProperty("focusId"));
      if (!oElement) return;
      try {
        // Merge the additional selection info into the existing focus info,
        // then apply both at once.
        const info = oElement.getFocusInfo();
        info.selectionStart = +this.getProperty("selectionStart");
        info.selectionEnd = +this.getProperty("selectionEnd");
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
});
