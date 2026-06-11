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
             `    "z2ui5/core/Server",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `    "sap/ui/core/Element",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/FrontendAction",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
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
             `    HashChanger,` && |\n| &&
             `    Element,` && |\n| &&
             `    Lib,` && |\n| &&
             `    FrontendAction,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Small utility helpers (module-private)` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Parse a value as integer milliseconds, falling back to ``def`` when the` && |\n| &&
             `    // input is empty / undefined.` && |\n| &&
             `    function parseMs(val, def) {` && |\n| &&
             `      return val ? +val : def;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Helpers reused across calls; kept as module-level singletons.` && |\n| &&
             `    const _hashChanger = HashChanger.getInstance();` && |\n| &&
             `` && |\n| &&
             `    // Single reusable BusyDialog flashed when the user clicks while a` && |\n| &&
             `    // roundtrip is already in flight (created lazily, kept for reuse).` && |\n| &&
             `    let _busyDialog = null;` && |\n| &&
             `` && |\n| &&
             `    function applyStoredSizeLimit(viewKey, oModel) {` && |\n| &&
             `      if (!oModel) return;` && |\n| &&
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
             `      // Runs once after each roundtrip's view has been rendered, in two` && |\n| &&
             `      // named phases: display pending fragments/views, then update the` && |\n| &&
             `      // browser history/hash.` && |\n| &&
             `      async _processAfterRendering() {` && |\n| &&
             `        try {` && |\n| &&
             `          const oResponse = z2ui5.oResponse;` && |\n| &&
             `          if (oResponse._processed) return;` && |\n| &&
             `          oResponse._processed = true;` && |\n| &&
             `` && |\n| &&
             `          const PARAMS = oResponse.PARAMS;` && |\n| &&
             `          if (!PARAMS) return;` && |\n| &&
             `` && |\n| &&
             `          await this._displayPendingViews(PARAMS);` && |\n| &&
             `          this._updateBrowserHistory(PARAMS, oResponse.ID);` && |\n| &&
             `          if (PARAMS.SET_NAV_BACK) history.back();` && |\n| &&
             `` && |\n| &&
             `          Lib.runCallbacks(z2ui5.onAfterRendering);` && |\n| &&
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
             `      // Phase 1: open/destroy the popup, nested views and popover the` && |\n| &&
             `      // response asked for.` && |\n| &&
             `      async _displayPendingViews(PARAMS) {` && |\n| &&
             `        const S_POPUP = PARAMS.S_POPUP;` && |\n| &&
             `        const S_VIEW_NEST = PARAMS.S_VIEW_NEST;` && |\n| &&
             `        const S_VIEW_NEST2 = PARAMS.S_VIEW_NEST2;` && |\n| &&
             `        const S_POPOVER = PARAMS.S_POPOVER;` && |\n| &&
             `` && |\n| &&
             `        if (S_POPUP?.CHECK_DESTROY) this.destroyPopup();` && |\n| &&
             `        if (S_POPOVER?.CHECK_DESTROY) this.destroyPopover();` && |\n| &&
             `` && |\n| &&
             `        if (S_POPUP?.XML) {` && |\n| &&
             `          this.destroyPopup();` && |\n| &&
             `          await this.displayFragment(S_POPUP.XML);` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (!z2ui5.checkNestAfter && S_VIEW_NEST?.XML) {` && |\n| &&
             `          this.destroyNestView();` && |\n| &&
             `          await this.displayNestedView(S_VIEW_NEST.XML, "NEST");` && |\n| &&
             `          z2ui5.checkNestAfter = true;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (!z2ui5.checkNestAfter2 && S_VIEW_NEST2?.XML) {` && |\n| &&
             `          this.destroyNestView2();` && |\n| &&
             `          await this.displayNestedView(S_VIEW_NEST2.XML, "NEST2");` && |\n| &&
             `          z2ui5.checkNestAfter2 = true;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (S_POPOVER?.XML) {` && |\n| &&
             `          this.destroyPopover();` && |\n| &&
             `          await this.displayPopover(S_POPOVER.XML, S_POPOVER.OPEN_BY_ID);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Phase 2: push the backend-requested URL and update the app-state` && |\n| &&
             `      // hash.` && |\n| &&
             `      _updateBrowserHistory(PARAMS, ID) {` && |\n| &&
             `        // Currently disabled: storing the rendered view + model in` && |\n| &&
             `        // history.state so a popstate could restore the view without a` && |\n| &&
             `        // backend hit. Cloning the full view XML and model data on every` && |\n| &&
             `        // roundtrip is expensive for large views and the restore is not` && |\n| &&
             `        // needed right now. Re-enable together with the popstate listener` && |\n| &&
             `        // in Component.js (_installPopstateListener).` && |\n| &&
             `        // const oView = z2ui5.oView;` && |\n| &&
             `        // let oState = {};` && |\n| &&
             `        // if (oView) {` && |\n| &&
             `        //   const model = oView.getModel();` && |\n| &&
             `        //   oState = {` && |\n| &&
             `        //     view: oView.mProperties.viewContent,` && |\n| &&
             `        //     model: model ? model.getData() : undefined,` && |\n| &&
             `        //     response: z2ui5.oResponse,` && |\n| &&
             `        //   };` && |\n| &&
             `        // }` && |\n| &&
             `` && |\n| &&
             `        try {` && |\n| &&
             `          if (PARAMS.SET_PUSH_STATE) {` && |\n| &&
             `            const hash = _hashChanger.getHash();` && |\n| &&
             `            const newUrl = ``${window.location.pathname}${window.location.search}#${hash}${PARAMS.SET_PUSH_STATE}``;` && |\n| &&
             `            history.pushState(null, "", newUrl);` && |\n| &&
             `          }` && |\n| &&
             `          // Disabled together with the state storing above - without a` && |\n| &&
             `          // state object this call was a pure no-op:` && |\n| &&
             `          // else {` && |\n| &&
             `          //   history.replaceState(oState, "", window.location.href);` && |\n| &&
             `          // }` && |\n| &&
             `          const newHash = PARAMS.SET_APP_STATE_ACTIVE` && |\n| &&
             `            ? ``z2ui5-xapp-state=${ID || ""}``` && |\n| &&
             `            : "";` && |\n| &&
             `          _hashChanger.replaceHash(newHash);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("_updateBrowserHistory: history update failed", e);` && |\n| &&
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
             `        const data = z2ui5.oResponse?.OVIEWMODEL;` && |\n| &&
             `        return this._trackChanges(new JSONModel(data));` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Display: popups, popovers, nested views, main view` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `      async displayFragment(xml) {` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit("POPUP", oModel);` && |\n| &&
             `        const oFragment = await Fragment.load({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: ViewSlots.getController("POPUP"),` && |\n| &&
             `          id: "popupId",` && |\n| &&
             `        });` && |\n| &&
             `        // The app might have been torn down while the fragment loaded.` && |\n| &&
             `        if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        ViewSlots.setView("POPUP", oFragment);` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayPopover(xml, openById) {` && |\n| &&
             `        try {` && |\n| &&
             `          const oModel = this._createViewModel();` && |\n| &&
             `          applyStoredSizeLimit("POPOVER", oModel);` && |\n| &&
             `          const oFragment = await Fragment.load({` && |\n| &&
             `            definition: xml,` && |\n| &&
             `            controller: ViewSlots.getController("POPOVER"),` && |\n| &&
             `            id: "popoverId",` && |\n| &&
             `          });` && |\n| &&
             `          if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `            oFragment.destroy();` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          oFragment.setModel(oModel);` && |\n| &&
             `` && |\n| &&
             `          // Find the control to attach the popover to. We search the main` && |\n| &&
             `          // view first, then any open popup / nested views, then the global` && |\n| &&
             `          // UI5 control registry as a last resort.` && |\n| &&
             `          let oControl =` && |\n| &&
             `            ViewSlots.byId("MAIN", openById) ||` && |\n| &&
             `            ViewSlots.byId("POPUP", openById) ||` && |\n| &&
             `            ViewSlots.byId("NEST", openById) ||` && |\n| &&
             `            ViewSlots.byId("NEST2", openById);` && |\n| &&
             `          if (!oControl) {` && |\n| &&
             `            if (Element.getElementById) {` && |\n| &&
             `              oControl = Element.getElementById(openById);` && |\n| &&
             `            } else {` && |\n| &&
             `              /* ui5lint-disable no-globals, no-deprecated-api --` && |\n| &&
             `                 deliberate fallback for UI5 releases that do not provide` && |\n| &&
             `                 Element.getElementById yet (added in 1.119); the modern` && |\n| &&
             `                 API is used in the branch above. */` && |\n| &&
             `              if (sap.ui.getCore) {` && |\n| &&
             `                const core = sap.ui.getCore();` && |\n| &&
             `                if (core?.byId) oControl = core.byId(openById);` && |\n| &&
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
             `          ViewSlots.setView("POPOVER", oFragment);` && |\n| &&
             `          oFragment.openBy(oControl);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("displayPopover: failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayNestedView(xml, slotKey) {` && |\n| &&
             `        const paramKey = ViewSlots.paramByKey(slotKey);` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: ViewSlots.getController(slotKey),` && |\n| &&
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
             `          z2ui5.oResponse?.PARAMS && z2ui5.oResponse.PARAMS[paramKey];` && |\n| &&
             `        if (!nestParams) {` && |\n| &&
             `          Lib.logError(``displayNestedView: missing PARAMS.${paramKey}``);` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;` && |\n| &&
             `` && |\n| &&
             `        const oParent = ViewSlots.byId("MAIN", ID);` && |\n| &&
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
             `        ViewSlots.setView(slotKey, oView);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Thin wrappers around the shared slot teardown in ViewSlots, kept` && |\n| &&
             `      // because existing apps may call them via custom JS.` && |\n| &&
             `      destroyPopup() {` && |\n| &&
             `        ViewSlots.destroy("POPUP");` && |\n| &&
             `      },` && |\n| &&
             `      destroyPopover() {` && |\n| &&
             `        ViewSlots.destroy("POPOVER");` && |\n| &&
             `      },` && |\n| &&
             `      destroyNestView() {` && |\n| &&
             `        ViewSlots.destroy("NEST");` && |\n| &&
             `      },` && |\n| &&
             `      destroyNestView2() {` && |\n| &&
             `        ViewSlots.destroy("NEST2");` && |\n| &&
             `      },` && |\n| &&
             `      destroyView() {` && |\n| &&
             `        ViewSlots.destroy("MAIN");` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eF = "event frontend": handles frontend-only events triggered by` && |\n| &&
             `      // the backend response, without a roundtrip. The name is part of the` && |\n| &&
             `      // protocol - backend-generated view XML binds events to eB/eF - and` && |\n| &&
             `      // must not be renamed. The individual handlers live in` && |\n| &&
             `      // core/FrontendAction.js.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eF(...args) {` && |\n| &&
             `        FrontendAction.execute(this, args);` && |\n| &&
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
             |\n|.
    result = result &&
             `          _busyDialog.open();` && |\n| &&
             `          queueMicrotask(() => _busyDialog.close());` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A new roundtrip overrides any pending timer - timers that fired` && |\n| &&
             `        // already removed themselves before calling eB, so this only cancels` && |\n| &&
             `        // timers that are still waiting.` && |\n| &&
             `        for (const key in z2ui5.timers) {` && |\n| &&
             `          clearTimeout(z2ui5.timers[key]);` && |\n| &&
             `          delete z2ui5.timers[key];` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        z2ui5.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `` && |\n| &&
             `        // The request body is built locally and handed explicitly through` && |\n| &&
             `        // Server.roundtrip/readHttp. It is mirrored to z2ui5.oBody right` && |\n| &&
             `        // away so onBeforeRoundtrip hooks and the debug tool see it.` && |\n| &&
             `        const oBody = { VIEWNAME: "MAIN" };` && |\n| &&
             `        z2ui5.oBody = oBody;` && |\n| &&
             `` && |\n| &&
             `        // Decide which view's model holds the data we need to send back. The` && |\n| &&
             `        // mapping is: main app controller -> main view, popup controller ->` && |\n| &&
             `        // popup view, etc.` && |\n| &&
             `        const oModel = this._pickModelForRoundtrip(useMainModel, oBody);` && |\n| &&
             `` && |\n| &&
             `        Lib.runCallbacks(z2ui5.onBeforeRoundtrip);` && |\n| &&
             `` && |\n| &&
             `        // If the user edited /XX/ paths, send only the delta to keep the` && |\n| &&
             `        // payload small.` && |\n| &&
             `        if (oModel && z2ui5.xxChangedPaths.size > 0) {` && |\n| &&
             `          const data = oModel.getData();` && |\n| &&
             `          const xx = data?.XX;` && |\n| &&
             `          if (xx) {` && |\n| &&
             `            oBody.XX = Lib.buildDeltaFromPaths(z2ui5.xxChangedPaths, xx);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        oBody.ID = z2ui5.oResponse?.ID;` && |\n| &&
             `        // Object arguments are stringified for transport; the event name in` && |\n| &&
             `        // args[0] is left as-is.` && |\n| &&
             `        oBody.ARGUMENTS = args.map((item, i) => {` && |\n| &&
             `          if (i > 0 && typeof item === "object") return JSON.stringify(item);` && |\n| &&
             `          return item;` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        Server.roundtrip(oBody);` && |\n| &&
             `        Lib.runCallbacks(z2ui5.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _pickModelForRoundtrip(useMainModel, oBody) {` && |\n| &&
             `        // useMainModel forces use of the main view's model even when called` && |\n| &&
             `        // from a popup/popover controller.` && |\n| &&
             `        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);` && |\n| &&
             `        if (!slotKey) return undefined;` && |\n| &&
             `` && |\n| &&
             `        if (slotKey === "MAIN") {` && |\n| &&
             `          const sView = z2ui5.oResponse?.PARAMS` && |\n| &&
             `            ? z2ui5.oResponse.PARAMS.S_VIEW` && |\n| &&
             `            : null;` && |\n| &&
             `          if (sView?.SWITCH_DEFAULT_MODEL_PATH) {` && |\n| &&
             `            return ViewSlots.getView("MAIN")?.getModel("http");` && |\n| &&
             `          }` && |\n| &&
             `          return ViewSlots.getView("MAIN")?.getModel();` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Nested views report their slot as VIEW in S_FRONT so the backend` && |\n| &&
             `        // routes the event to the right app instance.` && |\n| &&
             `        if (slotKey === "NEST" || slotKey === "NEST2") {` && |\n| &&
             `          oBody.VIEWNAME = slotKey;` && |\n| &&
             `        }` && |\n| &&
             `        return ViewSlots.getView(slotKey)?.getModel();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Re-bind a model to one of the views when the response signals an` && |\n| &&
             `      // update is required for that particular slot.` && |\n| &&
             `      updateModelIfRequired(slotKey) {` && |\n| &&
             `        const params = z2ui5.oResponse?.PARAMS;` && |\n| &&
             `        const slotParams = params?.[ViewSlots.paramByKey(slotKey)];` && |\n| &&
             `        if (!slotParams || !slotParams.CHECK_UPDATE_MODEL) return;` && |\n| &&
             `` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `        const oView = ViewSlots.getView(slotKey);` && |\n| &&
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
             `          const missingModule = err?._modules;` && |\n| &&
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
             `        const sView = z2ui5.oResponse?.PARAMS` && |\n| &&
             `          ? z2ui5.oResponse.PARAMS.S_VIEW` && |\n| &&
             `          : null;` && |\n| &&
             `        const switchPath = sView?.SWITCH_DEFAULT_MODEL_PATH;` && |\n| &&
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
             `        const oView = await XMLView.create({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          models: oModel,` && |\n| &&
             `          controller: ViewSlots.getController("MAIN"),` && |\n| &&
             `          id: "mainView",` && |\n| &&
             `          preprocessors: { xml: { models: { template: oViewModel } } },` && |\n| &&
             `        });` && |\n| &&
             `` && |\n| &&
             `        // Guard against the app being destroyed during the await above.` && |\n| &&
             `        if (!Lib.isAlive(z2ui5.oApp)) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          if (switchPath) oModel.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        ViewSlots.setView("MAIN", oView);` && |\n| &&
             `        oView.setModel(z2ui5.oDeviceModel, "device");` && |\n| &&
             `        if (switchPath) oView.setModel(oViewModel, "http");` && |\n| &&
             `        z2ui5.oApp.removeAllPages();` && |\n| &&
             `        z2ui5.oApp.insertPage(oView);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
