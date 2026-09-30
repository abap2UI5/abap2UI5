// Invisible control that sets the browser favicon from its bound
// `favicon` URL (updates the existing <link> tag or creates one).
sap.ui.define(
  [
    "sap/ui/core/Control",
    "z2ui5/core/Lib",
    "z2ui5/core/actions/Browser",
    "z2ui5/core/Env",
  ],
  (Control, Lib, Browser, Env) => {
    "use strict";
    // OBSOLETE: replaced by the frontend event cs_event-set_favicon - kept for backward compatibility.
    //
    // The setter IS that event: it hands the value to the SET_FAVICON
    // action handler (core/actions/Browser.js), which owns the URL guard
    // (Lib.isSafeDownloadURL - active schemes and empty values refused)
    // and the one decision worth having in one place: a page that already
    // declares an icon link gets THAT link updated, never a second,
    // competing one appended. The control used to carry a copy of both,
    // and the two spellings of the link (rel="icon" vs the legacy
    // "shortcut icon") drifted between them once.
    const Favicon = Control.extend("z2ui5.cc.Favicon", {
      metadata: {
        properties: {
          favicon: {
            type: "string",
          },
        },
      },
      setFavicon(val) {
        // Empty renderer -> suppress the no-op invalidation; the effect below
        // (updating the <link> tag) is what actually matters.
        this.setProperty("favicon", val, true);
        Browser.handlers.SET_FAVICON(null, ["SET_FAVICON", val]);
        return this;
      },
      renderer: Lib.EMPTY_RENDERER,
    });
    return Env.ownClass(Favicon);
  },
);
