// Invisible control that sets the Launchpad shell title and the
// full-width mode when the app runs inside the FLP; does nothing when
// running standalone.
sap.ui.define(
  [
    "sap/ui/core/Control",
    "z2ui5/core/Lib",
    "z2ui5/core/Context",
    "z2ui5/core/actions/Launchpad",
  ],
  (Control, Lib, Context, Launchpad) => {
    "use strict";

    // The context of the control's component (core/Context.js), whose
    // state carries the launchpad record (state.oLaunchpad, filled by
    // Component._initLaunchpad inside the FLP). Null for a control in no
    // component: that one cannot tell whether there is a shell to talk to,
    // so it is logged once per call site - it looks exactly like standalone
    // otherwise - and the setter stays the no-op it is standalone.
    function contextOf(control, where) {
      const ctx = Context.of(control);
      if (!ctx) {
        Lib.logError(`LPTitle.${where}: no component context, ignored`);
        return null;
      }
      return ctx;
    }

    // OBSOLETE: replaced by the frontend event cs_event-set_title_launchpad - kept for backward compatibility.
    return Control.extend("z2ui5.cc.LPTitle", {
      metadata: {
        properties: {
          title: {
            type: "string",
          },
          ApplicationFullWidth: {
            type: "boolean",
          },
        },
      },
      setTitle(val) {
        // Empty renderer -> suppress the no-op invalidation; the effect below
        // (setting the shell title) is what actually matters.
        this.setProperty("title", val, true);
        const ctx = contextOf(this, "setTitle");
        if (!ctx) return;
        // The setter IS the SET_TITLE_LAUNCHPAD event: the action handler
        // (core/actions/Launchpad.js) reads the shell service off the
        // context, normalizes the title (never undefined/null to the shell)
        // and logs a rejecting or throwing setTitle instead of throwing -
        // the control used to carry a copy of all three.
        Launchpad.handlers.SET_TITLE_LAUNCHPAD({ ctx }, [
          "SET_TITLE_LAUNCHPAD",
          val,
        ]);
      },

      setApplicationFullWidth(val) {
        this.setProperty("ApplicationFullWidth", val, true);
        try {
          const config = contextOf(this, "setApplicationFullWidth")?.state
            .oLaunchpad?.AppConfiguration;
          if (config?.setApplicationFullWidth) {
            config.setApplicationFullWidth(val);
          }
        } catch (e) {
          Lib.logError("LPTitle: setApplicationFullWidth failed", e);
        }
      },

      renderer: Lib.EMPTY_RENDERER,
    });
  },
);
