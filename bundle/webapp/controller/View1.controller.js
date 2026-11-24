// The central view controller. One instance serves each of the five view
// slots (main view, two nested views, popup, popover - see
// core/ViewSlots.js). It carries the protocol entry points the backend binds
// events to (eB, eBP, eF), builds the request for backend events and runs
// the response's two action phases. The display machinery behind those
// actions lives in core/actions/Slots.js. Every instance carries the
// context of its component as `ctx` (core/Context.js, set by
// App.controller): it is what every action handler reads the state through,
// and Lib.isControllerAlive's liveness test is membership in that context.
sap.ui.define(
  [
    "sap/ui/core/mvc/Controller",
    "sap/ui/core/BusyIndicator",
    "z2ui5/core/Server",
    "z2ui5/core/Lib",
    "z2ui5/core/FrontendAction",
    "z2ui5/core/actions/Slots",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/Router",
    "z2ui5/core/Env",
  ],
  (
    Controller,
    BusyIndicator,
    Server,
    Lib,
    FrontendAction,
    Slots,
    ViewSlots,
    Router,
    Env,
  ) => {
    "use strict";

    // The busy overlay of a roundtrip: the global BusyIndicator on a page the
    // component owns, the component's own area on a host's page
    // (state.ownsPage, Component.init - Lib.setComponentBusy). The same pair
    // sits in core/Server.js, the other half of the busy protocol.
    function showBusy(ctx, delay) {
      if (ctx?.state?.ownsPage === false)
        Lib.setComponentBusy(ctx, true, delay);
      else BusyIndicator.show(delay);
    }
    function hideBusy(ctx) {
      if (ctx?.state?.ownsPage === false) Lib.setComponentBusy(ctx, false);
      else BusyIndicator.hide();
    }

    // How many events fired while a view was being built may go out in a
    // row with no other event in between (eB keeps them, aRenderEvents). A
    // page with a handful of controls that answer from their rendering - a
    // Storage control per stored value - stays far below it; an app that
    // answers such an event with a view that fires it again would otherwise
    // roundtrip for as long as the page stays open.
    const RENDER_EVENT_CHAIN_MAX = 25;

    const View1Controller = Controller.extend("z2ui5.controller.View1", {
      onAfterRendering() {
        // _processAfterRendering re-checks _processed itself - only the
        // null check is load-bearing here
        if (this.ctx.state.oResponse) this._processAfterRendering();
      },

      // Runs once after each roundtrip's view has been rendered, in two
      // named phases: display pending fragments/views, then update the
      // browser history/hash. `reqSeq` is the stamp of the request the
      // response being processed belongs to (Server.responseSuccess); the
      // onAfterRendering entry above has none and falls back to the newest.
      async _processAfterRendering(reqSeq) {
        // Two different "too late"s, and they are not the same moment.
        // `superseded` - a newer REQUEST was dispatched: the busy protocol
        // and the parked hash belong to it from here on. `replaced` - the
        // screen this response built is GONE: the app was torn down, or the
        // newer request's response has already LANDED. Only the second one
        // invalidates this response's own follow-up actions (see the finally).
        let superseded = false;
        let replaced = false;
        // the build of THIS response failed and the fatal overlay is up
        let failed = false;
        // The claim happens BEFORE the try: the MAIN rebuild is part of
        // phase 1, so slots render (and re-enter here via their own
        // onAfterRendering - possibly with a NESTED controller as `this`)
        // while phase 1 is still awaiting. A losing entry must return here
        // and never reach the finally, which would hide the busy state and
        // consume the pending actions mid-phase, on the wrong controller.
        // The record is also pinned for the finally: the shared
        // this.ctx.state.oResponse may point at a newer response by then.
        const oResponse = this.ctx.state.oResponse;
        if (!oResponse || oResponse._processed) return;
        oResponse._processed = true;
        // ... and it is being processed from here to the finally below: an
        // event a control fires meanwhile, out of a view this response
        // built, is kept instead of dropped (eB, _firedWhileBuilding)
        oResponse._processing = true;
        // Stamp of the request this response belongs to: every await in
        // the display phase re-checks it, so a response superseded by a
        // parallel request (a Back/Forward restore, or a teardown that
        // bumped the sequence)
        // never attaches popups/nested views the backend no longer knows.
        // ONE stamp for BOTH phases - see the guard below - and for the
        // catch, which asks it before it raises the fatal overlay.
        const seq = reqSeq ?? this.ctx.server.requestSeq;
        try {
          // The response names its app. An app switch is nothing the
          // frontend acts on for the VIEWS any more - the backend states the
          // teardown of the standalone slots for every hop itself, as their
          // entries of the VIEWS section (z2ui5_cl_ui5_action=>
          // prepare_app_stack; until protocol 3 they were taken down here
          // whenever the class changed). What does go with the app is the
          // event a check_queue_last wire kept while the roundtrip ran: it
          // was typed into the leaving app's view, and the dispatch below
          // (_dispatchQueuedEvent) would otherwise send it under the NEW
          // app's draft id, where the backend routes it to an app that
          // never registered the event
          const state = this.ctx.state;
          const previousApp = state.renderedApp;
          if (oResponse.APP && previousApp !== oResponse.APP) {
            state.oQueuedEvent = null;
            state.oTickQueuedEvent = null;
            state.oQueuedWindow = null;
            // ... and what a control of the leaving app fired while its
            // view was built and that has not gone out yet
            state.aRenderEvents = [];
            state.renderedApp = oResponse.APP;
          }
          // The state an app OWNS goes when its PAGE goes - not when the
          // response merely names another app. An app called only to open
          // a dialog (nav_app_call to a popup app, the shape every
          // z2ui5_cl_pop_* has) answers two responses under its own name
          // while MAIN keeps the caller's view: resetting on the name alone
          // left the caller, once the dialog closed, with its shortcuts
          // dead, its hash listener gone, its tree snapshots lost and its
          // tables capped by the default size limit. So the reset asks who
          // filled MAIN (ViewSlots.getViewApp) and whether this response
          // replaces it - BEFORE the views are applied, since the new app
          // registers its shortcuts and takes its tree snapshots in them.
          if (this._replacesMainOwner(oResponse, previousApp)) {
            // the leaving app's keyboard shortcuts die with it - the new app
            // registers its own (actions/Shortcuts documents this reset) -
            // and so do its tree-expansion snapshots, which are keyed by the
            // LOCAL tree_id and would otherwise leak into a same-named tree
            // of the next app. Prototype-less like AppState.createState builds
            // them: both are keyed by names from the wire, and a plain {}
            // here would hand the second app a registry with a prototype again
            state.shortcuts = Object.create(null);
            state.treeStates = Object.create(null);
            state.tableStates = Object.create(null);
            // ... and the model size limits it set (cs_event-set_size_limit):
            // every model a slot builds takes the stored limit
            // (Slots.applyStoredSizeLimit), so the next app's tables were
            // capped - or uncapped - by a limit it never asked for
            state.viewSizeLimits = Object.create(null);
            // ... and so does the app-owned hash listener
            // (cs_event-hash_attach_changed): the backend keeps no record of
            // it and z2ui5_if_client promises it dies with the app switch,
            // but the context is only torn down with the component. A
            // listener the leaving app registered kept dispatching ITS event
            // name into the next app on every Back / hash edit, and
            // Router.sync skipped the app-state URL upkeep for that app as
            // long as it lived
            state.hashEvent = null;
            state.appHash = "";
            state.pendingAppHash = null;
          }
          // No early return on a response without VIEWS: it still gets its
          // model push, its hash sync and the after-render hooks below - a
          // roundtrip that changes no slot is the COMMON case.
          if (oResponse.VIEWS) {
            await this._applyViews(oResponse, seq);
          }
          // The app may have been torn down (reset / FLP re-launch) while the
          // pending views loaded; don't mutate history or fire onAfterRendering
          // hooks against a dead app (the custom-JS phase below guards the same
          // way via isControllerAlive). And a response a PARALLEL request replaced
          // mid-phase must not push its model or write its ids into the URL -
          // the push would read the NEWER response's data into this stale
          // render, and the sync would mix this draft id with the newer app.
          // The newer response runs its own push and sync.
          //
          // The request STAMP is what says "superseded", not the response
          // record: the display phase stops on it, and it flips the moment
          // the newer request is DISPATCHED, while the record only flips
          // when that request's response LANDS. Asking the record alone left
          // the window in between - a phase 1 cut short by a Back/Forward
          // restore still ran phase 2 here: it ended the busy state the
          // restore relies on (so a click could dispatch a third request and
          // abort it) and let Router.sync consume the restore's navFromHash
          // flag, which the restore's own response then no longer found.
          const alive = Lib.isControllerAlive(this);
          if (
            !alive ||
            seq !== this.ctx.server.requestSeq ||
            oResponse !== this.ctx.state.oResponse
          ) {
            // a NEWER request owns the busy state and the parked hash from
            // here on (see the finally below) - this response only stops
            superseded = true;
            // ... but what is ON SCREEN is still what this response built,
            // unless the app is gone or the newer response has landed - a
            // request merely DISPATCHED is still in flight.
            replaced = !alive || oResponse !== this.ctx.state.oResponse;
            return;
          }
          // A MODEL key in the response IS the model push - run it after the
          // displays. A slot built in this same roundtrip already holds the
          // model and is recognised as such (actions/Slots createViewModel),
          // so the push reaches what a fresh build alone does not: a nested
          // view re-displayed without its MAIN view (it inherits the MAIN
          // model by UI5 propagation) and a popup left open across a
          // roundtrip that rebuilt no view (one that DOES rebuild MAIN takes
          // the standalone slots down with it - see actions/Slots).
          if (oResponse.MODELPRESENT) Slots.action(this.ctx, "updateModel");
          // Phase 2: ONE history/hash sync per response, with the URL intent
          // the response carries as its NAV section - most carry none, and
          // still sync, so hash routing and app-state tracking follow every
          // new draft id.
          Router.sync(this.ctx, {
            ...(oResponse.NAV || {}),
            id: oResponse.ID,
          });
          Lib.runCallbacks(this.ctx.state.onAfterRendering);
          Lib.runCallbacks(this.ctx.state.onRoundtripEnd);
        } catch (e) {
          Lib.logError("_processAfterRendering: unexpected error", e);
          // A failure of a response a NEWER request has superseded, or
          // whose app is gone, is not the user's concern: the newer request
          // owns the outcome and the screen, exactly as Server.readHttp
          // swallows a stale request's own failure. A build a Back/Forward
          // restore cut short used to raise the fatal overlay over the
          // screen the restore's response was about to build (a duplicate
          // id, or a slot the restore had already torn down) - and the
          // overlay ends the app.
          if (
            !Lib.isControllerAlive(this) ||
            seq !== this.ctx.server.requestSeq
          ) {
            superseded = true;
            replaced =
              !Lib.isControllerAlive(this) ||
              oResponse !== this.ctx.state.oResponse;
          } else {
            // The overlay ends the app, so nothing of this response runs
            // after it: a START_TIMER among its follow-up actions would
            // tick roundtrips under the overlay, and a parked hash change
            // would send one - for an app declared dead, to render behind
            // the overlay or raise a second one. Server.responseError drops
            // the queued event for the same reason.
            failed = true;
            // Server decides which overlay this failure gets: a view that
            // could not load a sap.com module on openui5 shows the SDK hint,
            // anything else the fatal overlay (see Server.showRenderError).
            Server.showRenderError(
              this.ctx,
              e,
              "Unexpected Error Occurred - App Terminated",
            );
          }
        } finally {
          // A superseded response (a Back/Forward restore or a parallel
          // request replaced it while its views were still loading) leaves
          // the busy protocol to the request that superseded it: hiding
          // the indicator here ended the busy state the restore relied on
          // and let a click dispatch a third request that aborted it.
          //
          // hide() is unconditional even for a check_no_busy roundtrip that
          // never showed it: the indicator is a singleton, not a counter, and
          // a wire that opted out may still have to take the overlay down -
          // a CLICK dropped while its roundtrip ran raised it at 0 delay.
          oResponse._processing = false;
          if (!superseded) {
            hideBusy(this.ctx);
            this.ctx.state.isBusy = false;
          }
          // Its OWN follow-up actions are a different matter, and they run.
          // They are what the backend queued FOR THIS RESPONSE, and nothing
          // else will ever run them: the superseding request answers with its
          // own ACTIONS, so everything queued here was simply dropped.
          // The app's very FIRST roundtrip lost them every time, because it
          // is the one roundtrip eB does not mark busy (Server.roundtrip is
          // called straight from onInit) - so a control that fires an event
          // while the initial view renders dispatches request 2 and
          // supersedes the response that is building the screen. Measured on
          // the samples-controls corpus: an ICON_POOL registerFont (350) and
          // eight Wizard setNextStep calls (534) sat in the response, in
          // _pendingActions, and never ran.
          // Only a response whose screen is GONE skips them - and
          // _runPendingActions asks isControllerAlive for the torn-down app.
          // Order unchanged: after the busy indicator is down, so
          // render-dependent actions like SET_FOCUS find their control.
          // A page transition of the MAIN view still in motion ends first
          // (actions/Slots): a SET_FOCUS or SCROLL_TO belongs to the page
          // as it will stand, and the NavContainer's own autofocus at the
          // end of the move would take the focus back from an earlier one.
          // The promise never rejects - it settles on the move's end or on
          // its timeout.
          if (!replaced && this.ctx.state.mainTransition) {
            await this.ctx.state.mainTransition;
          }
          if (!replaced && !failed) await this._runPendingActions(oResponse);
          // ... except the timers they arm, when what superseded this
          // response is a Back/Forward restore: the restore cancelled the
          // timers of the screen it leaves when it went out - before these
          // actions ran - and a START_TIMER armed here would tick this
          // screen's event into the app the restore brings up. A response
          // an ordinary event superseded keeps them (the first roundtrip's
          // poll above is exactly that case).
          if (
            superseded &&
            !replaced &&
            this.ctx.server.restoreSeq === this.ctx.server.requestSeq &&
            seq !== this.ctx.server.requestSeq
          ) {
            Lib.cancelPendingTimers(this.ctx);
          }
          if (!superseded && !failed) {
            // The event a check_queue_last wire kept while this roundtrip ran
            // goes out first: it belongs to the screen this response built.
            // A parked hash change is re-parked by the router when that
            // dispatch made the app busy again, and delivered by the next
            // response - order preserved, nothing lost.
            this._dispatchQueuedEvent();
            // an app-hash change (Back/Forward under app-owned routing) that
            // arrived while this roundtrip was in flight was parked by the
            // router - deliver it now that the busy guard would let it through
            Router.dispatchPendingAppHash(this.ctx);
          }
        }
      },

      // Does this response put ANOTHER app's page on MAIN? True when it
      // carries a MAIN display and the app answering is not the one that
      // filled MAIN (ViewSlots.getViewApp; before any slot recorded an
      // owner, the app rendered before this response stands in). A
      // popup-only app's responses carry no MAIN display, and a same-app
      // re-display carries one for the same owner - neither replaces the
      // page.
      _replacesMainOwner(oResponse, previousApp) {
        if (!oResponse?.APP) return false;
        const main = oResponse.VIEWS?.MAIN;
        if (!main || main.DESTROY) return false;
        const owner = ViewSlots.getViewApp(this.ctx, "MAIN") ?? previousApp;
        return owner !== oResponse.APP;
      },

      // Phase 1: apply the response's VIEWS section - one entry per slot
      // the roundtrip changes, a display ({ XML, OPT }) or a teardown
      // ({ DESTROY: true }). The ORDER is this method's: MAIN first, then
      // the nested views, which are inserted into the main control tree,
      // then the two standalone slots - a new MAIN view takes them down
      // (actions/Slots displayMain), so a popup the same response opens has
      // to open after it. The backend sorts nothing. One at a time: a
      // display is async, and the next entry may well be about a slot it is
      // still building. The request stamp rides along so a display can
      // discard a build a newer parallel request superseded.
      async _applyViews(oResponse, seq) {
        const views = oResponse?.VIEWS;
        if (!views) return;
        for (const slot of ViewSlots.slots) {
          const entry = views[slot.key];
          if (!entry) continue;
          // Stop the whole phase once a newer request superseded this
          // response - the remaining entries would tear down or overwrite
          // what the newer response builds (the per-display guards check
          // the same stamp, but the synchronous teardowns do not).
          if (
            !Lib.isControllerAlive(this) ||
            seq !== this.ctx.server.requestSeq
          )
            return;
          await Slots.action(
            this.ctx,
            entry.DESTROY ? "destroy" : "display",
            slot.key,
            entry.XML,
            entry.OPT,
            seq,
          );
        }
      },

      // The read side of the queueLast slot in eB: the LAST event a
      // check_queue_last wire fired while the roundtrip that just landed was
      // in flight. Dispatched through eB itself, so it is a roundtrip like
      // any other - it picks its model (the edits typed meanwhile are still
      // pending, see Server._clearSentPaths), marks the app busy, and is
      // queued AGAIN should something else have started a roundtrip first.
      // The slot is cleared before the dispatch, so the dispatch can refill
      // it. An event whose controller is gone - the app torn down, the popup
      // it was typed into closed by the response - is dropped: its screen
      // is gone, and its model with it.
      //
      // "Gone" is asked of the VIEW, not only of the controller: the five
      // slot controllers are created once per app start and outlive the
      // popup they serve, so a popup the response closed still had a live
      // controller - its keystroke went out with no model, an event for a
      // screen the backend had just closed. The view the event was typed
      // into has to be the one still showing in that slot.
      //
      // The keystroke first - it belongs to the screen the response built -
      // then the window requests of the tables (oQueuedWindow, kept by
      // actions/Slots, one per table); when the keystroke started a
      // roundtrip they stay where they are, for the end of that one.
      //
      // Ahead of both goes the oldest event a control fired while its view
      // was being built (aRenderEvents): one per landed roundtrip, the rest
      // wait for the next one, in the order they fired. The chain counter
      // is what ends an app that answers such an event with a view that
      // fires it again - eB resets it for every other event, so only an
      // unbroken run of them counts.
      _dispatchQueuedEvent() {
        const state = this.ctx.state;
        while (state.aRenderEvents.length) {
          const queued = state.aRenderEvents.shift();
          if (!Lib.isControllerAlive(queued.controller)) continue;
          // the slot has to show the view THAT response built - asked of the
          // slot's record, not of a view kept at the time: a control can
          // fire before its view has reached the slot at all
          const key = ViewSlots.keyOfController(queued.controller);
          if (ViewSlots.getViewToken(this.ctx, key) !== queued.token) {
            continue;
          }
          const chain = state.renderEventChain + 1;
          if (chain > RENDER_EVENT_CHAIN_MAX) {
            Lib.logError(
              `eB: ${RENDER_EVENT_CHAIN_MAX} events fired while a view was being built went out in a row - '${queued.args[0]?.[0]}' and the ones behind it are dropped. An app that answers a rendering event with a new view fires it again`,
            );
            state.aRenderEvents = [];
            break;
          }
          queued.controller.eB(...queued.args);
          // eB counts every dispatch as the end of a chain - this one
          // continues it
          state.renderEventChain = chain;
          break;
        }
        // The click a START_TIMER tick held back (eB) goes out now, under
        // the draft id the tick's response named - unless a render event
        // above made the app busy again: then it waits for that response,
        // and is not dropped. Its view has to be in its slot still (a
        // popup the tick's response closed takes the click with it); a
        // view the response rebuilt in the same slot is the same screen
        // of the same app - an app switch dropped the click already.
        const tickQueued = state.oTickQueuedEvent;
        if (tickQueued && !state.isBusy) {
          state.oTickQueuedEvent = null;
          const key = ViewSlots.keyOfController(tickQueued.controller);
          if (
            Lib.isControllerAlive(tickQueued.controller) &&
            ViewSlots.getView(this.ctx, key)
          ) {
            tickQueued.controller.eB(...tickQueued.args);
          }
        }
        const queued = state.oQueuedEvent;
        state.oQueuedEvent = null;
        if (queued && Lib.isControllerAlive(queued.controller)) {
          const key = ViewSlots.keyOfController(queued.controller);
          if (ViewSlots.getView(this.ctx, key) === queued.view) {
            queued.controller.eB(...queued.args);
          }
        }
        // the window requests of the tables wait in a place of their own,
        // one per table, and go out whenever the app is idle
        Slots.dispatchQueuedWindows(this.ctx);
      },

      // Execute the follow-up actions stashed by Server.responseSuccess.
      // Runs once per roundtrip, after the view has rendered.
      // Sequential, and an action that hands back a promise (SET_ODATA_MODEL
      // loading its client on first use) is awaited before the next one
      // runs, so the order the backend queued them in is the order their
      // effects land in - every other action is synchronous and costs no
      // tick here. A REJECTED promise is logged and the next action runs:
      // FrontendAction.execute promises that a failing handler is logged,
      // never thrown, and the synchronous half keeps that. An await without
      // a catch broke it for the asynchronous half - the rejection escaped
      // the finally of _processAfterRendering, skipped the queued event and
      // the parked hash behind it, and turned a rendered screen into the
      // fatal "App Terminated" overlay.
      async _runPendingActions(oResponse) {
        const actions = oResponse?._pendingActions;
        if (oResponse) oResponse._pendingActions = null;
        if (!actions) return;
        if (!Lib.isControllerAlive(this)) return;
        for (const item of actions) {
          const result = FrontendAction.runCustom(item, this);
          if (typeof result?.then === "function") {
            try {
              await result;
            } catch (e) {
              Lib.logError(
                `FrontendAction: async action '${item?.[0]}' failed`,
                e,
              );
            }
            if (!Lib.isControllerAlive(this)) return;
          }
        }
      },

      // Thin wrappers around the shared slot teardown in ViewSlots. Nothing
      // in this repository or in the sample catalogues calls them, and the
      // caller they were kept for - custom JS - is gone (follow_up_action
      // runs no raw JavaScript since 2026-09-22, no-new-func is an ESLint
      // error). They stay because a view names a controller method as DATA:
      // an event attribute of an app's own view XML (`press=".destroyPopup"`,
      // `$controller.destroyPopup()` in an argument expression) rendered by
      // an older backend, or a customer custom control holding the
      // controller, breaks at runtime and not at build time if they go.
      // Their removal is tracked in docs/removal-plan.md section 3.
      destroyPopup() {
        ViewSlots.destroy(this.ctx, "POPUP");
      },
      destroyPopover() {
        ViewSlots.destroy(this.ctx, "POPOVER");
      },
      destroyNestView() {
        ViewSlots.destroy(this.ctx, "NEST");
      },
      destroyNestView2() {
        ViewSlots.destroy(this.ctx, "NEST2");
      },
      destroyView() {
        ViewSlots.destroy(this.ctx, "MAIN");
      },

      // ------------------------------------------------------------------
      // eF = "event frontend": handles frontend-only events triggered by
      // the backend response, without a roundtrip. The name is part of the
      // protocol - backend-generated view XML binds events to eB/eF - and
      // must not be renamed. The individual handlers live in the domain
      // modules under core/actions/ (merged in core/FrontendAction.js).
      // ------------------------------------------------------------------
      eF(...args) {
        return FrontendAction.execute(this, args);
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

      // Control resolved by id in a NAMED VIEW SLOT, for an event argument:
      // `$controller.slotById('POPUP','imageEditor')`. An id is local to the
      // view or fragment it was written in, so a control in a dialog is not
      // reachable from the MAIN view's own byId( ) - and `${...}` is a binding
      // path, which cannot address a control at all. Slot keys are the ones
      // ViewSlots owns: MAIN, NEST, NEST2, POPUP, POPOVER. An empty slot
      // searches every open one and then the global registry, the same
      // resolution CONTROL_BY_ID uses for cs_view-main.
      //
      // Returns null when the slot is closed or holds no such id, and says so
      // in the console. A null REACHES the expression, so
      // `slotById(...).getText()` on a miss throws inside UI5's handler
      // evaluation and the event is lost - use slotValue( ) below for the
      // read, which is the case this exists for and cannot throw.
      slotById(sSlot, sId) {
        const control = sSlot
          ? ViewSlots.byId(this.ctx, sSlot, sId)
          : ViewSlots.resolveById(this.ctx, sId);
        if (!control) {
          Lib.logError(
            `slotById: no control '${sId}' in slot '${sSlot || "(any)"}'`,
          );
          return null;
        }
        return control;
      },

      // The null-safe READ behind slotById: resolve, call a no-argument
      // getter, hand the value to the event -
      // `$controller.slotValue('POPUP','imageEditor','getImagePngDataURL')`.
      //
      // This is the shape an event argument needs, and the reason it exists
      // beside slotById: an argument expression is evaluated by UI5 while it
      // dispatches the handler, so anything that throws there takes the whole
      // event with it - the button does nothing and the app cannot tell. Every
      // miss (closed slot, unknown id, no such method, a getter that throws)
      // is logged and answered with the empty string, exactly as
      // Lib.getTextPath answers a control it cannot walk: the roundtrip still
      // happens and the backend sees an empty argument.
      //
      // A no-argument getter on purpose. Passing arguments would make this a
      // second, untyped CONTROL_BY_ID with no whitelist in front of it; what
      // an app needs here is to READ what the control currently holds.
      slotValue(sSlot, sId, sMethod) {
        try {
          const control = sSlot
            ? ViewSlots.byId(this.ctx, sSlot, sId)
            : ViewSlots.resolveById(this.ctx, sId);
          if (!control) {
            Lib.logError(
              `slotValue: no control '${sId}' in slot '${sSlot || "(any)"}'`,
            );
            return "";
          }
          if (typeof control[sMethod] !== "function") {
            Lib.logError(
              `slotValue: '${sMethod}' is not a method of control '${sId}'`,
            );
            return "";
          }
          const value = control[sMethod]();
          return value === undefined || value === null ? "" : value;
        } catch (e) {
          Lib.logError(`slotValue: '${sMethod}' on '${sId}' failed`, e);
          return "";
        }
      },

      // ------------------------------------------------------------------
      // eB = "event backend": triggers a backend roundtrip with arguments.
      // The name is part of the protocol - backend-generated view XML binds
      // events to eB/eF - and must not be renamed.
      //
      // args[0] is the event array built by the backend (get_event):
      //   [0] event name
      //   [1] the flags of the wire, as ONE object read by key - absent on a
      //       wire without one:
      //         queueLast  (s_ctrl-check_queue_last) - while a roundtrip is
      //                    in flight the LAST event fired on this wire is
      //                    kept and dispatched once the response has landed
      //                    (see the busy guard below and
      //                    _dispatchQueuedEvent); for per-keystroke wires
      //         noBusy     (s_ctrl-check_no_busy) - the roundtrip runs
      //                    exactly as it otherwise would, state.isBusy
      //                    included, but the global busy indicator is not
      //                    raised for it (both show() calls below are
      //                    skipped); for the same per-keystroke wires, and
      //                    for a START_TIMER tick armed with its no-busy
      //                    argument (actions/ViewOps)
      //         timer      set by no wire - the tick of START_TIMER
      //                    (actions/ViewOps): sent as S_FRONT.TIMER, and
      //                    a click during it is held back, not dropped
      //         useMainModel  an event fired from a popup or popover
      //                    controller that carries the MAIN model's edits;
      //                    nothing the framework renders sets it
      // Until protocol 3 the flags were POSITIONS [3], [4] and [5] of this
      // array behind two slots that were always false. They are not read
      // any more; a wire that still carries one says so in the log
      // (Lib.eventOptions) instead of quietly losing its flag.
      // ------------------------------------------------------------------
      eB(...args) {
        // The first argument is the event ARRAY. A string there - a wire
        // hand-written as eB('SAVE') - used to be destructured character by
        // character and round-tripped as the event "S", which the backend
        // answered with nothing an app could recognise. Say so instead;
        // there is no event to send.
        if (!Array.isArray(args[0])) {
          // described, not stringified: the wrong first argument is as often
          // `$event` or a control as a string, and JSON.stringify throws on
          // their circular graph - the guard itself then threw out of the
          // event handler instead of logging
          let got;
          try {
            got = JSON.stringify(args[0]);
          } catch {
            got = `an object that is no JSON (${Object.prototype.toString.call(args[0])})`;
          }
          Lib.logError(
            `eB: the first argument must be the event array, got ${got}`,
          );
          return;
        }
        const { useMainModel, queueLast, noBusy, timer } = Lib.eventOptions(
          args[0],
        );

        // No navigator.onLine gate here: a browser reports "offline" for a
        // host without a default route (a VPN-only adapter, an intranet
        // without internet) while the ABAP system is reachable, and the
        // gate answered every click - and every START_TIMER tick, whose
        // slot is deleted before it fires - with an alert and no roundtrip.
        // A real network failure is reported by the fetch itself, with a
        // Retry (Server.responseError).

        // A roundtrip is already in flight and this event's keystroke/click is
        // dropped. Surface the global busy indicator right away (0 delay)
        // instead of a separate, transient BusyDialog: it is the exact same
        // overlay the in-flight roundtrip hides on completion, so the user sees
        // one steady indicator until the response lands - not a modal flashing
        // in and straight back out over the (1s-delayed) global one. show() is
        // idempotent, so repeated drops during the same roundtrip are cheap.
        //
        // A wire that carries queueLast is not dropped but KEPT - one slot,
        // last wins - and dispatched through this very method once the
        // in-flight roundtrip has landed (_dispatchQueuedEvent). Dropping is
        // right for a click; for a per-keystroke wire it lost every keystroke
        // typed while a roundtrip ran, the last one included, and left the
        // backend at the value of the last COMPLETED roundtrip while the
        // control showed the current one (samples-controls 280, sap.m.TextArea:
        // `abc` typed at once left the bound field at `a`). The arguments are
        // marshalled now, not at dispatch: a control-valued argument may well
        // be destroyed by the response that lands in between.
        //
        // noBusy suppresses the indicator, not the guard: the event is still
        // kept or dropped exactly as above, only nothing is shown. The 0 delay
        // is what makes this the wire's worst moment - the FIRST roundtrip of
        // a live search is invisible for a second, and the second character
        // typed raises the overlay instantly, over the very field being typed
        // into. That is the right answer for a dropped click and the wrong one
        // for a keystroke, which is why it is a per-wire decision.
        if (this.ctx.state.isBusy) {
          if (queueLast) {
            this.ctx.state.oQueuedEvent = {
              controller: this,
              // the view the event was typed into - see _dispatchQueuedEvent
              view: ViewSlots.getView(
                this.ctx,
                ViewSlots.keyOfController(this),
              ),
              args: Lib.normalizeEventArgs(args),
            };
          } else if (this._firedWhileBuilding()) {
            // Not a click on a screen that is being replaced, but a control
            // of the view this very response is building, answering from
            // its rendering - a Storage control with the value it found, an
            // afterRendering an app wired. It belongs to the screen the
            // response builds, so it is kept, whatever its wire's flags, and
            // goes out once the response is done (_dispatchQueuedEvent). No
            // overlay: there is no user to tell.
            // Until 2026-11 the same event was sent at once on the first
            // roundtrip - which was not busy, and whose response it
            // superseded - and dropped on every later one.
            this.ctx.state.aRenderEvents.push({
              controller: this,
              // the response that builds the view the event comes from,
              // as its token - see _dispatchQueuedEvent
              token: this.ctx.state.oResponse.TOKEN,
              args: Lib.normalizeEventArgs(args),
            });
            return;
          } else if (this.ctx.state.tickInFlight && !timer) {
            // The roundtrip in flight is a START_TIMER tick - nothing the
            // user started or can see coming. Dropping the click there
            // lost it at random on every polling screen; it is kept
            // instead, the first one only (a second click meets the guard
            // as a second click always does), and sent once the tick's
            // response is applied (_dispatchQueuedEvent). The overlay
            // goes up as for a dropped click: the user's action is
            // pending now.
            if (!this.ctx.state.oTickQueuedEvent) {
              this.ctx.state.oTickQueuedEvent = {
                controller: this,
                args: Lib.normalizeEventArgs(args),
              };
            }
          }
          if (!noBusy) showBusy(this.ctx, 0);
          return;
        }

        // an event that is dispatched ends a run of render events - only an
        // unbroken run of them counts (_dispatchQueuedEvent sets the counter
        // again when the event was one of them)
        this.ctx.state.renderEventChain = 0;

        // A new roundtrip overrides any pending timer - the shared helper,
        // because the OTHER path that starts one (Server.restoreFromRoute,
        // the Back/Forward restore) owes the same cancel and had nothing.
        Lib.cancelPendingTimers(this.ctx);

        // The busy STATE is set either way - the guard above, the queued
        // dispatch, the parked hash routing and the request sequencing all
        // read it, and a wire that opted out of the overlay has not opted out
        // of being one roundtrip in flight. Only the overlay is skipped.
        this.ctx.state.isBusy = true;
        if (!noBusy) showBusy(this.ctx);
        // what the busy guard above asks: whether a click that lands during
        // this roundtrip is held back for it (a tick) or dropped
        this.ctx.state.tickInFlight = timer;

        // The request body is built locally and handed explicitly through
        // Server.roundtrip/readHttp. It is mirrored to this.ctx.state.oBody right
        // away so onBeforeRoundtrip hooks and the developer tools see it.
        const oBody = {};
        this.ctx.state.oBody = oBody;

        // Decide which view's model holds the data we need to send back. The
        // mapping is: main app controller -> main view, popup controller ->
        // popup view, etc.
        const oModel = this._pickModelForRoundtrip(useMainModel);

        Lib.runCallbacks(this.ctx.state.onBeforeRoundtrip);

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
          // The value of every path as it goes out. The winning response
          // clears a path only when the model still holds this value
          // (Server._clearSentPaths) - a path re-edited while the request
          // was in flight stays pending and travels with the next roundtrip.
          oModel._z2ui5SentValues = new Map(
            Array.from(changedPaths, (path) => [
              path,
              oModel.getProperty(path),
            ]),
          );
        }
        // Remember which model this request carried so the winning response
        // clears exactly its edits (Server.readHttp) - a stale response clears
        // nothing, and edits in other models stay pending for their own send.
        this.ctx.state.oSentModel = oModel;

        oBody.ID = this.ctx.state.oResponse?.ID;
        // a tick says so (S_FRONT.TIMER, Server.roundtrip): it is the one
        // roundtrip the backend may answer with the draft it continued,
        // when the app changed nothing (z2ui5_cl_ui5_handler=>main_end_reuse)
        if (timer) oBody.TIMER = true;
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

        Server.roundtrip(this.ctx, oBody);
        // "after roundtrip" means AFTER THE DISPATCH, not after the
        // response: readHttp is fire-and-forget, so these callbacks run
        // synchronously once the request went out. A hook that needs the
        // response or the re-rendered view belongs on onAfterRendering.
        Lib.runCallbacks(this.ctx.state.onAfterRoundtrip);
      },

      // Was this event fired by a control of a view the response IN PROCESS
      // is building? A response is in process from the moment View1 claims
      // it until its finally (_processAfterRendering), and the slot records
      // the response that built its view, as its token (ViewSlots.setView).
      // A control can fire before its view has reached the slot - while
      // XMLView.create is still building it - and then the slot tells
      // nothing: when it is
      // EMPTY the event cannot be a click on a screen being replaced, there
      // is none (the first response of a page, a popup being opened); when
      // it still shows the view of an earlier response the event is taken
      // for a click on that one, and dropped as before.
      _firedWhileBuilding() {
        const oResponse = this.ctx.state.oResponse;
        if (!oResponse?._processing) return false;
        const key = ViewSlots.keyOfController(this);
        if (!ViewSlots.getView(this.ctx, key)) return true;
        return ViewSlots.getViewToken(this.ctx, key) === oResponse.TOKEN;
      },

      _pickModelForRoundtrip(useMainModel) {
        // useMainModel forces use of the main view's model even when called
        // from a popup/popover controller.
        const slotKey = useMainModel ? "MAIN" : ViewSlots.keyOfController(this);
        if (!slotKey) return undefined;

        const oView = ViewSlots.getView(this.ctx, slotKey);
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
    return Env.ownClass(View1Controller);
  },
);
