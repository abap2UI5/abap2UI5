// Invisible control that sets the Launchpad shell title and the
// full-width mode when the app runs inside the FLP; does nothing when
// running standalone.
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/Context"],
  (Control, Lib, Context) => {
    "use strict";

    // The launchpad record of the control's component (state.oLaunchpad,
    // filled by Component._initLaunchpad inside the FLP). Null standalone
    // AND for a control in no component (Context.of answers null): the
    // second cannot tell whether there is a shell to talk to, so it is
    // logged once per call site - it looks exactly like standalone
    // otherwise - and the setter stays the no-op it is standalone.
    function launchpadOf(control, where) {
      const ctx = Context.of(control);
      if (!ctx) {
        Lib.logError(`LPTitle.${where}: no component context, ignored`);
        return null;
      }
      return ctx.state.oLaunchpad;
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
        try {
          const shell = launchpadOf(this, "setTitle")?.ShellUIService;
          if (!shell?.setTitle) return;
          // Same normalization as the SET_TITLE_LAUNCHPAD frontend action:
          // never hand undefined/null to the shell service.
          const result = shell.setTitle(Lib.toText(val));
          // setTitle may return a Promise; report any async failure.
          if (result?.catch) {
            result.catch((e) =>
              Lib.logError("LPTitle: Launchpad Service setTitle failed", e),
            );
          }
        } catch (e) {
          Lib.logError("LPTitle: Launchpad Service setTitle failed", e);
        }
      },

      setApplicationFullWidth(val) {
        this.setProperty("ApplicationFullWidth", val, true);
        try {
          const config = launchpadOf(
            this,
            "setApplicationFullWidth",
          )?.AppConfiguration;
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
