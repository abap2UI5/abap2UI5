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

    result = `sap.ui.define(["sap/ui/core/Control", "z2ui5/cc/Lib"], (Control, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `  return Control.extend("z2ui5.Focus", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        setUpdate: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        focusId: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `        },` && |\n| &&
             `        selectionStart: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "0",` && |\n| &&
             `        },` && |\n| &&
             `        selectionEnd: {` && |\n| &&
             `          type: "string",` && |\n| &&
             `          defaultValue: "0",` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    setFocusId(val) {` && |\n| &&
             `      try {` && |\n| &&
             `        this.setProperty("focusId", val);` && |\n| &&
             `        const oElement = z2ui5.oView && z2ui5.oView.byId(val);` && |\n| &&
             `        if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("Focus.setFocusId failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingFocus) return;` && |\n| &&
             `      this._pendingFocus = false;` && |\n| &&
             `      const oElement =` && |\n| &&
             `        z2ui5.oView && z2ui5.oView.byId(this.getProperty("focusId"));` && |\n| &&
             `      if (!oElement) return;` && |\n| &&
             `      try {` && |\n| &&
             `        // Merge the additional selection info into the existing focus info,` && |\n| &&
             `        // then apply both at once.` && |\n| &&
             `        const info = oElement.getFocusInfo();` && |\n| &&
             `        info.selectionStart = +this.getProperty("selectionStart");` && |\n| &&
             `        info.selectionEnd = +this.getProperty("selectionEnd");` && |\n| &&
             `        oElement.applyFocusInfo(info);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("Focus.onAfterRendering: applyFocusInfo failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    },` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `        if (!oControl.getProperty("setUpdate")) return;` && |\n| &&
             `        oControl.setProperty("setUpdate", false, true);` && |\n| &&
             `        oControl._pendingFocus = true;` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
