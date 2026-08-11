sap.ui.define(
  ["sap/m/library", "z2ui5/core/Lib", "z2ui5/core/AppState"],
  (mobileLibrary, Lib, AppState) => {
    "use strict";

    // ------------------------------------------------------------------
    // Actions against the SAP Fiori Launchpad shell: cross-app navigation
    // and the shell title. They all resolve the launchpad services captured
    // at component start (AppState.state.oLaunchpad) and no-op with a log
    // line outside the FLP.
    // ------------------------------------------------------------------

    const _URLHelper = mobileLibrary.URLHelper;

    // ------------------------------------------------------------------
    // Launchpad helpers
    // ------------------------------------------------------------------

    function withCrossAppNavigator(callback) {
      const nav = AppState.state.oLaunchpad?.CrossAppNavigator;
      if (!nav) {
        Lib.logError("CrossAppNav: not running inside Launchpad");
        return;
      }
      try {
        callback(nav);
      } catch (e) {
        Lib.logError("CrossAppNav: callback failed", e);
      }
    }

    function evCrossAppNavToPrevApp() {
      withCrossAppNavigator((nav) => nav.backToPreviousApp());
    }

    function evCrossAppNavToExt(oController, args) {
      withCrossAppNavigator((nav) => {
        const hash =
          nav.hrefForExternal({ target: args[1], params: args[2] }) || "";
        if (args[3] === "EXT") {
          // External redirect: replace the location while keeping the host.
          // base is the current page (same origin) + a shell-hash fragment,
          // so this is same-origin by construction; validate anyway to stay
          // consistent with every other redirect handler in this file.
          const base = window.location.href.split("#")[0];
          const url = `${base}${hash}`;
          if (!Lib.isValidRedirectURL(url)) {
            Lib.logError(`CrossAppNav EXT: unsafe redirect URL '${url}'`);
            return;
          }
          _URLHelper.redirect(url, true);
        } else {
          nav.toExternal({ target: { shellHash: hash } });
        }
      });
    }

    function evSetTitleLaunchpad(oController, args) {
      const title = Lib.toText(args[1]);
      try {
        const shell = AppState.state.oLaunchpad?.ShellUIService;
        if (shell?.setTitle) {
          const result = shell.setTitle(title);
          if (result?.catch) {
            result.catch((e) =>
              Lib.logError(
                "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",
                e,
              ),
            );
          }
        }
      } catch (e) {
        Lib.logError("SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed", e);
      }
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      CROSS_APP_NAV_TO_PREV_APP: evCrossAppNavToPrevApp,
      CROSS_APP_NAV_TO_EXT: evCrossAppNavToExt,
      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,
    };

    return { handlers };
  },
);
