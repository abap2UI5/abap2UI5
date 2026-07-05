CLASS z2ui5_cl_app_timer_js DEFINITION
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


CLASS z2ui5_cl_app_timer_js IMPLEMENTATION.

  METHOD get.

    result = `// Invisible control that fires its ``finished`` event once ``delayMS``` && |\n| &&
             `// milliseconds after rendering - the backend binds the event to trigger` && |\n| &&
             `// time-driven roundtrips (auto-refresh, polling). With checkRepeat the` && |\n| &&
             `// timer re-arms itself after every firing.` && |\n| &&
             `sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  return Control.extend("z2ui5.cc.Timer", {` && |\n| &&
             `    metadata: {` && |\n| &&
             `      properties: {` && |\n| &&
             `        delayMS: {` && |\n| &&
             `          type: "int",` && |\n| &&
             `          defaultValue: 0,` && |\n| &&
             `        },` && |\n| &&
             `        checkActive: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: true,` && |\n| &&
             `        },` && |\n| &&
             `        checkRepeat: {` && |\n| &&
             `          type: "boolean",` && |\n| &&
             `          defaultValue: false,` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      events: {` && |\n| &&
             `        finished: {` && |\n| &&
             `          allowPreventDefault: true,` && |\n| &&
             `          parameters: {},` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `    onAfterRendering() {` && |\n| &&
             `      if (!this._pendingTimer) return;` && |\n| &&
             `      this._pendingTimer = false;` && |\n| &&
             `      this.delayedCall();` && |\n| &&
             `    },` && |\n| &&
             `    exit() {` && |\n| &&
             `      clearTimeout(this._timerId);` && |\n| &&
             `    },` && |\n| &&
             `    delayedCall() {` && |\n| &&
             `      if (!this.getProperty("checkActive")) return;` && |\n| &&
             `      clearTimeout(this._timerId);` && |\n| &&
             `      const repeat = this.getProperty("checkRepeat");` && |\n| &&
             `      const delay = this.getProperty("delayMS");` && |\n| &&
             `      this._timerId = setTimeout(() => {` && |\n| &&
             `        // The control might have been destroyed during the delay.` && |\n| &&
             `        if (Lib.isDestroyed(this)) return;` && |\n| &&
             `        if (!repeat) this.setProperty("checkActive", false, true);` && |\n| &&
             `        this.fireFinished();` && |\n| &&
             `        // For repeating timers, queue the next iteration. Re-check destroy` && |\n| &&
             `        // again because fireFinished may have triggered teardown.` && |\n| &&
             `        if (repeat && !Lib.isDestroyed(this)) {` && |\n| &&
             `          this.delayedCall();` && |\n| &&
             `        }` && |\n| &&
             `      }, delay);` && |\n| &&
             `    },` && |\n| &&
             `    renderer: {` && |\n| &&
             `      apiVersion: 2,` && |\n| &&
             `      render(oRm, oControl) {` && |\n| &&
             `        oRm.openStart("span", oControl);` && |\n| &&
             `        oRm.style("display", "none");` && |\n| &&
             `        oRm.openEnd();` && |\n| &&
             `        oRm.close("span");` && |\n| &&
             `        oControl._pendingTimer = oControl.getProperty("checkActive");` && |\n| &&
             `      },` && |\n| &&
             `    },` && |\n| &&
             `  });` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
