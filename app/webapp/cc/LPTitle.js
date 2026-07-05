// Invisible control that sets the Launchpad shell title and the
// full-width mode when the app runs inside the FLP; does nothing when
// running standalone.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
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
      this.setProperty("title", val);
      try {
        const shell = z2ui5.oLaunchpad?.ShellUIService;
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
      this.setProperty("ApplicationFullWidth", val);
      try {
        const config = z2ui5.oLaunchpad?.AppConfiguration;
        if (config?.setApplicationFullWidth) {
          config.setApplicationFullWidth(val);
        }
      } catch (e) {
        Lib.logError("LPTitle: setApplicationFullWidth failed", e);
      }
    },

    renderer: { apiVersion: 2, render() {} },
  });
});
