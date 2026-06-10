sap.ui.define(["sap/ui/core/Control", "z2ui5/cc/Lib"], (Control, Lib) => {
  "use strict";
  return Control.extend("z2ui5.History", {
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
        const search = val == null ? "" : val;
        // Pass the current state object along: _processAfterRendering stores
        // the rendered view/model in history.state so the back button can
        // restore it without a roundtrip - replacing it with null would
        // break that popstate restore.
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
