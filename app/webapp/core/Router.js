// The abap2UI5 hash router - the framework counterpart of
// sap.ui.core.routing.Router, and the ONLY module that touches the URL hash.
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
// restarts clean. Routing is opt-in per app (cs_event-set_nav_routing).
sap.ui.define(
  ["sap/ui/core/routing/HashChanger", "z2ui5/core/AppState", "z2ui5/core/Lib"],
  (HashChanger, AppState, Lib) => {
    "use strict";

    const APP_ROUTE_PREFIX = "/app/";
    // Separates the FLP shell hash from the app (inner) hash.
    const SHELL_SEPARATOR = "&/";

    // Injected by Component.js - runs the roundtrip that restores the app a
    // matched route points at. Kept as a callback so the router does not
    // depend on Server (Component wires both and owns their lifecycle).
    let _fnNavigate = null;
    let _boundHashChanged = null;

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
    // event's newHash, a raw location hash, an app's set_push_state value -
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

    // Build an absolute URL for an app hash, keeping the FLP shell hash in
    // place so the link reopens the same launchpad target. Used by the
    // copy-link features - a bare `location.href.split("#")[0] + "#" + hash`
    // would drop the shell hash and land the recipient on the FLP home page.
    function hrefFor(sAppHash) {
      const base = window.location.href.split("#")[0];
      const raw = String(window.location.hash || "").replace(/^#/, "");
      let shell = splitHash(raw).shell;
      // location.hash is the RAW hash: a bare non-"/" form is a launchpad
      // intent opened from the tile - ALL shell - even though splitHash
      // (built for the inner-hash shape the HashChanger hands out) reads it
      // as app. Dropping it would land the recipient on the FLP home page.
      // Mirrors the backend's hash_get_shell_part( check_bare_is_shell ).
      if (!shell && raw && !raw.startsWith("/")) shell = raw;
      if (!shell) return `${base}#${sAppHash}`;
      // Canonical launchpad spelling: the "/" of "&/" already opens the app
      // hash, so the app hash itself is appended without its leading slash.
      return `${base}#${shell}${SHELL_SEPARATOR}${String(sAppHash).replace(/^\/+/, "")}`;
    }

    // The raw hash (shell part included) - for callers that rebuild a whole
    // URL rather than hand an app hash to the HashChanger.
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
    // route at all (an app-owned hash from set_push_state, the legacy
    // app-state hash, a bare FLP shell hash - all ignored by the router).
    function parse(sHash) {
      const parts = segmentsOf(sHash);
      if (!parts || !parts[0]) return null;
      return { app: parts[0], draft: parts.length > 1 ? parts[1] : "" };
    }

    function appOf(sHash) {
      const route = parse(sHash);
      return route ? route.app : "";
    }

    function draftOf(sHash) {
      const route = parse(sHash);
      return route ? route.draft : "";
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

    // The UI5 onNavBack pattern (History.getPreviousHash), app-owned - the
    // HASH_BACK frontend action lands here so the hash logic stays in this
    // module. One real step back when this page load has pushed an app hash:
    // the history entry is CONSUMED, and the resulting hashChanged
    // round-trips the registered event like any browser Back. On a cold deep
    // link there is no in-app entry to consume: with a fallback hash the app
    // lands on that route via a REPLACE - deliberately NOT adopted, so the
    // change dispatches the listener and the backend renders the fallback -
    // and without one it behaves like the plain browser button.
    function navBack(sFallback) {
      if (!sFallback || AppState.state.hashPushCount > 0) {
        window.history.back();
        return;
      }
      navTo(sFallback, true);
    }

    // ------------------------------------------------------------------
    // Route matched - the read side
    // ------------------------------------------------------------------

    // Called for every hash change (browser Back/Forward, a manual URL edit,
    // a bookmark, and the echo of our own writes). The abap2UI5 equivalent of
    // a UI5 route's patternMatched handler: it decides whether the new hash
    // names a DIFFERENT app state than the one on screen and, if so, asks the
    // backend to restore it.
    function onHashChanged(sNewHash) {
      const state = AppState.state;

      // Routing is opt-in per app (cs_event-set_nav_routing); until one
      // enabled it, the hash belongs entirely to the app (set_push_state,
      // and - when the app registered one - the HASH_LISTENER event).
      if (!state.navRouting) {
        dispatchAppHashChange(sNewHash);
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
      if (_fnNavigate) _fnNavigate();
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
    // encoding app_state_set_active uses. AppState's reset clears it on an
    // app switch. Applies with routing OFF only - a routed app's hash
    // belongs to the router, not to the app.
    function applyHashEvent(mOptions) {
      if (!mOptions.setHashEvent) return;
      const state = AppState.state;
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
    function dispatchAppHashChange(sNewHash) {
      const state = AppState.state;
      if (!state.hashEvent) return;
      const appHash = appHashNormalized(sNewHash);
      if (appHash === state.appHash) return;
      const controller = state.oController;
      if (!controller || !Lib.isControllerAlive(controller)) return;
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
    function dispatchPendingAppHash() {
      const state = AppState.state;
      const pending = state.pendingAppHash;
      if (pending === null || pending === undefined) return;
      state.pendingAppHash = null;
      dispatchAppHashChange(pending);
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
    function repointCallerEntry(mOptions, draftForRoute) {
      const state = AppState.state;
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
      navTo(prevRoute, true);
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
    function applyMode(mOptions) {
      if (!mOptions.setNavRouting) return;
      const mode = String(mOptions.setNavRouting).toUpperCase();
      const on = mode === "KEEP" || mode === "FRESH";
      AppState.state.navRouting = on;
      AppState.state.navMode = on ? mode : null;
    }

    // Adopt the rendered app as the current route and write it to the hash.
    // Only called while routing is on and the response named an app.
    function updateAppRoute(mOptions, ID, app) {
      const state = AppState.state;

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
        return;
      }
      if (mOptions.setPushState || mOptions.setHashReplace) return;

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
        repointCallerEntry(mOptions, draftForRoute);
        state.currentApp = app;
        state.currentDraftId = draftForRoute;
        navTo(route);
      } else if (getHash() !== route) {
        navTo(route, true);
      }
    }

    // Keep the URL in sync with what was just rendered - the ROUTER/sync
    // system action, run once per roundtrip. The options object is
    // self-contained: `id` carries the response's draft id.
    function sync(mOptions) {
      const ID = mOptions.id;
      try {
        applyMode(mOptions);
        applyHashEvent(mOptions);

        const state = AppState.state;
        if (state.navRouting) {
          const app = state.oResponse?.APP;
          if (app) updateAppRoute(mOptions, ID, app);
          // Routing owns the app-state hash; skip the legacy handling below.
          if (!mOptions.setPushState && !mOptions.setHashReplace) return;
          // In KEEP mode the suffix is pushed as a real ROUTE through the
          // HashChanger, not via history.pushState: pushState writes the URL
          // bar but not hasher's cached hash, so the next browser Back lands
          // exactly on the cached value, hasher reads "no change", and the
          // restore roundtrip never fires - the one Back the push exists
          // for. Through setHash the cache follows the push, the echo
          // parses to the CURRENT draft and dies in onHashChanged's guard,
          // and Back reaches the pre-event draft the entry below kept (the
          // updateAppRoute skip above). Forward restores this draft, with
          // the suffix riding behind it for the app to read. FRESH carries
          // no draft id, so a suffix there would PARSE as one - it stays on
          // the legacy push below, where Back is inert by design (a FRESH
          // route restarts the app either way).
          if (state.currentDraftId) {
            if (mOptions.setPushState) {
              state.hashPushCount += 1;
              navTo(
                patternFor(state.currentApp, state.currentDraftId) +
                  mOptions.setPushState,
              );
            } else {
              // the replace twin: the same route+suffix write, in place -
              // no new history entry, Back does not step through it
              navTo(
                patternFor(state.currentApp, state.currentDraftId) +
                  mOptions.setHashReplace,
                true,
              );
            }
            return;
          }
        }

        if (mOptions.setPushState) {
          if (state.hashEvent) {
            // The app owns the hash AND listens for its changes: write the
            // value as the real app hash through the HashChanger - a pushed
            // history entry hasher's cache follows, so the next browser Back
            // fires hashChanged instead of being read as "no change" (the
            // history.pushState below bypasses that cache). Adopt the value
            // first so the write's own echo dies in dispatchAppHashChange.
            state.appHash = appHashNormalized(mOptions.setPushState);
            state.hashPushCount += 1;
            navTo(mOptions.setPushState);
            return;
          }
          // The app pushes its own hash suffix. Build the new URL on the RAW
          // hash so the FLP shell hash survives - appending to the app hash
          // alone would rewrite "#SO-action&/x" to "#x" and strand the
          // launchpad.
          const newUrl = `${window.location.pathname}${window.location.search}#${getRawHash()}${mOptions.setPushState}`;
          state.hashPushCount += 1;
          history.pushState(null, "", newUrl);
          // The pushed hash IS the desired URL - stop here. The cleanup below
          // is a no-op while hasher's cached hash is empty (legacy mode), but
          // with routing on the cache holds the app route, so replaceHash("")
          // would count as a change and wipe both the route and the suffix
          // pushed one line above.
          return;
        }

        if (mOptions.setHashReplace) {
          if (state.hashEvent) {
            // the replace twin of the push above: adopt first so the write's
            // own echo dies, then write WITHOUT a new history entry - the
            // router's navTo( ..., true ), e.g. an FCL navigation arrow
            state.appHash = appHashNormalized(mOptions.setHashReplace);
            navTo(mOptions.setHashReplace, true);
            return;
          }
          // legacy replace: the same suffix-on-raw-hash URL as the legacy
          // push, written in place
          const replUrl = `${window.location.pathname}${window.location.search}#${getRawHash()}${mOptions.setHashReplace}`;
          history.replaceState(null, "", replUrl);
          return;
        }
        // While a HASH_LISTENER owns the hash, the cleanup below must not
        // touch it: with the app's value in hasher's cache a replaceHash("")
        // counts as a change and would wipe the hash on the NEXT unrelated
        // roundtrip (the legacy pushState only survived it because the cache
        // was desynced). The listener and the app-state hash are mutually
        // exclusive by construction - both claim the whole app hash.
        if (state.hashEvent) return;
        // The live URL must match the format the copy link
        // (FrontendAction.evClipboardAppState) writes and the backend restore
        // path expects: the app-state id is read as a URL parameter of the
        // app hash, i.e. after exactly one "/". navTo strips the leading
        // slash and standalone hasher prepends exactly one again; inside the
        // FLP the shell appends the slash-less hash after "&/" - both end up
        // in the canonical single-slash form.
        const newHash = mOptions.setAppStateActive
          ? `/z2ui5-xapp-state=${ID || ""}`
          : "";
        navTo(newHash, true);
      } catch (e) {
        Lib.logError("Router.sync: history update failed", e);
      }
    }

    // ------------------------------------------------------------------
    // Lifecycle
    // ------------------------------------------------------------------

    function init(fnNavigate) {
      _fnNavigate = fnNavigate;
      // Listening to the HashChanger's hashChanged event is what makes the
      // native browser Back/Forward buttons - and the FLP shell's back
      // button, which drives the same history - navigate between apps.
      _boundHashChanged = (oEvent) =>
        onHashChanged(oEvent.getParameter("newHash"));
      hashChanger().attachEvent("hashChanged", _boundHashChanged);

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

    function exit() {
      if (_boundHashChanged) {
        hashChanger().detachEvent("hashChanged", _boundHashChanged);
        _boundHashChanged = null;
      }
      _fnNavigate = null;
    }

    return {
      init,
      exit,
      splitHash,
      hrefFor,
      patternFor,
      parse,
      appOf,
      draftOf,
      navTo,
      navBack,
      onHashChanged,
      dispatchPendingAppHash,
      sync,
    };
  },
);
