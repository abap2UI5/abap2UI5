// Invisible control that sets the browser tab title from its bound
// `title` property.
sap.ui.define(
  [
    "sap/ui/core/Control",
    "z2ui5/core/Lib",
    "z2ui5/core/actions/Browser",
    "z2ui5/core/Env",
  ],
  (Control, Lib, Browser, Env) => {
    "use strict";
    // OBSOLETE: replaced by the frontend event cs_event-set_title - kept for backward compatibility.
    // The setter IS that event - the SET_TITLE action handler of
    // core/actions/Browser.js, which normalizes the value (an unbound
    // property becomes "", never "undefined") and logs instead of throwing.
    const Title = Control.extend("z2ui5.cc.Title", {
      metadata: {
        properties: {
          title: {
            type: "string",
          },
        },
      },
      setTitle(val) {
        // Empty renderer -> suppress the no-op invalidation; the effect below
        // (setting the tab title) is what actually matters.
        this.setProperty("title", val, true);
        Browser.handlers.SET_TITLE(null, ["SET_TITLE", val]);
        return this;
      },
      renderer: Lib.EMPTY_RENDERER,
    });
    return Env.ownClass(Title);
  },
);
