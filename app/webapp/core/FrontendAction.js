sap.ui.define(
  [
    "sap/m/MessageBox",
    "sap/ui/model/odata/v2/ODataModel",
    "sap/m/library",
    "sap/ui/util/Storage",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (
    MessageBox,
    ODataModel,
    mobileLibrary,
    Storage,
    Lib,
    ViewSlots,
    AppState,
  ) => {
    "use strict";

    // ------------------------------------------------------------------
    // Frontend actions: the handlers behind the controller's eF() entry
    // point. eF itself stays on View1.controller (its name is part of the
    // protocol - backend-generated view XML binds events to eB/eF); the
    // behavior lives here, one function per event. Handlers that need to
    // reach controller state (destroyPopup, eB, ...) receive the calling
    // controller as first argument.
    // ------------------------------------------------------------------

    const _URLHelper = mobileLibrary.URLHelper;

    // ------------------------------------------------------------------
    // Launchpad / NavContainer helpers
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

    function navigateContainer(lookup, args) {
      try {
        const container = lookup(args[1]);
        const target = lookup(args[2]);
        if (!container || !target) {
          Lib.logError(
            `navigateContainer: control '${!container ? args[1] : args[2]}' not found`,
          );
          return;
        }
        container.to(target);
      } catch (e) {
        Lib.logError("navigateContainer: navigation failed", e);
      }
    }

    // Lookup tables mapping event names to the right view slot.
    const navContainerLookups = {
      NAV_CONTAINER_TO: (id) => ViewSlots.byId("MAIN", id),
      NEST_NAV_CONTAINER_TO: (id) => ViewSlots.byId("NEST", id),
      NEST2_NAV_CONTAINER_TO: (id) => ViewSlots.byId("NEST2", id),
      POPUP_NAV_CONTAINER_TO: (id) => ViewSlots.byId("POPUP", id),
      POPOVER_NAV_CONTAINER_TO: (id) => ViewSlots.byId("POPOVER", id),
    };

    // ------------------------------------------------------------------
    // Individual event handlers - one per entry in the dispatch table at
    // the bottom. Uniform signature (oController, args) so the dispatch
    // stays trivial; handlers that don't need the controller ignore it.
    // ------------------------------------------------------------------

    function evHistoryBack() {
      history.back();
    }

    function evClipboardCopy(oController, args) {
      Lib.copyToClipboard(args[1]);
    }

    function evClipboardAppState() {
      // Guard against a missing response so the copied link never carries
      // the literal "undefined" as its state id.
      const id = AppState.state.oResponse?.ID || "";
      // Strip any existing hash (e.g. an active app-state) so the copied
      // link carries only the fresh state id.
      const base = window.location.href.split("#")[0];
      Lib.copyToClipboard(`${base}#/z2ui5-xapp-state=${id}`);
    }

    function evDownloadB64File(oController, args) {
      if (!Lib.isSafeDownloadURL(args[1])) {
        Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");
        return;
      }
      const a = document.createElement("a");
      a.href = args[1];
      // Fall back to an empty download attribute when the backend omits the
      // filename, so the anchor never carries the literal "undefined".
      a.download = args[2] || "";
      // Firefox only triggers a programmatic download click when the anchor
      // is part of the document, so attach it briefly and remove it again.
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }

    function evCrossAppNavToPrevApp() {
      withCrossAppNavigator((nav) => nav.backToPreviousApp());
    }

    function evSetSizeLimit(oController, args) {
      // Two call shapes:
      //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit
      //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit
      const hasLimit = args[2] !== undefined && args[2] !== "";
      const viewKey = hasLimit ? args[2] : args[1];
      const limit = hasLimit ? Number(args[1]) : NaN;
      const model = ViewSlots.getView(viewKey)?.getModel();

      const isValidLimit = Number.isFinite(limit) && limit > 0;
      if (isValidLimit) {
        AppState.state.viewSizeLimits[viewKey] = limit;
      } else {
        delete AppState.state.viewSizeLimits[viewKey];
      }
      if (model) {
        // 100 is the UI5 JSONModel default size limit.
        model.setSizeLimit(isValidLimit ? limit : 100);
        model.refresh(true);
      }
    }

    function evSetODataModel(oController, args) {
      try {
        const oModel = new ODataModel({
          serviceUrl: args[1],
          annotationURI: args[3] || "",
        });
        const oView = ViewSlots.getView("MAIN");
        if (oView) {
          oView.setModel(oModel, args[2] || undefined);
        } else {
          // No view to attach to - release the model instead of leaking it.
          oModel.destroy();
        }
      } catch (e) {
        Lib.logError(`SET_ODATA_MODEL: failed for '${args[1]}'`, e);
      }
    }

    function evStoreData(oController, args) {
      // Guard against a missing payload so the try below logs a
      // STORE_DATA-specific error instead of a generic dispatch failure.
      const { TYPE, PREFIX, VALUE, KEY } = args[1] ?? {};
      try {
        const storageType = Storage.Type[TYPE] || Storage.Type.session;
        const oStorage = new Storage(storageType, PREFIX);
        if (VALUE === "" || VALUE == null) {
          oStorage.remove(KEY);
        } else {
          oStorage.put(KEY, VALUE);
        }
      } catch (e) {
        Lib.logError(
          `STORE_DATA: storage operation failed for key '${KEY}'`,
          e,
        );
      }
    }

    function evCrossAppNavToExt(oController, args) {
      withCrossAppNavigator((nav) => {
        const hash =
          nav.hrefForExternal({ target: args[1], params: args[2] }) || "";
        if (args[3] === "EXT") {
          // External redirect: replace the location while keeping the host.
          const base = window.location.href.split("#")[0];
          _URLHelper.redirect(`${base}${hash}`, true);
        } else {
          nav.toExternal({ target: { shellHash: hash } });
        }
      });
    }

    function evLocationReload(oController, args) {
      if (Lib.isValidRedirectURL(args[1])) {
        window.location.href = args[1];
      } else {
        MessageBox.error(
          "Invalid redirect URL. Only relative URLs to the same domain are allowed.",
        );
      }
    }

    // SYSTEM_LOGOUT: prefer the launchpad logout when running inside the
    // FLP; otherwise terminate a possible stateful BSP session first and
    // then navigate to the logout URL.
    function evSystemLogout(oController, args) {
      const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";
      try {
        const container = AppState.state.oLaunchpad?.Container;
        // No explicit logout URL was passed (args is just the event name):
        // inside the launchpad, prefer its own logout over the BSP/ICF
        // redirect below.
        if (container?.logout && args.length <= 1) {
          container.logout();
          return;
        }
      } catch (e) {
        Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);
      }
      logoutViaBspTerminate(logoutUrl);
    }

    // When abap2UI5 is hosted as a BSP application,
    // /sap/public/bc/icf/logoff alone does not terminate the stateful
    // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).
    // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP
    // runtime calls server->session->terminate( ), then go to the ICF
    // logoff to also drop the SSO2 ticket. Outside a BSP path this goes
    // straight to the logout URL.
    function logoutViaBspTerminate(logoutUrl) {
      const path = window.location.pathname;
      if (!path.startsWith("/sap/bc/bsp/")) {
        redirectToLogout(logoutUrl);
        return;
      }

      const separator = path.includes("?") ? "&" : "?";
      const bspKill = `${path}${separator}sap-sessioncmd=logoff`;
      let done = false;
      const finish = () => {
        if (done) return;
        done = true;
        redirectToLogout(logoutUrl);
      };
      try {
        const frame = document.createElement("iframe");
        frame.style.display = "none";
        frame.src = bspKill;
        frame.addEventListener("load", finish);
        document.body.appendChild(frame);
      } catch {
        finish();
        return;
      }
      // Safety net: never wait longer than 1.5s for the BSP terminate.
      setTimeout(finish, 1500);
    }

    function redirectToLogout(logoutUrl) {
      if (Lib.isValidRedirectURL(logoutUrl)) {
        window.location.href = logoutUrl;
      } else {
        MessageBox.error(
          "Invalid logout URL. Only relative URLs to the same domain are allowed.",
        );
      }
    }

    function evOpenNewTab(oController, args) {
      if (!Lib.isValidRedirectURL(args[1])) {
        MessageBox.error(
          "Invalid URL. Only relative URLs to the same domain are allowed.",
        );
        return;
      }
      const newWindow = window.open(args[1], "_blank");
      // Clear opener to prevent the new tab from accessing window.opener.
      if (newWindow) newWindow.opener = null;
    }

    function evUrlHelper(oController, args) {
      const params = args[2] ?? {};
      const actions = {
        REDIRECT: () => {
          if (!Lib.isSafeRedirectProtocol(params.URL)) {
            MessageBox.error(
              "Invalid redirect URL. Only http/https protocols are allowed.",
            );
            return;
          }
          _URLHelper.redirect(params.URL, params.NEW_WINDOW);
        },
        TRIGGER_EMAIL: () =>
          _URLHelper.triggerEmail(
            params.EMAIL,
            params.SUBJECT,
            params.BODY,
            params.CC,
            params.BCC,
            params.NEW_WINDOW,
          ),
        TRIGGER_SMS: () => _URLHelper.triggerSms(params),
        TRIGGER_TEL: () => _URLHelper.triggerTel(params),
      };
      try {
        const fn = actions[args[1]];
        if (fn) fn();
      } catch (e) {
        Lib.logError(`URLHELPER: '${args[1]}' failed`, e);
      }
    }

    function evImageEditorPopupClose(oController) {
      let image;
      try {
        const editor = ViewSlots.byId("POPUP", "imageEditor");
        if (editor) image = editor.getImagePngDataURL();
      } catch (e) {
        Lib.logError("IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed", e);
      }
      ViewSlots.destroy("POPUP");
      oController.eB(["SAVE"], image);
    }

    function evStartTimer(oController, args) {
      // Intentionally a single timer slot: args[0] is always the event
      // name "START_TIMER", so a new START_TIMER replaces the previous
      // one. At most one backend timer is pending at any time - this is
      // by design, not a bug.
      const timerKey = args[0];
      const callbackEvent = args[1];
      const delay = Number(args[2]) || 0;
      const timers = AppState.state.timers;
      clearTimeout(timers[timerKey]);
      timers[timerKey] = setTimeout(() => {
        delete timers[timerKey];
        oController.eB([callbackEvent]);
      }, delay);
    }

    function evSetInputMode(oController, args) {
      try {
        const oElement = ViewSlots.byId("MAIN", args[1]);
        if (!oElement) return;
        const dom = oElement.getDomRef();
        if (!dom) return;
        const input = dom.matches("input, textarea")
          ? dom
          : dom.querySelector("input, textarea");
        if (!input) return;
        input.setAttribute("inputmode", args[2] || "text");
      } catch (e) {
        Lib.logError(
          `KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'`,
          e,
        );
      }
    }

    function evSetFocus(oController, args) {
      const oElement = ViewSlots.byId("MAIN", args[1]);
      if (!oElement) return;

      const applyFocus = () => {
        try {
          const info = oElement.getFocusInfo();
          if (args[2] != null && args[2] !== "") {
            info.selectionStart = Number(args[2]);
          }
          if (args[3] != null && args[3] !== "") {
            info.selectionEnd = Number(args[3]);
          }
          oElement.applyFocusInfo(info);
        } catch (e) {
          Lib.logError(`SET_FOCUS: failed for '${args[1]}'`, e);
        }
      };

      // The control may still be missing from the DOM when SET_FOCUS runs
      // together with a fresh view build. Apply now if it is rendered,
      // otherwise once it is.
      Lib.whenRendered(oElement, oController, applyFocus);
    }

    function evScrollTo(oController, args) {
      // args[1] = control id
      // args[2] = scrollTop  (Y, vertical, px)
      // args[3] = scrollLeft (X, horizontal, px) - optional, default 0
      // args[4] = behavior - "auto" (default) | "smooth" | "instant"
      // Strategy: prefer the control's scroll delegate (sap.m.Page,
      // ScrollContainer etc. expose ScrollEnablement). The delegate knows
      // the real scroll container, which often is NOT the control's root
      // DOM element - so native Element.scrollTo on getDomRef() silently
      // does nothing on a Page. ScrollEnablement.scrollTo(x, y, time)
      // animates when time > 0, so "smooth" maps to a 300ms animation.
      // Native Element.scrollTo is only used as a fallback for controls
      // without a delegate.
      try {
        const oElement = ViewSlots.byId("MAIN", args[1]);
        if (!oElement) return;
        const y = Number(args[2]) || 0;
        const x = Number(args[3]) || 0;
        const behavior = args[4] || "auto";
        const smooth = behavior === "smooth";

        let handled = false;
        try {
          const delegate = oElement.getScrollDelegate?.();
          if (delegate?.scrollTo) {
            // ScrollEnablement / iScroll delegate: scrollTo(x, y, time)
            delegate.scrollTo(x, y, smooth ? 300 : 0);
            handled = true;
          }
        } catch {
          // fall through
        }

        if (!handled) {
          const dom =
            document.getElementById(`${oElement.getId()}-inner`) ||
            oElement.getDomRef();
          if (dom?.scrollTo) {
            dom.scrollTo({ top: y, left: x, behavior });
            handled = true;
          } else if (dom) {
            dom.scrollTop = y;
            dom.scrollLeft = x;
            handled = true;
          } else if (oElement.scrollTo) {
            // sap.m.Page.scrollTo(y, time) - vertical only
            oElement.scrollTo(y, smooth ? 300 : 0);
            handled = true;
          }
        }
      } catch (e) {
        Lib.logError(`SCROLL_TO: failed for '${args[1]}'`, e);
      }
    }

    function evScrollIntoView(oController, args) {
      // args[1] = control id
      // args[2] = behavior - "smooth" (default) | "auto" | "instant"
      // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"
      // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"
      // Modern declarative scroll: bring a control into the viewport,
      // regardless of where the surrounding scroll container currently is.
      try {
        const oElement = ViewSlots.byId("MAIN", args[1]);
        if (!oElement) return;
        const dom = oElement.getDomRef();
        if (!dom || !dom.scrollIntoView) return;
        dom.scrollIntoView({
          behavior: args[2] || "smooth",
          block: args[3] || "start",
          inline: args[4] || "nearest",
        });
      } catch (e) {
        Lib.logError(`SCROLL_INTO_VIEW: failed for '${args[1]}'`, e);
      }
    }

    function evSetTitle(oController, args) {
      const title = Lib.toText(args[1]);
      try {
        document.title = title;
      } catch (e) {
        Lib.logError("SET_TITLE: setting document.title failed", e);
      }
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

    function evZ2ui5Custom(oController, args) {
      try {
        // Custom functions are registered by apps on the public z2ui5
        // global (js_loader popup), so resolve them via the facade.
        const fn = AppState.getGlobal(args[1]);
        if (typeof fn === "function") {
          fn(args.slice(2));
        } else {
          // Missing or not callable (e.g. the app never registered it via
          // the js_loader popup) - log it instead of failing silently or
          // with a generic TypeError.
          Lib.logError(`Z2UI5: 'z2ui5.${args[1]}' is not a function`);
        }
      } catch (e) {
        Lib.logError(`Z2UI5: '${args[1]}' failed`, e);
      }
    }

    function evWizardSetNextStep(oController, args) {
      try {
        const wiz = ViewSlots.byId("MAIN", args[1]);
        const step = ViewSlots.byId("MAIN", args[2]);
        const nextStep = ViewSlots.byId("MAIN", args[3]);
        if (wiz && step) wiz.discardProgress(step);
        if (step && nextStep) step.setNextStep(nextStep);
      } catch (e) {
        Lib.logError(`WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'`, e);
      }
    }

    function evPlayAudio(oController, args) {
      try {
        const playing = new Audio(args[1]).play();
        // play() returns a Promise; a rejection (e.g. blocked by the
        // browser's autoplay policy) is not caught by the surrounding
        // try/catch and would surface as an unhandled rejection.
        if (playing?.catch) {
          playing.catch((e) =>
            Lib.logError(`PLAY_AUDIO: failed for '${args[1]}'`, e),
          );
        }
      } catch (e) {
        Lib.logError(`PLAY_AUDIO: failed for '${args[1]}'`, e);
      }
    }

    // Frontend event dispatch: maps the eF event name to its handler.
    // NavContainer events are dispatched separately via
    // navContainerLookups above.
    const handlers = {
      SET_SIZE_LIMIT: evSetSizeLimit,
      HISTORY_BACK: evHistoryBack,
      CLIPBOARD_COPY: evClipboardCopy,
      CLIPBOARD_APP_STATE: evClipboardAppState,
      SET_ODATA_MODEL: evSetODataModel,
      STORE_DATA: evStoreData,
      DOWNLOAD_B64_FILE: evDownloadB64File,
      CROSS_APP_NAV_TO_PREV_APP: evCrossAppNavToPrevApp,
      CROSS_APP_NAV_TO_EXT: evCrossAppNavToExt,
      LOCATION_RELOAD: evLocationReload,
      SYSTEM_LOGOUT: evSystemLogout,
      OPEN_NEW_TAB: evOpenNewTab,
      POPUP_CLOSE: () => ViewSlots.destroy("POPUP"),
      POPOVER_CLOSE: () => ViewSlots.destroy("POPOVER"),
      URLHELPER: evUrlHelper,
      IMAGE_EDITOR_POPUP_CLOSE: evImageEditorPopupClose,
      SET_TITLE: evSetTitle,
      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,
      SET_FOCUS: evSetFocus,
      SCROLL_TO: evScrollTo,
      SCROLL_INTO_VIEW: evScrollIntoView,
      START_TIMER: evStartTimer,
      KEYBOARD_SET_MODE: evSetInputMode,
      Z2UI5: evZ2ui5Custom,
      WIZARD_SET_NEXT_STEP: evWizardSetNextStep,
      PLAY_AUDIO: evPlayAudio,
    };

    // Entry point called by View1.controller's eF().
    function execute(oController, args) {
      Lib.runCallbacks(AppState.state.onBeforeEventFrontend, args);

      try {
        // NavContainer navigation is dispatched via lookup table.
        const navLookup = navContainerLookups[args[0]];
        if (navLookup) {
          navigateContainer(navLookup, args);
          return;
        }

        const handler = handlers[args[0]];
        if (handler) handler(oController, args);
      } catch (e) {
        // Backstop: individual handlers already guard themselves, but a
        // malformed payload must never let an error escape into the caller.
        Lib.logError(`FrontendAction: handler '${args[0]}' failed`, e);
      }
    }

    return { execute };
  },
);
