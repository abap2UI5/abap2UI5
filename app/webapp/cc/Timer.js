// Invisible control that fires its `finished` event once `delayMS`
// milliseconds after rendering - the backend binds the event to trigger
// time-driven roundtrips (auto-refresh, polling). With checkRepeat the
// timer re-arms itself after every firing.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";

  // OBSOLETE: replaced by the frontend event cs_event-start_timer - kept for backward compatibility.
  return Control.extend("z2ui5.cc.Timer", {
    metadata: {
      properties: {
        delayMS: {
          type: "int",
          defaultValue: 0,
        },
        checkActive: {
          type: "boolean",
          defaultValue: true,
        },
        checkRepeat: {
          type: "boolean",
          defaultValue: false,
        },
      },
      events: {
        finished: {
          allowPreventDefault: true,
          parameters: {},
        },
      },
    },
    onAfterRendering() {
      if (!this._pendingTimer) return;
      this._pendingTimer = false;
      this.delayedCall();
    },
    exit() {
      clearTimeout(this._timerId);
    },
    delayedCall() {
      if (!this.getProperty("checkActive")) return;
      clearTimeout(this._timerId);
      let repeat = this.getProperty("checkRepeat");
      const delay = Math.max(0, Number(this.getProperty("delayMS")) || 0);
      // a repeating timer with no delay is a loop of roundtrips as fast as
      // the browser can schedule them - never what was meant, and nothing
      // else in the chain could stop it. It fires once and says why
      if (repeat && delay === 0) {
        Lib.logError(
          "Timer: checkRepeat with delayMS 0 fires once - a repeating timer needs a delay",
        );
        repeat = false;
      }
      this._timerId = setTimeout(() => {
        // The control might have been destroyed during the delay.
        if (Lib.isDestroyed(this)) return;
        if (!repeat) this.setProperty("checkActive", false, true);
        this.fireFinished();
        // For repeating timers, queue the next iteration. Re-check destroy
        // again because fireFinished may have triggered teardown.
        if (repeat && !Lib.isDestroyed(this)) {
          this.delayedCall();
        }
      }, delay);
    },
    renderer: {
      apiVersion: 2,
      render(oRm, oControl) {
        Lib.renderInvisibleSpan(oRm, oControl);
        oControl._pendingTimer = oControl.getProperty("checkActive");
      },
    },
  });
});
