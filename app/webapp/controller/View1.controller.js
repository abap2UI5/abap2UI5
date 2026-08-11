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
    "z2ui5/core/Server",
    "sap/ui/model/odata/v2/ODataModel",
    "z2ui5/core/Router",
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
    Server,
    ODataModel,
    Router,
    Lib,
    FrontendAction,
    ViewSlots,
    AppState,
  ) => {
    "use strict";

    function applyStoredSizeLimit(viewKey, oModel) {
      if (!oModel) return;
      // For the root slots (MAIN/NEST/NEST2) this is the max limit across them,
      // since they share this one model; popup/popover get their own limit.
      const limit = Lib.effectiveSizeLimit(
        AppState.state.viewSizeLimits,
        viewKey,
      );
      if (limit !== undefined) oModel.setSizeLimit(limit);
    }

    return Controller.extend("z2ui5.controller.View1", {
      // ------------------------------------------------------------------
      // Model change tracking - remembers which model paths the user edited
      // so the next roundtrip only ships the delta.
      // ------------------------------------------------------------------
      _trackChanges(oModel) {
        // Mark the model as framework-owned: updateModelIfRequired may only
        // reuse models that carry this change tracker.
        oModel._z2ui5Tracked = true;
        // Edited paths are tracked PER MODEL, not in one shared set: the main
        // view and a popup/popover each have their own JSON model, and a
        // roundtrip ships only the picked model's own edits. A single shared
        // set would build the delta of one model against another's data (a
        // path missing there serializes as `undefined` and clears the field
        // on the backend) and would drop the other model's still-unsent edits.
        oModel._z2ui5ChangedPaths = new Set();
        oModel.attachPropertyChange((e) => {
          const params = e.getParameters();
          const raw = params.path;
          const ctx = params.context;
          if (!raw) return;
          // Resolve relative paths against the binding context.
          const changedPath =
            ctx && !raw.startsWith("/") ? `${ctx.getPath()}/${raw}` : raw;
          if (changedPath.startsWith("/")) {
            oModel._z2ui5ChangedPaths.add(changedPath);
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
        // Hoisted out of the try block: the finally below must run the
        // follow-up JS of exactly THIS response. Re-reading the shared
        // AppState.state.oResponse there would - after a parallel request
        // replaced it during the awaits - consume (and clear) the newer
        // response's snippets before its own render.
        let oResponse;
        try {
          oResponse = AppState.state.oResponse;
          if (oResponse._processed) return;
          oResponse._processed = true;

          const PARAMS = oResponse.PARAMS;
          if (!PARAMS) return;

          // Stamp of the request this response belongs to: every await in
          // the display phase re-checks it, so a response superseded by a
          // parallel request (check_allow_multi_req, Back/Forward restore)
          // never attaches popups/nested views the backend no longer knows.
          const seq = Server._requestSeq;
          await this._runSystemActions(oResponse, seq);
          // The app may have been torn down (reset / FLP re-launch) while the
          // pending views loaded; don't mutate history or fire onAfterRendering
          // hooks against a dead app (the custom-JS phase below guards the same
          // way via isDestroyed).
          if (Lib.isDestroyed(this)) return;
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
          this._runPendingCustomJs(oResponse);
        }
      },

      // Phase 1: run the SYSTEM actions - the framework's own view-lifecycle
      // calls (destroy a slot, display one, push the model into it), in the
      // order the backend queued them. They run BEFORE anything an app
      // queued, and one at a time: a display is async, and the next action
      // may well be about the slot it is still building.
      async _runSystemActions(oResponse, seq) {
        const systemJs = oResponse?.PARAMS?.S_FOLLOW_UP_ACTION?.SYSTEM_JS;
        if (!systemJs) return;
        // the slot handlers take the request stamp from here rather than
        // through the generic action signature, which carries only the
        // payload the backend sent
        this._systemSeq = seq;
        try {
          for (const item of systemJs) {
            if (Lib.isDestroyed(this)) return;
            await Server._runSystemJs(item, this);
          }
        } finally {
          this._systemSeq = undefined;
        }
      },

      // The VIEW_SLOTS target of a system action. destroy is ViewSlots' own
      // method; display and updateModel live here, because loading a fragment
      // and owning the model is the controller's job.
      slotAction(method, slotKey, mOptions) {
        const seq = this._systemSeq;
        if (method === "destroy") {
          ViewSlots.destroy(slotKey);
          return undefined;
        }
        if (method === "updateModel") {
          this.updateModelIfRequired(slotKey);
          return undefined;
        }
        // display: the slot is rebuilt from scratch, so whatever is open in
        // it goes first - the same destroy-then-open the slot protocol did.
        ViewSlots.destroy(slotKey);
        const xml = mOptions.xml;
        if (slotKey === "POPUP") return this.displayFragment(xml, seq);
        if (slotKey === "POPOVER") {
          return this.displayPopover(xml, mOptions.openById, seq);
        }
        return this.displayNestedView(
          xml,
          slotKey,
          {
            ID: mOptions.id,
            METHOD_INSERT: mOptions.methodInsert,
            METHOD_DESTROY: mOptions.methodDestroy,
          },
          seq,
        );
      },

      // eFS = "event frontend, system": the SYSTEM phase counterpart of eF.
      // It returns the handler's result so an async display can be awaited,
      // and lets errors propagate - see FrontendAction.executeSystem.
      eFS(...args) {
        return FrontendAction.executeSystem(this, args);
      },

      // Phase 2: keep the URL in sync with what was rendered - the hash
      // route of the running app, plus the legacy push-state / app-state
      // hashes. core/Router owns all of it (and the FLP shell-hash rules).
      _updateBrowserHistory(PARAMS, ID) {
        Router.sync(PARAMS, ID);
      },

      // Execute the follow-up JS snippets stashed by Server.responseSuccess.
      // Runs once per roundtrip, after the view has rendered.
      _runPendingCustomJs(oResponse) {
        const customJs = oResponse?._pendingCustomJs;
        if (oResponse) oResponse._pendingCustomJs = null;
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

      // Shared load path of the two fragment slots (popup, popover): create
      // the slot's own JSON model, load the fragment and attach the model.
      // Returns null when the app was torn down while the fragment loaded or a
      // newer request superseded this response - we must not open a dialog the
      // backend no longer knows about.
      async _loadSlotFragment(slotKey, fragmentId, xml, seq) {
        const oModel = this._createViewModel();
        applyStoredSizeLimit(slotKey, oModel);
        const oFragment = await Fragment.load({
          definition: xml,
          controller: ViewSlots.getController(slotKey),
          id: fragmentId,
        });
        if (!Lib.isAlive(AppState.state.oApp) || this._isSuperseded(seq)) {
          oFragment.destroy();
          return null;
        }
        oFragment.setModel(oModel);
        return oFragment;
      },

      async displayFragment(xml, seq) {
        const oFragment = await this._loadSlotFragment(
          "POPUP",
          "popupId",
          xml,
          seq,
        );
        if (!oFragment) return;
        // The shared device + message models are attached inside
        // ViewSlots.setView (the single funnel), so error paths that
        // destroy a view without reaching setView never register it.
        ViewSlots.setView("POPUP", oFragment);
        oFragment.open();
      },

      // True when this response was superseded by a newer request while an
      // async view build was awaiting (undefined seq = no check, for
      // custom-JS callers of the display helpers).
      _isSuperseded(seq) {
        return seq !== undefined && seq !== Server._requestSeq;
      },

      async displayPopover(xml, openById, seq) {
        // No catch-all here on purpose: a malformed-XML load or render
        // failure must propagate to _processAfterRendering and surface the
        // fatal "App Terminated" overlay, exactly like displayFragment and
        // displayNestedView. The explicit returns below stay graceful - they
        // handle expected, non-error conditions (app torn down mid-load, or
        // the openBy anchor not being present), matching the parent-not-found
        // guard in displayNestedView.
        const oFragment = await this._loadSlotFragment(
          "POPOVER",
          "popoverId",
          xml,
          seq,
        );
        if (!oFragment) return;

        // Find the control to attach the popover to: any open slot first,
        // then the global UI5 control registry as a last resort.
        const oControl = ViewSlots.resolveById(openById);

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

      async displayNestedView(xml, slotKey, nestParamsIn, seq) {
        const paramKey = ViewSlots.paramByKey(slotKey);
        // Nested views do NOT create their own model. They are inserted into
        // the MAIN control tree below and inherit its default JSON model via
        // UI5 model propagation, so every view binds against the same data with
        // one change tracker and one refresh per roundtrip - no duplicate
        // models pointing at the same data. The model passed to the XML
        // preprocessor here only feeds {template>...} bindings at build time;
        // it is the MAIN view's JSON model (the named "http" model when
        // SWITCH_DEFAULT_MODEL_PATH moved OData into the default slot, otherwise
        // the default model), mirroring displayView's template model.
        const oMainView = ViewSlots.getView("MAIN");
        const oTemplateModel =
          oMainView?.getModel("http") ?? oMainView?.getModel();
        const oView = await XMLView.create({
          definition: xml,
          controller: ViewSlots.getController(slotKey),
          preprocessors: { xml: { models: { template: oTemplateModel } } },
        });

        if (!Lib.isAlive(AppState.state.oApp) || this._isSuperseded(seq)) {
          oView.destroy();
          return;
        }

        // Prefer the params passed by _displayPendingViews: they belong to
        // the same response as the XML. Re-reading the live global here
        // would mix this response's view with a newer response's parent id
        // and insert/destroy methods. The global stays as fallback for
        // custom-JS callers.
        const nestParams =
          nestParamsIn ?? AppState.state.oResponse?.PARAMS?.[paramKey];
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

        // METHOD_DESTROY is optional: only call it when the app asked for a
        // parent teardown method. An empty value used to reach oParent[""]()
        // and throw on every render (e.g. app 065 passes only method_insert).
        if (METHOD_DESTROY) {
          try {
            oParent[METHOD_DESTROY]();
          } catch (e) {
            Lib.logError(
              `displayNestedView: parent destroy method '${METHOD_DESTROY}' failed`,
              e,
            );
          }
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
      // eBP = "event backend, prevent default": cancels the control's
      // built-in default for this event and then round-trips exactly like
      // eB. The backend emits it (instead of eB) for an event registered
      // with s_ctrl-check_prevent_default, passing $event as the first
      // argument - preventDefault() only works synchronously inside the
      // handler, so it cannot be a follow-up action from the response.
      // Example: sap.tnt NavigationListItem.press, where cancelling the
      // default suppresses the item selection and leaves the decision to
      // the backend. The name is part of the protocol - do not rename it.
      //
      // The second argument is the veto CONDITION, so the decision can be
      // made per firing instead of per wire: s_ctrl-check_prevent_default
      // sends the constant true, s_ctrl-prevent_default_expr sends an
      // expression UI5 resolves on each firing (e.g. "is this the one column
      // that must not be resized?"). Everything after it is the eB payload.
      // ------------------------------------------------------------------
      eBP(oEvent, bVeto, ...args) {
        // guard the call: a malformed wire (no $event) must still round-trip
        if (bVeto && typeof oEvent?.preventDefault === "function") {
          oEvent.preventDefault();
        }
        this.eB(...args);
      },

      // Ancestor-text breadcrumb of a control resolved in an event argument,
      // e.g. `$controller.textPath(${$parameters>/item})` on a menu's
      // itemSelected -> "Create New Site > Official Store". The parent-chain
      // walk happens on the live control tree, so no binding path can express
      // it; the separator defaults to " > ".
      textPath(oControl, sSeparator) {
        return Lib.getTextPath(oControl, sSeparator);
      },

      // ------------------------------------------------------------------
      // eB = "event backend": triggers a backend roundtrip with arguments.
      // The name is part of the protocol - backend-generated view XML binds
      // events to eB/eF - and must not be renamed.
      //
      // args[0] is the event array built by the backend (get_event):
      //   [0] event name
      //   [1] reserved placeholder, always false
      //   [2] "ignore busy" flag - background events (e.g. timers) skip the
      //       busy guard below
      //   [3] "use main view model" flag - events fired from a popup or
      //       popover controller that still target the main app's model;
      //       not emitted by the framework today, only by custom JS
      // ------------------------------------------------------------------
      eB(...args) {
        const [, , ignoreBusy, useMainModel] = args[0];

        if (!navigator.onLine) {
          MessageBox.alert(
            "No internet connection! Please reconnect to the server and try again.",
          );
          return;
        }

        // A roundtrip is already in flight and this event's keystroke/click is
        // dropped. Surface the global busy indicator right away (0 delay)
        // instead of a separate, transient BusyDialog: it is the exact same
        // overlay the in-flight roundtrip hides on completion, so the user sees
        // one steady indicator until the response lands - not a modal flashing
        // in and straight back out over the (1s-delayed) global one. show() is
        // idempotent, so repeated drops during the same roundtrip are cheap.
        if (AppState.state.isBusy && !ignoreBusy) {
          BusyIndicator.show(0);
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
        // away so onBeforeRoundtrip hooks and the developer tools see it.
        const oBody = {};
        AppState.state.oBody = oBody;

        // Decide which view's model holds the data we need to send back. The
        // mapping is: main app controller -> main view, popup controller ->
        // popup view, etc.
        const oModel = this._pickModelForRoundtrip(useMainModel);

        Lib.runCallbacks(AppState.state.onBeforeRoundtrip);

        // If the user edited model paths, send only the delta to keep the
        // payload small. The edited paths live on the picked model itself
        // (set in _trackChanges), so onBeforeRoundtrip hooks that mark paths
        // dirty (e.g. the Scrolling control) must have run above first.
        const changedPaths = oModel?._z2ui5ChangedPaths;
        if (oModel && changedPaths?.size > 0) {
          const data = oModel.getData();
          if (data) {
            oBody.MODEL = Lib.buildDeltaFromPaths(changedPaths, data);
          }
        }
        // Remember which model this request carried so the winning response
        // clears exactly its edits (Server.readHttp) - a stale response clears
        // nothing, and edits in other models stay pending for their own send.
        AppState.state.oSentModel = oModel;

        oBody.ID = AppState.state.oResponse?.ID;
        // Arguments travel as raw JSON values - the request body is
        // serialized exactly once in Server.readHttp. Object arguments are
        // turned into JSON strings by the backend when it fills
        // T_EVENT_ARG, so apps keep receiving them as strings; stringifying
        // them here as well would encode (and escape) the payload twice.
        // Control-valued arguments are marshalled into plain data first (see
        // Lib.normalizeEventArgs): a UI5 event parameter is often a control or
        // an array of controls, and JSON.stringify throws on the circular
        // parent/aggregation graph of a ManagedObject. Everything else passes
        // through untouched. normalizeEventArgs returns a fresh array, which
        // is what Server.roundtrip needs - it mutates ARGUMENTS via shift and
        // must not reach this call's own rest-parameter array.
        oBody.ARGUMENTS = Lib.normalizeEventArgs(args);

        Server.roundtrip(oBody);
        Lib.runCallbacks(AppState.state.onAfterRoundtrip);
      },

      // The framework-owned JSON model on a slot's view: the DEFAULT model
      // normally, but the NAMED "http" model when SWITCH_DEFAULT_MODEL_PATH put
      // an OData model in the default slot. Returns undefined when neither model
      // is ours (marked by _z2ui5Tracked).
      _resolveTrackedModel(oView) {
        const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
        return isOurs(oView.getModel()) ?? isOurs(oView.getModel("http"));
      },

      _pickModelForRoundtrip(useMainModel) {
        // useMainModel forces use of the main view's model even when called
        // from a popup/popover controller.
        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);
        if (!slotKey) return undefined;

        const oView = ViewSlots.getView(slotKey);
        if (!oView) return undefined;

        // MAIN and its nested views (NEST/NEST2) share one framework-owned
        // JSON model, so a nested-slot event must resolve the tracked model
        // (not the propagated OData default, which has no getData()) or the
        // edit is silently dropped. The data and changedPaths delta are shared
        // across the root slots, so any of them yields the same model.
        if (Lib.isRootModelSlot(slotKey)) {
          return this._resolveTrackedModel(oView);
        }

        // Popup/popover are standalone and return their own (default) model.
        return oView.getModel();
      },

      // Refresh a slot's model when the response signals an update for it
      // (CHECK_UPDATE_MODEL - the data-only roundtrip every app triggers
      // via client->view_model_update( )).
      // Only the three model-owning slots ever carry the flag: MAIN owns the
      // root model, POPUP/POPOVER own their own. NEST/NEST2 are inserted into
      // the MAIN control tree and inherit its model by propagation, so the
      // backend has no CHECK_UPDATE_MODEL for them at all and
      // nest_view_model_update( ) refreshes MAIN instead - which is why this
      // can setData unconditionally without refreshing one shared model twice.
      // Push the response's model into an open slot. The backend decides
      // WHICH slots by queuing one updateModel system action per model-owning
      // slot; naming a slot that is not open is free and ends here.
      updateModelIfRequired(slotKey) {
        const oView = ViewSlots.getView(slotKey);
        if (!oView) return;

        // Reuse the existing model whenever it is ours: setData() keeps the
        // view's bindings alive and only refreshes what changed, while a new
        // model + setModel() destroys and recreates every binding - measured
        // ~3x slower with all values changed and ~150x slower when little
        // changed (see node/tests-examples/modelUpdate.bench.spec.js).
        // Never overwrite an OData default (switch mode) with a fresh JSON model.
        const tracked = this._resolveTrackedModel(oView);
        if (tracked) {
          applyStoredSizeLimit(slotKey, tracked);
          tracked.setData(AppState.state.oResponse?.OVIEWMODEL);
          return;
        }

        // No framework-owned model on this slot at all: bind a fresh default
        // JSON model (keeps the previous behavior for that edge case).
        const oModel = this._createViewModel();
        applyStoredSizeLimit(slotKey, oModel);
        oView.setModel(oModel);
      },

      // Replace the main app view with the XML coming from the backend.
      async displayView(xml, viewModel, reqSeq) {
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

        // oModel covers oViewModel too when they are the same object (no
        // switchPath); with an OData default model both must go.
        const discardBuild = () => {
          oView.destroy();
          oModel.destroy();
          if (switchPath) oViewModel.destroy();
        };

        // Guard against the app being destroyed during the await above.
        if (!Lib.isAlive(AppState.state.oApp)) {
          discardBuild();
          return;
        }

        // A newer parallel request (check_allow_multi_req) superseded this one
        // while XMLView.create was awaiting - discard this rebuild instead of
        // letting an out-of-order resolve overwrite the newer view. Last-write
        // wins by request order, not by which create() happened to resolve last.
        // Only discard when a newer view actually took the slot: if the
        // superseding response was data-only, dropping this build too would
        // leave the app permanently blank - a slightly stale view is the
        // better outcome then.
        if (
          reqSeq !== undefined &&
          reqSeq !== Server._requestSeq &&
          ViewSlots.getView("MAIN")
        ) {
          discardBuild();
          return;
        }

        ViewSlots.setView("MAIN", oView);
        if (switchPath) oView.setModel(oViewModel, "http");
        AppState.state.oApp.removeAllPages();
        AppState.state.oApp.insertPage(oView);
      },
    });
  },
);
