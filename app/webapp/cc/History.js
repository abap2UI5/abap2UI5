// Invisible control that rewrites the query string of the current browser
// URL (history.replaceState) from its bound `search` property - no page
// reload, no new history entry.
sap.ui.define(["sap/ui/core/Control", "z2ui5/core/Lib"], (Control, Lib) => {
  "use strict";
  // OBSOLETE: app state in the URL is handled by the framework now (client->hash_set( ), client->app_state_set_active( )) - kept for backward compatibility.
  return Control.extend("z2ui5.cc.History", {
    metadata: {
      properties: {
        search: {
          type: "string",
        },
      },
    },
    setSearch(val) {
      // Empty renderer -> suppress the no-op invalidation; the effect below
      // (rewriting the URL) is what actually matters.
      this.setProperty("search", val, true);
      try {
        const search = Lib.toText(val);
        // The value REPLACES the query string, so it is either empty or one
        // that starts with "?": it is written straight after the pathname,
        // and a value without the "?" rewrote the PATH ("app=x" turned
        // /sap/bc/z2ui5 into /sap/bc/z2ui5app=x) - replaceState accepts any
        // same-origin path without complaint. Logged, not repaired: a
        // control delegates, it does not guess what the app meant.
        if (search && !search.startsWith("?")) {
          Lib.logError(
            `History.setSearch: '${search}' is no query string - it has to start with "?"`,
          );
          return;
        }
        // Pass the existing state object along instead of null so we do
        // not clobber state someone else stored on the history entry.
        // The HASH is kept: core/Router.js is the hash's only owner, and
        // in the FLP the front of it is the SHELL's (#SO-action&/...) -
        // rewriting the URL without it stranded the launchpad, and with
        // routing active it dropped the #/app/<CLASS>/<DRAFT> route, so
        // Back/Forward/Reload fell back to ?app_start=.
        history.replaceState(
          history.state,
          "",
          `${window.location.pathname}${search}${window.location.hash}`,
        );
      } catch (e) {
        Lib.logError("History.setSearch: replaceState failed", e);
      }
    },
    renderer: Lib.EMPTY_RENDERER,
  });
});
