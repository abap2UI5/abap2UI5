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

    result = `// The central view controller. One instance serves each of the five view` && |\n| &&
             `// slots (main view, two nested views, popup, popover - see` && |\n| &&
             `// core/ViewSlots.js). It builds the request for backend events (eB),` && |\n| &&
             `// dispatches frontend-only events (eF), renders the views and fragments a` && |\n| &&
             `// response asks for, and runs the post-render follow-ups.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "sap/ui/core/mvc/XMLView",` && |\n| &&
             `    "sap/ui/model/json/JSONModel",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "sap/ui/core/Fragment",` && |\n| &&
             `    "sap/m/BusyDialog",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "sap/ui/model/odata/v2/ODataModel",` && |\n| &&
             `    "sap/ui/core/routing/HashChanger",` && |\n| &&
             `    "sap/ui/core/Element",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/FrontendAction",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    Controller,` && |\n| &&
             `    XMLView,` && |\n| &&
             `    JSONModel,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    Fragment,` && |\n| &&
             `    BusyDialog,` && |\n| &&
             `    Server,` && |\n| &&
             `    ODataModel,` && |\n| &&
             `    HashChanger,` && |\n| &&
             `    Element,` && |\n| &&
             `    Lib,` && |\n| &&
             `    FrontendAction,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Helpers reused across calls; kept as module-level singletons.` && |\n| &&
             `    const _hashChanger = HashChanger.getInstance();` && |\n| &&
             `` && |\n| &&
             `    // Single reusable BusyDialog flashed when the user clicks while a` && |\n| &&
             `    // roundtrip is already in flight (created lazily, kept for reuse).` && |\n| &&
             `    // The timestamp throttles the flash: rapid clicking during a slow` && |\n| &&
             `    // roundtrip would otherwise run a full open/render/close cycle per` && |\n| &&
             `    // click without adding any feedback.` && |\n| &&
             `    let _busyDialog = null;` && |\n| &&
             `    let _busyFlashUntil = 0;` && |\n| &&
             `` && |\n| &&
             `    function applyStoredSizeLimit(viewKey, oModel) {` && |\n| &&
             `      if (!oModel) return;` && |\n| &&
             `      const limit = AppState.state.viewSizeLimits[viewKey];` && |\n| &&
             `      if (limit !== undefined) oModel.setSizeLimit(limit);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return Controller.extend("z2ui5.controller.View1", {` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // Model change tracking - remembers which /XX/ paths the user edited` && |\n| &&
             `      // so the next roundtrip only ships the delta.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      _trackChanges(oModel) {` && |\n| &&
             `        // Mark the model as framework-owned: updateModelIfRequired may only` && |\n| &&
             `        // reuse models that carry this change tracker.` && |\n| &&
             `        oModel._z2ui5Tracked = true;` && |\n| &&
             `        oModel.attachPropertyChange((e) => {` && |\n| &&
             `          const params = e.getParameters();` && |\n| &&
             `          const raw = params.path;` && |\n| &&
             `          const ctx = params.context;` && |\n| &&
             `          if (!raw) return;` && |\n| &&
             `          // Resolve relative paths against the binding context.` && |\n| &&
             `          const changedPath =` && |\n| &&
             `            ctx && !raw.startsWith("/") ? ``${ctx.getPath()}/${raw}`` : raw;` && |\n| &&
             `          if (changedPath.startsWith("/XX/")) {` && |\n| &&
             `            AppState.state.xxChangedPaths.add(changedPath);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        return oModel;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        if (AppState.state.oResponse && !AppState.state.oResponse._processed) {` && |\n| &&
             `          this._processAfterRendering();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Runs once after each roundtrip's view has been rendered, in two` && |\n| &&
             `      // named phases: display pending fragments/views, then update the` && |\n| &&
             `      // browser history/hash.` && |\n| &&
             `      async _processAfterRendering() {` && |\n| &&
             `        try {` && |\n| &&
             `          const oResponse = AppState.state.oResponse;` && |\n| &&
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
             `          Lib.runCallbacks(AppState.state.onAfterRendering);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("_processAfterRendering: unexpected error", e);` && |\n| &&
             `          Server.responseError(e, "Unexpected Error Occurred - App Terminated");` && |\n| &&
             `        } finally {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          AppState.state.isBusy = false;` && |\n| &&
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
             `        if (!AppState.state.checkNestAfter && S_VIEW_NEST?.XML) {` && |\n| &&
             `          this.destroyNestView();` && |\n| &&
             `          await this.displayNestedView(S_VIEW_NEST.XML, "NEST");` && |\n| &&
             `          AppState.state.checkNestAfter = true;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (!AppState.state.checkNestAfter2 && S_VIEW_NEST2?.XML) {` && |\n| &&
             `          this.destroyNestView2();` && |\n| &&
             `          await this.displayNestedView(S_VIEW_NEST2.XML, "NEST2");` && |\n| &&
             `          AppState.state.checkNestAfter2 = true;` && |\n| &&
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
             `        try {` && |\n| &&
             `          if (PARAMS.SET_PUSH_STATE) {` && |\n| &&
             `            const hash = _hashChanger.getHash();` && |\n| &&
             `            const newUrl = ``${window.location.pathname}${window.location.search}#${hash}${PARAMS.SET_PUSH_STATE}``;` && |\n| &&
             `            history.pushState(null, "", newUrl);` && |\n| &&
             `          }` && |\n| &&
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
             `        const customJs = AppState.state.pendingCustomJs;` && |\n| &&
             `        AppState.state.pendingCustomJs = null;` && |\n| &&
             `        if (!customJs) return;` && |\n| &&
             `        if (Lib.isDestroyed(this)) return;` && |\n| &&
             `        for (const item of customJs) {` && |\n| &&
             `          Server._runCustomJs(item, this);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _createViewModel() {` && |\n| &&
             `        const data = AppState.state.oResponse?.OVIEWMODEL;` && |\n| &&
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
             `        if (!Lib.isAlive(AppState.state.oApp)) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `        ViewSlots.setView("POPUP", oFragment);` && |\n| &&
             `        oFragment.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async displayPopover(xml, openById) {` && |\n| &&
             `        // No catch-all here on purpose: a malformed-XML load or render` && |\n| &&
             `        // failure must propagate to _processAfterRendering and surface the` && |\n| &&
             `        // fatal "App Terminated" overlay, exactly like displayFragment and` && |\n| &&
             `        // displayNestedView. The explicit returns below stay graceful - they` && |\n| &&
             `        // handle expected, non-error conditions (app torn down mid-load, or` && |\n| &&
             `        // the openBy anchor not being present), matching the parent-not-found` && |\n| &&
             `        // guard in displayNestedView.` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit("POPOVER", oModel);` && |\n| &&
             `        const oFragment = await Fragment.load({` && |\n| &&
             `          definition: xml,` && |\n| &&
             `          controller: ViewSlots.getController("POPOVER"),` && |\n| &&
             `          id: "popoverId",` && |\n| &&
             `        });` && |\n| &&
             `        if (!Lib.isAlive(AppState.state.oApp)) {` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oFragment.setModel(oModel);` && |\n| &&
             `` && |\n| &&
             `        // Find the control to attach the popover to. We search the main` && |\n| &&
             `        // view first, then any open popup / nested views, then the global` && |\n| &&
             `        // UI5 control registry as a last resort.` && |\n| &&
             `        let oControl =` && |\n| &&
             `          ViewSlots.byId("MAIN", openById) ||` && |\n| &&
             `          ViewSlots.byId("POPUP", openById) ||` && |\n| &&
             `          ViewSlots.byId("NEST", openById) ||` && |\n| &&
             `          ViewSlots.byId("NEST2", openById);` && |\n| &&
             `        if (!oControl) {` && |\n| &&
             `          if (Element.getElementById) {` && |\n| &&
             `            oControl = Element.getElementById(openById);` && |\n| &&
             `          } else {` && |\n| &&
             `            /* ui5lint-disable no-globals, no-deprecated-api --` && |\n| &&
             `               deliberate fallback for UI5 releases that do not provide` && |\n| &&
             `               Element.getElementById yet (added in 1.119); the modern` && |\n| &&
             `               API is used in the branch above. */` && |\n| &&
             `            if (sap.ui.getCore) {` && |\n| &&
             `              const core = sap.ui.getCore();` && |\n| &&
             `              if (core?.byId) oControl = core.byId(openById);` && |\n| &&
             `            }` && |\n| &&
             `            /* ui5lint-enable no-globals, no-deprecated-api */` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (!oControl) {` && |\n| &&
             `          Lib.logError(` && |\n| &&
             `            ``displayPopover: openBy control '${openById}' not found``,` && |\n| &&
             `          );` && |\n| &&
             `          oFragment.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        ViewSlots.setView("POPOVER", oFragment);` && |\n| &&
             `        oFragment.openBy(oControl);` && |\n| &&
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
             `        if (!Lib.isAlive(AppState.state.oApp)) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `` && |\n| &&
             `        const nestParams = AppState.state.oResponse?.PARAMS?.[paramKey];` && |\n| &&
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
             `        // the user gets visual feedback instead of a silent click - at most` && |\n| &&
             `        // once per second, further clicks inside that window are ignored.` && |\n| &&
             `        if (AppState.state.isBusy && !ignoreBusy) {` && |\n| &&
             `          if (Date.now() >= _busyFlashUntil) {` && |\n| &&
             `            _busyFlashUntil = Date.now() + 1000;` && |\n| &&
             `            if (!_busyDialog) _busyDialog = new BusyDialog();` && |\n| &&
             `            _busyDialog.open();` && |\n| &&
             `            queueMicrotask(() => _busyDialog.close());` && |\n| &&
             `          }` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // A new roundtrip overrides any pending timer - timers that fired` && |\n| &&
             `        // already removed themselves before calling eB, so this only cancels` && |\n| &&
             `        // timers that are still waiting.` && |\n| &&
             `        for (const key in AppState.state.timers) {` && |\n| &&
             `          clearTimeout(AppState.state.timers[key]);` && |\n| &&
             `          delete AppState.state.timers[key];` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        AppState.state.isBusy = true;` && |\n| &&
             `        BusyIndicator.show();` && |\n| &&
             `` && |\n| &&
             `        // The request body is built locally and handed explicitly through` && |\n| &&
             `        // Server.roundtrip/readHttp. It is mirrored to AppState.state.oBody right` && |\n| &&
             `        // away so onBeforeRoundtrip hooks and the debug tool see it.` && |\n| &&
             `        const oBody = { VIEWNAME: "MAIN" };` && |\n| &&
             `        AppState.state.oBody = oBody;` && |\n| &&
             `` && |\n| &&
             `        // Decide which view's model holds the data we need to send back. The` && |\n| &&
             `        // mapping is: main app controller -> main view, popup controller ->` && |\n| &&
             `        // popup view, etc.` && |\n| &&
             `        const oModel = this._pickModelForRoundtrip(useMainModel, oBody);` && |\n|.
    result = result &&
             `` && |\n| &&
             `        Lib.runCallbacks(AppState.state.onBeforeRoundtrip);` && |\n| &&
             `` && |\n| &&
             `        // If the user edited /XX/ paths, send only the delta to keep the` && |\n| &&
             `        // payload small.` && |\n| &&
             `        if (oModel && AppState.state.xxChangedPaths.size > 0) {` && |\n| &&
             `          const data = oModel.getData();` && |\n| &&
             `          const xx = data?.XX;` && |\n| &&
             `          if (xx) {` && |\n| &&
             `            oBody.XX = Lib.buildDeltaFromPaths(` && |\n| &&
             `              AppState.state.xxChangedPaths,` && |\n| &&
             `              xx,` && |\n| &&
             `            );` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        oBody.ID = AppState.state.oResponse?.ID;` && |\n| &&
             `        // Arguments travel as raw JSON values - the request body is` && |\n| &&
             `        // serialized exactly once in Server.readHttp. Object arguments are` && |\n| &&
             `        // turned into JSON strings by the backend when it fills` && |\n| &&
             `        // T_EVENT_ARG, so apps keep receiving them as strings; stringifying` && |\n| &&
             `        // them here as well would encode (and escape) the payload twice.` && |\n| &&
             `        oBody.ARGUMENTS = args.slice();` && |\n| &&
             `` && |\n| &&
             `        Server.roundtrip(oBody);` && |\n| &&
             `        Lib.runCallbacks(AppState.state.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _pickModelForRoundtrip(useMainModel, oBody) {` && |\n| &&
             `        // useMainModel forces use of the main view's model even when called` && |\n| &&
             `        // from a popup/popover controller.` && |\n| &&
             `        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);` && |\n| &&
             `        if (!slotKey) return undefined;` && |\n| &&
             `` && |\n| &&
             `        if (slotKey === "MAIN") {` && |\n| &&
             `          const sView = AppState.state.oResponse?.PARAMS?.S_VIEW;` && |\n| &&
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
             `      // Refresh a slot's model when the response signals an update for it` && |\n| &&
             `      // (CHECK_UPDATE_MODEL - the data-only roundtrip every app triggers` && |\n| &&
             `      // via client->view_model_update( )).` && |\n| &&
             `      updateModelIfRequired(slotKey) {` && |\n| &&
             `        const params = AppState.state.oResponse?.PARAMS;` && |\n| &&
             `        const slotParams = params?.[ViewSlots.paramByKey(slotKey)];` && |\n| &&
             `        if (!slotParams?.CHECK_UPDATE_MODEL) return;` && |\n| &&
             `` && |\n| &&
             `        const oView = ViewSlots.getView(slotKey);` && |\n| &&
             `        if (!oView) return;` && |\n| &&
             `` && |\n| &&
             `        // Reuse the existing model whenever it is ours: setData() keeps the` && |\n| &&
             `        // view's bindings alive and only refreshes what changed, while a new` && |\n| &&
             `        // model + setModel() destroys and recreates every binding - measured` && |\n| &&
             `        // ~3x slower with all values changed and ~150x slower when little` && |\n| &&
             `        // changed (see node/tests-examples/modelUpdate.bench.spec.js).` && |\n| &&
             `        const existing = oView.getModel();` && |\n| &&
             `        if (existing?._z2ui5Tracked) {` && |\n| &&
             `          applyStoredSizeLimit(slotKey, existing);` && |\n| &&
             `          existing.setData(AppState.state.oResponse?.OVIEWMODEL);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // The slot's default model is not framework-owned (e.g. an` && |\n| &&
             `        // ODataModel via SWITCH_DEFAULT_MODEL_PATH): keep the previous` && |\n| &&
             `        // behavior and bind a fresh JSON model.` && |\n| &&
             `        const oModel = this._createViewModel();` && |\n| &&
             `        applyStoredSizeLimit(slotKey, oModel);` && |\n| &&
             `        oView.setModel(oModel);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Replace the main app view with the XML coming from the backend.` && |\n| &&
             `      async displayView(xml, viewModel) {` && |\n| &&
             `        const oViewModel = this._trackChanges(new JSONModel(viewModel));` && |\n| &&
             `` && |\n| &&
             `        const sView = AppState.state.oResponse?.PARAMS?.S_VIEW;` && |\n| &&
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
             `        if (!Lib.isAlive(AppState.state.oApp)) {` && |\n| &&
             `          oView.destroy();` && |\n| &&
             `          if (switchPath) oModel.destroy();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        ViewSlots.setView("MAIN", oView);` && |\n| &&
             `        oView.setModel(AppState.state.oDeviceModel, "device");` && |\n| &&
             `        if (switchPath) oView.setModel(oViewModel, "http");` && |\n| &&
             `        AppState.state.oApp.removeAllPages();` && |\n| &&
             `        AppState.state.oApp.insertPage(oView);` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
