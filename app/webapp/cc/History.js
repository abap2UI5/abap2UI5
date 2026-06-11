sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
  return Control.extend("z2ui5.cc.History", {
    metadata: {
      properties: {
        search: {
          type: "string",
        },
      },
    },
    setSearch(val) {
      this.setProperty("search", val);
      try {
        const search = Lib.toText(val);
        // Pass the existing state object along instead of null so we do
        // not clobber state someone else stored on the history entry.
        history.replaceState(
          history.state,
          "",
          `${window.location.pathname}${search}`,
        );
      } catch (e) {
        Lib.logError("History.setSearch: replaceState failed", e);
      }
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
