* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_router_js DEFINITION
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


CLASS z2ui5_cl_app_router_js IMPLEMENTATION.

  METHOD get.

    result = `// The abap2UI5 hash router - the framework counterpart of` && |\n| &&
             `// sap.ui.core.routing.Router, and the ONLY module that touches the URL hash.` && |\n| &&
             `//` && |\n| &&
             `// Why a module of its own: a UI5 app hash means two different things` && |\n| &&
             `// depending on where the app runs, and every place that reads or writes the` && |\n| &&
             `// hash has to know it. Concentrating that knowledge here is what makes the` && |\n| &&
             `// router work inside the SAP Fiori Launchpad as well as standalone.` && |\n| &&
             `//` && |\n| &&
             `//   standalone   #/app/<CLASS>/<DRAFT>` && |\n| &&
             `//   inside FLP   #<SemanticObject>-<action>&/app/<CLASS>/<DRAFT>` && |\n| &&
             `//                 \______ shell hash ______/  \___ app hash ___/` && |\n| &&
             `//` && |\n| &&
             `// The shell owns everything before "&/" (it is how the launchpad knows which` && |\n| &&
             `// tile the user is on); the part after it is the "app hash" - the inner hash` && |\n| &&
             `// a UI5 router configures its route patterns against. splitHash() is the one` && |\n| &&
             `// place that separates the two, so the rest of the frontend - and the backend` && |\n| &&
             `// route parser, which mirrors the same rule - only ever deals with app` && |\n| &&
             `// hashes. Writing goes through the HashChanger, which is the shell's own` && |\n| &&
             `// HashChanger inside the FLP and therefore preserves the shell hash by` && |\n| &&
             `// construction.` && |\n| &&
             `//` && |\n| &&
             `// The routes themselves mirror a UI5 route pattern "app/{class}/{state}":` && |\n| &&
             `// the <CLASS> segment names the app (human-readable), the <DRAFT> segment is` && |\n| &&
             `// the server draft holding its state, so Back/Forward/reload/bookmark restore` && |\n| &&
             `// the EXACT state. In FRESH mode the draft segment is omitted and the app` && |\n| &&
             `// restarts clean. Routing is opt-in per app (client->set_nav_routing).` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/routing/HashChanger", "z2ui5/core/AppState", "z2ui5/core/Lib"],` && |\n| &&
             `  (HashChanger, AppState, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    const APP_ROUTE_PREFIX = "/app/";` && |\n| &&
             `    // Separates the FLP shell hash from the app (inner) hash.` && |\n| &&
             `    const SHELL_SEPARATOR = "&/";` && |\n| &&
             `` && |\n| &&
             `    // Injected by Component.js - runs the roundtrip that restores the app a` && |\n| &&
             `    // matched route points at. Kept as a callback so the router does not` && |\n| &&
             `    // depend on Server (Component wires both and owns their lifecycle).` && |\n| &&
             `    let _fnNavigate = null;` && |\n| &&
             `    let _boundHashChanged = null;` && |\n| &&
             `` && |\n| &&
             `    function hashChanger() {` && |\n| &&
             `      return HashChanger.getInstance();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // FLP shell hash vs. app hash` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Split a hash into its shell and app part. Accepts every form the hash` && |\n| &&
             `    // reaches us in: a raw window.location.hash (leading "#"), a HashChanger` && |\n| &&
             `    // hash (no "#"), and the newHash of a hashChanged event (already the app` && |\n| &&
             `    // hash inside the FLP).` && |\n| &&
             `    //` && |\n| &&
             `    // The app part is always normalized to a leading "/", the shape every` && |\n| &&
             `    // route this router builds has. That absorbs the two spellings the FLP` && |\n| &&
             `    // separator produces - "&/app/X" (the launchpad convention, app hashes` && |\n| &&
             `    // written without a leading slash) and "&//app/X" (our slash-prefixed` && |\n| &&
             `    // routes appended verbatim) - so comparing a hash against a route never` && |\n| &&
             `    // depends on which one a ushell release wrote.` && |\n| &&
             `    function splitHash(sHash) {` && |\n| &&
             `      const raw = String(sHash || "").replace(/^#/, "");` && |\n| &&
             `      // An app hash always starts with "/", a shell hash never does - it is` && |\n| &&
             `      // "<SemanticObject>-<action>" optionally followed by "?<params>".` && |\n| &&
             `      // Checking this FIRST matters: an app hash may legitimately contain` && |\n| &&
             `      // "&/" in a query parameter, and splitting on that would truncate it.` && |\n| &&
             `      if (!raw || raw.startsWith("/")) return { shell: "", app: raw };` && |\n| &&
             `      const i = raw.indexOf(SHELL_SEPARATOR);` && |\n| &&
             `      if (i < 0) return { shell: "", app: raw };` && |\n| &&
             `      let app = raw.slice(i + SHELL_SEPARATOR.length).replace(/^\/+/, "");` && |\n| &&
             `      if (app) app = ``/${app}``;` && |\n| &&
             `      return { shell: raw.slice(0, i), app };` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function appHashOf(sHash) {` && |\n| &&
             `      return splitHash(sHash).app;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The app hash the browser currently stands on. Inside the FLP the` && |\n| &&
             `    // HashChanger is the shell's own and already returns the inner hash;` && |\n| &&
             `    // appHashOf normalizes the standalone case (and any release that hands` && |\n| &&
             `    // back the full hash) to the same shape. Standalone, hasher trims the` && |\n| &&
             `    // "/" it prepended on write; the FLP shell hands the inner hash back` && |\n| &&
             `    // without one - re-add it so comparisons against the slash-prefixed` && |\n| &&
             `    // routes this router builds hold on both stacks.` && |\n| &&
             `    function getHash() {` && |\n| &&
             `      const app = appHashOf(hashChanger().getHash());` && |\n| &&
             `      return app && !app.startsWith("/") ? ``/${app}`` : app;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Build an absolute URL for an app hash, keeping the FLP shell hash in` && |\n| &&
             `    // place so the link reopens the same launchpad target. Used by the` && |\n| &&
             `    // copy-link features - a bare ``location.href.split("#")[0] + "#" + hash``` && |\n| &&
             `    // would drop the shell hash and land the recipient on the FLP home page.` && |\n| &&
             `    function hrefFor(sAppHash) {` && |\n| &&
             `      const base = window.location.href.split("#")[0];` && |\n| &&
             `      const shell = splitHash(window.location.hash).shell;` && |\n| &&
             `      if (!shell) return ``${base}#${sAppHash}``;` && |\n| &&
             `      // Canonical launchpad spelling: the "/" of "&/" already opens the app` && |\n| &&
             `      // hash, so the app hash itself is appended without its leading slash.` && |\n| &&
             `      return ``${base}#${shell}${SHELL_SEPARATOR}${String(sAppHash).replace(/^\/+/, "")}``;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // The raw hash (shell part included) - for callers that rebuild a whole` && |\n| &&
             `    // URL rather than hand an app hash to the HashChanger.` && |\n| &&
             `    function getRawHash() {` && |\n| &&
             `      return String(window.location.hash || "").replace(/^#/, "");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Route patterns - "app/{class}/{state}"` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function patternFor(sClass, sDraftId) {` && |\n| &&
             `      const base = ``${APP_ROUTE_PREFIX}${sClass}``;` && |\n| &&
             `      return sDraftId ? ``${base}/${sDraftId}`` : base;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function segmentsOf(sHash) {` && |\n| &&
             `      // tolerate any number of leading slashes: routes written before navTo` && |\n| &&
             `      // stripped its slash live on in bookmarks and history as "#//app/X"` && |\n| &&
             `      const app = appHashOf(sHash).replace(/^\/+/, "");` && |\n| &&
             `      const marker = "app/";` && |\n| &&
             `      if (!app.startsWith(marker)) return null;` && |\n| &&
             `      // Stop at any route/query separator, then split class / draft id.` && |\n| &&
             `      return app.slice(marker.length).split(/[&?]/)[0].split("/");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Parse a hash into the route it matches, or null when it is no app` && |\n| &&
             `    // route at all (an app-owned hash from set_push_state, the legacy` && |\n| &&
             `    // app-state hash, a bare FLP shell hash - all ignored by the router).` && |\n| &&
             `    function parse(sHash) {` && |\n| &&
             `      const parts = segmentsOf(sHash);` && |\n| &&
             `      if (!parts || !parts[0]) return null;` && |\n| &&
             `      return { app: parts[0], draft: parts.length > 1 ? parts[1] : "" };` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function appOf(sHash) {` && |\n| &&
             `      const route = parse(sHash);` && |\n| &&
             `      return route ? route.app : "";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function draftOf(sHash) {` && |\n| &&
             `      const route = parse(sHash);` && |\n| &&
             `      return route ? route.draft : "";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Navigation` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // The UI5 navTo equivalent: setHash pushes a new history entry (Back` && |\n| &&
             `    // returns to the current app), replaceHash updates the current one in` && |\n| &&
             `    // place and leaves the history depth alone. Both go through the` && |\n| &&
             `    // HashChanger, so inside the FLP only the app hash is rewritten.` && |\n| &&
             `    //` && |\n| &&
             `    // The hash is handed over WITHOUT its leading slash: standalone, the` && |\n| &&
             `    // HashChanger's engine (hasher, prependHash "/") unconditionally prepends` && |\n| &&
             `    // one more - a slash-prefixed route would put "#//app/X" into the URL.` && |\n| &&
             `    // Reads through the HashChanger come back trimmed, so the frontend never` && |\n| &&
             `    // noticed, but the backend parses window.location.hash raw: the double` && |\n| &&
             `    // slash hid the route from it and every browser Back/Forward/reload fell` && |\n| &&
             `    // back to the "?app_start=" boot query (the app restarted instead of the` && |\n| &&
             `    // routed one being restored). Inside the FLP the shell appends the hash` && |\n| &&
             `    // after "&/" - the canonical launchpad spelling is slash-less anyway.` && |\n| &&
             `    function navTo(sRoute, bReplace) {` && |\n| &&
             `      const sHash = String(sRoute || "").replace(/^\/+/, "");` && |\n| &&
             `      if (bReplace) {` && |\n| &&
             `        hashChanger().replaceHash(sHash);` && |\n| &&
             `      } else {` && |\n| &&
             `        hashChanger().setHash(sHash);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Navigate to an app class by route (the NAV_TO_ROUTE frontend action).` && |\n| &&
             `    function navToApp(sClassOrRoute) {` && |\n| &&
             `      const cls = appOf(sClassOrRoute) || sClassOrRoute;` && |\n| &&
             `      navTo(patternFor(cls));` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Route matched - the read side` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Called for every hash change (browser Back/Forward, a manual URL edit,` && |\n| &&
             `    // a bookmark, and the echo of our own writes). The abap2UI5 equivalent of` && |\n| &&
             `    // a UI5 route's patternMatched handler: it decides whether the new hash` && |\n| &&
             `    // names a DIFFERENT app state than the one on screen and, if so, asks the` && |\n| &&
             `    // backend to restore it.` && |\n| &&
             `    function onHashChanged(sNewHash) {` && |\n| &&
             `      const state = AppState.state;` && |\n| &&
             `` && |\n| &&
             `      // Routing is opt-in per app (client->set_nav_routing); until one` && |\n| &&
             `      // enabled it, the hash belongs entirely to the app (set_push_state).` && |\n| &&
             `      if (!state.navRouting) return;` && |\n| &&
             `` && |\n| &&
             `      const route = parse(sNewHash);` && |\n| &&
             `      if (!route) return;` && |\n| &&
             `` && |\n| &&
             `      // Ignore the echo of our own hash write after rendering (not a user` && |\n| &&
             `      // navigation), so we do not loop. Match on the draft id when the route` && |\n| &&
             `      // carries one - that is the precise app state - otherwise on the class.` && |\n| &&
             `      if (route.draft) {` && |\n| &&
             `        if (route.draft === state.currentDraftId) return;` && |\n| &&
             `      } else if (` && |\n| &&
             `        route.app.toUpperCase() === String(state.currentApp).toUpperCase()` && |\n| &&
             `      ) {` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `` && |\n| &&
             `      // A different app state: restore it. Mark the roundtrip as` && |\n| &&
             `      // browser-initiated so the render does NOT rewrite the hash (the` && |\n| &&
             `      // browser sits at a non-top history position - rewriting there would` && |\n| &&
             `      // drop the forward entries and break the Forward button).` && |\n| &&
             `      state.navFromHash = true;` && |\n| &&
             `      if (_fnNavigate) _fnNavigate();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Hash sync after a render - the write side` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    // Point the CALLING app's history entry at the draft the backend saved` && |\n| &&
             `    // for it during this very nav_app_call (PARAMS.NAV_APP_CALL_PREV_*).` && |\n| &&
             `    // That draft carries every client-side change the user made since the` && |\n| &&
             `    // caller last rendered - two-way bound switches, checkboxes, input - all` && |\n| &&
             `    // of which travelled to the backend with the event that triggered the` && |\n| &&
             `    // navigation. The entry itself still carries the older draft of that` && |\n| &&
             `    // last render, so without this Back restores the caller as it was` && |\n| &&
             `    // RENDERED and silently drops those changes. The entry is still the top` && |\n| &&
             `    // one here (the called app's route is pushed right after), so a` && |\n| &&
             `    // replaceHash updates it in place and leaves the history depth alone.` && |\n| &&
             `    // KEEP mode only - a FRESH route carries no draft and always restarts` && |\n| &&
             `    // the app anyway.` && |\n| &&
             `    function repointCallerEntry(PARAMS, draftForRoute) {` && |\n| &&
             `      const state = AppState.state;` && |\n| &&
             `      const prevApp = PARAMS.NAV_APP_CALL_PREV_APP;` && |\n| &&
             `      const prevDraft = PARAMS.NAV_APP_CALL_PREV_ID;` && |\n| &&
             `      if (!draftForRoute || !prevApp || !prevDraft) return;` && |\n| &&
             `      const prevRoute = patternFor(prevApp, prevDraft);` && |\n| &&
             `      if (getHash() === prevRoute) return;` && |\n| &&
             `      // onHashChanged ignores the echo of our own hash writes by comparing` && |\n| &&
             `      // the route's draft id against currentDraftId - adopt the caller's` && |\n| &&
             `      // fresh draft BEFORE replacing, or the write reads as a user` && |\n| &&
             `      // navigation and fires a restore roundtrip. The caller of this` && |\n| &&
             `      // function sets the state back to the called app right afterwards.` && |\n| &&
             `      state.currentDraftId = prevDraft;` && |\n| &&
             `      navTo(prevRoute, true);` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Apply the routing mode the backend sent with this response. The flag` && |\n| &&
             `    // carries the MODE (z2ui5_if_client=>cs_nav_mode): "KEEP" routes by class` && |\n| &&
             `    // + draft id (exact state restored on Back/Forward), "FRESH" routes by` && |\n| &&
             `    // class only (Back/Forward start the app fresh); any other non-empty` && |\n| &&
             `    // value ("DEFAULT") turns routing back OFF. An EMPTY value is "no change".` && |\n| &&
             `    //` && |\n| &&
             `    // The backend re-sends the mode with EVERY response of an app that` && |\n| &&
             `    // enabled it (it is remembered on the app, not on the session), so the` && |\n| &&
             `    // mode follows the app the user is actually looking at - the way UI5` && |\n| &&
             `    // routing is configured once in the manifest rather than re-asserted on` && |\n| &&
             `    // every navigation.` && |\n| &&
             `    function applyMode(PARAMS) {` && |\n| &&
             `      if (!PARAMS.SET_NAV_ROUTING) return;` && |\n| &&
             `      const mode = String(PARAMS.SET_NAV_ROUTING).toUpperCase();` && |\n| &&
             `      const on = mode === "KEEP" || mode === "FRESH";` && |\n| &&
             `      AppState.state.navRouting = on;` && |\n| &&
             `      AppState.state.navMode = on ? mode : null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Adopt the rendered app as the current route and write it to the hash.` && |\n| &&
             `    // Only called while routing is on and the response named an app.` && |\n| &&
             `    function updateAppRoute(PARAMS, ID, app) {` && |\n| &&
             `      const state = AppState.state;` && |\n| &&
             `` && |\n| &&
             `      // In FRESH mode the route carries the class only, so every history` && |\n| &&
             `      // entry (Back/Forward/reload/bookmark) starts the app fresh; in KEEP` && |\n| &&
             `      // mode it carries the draft id too, so they restore the exact preserved` && |\n| &&
             `      // state. draftForRoute is what the route (and the echo guard in` && |\n| &&
             `      // onHashChanged) uses - null in FRESH, the app-state ID in KEEP.` && |\n| &&
             `      const draftForRoute = state.navMode === "FRESH" ? null : ID;` && |\n| &&
             `      // Set current app/draft BEFORE touching the hash: the writes below` && |\n| &&
             `      // re-fire hashChanged, and onHashChanged compares the incoming route's` && |\n| &&
             `      // draft id against currentDraftId to ignore our own echo. In FRESH mode` && |\n| &&
             `      // there is no draft, so the guard matches the class.` && |\n| &&
             `      state.currentApp = app;` && |\n| &&
             `      state.currentDraftId = draftForRoute;` && |\n| &&
             `` && |\n| &&
             `      if (state.navFromHash) {` && |\n| &&
             `        // This render is the result of a browser Back/Forward (or a manual` && |\n| &&
             `        // hash edit) routed through onHashChanged. The hash already matches` && |\n| &&
             `        // this history entry and the browser sits at a non-top position -` && |\n| &&
             `        // rewriting it here would drop the forward entries and break the` && |\n| &&
             `        // Forward button. Just adopt the state.` && |\n| &&
             `        state.navFromHash = false;` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      if (PARAMS.SET_PUSH_STATE) return;` && |\n| &&
             `` && |\n| &&
             `      // Reflect the running app in the URL as a bookmarkable route. A forward` && |\n| &&
             `      // navigation done in the backend (client->nav_app_call,` && |\n| &&
             `      // CHECK_NAV_APP_CALL) pushes a NEW history entry so Back returns to the` && |\n| &&
             `      // calling app - the routing equivalent of a UI5 navTo. A plain roundtrip` && |\n| &&
             `      // only replaces the current (top) entry, advancing it to the app's` && |\n| &&
             `      // latest draft so a later Forward restores the newest state.` && |\n| &&
             `      const route = patternFor(app, draftForRoute);` && |\n| &&
             `      if (PARAMS.CHECK_NAV_APP_CALL) {` && |\n| &&
             `        // repoint the caller's entry first - it borrows the echo guard, so` && |\n| &&
             `        // restore it to this app before pushing the route` && |\n| &&
             `        repointCallerEntry(PARAMS, draftForRoute);` && |\n| &&
             `        state.currentApp = app;` && |\n| &&
             `        state.currentDraftId = draftForRoute;` && |\n| &&
             `        navTo(route);` && |\n| &&
             `      } else if (getHash() !== route) {` && |\n| &&
             `        navTo(route, true);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // Keep the URL in sync with what was just rendered. Called once per` && |\n| &&
             `    // roundtrip from View1's after-render phase.` && |\n| &&
             `    function sync(PARAMS, ID) {` && |\n| &&
             `      try {` && |\n| &&
             `        applyMode(PARAMS);` && |\n| &&
             `` && |\n| &&
             `        const state = AppState.state;` && |\n| &&
             `        if (state.navRouting) {` && |\n| &&
             `          const app = state.oResponse?.APP;` && |\n| &&
             `          if (app) updateAppRoute(PARAMS, ID, app);` && |\n| &&
             `          // Routing owns the app-state hash; skip the legacy handling below.` && |\n| &&
             `          if (!PARAMS.SET_PUSH_STATE) return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (PARAMS.SET_PUSH_STATE) {` && |\n| &&
             `          // The app pushes its own hash suffix. Build the new URL on the RAW` && |\n| &&
             `          // hash so the FLP shell hash survives - appending to the app hash` && |\n| &&
             `          // alone would rewrite "#SO-action&/x" to "#x" and strand the` && |\n| &&
             `          // launchpad.` && |\n| &&
             `          const newUrl = ``${window.location.pathname}${window.location.search}#${getRawHash()}${PARAMS.SET_PUSH_STATE}``;` && |\n| &&
             `          history.pushState(null, "", newUrl);` && |\n| &&
             `          // The pushed hash IS the desired URL - stop here. The cleanup below` && |\n| &&
             `          // is a no-op while hasher's cached hash is empty (legacy mode), but` && |\n| &&
             `          // with routing on the cache holds the app route, so replaceHash("")` && |\n| &&
             `          // would count as a change and wipe both the route and the suffix` && |\n| &&
             `          // pushed one line above.` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        // The live URL must match the format the copy link` && |\n| &&
             `        // (FrontendAction.evClipboardAppState) writes and the backend restore` && |\n| &&
             `        // path expects: the app-state id is read as a URL parameter of the` && |\n| &&
             `        // app hash, i.e. after exactly one "/". navTo strips the leading` && |\n| &&
             `        // slash and standalone hasher prepends exactly one again; inside the` && |\n| &&
             `        // FLP the shell appends the slash-less hash after "&/" - both end up` && |\n| &&
             `        // in the canonical single-slash form.` && |\n| &&
             `        const newHash = PARAMS.SET_APP_STATE_ACTIVE` && |\n| &&
             `          ? ``/z2ui5-xapp-state=${ID || ""}``` && |\n| &&
             `          : "";` && |\n| &&
             `        navTo(newHash, true);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        Lib.logError("Router.sync: history update failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `    // Lifecycle` && |\n| &&
             `    // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `    function init(fnNavigate) {` && |\n| &&
             `      _fnNavigate = fnNavigate;` && |\n| &&
             `      // Listening to the HashChanger's hashChanged event is what makes the` && |\n| &&
             `      // native browser Back/Forward buttons - and the FLP shell's back` && |\n| &&
             `      // button, which drives the same history - navigate between apps.` && |\n| &&
             `      _boundHashChanged = (oEvent) =>` && |\n| &&
             `        onHashChanged(oEvent.getParameter("newHash"));` && |\n| &&
             `      hashChanger().attachEvent("hashChanged", _boundHashChanged);` && |\n| &&
             `` && |\n| &&
             `      // The stopped router removed with the manifest routing section used to` && |\n| &&
             `      // initialize the HashChanger (and its underlying hasher singleton) as a` && |\n| &&
             `      // side effect. Without that init hasher never learns the URL's current` && |\n| &&
             `      // hash, so the app-state cleanup after every roundtrip (sync calling` && |\n| &&
             `      // navTo("", true)) is treated as a change and rewrites the URL to` && |\n| &&
             `      // "...#" - every app start ended with a dangling "#". Initialize it` && |\n| &&
             `      // explicitly; inside the FLP the shell has already done this and` && |\n| &&
             `      // init() is a guarded no-op.` && |\n| &&
             `      hashChanger().init();` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    function exit() {` && |\n| &&
             `      if (_boundHashChanged) {` && |\n| &&
             `        hashChanger().detachEvent("hashChanged", _boundHashChanged);` && |\n| &&
             `        _boundHashChanged = null;` && |\n| &&
             `      }` && |\n| &&
             `      _fnNavigate = null;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return {` && |\n| &&
             `      init,` && |\n| &&
             `      exit,` && |\n| &&
             `      splitHash,` && |\n| &&
             `      appHashOf,` && |\n| &&
             `      getHash,` && |\n| &&
             `      getRawHash,` && |\n|.
    result = result &&
             `      hrefFor,` && |\n| &&
             `      patternFor,` && |\n| &&
             `      parse,` && |\n| &&
             `      appOf,` && |\n| &&
             `      draftOf,` && |\n| &&
             `      navTo,` && |\n| &&
             `      navToApp,` && |\n| &&
             `      onHashChanged,` && |\n| &&
             `      sync,` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
