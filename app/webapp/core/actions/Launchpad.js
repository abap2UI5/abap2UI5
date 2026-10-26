sap.ui.define(
  ["sap/m/library", "z2ui5/core/Lib", "z2ui5/core/ViewSlots"],
  (mobileLibrary, Lib, ViewSlots) => {
    "use strict";

    // ------------------------------------------------------------------
    // Actions against the SAP Fiori Launchpad shell: cross-app navigation,
    // the links of a semantic object, the shell title and the app's width.
    // They all resolve
    // the launchpad services captured
    // at component start (ctx.state.oLaunchpad, through the controller's
    // context). The cross-app-nav
    // handlers no-op with a log line outside the FLP; the title and width
    // handlers are deliberately silent outside it, as there is no shell to
    // change.
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
    // documented `$` && client->_bind( nav_params ) is resolved by the
    // runner (FrontendAction.runCustom), and the two spellings it leaves -
    // `{/NAV_PARAMS}` (a bare _bind( )) and `/NAV_PARAMS` - arrive as the
    // model path (Lib.modelPathOf), which is read from the framework model
    // here. It used to go into hrefForExternal as a string, and the target
    // app started without its parameters. The empty placeholder in front of
    // the EXT flag is no parameters. Returns null when a path names nothing:
    // navigating anyway would hand over an app that misses the data it was
    // called for. The TARGET (args[1]) is read the same way - a bound
    // { semanticObject, action } structure works from both places.
    function boundArg(oController, raw, what) {
      if (raw == null || raw === "") return undefined;
      const path = Lib.modelPathOf(raw);
      if (!path) return raw;
      // the model of the slot the responding app filled (a popup app's
      // arguments live in POPUP, not in the caller's MAIN)
      const oModel = ViewSlots.responseModel(oController?.ctx, oController);
      const value = oModel?.getProperty(path);
      if (value == null) {
        Lib.logError(
          `CROSS_APP_NAV_TO_EXT: nothing bound at the model path '${path}' (${what})`,
        );
        return null;
      }
      return value;
    }

    // The target as hrefForExternal takes it. A view wire writes it as a JS
    // object literal - `{ semanticObject: "SO", action: "display" }`, which
    // UI5 evaluates into an object when the view is built. Queued from a
    // HANDLER the same text is no JSON (the keys are unquoted), the backend
    // cannot embed it as an object, and it arrived here as the STRING:
    // hrefForExternal composed a hash from nothing and the shell navigated
    // to it, silently. A string that opens a brace is therefore refused
    // with the spelling that works in both places - JSON, which the backend
    // embeds as an object and UI5's expression parser reads as well.
    function navTarget(oController, raw) {
      const target = boundArg(oController, raw, "target");
      if (typeof target === "string" && target.trim().startsWith("{")) {
        Lib.logError(
          `CROSS_APP_NAV_TO_EXT: target '${target}' is no object - spell it as JSON ({"semanticObject":"...","action":"..."}) or pass its model path`,
        );
        return null;
      }
      return target;
    }

    function evCrossAppNavToExt(oController, args) {
      withCrossAppNavigator(oController, (nav) => {
        const target = navTarget(oController, args[1]);
        if (target === null) return;
        const params = boundArg(oController, args[2], "params");
        if (params === null) return;
        const hash = nav.hrefForExternal({ target, params }) || "";
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

    // An intent as getLinks returns it ("#SO-action?A=1&B=2") split into
    // the parts CROSS_APP_NAV_TO_EXT takes, so the backend can navigate to
    // an entry without parsing a hash. A malformed one keeps only the hash.
    function splitIntent(sIntent) {
      const m = /^#?([^-?&#]+)-([^?&#~]+)(?:\?(.*))?$/.exec(sIntent || "");
      if (!m) return {};
      const params = {};
      for (const pair of (m[3] || "").split("&")) {
        if (!pair) continue;
        const i = pair.indexOf("=");
        const key = decodeURIComponent(i < 0 ? pair : pair.slice(0, i));
        if (key.startsWith("sap-")) continue; // shell-internal, not the app's
        params[key] = i < 0 ? "" : decodeURIComponent(pair.slice(i + 1));
      }
      return { semanticObject: m[1], action: m[2], params };
    }

    // A result that arrives after the roundtrip that asked for it waits for
    // a roundtrip in flight instead of meeting the busy guard, and a
    // controller gone in between (an app reset, an FLP re-launch) gets
    // nothing - the same as a message box's close callback
    // (ControlCall.dispatchWhenIdle).
    function dispatchWhenIdle(oController, eventArgs) {
      const fire = () => {
        if (!Lib.isControllerAlive(oController)) return;
        if (oController.ctx?.state?.isBusy) {
          Lib.afterRoundtrip(oController, () => setTimeout(fire, 0));
          return;
        }
        oController.eB(...eventArgs);
      };
      fire();
    }

    // The links of a semantic object, as getLinks resolves them for the
    // user's roles - the list a Fiori elements smart link shows in its
    // popover. args[1] is the target ({ semanticObject, action? }, read like
    // CROSS_APP_NAV_TO_EXT's), args[2] the intent parameters, args[3] the
    // backend event that receives the result as its first argument: a JSON
    // array of { intent, text, subTitle, semanticObject, action, params }.
    function evCrossAppNavGetLinks(oController, args) {
      withCrossAppNavigator(oController, (nav) => {
        const target = navTarget(oController, args[1]);
        if (target === null) return;
        const params = boundArg(oController, args[2], "params");
        if (params === null) return;
        const sEvent = Lib.toText(args[3]);
        if (!target?.semanticObject || !sEvent) {
          Lib.logError(
            "CROSS_APP_NAV_GET_LINKS: needs a target with a semanticObject and a callback event",
          );
          return;
        }
        const query = { semanticObject: target.semanticObject };
        if (target.action) query.action = target.action;
        if (params) query.params = params;
        // CrossApplicationNavigation answers with a jQuery promise, which
        // Promise.resolve adopts like any thenable
        Promise.resolve(nav.getLinks(query))
          .then((links) => {
            const result = (links || []).map((l) => ({
              intent: l.intent,
              text: l.text || "",
              subTitle: l.subTitle || "",
              ...splitIntent(l.intent),
            }));
            dispatchWhenIdle(oController, [[sEvent], JSON.stringify(result)]);
          })
          .catch((e) =>
            Lib.logError("CROSS_APP_NAV_GET_LINKS: getLinks failed", e),
          );
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

    // Full width instead of the shell's letterbox, what a Fiori elements
    // list gets from "sap.ui": { "fullWidth": true } in its manifest - which
    // the one z2ui5 component cannot set per app. args[1]: X or true for full
    // width, anything else for the letterbox - the backend drops a trailing
    // empty argument, so abap_false arrives as no argument at all. The
    // AppConfiguration module is required at component start; should the
    // first roundtrip outrun it, it is required here instead.
    function evSetAppFullWidth(oController, args) {
      const launchpad = oController?.ctx?.state.oLaunchpad;
      if (!launchpad) return;
      const raw = args[1];
      const fullWidth = raw === true || raw === "X" || raw === "true";
      const apply = (ac) => {
        try {
          ac.setApplicationFullWidth(fullWidth);
        } catch (e) {
          Lib.logError("SET_APP_FULL_WIDTH: setApplicationFullWidth failed", e);
        }
      };
      if (launchpad.AppConfiguration) {
        apply(launchpad.AppConfiguration);
        return;
      }
      sap.ui.require(["sap/ushell/services/AppConfiguration"], apply, (e) =>
        Lib.logError("SET_APP_FULL_WIDTH: AppConfiguration not loaded", e),
      );
    }

    // The events this module owns in the eF dispatch (see
    // core/FrontendAction.js, which merges the domain modules' handler maps).
    const handlers = {
      CROSS_APP_NAV_TO_PREV_APP: evCrossAppNavToPrevApp,
      CROSS_APP_NAV_TO_EXT: evCrossAppNavToExt,
      CROSS_APP_NAV_GET_LINKS: evCrossAppNavGetLinks,
      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,
      SET_APP_FULL_WIDTH: evSetAppFullWidth,
    };

    return { handlers };
  },
);
