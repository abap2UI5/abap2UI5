CLASS z2ui5_cl_app_view1_js DEFINITION
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


CLASS z2ui5_cl_app_view1_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "sap/ui/core/mvc/XMLView",` && |\n| &&
             `    "sap/ui/model/json/JSONModel",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/m/MessageToast",` && |\n| &&
             `    "sap/ui/core/Fragment",` && |\n| &&
             `    "sap/m/BusyDialog",` && |\n| &&
             `    "sap/ui/VersionInfo",` && |\n| &&
             `    "z2ui5/cc/Server",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "sap/m/library",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `    "sap/ui/util/Storage",` && |\n| &&
             `    "sap/ui/core/Element",` && |\n| &&
             `    "z2ui5/cc/Lib",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    Controller,` && |\n| &&
             `    XMLView,` && |\n| &&
             `    JSONModel,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    MessageToast,` && |\n| &&
             `    Fragment,` && |\n| &&
             `    BusyDialog,` && |\n| &&
             `    VersionInfo,` && |\n| &&
             `    Server,` && |\n| &&
             `    ODataModel,` && |\n| &&
             `    mobileLibrary,` && |\n| &&
             `    HashChanger,` && |\n| &&
             `    Storage,` && |\n| &&
             `    Element,` && |\n| &&
             `    Lib,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Small utility helpers (module-private)` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Run every callback in ``arr``, swallowing individual failures so one bad` && |\n| &&
             `    // callback cannot break the whole event sequence.` && |\n| &&
             `    function runCallbacks(arr, ...args) {` && |\n| &&
             `      if (!arr) return;` && |\n| &&
             `      for (const fn of arr) {` && |\n| &&
             `        if (!fn) continue;` && |\n| &&
             `        try {` && |\n| &&
             `          fn(...args);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("runCallbacks: callback failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Parse a value as integer milliseconds, falling back to ``def`` when the` && |\n| &&
             `    // input is empty / undefined.` && |\n| &&
             `    function parseMs(val, def) {` && |\n| &&
             `      return val ? +val : def;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Helpers reused across calls; kept as module-level singletons.` && |\n| &&
             `    const _hashChanger = HashChanger.getInstance();` && |\n| &&
             `    const _URLHelper = mobileLibrary.URLHelper;` && |\n| &&
             `` && |\n| &&
             `    // Single reusable BusyDialog flashed when the user clicks while a` && |\n| &&
             `    // roundtrip is already in flight (created lazily, kept for reuse).` && |\n| &&
             `    let _busyDialog = null;` && |\n| &&
             `` && |\n| &&
             `    function copyToClipboard(textToCopy) {` && |\n| &&
             `      if (navigator.clipboard && navigator.clipboard.writeText) {` && |\n| &&
             `        navigator.clipboard.writeText(textToCopy).catch((err) => {` && |\n| &&
             `          Lib.logError("Clipboard: writeText failed, falling back", err);` && |\n| &&
             `          copyToClipboardFallback(textToCopy);` && |\n| &&
             `        });` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      copyToClipboardFallback(textToCopy);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function copyToClipboardFallback(textToCopy) {` && |\n| &&
             `      const textarea = document.createElement("textarea");` && |\n| &&
             `      textarea.value = textToCopy;` && |\n| &&
             `      textarea.setAttribute("readonly", "");` && |\n| &&
             `      textarea.style.position = "fixed";` && |\n| &&
             `      textarea.style.top = "-1000px";` && |\n| &&
             `      textarea.style.opacity = "0";` && |\n| &&
             `      document.body.appendChild(textarea);` && |\n| &&
             `      textarea.select();` && |\n| &&
             `      try {` && |\n| &&
             `        if (!document.execCommand("copy")) {` && |\n| &&
             `          Lib.logError("Clipboard: execCommand('copy') returned false");` && |\n| &&
             `        }` && |\n| &&
             `      } catch (err) {` && |\n| &&
             `        Lib.logError("Clipboard: execCommand('copy') threw", err);` && |\n| &&
             `      } finally {` && |\n| &&
             `        document.body.removeChild(textarea);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Launchpad / NavContainer helpers` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function withCrossAppNavigator(callback) {` && |\n| &&
             `      const nav = z2ui5.oLaunchpad && z2ui5.oLaunchpad.CrossAppNavigator;` && |\n| &&
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
             `        if (container) container.to(lookup(args[2]));` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("navigateContainer: navigation failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Lookup tables mapping event names / param keys to the right view.` && |\n| &&
             `    const navContainerLookups = {` && |\n| &&
             `      NAV_CONTAINER_TO: (id) => z2ui5.oView && z2ui5.oView.byId(id),` && |\n| &&
             `      NEST_NAV_CONTAINER_TO: (id) =>` && |\n| &&
             `        z2ui5.oViewNest && z2ui5.oViewNest.byId(id),` && |\n| &&
             `      NEST2_NAV_CONTAINER_TO: (id) =>` && |\n| &&
             `        z2ui5.oViewNest2 && z2ui5.oViewNest2.byId(id),` && |\n| &&
             `      POPUP_NAV_CONTAINER_TO: (id) => Fragment.byId("popupId", id),` && |\n| &&
             `      POPOVER_NAV_CONTAINER_TO: (id) => Fragment.byId("popoverId", id),` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    // Frontend event dispatch: maps the eF event name to the controller` && |\n| &&
             `    // method handling it. NavContainer events are dispatched separately` && |\n| &&
             `    // via navContainerLookups above.` && |\n| &&
             `    const eventFrontendHandlers = {` && |\n| &&
             `      SET_SIZE_LIMIT: "_evSetSizeLimit",` && |\n| &&
             `      HISTORY_BACK: "_evHistoryBack",` && |\n| &&
             `      CLIPBOARD_COPY: "_evClipboardCopy",` && |\n| &&
             `      CLIPBOARD_APP_STATE: "_evClipboardAppState",` && |\n| &&
             `      SET_ODATA_MODEL: "_evSetODataModel",` && |\n| &&
             `      STORE_DATA: "_evStoreData",` && |\n| &&
             `      DOWNLOAD_B64_FILE: "_evDownloadB64File",` && |\n| &&
             `      CROSS_APP_NAV_TO_PREV_APP: "_evCrossAppNavToPrevApp",` && |\n| &&
             `      CROSS_APP_NAV_TO_EXT: "_evCrossAppNavToExt",` && |\n| &&
             `      LOCATION_RELOAD: "_evLocationReload",` && |\n| &&
             `      SYSTEM_LOGOUT: "_evSystemLogout",` && |\n| &&
             `      OPEN_NEW_TAB: "_evOpenNewTab",` && |\n| &&
             `      POPUP_CLOSE: "destroyPopup",` && |\n| &&
             `      POPOVER_CLOSE: "destroyPopover",` && |\n| &&
             `      URLHELPER: "_evUrlHelper",` && |\n| &&
             `      IMAGE_EDITOR_POPUP_CLOSE: "_evImageEditorPopupClose",` && |\n| &&
             `      SET_TITLE: "_evSetTitle",` && |\n| &&
             `      SET_TITLE_LAUNCHPAD: "_evSetTitleLaunchpad",` && |\n| &&
             `      SET_FOCUS: "_evSetFocus",` && |\n| &&
             `      SCROLL_TO: "_evScrollTo",` && |\n| &&
             `      SCROLL_INTO_VIEW: "_evScrollIntoView",` && |\n| &&
             `      START_TIMER: "_evStartTimer",` && |\n| &&
             `      KEYBOARD_SET_MODE: "_evSetInputMode",` && |\n| &&
             `      Z2UI5: "_evZ2ui5Custom",` && |\n| &&
             `      WIZARD_SET_NEXT_STEP: "_evWizardSetNextStep",` && |\n| &&
             `      PLAY_AUDIO: "_evPlayAudio",` && |\n| &&
             `    };` && |\n| &&
             `` && |\n| &&
             `    function applyStoredSizeLimit(viewKey, oModel) {` && |\n| &&
             `      if (!oModel || !z2ui5.viewSizeLimits) return;` && |\n| &&
             `      const limit = z2ui5.viewSizeLimits[viewKey];` && |\n| &&
             `      if (limit !== undefined) oModel.setSizeLimit(limit);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Controller.extend("z2ui5.controller.View1", {` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Model change tracking - remembers which /XX/ paths the user edited` && |\n| &&
             `      // so the next roundtrip only ships the delta.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      _trackChanges(oModel) {` && |\n| &&
             `        oModel.attachPropertyChange((e) => {` && |\n| &&
             `          const params = e.getParameters();` && |\n| &&
             `          const raw = params.path;` && |\n| &&
             `          const ctx = params.context;` && |\n| &&
             `          if (!raw) return;` && |\n| &&
             `          // Resolve relative paths against the binding context.` && |\n| &&
             `          let p;` && |\n| &&
             `          if (ctx && !raw.startsWith("/")) {` && |\n| &&
             `            p = ``${ctx.getPath()}/${raw}``;` && |\n| &&
             `          } else {` && |\n| &&
             `            p = raw;` && |\n| &&
             `          }` && |\n| &&
             `          if (p.startsWith("/XX/")) {` && |\n| &&
             `            if (!z2ui5.xxChangedPaths) z2ui5.xxChangedPaths = new Set();` && |\n| &&
             `            z2ui5.xxChangedPaths.add(p);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        return oModel;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onInit() {` && |\n| &&
             `        z2ui5.oRouter.attachRouteMatched(() => {` && |\n| &&
             `          Server.roundtrip();` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (z2ui5.oResponse && !z2ui5.oResponse._processed) {` && |\n| &&
             `          this._processAfterRendering();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Runs once after each roundtrip's view has been rendered. Handles` && |\n| &&
             `      // popups, nested views, popovers and browser-history updates.` && |\n| &&
             `      async _processAfterRendering() {` && |\n| &&
             `        try {` && |\n| &&
             `          const oResponse = z2ui5.oResponse;` && |\n| &&
             `          if (oResponse._processed) return;` && |\n| &&
             `          oResponse._processed = true;` && |\n| &&
             `` && |\n| &&
             `          const PARAMS = oResponse.PARAMS;` && |\n| &&
             `          const ID = oResponse.ID;` && |\n| &&
             `          if (!PARAMS) return;` && |\n| &&
             `` && |\n| &&
             `          const S_POPUP = PARAMS.S_POPUP;` && |\n| &&
             `          const S_VIEW_NEST = PARAMS.S_VIEW_NEST;` && |\n| &&
             `          const S_VIEW_NEST2 = PARAMS.S_VIEW_NEST2;` && |\n| &&
             `          const S_POPOVER = PARAMS.S_POPOVER;` && |\n| &&
             `          const SET_APP_STATE_ACTIVE = PARAMS.SET_APP_STATE_ACTIVE;` && |\n| &&
             `          const SET_PUSH_STATE = PARAMS.SET_PUSH_STATE;` && |\n| &&
             `          const SET_NAV_BACK = PARAMS.SET_NAV_BACK;` && |\n| &&
             `` && |\n| &&
             `          if (S_POPUP && S_POPUP.CHECK_DESTROY) this.destroyPopup();` && |\n| &&
             `          if (S_POPOVER && S_POPOVER.CHECK_DESTROY) this.destroyPopover();` && |\n| &&
             `` && |\n| &&
             `          if (S_POPUP && S_POPUP.XML) {` && |\n| &&
             `            this.destroyPopup();` && |\n| &&
             `            await this.displayFragment(S_POPUP.XML, "oViewPopup");` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!z2ui5.checkNestAfter && S_VIEW_NEST && S_VIEW_NEST.XML) {` && |\n| &&
             `            this.destroyNestView();` && |\n| &&
             `            await this.displayNestedView(` && |\n| &&
             `              S_VIEW_NEST.XML,` && |\n| &&
             `              "oViewNest",` && |\n| &&
             `              "S_VIEW_NEST",` && |\n| &&
             `              z2ui5.oControllerNest,` && |\n| &&
             `            );` && |\n| &&
             `            z2ui5.checkNestAfter = true;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2 && S_VIEW_NEST2.XML) {` && |\n| &&
             `            this.destroyNestView2();` && |\n| &&
             `            await this.displayNestedView(` && |\n| &&
             `              S_VIEW_NEST2.XML,` && |\n| &&
             `              "oViewNest2",` && |\n| &&
             `              "S_VIEW_NEST2",` && |\n| &&
             `              z2ui5.oControllerNest2,` && |\n| &&
             `            );` && |\n| &&
             `            z2ui5.checkNestAfter2 = true;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (S_POPOVER && S_POPOVER.XML) {` && |\n| &&
             `            this.destroyPopover();` && |\n| &&
             `            await this.displayPopover(` && |\n| &&
             `              S_POPOVER.XML,` && |\n| &&
             `              "oViewPopover",` && |\n| &&
             `              S_POPOVER.OPEN_BY_ID,` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Currently disabled: storing the rendered view + model in` && |\n| &&
             `          // history.state so a popstate could restore the view without a` && |\n| &&
             `          // backend hit. Cloning the full view XML and model data on every` && |\n| &&
             `          // roundtrip is expensive for large views and the restore is not` && |\n| &&
             `          // needed right now. Re-enable together with the popstate listener` && |\n| &&
             `          // in Component.js (_installPopstateListener).` && |\n| &&
             `          // const oView = z2ui5.oView;` && |\n| &&
             `          // let oState = {};` && |\n| &&
             `          // if (oView) {` && |\n| &&
             `          //   const model = oView.getModel();` && |\n| &&
             `          //   oState = {` && |\n| &&
             `          //     view: oView.mProperties.viewContent,` && |\n| &&
             `          //     model: model ? model.getData() : undefined,` && |\n| &&
             `          //     response: z2ui5.oResponse,` && |\n| &&
             `          //   };` && |\n| &&
             `          // }` && |\n| &&
             `` && |\n| &&
             `          try {` && |\n| &&
             `            if (SET_PUSH_STATE) {` && |\n| &&
             `              const hash = _hashChanger.getHash();` && |\n| &&
             `              const newUrl = ``${window.location.pathname}${window.location.search}#${hash}${SET_PUSH_STATE}``;` && |\n| &&
             `              history.pushState(null, "", newUrl);` && |\n| &&
             `            }` && |\n| &&
             `            // Disabled together with the state storing above - without a` && |\n| &&
             `            // state object this call was a pure no-op:` && |\n| &&
             `            // else {` && |\n| &&
             `            //   history.replaceState(oState, "", window.location.href);` && |\n| &&
             `            // }` && |\n| &&
             `            const newHash = SET_APP_STATE_ACTIVE` && |\n| &&
             `              ? ``z2ui5-xapp-state=${ID || ""}``` && |\n| &&
             `              : "";` && |\n| &&
             `            _hashChanger.replaceHash(newHash);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            Lib.logError("_processAfterRendering: history update failed", e);` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (SET_NAV_BACK) history.back();` && |\n| &&
             `` && |\n| &&
             `          runCallbacks(z2ui5.onAfterRendering);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("_processAfterRendering: unexpected error", e);` && |\n| &&
             `          Server.responseError(e, "Unexpected Error Occurred - App Terminated");` && |\n| &&
             `        } finally {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          z2ui5.isBusy = false;` && |\n| &&
             `          // Now that the view is rendered (and any busy indicator is gone),` && |\n| &&
             `          // run the follow-up JS snippets the backend asked for. Doing it here` && |\n| &&
             `          // - rather than as an early microtask - guarantees render-dependent` && |\n| &&
             `          // actions like SET_FOCUS find their target control in the DOM.` && |\n| &&
             `          this._runPendingCustomJs();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Execute the follow-up JS snippets stashed by Server.responseSuccess.` && |\n| &&
             `      // Runs once per roundtrip, after the view has rendered.` && |\n| &&
             `      _runPendingCustomJs() {` && |\n| &&
             `        const customJs = z2ui5.pendingCustomJs;` && |\n| &&
             `        z2ui5.pendingCustomJs = null;` && |\n| &&
             `        if (!customJs) return;` && |\n| &&
             `        if (Lib.isDestroyed(this)) return;` && |\n| &&
             `        for (const item of customJs) {` && |\n| &&
             `          Server._runCustomJs(item, this);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _createViewModel() {` && |\n| &&
             `        const data = z2ui5.oResponse && z2ui5.oResponse.OVIEWMODEL;` && |\n| &&
             `        return this._trackChanges(new JSONModel(data));` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Display: popups, popovers, nested views, main view` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      async displayFragment(xml, viewProp) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit("POPUP", oModel);` && |\n| &&
             `        const oFragment = await Fragment.load({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: z2ui5.oControllerPopup,` && |\n| &&
             `          id: "popupId",` && |\n| &&
             `        });` && |\n| &&
             `        // The app might have been torn down while the fragment loaded.` && |\n| &&
             `        if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        oFragment.Fragment = Fragment;` && |\n| &&
             `        z2ui5[viewProp] = oFragment;` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayPopover(xml, viewProp, openById) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oModel = this._createViewModel();` && |\n| &&
             `          applyStoredSizeLimit("POPOVER", oModel);` && |\n| &&
             `          const oFragment = await Fragment.load({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller: z2ui5.oControllerPopover,` && |\n| &&
             `            id: "popoverId",` && |\n| &&
             `          });` && |\n| &&
             `          if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          oFragment.setModel(oModel);` && |\n| &&
             `          oFragment.Fragment = Fragment;` && |\n| &&
             `` && |\n| &&
             `          // Find the control to attach the popover to. We search the main` && |\n| &&
             `          // view first, then any open popup / nested views, then the global` && |\n| &&
             `          // UI5 control registry as a last resort.` && |\n| &&
             `          let oControl = z2ui5.oView && z2ui5.oView.byId(openById);` && |\n| &&
             `          if (!oControl && z2ui5.oViewPopup && z2ui5.oViewPopup.Fragment) {` && |\n| &&
             `            oControl = z2ui5.oViewPopup.Fragment.byId("popupId", openById);` && |\n| &&
             `          }` && |\n| &&
             `          if (!oControl && z2ui5.oViewNest) {` && |\n| &&
             `            oControl = z2ui5.oViewNest.byId(openById);` && |\n| &&
             `          }` && |\n| &&
             `          if (!oControl && z2ui5.oViewNest2) {` && |\n| &&
             `            oControl = z2ui5.oViewNest2.byId(openById);` && |\n| &&
             `          }` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            if (Element.getElementById) {` && |\n| &&
             `              oControl = Element.getElementById(openById);` && |\n| &&
             `            } else {` && |\n| &&
             |\n|.
    result = result &&
             `              /* ui5lint-disable no-globals, no-deprecated-api --` && |\n| &&
             `                 deliberate fallback for UI5 releases that do not provide` && |\n| &&
             `                 Element.getElementById yet (added in 1.119); the modern` && |\n| &&
             `                 API is used in the branch above. */` && |\n| &&
             `              if (sap.ui.getCore) {` && |\n| &&
             `                const core = sap.ui.getCore();` && |\n| &&
             `                if (core && core.byId) oControl = core.byId(openById);` && |\n| &&
             `              }` && |\n| &&
             `              /* ui5lint-enable no-globals, no-deprecated-api */` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            Lib.logError(` && |\n| &&
             `              ``displayPopover: openBy control '${openById}' not found``,` && |\n| &&
             `            );` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          z2ui5[viewProp] = oFragment;` && |\n| &&
             `          oFragment.openBy(oControl);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("displayPopover: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayNestedView(xml, viewProp, viewNestId, controller) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(Lib.slotKeyByParam(viewNestId), oModel);` && |\n| &&
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: controller,` && |\n| &&
             `          preprocessors: { xml: { models: { template: oModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `` && |\n| &&
             `        const nestParams =` && |\n| &&
             `          z2ui5.oResponse &&` && |\n| &&
             `          z2ui5.oResponse.PARAMS &&` && |\n| &&
             `          z2ui5.oResponse.PARAMS[viewNestId];` && |\n| &&
             `        if (!nestParams) {` && |\n| &&
             `          Lib.logError(``displayNestedView: missing PARAMS.${viewNestId}``);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;` && |\n| &&
             `` && |\n| &&
             `        const oParent = z2ui5.oView && z2ui5.oView.byId(ID);` && |\n| &&
             `        if (!oParent) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``displayNestedView: parent control '${ID}' not found, nested view discarded``,` && |\n| &&
             `          );` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_DESTROY]();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("displayNestedView: parent destroy method failed", e);` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          oParent[METHOD_INSERT](oView);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("displayNestedView: parent insert method failed", e);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[viewProp] = oView;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Shared destroy logic: close (if dialog/popover) and destroy the view,` && |\n| &&
             `      // then clear the slot on z2ui5.` && |\n| &&
             `      _destroyView(prop, tryClose) {` && |\n| &&
             `        const view = z2ui5[prop];` && |\n| &&
             `        if (!view) return;` && |\n| &&
             `        if (tryClose) {` && |\n| &&
             `          try {` && |\n| &&
             `            if (view.close) view.close();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            Lib.logError(``_destroyView: view.close() failed for ${prop}``, e);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        try {` && |\n| &&
             `          view.destroy();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``_destroyView: view.destroy() failed for ${prop}``, e);` && |\n| &&
             `        }` && |\n| &&
             `        z2ui5[prop] = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      destroyPopup() {` && |\n| &&
             `        this._destroyView("oViewPopup", true);` && |\n| &&
             `      },` && |\n| &&
             `      destroyPopover() {` && |\n| &&
             `        this._destroyView("oViewPopover", true);` && |\n| &&
             `      },` && |\n| &&
             `      destroyNestView() {` && |\n| &&
             `        this._destroyView("oViewNest");` && |\n| &&
             `      },` && |\n| &&
             `      destroyNestView2() {` && |\n| &&
             `        this._destroyView("oViewNest2");` && |\n| &&
             `      },` && |\n| &&
             `      destroyView() {` && |\n| &&
             `        this._destroyView("oView");` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eF = "event frontend": handles frontend-only events triggered by` && |\n| &&
             `      // the backend response, without a roundtrip. The name is part of the` && |\n| &&
             `      // protocol - backend-generated view XML binds events to eB/eF - and` && |\n| &&
             `      // must not be renamed.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eF(...args) {` && |\n| &&
             `        runCallbacks(z2ui5.onBeforeEventFrontend, args);` && |\n| &&
             `` && |\n| &&
             `        // NavContainer navigation is dispatched via lookup table.` && |\n| &&
             `        const navLookup = navContainerLookups[args[0]];` && |\n| &&
             `        if (navLookup) {` && |\n| &&
             `          navigateContainer(navLookup, args);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        const handler = eventFrontendHandlers[args[0]];` && |\n| &&
             `        if (handler) this[handler](args);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Individual event handlers - one per entry in eventFrontendHandlers.` && |\n| &&
             `      // Splitting them out keeps eF() short and makes each behavior easy to` && |\n| &&
             `      // find.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      _evHistoryBack() {` && |\n| &&
             `        history.back();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evClipboardCopy(args) {` && |\n| &&
             `        copyToClipboard(args[1]);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evClipboardAppState() {` && |\n| &&
             `        const id = z2ui5.oResponse && z2ui5.oResponse.ID;` && |\n| &&
             `        copyToClipboard(``${window.location.href}#/z2ui5-xapp-state=${id}``);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evDownloadB64File(args) {` && |\n| &&
             `        if (!Lib.isSafeDownloadURL(args[1])) {` && |\n| &&
             `          Lib.logError("DOWNLOAD_B64_FILE: blocked unsafe URL");` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const a = document.createElement("a");` && |\n| &&
             `        a.href = args[1];` && |\n| &&
             `        a.download = args[2];` && |\n| &&
             `        a.click();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evCrossAppNavToPrevApp() {` && |\n| &&
             `        withCrossAppNavigator((nav) => nav.backToPreviousApp());` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetSizeLimit(args) {` && |\n| &&
             `        // Two call shapes:` && |\n| &&
             `        //   ["SET_SIZE_LIMIT", "<limit>", "<viewKey>"]   -> set the limit` && |\n| &&
             `        //   ["SET_SIZE_LIMIT", "<viewKey>"]              -> reset the limit` && |\n| &&
             `        const hasLimit = args[2] !== undefined && args[2] !== "";` && |\n| &&
             `        const viewKey = hasLimit ? args[2] : args[1];` && |\n| &&
             `        const limit = hasLimit ? Number(args[1]) : NaN;` && |\n| &&
             `        const view = Lib.getViewByKey(viewKey);` && |\n| &&
             `        const model = view && view.getModel();` && |\n| &&
             `` && |\n| &&
             `        if (Number.isFinite(limit) && limit > 0) {` && |\n| &&
             `          if (!z2ui5.viewSizeLimits) z2ui5.viewSizeLimits = {};` && |\n| &&
             `          z2ui5.viewSizeLimits[viewKey] = limit;` && |\n| &&
             `          if (model) {` && |\n| &&
             `            model.setSizeLimit(limit);` && |\n| &&
             `            model.refresh(true);` && |\n| &&
             `          }` && |\n| &&
             `        } else {` && |\n| &&
             `          if (z2ui5.viewSizeLimits) delete z2ui5.viewSizeLimits[viewKey];` && |\n| &&
             `          if (model) {` && |\n| &&
             `            model.setSizeLimit(100);` && |\n| &&
             `            model.refresh(true);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetODataModel(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oModel = new ODataModel({` && |\n| &&
             `            serviceUrl: args[1],` && |\n| &&
             `            annotationURI: args[3] || "",` && |\n| &&
             `          });` && |\n| &&
             `          if (z2ui5.oView) z2ui5.oView.setModel(oModel, args[2] || undefined);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``SET_ODATA_MODEL: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evStoreData(args) {` && |\n| &&
             `        const { TYPE, PREFIX, VALUE, KEY } = args[1];` && |\n| &&
             `        try {` && |\n| &&
             `          const storageType = Storage.Type[TYPE] || Storage.Type.session;` && |\n| &&
             `          const oStorage = new Storage(storageType, PREFIX);` && |\n| &&
             `          if (VALUE === "" || VALUE == null) {` && |\n| &&
             `            oStorage.remove(KEY);` && |\n| &&
             `          } else {` && |\n| &&
             `            oStorage.put(KEY, VALUE);` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``STORE_DATA: storage operation failed for key '${KEY}'``,` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evCrossAppNavToExt(args) {` && |\n| &&
             `        withCrossAppNavigator((nav) => {` && |\n| &&
             `          const hash =` && |\n| &&
             `            nav.hrefForExternal({ target: args[1], params: args[2] }) || "";` && |\n| &&
             `          if (args[3] === "EXT") {` && |\n| &&
             `            // External redirect: replace the location while keeping the host.` && |\n| &&
             `            const base = window.location.href.split("#")[0];` && |\n| &&
             `            _URLHelper.redirect(``${base}${hash}``, true);` && |\n| &&
             `          } else {` && |\n| &&
             `            nav.toExternal({ target: { shellHash: hash } });` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evLocationReload(args) {` && |\n| &&
             `        if (Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `          window.location.href = args[1];` && |\n| &&
             `        } else {` && |\n| &&
             `          MessageBox.error(` && |\n| &&
             `            "Invalid redirect URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSystemLogout(args) {` && |\n| &&
             `        const logoutUrl = args[1] || "/sap/public/bc/icf/logoff";` && |\n| &&
             `        const goToLogoutUrl = () => {` && |\n| &&
             `          if (Lib.isValidRedirectURL(logoutUrl)) {` && |\n| &&
             `            window.location.href = logoutUrl;` && |\n| &&
             `          } else {` && |\n| &&
             `            MessageBox.error(` && |\n| &&
             `              "Invalid logout URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        // When abap2UI5 is hosted as a BSP application,` && |\n| &&
             `        // /sap/public/bc/icf/logoff alone does not terminate the stateful` && |\n| &&
             `        // BSP context (sap-contextid stays bound to /sap/bc/bsp/sap/<app>/).` && |\n| &&
             `        // Hit the BSP path with ?sap-sessioncmd=logoff first so the BSP` && |\n| &&
             `        // runtime calls server->session->terminate( ), then go to the ICF` && |\n| &&
             `        // logoff to also drop the SSO2 ticket.` && |\n| &&
             `        const redirectToLogoff = () => {` && |\n| &&
             `          const path = window.location.pathname;` && |\n| &&
             `          if (path.indexOf("/sap/bc/bsp/") !== 0) {` && |\n| &&
             `            goToLogoutUrl();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const sep = path.indexOf("?") >= 0 ? "&" : "?";` && |\n| &&
             `          const bspKill = path + sep + "sap-sessioncmd=logoff";` && |\n| &&
             `          let done = false;` && |\n| &&
             `          const finish = () => {` && |\n| &&
             `            if (done) return;` && |\n| &&
             `            done = true;` && |\n| &&
             `            goToLogoutUrl();` && |\n| &&
             `          };` && |\n| &&
             `          try {` && |\n| &&
             `            const f = document.createElement("iframe");` && |\n| &&
             `            f.style.display = "none";` && |\n| &&
             `            f.src = bspKill;` && |\n| &&
             `            f.addEventListener("load", finish);` && |\n| &&
             `            document.body.appendChild(f);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            finish();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          // Safety net: never wait longer than 1.5s for the BSP terminate.` && |\n| &&
             `          setTimeout(finish, 1500);` && |\n| &&
             `        };` && |\n| &&
             `        try {` && |\n| &&
             `          const launchpadLogout =` && |\n| &&
             `            z2ui5.oLaunchpad &&` && |\n| &&
             `            z2ui5.oLaunchpad.Container &&` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout;` && |\n| &&
             `          if (launchpadLogout) {` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout();` && |\n| &&
             `          } else {` && |\n| &&
             `            redirectToLogoff();` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("SYSTEM_LOGOUT: ushell logout failed", e);` && |\n| &&
             `          redirectToLogoff();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evOpenNewTab(args) {` && |\n| &&
             `        if (!Lib.isValidRedirectURL(args[1])) {` && |\n| &&
             `          MessageBox.error(` && |\n| &&
             `            "Invalid URL. Only relative URLs to the same domain are allowed.",` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const newWindow = window.open(args[1], "_blank");` && |\n| &&
             `        // Clear opener to prevent the new tab from accessing window.opener.` && |\n| &&
             `        if (newWindow) newWindow.opener = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evUrlHelper(args) {` && |\n| &&
             `        const params = args[2];` && |\n| &&
             `        const actions = {` && |\n| &&
             `          REDIRECT: () => {` && |\n| &&
             `            if (!Lib.isSafeRedirectProtocol(params.URL)) {` && |\n| &&
             `              MessageBox.error(` && |\n| &&
             `                "Invalid redirect URL. Only http/https protocols are allowed.",` && |\n| &&
             `              );` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            _URLHelper.redirect(params.URL, params.NEW_WINDOW);` && |\n| &&
             `          },` && |\n| &&
             `          TRIGGER_EMAIL: () =>` && |\n| &&
             `            _URLHelper.triggerEmail(` && |\n| &&
             `              params.EMAIL,` && |\n| &&
             `              params.SUBJECT,` && |\n| &&
             `              params.BODY,` && |\n| &&
             `              params.CC,` && |\n| &&
             `              params.BCC,` && |\n| &&
             `              params.NEW_WINDOW,` && |\n| &&
             `            ),` && |\n| &&
             `          TRIGGER_SMS: () => _URLHelper.triggerSms(params),` && |\n| &&
             `          TRIGGER_TEL: () => _URLHelper.triggerTel(params),` && |\n| &&
             `        };` && |\n| &&
             `        try {` && |\n| &&
             `          const fn = actions[args[1]];` && |\n| &&
             `          if (fn) fn();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``URLHELPER: '${args[1]}' failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evImageEditorPopupClose() {` && |\n| &&
             `        let image;` && |\n| &&
             `        try {` && |\n| &&
             `          const editor = Fragment.byId("popupId", "imageEditor");` && |\n| &&
             `          if (editor) image = editor.getImagePngDataURL();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            "IMAGE_EDITOR_POPUP_CLOSE: getImagePngDataURL failed",` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `        this.destroyPopup();` && |\n| &&
             `        this.eB(["SAVE"], image);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evStartTimer(args) {` && |\n| &&
             `        // Intentionally a single timer slot: args[0] is always the event` && |\n| &&
             `        // name "START_TIMER", so a new START_TIMER replaces the previous` && |\n| &&
             `        // one. At most one backend timer is pending at any time - this is` && |\n| &&
             `        // by design, not a bug.` && |\n| &&
             `        const timerKey = args[0];` && |\n| &&
             `        const callbackEvent = args[1];` && |\n| &&
             `        const delay = +args[2] || 0;` && |\n| &&
             `        if (!z2ui5.timers) z2ui5.timers = {};` && |\n| &&
             `        clearTimeout(z2ui5.timers[timerKey]);` && |\n| &&
             `        z2ui5.timers[timerKey] = setTimeout(() => {` && |\n| &&
             `          delete z2ui5.timers[timerKey];` && |\n| &&
             `          this.eB([callbackEvent]);` && |\n| &&
             `        }, delay);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetInputMode(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const dom = oElement.getDomRef();` && |\n| &&
             `          if (!dom) return;` && |\n| &&
             `          const input = dom.matches("input, textarea")` && |\n| &&
             `            ? dom` && |\n| &&
             `            : dom.querySelector("input, textarea");` && |\n| &&
             `          if (!input) return;` && |\n| &&
             `          input.setAttribute("inputmode", args[2] || "text");` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``KEYBOARD_SET_MODE: setAttribute failed for '${args[1]}'``,` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             |\n|.
    result = result &&
             `      _evSetFocus(args) {` && |\n| &&
             `        const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `        if (!oElement) return;` && |\n| &&
             `` && |\n| &&
             `        const applyFocus = () => {` && |\n| &&
             `          try {` && |\n| &&
             `            const info = oElement.getFocusInfo();` && |\n| &&
             `            if (args[2] != null && args[2] !== "")` && |\n| &&
             `              info.selectionStart = +args[2];` && |\n| &&
             `            if (args[3] != null && args[3] !== "") info.selectionEnd = +args[3];` && |\n| &&
             `            oElement.applyFocusInfo(info);` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            Lib.logError(``SET_FOCUS: failed for '${args[1]}'``, e);` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `` && |\n| &&
             `        // The control may still be missing from the DOM when SET_FOCUS runs` && |\n| &&
             `        // together with a fresh view build. Apply now if it is rendered,` && |\n| &&
             `        // otherwise once it is - same pattern as UITableExt / Scrolling.` && |\n| &&
             `        if (oElement.getDomRef && oElement.getDomRef()) {` && |\n| &&
             `          applyFocus();` && |\n| &&
             `        } else {` && |\n| &&
             `          const delegate = {` && |\n| &&
             `            onAfterRendering: () => {` && |\n| &&
             `              oElement.removeEventDelegate(delegate);` && |\n| &&
             `              applyFocus();` && |\n| &&
             `            },` && |\n| &&
             `          };` && |\n| &&
             `          oElement.addEventDelegate(delegate);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evScrollTo(args) {` && |\n| &&
             `        // args[1] = control id` && |\n| &&
             `        // args[2] = scrollTop  (Y, vertical, px)` && |\n| &&
             `        // args[3] = scrollLeft (X, horizontal, px) - optional, default 0` && |\n| &&
             `        // args[4] = behavior - "auto" (default) | "smooth" | "instant"` && |\n| &&
             `        // Strategy: prefer the control's scroll delegate (sap.m.Page,` && |\n| &&
             `        // ScrollContainer etc. expose ScrollEnablement). The delegate knows` && |\n| &&
             `        // the real scroll container, which often is NOT the control's root` && |\n| &&
             `        // DOM element - so native Element.scrollTo on getDomRef() silently` && |\n| &&
             `        // does nothing on a Page. ScrollEnablement.scrollTo(x, y, time)` && |\n| &&
             `        // animates when time > 0, so "smooth" maps to a 300ms animation.` && |\n| &&
             `        // Native Element.scrollTo is only used as a fallback for controls` && |\n| &&
             `        // without a delegate.` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const y = +args[2] || 0;` && |\n| &&
             `          const x = +args[3] || 0;` && |\n| &&
             `          const behavior = args[4] || "auto";` && |\n| &&
             `          const smooth = behavior === "smooth";` && |\n| &&
             `` && |\n| &&
             `          let handled = false;` && |\n| &&
             `          try {` && |\n| &&
             `            const d =` && |\n| &&
             `              oElement.getScrollDelegate && oElement.getScrollDelegate();` && |\n| &&
             `            if (d && d.scrollTo) {` && |\n| &&
             `              // ScrollEnablement / iScroll delegate: scrollTo(x, y, time)` && |\n| &&
             `              d.scrollTo(x, y, smooth ? 300 : 0);` && |\n| &&
             `              handled = true;` && |\n| &&
             `            }` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            // fall through` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          if (!handled) {` && |\n| &&
             `            const dom =` && |\n| &&
             `              document.getElementById(``${oElement.getId()}-inner``) ||` && |\n| &&
             `              oElement.getDomRef();` && |\n| &&
             `            if (dom && dom.scrollTo) {` && |\n| &&
             `              dom.scrollTo({ top: y, left: x, behavior });` && |\n| &&
             `              handled = true;` && |\n| &&
             `            } else if (dom) {` && |\n| &&
             `              dom.scrollTop = y;` && |\n| &&
             `              dom.scrollLeft = x;` && |\n| &&
             `              handled = true;` && |\n| &&
             `            } else if (oElement.scrollTo) {` && |\n| &&
             `              // sap.m.Page.scrollTo(y, time) - vertical only` && |\n| &&
             `              oElement.scrollTo(y, smooth ? 300 : 0);` && |\n| &&
             `              handled = true;` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``SCROLL_TO: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evScrollIntoView(args) {` && |\n| &&
             `        // args[1] = control id` && |\n| &&
             `        // args[2] = behavior - "smooth" (default) | "auto" | "instant"` && |\n| &&
             `        // args[3] = block    - "start"  (default) | "center" | "end" | "nearest"` && |\n| &&
             `        // args[4] = inline   - "nearest" (default)| "start"  | "center" | "end"` && |\n| &&
             `        // Modern declarative scroll: bring a control into the viewport,` && |\n| &&
             `        // regardless of where the surrounding scroll container currently is.` && |\n| &&
             `        try {` && |\n| &&
             `          const oElement = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          if (!oElement) return;` && |\n| &&
             `          const dom = oElement.getDomRef();` && |\n| &&
             `          if (!dom || !dom.scrollIntoView) return;` && |\n| &&
             `          dom.scrollIntoView({` && |\n| &&
             `            behavior: args[2] || "smooth",` && |\n| &&
             `            block: args[3] || "start",` && |\n| &&
             `            inline: args[4] || "nearest",` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``SCROLL_INTO_VIEW: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetTitle(args) {` && |\n| &&
             `        const title = args[1] == null ? "" : String(args[1]);` && |\n| &&
             `        try {` && |\n| &&
             `          document.title = title;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("SET_TITLE: setting document.title failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evSetTitleLaunchpad(args) {` && |\n| &&
             `        const title = args[1] == null ? "" : String(args[1]);` && |\n| &&
             `        try {` && |\n| &&
             `          const shell = z2ui5.oLaunchpad && z2ui5.oLaunchpad.ShellUIService;` && |\n| &&
             `          if (shell && shell.setTitle) {` && |\n| &&
             `            const result = shell.setTitle(title);` && |\n| &&
             `            if (result && result.catch) {` && |\n| &&
             `              result.catch((e) =>` && |\n| &&
             `                Lib.logError(` && |\n| &&
             `                  "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",` && |\n| &&
             `                  e,` && |\n| &&
             `                ),` && |\n| &&
             `              );` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            "SET_TITLE_LAUNCHPAD: ShellUIService.setTitle failed",` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evZ2ui5Custom(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const fn = z2ui5[args[1]];` && |\n| &&
             `          if (fn) fn(args.slice(2));` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``Z2UI5: '${args[1]}' failed``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evWizardSetNextStep(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const wiz = z2ui5.oView && z2ui5.oView.byId(args[1]);` && |\n| &&
             `          const step = z2ui5.oView && z2ui5.oView.byId(args[2]);` && |\n| &&
             `          const nextStep = z2ui5.oView && z2ui5.oView.byId(args[3]);` && |\n| &&
             `          if (wiz && step) wiz.discardProgress(step);` && |\n| &&
             `          if (step && nextStep) step.setNextStep(nextStep);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``WIZARD_SET_NEXT_STEP: failed for wizard '${args[1]}'``,` && |\n| &&
             `            e,` && |\n| &&
             `          );` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _evPlayAudio(args) {` && |\n| &&
             `        try {` && |\n| &&
             `          const playing = new Audio(args[1]).play();` && |\n| &&
             `          // play() returns a Promise; a rejection (e.g. blocked by the` && |\n| &&
             `          // browser's autoplay policy) is not caught by the surrounding` && |\n| &&
             `          // try/catch and would surface as an unhandled rejection.` && |\n| &&
             `          if (playing && playing.catch) {` && |\n| &&
             `            playing.catch((e) =>` && |\n| &&
             `              Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e),` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError(``PLAY_AUDIO: failed for '${args[1]}'``, e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eB = "event backend": triggers a backend roundtrip with arguments.` && |\n| &&
             `      // The name is part of the protocol - backend-generated view XML binds` && |\n| &&
             `      // events to eB/eF - and must not be renamed.` && |\n| &&
             `      //` && |\n| &&
             `      // args[0] is the event array built by the backend:` && |\n| &&
             `      //   [0] event name` && |\n| &&
             `      //   [2] "ignore busy" flag - background events (e.g. timers) skip the` && |\n| &&
             `      //       busy guard below` && |\n| &&
             `      //   [3] "use main view model" flag - events fired from a popup or` && |\n| &&
             `      //       popover controller that still target the main app's model` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eB(...args) {` && |\n| &&
             `        const [, , ignoreBusy, useMainModel] = args[0];` && |\n| &&
             `` && |\n| &&
             `        if (!navigator.onLine) {` && |\n| &&
             `          MessageBox.alert(` && |\n| &&
             `            "No internet connection! Please reconnect to the server and try again.",` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // If a roundtrip is already in flight, briefly show a BusyDialog so` && |\n| &&
             `        // the user gets visual feedback instead of a silent click.` && |\n| &&
             `        if (z2ui5.isBusy && !ignoreBusy) {` && |\n| &&
             `          if (!_busyDialog) _busyDialog = new BusyDialog();` && |\n| &&
             `          _busyDialog.open();` && |\n| &&
             `          queueMicrotask(() => _busyDialog.close());` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A new roundtrip overrides any pending timer - timers that fired` && |\n| &&
             `        // already removed themselves before calling eB, so this only cancels` && |\n| &&
             `        // timers that are still waiting.` && |\n| &&
             `        if (z2ui5.timers) {` && |\n| &&
             `          for (const key in z2ui5.timers) {` && |\n| &&
             `            clearTimeout(z2ui5.timers[key]);` && |\n| &&
             `            delete z2ui5.timers[key];` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `        z2ui5.oBody = { VIEWNAME: "MAIN" };` && |\n| &&
             `` && |\n| &&
             `        // Decide which view's model holds the data we need to send back. The` && |\n| &&
             `        // mapping is: main app controller -> main view, popup controller ->` && |\n| &&
             `        // popup view, etc.` && |\n| &&
             `        const oModel = this._pickModelForRoundtrip(useMainModel);` && |\n| &&
             `` && |\n| &&
             `        runCallbacks(z2ui5.onBeforeRoundtrip);` && |\n| &&
             `` && |\n| &&
             `        // If the user edited /XX/ paths, send only the delta to keep the` && |\n| &&
             `        // payload small.` && |\n| &&
             `        if (oModel && z2ui5.xxChangedPaths && z2ui5.xxChangedPaths.size > 0) {` && |\n| &&
             `          const data = oModel.getData();` && |\n| &&
             `          const xx = data && data.XX;` && |\n| &&
             `          if (xx) {` && |\n| &&
             `            z2ui5.oBody.XX = Lib.buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oBody.ID = z2ui5.oResponse && z2ui5.oResponse.ID;` && |\n| &&
             `        // Object arguments are stringified for transport; the event name in` && |\n| &&
             `        // args[0] is left as-is.` && |\n| &&
             `        z2ui5.oBody.ARGUMENTS = args.map((item, i) => {` && |\n| &&
             `          if (i > 0 && typeof item === "object") return JSON.stringify(item);` && |\n| &&
             `          return item;` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        Server.roundtrip();` && |\n| &&
             `        runCallbacks(z2ui5.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _pickModelForRoundtrip(useMainModel) {` && |\n| &&
             `        // useMainModel forces use of the main view's model even when called` && |\n| &&
             `        // from a popup/popover controller.` && |\n| &&
             `        if (useMainModel || z2ui5.oController === this) {` && |\n| &&
             `          const sView =` && |\n| &&
             `            z2ui5.oResponse && z2ui5.oResponse.PARAMS` && |\n| &&
             `              ? z2ui5.oResponse.PARAMS.S_VIEW` && |\n| &&
             `              : null;` && |\n| &&
             `          if (sView && sView.SWITCH_DEFAULT_MODEL_PATH) {` && |\n| &&
             `            return z2ui5.oView && z2ui5.oView.getModel("http");` && |\n| &&
             `          }` && |\n| &&
             `          return z2ui5.oView && z2ui5.oView.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerPopup === this) {` && |\n| &&
             `          return z2ui5.oViewPopup && z2ui5.oViewPopup.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerPopover === this) {` && |\n| &&
             `          return z2ui5.oViewPopover && z2ui5.oViewPopover.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerNest === this) {` && |\n| &&
             `          z2ui5.oBody.VIEWNAME = "NEST";` && |\n| &&
             `          return z2ui5.oViewNest && z2ui5.oViewNest.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        if (z2ui5.oControllerNest2 === this) {` && |\n| &&
             `          z2ui5.oBody.VIEWNAME = "NEST2";` && |\n| &&
             `          return z2ui5.oViewNest2 && z2ui5.oViewNest2.getModel();` && |\n| &&
             `        }` && |\n| &&
             `        return undefined;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Re-bind a model to one of the views when the response signals an` && |\n| &&
             `      // update is required for that particular slot.` && |\n| &&
             `      updateModelIfRequired(paramKey, oView) {` && |\n| &&
             `        const params = z2ui5.oResponse && z2ui5.oResponse.PARAMS;` && |\n| &&
             `        const slot = params && params[paramKey];` && |\n| &&
             `        if (!slot || !slot.CHECK_UPDATE_MODEL) return;` && |\n| &&
             `` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(Lib.slotKeyByParam(paramKey), oModel);` && |\n| &&
             `        if (oView) oView.setModel(oModel);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async checkSDKcompatibility(err) {` && |\n| &&
             `        let gav;` && |\n| &&
             `        try {` && |\n| &&
             `          const info = await VersionInfo.load();` && |\n| &&
             `          gav = info.gav;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("checkSDKcompatibility: VersionInfo.load failed", e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!gav || !gav.includes("com.sap.ui5")) {` && |\n| &&
             `          // openui5 doesn't ship some sap.com modules - tell the user which` && |\n| &&
             `          // module is missing so they know to switch to SAPUI5.` && |\n| &&
             `          const missingModule = err && err._modules;` && |\n| &&
             `          Server.responseError(` && |\n| &&
             `            ``openui5 SDK is loaded, module: ${missingModule} is not available in openui5``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        Server.responseError(err);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Display a toast or message box. Triggered for S_MSG_TOAST and` && |\n| &&
             `      // S_MSG_BOX entries in the server response.` && |\n| &&
             `      showMessage(msgType, params) {` && |\n| &&
             `        if (!params) return;` && |\n| &&
             `        const msg = params[msgType];` && |\n| &&
             `        if (!msg || msg.TEXT === undefined) return;` && |\n| &&
             `` && |\n| &&
             `        if (msgType === "S_MSG_TOAST") {` && |\n| &&
             `          MessageToast.show(msg.TEXT, {` && |\n| &&
             `            duration: parseMs(msg.DURATION, 3000),` && |\n| &&
             `            width: msg.WIDTH || "15em",` && |\n| &&
             `            onClose: msg.ONCLOSE ? () => this.eB([msg.ONCLOSE]) : null,` && |\n| &&
             `            autoClose: !!msg.AUTOCLOSE,` && |\n| &&
             `            animationTimingFunction: msg.ANIMATIONTIMINGFUNCTION || "ease",` && |\n| &&
             `            animationDuration: parseMs(msg.ANIMATIONDURATION, 1000),` && |\n| &&
             `            closeonBrowserNavigation: !!msg.CLOSEONBROWSERNAVIGATION,` && |\n| &&
             `          });` && |\n| &&
             `          if (msg.CLASS) {` && |\n| &&
             `            const classes = msg.CLASS.trim().split(/\s+/).filter(Boolean);` && |\n| &&
             `            // Pick the newest toast (several can be open at once). The` && |\n| &&
             `            // element may not be in the DOM yet right after show(), so` && |\n| &&
             `            // retry once on the next animation frame.` && |\n| &&
             `            const applyClass = () => {` && |\n| &&
             `              const toasts = document.querySelectorAll(".sapMMessageToast");` && |\n| &&
             `              const toastEl = toasts[toasts.length - 1];` && |\n| &&
             `              if (toastEl) toastEl.classList.add(...classes);` && |\n| &&
             `              return !!toastEl;` && |\n| &&
             `            };` && |\n| &&
             `            if (!applyClass()) requestAnimationFrame(applyClass);` && |\n| &&
             `          }` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (msgType === "S_MSG_BOX") {` && |\n| &&
             `          const oParams = {` && |\n| &&
             `            styleClass: msg.STYLECLASS || "",` && |\n| &&
             `            title: msg.TITLE || "",` && |\n| &&
             `            onClose: msg.ONCLOSE` && |\n| &&
             `              ? (sAction) => this.eB([msg.ONCLOSE, sAction])` && |\n| &&
             `              : null,` && |\n| &&
             `            actions: msg.ACTIONS || "OK",` && |\n| &&
             `            emphasizedAction: msg.EMPHASIZEDACTION || "OK",` && |\n| &&
             `            initialFocus: msg.INITIALFOCUS || null,` && |\n| &&
             `            textDirection: msg.TEXTDIRECTION || "Inherit",` && |\n| &&
             `            details: msg.DETAILS ? Lib.sanitizeMessageDetails(msg.DETAILS) : "",` && |\n| &&
             `            closeOnNavigation: !!msg.CLOSEONNAVIGATION,` && |\n| &&
             `          };` && |\n| &&
             `          if (msg.ICON && msg.ICON !== "NONE") oParams.icon = msg.ICON;` && |\n| &&
             `          const showFn = MessageBox[msg.TYPE];` && |\n| &&
             `          if (showFn) showFn(msg.TEXT, oParams);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Replace the main app view with the XML coming from the backend.` && |\n| &&
             `      async displayView(xml, viewModel) {` && |\n| &&
             `        const oViewModel = this._trackChanges(new JSONModel(viewModel));` && |\n| &&
             `` && |\n| &&
             `        const sView =` && |\n| &&
             `          z2ui5.oResponse && z2ui5.oResponse.PARAMS` && |\n| &&
             `            ? z2ui5.oResponse.PARAMS.S_VIEW` && |\n| &&
             `            : null;` && |\n| &&
             `        const switchPath = sView && sView.SWITCH_DEFAULT_MODEL_PATH;` && |\n| &&
             `` && |\n| &&
             `        // When the app wants OData as the default model, build it here and` && |\n| &&
             `        // keep the JSON model as the named "http" model.` && |\n| &&
             `        let oModel;` && |\n| &&
             `        if (switchPath) {` && |\n| &&
             `          oModel = new ODataModel({` && |\n| &&
             `            serviceUrl: switchPath,` && |\n| &&
             `            annotationURI: sView.SWITCHDEFAULTMODELANNOURI || "",` && |\n| &&
             `          });` && |\n| &&
             `        } else {` && |\n| &&
             `          oModel = oViewModel;` && |\n| &&
             `        }` && |\n| &&
             `        applyStoredSizeLimit("MAIN", oModel);` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          models: oModel,` && |\n| &&
             `          controller: z2ui5.oController,` && |\n| &&
             `          id: "mainView",` && |\n| &&
             |\n|.
    result = result &&
             `          preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        // Guard against the app being destroyed during the await above.` && |\n| &&
             `        if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `          z2ui5.oView.destroy();` && |\n| &&
             `          if (switchPath) oModel.destroy();` && |\n| &&
             `          z2ui5.oView = null;` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.oView.setModel(z2ui5.oDeviceModel, "device");` && |\n| &&
             `        if (switchPath) z2ui5.oView.setModel(oViewModel, "http");` && |\n| &&
             `        z2ui5.oApp.removeAllPages();` && |\n| &&
             `        z2ui5.oApp.insertPage(z2ui5.oView);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
