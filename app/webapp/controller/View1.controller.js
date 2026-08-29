// The central view controller. One instance serves each of the five view
// slots (main view, two nested views, popup, popover - see
// core/ViewSlots.js). It carries the protocol entry points the backend binds
// events to (eB, eBP, eF), builds the request for backend events and runs
// the response's two action phases. The display machinery behind those
// actions lives in core/actions/Slots.js.
sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/BusyIndicator",
    "sap/m/MessageBox",
    "z2ui5/core/Server",
    "z2ui5/core/Lib",
    "z2ui5/core/FrontendAction",
    "z2ui5/core/actions/Slots",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/Router",
    "z2ui5/core/AppState",
  ],
  (
    Controller,
    BusyIndicator,
    MessageBox,
    Server,
    Lib,
    FrontendAction,
    Slots,
    ViewSlots,
    Router,
    AppState,
  ) => {
    "use strict";

    return Controller.extend("z2ui5.controller.View1", {
      onAfterRendering() {
        // _processAfterRendering re-checks _processed itself - only the
        // null check is load-bearing here
        if (AppState.state.oResponse) this._processAfterRendering();
      },

      // Runs once after each roundtrip's view has been rendered, in two
      // named phases: display pending fragments/views, then update the
      // browser history/hash. `reqSeq` is the stamp of the request the
      // response being processed belongs to (Server.responseSuccess); the
      // onAfterRendering entry above has none and falls back to the newest.
      async _processAfterRendering(reqSeq) {
        // The claim happens BEFORE the try: the MAIN rebuild is a system
        // action now, so slots render (and re-enter here via their own
        // onAfterRendering - possibly with a NESTED controller as `this`)
        // while phase 1 is still awaiting. A losing entry must return here
        // and never reach the finally, which would hide the busy state and
        // consume the pending custom JS mid-phase, on the wrong controller.
        // The record is also pinned for the finally: the shared
        // AppState.state.oResponse may point at a newer response by then.
        const oResponse = AppState.state.oResponse;
        if (!oResponse || oResponse._processed) return;
        oResponse._processed = true;
        try {
          // An APP SWITCH kills the two standalone slots implicitly: they
          // live outside the MAIN control tree, so they do not fall with
          // the page the new app renders - and the switch is visible right
          // here (the response names its app), so no destroy action travels
          // for it. BEFORE the system actions, so the new app's own
          // popup_display still opens afterwards. (A hop to another
          // instance of the SAME class is invisible here - the backend
          // queues the teardown for exactly that case.)
          const state = AppState.state;
          if (oResponse.APP && state.renderedApp !== oResponse.APP) {
            if (state.renderedApp) {
              ViewSlots.destroy("POPUP");
              ViewSlots.destroy("POPOVER");
            }
            // the leaving app's keyboard shortcuts die with it - the new app
            // registers its own (actions/Shortcuts documents this reset) -
            // and so do its tree-expansion snapshots, which are keyed by the
            // LOCAL tree_id and would otherwise leak into a same-named tree
            // of the next app
            state.shortcuts = {};
            state.treeStates = {};
            state.renderedApp = oResponse.APP;
          }
          // No early return on an empty action list: a response without any
          // action still gets its model push, its hash sync and the
          // after-render hooks below - with the ROUTER and updateModel
          // actions derived/gated away, an action-free response is the
          // COMMON case now, not the exception.
          if (oResponse.S_ACTION) {
            // Stamp of the request this response belongs to: every await in
            // the display phase re-checks it, so a response superseded by a
            // parallel request (check_allow_multi_req, Back/Forward restore)
            // never attaches popups/nested views the backend no longer knows.
            const seq = reqSeq ?? Server._requestSeq;
            await this._runSystemActions(oResponse, seq);
          }
          // The app may have been torn down (reset / FLP re-launch) while the
          // pending views loaded; don't mutate history or fire onAfterRendering
          // hooks against a dead app (the custom-JS phase below guards the same
          // way via isDestroyed). And a response a PARALLEL request replaced
          // mid-phase must not push its model or write its ids into the URL -
          // the push would read the NEWER response's data into this stale
          // render, and the sync would mix this draft id with the newer app.
          // The newer response runs its own push and sync.
          if (Lib.isDestroyed(this) || oResponse !== AppState.state.oResponse) {
            return;
          }
          // A MODEL key in the response IS the model push - run it after the
          // displays, so a slot built in this same roundtrip is filled before
          // it is pushed to. This reaches what a fresh build alone does not:
          // a nested view re-displayed without its MAIN view (it inherits the
          // MAIN model by UI5 propagation) and a popup left open across a
          // roundtrip that rebuilt no view (one that DOES rebuild MAIN takes
          // the standalone slots down with it - see actions/Slots).
          if (oResponse.MODELPRESENT) Slots.action("updateModel");
          // Phase 2: ONE history/hash sync per response. A ROUTER action only
          // travels when the roundtrip carries nav intent - its options were
          // stashed by the ControlCall hook. The plain response still syncs,
          // so hash routing and app-state tracking follow every new draft id.
          Router.sync({
            ...(oResponse._routerOptions || {}),
            id: oResponse.ID,
          });
          Lib.runCallbacks(AppState.state.onAfterRendering);
        } catch (e) {
          Lib.logError("_processAfterRendering: unexpected error", e);
          // Server decides which overlay this failure gets: a view that could
          // not load a sap.com module on openui5 shows the SDK hint, anything
          // else the fatal overlay (see Server.showRenderError).
          Server.showRenderError(
            e,
            "Unexpected Error Occurred - App Terminated",
          );
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
      // may well be about the slot it is still building. The action context
      // carries the request stamp (so the slot displays can discard a build
      // a newer parallel request superseded) and the response record (so the
      // ROUTER action stashes its options on the response they belong to).
      async _runSystemActions(oResponse, seq) {
        const systemJs = oResponse?.S_ACTION?.T_SYSTEM;
        if (!systemJs) return;
        for (const item of systemJs) {
          // Stop the whole phase once a newer request superseded this
          // response - the remaining actions would tear down or overwrite
          // what the newer response builds (the per-display guards check
          // the same stamp, but the synchronous teardowns do not).
          if (Lib.isDestroyed(this) || seq !== Server._requestSeq) return;
          await FrontendAction.runSystem(item, this, {
            seq,
            response: oResponse,
          });
        }
      },

      // Execute the follow-up JS snippets stashed by Server.responseSuccess.
      // Runs once per roundtrip, after the view has rendered.
      _runPendingCustomJs(oResponse) {
        const customJs = oResponse?._pendingCustomJs;
        if (oResponse) oResponse._pendingCustomJs = null;
        if (!customJs) return;
        if (Lib.isDestroyed(this)) return;
        for (const item of customJs) {
          FrontendAction.runCustom(item, this);
        }
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
      // must not be renamed. The individual handlers live in the domain
      // modules under core/actions/ (merged in core/FrontendAction.js).
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
      // e.g. `$controller.textPath(${$parameters>/item})` on a tree or list
      // item -> "Create New Site > Official Store". The parent-chain walk
      // happens on the live control tree, so no binding path can express it;
      // the separator defaults to " > ".
      //
      // It stops at the first ancestor without getText, which for a sap.m.Menu
      // item is the internal MenuWrapper one hop up - so a MENU is the one
      // example not to reach for here; see getTextPath in core/Lib.js.
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
        // (set in Slots.trackChanges), so onBeforeRoundtrip hooks that mark
        // paths dirty (e.g. the Scrolling control) must have run above first.
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
          return Slots.resolveTrackedModel(oView);
        }

        // Popup/popover are standalone and return their own (default) model.
        return oView.getModel();
      },
    });
  },
);
