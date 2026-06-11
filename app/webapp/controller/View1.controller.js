sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/BusyIndicator",
    "sap/m/MessageBox",
    "sap/m/MessageToast",
    "sap/ui/core/Fragment",
    "sap/m/BusyDialog",
    "sap/ui/VersionInfo",
    "z2ui5/core/Server",
    "sap/ui/model/odata/v2/ODataModel",
    "sap/m/library",
    "sap/ui/core/routing/HashChanger",
    "sap/ui/util/Storage",
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
  ],
  (
    Controller,
    XMLView,
    JSONModel,
    BusyIndicator,
    MessageBox,
    MessageToast,
    Fragment,
    BusyDialog,
    VersionInfo,
    Server,
    ODataModel,
    mobileLibrary,
    HashChanger,
    Storage,
    Element,
    Lib,
  ) => {
    "use strict";

    // ------------------------------------------------------------------
    // Small utility helpers (module-private)
    // ------------------------------------------------------------------

    // Parse a value as integer milliseconds, falling back to `def` when the
    // input is empty / undefined.
    function parseMs(val, def) {
      return val ? +val : def;
    }

    // Helpers reused across calls; kept as module-level singletons.
    const _hashChanger = HashChanger.getInstance();
    const _URLHelper = mobileLibrary.URLHelper;

    // Single reusable BusyDialog flashed when the user clicks while a
    // roundtrip is already in flight (created lazily, kept for reuse).
    let _busyDialog = null;

    // ------------------------------------------------------------------
    // Launchpad / NavContainer helpers
    // ------------------------------------------------------------------

    function withCrossAppNavigator(callback) {
      const nav = z2ui5.oLaunchpad?.CrossAppNavigator;
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
        if (container) container.to(lookup(args[2]));
      } catch (e) {
        Lib.logError("navigateContainer: navigation failed", e);
      }
    }

    // Lookup tables mapping event names / param keys to the right view.
    const navContainerLookups = {
      NAV_CONTAINER_TO: (id) => z2ui5.oView?.byId(id),
      NEST_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest?.byId(id),
      NEST2_NAV_CONTAINER_TO: (id) => z2ui5.oViewNest2?.byId(id),
      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId("popupId", id),
      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId("popoverId", id),
    };

    // Frontend event dispatch: maps the eF event name to the controller
    // method handling it. NavContainer events are dispatched separately
    // via navContainerLookups above.
    const eventFrontendHandlers = {
      SET_SIZE_LIMIT: "_evSetSizeLimit",
      HISTORY_BACK: "_evHistoryBack",
      CLIPBOARD_COPY: "_evClipboardCopy",
      CLIPBOARD_APP_STATE: "_evClipboardAppState",
      SET_ODATA_MODEL: "_evSetODataModel",
      STORE_DATA: "_evStoreData",
      DOWNLOAD_B64_FILE: "_evDownloadB64File",
      CROSS_APP_NAV_TO_PREV_APP: "_evCrossAppNavToPrevApp",
      CROSS_APP_NAV_TO_EXT: "_evCrossAppNavToExt",
      LOCATION_RELOAD: "_evLocationReload",
      SYSTEM_LOGOUT: "_evSystemLogout",
      OPEN_NEW_TAB: "_evOpenNewTab",
      POPUP_CLOSE: "destroyPopup",
      POPOVER_CLOSE: "destroyPopover",
      URLHELPER: "_evUrlHelper",
      IMAGE_EDITOR_POPUP_CLOSE: "_evImageEditorPopupClose",
      SET_TITLE: "_evSetTitle",
      SET_TITLE_LAUNCHPAD: "_evSetTitleLaunchpad",
      SET_FOCUS: "_evSetFocus",
      SCROLL_TO: "_evScrollTo",
      SCROLL_INTO_VIEW: "_evScrollIntoView",
      START_TIMER: "_evStartTimer",
      KEYBOARD_SET_MODE: "_evSetInputMode",
      Z2UI5: "_evZ2ui5Custom",
      WIZARD_SET_NEXT_STEP: "_evWizardSetNextStep",
      PLAY_AUDIO: "_evPlayAudio",
    };

    function applyStoredSizeLimit(viewKey, oModel) {
      if (!oModel || !z2ui5.viewSizeLimits) return;
      const limit = z2ui5.viewSizeLimits[viewKey];
      if (limit !== undefined) oModel.setSizeLimit(limit);
    }

    return Controller.extend("z2ui5.controller.View1", {
      // ------------------------------------------------------------------
      // Model change tracking - remembers which /XX/ paths the user edited
      // so the next roundtrip only ships the delta.
      // ------------------------------------------------------------------
      _trackChanges(oModel) {
        oModel.attachPropertyChange((e) => {
          const params = e.getParameters();
          const raw = params.path;
          const ctx = params.context;
          if (!raw) return;
          // Resolve relative paths against the binding context.
          let p;
          if (ctx && !raw.startsWith("/")) {
            p = `${ctx.getPath()}/${raw}`;
          } else {
            p = raw;
          }
          if (p.startsWith("/XX/")) {
            if (!z2ui5.xxChangedPaths) z2ui5.xxChangedPaths = new Set();
            z2ui5.xxChangedPaths.add(p);
          }
        });
        return oModel;
      },

      onInit() {
        z2ui5.oRouter.attachRouteMatched(() => {
          Server.roundtrip();
        });
      },

      onAfterRendering() {
        if (z2ui5.oResponse && !z2ui5.oResponse._processed) {
          this._processAfterRendering();
        }
      },

      // Runs once after each roundtrip's view has been rendered, in two
      // named phases: display pending fragments/views, then update the
      // browser history/hash.
      async _processAfterRendering() {
        try {
          const oResponse = z2ui5.oResponse;
          if (oResponse._processed) return;
          oResponse._processed = true;

          const PARAMS = oResponse.PARAMS;
          if (!PARAMS) return;

          await this._displayPendingViews(PARAMS);
          this._updateBrowserHistory(PARAMS, oResponse.ID);
          if (PARAMS.SET_NAV_BACK) history.back();

          Lib.runCallbacks(z2ui5.onAfterRendering);
        } catch (e) {
          Lib.logError("_processAfterRendering: unexpected error", e);
          Server.responseError(e, "Unexpected Error Occurred - App Terminated");
        } finally {
          BusyIndicator.hide();
          z2ui5.isBusy = false;
          // Now that the view is rendered (and any busy indicator is gone),
          // run the follow-up JS snippets the backend asked for. Doing it here
          // - rather than as an early microtask - guarantees render-dependent
          // actions like SET_FOCUS find their target control in the DOM.
          this._runPendingCustomJs();
        }
      },

      // Phase 1: open/destroy the popup, nested views and popover the
      // response asked for.
      async _displayPendingViews(PARAMS) {
        const S_POPUP = PARAMS.S_POPUP;
        const S_VIEW_NEST = PARAMS.S_VIEW_NEST;
        const S_VIEW_NEST2 = PARAMS.S_VIEW_NEST2;
        const S_POPOVER = PARAMS.S_POPOVER;

        if (S_POPUP?.CHECK_DESTROY) this.destroyPopup();
        if (S_POPOVER?.CHECK_DESTROY) this.destroyPopover();

        if (S_POPUP?.XML) {
          this.destroyPopup();
          await this.displayFragment(S_POPUP.XML, "oViewPopup");
        }

        if (!z2ui5.checkNestAfter && S_VIEW_NEST?.XML) {
          this.destroyNestView();
          await this.displayNestedView(
            S_VIEW_NEST.XML,
            "oViewNest",
            "S_VIEW_NEST",
            z2ui5.oControllerNest,
          );
          z2ui5.checkNestAfter = true;
        }

        if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2?.XML) {
          this.destroyNestView2();
          await this.displayNestedView(
            S_VIEW_NEST2.XML,
            "oViewNest2",
            "S_VIEW_NEST2",
            z2ui5.oControllerNest2,
          );
          z2ui5.checkNestAfter2 = true;
        }

        if (S_POPOVER?.XML) {
          this.destroyPopover();
          await this.displayPopover(
            S_POPOVER.XML,
            "oViewPopover",
            S_POPOVER.OPEN_BY_ID,
          );
        }
      },

      // Phase 2: push the backend-requested URL and update the app-state
      // hash.
      _updateBrowserHistory(PARAMS, ID) {
        // Currently disabled: storing the rendered view + model in
        // history.state so a popstate could restore the view without a
        // backend hit. Cloning the full view XML and model data on every
        // roundtrip is expensive for large views and the restore is not
        // needed right now. Re-enable together with the popstate listener
        // in Component.js (_installPopstateListener).
        // const oView = z2ui5.oView;
        // let oState = {};
        // if (oView) {
        //   const model = oView.getModel();
        //   oState = {
        //     view: oView.mProperties.viewContent,
        //     model: model ? model.getData() : undefined,
        //     response: z2ui5.oResponse,
        //   };
        // }

        try {
          if (PARAMS.SET_PUSH_STATE) {
            const hash = _hashChanger.getHash();
            const newUrl = `${window.location.pathname}${window.location.search}#${hash}${PARAMS.SET_PUSH_STATE}`;
            history.pushState(null, "", newUrl);
          }
          // Disabled together with the state storing above - without a
          // state object this call was a pure no-op:
          // else {
          //   history.replaceState(oState, "", window.location.href);
          // }
          const newHash = PARAMS.SET_APP_STATE_ACTIVE
            ? `z2ui5-xapp-state=${ID || ""}`
            : "";
          _hashChanger.replaceHash(newHash);
        } catch (e) {
          Lib.logError("_updateBrowserHistory: history update failed", e);
        }
      },

      // Execute the follow-up JS snippets stashed by Server.responseSuccess.
      // Runs once per roundtrip, after the view has rendered.
      _runPendingCustomJs() {
        const customJs = z2ui5.pendingCustomJs;
        z2ui5.pendingCustomJs = null;
        if (!customJs) return;
        if (Lib.isDestroyed(this)) return;
        for (const item of customJs) {
          Server._runCustomJs(item, this);
        }
      },

      _createViewModel() {
        const data = z2ui5.oResponse?.OVIEWMODEL;
        return this._trackChanges(new JSONModel(data));
      },

      // ------------------------------------------------------------------
      // Display: popups, popovers, nested views, main view
      // ------------------------------------------------------------------

      async displayFragment(xml, viewProp) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit("POPUP", oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: z2ui5.oControllerPopup,
          id: "popupId",
        });
        // The app might have been torn down while the fragment loaded.
        if (!Lib.isAlive(z2ui5.oApp)) {
          oFragment.destroy();
          return;
        }
        oFragment.setModel(oModel);
        oFragment.Fragment = Fragment;
        z2ui5[viewProp] = oFragment;
        oFragment.open();
      },

      async displayPopover(xml, viewProp, openById) {
        try {
          const oModel = this._createViewModel();
          applyStoredSizeLimit("POPOVER", oModel);
          const oFragment = await Fragment.load({
            definition: xml,
            controller: z2ui5.oControllerPopover,
            id: "popoverId",
          });
          if (!Lib.isAlive(z2ui5.oApp)) {
            oFragment.destroy();
            return;
          }
          oFragment.setModel(oModel);
          oFragment.Fragment = Fragment;

          // Find the control to attach the popover to. We search the main
          // view first, then any open popup / nested views, then the global
          // UI5 control registry as a last resort.
          let oControl = z2ui5.oView?.byId(openById);
          if (!oControl && z2ui5.oViewPopup?.Fragment) {
            oControl = z2ui5.oViewPopup.Fragment.byId("popupId", openById);
          }
          if (!oControl && z2ui5.oViewNest) {
            oControl = z2ui5.oViewNest.byId(openById);
          }
          if (!oControl && z2ui5.oViewNest2) {
            oControl = z2ui5.oViewNest2.byId(openById);
          }
          if (!oControl) {
            if (Element.getElementById) {
              oControl = Element.getElementById(openById);
            } else {
              /* ui5lint-disable no-globals, no-deprecated-api --
                 deliberate fallback for UI5 releases that do not provide
                 Element.getElementById yet (added in 1.119); the modern
                 API is used in the branch above. */
              if (sap.ui.getCore) {
                const core = sap.ui.getCore();
                if (core?.byId) oControl = core.byId(openById);
              }
              /* ui5lint-enable no-globals, no-deprecated-api */
            }
          }

          if (!oControl) {
            Lib.logError(
              `displayPopover: openBy control '${openById}' not found`,
            );
            oFragment.destroy();
            return;
          }
          z2ui5[viewProp] = oFragment;
          oFragment.openBy(oControl);
        } catch (e) {
          Lib.logError("displayPopover: failed", e);
        }
      },

      async displayNestedView(xml, viewProp, viewNestId, controller) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit(Lib.slotKeyByParam(viewNestId), oModel);
        const oView = await XMLView.create({
          definition: xml,
          controller: controller,
          preprocessors: { xml: { models: { template: oModel } } },
        });

        if (!Lib.isAlive(z2ui5.oApp)) {
          oView.destroy();
          return;
        }
        oView.setModel(oModel);

        const nestParams =
          z2ui5.oResponse?.PARAMS && z2ui5.oResponse.PARAMS[viewNestId];
        if (!nestParams) {
          Lib.logError(`displayNestedView: missing PARAMS.${viewNestId}`);
          oView.destroy();
          return;
        }
        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;

        const oParent = z2ui5.oView?.byId(ID);
        if (!oParent) {
          Lib.logError(
            `displayNestedView: parent control '${ID}' not found, nested view discarded`,
          );
          oView.destroy();
          return;
        }

        try {
          oParent[METHOD_DESTROY]();
        } catch (e) {
          Lib.logError("displayNestedView: parent destroy method failed", e);
        }
        try {
          oParent[METHOD_INSERT](oView);
        } catch (e) {
          Lib.logError("displayNestedView: parent insert method failed", e);
          oView.destroy();
          return;
        }
        z2ui5[viewProp] = oView;
      },

      // Shared destroy logic: close (if dialog/popover) and destroy the view,
      // then clear the slot on z2ui5.
      _destroyView(prop, tryClose) {
        const view = z2ui5[prop];
        if (!view) return;
        if (tryClose) {
          try {
            if (view.close) view.close();
          } catch (e) {
            Lib.logError(`_destroyView: view.close() failed for ${prop}`, e);
          }
        }
        try {
          view.destroy();
        } catch (e) {
          Lib.logError(`_destroyView: view.destroy() failed for ${prop}`, e);
        }
        z2ui5[prop] = null;
      },

      destroyPopup() {
        this._destroyView("oViewPopup", true);
      },
      destroyPopover() {
        this._destroyView("oViewPopover", true);
      },
      destroyNestView() {
        this._destroyView("oViewNest");
      },
      destroyNestView2() {
        this._destroyView("oViewNest2");
      },
      destroyView() {
        this._destroyView("oView");
      },

      // ------------------------------------------------------------------
      // eF = "event frontend": handles frontend-only events triggered by
      // the backend response, without a roundtrip. The name is part of the
      // protocol - backend-generated view XML binds events to eB/eF - and
      // must not be renamed.
      // ------------------------------------------------------------------
      eF(...args) {
        Lib.runCallbacks(z2ui5.onBeforeEventFrontend, args);

        // NavContainer navigation is dispatched via lookup table.
        const navLookup = navContainerLookups[args[0]];
        if (navLookup) {
          navigateContainer(navLookup, args);
          return;
        }

        const handler = eventFrontendHandlers[args[0]];
        if (handler) this[handler](args);
      },

      // ------------------------------------------------------------------
      // Individual event handlers - one per entry in eventFrontendHandlers.
      // Splitting them out keeps eF() short and makes each behavior easy to
      // find.
      // ------------------------------------------------------------------

      _evHistoryBack() {
        history.back();
      },

      _evClipboardCopy(args) {
        Lib.copyToClipboard(args[1]);
      },

      _evClipboardAppState() {
        const id = z2ui5.oResponse?.ID;
        Lib.copyToClipboard(`${window.location.href}#/z2ui5-xapp-state=${id}`);
      },

      _evDownloadB64File(args) {
        if (!Lib.isSafeDownloadURL(args[1])) {
          Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");
          return;
        }
        const a = document.createElement("a");
        a.href = args[1];
        a.download = args[2];
        a.click();
      },

      _evCrossAppNavToPrevApp() {
        withCrossAppNavigator((nav) => nav.backToPreviousApp());
      },

      _evSetSizeLimit(args) {
        // Two call shapes:
        //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit
        //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit
        const hasLimit = args[2] !== undefined && args[2] !== "";
        const viewKey = hasLimit ? args[2] : args[1];
        const limit = hasLimit ? Number(args[1]) : NaN;
        const view = Lib.getViewByKey(viewKey);
        const model = view?.getModel();

        if (Number.isFinite(limit) && limit > 0) {
          if (!z2ui5.viewSizeLimits) z2ui5.viewSizeLimits = {};
          z2ui5.viewSizeLimits[viewKey] = limit;
          if (model) {
            model.setSizeLimit(limit);
            model.refresh(true);
          }
        } else {
          if (z2ui5.viewSizeLimits) delete z2ui5.viewSizeLimits[viewKey];
          if (model) {
            model.setSizeLimit(100);
            model.refresh(true);
          }
        }
      },

      _evSetODataModel(args) {
        try {
          const oModel = new ODataModel({
            serviceUrl: args[1],
            annotationURI: args[3] || "",
          });
          if (z2ui5.oView) z2ui5.oView.setModel(oModel, args[2] || undefined);
        } catch (e) {
          Lib.logError(`SET_ODATA_MODEL: failed for '${args[1]}'`, e);
        }
      },

      _evStoreData(args) {
        const { TYPE, PREFIX, VALUE, KEY } = args[1];
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
      },

      _evCrossAppNavToExt(args) {
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
      },

      _evLocationReload(args) {
        if (Lib.isValidRedirectURL(args[1])) {
          window.location.href = args[1];
        } else {
          MessageBox.error(
            "Invalid redirect URL. Only relative URLs to the same domain are allowed.",
          );
        }
      },

      // SYSTEM_LOGOUT: prefer the launchpad logout when running inside the
      // FLP; otherwise terminate a possible stateful BSP session first and
      // then navigate to the logout URL.
      _evSystemLogout(args) {
        const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";
        try {
          const container = z2ui5.oLaunchpad?.Container;
          if (container?.logout) {
            container.logout();
            return;
          }
        } catch (e) {
          Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);
        }
        this._logoutViaBspTerminate(logoutUrl);
      },

      // When abap2UI5 is hosted as a BSP application,
      // /sap/public/bc/icf/logoff alone does not terminate the stateful
      // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).
      // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP
      // runtime calls server->session->terminate( ), then go to the ICF
      // logoff to also drop the SSO2 ticket. Outside a BSP path this goes
      // straight to the logout URL.
      _logoutViaBspTerminate(logoutUrl) {
        const path = window.location.pathname;
        if (!path.startsWith("/sap/bc/bsp/")) {
          this._redirectToLogout(logoutUrl);
          return;
        }

        const sep = path.indexOf("?") >= 0 ? "&" : "?";
        const bspKill = `${path}${sep}sap-sessioncmd=logoff`;
        let done = false;
        const finish = () => {
          if (done) return;
          done = true;
          this._redirectToLogout(logoutUrl);
        };
        try {
          const f = document.createElement("iframe");
          f.style.display = "none";
          f.src = bspKill;
          f.addEventListener("load", finish);
          document.body.appendChild(f);
        } catch (e) {
          finish();
          return;
        }
        // Safety net: never wait longer than 1.5s for the BSP terminate.
        setTimeout(finish, 1500);
      },

      _redirectToLogout(logoutUrl) {
        if (Lib.isValidRedirectURL(logoutUrl)) {
          window.location.href = logoutUrl;
        } else {
          MessageBox.error(
            "Invalid logout URL. Only relative URLs to the same domain are allowed.",
          );
        }
      },

      _evOpenNewTab(args) {
        if (!Lib.isValidRedirectURL(args[1])) {
          MessageBox.error(
            "Invalid URL. Only relative URLs to the same domain are allowed.",
          );
          return;
        }
        const newWindow = window.open(args[1], "_blank");
        // Clear opener to prevent the new tab from accessing window.opener.
        if (newWindow) newWindow.opener = null;
      },

      _evUrlHelper(args) {
        const params = args[2];
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
      },

      _evImageEditorPopupClose() {
        let image;
        try {
          const editor = Fragment.byId("popupId", "imageEditor");
          if (editor) image = editor.getImagePngDataURL();
        } catch (e) {
          Lib.logError(
            "IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed",
            e,
          );
        }
        this.destroyPopup();
        this.eB(["SAVE"], image);
      },

      _evStartTimer(args) {
        // Intentionally a single timer slot: args[0] is always the event
        // name "START_TIMER", so a new START_TIMER replaces the previous
        // one. At most one backend timer is pending at any time - this is
        // by design, not a bug.
        const timerKey = args[0];
        const callbackEvent = args[1];
        const delay = +args[2] || 0;
        if (!z2ui5.timers) z2ui5.timers = {};
        clearTimeout(z2ui5.timers[timerKey]);
        z2ui5.timers[timerKey] = setTimeout(() => {
          delete z2ui5.timers[timerKey];
          this.eB([callbackEvent]);
        }, delay);
      },

      _evSetInputMode(args) {
        try {
          const oElement = z2ui5.oView?.byId(args[1]);
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
      },

      _evSetFocus(args) {
        const oElement = z2ui5.oView?.byId(args[1]);
        if (!oElement) return;

        const applyFocus = () => {
          try {
            const info = oElement.getFocusInfo();
            if (args[2] != null && args[2] !== "")
              info.selectionStart = +args[2];
            if (args[3] != null && args[3] !== "") info.selectionEnd = +args[3];
            oElement.applyFocusInfo(info);
          } catch (e) {
            Lib.logError(`SET_FOCUS: failed for '${args[1]}'`, e);
          }
        };

        // The control may still be missing from the DOM when SET_FOCUS runs
        // together with a fresh view build. Apply now if it is rendered,
        // otherwise once it is.
        Lib.whenRendered(oElement, this, applyFocus);
      },

      _evScrollTo(args) {
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
          const oElement = z2ui5.oView?.byId(args[1]);
          if (!oElement) return;
          const y = +args[2] || 0;
          const x = +args[3] || 0;
          const behavior = args[4] || "auto";
          const smooth = behavior === "smooth";

          let handled = false;
          try {
            const d = oElement.getScrollDelegate?.();
            if (d?.scrollTo) {
              // ScrollEnablement / iScroll delegate: scrollTo(x, y, time)
              d.scrollTo(x, y, smooth ? 300 : 0);
              handled = true;
            }
          } catch (e) {
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
      },

      _evScrollIntoView(args) {
        // args[1] = control id
        // args[2] = behavior - "smooth" (default) | "auto" | "instant"
        // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"
        // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"
        // Modern declarative scroll: bring a control into the viewport,
        // regardless of where the surrounding scroll container currently is.
        try {
          const oElement = z2ui5.oView?.byId(args[1]);
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
      },

      _evSetTitle(args) {
        const title = Lib.toText(args[1]);
        try {
          document.title = title;
        } catch (e) {
          Lib.logError("SET_TITLE: setting document.title failed", e);
        }
      },

      _evSetTitleLaunchpad(args) {
        const title = Lib.toText(args[1]);
        try {
          const shell = z2ui5.oLaunchpad?.ShellUIService;
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
          Lib.logError(
            "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",
            e,
          );
        }
      },

      _evZ2ui5Custom(args) {
        try {
          const fn = z2ui5[args[1]];
          if (fn) fn(args.slice(2));
        } catch (e) {
          Lib.logError(`Z2UI5: '${args[1]}' failed`, e);
        }
      },

      _evWizardSetNextStep(args) {
        try {
          const wiz = z2ui5.oView?.byId(args[1]);
          const step = z2ui5.oView?.byId(args[2]);
          const nextStep = z2ui5.oView?.byId(args[3]);
          if (wiz && step) wiz.discardProgress(step);
          if (step && nextStep) step.setNextStep(nextStep);
        } catch (e) {
          Lib.logError(
            `WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'`,
            e,
          );
        }
      },

      _evPlayAudio(args) {
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
      },

      // ------------------------------------------------------------------
      // eB = "event backend": triggers a backend roundtrip with arguments.
      // The name is part of the protocol - backend-generated view XML binds
      // events to eB/eF - and must not be renamed.
      //
      // args[0] is the event array built by the backend:
      //   [0] event name
      //   [2] "ignore busy" flag - background events (e.g. timers) skip the
      //       busy guard below
      //   [3] "use main view model" flag - events fired from a popup or
      //       popover controller that still target the main app's model
      // ------------------------------------------------------------------
      eB(...args) {
        const [, , ignoreBusy, useMainModel] = args[0];

        if (!navigator.onLine) {
          MessageBox.alert(
            "No internet connection! Please reconnect to the server and try again.",
          );
          return;
        }

        // If a roundtrip is already in flight, briefly show a BusyDialog so
        // the user gets visual feedback instead of a silent click.
        if (z2ui5.isBusy && !ignoreBusy) {
          if (!_busyDialog) _busyDialog = new BusyDialog();
          _busyDialog.open();
          queueMicrotask(() => _busyDialog.close());
          return;
        }

        // A new roundtrip overrides any pending timer - timers that fired
        // already removed themselves before calling eB, so this only cancels
        // timers that are still waiting.
        if (z2ui5.timers) {
          for (const key in z2ui5.timers) {
            clearTimeout(z2ui5.timers[key]);
            delete z2ui5.timers[key];
          }
        }

        z2ui5.isBusy = true;
        BusyIndicator.show();
        z2ui5.oBody = { VIEWNAME: "MAIN" };

        // Decide which view's model holds the data we need to send back. The
        // mapping is: main app controller -> main view, popup controller ->
        // popup view, etc.
        const oModel = this._pickModelForRoundtrip(useMainModel);

        Lib.runCallbacks(z2ui5.onBeforeRoundtrip);

        // If the user edited /XX/ paths, send only the delta to keep the
        // payload small.
        if (oModel && z2ui5.xxChangedPaths?.size > 0) {
          const data = oModel.getData();
          const xx = data?.XX;
          if (xx) {
            z2ui5.oBody.XX = Lib.buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);
          }
        }

        z2ui5.oBody.ID = z2ui5.oResponse?.ID;
        // Object arguments are stringified for transport; the event name in
        // args[0] is left as-is.
        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {
          if (i > 0 && typeof item === "object") return JSON.stringify(item);
          return item;
        });

        Server.roundtrip();
        Lib.runCallbacks(z2ui5.onAfterRoundtrip);
      },

      _pickModelForRoundtrip(useMainModel) {
        // useMainModel forces use of the main view's model even when called
        // from a popup/popover controller.
        if (useMainModel || z2ui5.oController === this) {
          const sView = z2ui5.oResponse?.PARAMS
            ? z2ui5.oResponse.PARAMS.S_VIEW
            : null;
          if (sView?.SWITCH_DEFAULT_MODEL_PATH) {
            return z2ui5.oView?.getModel("http");
          }
          return z2ui5.oView?.getModel();
        }
        if (z2ui5.oControllerPopup === this) {
          return z2ui5.oViewPopup?.getModel();
        }
        if (z2ui5.oControllerPopover === this) {
          return z2ui5.oViewPopover?.getModel();
        }
        if (z2ui5.oControllerNest === this) {
          z2ui5.oBody.VIEWNAME = "NEST";
          return z2ui5.oViewNest?.getModel();
        }
        if (z2ui5.oControllerNest2 === this) {
          z2ui5.oBody.VIEWNAME = "NEST2";
          return z2ui5.oViewNest2?.getModel();
        }
        return undefined;
      },

      // Re-bind a model to one of the views when the response signals an
      // update is required for that particular slot.
      updateModelIfRequired(paramKey, oView) {
        const params = z2ui5.oResponse?.PARAMS;
        const slot = params?.[paramKey];
        if (!slot || !slot.CHECK_UPDATE_MODEL) return;

        const oModel = this._createViewModel();
        applyStoredSizeLimit(Lib.slotKeyByParam(paramKey), oModel);
        if (oView) oView.setModel(oModel);
      },

      async checkSDKcompatibility(err) {
        let gav;
        try {
          const info = await VersionInfo.load();
          gav = info.gav;
        } catch (e) {
          Lib.logError("checkSDKcompatibility: VersionInfo.load failed", e);
          return;
        }
        if (!gav || !gav.includes("com.sap.ui5")) {
          // openui5 doesn't ship some sap.com modules - tell the user which
          // module is missing so they know to switch to SAPUI5.
          const missingModule = err?._modules;
          Server.responseError(
            `openui5 SDK is loaded, module: ${missingModule} is not available in openui5`,
          );
          return;
        }
        Server.responseError(err);
      },

      // Display a toast or message box. Triggered for S_MSG_TOAST and
      // S_MSG_BOX entries in the server response.
      showMessage(msgType, params) {
        if (!params) return;
        const msg = params[msgType];
        if (!msg || msg.TEXT === undefined) return;

        if (msgType === "S_MSG_TOAST") {
          MessageToast.show(msg.TEXT, {
            duration: parseMs(msg.DURATION, 3000),
            width: msg.WIDTH || "15em",
            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,
            autoClose: !!msg.AUTOCLOSE,
            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",
            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),
            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,
          });
          if (msg.CLASS) {
            const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);
            // Pick the newest toast (several can be open at once). The
            // element may not be in the DOM yet right after show(), so
            // retry once on the next animation frame.
            const applyClass = () => {
              const toasts = document.querySelectorAll(".sapMMessageToast");
              const toastEl = toasts[toasts.length - 1];
              if (toastEl) toastEl.classList.add(...classes);
              return !!toastEl;
            };
            if (!applyClass()) requestAnimationFrame(applyClass);
          }
          return;
        }

        if (msgType === "S_MSG_BOX") {
          const oParams = {
            styleClass: msg.STYLECLASS || "",
            title: msg.TITLE || "",
            onClose: msg.ONCLOSE
              ? (sAction) => this.eB([msg.ONCLOSE, sAction])
              : null,
            actions: msg.ACTIONS || "OK",
            emphasizedAction: msg.EMPHASIZEDACTION || "OK",
            initialFocus: msg.INITIALFOCUS || null,
            textDirection: msg.TEXTDIRECTION || "Inherit",
            details: msg.DETAILS ? Lib.sanitizeMessageDetails(msg.DETAILS) : "",
            closeOnNavigation: !!msg.CLOSEONNAVIGATION,
          };
          if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;
          const showFn = MessageBox[msg.TYPE];
          if (showFn) showFn(msg.TEXT, oParams);
        }
      },

      // Replace the main app view with the XML coming from the backend.
      async displayView(xml, viewModel) {
        const oViewModel = this._trackChanges(new JSONModel(viewModel));

        const sView = z2ui5.oResponse?.PARAMS
          ? z2ui5.oResponse.PARAMS.S_VIEW
          : null;
        const switchPath = sView?.SWITCH_DEFAULT_MODEL_PATH;

        // When the app wants OData as the default model, build it here and
        // keep the JSON model as the named "http" model.
        let oModel;
        if (switchPath) {
          oModel = new ODataModel({
            serviceUrl: switchPath,
            annotationURI: sView.SWITCHDEFAULTMODELANNOURI || "",
          });
        } else {
          oModel = oViewModel;
        }
        applyStoredSizeLimit("MAIN", oModel);

        z2ui5.oView = await XMLView.create({
          definition: xml,
          models: oModel,
          controller: z2ui5.oController,
          id: "mainView",
          preprocessors: { xml: { models: { template: oViewModel } } },
        });

        // Guard against the app being destroyed during the await above.
        if (!Lib.isAlive(z2ui5.oApp)) {
          z2ui5.oView.destroy();
          if (switchPath) oModel.destroy();
          z2ui5.oView = null;
          return;
        }

        z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");
        if (switchPath) z2ui5.oView.setModel(oViewModel, "http");
        z2ui5.oApp.removeAllPages();
        z2ui5.oApp.insertPage(z2ui5.oView);
      },
    });
  },
);
