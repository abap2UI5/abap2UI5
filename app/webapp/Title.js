sap.ui.define(["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.Title", {
    metadata: {
      properties: {
        title: {
          type: "string",
        },
      },
    },
    setTitle(val) {
      this.setProperty("title", val);
      document.title = val == null ? "" : String(val);
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
