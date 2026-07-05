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
             `          const oElement = ViewSlots.byId("MAIN", val);` && |\n| &&
             `          if (oElement) oElement.applyFocusInfo(oElement.getFocusInfo());` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Focus.setFocusId failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (!this._pendingFocus) return;` && |\n| &&
             `        this._pendingFocus = false;` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", this.getProperty("focusId"));` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        try {` && |\n| &&
             `          // Merge the additional selection info into the existing focus info,` && |\n| &&
             `          // then apply both at once.` && |\n| &&
             `          const info = oElement.getFocusInfo();` && |\n| &&
             `          info.selectionStart = Number(this.getProperty("selectionStart"));` && |\n| &&
             `          info.selectionEnd = Number(this.getProperty("selectionEnd"));` && |\n| &&
             `          oElement.applyFocusInfo(info);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("Focus.onAfterRendering: applyFocusInfo failed", e);` && |\n| &&
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
