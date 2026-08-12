* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
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
             `// core/ViewSlots.js). It carries the protocol entry points the backend binds` && |\n| &&
             `// events to (eB, eBP, eF), builds the request for backend events and runs` && |\n| &&
             `// the response's two action phases. The display machinery behind those` && |\n| &&
             `// actions lives in core/actions/Slots.js.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/mvc/Controller",` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/m/MessageBox",` && |\n| &&
             `    "z2ui5/core/Server",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/FrontendAction",` && |\n| &&
             `    "z2ui5/core/actions/Slots",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/Router",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    Controller,` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    MessageBox,` && |\n| &&
             `    Server,` && |\n| &&
             `    Lib,` && |\n| &&
             `    FrontendAction,` && |\n| &&
             `    Slots,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    Router,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    return Controller.extend("z2ui5.controller.View1", {` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        // _processAfterRendering re-checks _processed itself - only the` && |\n| &&
             `        // null check is load-bearing here` && |\n| &&
             `        if (AppState.state.oResponse) this._processAfterRendering();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Runs once after each roundtrip's view has been rendered, in two` && |\n| &&
             `      // named phases: display pending fragments/views, then update the` && |\n| &&
             `      // browser history/hash. ``reqSeq`` is the stamp of the request the` && |\n| &&
             `      // response being processed belongs to (Server.responseSuccess); the` && |\n| &&
             `      // onAfterRendering entry above has none and falls back to the newest.` && |\n| &&
             `      async _processAfterRendering(reqSeq) {` && |\n| &&
             `        // The claim happens BEFORE the try: the MAIN rebuild is a system` && |\n| &&
             `        // action now, so slots render (and re-enter here via their own` && |\n| &&
             `        // onAfterRendering - possibly with a NESTED controller as ``this``)` && |\n| &&
             `        // while phase 1 is still awaiting. A losing entry must return here` && |\n| &&
             `        // and never reach the finally, which would hide the busy state and` && |\n| &&
             `        // consume the pending custom JS mid-phase, on the wrong controller.` && |\n| &&
             `        // The record is also pinned for the finally: the shared` && |\n| &&
             `        // AppState.state.oResponse may point at a newer response by then.` && |\n| &&
             `        const oResponse = AppState.state.oResponse;` && |\n| &&
             `        if (!oResponse || oResponse._processed) return;` && |\n| &&
             `        oResponse._processed = true;` && |\n| &&
             `        try {` && |\n| &&
             `          // An APP SWITCH kills the two standalone slots implicitly: they` && |\n| &&
             `          // live outside the MAIN control tree, so they do not fall with` && |\n| &&
             `          // the page the new app renders - and the switch is visible right` && |\n| &&
             `          // here (the response names its app), so no destroy action travels` && |\n| &&
             `          // for it. BEFORE the system actions, so the new app's own` && |\n| &&
             `          // popup_display still opens afterwards. (A hop to another` && |\n| &&
             `          // instance of the SAME class is invisible here - the backend` && |\n| &&
             `          // queues the teardown for exactly that case.)` && |\n| &&
             `          const state = AppState.state;` && |\n| &&
             `          if (oResponse.APP && state.renderedApp !== oResponse.APP) {` && |\n| &&
             `            if (state.renderedApp) {` && |\n| &&
             `              ViewSlots.destroy("POPUP");` && |\n| &&
             `              ViewSlots.destroy("POPOVER");` && |\n| &&
             `            }` && |\n| &&
             `            // the leaving app's keyboard shortcuts die with it - the new app` && |\n| &&
             `            // registers its own (actions/Shortcuts documents this reset) -` && |\n| &&
             `            // and so do its tree-expansion snapshots, which are keyed by the` && |\n| &&
             `            // LOCAL tree_id and would otherwise leak into a same-named tree` && |\n| &&
             `            // of the next app` && |\n| &&
             `            state.shortcuts = {};` && |\n| &&
             `            state.treeStates = {};` && |\n| &&
             `            state.renderedApp = oResponse.APP;` && |\n| &&
             `          }` && |\n| &&
             `          // No early return on an empty action list: a response without any` && |\n| &&
             `          // action still gets its model push, its hash sync and the` && |\n| &&
             `          // after-render hooks below - with the ROUTER and updateModel` && |\n| &&
             `          // actions derived/gated away, an action-free response is the` && |\n| &&
             `          // COMMON case now, not the exception.` && |\n| &&
             `          if (oResponse.S_ACTION) {` && |\n| &&
             `            // Stamp of the request this response belongs to: every await in` && |\n| &&
             `            // the display phase re-checks it, so a response superseded by a` && |\n| &&
             `            // parallel request (check_allow_multi_req, Back/Forward restore)` && |\n| &&
             `            // never attaches popups/nested views the backend no longer knows.` && |\n| &&
             `            const seq = reqSeq ?? Server._requestSeq;` && |\n| &&
             `            await this._runSystemActions(oResponse, seq);` && |\n| &&
             `          }` && |\n| &&
             `          // The app may have been torn down (reset / FLP re-launch) while the` && |\n| &&
             `          // pending views loaded; don't mutate history or fire onAfterRendering` && |\n| &&
             `          // hooks against a dead app (the custom-JS phase below guards the same` && |\n| &&
             `          // way via isDestroyed). And a response a PARALLEL request replaced` && |\n| &&
             `          // mid-phase must not push its model or write its ids into the URL -` && |\n| &&
             `          // the push would read the NEWER response's data into this stale` && |\n| &&
             `          // render, and the sync would mix this draft id with the newer app.` && |\n| &&
             `          // The newer response runs its own push and sync.` && |\n| &&
             `          if (Lib.isDestroyed(this) || oResponse !== AppState.state.oResponse) {` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          // A MODEL key in the response IS the model push - run it after the` && |\n| &&
             `          // displays, so a slot built in this same roundtrip is filled before` && |\n| &&
             `          // it is pushed to. This reaches what a fresh build alone does not:` && |\n| &&
             `          // a nested view re-displayed without its MAIN view (it inherits the` && |\n| &&
             `          // MAIN model by UI5 propagation) and a popup left open across a` && |\n| &&
             `          // roundtrip that rebuilt no view (one that DOES rebuild MAIN takes` && |\n| &&
             `          // the standalone slots down with it - see actions/Slots).` && |\n| &&
             `          if (oResponse.MODELPRESENT) Slots.action("updateModel");` && |\n| &&
             `          // Phase 2: ONE history/hash sync per response. A ROUTER action only` && |\n| &&
             `          // travels when the roundtrip carries nav intent - its options were` && |\n| &&
             `          // stashed by the ControlCall hook. The plain response still syncs,` && |\n| &&
             `          // so hash routing and app-state tracking follow every new draft id.` && |\n| &&
             `          Router.sync({` && |\n| &&
             `            ...(oResponse._routerOptions || {}),` && |\n| &&
             `            id: oResponse.ID,` && |\n| &&
             `          });` && |\n| &&
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
             `          this._runPendingCustomJs(oResponse);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Phase 1: run the SYSTEM actions - the framework's own view-lifecycle` && |\n| &&
             `      // calls (destroy a slot, display one, push the model into it), in the` && |\n| &&
             `      // order the backend queued them. They run BEFORE anything an app` && |\n| &&
             `      // queued, and one at a time: a display is async, and the next action` && |\n| &&
             `      // may well be about the slot it is still building. The action context` && |\n| &&
             `      // carries the request stamp (so the slot displays can discard a build` && |\n| &&
             `      // a newer parallel request superseded) and the response record (so the` && |\n| &&
             `      // ROUTER action stashes its options on the response they belong to).` && |\n| &&
             `      async _runSystemActions(oResponse, seq) {` && |\n| &&
             `        const systemJs = oResponse?.S_ACTION?.T_SYSTEM;` && |\n| &&
             `        if (!systemJs) return;` && |\n| &&
             `        for (const item of systemJs) {` && |\n| &&
             `          // Stop the whole phase once a newer request superseded this` && |\n| &&
             `          // response - the remaining actions would tear down or overwrite` && |\n| &&
             `          // what the newer response builds (the per-display guards check` && |\n| &&
             `          // the same stamp, but the synchronous teardowns do not).` && |\n| &&
             `          if (Lib.isDestroyed(this) || seq !== Server._requestSeq) return;` && |\n| &&
             `          await FrontendAction.runSystem(item, this, {` && |\n| &&
             `            seq,` && |\n| &&
             `            response: oResponse,` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Execute the follow-up JS snippets stashed by Server.responseSuccess.` && |\n| &&
             `      // Runs once per roundtrip, after the view has rendered.` && |\n| &&
             `      _runPendingCustomJs(oResponse) {` && |\n| &&
             `        const customJs = oResponse?._pendingCustomJs;` && |\n| &&
             `        if (oResponse) oResponse._pendingCustomJs = null;` && |\n| &&
             `        if (!customJs) return;` && |\n| &&
             `        if (Lib.isDestroyed(this)) return;` && |\n| &&
             `        for (const item of customJs) {` && |\n| &&
             `          FrontendAction.runCustom(item, this);` && |\n| &&
             `        }` && |\n| &&
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
             `      // must not be renamed. The individual handlers live in the domain` && |\n| &&
             `      // modules under core/actions/ (merged in core/FrontendAction.js).` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eF(...args) {` && |\n| &&
             `        FrontendAction.execute(this, args);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eBP = "event backend, prevent default": cancels the control's` && |\n| &&
             `      // built-in default for this event and then round-trips exactly like` && |\n| &&
             `      // eB. The backend emits it (instead of eB) for an event registered` && |\n| &&
             `      // with s_ctrl-check_prevent_default, passing $event as the first` && |\n| &&
             `      // argument - preventDefault() only works synchronously inside the` && |\n| &&
             `      // handler, so it cannot be a follow-up action from the response.` && |\n| &&
             `      // Example: sap.tnt NavigationListItem.press, where cancelling the` && |\n| &&
             `      // default suppresses the item selection and leaves the decision to` && |\n| &&
             `      // the backend. The name is part of the protocol - do not rename it.` && |\n| &&
             `      //` && |\n| &&
             `      // The second argument is the veto CONDITION, so the decision can be` && |\n| &&
             `      // made per firing instead of per wire: s_ctrl-check_prevent_default` && |\n| &&
             `      // sends the constant true, s_ctrl-prevent_default_expr sends an` && |\n| &&
             `      // expression UI5 resolves on each firing (e.g. "is this the one column` && |\n| &&
             `      // that must not be resized?"). Everything after it is the eB payload.` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      eBP(oEvent, bVeto, ...args) {` && |\n| &&
             `        // guard the call: a malformed wire (no $event) must still round-trip` && |\n| &&
             `        if (bVeto && typeof oEvent?.preventDefault === "function") {` && |\n| &&
             `          oEvent.preventDefault();` && |\n| &&
             `        }` && |\n| &&
             `        this.eB(...args);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Ancestor-text breadcrumb of a control resolved in an event argument,` && |\n| &&
             `      // e.g. ``$controller.textPath(${$parameters>/item})`` on a menu's` && |\n| &&
             `      // itemSelected -> "Create New Site > Official Store". The parent-chain` && |\n| &&
             `      // walk happens on the live control tree, so no binding path can express` && |\n| &&
             `      // it; the separator defaults to " > ".` && |\n| &&
             `      textPath(oControl, sSeparator) {` && |\n| &&
             `        return Lib.getTextPath(oControl, sSeparator);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // ------------------------------------------------------------------` && |\n| &&
             `      // eB = "event backend": triggers a backend roundtrip with arguments.` && |\n| &&
             `      // The name is part of the protocol - backend-generated view XML binds` && |\n| &&
             `      // events to eB/eF - and must not be renamed.` && |\n| &&
             `      //` && |\n| &&
             `      // args[0] is the event array built by the backend (get_event):` && |\n| &&
             `      //   [0] event name` && |\n| &&
             `      //   [1] reserved placeholder, always false` && |\n| &&
             `      //   [2] "ignore busy" flag - background events (e.g. timers) skip the` && |\n| &&
             `      //       busy guard below` && |\n| &&
             `      //   [3] "use main view model" flag - events fired from a popup or` && |\n| &&
             `      //       popover controller that still target the main app's model;` && |\n| &&
             `      //       not emitted by the framework today, only by custom JS` && |\n| &&
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
             `        // A roundtrip is already in flight and this event's keystroke/click is` && |\n| &&
             `        // dropped. Surface the global busy indicator right away (0 delay)` && |\n| &&
             `        // instead of a separate, transient BusyDialog: it is the exact same` && |\n| &&
             `        // overlay the in-flight roundtrip hides on completion, so the user sees` && |\n| &&
             `        // one steady indicator until the response lands - not a modal flashing` && |\n| &&
             `        // in and straight back out over the (1s-delayed) global one. show() is` && |\n| &&
             `        // idempotent, so repeated drops during the same roundtrip are cheap.` && |\n| &&
             `        if (AppState.state.isBusy && !ignoreBusy) {` && |\n| &&
             `          BusyIndicator.show(0);` && |\n| &&
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
             `        // away so onBeforeRoundtrip hooks and the developer tools see it.` && |\n| &&
             `        const oBody = {};` && |\n| &&
             `        AppState.state.oBody = oBody;` && |\n| &&
             `` && |\n| &&
             `        // Decide which view's model holds the data we need to send back. The` && |\n| &&
             `        // mapping is: main app controller -> main view, popup controller ->` && |\n| &&
             `        // popup view, etc.` && |\n| &&
             `        const oModel = this._pickModelForRoundtrip(useMainModel);` && |\n| &&
             `` && |\n| &&
             `        Lib.runCallbacks(AppState.state.onBeforeRoundtrip);` && |\n| &&
             `` && |\n| &&
             `        // If the user edited model paths, send only the delta to keep the` && |\n| &&
             `        // payload small. The edited paths live on the picked model itself` && |\n| &&
             `        // (set in Slots.trackChanges), so onBeforeRoundtrip hooks that mark` && |\n| &&
             `        // paths dirty (e.g. the Scrolling control) must have run above first.` && |\n| &&
             `        const changedPaths = oModel?._z2ui5ChangedPaths;` && |\n| &&
             `        if (oModel && changedPaths?.size > 0) {` && |\n| &&
             `          const data = oModel.getData();` && |\n| &&
             `          if (data) {` && |\n| &&
             `            oBody.MODEL = Lib.buildDeltaFromPaths(changedPaths, data);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `        // Remember which model this request carried so the winning response` && |\n| &&
             `        // clears exactly its edits (Server.readHttp) - a stale response clears` && |\n| &&
             `        // nothing, and edits in other models stay pending for their own send.` && |\n| &&
             `        AppState.state.oSentModel = oModel;` && |\n| &&
             `` && |\n| &&
             `        oBody.ID = AppState.state.oResponse?.ID;` && |\n| &&
             `        // Arguments travel as raw JSON values - the request body is` && |\n| &&
             `        // serialized exactly once in Server.readHttp. Object arguments are` && |\n| &&
             `        // turned into JSON strings by the backend when it fills` && |\n| &&
             `        // T_EVENT_ARG, so apps keep receiving them as strings; stringifying` && |\n| &&
             `        // them here as well would encode (and escape) the payload twice.` && |\n| &&
             `        // Control-valued arguments are marshalled into plain data first (see` && |\n| &&
             `        // Lib.normalizeEventArgs): a UI5 event parameter is often a control or` && |\n| &&
             `        // an array of controls, and JSON.stringify throws on the circular` && |\n| &&
             `        // parent/aggregation graph of a ManagedObject. Everything else passes` && |\n| &&
             `        // through untouched. normalizeEventArgs returns a fresh array, which` && |\n| &&
             `        // is what Server.roundtrip needs - it mutates ARGUMENTS via shift and` && |\n| &&
             `        // must not reach this call's own rest-parameter array.` && |\n| &&
             `        oBody.ARGUMENTS = Lib.normalizeEventArgs(args);` && |\n| &&
             `` && |\n| &&
             `        Server.roundtrip(oBody);` && |\n| &&
             `        Lib.runCallbacks(AppState.state.onAfterRoundtrip);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _pickModelForRoundtrip(useMainModel) {` && |\n| &&
             `        // useMainModel forces use of the main view's model even when called` && |\n| &&
             `        // from a popup/popover controller.` && |\n| &&
             `        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);` && |\n| &&
             `        if (!slotKey) return undefined;` && |\n| &&
             `` && |\n| &&
             `        const oView = ViewSlots.getView(slotKey);` && |\n| &&
             `        if (!oView) return undefined;` && |\n| &&
             `` && |\n| &&
             `        // MAIN and its nested views (NEST/NEST2) share one framework-owned` && |\n| &&
             `        // JSON model, so a nested-slot event must resolve the tracked model` && |\n| &&
             `        // (not the propagated OData default, which has no getData()) or the` && |\n| &&
             `        // edit is silently dropped. The data and changedPaths delta are shared` && |\n| &&
             `        // across the root slots, so any of them yields the same model.` && |\n| &&
             `        if (Lib.isRootModelSlot(slotKey)) {` && |\n| &&
             `          return Slots.resolveTrackedModel(oView);` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Popup/popover are standalone and return their own (default) model.` && |\n| &&
             `        return oView.getModel();` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
