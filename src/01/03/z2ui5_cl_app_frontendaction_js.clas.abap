CLASS z2ui5_cl_app_frontendaction_js DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_frontendaction_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "sap/m/library",` && |\n| &&
             `    "sap/ui/util/Storage",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `  ],` && |\n| &&
             `  (MessageBox, ODataModel, mobileLibrary, Storage, Lib, ViewSlots) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Frontend actions: the handlers behind the controller's eF() entry` && |\n| &&
             `    // point. eF itself stays on View1.controller (its name is part of the` && |\n| &&
             `    // protocol - backend-generated view XML binds events to eB/eF); the` && |\n| &&
             `    // behavior lives here, one function per event. Handlers that need to` && |\n| &&
             `    // reach controller state (destroyPopup, eB, ...) receive the calling` && |\n| &&
             `    // controller as first argument.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Launchpad / NavContainer helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function withCrossAppNavigator(callback) {` && |\n| &&
             `      const nav = z2ui5.oLaunchpad?.CrossAppNavigator;` && |\n| &&
             `      if (!nav) {` && |\n| &&
             `        Lib.logError("CrossAppNav: not running inside Launchpad");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      try {` && |\n| &&
             `        callback(nav);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("CrossAppNav: callback failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function navigateContainer(lookup, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const container = lookup(args[1]);` && |\n| &&
             `        const target = lookup(args[2]);` && |\n| &&
             `        if (!container || !target) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``navigateContainer: control '${!container ? args[1] : args[2]}' not found``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        container.to(target);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("navigateContainer: navigation failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Lookup tables mapping event names to the right view slot.` && |\n| &&
             `    const navContainerLookups = {` && |\n| &&
             `      NAV_CONTAINER_TO: (id) => ViewSlots.byId("MAIN", id),` && |\n| &&
             `      NEST_NAV_CONTAINER_TO: (id) => ViewSlots.byId("NEST", id),` && |\n| &&
             `      NEST2_NAV_CONTAINER_TO: (id) => ViewSlots.byId("NEST2", id),` && |\n| &&
             `      POPUP_NAV_CONTAINER_TO: (id) => ViewSlots.byId("POPUP", id),` && |\n| &&
             `      POPOVER_NAV_CONTAINER_TO: (id) => ViewSlots.byId("POPOVER", id),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Individual event handlers - one per entry in the dispatch table at` && |\n| &&
             `    // the bottom. Uniform signature (oController, args) so the dispatch` && |\n| &&
             `    // stays trivial; handlers that don't need the controller ignore it.` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function evHistoryBack() {` && |\n| &&
             `      history.back();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evClipboardCopy(oController, args) {` && |\n| &&
             `      Lib.copyToClipboard(args[1]);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evClipboardAppState() {` && |\n| &&
             `      // Guard against a missing response so the copied link never carries` && |\n| &&
             `      // the literal "undefined" as its state id.` && |\n| &&
             `      const id = z2ui5.oResponse?.ID || "";` && |\n| &&
             `      // Strip any existing hash (e.g. an active app-state) so the copied` && |\n| &&
             `      // link carries only the fresh state id.` && |\n| &&
             `      const base = window.location.href.split("#")[0];` && |\n| &&
             `      Lib.copyToClipboard(``${base}#/z2ui5-xapp-state=${id}``);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evDownloadB64File(oController, args) {` && |\n| &&
             `      if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `        Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const a = document.createElement("a");` && |\n| &&
             `      a.href = args[1];` && |\n| &&
             `      // Fall back to an empty download attribute when the backend omits the` && |\n| &&
             `      // filename, so the anchor never carries the literal "undefined".` && |\n| &&
             `      a.download = args[2] || "";` && |\n| &&
             `      // Firefox only triggers a programmatic download click when the anchor` && |\n| &&
             `      // is part of the document, so attach it briefly and remove it again.` && |\n| &&
             `      document.body.appendChild(a);` && |\n| &&
             `      a.click();` && |\n| &&
             `      document.body.removeChild(a);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evCrossAppNavToPrevApp() {` && |\n| &&
             `      withCrossAppNavigator((nav) => nav.backToPreviousApp());` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetSizeLimit(oController, args) {` && |\n| &&
             `      // Two call shapes:` && |\n| &&
             `      //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit` && |\n| &&
             `      //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit` && |\n| &&
             `      const hasLimit = args[2] !== undefined && args[2] !== "";` && |\n| &&
             `      const viewKey = hasLimit ? args[2] : args[1];` && |\n| &&
             `      const limit = hasLimit ? Number(args[1]) : NaN;` && |\n| &&
             `      const model = ViewSlots.getView(viewKey)?.getModel();` && |\n| &&
             `` && |\n| &&
             `      const isValidLimit = Number.isFinite(limit) && limit > 0;` && |\n| &&
             `      if (isValidLimit) {` && |\n| &&
             `        z2ui5.viewSizeLimits[viewKey] = limit;` && |\n| &&
             `      } else {` && |\n| &&
             `        delete z2ui5.viewSizeLimits[viewKey];` && |\n| &&
             `      }` && |\n| &&
             `      if (model) {` && |\n| &&
             `        // 100 is the UI5 JSONModel default size limit.` && |\n| &&
             `        model.setSizeLimit(isValidLimit ? limit : 100);` && |\n| &&
             `        model.refresh(true);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetODataModel(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const oModel = new ODataModel({` && |\n| &&
             `          serviceUrl: args[1],` && |\n| &&
             `          annotationURI: args[3] || "",` && |\n| &&
             `        });` && |\n| &&
             `        const oView = ViewSlots.getView("MAIN");` && |\n| &&
             `        if (oView) {` && |\n| &&
             `          oView.setModel(oModel, args[2] || undefined);` && |\n| &&
             `        } else {` && |\n| &&
             `          // No view to attach to - release the model instead of leaking it.` && |\n| &&
             `          oModel.destroy();` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``SET_ODATA_MODEL: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evStoreData(oController, args) {` && |\n| &&
             `      // Guard against a missing payload so the try below logs a` && |\n| &&
             `      // STORE_DATA-specific error instead of a generic dispatch failure.` && |\n| &&
             `      const { TYPE, PREFIX, VALUE, KEY } = args[1] ?? {};` && |\n| &&
             `      try {` && |\n| &&
             `        const storageType = Storage.Type[TYPE] || Storage.Type.session;` && |\n| &&
             `        const oStorage = new Storage(storageType, PREFIX);` && |\n| &&
             `        if (VALUE === "" || VALUE == null) {` && |\n| &&
             `          oStorage.remove(KEY);` && |\n| &&
             `        } else {` && |\n| &&
             `          oStorage.put(KEY, VALUE);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``STORE_DATA: storage operation failed for key '${KEY}'``,` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evCrossAppNavToExt(oController, args) {` && |\n| &&
             `      withCrossAppNavigator((nav) => {` && |\n| &&
             `        const hash =` && |\n| &&
             `          nav.hrefForExternal({ target: args[1], params: args[2] }) || "";` && |\n| &&
             `        if (args[3] === "EXT") {` && |\n| &&
             `          // External redirect: replace the location while keeping the host.` && |\n| &&
             `          const base = window.location.href.split("#")[0];` && |\n| &&
             `          _URLHelper.redirect(``${base}${hash}``, true);` && |\n| &&
             `        } else {` && |\n| &&
             `          nav.toExternal({ target: { shellHash: hash } });` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evLocationReload(oController, args) {` && |\n| &&
             `      if (Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `        window.location.href = args[1];` && |\n| &&
             `      } else {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid redirect URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // SYSTEM_LOGOUT: prefer the launchpad logout when running inside the` && |\n| &&
             `    // FLP; otherwise terminate a possible stateful BSP session first and` && |\n| &&
             `    // then navigate to the logout URL.` && |\n| &&
             `    function evSystemLogout(oController, args) {` && |\n| &&
             `      const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";` && |\n| &&
             `      try {` && |\n| &&
             `        const container = z2ui5.oLaunchpad?.Container;` && |\n| &&
             `        // No explicit logout URL was passed (args is just the event name):` && |\n| &&
             `        // inside the launchpad, prefer its own logout over the BSP/ICF` && |\n| &&
             `        // redirect below.` && |\n| &&
             `        if (container?.logout && args.length <= 1) {` && |\n| &&
             `          container.logout();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);` && |\n| &&
             `      }` && |\n| &&
             `      logoutViaBspTerminate(logoutUrl);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // When abap2UI5 is hosted as a BSP application,` && |\n| &&
             `    // /sap/public/bc/icf/logoff alone does not terminate the stateful` && |\n| &&
             `    // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).` && |\n| &&
             `    // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP` && |\n| &&
             `    // runtime calls server->session->terminate( ), then go to the ICF` && |\n| &&
             `    // logoff to also drop the SSO2 ticket. Outside a BSP path this goes` && |\n| &&
             `    // straight to the logout URL.` && |\n| &&
             `    function logoutViaBspTerminate(logoutUrl) {` && |\n| &&
             `      const path = window.location.pathname;` && |\n| &&
             `      if (!path.startsWith("/sap/bc/bsp/")) {` && |\n| &&
             `        redirectToLogout(logoutUrl);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      const separator = path.includes("?") ? "&" : "?";` && |\n| &&
             `      const bspKill = ``${path}${separator}sap-sessioncmd=logoff``;` && |\n| &&
             `      let done = false;` && |\n| &&
             `      const finish = () => {` && |\n| &&
             `        if (done) return;` && |\n| &&
             `        done = true;` && |\n| &&
             `        redirectToLogout(logoutUrl);` && |\n| &&
             `      };` && |\n| &&
             `      try {` && |\n| &&
             `        const frame = document.createElement("iframe");` && |\n| &&
             `        frame.style.display = "none";` && |\n| &&
             `        frame.src = bspKill;` && |\n| &&
             `        frame.addEventListener("load", finish);` && |\n| &&
             `        document.body.appendChild(frame);` && |\n| &&
             `      } catch {` && |\n| &&
             `        finish();` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      // Safety net: never wait longer than 1.5s for the BSP terminate.` && |\n| &&
             `      setTimeout(finish, 1500);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function redirectToLogout(logoutUrl) {` && |\n| &&
             `      if (Lib.isValidRedirectURL(logoutUrl)) {` && |\n| &&
             `        window.location.href = logoutUrl;` && |\n| &&
             `      } else {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid logout URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evOpenNewTab(oController, args) {` && |\n| &&
             `      if (!Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `        MessageBox.error(` && |\n| &&
             `          "Invalid URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `        );` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const newWindow = window.open(args[1], "_blank");` && |\n| &&
             `      // Clear opener to prevent the new tab from accessing window.opener.` && |\n| &&
             `      if (newWindow) newWindow.opener = null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evUrlHelper(oController, args) {` && |\n| &&
             `      const params = args[2] ?? {};` && |\n| &&
             `      const actions = {` && |\n| &&
             `        REDIRECT: () => {` && |\n| &&
             `          if (!Lib.isSafeRedirectProtocol(params.URL)) {` && |\n| &&
             `            MessageBox.error(` && |\n| &&
             `              "Invalid redirect URL. Only http/https protocols are allowed.",` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          _URLHelper.redirect(params.URL, params.NEW_WINDOW);` && |\n| &&
             `        },` && |\n| &&
             `        TRIGGER_EMAIL: () =>` && |\n| &&
             `          _URLHelper.triggerEmail(` && |\n| &&
             `            params.EMAIL,` && |\n| &&
             `            params.SUBJECT,` && |\n| &&
             `            params.BODY,` && |\n| &&
             `            params.CC,` && |\n| &&
             `            params.BCC,` && |\n| &&
             `            params.NEW_WINDOW,` && |\n| &&
             `          ),` && |\n| &&
             `        TRIGGER_SMS: () => _URLHelper.triggerSms(params),` && |\n| &&
             `        TRIGGER_TEL: () => _URLHelper.triggerTel(params),` && |\n| &&
             `      };` && |\n| &&
             `      try {` && |\n| &&
             `        const fn = actions[args[1]];` && |\n| &&
             `        if (fn) fn();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``URLHELPER: '${args[1]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evImageEditorPopupClose(oController) {` && |\n| &&
             `      let image;` && |\n| &&
             `      try {` && |\n| &&
             `        const editor = ViewSlots.byId("POPUP", "imageEditor");` && |\n| &&
             `        if (editor) image = editor.getImagePngDataURL();` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed", e);` && |\n| &&
             `      }` && |\n| &&
             `      ViewSlots.destroy("POPUP");` && |\n| &&
             `      oController.eB(["SAVE"], image);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evStartTimer(oController, args) {` && |\n| &&
             `      // Intentionally a single timer slot: args[0] is always the event` && |\n| &&
             `      // name "START_TIMER", so a new START_TIMER replaces the previous` && |\n| &&
             `      // one. At most one backend timer is pending at any time - this is` && |\n| &&
             `      // by design, not a bug.` && |\n| &&
             `      const timerKey = args[0];` && |\n| &&
             `      const callbackEvent = args[1];` && |\n| &&
             `      const delay = Number(args[2]) || 0;` && |\n| &&
             `      clearTimeout(z2ui5.timers[timerKey]);` && |\n| &&
             `      z2ui5.timers[timerKey] = setTimeout(() => {` && |\n| &&
             `        delete z2ui5.timers[timerKey];` && |\n| &&
             `        oController.eB([callbackEvent]);` && |\n| &&
             `      }, delay);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetInputMode(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const dom = oElement.getDomRef();` && |\n| &&
             `        if (!dom) return;` && |\n| &&
             `        const input = dom.matches("input, textarea")` && |\n| &&
             `          ? dom` && |\n| &&
             `          : dom.querySelector("input, textarea");` && |\n| &&
             `        if (!input) return;` && |\n| &&
             `        input.setAttribute("inputmode", args[2] || "text");` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(` && |\n| &&
             `          ``KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'``,` && |\n| &&
             `          e,` && |\n| &&
             `        );` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetFocus(oController, args) {` && |\n| &&
             `      const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `      if (!oElement) return;` && |\n| &&
             `` && |\n| &&
             `      const applyFocus = () => {` && |\n| &&
             `        try {` && |\n| &&
             `          const info = oElement.getFocusInfo();` && |\n| &&
             `          if (args[2] != null && args[2] !== "") {` && |\n| &&
             `            info.selectionStart = Number(args[2]);` && |\n| &&
             `          }` && |\n| &&
             `          if (args[3] != null && args[3] !== "") {` && |\n| &&
             `            info.selectionEnd = Number(args[3]);` && |\n| &&
             `          }` && |\n| &&
             `          oElement.applyFocusInfo(info);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``SET_FOCUS: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      };` && |\n| &&
             `` && |\n| &&
             `      // The control may still be missing from the DOM when SET_FOCUS runs` && |\n| &&
             `      // together with a fresh view build. Apply now if it is rendered,` && |\n| &&
             `      // otherwise once it is.` && |\n| &&
             `      Lib.whenRendered(oElement, oController, applyFocus);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evScrollTo(oController, args) {` && |\n| &&
             `      // args[1] = control id` && |\n| &&
             `      // args[2] = scrollTop  (Y, vertical, px)` && |\n| &&
             `      // args[3] = scrollLeft (X, horizontal, px) - optional, default 0` && |\n| &&
             `      // args[4] = behavior - "auto" (default) | "smooth" | "instant"` && |\n| &&
             `      // Strategy: prefer the control's scroll delegate (sap.m.Page,` && |\n| &&
             `      // ScrollContainer etc. expose ScrollEnablement). The delegate knows` && |\n| &&
             `      // the real scroll container, which often is NOT the control's root` && |\n| &&
             `      // DOM element - so native Element.scrollTo on getDomRef() silently` && |\n| &&
             `      // does nothing on a Page. ScrollEnablement.scrollTo(x, y, time)` && |\n| &&
             `      // animates when time > 0, so "smooth" maps to a 300ms animation.` && |\n| &&
             `      // Native Element.scrollTo is only used as a fallback for controls` && |\n| &&
             `      // without a delegate.` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const y = Number(args[2]) || 0;` && |\n| &&
             `        const x = Number(args[3]) || 0;` && |\n| &&
             `        const behavior = args[4] || "auto";` && |\n| &&
             `        const smooth = behavior === "smooth";` && |\n| &&
             `` && |\n| &&
             `        let handled = false;` && |\n| &&
             `        try {` && |\n| &&
             `          const delegate = oElement.getScrollDelegate?.();` && |\n| &&
             `          if (delegate?.scrollTo) {` && |\n|.
    result = result &&
             `            // ScrollEnablement / iScroll delegate: scrollTo(x, y, time)` && |\n| &&
             `            delegate.scrollTo(x, y, smooth ? 300 : 0);` && |\n| &&
             `            handled = true;` && |\n| &&
             `          }` && |\n| &&
             `        } catch {` && |\n| &&
             `          // fall through` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (!handled) {` && |\n| &&
             `          const dom =` && |\n| &&
             `            document.getElementById(``${oElement.getId()}-inner``) ||` && |\n| &&
             `            oElement.getDomRef();` && |\n| &&
             `          if (dom?.scrollTo) {` && |\n| &&
             `            dom.scrollTo({ top: y, left: x, behavior });` && |\n| &&
             `            handled = true;` && |\n| &&
             `          } else if (dom) {` && |\n| &&
             `            dom.scrollTop = y;` && |\n| &&
             `            dom.scrollLeft = x;` && |\n| &&
             `            handled = true;` && |\n| &&
             `          } else if (oElement.scrollTo) {` && |\n| &&
             `            // sap.m.Page.scrollTo(y, time) - vertical only` && |\n| &&
             `            oElement.scrollTo(y, smooth ? 300 : 0);` && |\n| &&
             `            handled = true;` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``SCROLL_TO: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evScrollIntoView(oController, args) {` && |\n| &&
             `      // args[1] = control id` && |\n| &&
             `      // args[2] = behavior - "smooth" (default) | "auto" | "instant"` && |\n| &&
             `      // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"` && |\n| &&
             `      // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"` && |\n| &&
             `      // Modern declarative scroll: bring a control into the viewport,` && |\n| &&
             `      // regardless of where the surrounding scroll container currently is.` && |\n| &&
             `      try {` && |\n| &&
             `        const oElement = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `        const dom = oElement.getDomRef();` && |\n| &&
             `        if (!dom || !dom.scrollIntoView) return;` && |\n| &&
             `        dom.scrollIntoView({` && |\n| &&
             `          behavior: args[2] || "smooth",` && |\n| &&
             `          block: args[3] || "start",` && |\n| &&
             `          inline: args[4] || "nearest",` && |\n| &&
             `        });` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``SCROLL_INTO_VIEW: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetTitle(oController, args) {` && |\n| &&
             `      const title = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        document.title = title;` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_TITLE: setting document.title failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evSetTitleLaunchpad(oController, args) {` && |\n| &&
             `      const title = Lib.toText(args[1]);` && |\n| &&
             `      try {` && |\n| &&
             `        const shell = z2ui5.oLaunchpad?.ShellUIService;` && |\n| &&
             `        if (shell?.setTitle) {` && |\n| &&
             `          const result = shell.setTitle(title);` && |\n| &&
             `          if (result?.catch) {` && |\n| &&
             `            result.catch((e) =>` && |\n| &&
             `              Lib.logError(` && |\n| &&
             `                "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",` && |\n| &&
             `                e,` && |\n| &&
             `              ),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evZ2ui5Custom(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const fn = z2ui5[args[1]];` && |\n| &&
             `        if (typeof fn === "function") {` && |\n| &&
             `          fn(args.slice(2));` && |\n| &&
             `        } else {` && |\n| &&
             `          // Missing or not callable (e.g. the app never registered it via` && |\n| &&
             `          // the js_loader popup) - log it instead of failing silently or` && |\n| &&
             `          // with a generic TypeError.` && |\n| &&
             `          Lib.logError(``Z2UI5: 'z2ui5.${args[1]}' is not a function``);` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``Z2UI5: '${args[1]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evWizardSetNextStep(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const wiz = ViewSlots.byId("MAIN", args[1]);` && |\n| &&
             `        const step = ViewSlots.byId("MAIN", args[2]);` && |\n| &&
             `        const nextStep = ViewSlots.byId("MAIN", args[3]);` && |\n| &&
             `        if (wiz && step) wiz.discardProgress(step);` && |\n| &&
             `        if (step && nextStep) step.setNextStep(nextStep);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function evPlayAudio(oController, args) {` && |\n| &&
             `      try {` && |\n| &&
             `        const playing = new Audio(args[1]).play();` && |\n| &&
             `        // play() returns a Promise; a rejection (e.g. blocked by the` && |\n| &&
             `        // browser's autoplay policy) is not caught by the surrounding` && |\n| &&
             `        // try/catch and would surface as an unhandled rejection.` && |\n| &&
             `        if (playing?.catch) {` && |\n| &&
             `          playing.catch((e) =>` && |\n| &&
             `            Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e),` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Frontend event dispatch: maps the eF event name to its handler.` && |\n| &&
             `    // NavContainer events are dispatched separately via` && |\n| &&
             `    // navContainerLookups above.` && |\n| &&
             `    const handlers = {` && |\n| &&
             `      SET_SIZE_LIMIT: evSetSizeLimit,` && |\n| &&
             `      HISTORY_BACK: evHistoryBack,` && |\n| &&
             `      CLIPBOARD_COPY: evClipboardCopy,` && |\n| &&
             `      CLIPBOARD_APP_STATE: evClipboardAppState,` && |\n| &&
             `      SET_ODATA_MODEL: evSetODataModel,` && |\n| &&
             `      STORE_DATA: evStoreData,` && |\n| &&
             `      DOWNLOAD_B64_FILE: evDownloadB64File,` && |\n| &&
             `      CROSS_APP_NAV_TO_PREV_APP: evCrossAppNavToPrevApp,` && |\n| &&
             `      CROSS_APP_NAV_TO_EXT: evCrossAppNavToExt,` && |\n| &&
             `      LOCATION_RELOAD: evLocationReload,` && |\n| &&
             `      SYSTEM_LOGOUT: evSystemLogout,` && |\n| &&
             `      OPEN_NEW_TAB: evOpenNewTab,` && |\n| &&
             `      POPUP_CLOSE: () => ViewSlots.destroy("POPUP"),` && |\n| &&
             `      POPOVER_CLOSE: () => ViewSlots.destroy("POPOVER"),` && |\n| &&
             `      URLHELPER: evUrlHelper,` && |\n| &&
             `      IMAGE_EDITOR_POPUP_CLOSE: evImageEditorPopupClose,` && |\n| &&
             `      SET_TITLE: evSetTitle,` && |\n| &&
             `      SET_TITLE_LAUNCHPAD: evSetTitleLaunchpad,` && |\n| &&
             `      SET_FOCUS: evSetFocus,` && |\n| &&
             `      SCROLL_TO: evScrollTo,` && |\n| &&
             `      SCROLL_INTO_VIEW: evScrollIntoView,` && |\n| &&
             `      START_TIMER: evStartTimer,` && |\n| &&
             `      KEYBOARD_SET_MODE: evSetInputMode,` && |\n| &&
             `      Z2UI5: evZ2ui5Custom,` && |\n| &&
             `      WIZARD_SET_NEXT_STEP: evWizardSetNextStep,` && |\n| &&
             `      PLAY_AUDIO: evPlayAudio,` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Entry point called by View1.controller's eF().` && |\n| &&
             `    function execute(oController, args) {` && |\n| &&
             `      Lib.runCallbacks(z2ui5.onBeforeEventFrontend, args);` && |\n| &&
             `` && |\n| &&
             `      try {` && |\n| &&
             `        // NavContainer navigation is dispatched via lookup table.` && |\n| &&
             `        const navLookup = navContainerLookups[args[0]];` && |\n| &&
             `        if (navLookup) {` && |\n| &&
             `          navigateContainer(navLookup, args);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        const handler = handlers[args[0]];` && |\n| &&
             `        if (handler) handler(oController, args);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        // Backstop: individual handlers already guard themselves, but a` && |\n| &&
             `        // malformed payload must never let an error escape into the caller.` && |\n| &&
             `        Lib.logError(``FrontendAction: handler '${args[0]}' failed``, e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return { execute };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
