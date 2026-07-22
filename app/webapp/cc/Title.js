// Invisible control that sets the browser tab title from its bound
// `title` property.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
  // OBSOLETE: replaced by the frontend event cs_event-set_title - kept for backward compatibility.
  return Control.extend("z2ui5.cc.Title", {
    metadata: {
      properties: {
        title: {
          type: "string",
        },
      },
    },
    setTitle(val) {
      // Suppress invalidation: the renderer is empty, so a re-render would be
      // a no-op; the effect happens explicitly below.
      this.setProperty("title", val, true);
      document.title = Lib.toText(val);
    },
    renderer: { apiVersion: 2, render() {} },
  });
});
