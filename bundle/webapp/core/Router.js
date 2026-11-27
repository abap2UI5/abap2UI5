// The abap2UI5 hash router - the framework counterpart of
// sap.ui.core.routing.Router, and the only module that WRITES the URL hash
// or interprets its structure. Two others read the raw hash and neither
// splits it: core/Server.js ships it as S_FRONT.HASH on every request, and
// core/actions/Launchpad.js takes the part before the "#" as a base URL. A
// module that needs more than that - a route to parse, a hash to split -
// asks this one (parse, splitHash), it does not read location.hash itself.
//
// Why a module of its own: a UI5 app hash means two different things
// depending on where the app runs, and every place that reads or writes the
// hash has to know it. Concentrating that knowledge here is what makes the
// router work inside the SAP Fiori Launchpad as well as standalone.
//
//   standalone   #/app/<CLASS>/<DRAFT>
//   inside FLP   #<SemanticObject>-<action>&/app/<CLASS>/<DRAFT>
//                 \______ shell hash ______/  \___ app hash ___/
//
// The shell owns everything before "&/" (it is how the launchpad knows which
// tile the user is on); the part after it is the "app hash" - the inner hash
// a UI5 router configures its route patterns against. splitHash() is the one
// place that separates the two, so the rest of the frontend - and the backend
// route parser, which mirrors the same rule - only ever deals with app
// hashes. Writing goes through the HashChanger, which is the shell's own
// HashChanger inside the FLP and therefore preserves the shell hash by
// construction.
//
// The routes themselves mirror a UI5 route pattern "app/{class}/{state}":
// the <CLASS> segment names the app (human-readable), the <DRAFT> segment is
// the server draft holding its state, so Back/Forward/reload/bookmark restore
// the EXACT state. In FRESH mode the draft segment is omitted and the app
// restarts clean. Routing is opt-in per app (cs_event-hash_routing, which
// travels under the wire value SET_NAV_ROUTING - the name the hash_* family
// was renamed from, kept so no app's queued action had to move).
sap.ui.define(
  ["sap/ui/core/routing/HashChanger", "z2ui5/core/Lib"],
  (HashChanger, Lib) => {
    "use strict";

    const APP_ROUTE_PREFIX = "/app/";
    // Separates the FLP shell hash from the app (inner) hash.
    const SHELL_SEPARATOR = "&/";

    // Per component (`ctx.router`, core/Context.js): `navigate`, injected by
    // Component.js, runs the roundtrip that restores the app a matched route
    // points at - a callback so the router does not depend on Server
    // (Component wires both and owns their lifecycle); `hashListener` is
    // this context's hashChanged listener on the page's one HashChanger.
    // The URL itself stays page-wide: every routed instance reacts to a
    // hash change, which is why a component leaves the hash to its host - it
    // neither listens (init) nor writes (sync) - unless the host handed the
    // page over (state.ownsPage, Component.init). Both ask ownsPage alone.

    function hashChanger() {
      return HashChanger.getInstance();
    }

    // ------------------------------------------------------------------
    // FLP shell hash vs. app hash
    // ------------------------------------------------------------------

    // Split a hash into its shell and app part. Accepts every form the hash
    // reaches us in: a raw window.location.hash (leading "#"), a HashChanger
    // hash (no "#"), and the newHash of a hashChanged event (already the app
    // hash inside the FLP).
    //
    // The app part is always normalized to a leading "/", the shape every
    // route this router builds has. That absorbs the two spellings the FLP
    // separator produces - "&/app/X" (the launchpad convention, app hashes
    // written without a leading slash) and "&//app/X" (our slash-prefixed
    // routes appended verbatim) - so comparing a hash against a route never
    // depends on which one a ushell release wrote.
    function splitHash(sHash) {
      const raw = String(sHash || "").replace(/^#/, "");
      // An app hash always starts with "/", a shell hash never does - it is
      // "<SemanticObject>-<action>" optionally followed by "?<params>".
      // Checking this FIRST matters: an app hash may legitimately contain
      // "&/" in a query parameter, and splitting on that would truncate it.
      if (!raw || raw.startsWith("/")) return { shell: "", app: raw };
      const i = raw.indexOf(SHELL_SEPARATOR);
      if (i < 0) return { shell: "", app: raw };
      let app = raw.slice(i + SHELL_SEPARATOR.length).replace(/^\/+/, "");
      if (app) app = `/${app}`;
      return { shell: raw.slice(0, i), app };
    }

    function appHashOf(sHash) {
      return splitHash(sHash).app;
    }

    // The app hash the browser currently stands on. Inside the FLP the
    // HashChanger is the shell's own and already returns the inner hash;
    // appHashOf normalizes the standalone case (and any release that hands
    // back the full hash) to the same shape. Standalone, hasher trims the
    // "/" it prepended on write; the FLP shell hands the inner hash back
    // without one - re-add it so comparisons against the slash-prefixed
    // routes this router builds hold on both stacks.
    function getHash() {
      return appHashNormalized(hashChanger().getHash());
    }

    // The same normalization for a hash string from anywhere - a hashChanged
    // event's newHash, a raw location hash, an app's hash_set value -
    // so every comparison in this module runs on one canonical form.
    function appHashNormalized(sHash) {
      const app = appHashOf(sHash);
      // a bare "/" is the EMPTY route (an app pushing its start URL, e.g. a
      // ':section:' pattern without a section): navTo strips the slash and
      // writes the empty hash, so the canonical form must be "" too - as "/"
      // the write's own echo would escape the adopt-compare and round-trip
      if (app === "/") return "";
      return app && !app.startsWith("/") ? `/${app}` : app;
    }

    // The raw hash (shell part included) - for the callers that rebuild a
    // whole URL rather than hand an app hash to the HashChanger. Read
    // straight from the location, not through the HashChanger, which hands
    // out the app part alone inside the FLP.
    function getRawHash() {
      return String(window.location.hash || "").replace(/^#/, "");
    }

    // ------------------------------------------------------------------
    // Route patterns - "app/{class}/{state}"
    // ------------------------------------------------------------------

    function patternFor(sClass, sDraftId) {
      const base = `${APP_ROUTE_PREFIX}${sClass}`;
      return sDraftId ? `${base}/${sDraftId}` : base;
    }

    function segmentsOf(sHash) {
      // tolerate any number of leading slashes: routes written before navTo
      // stripped its slash live on in bookmarks and history as "#//app/X"
      const app = appHashOf(sHash).replace(/^\/+/, "");
      const marker = "app/";
      if (!app.startsWith(marker)) return null;
      // Stop at any route/query separator, then split class / draft id.
      return app.slice(marker.length).split(/[&?]/)[0].split("/");
    }

    // Parse a hash into the route it matches, or null when it is no app
    // route at all (an app-owned hash from cs_event-hash_set, the legacy
    // app-state hash, a bare FLP shell hash - all ignored by the router).
    function parse(sHash) {
      const parts = segmentsOf(sHash);
      if (!parts) return null;
      // A namespaced class (/NS/CL_X) carries the route separator in its
      // own name: patternFor writes "app//NS/CL_X/<draft>", so the token
      // is three segments long - ["", "NS", "CL_X", draft]. Reading only
      // the first segment answered an empty app and no route at all, so
      // Back/Forward between namespaced apps was inert. The backend's
      // route_split read the same shape, until this became the one reader.
      if (parts[0] === "") {
        if (parts.length < 3 || !parts[1] || !parts[2]) return null;
        return {
          app: `/${parts[1]}/${parts[2]}`,
          draft: parts.length > 3 ? parts[3] : "",
        };
      }
      if (!parts[0]) return null;
      return { app: parts[0], draft: parts.length > 1 ? parts[1] : "" };
    }

    // What a hash asks an app START to restore - what the frontend sends as
    // S_FRONT.ROUTE with every request that names no draft (the page load,
    // a Back/Forward restore): the route's class and draft, or the draft of
    // an app-state link, or null when the hash names neither (a normal boot,
    // an app-owned hash, a bare launchpad intent).
    //
    // Until protocol 3 the backend read the same three values out of the raw
    // hash itself (z2ui5_cl_ui5_handler: hash_get_app_part, route_split and
    // four more), a second parser kept equal to this one by hand - the
    // launchpad separator, the stacked leading slashes of older URLs and the
    // namespaced class each had to be taught to both.
    //
    // The app-state link is `#/z2ui5-xapp-state=<id>` (sync below writes it,
    // z2ui5_cl_ui5_client=>app_state_get_href composes it): the id is a
    // parameter of the app hash, so it is found among its `&`-separated
    // parts, behind a `?` when there is one.
    const APP_STATE_PARAM = "z2ui5-xapp-state=";

    function appStateOf(sHash) {
      const app = appHashOf(sHash).replace(/^\/+/, "");
      const query = app.includes("?") ? app.slice(app.indexOf("?") + 1) : app;
      for (const part of query.split("&")) {
        if (part.toLowerCase().startsWith(APP_STATE_PARAM)) {
          return part.slice(APP_STATE_PARAM.length);
        }
      }
      return "";
    }

    function startRoute(sHash) {
      const route = parse(sHash);
      if (route) {
        return route.draft
          ? { APP: route.app, DRAFT: route.draft }
          : { APP: route.app };
      }
      const appState = appStateOf(sHash);
      return appState ? { APP_STATE: appState } : null;
    }

    // ------------------------------------------------------------------
    // Navigation
    // ------------------------------------------------------------------

    // The UI5 navTo equivalent: setHash pushes a new history entry (Back
    // returns to the current app), replaceHash updates the current one in
    // place and leaves the history depth alone. Both go through the
    // HashChanger, so inside the FLP only the app hash is rewritten.
    //
    // The hash is handed over WITHOUT its leading slash: standalone, the
    // HashChanger's engine (hasher, prependHash "/") unconditionally prepends
    // one more - a slash-prefixed route would put "#//app/X" into the URL.
    // Reads through the HashChanger come back trimmed, so the frontend never
    // noticed, but the backend parses window.location.hash raw: the double
    // slash hid the route from it and every browser Back/Forward/reload fell
    // back to the "?app_start=" boot query (the app restarted instead of the
    // routed one being restored). Inside the FLP the shell appends the hash
    // after "&/" - the canonical launchpad spelling is slash-less anyway.
    function navTo(sRoute, bReplace) {
      const sHash = String(sRoute || "").replace(/^\/+/, "");
      if (bReplace) {
        hashChanger().replaceHash(sHash);
      } else {
        hashChanger().setHash(sHash);
      }
    }

    // ------------------------------------------------------------------
    // The trail - which way a browser navigation went
    // ------------------------------------------------------------------

    // The app hashes this page load wrote, in history order, and the
    // position the browser stands on (ctx.router.trail / trailPos) - what
    // UI5's History.getDirection( ) keeps, for the routes of THIS router.
    // The page transition of the MAIN view needs the answer: a browser Back
    // plays the page being left out in reverse (actions/Slots). History
    // itself is not asked: it learns the trail only from the hash changes
    // it witnessed after its module loaded, and every write here goes
    // through this module anyway. A push cuts the forward part off, as the
    // browser does; a replace rewrites the entry the browser stands on.
    function trailWrite(ctx, sHash, bReplace) {
      const r = ctx.router;
      const h = appHashNormalized(sHash);
      if (bReplace && r.trailPos >= 0) {
        r.trail[r.trailPos] = h;
        return;
      }
      r.trail = r.trail.slice(0, r.trailPos + 1);
      r.trail.push(h);
      r.trailPos = r.trail.length - 1;
    }

    // Every write of this module with a context: the trail first, then the
    // hash - the echo the write fires then finds itself where the browser
    // stands and moves nothing.
    function write(ctx, sHash, bReplace) {
      trailWrite(ctx, sHash, bReplace);
      navTo(sHash, bReplace);
    }

    // Move along the trail to the hash the browser now stands on and answer
    // which way that was: "back", "forward", or "" - for the echo of a
    // write (no move), and for a hash that is nowhere on the trail: a
    // manual edit or a bookmark, which the browser adds as a new entry, so
    // the trail does too. The NEAREST occurrence decides, the neighbours
    // first: a FRESH route carries no draft id, so one app can stand on both
    // sides of the current entry - that stays "", as History has it
    // ("Unknown"), and the trail assumes the step back.
    function trailMove(ctx, sHash) {
      const r = ctx.router;
      const h = appHashNormalized(sHash);
      const pos = r.trailPos;
      if (r.trail[pos] === h) return "";
      const prev = pos > 0 && r.trail[pos - 1] === h;
      const next = r.trail[pos + 1] === h;
      if (prev) {
        r.trailPos = pos - 1;
        return next ? "" : "back";
      }
      if (next) {
        r.trailPos = pos + 1;
        return "forward";
      }
      // a longer jump (history.go(-2), the history menu of the button)
      const before = pos > 0 ? r.trail.lastIndexOf(h, pos - 1) : -1;
      if (before >= 0) {
        r.trailPos = before;
        return "back";
      }
      const after = r.trail.indexOf(h, pos + 1);
      if (after >= 0) {
        r.trailPos = after;
        return "forward";
      }
      trailWrite(ctx, h, false);
      return "";
    }

    // A hash write of sync( ) comes in two flavours: a PUSH adds a history
    // entry (Back returns to what was there) and counts towards
    // hashPushCount - navBack's stand-in for UI5's History.getPreviousHash -
    // while a REPLACE writes in place and leaves the history depth alone.
    //
    // A push of the hash the browser already stands on is no push at all:
    // hasher's setHash leaves an unchanged hash alone, so no history entry
    // is added and none may be counted (or put on the trail) - counted, the
    // next navBack took history.back( ) for an in-app step and left the
    // app, or the page, instead of taking its fallback.
    function writeHash(ctx, sHash, bPush) {
      if (bPush && appHashNormalized(sHash) === getHash()) return;
      if (bPush) ctx.state.hashPushCount += 1;
      write(ctx, sHash, !bPush);
    }

    // The UI5 onNavBack pattern (History.getPreviousHash), app-owned - the
    // HASH_BACK frontend action lands here so the hash logic stays in this
    // module. One real step back when this page load has pushed an app hash:
    // the history entry is CONSUMED, and the resulting hashChanged
    // round-trips the registered event like any browser Back. On a cold deep
    // link there is no in-app entry to consume: with a fallback hash the app
    // lands on that route via a REPLACE - deliberately NOT adopted, so the
    // change dispatches the listener and the backend renders the fallback -
    // and without one it behaves like the plain browser button.
    //
    // Only on a page the component owns (state.ownsPage), as sync( ) and
    // init( ) ask: embedded, the history is the HOST's - history.back( )
    // would navigate the host's page and the fallback's replaceHash would
    // overwrite the host's route. Refused and said so, like a hash_set
    // there. Not under the fatal overlay either (state.terminated): the app
    // has ended, and the overlay's Retry / Restart decide what comes next.
    function navBack(ctx, sFallback) {
      if (!ctx?.state?.ownsPage) {
        Lib.logError(
          "Router: hash_back needs the page - the component does not own it (embedded, ownsPage); the history is its host's",
        );
        return;
      }
      if (ctx.state.terminated) return;
      if (!sFallback || ctx.state.hashPushCount > 0) {
        window.history.back();
        return;
      }
      write(ctx, sFallback, true);
    }

    // ------------------------------------------------------------------
    // Route matched - the read side
    // ------------------------------------------------------------------

    // Called for every hash change (browser Back/Forward, a manual URL edit,
    // a bookmark, and the echo of our own writes). The abap2UI5 equivalent of
    // a UI5 route's patternMatched handler: it decides whether the new hash
    // names a DIFFERENT app state than the one on screen and, if so, asks the
    // backend to restore it.
    function onHashChanged(ctx, sNewHash) {
      const state = ctx.state;

      // Every change moves the trail - the echoes of our own writes too,
      // which move nothing - so the NEXT Back/Forward is read against where
      // the browser really stands, whatever this one turns out to be.
      const direction = trailMove(ctx, sNewHash);

      // A Back steps off a pushed entry, a Forward onto one again - so the
      // count navBack reads is the number of in-app entries BEHIND the
      // browser, not the number ever pushed. Counting pushes only made the
      // second in-app Back of a cold deep link call history.back( ) and
      // leave the page, the exact case its fallback exists for.
      if (direction === "back") {
        state.hashPushCount = Math.max(0, state.hashPushCount - 1);
      } else if (direction === "forward") {
        state.hashPushCount += 1;
      }

      // Routing is opt-in per app (cs_event-hash_routing); until one
      // enabled it, the hash belongs entirely to the app (cs_event-hash_set,
      // and - when the app registered one - the HASH_LISTENER event).
      if (!state.navRouting) {
        dispatchAppHashChange(ctx, sNewHash);
        return;
      }

      const route = parse(sNewHash);
      if (!route) return;

      // Ignore the echo of our own hash write after rendering (not a user
      // navigation), so we do not loop. Match on the draft id when the route
      // carries one - that is the precise app state - otherwise on the class.
      if (route.draft) {
        if (route.draft === state.currentDraftId) return;
      } else if (
        route.app.toUpperCase() === String(state.currentApp).toUpperCase()
      ) {
        return;
      }

      // A different app state: restore it. Mark the roundtrip as
      // browser-initiated so the render does NOT rewrite the hash (the
      // browser sits at a non-top history position - rewriting there would
      // drop the forward entries and break the Forward button).
      state.navFromHash = true;
      // ...and which way it went: a Back plays the page being left out in
      // reverse (actions/Slots). Lives and dies with navFromHash.
      state.navDirection = direction;
      if (ctx.router.navigate) ctx.router.navigate();
    }

    // ------------------------------------------------------------------
    // App-owned hash routing (routing OFF) - the setHashEvent option
    // ------------------------------------------------------------------

    // Register a named backend event for hash changes while the APP owns the
    // hash (cs_event-hash_attach_changed). The registration travels as a nav
    // OPTION on the response, not as a follow-up action, because sync( )
    // must already see it on the very response that registers: follow-ups
    // run AFTER the phase-2 sync, and a boot on a deep link (`#/Page2`)
    // would have its hash wiped by the app-state cleanup below before the
    // registration ever ran. While registered, hash_set writes the
    // hash as a real route through the HashChanger (see sync) and the
    // cleanup leaves the hash alone. The value is the event name; a blank
    // (single space) unregisters, empty means "no change" - the same
    // encoding app_state_set_active uses. View1 clears it on an app switch
    // (a response naming another app), AppState.reset( ) on the teardown.
    // Applies with routing OFF only - a routed app's hash belongs to the
    // router, not to the app.
    function applyHashEvent(ctx, mOptions) {
      if (!mOptions.setHashEvent) return;
      const state = ctx.state;
      const sEvent = String(mOptions.setHashEvent).trim();
      state.hashEvent = sEvent || null;
      // adopt the hash the browser stands on as the app's known value, so
      // the first CHANGE - not the registration's own render - dispatches
      state.appHash = appHashNormalized(getRawHash());
    }

    // A hash change while the app owns the hash: swallow the echo of the
    // app's own set_push_state write, adopt the new value, round-trip the
    // registered event on the CURRENT main controller (always the live one,
    // so a rebuilt view needs no re-registration to stay dispatchable). The
    // new hash needs no argument - S_FRONT.HASH rides on every request, so
    // the backend reads it from s_config-hash.
    function dispatchAppHashChange(ctx, sNewHash) {
      const state = ctx.state;
      if (!state.hashEvent) return;
      // Under the fatal overlay (Server.responseError) the app has ended:
      // a hash change must not send its event into the broken session. Not
      // parked either - the overlay's Retry / Restart decide what comes next
      if (state.terminated) return;
      const appHash = appHashNormalized(sNewHash);
      if (appHash === state.appHash) return;
      const controller = state.oController;
      if (!Lib.isControllerAlive(controller)) return;
      // A roundtrip in flight: View1.eB drops an ordinary event on its busy
      // guard. The hash used to be adopted BEFORE that dispatch, so the drop
      // was final - the URL said the new page, the app still showed the old
      // one, and no later change re-dispatched it (Back during a click was
      // enough). Park it instead; the roundtrip's end delivers it through
      // dispatchPendingAppHash. Only the LAST change matters: a browser
      // that went Back twice meanwhile lands on the second.
      if (state.isBusy) {
        state.pendingAppHash = sNewHash;
        return;
      }
      state.pendingAppHash = null;
      state.appHash = appHash;
      controller.eB([state.hashEvent]);
    }

    // The write side of the parking above: called once a roundtrip has
    // landed (View1._processAfterRendering, after isBusy went false).
    function dispatchPendingAppHash(ctx) {
      const state = ctx.state;
      const pending = state.pendingAppHash;
      if (pending == null) return;
      state.pendingAppHash = null;
      dispatchAppHashChange(ctx, pending);
    }

    // ------------------------------------------------------------------
    // Hash sync after a render - the write side
    // ------------------------------------------------------------------

    // Point the CALLING app's history entry at the draft the backend saved
    // for it during this very nav_app_call (the navAppCallPrev* options).
    // That draft carries every client-side change the user made since the
    // caller last rendered - bound switches, checkboxes, input - all
    // of which travelled to the backend with the event that triggered the
    // navigation. The entry itself still carries the older draft of that
    // last render, so without this Back restores the caller as it was
    // RENDERED and silently drops those changes. The entry is still the top
    // one here (the called app's route is pushed right after), so a
    // replaceHash updates it in place and leaves the history depth alone.
    // KEEP mode only - a FRESH route carries no draft and always restarts
    // the app anyway.
    function repointCallerEntry(ctx, mOptions, draftForRoute) {
      const state = ctx.state;
      const prevApp = mOptions.navAppCallPrevApp;
      const prevDraft = mOptions.navAppCallPrevId;
      if (!draftForRoute || !prevApp || !prevDraft) return;
      const prevRoute = patternFor(prevApp, prevDraft);
      if (getHash() === prevRoute) return;
      // onHashChanged ignores the echo of our own hash writes by comparing
      // the route's draft id against currentDraftId - adopt the caller's
      // fresh draft BEFORE replacing, or the write reads as a user
      // navigation and fires a restore roundtrip. The caller of this
      // function sets the state back to the called app right afterwards.
      state.currentDraftId = prevDraft;
      write(ctx, prevRoute, true);
    }

    // Apply the routing mode the backend sent with this response. The flag
    // carries the MODE (z2ui5_if_client=>cs_nav_mode): "KEEP" routes by class
    // + draft id (exact state restored on Back/Forward), "FRESH" routes by
    // class only (Back/Forward start the app fresh); any other non-empty
    // value ("DEFAULT") turns routing back OFF. An EMPTY value is "no change".
    //
    // The backend re-sends the mode with EVERY response of an app that
    // enabled it (it is remembered on the app, not on the session), so the
    // mode follows the app the user is actually looking at - the way UI5
    // routing is configured once in the manifest rather than re-asserted on
    // every navigation.
    function applyMode(ctx, mOptions) {
      if (!mOptions.setNavRouting) return;
      const mode = String(mOptions.setNavRouting).toUpperCase();
      const on = mode === "KEEP" || mode === "FRESH";
      ctx.state.navRouting = on;
      ctx.state.navMode = on ? mode : null;
    }

    // Adopt the rendered app as the current route and write it to the hash.
    // Only called while routing is on and the response named an app.
    function updateAppRoute(ctx, mOptions, ID, app) {
      const state = ctx.state;

      // In FRESH mode the route carries the class only, so every history
      // entry (Back/Forward/reload/bookmark) starts the app fresh; in KEEP
      // mode it carries the draft id too, so they restore the exact preserved
      // state. draftForRoute is what the route (and the echo guard in
      // onHashChanged) uses - null in FRESH, the app-state ID in KEEP.
      const draftForRoute = state.navMode === "FRESH" ? null : ID;
      // Set current app/draft BEFORE touching the hash: the writes below
      // re-fire hashChanged, and onHashChanged compares the incoming route's
      // draft id against currentDraftId to ignore our own echo. In FRESH mode
      // there is no draft, so the guard matches the class.
      state.currentApp = app;
      state.currentDraftId = draftForRoute;

      if (state.navFromHash) {
        // This render is the result of a browser Back/Forward (or a manual
        // hash edit) routed through onHashChanged. The hash already matches
        // this history entry and the browser sits at a non-top position -
        // rewriting it here would drop the forward entries and break the
        // Forward button. Just adopt the state.
        state.navFromHash = false;
        state.navDirection = "";
        return;
      }
      // Reflect the running app in the URL as a bookmarkable route. A forward
      // navigation done in the backend (client->nav_app_call,
      // CHECK_NAV_APP_CALL) pushes a NEW history entry so Back returns to the
      // calling app - the routing equivalent of a UI5 navTo. A plain roundtrip
      // only replaces the current (top) entry, advancing it to the app's
      // latest draft so a later Forward restores the newest state.
      const route = patternFor(app, draftForRoute);
      if (mOptions.checkNavAppCall) {
        // repoint the caller's entry first - it borrows the echo guard, so
        // restore it to this app before pushing the route
        repointCallerEntry(ctx, mOptions, draftForRoute);
        state.currentApp = app;
        state.currentDraftId = draftForRoute;
        // a push like every other: counted, so a hash_back after a
        // nav_app_call consumes this entry instead of taking its fallback
        writeHash(ctx, route, true);
      } else if (getHash() !== route) {
        write(ctx, route, true);
      }
    }

    // Keep the URL in sync with what was just rendered - run once per
    // roundtrip, with the response's NAV section as options (View1). The
    // options object is self-contained: `id` carries the response's draft id.
    function sync(ctx, mOptions) {
      // On a host's page the hash is the host's (Component.init): no route,
      // no app hash, and above all not the per-roundtrip cleanup at the end
      // - its replaceHash("") wipes the host's own route, and a Fiori
      // elements app answers that by leaving its object page for the list.
      // An app there that asks for routing or a hash gets neither - unless
      // its host handed the page over (state.ownsPage).
      if (!ctx.state.ownsPage) return;
      const ID = mOptions.id;
      try {
        applyMode(ctx, mOptions);
        applyHashEvent(ctx, mOptions);

        const state = ctx.state;
        // The hash the app asked to have written, and in which flavour:
        // hash_set adds a history entry, hash_replace writes in place.
        //
        // An app writes the hash only as its OWNER: with routing off and a
        // listener registered (cs_event-hash_attach_changed, applyHashEvent
        // above - the same response may register and write). The value is
        // then the WHOLE app hash, written through the HashChanger, so
        // hasher's cache follows it and the next browser Back fires
        // hashChanged. Anything else is refused and said so: under routing
        // the hash is the router's, and without a listener nobody would
        // hear a Back onto what was written.
        //
        // Until 2026-11 such a write was APPENDED to the hash the page had,
        // as a suffix - behind the route in KEEP mode, with history.pushState
        // otherwise. That bypassed hasher's cache (the next Back was read as
        // "no change" and went nowhere), grew the URL with every roundtrip
        // of an app that wrote a whole route (`#/repo/1/repo/1`), and was
        // what kept the cleanup below from being a rule of its own.
        const sAsked = mOptions.setPushState || mOptions.setHashReplace;
        const bPush = Boolean(mOptions.setPushState);
        const bOwner = !state.navRouting && Boolean(state.hashEvent);
        if (sAsked && !bOwner) {
          Lib.logError(
            `Router: hash_set / hash_replace need the app to own the hash - '${sAsked}' is not written. Register a listener first (cs_event-hash_attach_changed); ${state.navRouting ? "under hash_routing the hash is the router's" : "none is registered"}`,
          );
        }

        if (state.navRouting) {
          const app = state.oResponse?.APP;
          if (app) updateAppRoute(ctx, mOptions, ID, app);
          // Routing owns the hash; the app-state handling below is not its
          return;
        }

        if (sAsked && bOwner) {
          // Adopt the value first so the write's own echo dies in
          // dispatchAppHashChange.
          state.appHash = appHashNormalized(sAsked);
          writeHash(ctx, sAsked, bPush);
          return;
        }
        // While a listener owns the hash, the cleanup below must not touch
        // it: with the app's value in hasher's cache a replaceHash("")
        // counts as a change and would wipe the hash on the NEXT unrelated
        // roundtrip. The listener and the app-state hash are mutually
        // exclusive by construction - both claim the whole app hash.
        if (state.hashEvent) return;
        // The live URL must match the format the share link
        // (z2ui5_cl_ui5_client=>app_state_get_href, which composes it on the
        // BACKEND from the same shell/app split) writes and the backend restore
        // path expects: the app-state id is read as a URL parameter of the
        // app hash, i.e. after exactly one "/". navTo strips the leading
        // slash and standalone hasher prepends exactly one again; inside the
        // FLP the shell appends the slash-less hash after "&/" - both end up
        // in the canonical single-slash form.
        const newHash = mOptions.setAppStateActive
          ? `/z2ui5-xapp-state=${ID || ""}`
          : "";
        write(ctx, newHash, true);
      } catch (e) {
        Lib.logError("Router.sync: history update failed", e);
      }
    }

    // ------------------------------------------------------------------
    // Lifecycle
    // ------------------------------------------------------------------

    function init(ctx, fnNavigate) {
      ctx.router.navigate = fnNavigate;
      // what the hash asks an app start to restore, for the request builder
      // (Server.roundtrip): handed over like `navigate`, so Server does not
      // depend on this module either. Not on a host's page - the hash is the
      // host's route there, and nothing in it is this component's to read
      ctx.router.startRoute = ctx.state.ownsPage
        ? () => startRoute(window.location.hash)
        : null;
      // Embedded, there is no hash of ours to listen to, and the host has
      // initialized the HashChanger itself if it routes at all - a host
      // route change is none of this component's business. A host that
      // handed the page over (state.ownsPage) routes by nothing: the
      // component listens and initializes the engine as on a page of its
      // own.
      if (!ctx.state.ownsPage) return;
      // Listening to the HashChanger's hashChanged event is what makes the
      // native browser Back/Forward buttons - and the FLP shell's back
      // button, which drives the same history - navigate between apps.
      const listener = (oEvent) =>
        onHashChanged(ctx, oEvent.getParameter("newHash"));
      ctx.router.hashListener = listener;
      hashChanger().attachEvent("hashChanged", listener);

      // The stopped router removed with the manifest routing section used to
      // initialize the HashChanger (and its underlying hasher singleton) as a
      // side effect. Without that init hasher never learns the URL's current
      // hash, so the app-state cleanup after every roundtrip (sync calling
      // navTo("", true)) is treated as a change and rewrites the URL to
      // "...#" - every app start ended with a dangling "#". Initialize it
      // explicitly; inside the FLP the shell has already done this and
      // init() is a guarded no-op.
      hashChanger().init();
    }

    function exit(ctx) {
      const listener = ctx.router.hashListener;
      if (listener) {
        hashChanger().detachEvent("hashChanged", listener);
        ctx.router.hashListener = null;
      }
      ctx.router.navigate = null;
      ctx.router.startRoute = null;
    }

    return {
      init,
      exit,
      splitHash,
      patternFor,
      parse,
      startRoute,
      navTo,
      navBack,
      onHashChanged,
      dispatchPendingAppHash,
      sync,
    };
  },
);
