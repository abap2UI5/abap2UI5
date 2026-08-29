// Invisible control that sets the browser favicon from its bound
// `favicon` URL (updates the existing <link> tag or creates one).
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
  // OBSOLETE: replaced by the frontend event cs_event-set_favicon - kept for backward compatibility.
  return Control.extend("z2ui5.cc.Favicon", {
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
      const href = Lib.toText(val);
      // same guard as the SET_FAVICON action - see core/actions/Browser.js
      if (!Lib.isSafeDownloadURL(href)) {
        Lib.logError(`Favicon: refused unsafe URL "${href}"`);
        return;
      }
      // Match ANY icon link, not just rel="shortcut icon": a page that
      // declares the modern rel="icon" (or "icon shortcut") would otherwise
      // keep its own link and get a second, competing one appended on every
      // app start - which icon the browser then shows is up to it.
      // ~= matches one entry of the whitespace-separated rel list.
      const existing = document.head.querySelector('link[rel~="icon"]');
      if (existing) {
        existing.href = href;
        return;
      }
      const link = document.createElement("link");
      link.rel = "shortcut icon";
      link.href = href;
      document.head.appendChild(link);
    },
    renderer: Lib.EMPTY_RENDERER,
  });
});
