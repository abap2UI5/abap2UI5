// The central view controller. One instance serves each of the five view
// slots (main view, two nested views, popup, popover - see
// core/ViewSlots.js). It builds the request for backend events (eB),
// dispatches frontend-only events (eF), renders the views and fragments a
// response asks for, and runs the post-render follow-ups.
sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/mvc/XMLView",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/BusyIndicator",
    "sap/m/MessageBox",
    "sap/ui/core/Fragment",
    "sap/m/BusyDialog",
    "z2ui5/core/Server",
    "sap/ui/model/odata/v2/ODataModel",
    "sap/ui/core/routing/HashChanger",
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
    "z2ui5/core/FrontendAction",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/AppState",
  ],
  (
    Controller,
    XMLView,
    JSONModel,
    BusyIndicator,
    MessageBox,
    Fragment,
    BusyDialog,
    Server,
    ODataModel,
    HashChanger,
    Element,
    Lib,
    FrontendAction,
    ViewSlots,
    AppState,
  ) => {
    "use strict";

    // Helpers reused across calls; kept as module-level singletons.
    const _hashChanger = HashChanger.getInstance();

    // Single reusable BusyDialog flashed when the user clicks while a
    // roundtrip is already in flight (created lazily, kept for reuse).
    // The timestamp throttles the flash: rapid clicking during a slow
    // roundtrip would otherwise run a full open/render/close cycle per
    // click without adding any feedback.
    let _busyDialog = null;
    let _busyFlashUntil = 0;

    function applyStoredSizeLimit(viewKey, oModel) {
      if (!oModel) return;
      const limit = AppState.state.viewSizeLimits[viewKey];
      if (limit !== undefined) oModel.setSizeLimit(limit);
    }

    return Controller.extend("z2ui5.controller.View1", {
      // ------------------------------------------------------------------
      // Model change tracking - remembers which /XX/ paths the user edited
      // so the next roundtrip only ships the delta.
      // ------------------------------------------------------------------
      _trackChanges(oModel) {
        // Mark the model as framework-owned: updateModelIfRequired may only
        // reuse models that carry this change tracker.
        oModel._z2ui5Tracked = true;
        oModel.attachPropertyChange((e) => {
          const params = e.getParameters();
          const raw = params.path;
          const ctx = params.context;
          if (!raw) return;
          // Resolve relative paths against the binding context.
          const changedPath =
            ctx && !raw.startsWith("/") ? `${ctx.getPath()}/${raw}` : raw;
          if (changedPath.startsWith("/XX/")) {
            AppState.state.xxChangedPaths.add(changedPath);
          }
        });
        return oModel;
      },

      onAfterRendering() {
        if (AppState.state.oResponse && !AppState.state.oResponse._processed) {
          this._processAfterRendering();
        }
      },

      // Runs once after each roundtrip's view has been rendered, in two
      // named phases: display pending fragments/views, then update the
      // browser history/hash.
      async _processAfterRendering() {
        try {
          const oResponse = AppState.state.oResponse;
          if (oResponse._processed) return;
          oResponse._processed = true;

          const PARAMS = oResponse.PARAMS;
          if (!PARAMS) return;

          await this._displayPendingViews(PARAMS);
          this._updateBrowserHistory(PARAMS, oResponse.ID);
          if (PARAMS.SET_NAV_BACK) history.back();

          Lib.runCallbacks(AppState.state.onAfterRendering);
        } catch (e) {
          Lib.logError("_processAfterRendering: unexpected error", e);
          Server.responseError(e, "Unexpected Error Occurred - App Terminated");
        } finally {
          BusyIndicator.hide();
          AppState.state.isBusy = false;
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
        if (S_VIEW_NEST?.CHECK_DESTROY) this.destroyNestView();
        if (S_VIEW_NEST2?.CHECK_DESTROY) this.destroyNestView2();

        if (S_POPUP?.XML) {
          this.destroyPopup();
          await this.displayFragment(S_POPUP.XML);
        }

        if (!AppState.state.checkNestAfter && S_VIEW_NEST?.XML) {
          this.destroyNestView();
          await this.displayNestedView(S_VIEW_NEST.XML, "NEST");
          AppState.state.checkNestAfter = true;
        }

        if (!AppState.state.checkNestAfter2 && S_VIEW_NEST2?.XML) {
          this.destroyNestView2();
          await this.displayNestedView(S_VIEW_NEST2.XML, "NEST2");
          AppState.state.checkNestAfter2 = true;
        }

        if (S_POPOVER?.XML) {
          this.destroyPopover();
          await this.displayPopover(S_POPOVER.XML, S_POPOVER.OPEN_BY_ID);
        }
      },

      // Phase 2: push the backend-requested URL and update the app-state
      // hash.
      _updateBrowserHistory(PARAMS, ID) {
        try {
          if (PARAMS.SET_PUSH_STATE) {
            const hash = _hashChanger.getHash();
            const newUrl = `${window.location.pathname}${window.location.search}#${hash}${PARAMS.SET_PUSH_STATE}`;
            history.pushState(null, "", newUrl);
          }
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
        const customJs = AppState.state.pendingCustomJs;
        AppState.state.pendingCustomJs = null;
        if (!customJs) return;
        if (Lib.isDestroyed(this)) return;
        for (const item of customJs) {
          Server._runCustomJs(item, this);
        }
      },

      _createViewModel() {
        const data = AppState.state.oResponse?.OVIEWMODEL;
        return this._trackChanges(new JSONModel(data));
      },

      // ------------------------------------------------------------------
      // Display: popups, popovers, nested views, main view
      // ------------------------------------------------------------------

      async displayFragment(xml) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit("POPUP", oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: ViewSlots.getController("POPUP"),
          id: "popupId",
        });
        // The app might have been torn down while the fragment loaded.
        if (!Lib.isAlive(AppState.state.oApp)) {
          oFragment.destroy();
          return;
        }
        oFragment.setModel(oModel);
        ViewSlots.setView("POPUP", oFragment);
        oFragment.open();
      },

      async displayPopover(xml, openById) {
        // No catch-all here on purpose: a malformed-XML load or render
        // failure must propagate to _processAfterRendering and surface the
        // fatal "App Terminated" overlay, exactly like displayFragment and
        // displayNestedView. The explicit returns below stay graceful - they
        // handle expected, non-error conditions (app torn down mid-load, or
        // the openBy anchor not being present), matching the parent-not-found
        // guard in displayNestedView.
        const oModel = this._createViewModel();
        applyStoredSizeLimit("POPOVER", oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: ViewSlots.getController("POPOVER"),
          id: "popoverId",
        });
        if (!Lib.isAlive(AppState.state.oApp)) {
          oFragment.destroy();
          return;
        }
        oFragment.setModel(oModel);

        // Find the control to attach the popover to. We search the main
        // view first, then any open popup / nested views, then the global
        // UI5 control registry as a last resort.
        let oControl =
          ViewSlots.byId("MAIN", openById) ||
          ViewSlots.byId("POPUP", openById) ||
          ViewSlots.byId("NEST", openById) ||
          ViewSlots.byId("NEST2", openById);
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
        ViewSlots.setView("POPOVER", oFragment);
        oFragment.openBy(oControl);
      },

      async displayNestedView(xml, slotKey) {
        const paramKey = ViewSlots.paramByKey(slotKey);
        const oModel = this._createViewModel();
        applyStoredSizeLimit(slotKey, oModel);
        const oView = await XMLView.create({
          definition: xml,
          controller: ViewSlots.getController(slotKey),
          preprocessors: { xml: { models: { template: oModel } } },
        });

        if (!Lib.isAlive(AppState.state.oApp)) {
          oView.destroy();
          return;
        }
        oView.setModel(oModel);

        const nestParams = AppState.state.oResponse?.PARAMS?.[paramKey];
        if (!nestParams) {
          Lib.logError(`displayNestedView: missing PARAMS.${paramKey}`);
          oView.destroy();
          return;
        }
        const { ID, METHOD_DESTROY, METHOD_INSERT } = nestParams;

        const oParent = ViewSlots.byId("MAIN", ID);
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
        ViewSlots.setView(slotKey, oView);
      },

      // Thin wrappers around the shared slot teardown in ViewSlots, kept
      // because existing apps may call them via custom JS.
      destroyPopup() {
        ViewSlots.destroy("POPUP");
      },
      destroyPopover() {
        ViewSlots.destroy("POPOVER");
      },
      destroyNestView() {
        ViewSlots.destroy("NEST");
      },
      destroyNestView2() {
        ViewSlots.destroy("NEST2");
      },
      destroyView() {
        ViewSlots.destroy("MAIN");
      },

      // ------------------------------------------------------------------
      // eF = "event frontend": handles frontend-only events triggered by
      // the backend response, without a roundtrip. The name is part of the
      // protocol - backend-generated view XML binds events to eB/eF - and
      // must not be renamed. The individual handlers live in
      // core/FrontendAction.js.
      // ------------------------------------------------------------------
      eF(...args) {
        FrontendAction.execute(this, args);
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
        // the user gets visual feedback instead of a silent click - at most
        // once per second, further clicks inside that window are ignored.
        if (AppState.state.isBusy && !ignoreBusy) {
          if (Date.now() >= _busyFlashUntil) {
            _busyFlashUntil = Date.now() + 1000;
            if (!_busyDialog) _busyDialog = new BusyDialog();
            _busyDialog.open();
            queueMicrotask(() => _busyDialog.close());
          }
          return;
        }

        // A new roundtrip overrides any pending timer - timers that fired
        // already removed themselves before calling eB, so this only cancels
        // timers that are still waiting.
        for (const key in AppState.state.timers) {
          clearTimeout(AppState.state.timers[key]);
          delete AppState.state.timers[key];
        }

        AppState.state.isBusy = true;
        BusyIndicator.show();

        // The request body is built locally and handed explicitly through
        // Server.roundtrip/readHttp. It is mirrored to AppState.state.oBody right
        // away so onBeforeRoundtrip hooks and the debug tool see it.
        const oBody = { VIEWNAME: "MAIN" };
        AppState.state.oBody = oBody;

        // Decide which view's model holds the data we need to send back. The
        // mapping is: main app controller -> main view, popup controller ->
        // popup view, etc.
        const oModel = this._pickModelForRoundtrip(useMainModel, oBody);

        Lib.runCallbacks(AppState.state.onBeforeRoundtrip);

        // If the user edited /XX/ paths, send only the delta to keep the
        // payload small.
        if (oModel && AppState.state.xxChangedPaths.size > 0) {
          const data = oModel.getData();
          const xx = data?.XX;
          if (xx) {
            oBody.XX = Lib.buildDeltaFromPaths(
              AppState.state.xxChangedPaths,
              xx,
            );
          }
        }

        oBody.ID = AppState.state.oResponse?.ID;
        // Arguments travel as raw JSON values - the request body is
        // serialized exactly once in Server.readHttp. Object arguments are
        // turned into JSON strings by the backend when it fills
        // T_EVENT_ARG, so apps keep receiving them as strings; stringifying
        // them here as well would encode (and escape) the payload twice.
        oBody.ARGUMENTS = args.slice();

        Server.roundtrip(oBody);
        Lib.runCallbacks(AppState.state.onAfterRoundtrip);
      },

      _pickModelForRoundtrip(useMainModel, oBody) {
        // useMainModel forces use of the main view's model even when called
        // from a popup/popover controller.
        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);
        if (!slotKey) return undefined;

        if (slotKey === "MAIN") {
          const sView = AppState.state.oResponse?.PARAMS?.S_VIEW;
          if (sView?.SWITCH_DEFAULT_MODEL_PATH) {
            return ViewSlots.getView("MAIN")?.getModel("http");
          }
          return ViewSlots.getView("MAIN")?.getModel();
        }

        // Nested views report their slot as VIEW in S_FRONT so the backend
        // routes the event to the right app instance.
        if (slotKey === "NEST" || slotKey === "NEST2") {
          oBody.VIEWNAME = slotKey;
        }
        return ViewSlots.getView(slotKey)?.getModel();
      },

      // Refresh a slot's model when the response signals an update for it
      // (CHECK_UPDATE_MODEL - the data-only roundtrip every app triggers
      // via client->view_model_update( )).
      updateModelIfRequired(slotKey) {
        const params = AppState.state.oResponse?.PARAMS;
        const slotParams = params?.[ViewSlots.paramByKey(slotKey)];
        if (!slotParams?.CHECK_UPDATE_MODEL) return;

        const oView = ViewSlots.getView(slotKey);
        if (!oView) return;

        // Reuse the existing model whenever it is ours: setData() keeps the
        // view's bindings alive and only refreshes what changed, while a new
        // model + setModel() destroys and recreates every binding - measured
        // ~3x slower with all values changed and ~150x slower when little
        // changed (see node/tests-examples/modelUpdate.bench.spec.js).
        const existing = oView.getModel();
        if (existing?._z2ui5Tracked) {
          applyStoredSizeLimit(slotKey, existing);
          existing.setData(AppState.state.oResponse?.OVIEWMODEL);
          return;
        }

        // The slot's default model is not framework-owned (e.g. an
        // ODataModel via SWITCH_DEFAULT_MODEL_PATH): keep the previous
        // behavior and bind a fresh JSON model.
        const oModel = this._createViewModel();
        applyStoredSizeLimit(slotKey, oModel);
        oView.setModel(oModel);
      },

      // Replace the main app view with the XML coming from the backend.
      async displayView(xml, viewModel) {
        const oViewModel = this._trackChanges(new JSONModel(viewModel));

        const sView = AppState.state.oResponse?.PARAMS?.S_VIEW;
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

        const oView = await XMLView.create({
          definition: xml,
          models: oModel,
          controller: ViewSlots.getController("MAIN"),
          id: "mainView",
          preprocessors: { xml: { models: { template: oViewModel } } },
        });

        // Guard against the app being destroyed during the await above.
        if (!Lib.isAlive(AppState.state.oApp)) {
          oView.destroy();
          if (switchPath) oModel.destroy();
          return;
        }

        ViewSlots.setView("MAIN", oView);
        oView.setModel(AppState.state.oDeviceModel, "device");
        if (switchPath) oView.setModel(oViewModel, "http");
        AppState.state.oApp.removeAllPages();
        AppState.state.oApp.insertPage(oView);
      },
    });
  },
);
