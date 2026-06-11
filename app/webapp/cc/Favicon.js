sap.ui.define(["sap/ui/core/Control"], (Control) => {
  "use strict";
  return Control.extend("z2ui5.cc.Favicon", {
    metadata: {
      properties: {
        favicon: {
          type: "string",
        },
      },
    },
    setFavicon(val) {
      this.setProperty("favicon", val);
      const existing = document.head.querySelector('link[rel="shortcut icon"]');
      if (existing) {
        existing.href = val;
        return;
      }
      const link = document.createElement("link");
      link.rel = "shortcut icon";
      link.href = val;
      document.head.appendChild(link);
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
