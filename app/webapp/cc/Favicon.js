// Invisible control that sets the browser favicon from its bound
// `favicon` URL (updates the existing <link> tag or creates one).
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
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
      const href = Lib.toText(val);
      const existing = document.head.querySelector('link[rel="shortcut icon"]');
      if (existing) {
        existing.href = href;
        return;
      }
      const link = document.createElement("link");
      link.rel = "shortcut icon";
      link.href = href;
      document.head.appendChild(link);
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
