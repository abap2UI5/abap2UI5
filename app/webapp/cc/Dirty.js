// Invisible control that marks the session as having unsaved changes:
// inside the Launchpad via the FLP dirty flag, standalone via the
// browser's "leave page?" confirmation prompt.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
  return Control.extend("z2ui5.cc.Dirty", {
    metadata: {
      properties: {
        isDirty: {
          type: "boolean",
          defaultValue: false,
        },
      },
    },
    setIsDirty(val) {
      this.setProperty("isDirty", val);

      // Fallback for non-launchpad scenarios: ask the browser to confirm
      // before leaving the page when something is unsaved.
      const fallback = () => {
        if (val) {
          window.onbeforeunload = (e) => {
            e.preventDefault();
            e.returnValue = "";
          };
        } else {
          window.onbeforeunload = null;
        }
      };

      // Use the FLP dirty flag when running inside the Launchpad (SAPUI5
      // only); otherwise fall back to the browser unload prompt.
      try {
        const launchpad = z2ui5.oLaunchpad;
        const hasFlpDirtyFlag =
          launchpad?.Container?.setDirtyFlag && launchpad.ShellUIService;
        if (hasFlpDirtyFlag) {
          launchpad.Container.setDirtyFlag(val);
        } else {
          fallback();
        }
      } catch (e) {
        Lib.logError("Dirty.setIsDirty: setDirtyFlag failed", e);
        fallback();
      }
    },
    exit() {
      window.onbeforeunload = null;
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
