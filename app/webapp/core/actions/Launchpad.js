sap.ui.define(
  ["sap/m/library", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (mobileLibrary, Lib, ViewSlots) => {
    "use strict";

    // ------------------------------------------------------------------
    // Actions against the SAP Fiori Launchpad shell: cross-app navigation
    // and the shell title. They all resolve the launchpad services captured
    // at component start (ctx.state.oLaunchpad, through the controller's
    // context). The cross-app-nav
    // handlers no-op with a log line outside the FLP; the title handler is
    // deliberately silent, because ShellUIService resolves asynchronously
    // and can legitimately still be unset inside the FLP.
    // ------------------------------------------------------------------

    const _URLHelper = mobileLibrary.URLHelper;

    // ------------------------------------------------------------------
    // Launchpad helpers
    // ------------------------------------------------------------------

    function withCrossAppNavigator(oController, callback) {
      const nav = oController?.ctx?.state.oLaunchpad?.CrossAppNavigator;
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

    function evCrossAppNavToPrevApp(oController) {
      withCrossAppNavigator(oController, (nav) => nav.backToPreviousApp());
    }

    // The startup parameters handed to the target app (args[2]). Wired in a
    // view they arrive as the bound structure; queued from a handler the
    // documented `$` && client->_bind( nav_params ) arrives as its model path
    // (Lib.modelPathOf), which is read from the framework model here - it
    // used to go into hrefForExternal as a string, and the target app started
    // without its parameters. The empty placeholder in front of the EXT flag
    // is no parameters. Returns null when a path names nothing: navigating
    // anyway would hand over an app that misses the data it was called for.
    function navParams(oController, raw) {
      if (raw == null || raw === "") return undefined;
      const path = Lib.modelPathOf(raw);
      if (!path) return raw;
      const oView = oController?.getView?.();
      const oModel = oView
        ? (ViewSlots.trackedModel(oView) ?? oView.getModel())
        : undefined;
      const value = oModel?.getProperty(path);
      if (value == null) {
        Lib.logError(
          `CROSS_APP_NAV_TO_EXT: nothing bound at the model path '${path}'`,
        );
        return null;
      }
      return value;
    }

    function evCrossAppNavToExt(oController, args) {
      withCrossAppNavigator(oController, (nav) => {
        const params = navParams(oController, args[2]);
        if (params === null) return;
        const hash = nav.hrefForExternal({ target: args[1], params }) || "";
        if (args[3] === "EXT") {
          // External navigation: the intent is opened in a NEW window/tab
          // (URLHelper.redirect's second argument is bNewWindow) - the
          // behaviour the legacy handler had, kept as is; the current page
          // stays where it is.
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
        const shell = oController?.ctx?.state.oLaunchpad?.ShellUIService;
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
