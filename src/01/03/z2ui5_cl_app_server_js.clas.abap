* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_server_js DEFINITION
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


CLASS z2ui5_cl_app_server_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/BusyIndicator",` && |\n| &&
             `    "sap/ui/VersionInfo",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/Session",` && |\n| &&
             `    "z2ui5/core/ScrollFocus",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/ErrorView",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    VersionInfo,` && |\n| &&
             `    Lib,` && |\n| &&
             `    Session,` && |\n| &&
             `    ScrollFocus,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    ErrorView,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Last-resort client-side timeout for backend roundtrips. Infrastructure` && |\n| &&
             `    // timeouts (ICM, web dispatcher, proxies) usually fire much earlier and` && |\n| &&
             `    // surface as a regular error response; this backstop only ensures that a` && |\n| &&
             `    // completely hung connection cannot leave the busy indicator spinning` && |\n| &&
             `    // forever. Override via z2ui5.requestTimeoutMs.` && |\n| &&
             `    const REQUEST_TIMEOUT_MS = 600000;` && |\n| &&
             `` && |\n| &&
             `    // Roundtrip lifecycle (spans this file and View1.controller.js):` && |\n| &&
             `    //   1. View1.eB(...)              builds the request body with the model` && |\n| &&
             `    //                                 delta and hands it to roundtrip(oBody)` && |\n| &&
             `    //   2. Server.roundtrip(oBody)    adds S_FRONT (device/focus/scroll info)` && |\n| &&
             `    //   3. Server.readHttp(oBody)     POSTs { value: oBody }, parses the JSON` && |\n| &&
             `    //   4. Server.responseSuccess()   shows messages, rebuilds/updates views` && |\n| &&
             `    //   5. View1._processAfterRendering()  system actions (popups, nested` && |\n| &&
             `    //      views, model push), history, then the app follow-up actions once` && |\n| &&
             `    //      rendering is done` && |\n| &&
             `    // The request body travels through the steps as a parameter; it is` && |\n| &&
             `    // mirrored to z2ui5.oBody so onBeforeRoundtrip hooks and the developer tools` && |\n| &&
             `    // can inspect it. Only the response side still crosses an async boundary` && |\n| &&
             `    // (the rendering) via the oResponse global; the app follow-up snippets` && |\n| &&
             `    // travel on the response record itself (_pendingCustomJs).` && |\n| &&
             `    //` && |\n| &&
             `    // Wire format - request (POST body; ARGUMENTS is folded into` && |\n| &&
             `    // S_FRONT before sending, empty fields are removed):` && |\n| &&
             `    //   { "value": {` && |\n| &&
             `    //       "MODEL": {                     // view model delta` && |\n| &&
             `    //         "NAME": "new value",         //   scalar: full attribute` && |\n| &&
             `    //         "TAB": { "__delta": { "0": { "COL1": "new cell" } } }` && |\n| &&
             `    //       },` && |\n| &&
             `    //       "S_FRONT": {` && |\n| &&
             `    //         "ID": "<draft id of the previous response>",` && |\n| &&
             `    //         "EVENT": "SAVE",             // event name` && |\n| &&
             `    //         "T_EVENT_ARG": ["arg1"],     // further event arguments` && |\n| &&
             `    //         "HASH": "#...",              // live routing state, every request` && |\n| &&
             `    //         "ORIGIN": "https://host", "PATHNAME": "/sap/...", "SEARCH": "?p=1",` && |\n| &&
             `    //                                      // session-constant location: only on` && |\n| &&
             `    //                                      // app-start-shaped requests and the` && |\n| &&
             `    //                                      // page load's first roundtrip` && |\n| &&
             `    //         "CONFIG": { "S_UI5": {...}, "S_DEVICE": {...},` && |\n| &&
             `    //                     "S_FOCUS": {...}, "S_SCROLL": {...},` && |\n| &&
             `    //                     "ComponentData": {...} }` && |\n| &&
             `    //   } } }` && |\n| &&
             `    //` && |\n| &&
             `    // Wire format - response. S_FRONT carries nothing but the id, the app` && |\n| &&
             `    // and the action lists: every view build, teardown, model push and` && |\n| &&
             `    // history update is an action, run by View1/FrontendAction in the` && |\n| &&
             `    // documented order.` && |\n| &&
             `    //   { "S_FRONT": {` && |\n| &&
             `    //       "ID": "<new draft id>",        // sent back with the next request` && |\n| &&
             `    //       "APP": "<app class name>",     // rendered app, for the router` && |\n| &&
             `    //       "S_ACTION": {` && |\n| &&
             `    //           // SYSTEM: the framework's own view-lifecycle calls, run` && |\n| &&
             `    //           // first, in order, before the view is rendered; the` && |\n| &&
             `    //           // ROUTER/sync call is always queued last` && |\n| &&
             `    //           "T_SYSTEM": [` && |\n| &&
             `    //             ["CONTROL_GLOBAL","VIEW_SLOTS","destroy","POPUP"],` && |\n| &&
             `    //             ["CONTROL_GLOBAL","VIEW_SLOTS","display","POPOVER","<Popover/>",{"openById":"btn"}]` && |\n| &&
             `    //           ],` && |\n| &&
             `    //           // APP: what the app queued, run last, once the DOM exists.` && |\n| &&
             `    //           // A legacy app-authored raw-JS snippet stays a string entry.` && |\n| &&
             `    //           "T_CUSTOM": [["SET_FOCUS","id1"]]` && |\n| &&
             `    //       }` && |\n| &&
             `    //     },` && |\n| &&
             `    //     "MODEL": { "NAME": ..., ... }    // full JSON view model, becomes` && |\n| &&
             `    //   }                                  // the view's binding model. Absent` && |\n| &&
             `    //                                      // when nothing bound changed.` && |\n| &&
             `    //` && |\n| &&
             `    // Inspect live payloads via the developer tools (Ctrl+F12): "Previous` && |\n| &&
             `    // Request" and "Response".` && |\n| &&
             `    return {` && |\n| &&
             `      // Monotonic id stamped on every dispatched request (see readHttp). When` && |\n| &&
             `      // parallel requests are allowed (check_allow_multi_req), it lets a` && |\n| &&
             `      // response tell whether a newer request has since gone out, so only the` && |\n| &&
             `      // newest result is committed and stale ones are dropped.` && |\n| &&
             `      _requestSeq: 0,` && |\n| &&
             `` && |\n| &&
             `      // Abort controllers of the requests still in flight. A newly dispatched` && |\n| &&
             `      // request aborts them all - it supersedes them, so there is no point` && |\n| &&
             `      // letting the backend finish work whose response would be dropped anyway.` && |\n| &&
             `      _inflight: new Set(),` && |\n| &&
             `` && |\n| &&
             `      // Chain that serializes full MAIN-view rebuilds (see responseSuccess):` && |\n| &&
             `      // XMLView.create claims the fixed "mainView" id synchronously, so two` && |\n| &&
             `      // overlapping builds would throw "duplicate id".` && |\n| &&
             `      _viewBuild: null,` && |\n| &&
             `` && |\n| &&
             `      endSession() {` && |\n| &&
             `        if (!Lib.isValidContextId(AppState.state.contextId)) return;` && |\n| &&
             `        // Best-effort notify the backend that the session ends. Errors are` && |\n| &&
             `        // intentionally swallowed: the browser tab is closing anyway.` && |\n| &&
             `        fetch(AppState.getGlobal("url"), {` && |\n| &&
             `          method: "HEAD",` && |\n| &&
             `          keepalive: true,` && |\n| &&
             `          headers: {` && |\n| &&
             `            "sap-terminate": "session",` && |\n| &&
             `            "sap-contextid": AppState.state.contextId,` && |\n| &&
             `            "sap-contextid-accept": "header",` && |\n| &&
             `          },` && |\n| &&
             `        }).catch(() => {});` && |\n| &&
             `        AppState.state.contextId = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Restore the app state a matched hash route points at. Wired into` && |\n| &&
             `      // core/Router by Component.js and called when the browser Back/Forward` && |\n| &&
             `      // buttons (or a manual URL edit / bookmark) select a different route.` && |\n| &&
             `      // An empty body (no ID) makes the backend take the first-start path and` && |\n| &&
             `      // read the target class + draft from the hash it receives` && |\n| &&
             `      // (request_app_start_route[_draft]).` && |\n| &&
             `      restoreFromRoute() {` && |\n| &&
             `        // Participate in the normal busy protocol: without it the app looks` && |\n| &&
             `        // idle during the restore, and an ordinary click would dispatch a` && |\n| &&
             `        // request that aborts the Back/Forward navigation without any` && |\n| &&
             `        // feedback. _processAfterRendering / responseError clear it again.` && |\n| &&
             `        AppState.state.isBusy = true;` && |\n| &&
             `        BusyIndicator.show(0);` && |\n| &&
             `        this.roundtrip({});` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      roundtrip(oBody = {}) {` && |\n| &&
             `        const state = AppState.state;` && |\n| &&
             `` && |\n| &&
             `        // Keep the shared record in sync (developer tools "Previous Request",` && |\n| &&
             `        // app hooks); the parameter stays the working object. Calls without` && |\n| &&
             `        // a body (initial roundtrip, route changes) start from scratch.` && |\n| &&
             `        state.oBody = oBody;` && |\n| &&
             `` && |\n| &&
             `        // Pick the first event argument (event name) safely.` && |\n| &&
             `        const eventName = oBody.ARGUMENTS?.[0]?.[0];` && |\n| &&
             `` && |\n| &&
             `        const oConfig = AppState.getGlobal("oConfig");` && |\n| &&
             `        oBody.S_FRONT = {` && |\n| &&
             `          CONFIG: {` && |\n| &&
             `            // the session-constant block travels once per page load` && |\n| &&
             `            // (core/Session.js); focus and scroll are per roundtrip by nature` && |\n| &&
             `            // (core/ScrollFocus.js)` && |\n| &&
             `            ...Session.config(oConfig),` && |\n| &&
             `            S_FOCUS: ScrollFocus.getFocusInfo(),` && |\n| &&
             `            S_SCROLL: ScrollFocus.getScrollInfo(),` && |\n| &&
             `          },` && |\n| &&
             `          ID: oBody.ID,` && |\n| &&
             `          EVENT: eventName,` && |\n| &&
             `          // the hash is NOT session-constant - it carries the live routing` && |\n| &&
             `          // state (route restore, app-state bookmarks) on every request` && |\n| &&
             `          HASH: window.location.hash,` && |\n| &&
             `        };` && |\n| &&
             `        const sFront = oBody.S_FRONT;` && |\n| &&
             `` && |\n| &&
             `        // The page location travels on its own session cadence - the latch` && |\n| &&
             `        // lives with the rest of the once-per-page-load state in` && |\n| &&
             `        // core/Session.js. An event roundtrip gets null, and Object.assign` && |\n| &&
             `        // with null adds nothing.` && |\n| &&
             `        Object.assign(sFront, Session.location(oBody.ID, state.search));` && |\n| &&
             `` && |\n| &&
             `        // The first argument was the event name (already stored as EVENT),` && |\n| &&
             `        // the remaining entries are the actual event arguments.` && |\n| &&
             `        if (oBody.ARGUMENTS) oBody.ARGUMENTS.shift();` && |\n| &&
             `        sFront.T_EVENT_ARG = oBody.ARGUMENTS;` && |\n| &&
             `` && |\n| &&
             `        delete oBody.ID;` && |\n| &&
             `        delete oBody.ARGUMENTS;` && |\n| &&
             `` && |\n| &&
             `        // Remove empty / undefined fields so the backend request stays small` && |\n| &&
             `        // and these keys are not present in the JSON sent over the wire.` && |\n| &&
             `        if (!sFront.T_EVENT_ARG?.length) delete sFront.T_EVENT_ARG;` && |\n| &&
             `        if (sFront.SEARCH === "") delete sFront.SEARCH;` && |\n| &&
             `        if (!oBody.MODEL) delete oBody.MODEL;` && |\n| &&
             `` && |\n| &&
             `        this.readHttp(oBody);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Returns an abort signal that fires after ``ms`` plus a cancel function` && |\n| &&
             `      // that releases the underlying timer. Uses AbortSignal.timeout where` && |\n| &&
             `      // available and falls back to a manual AbortController + setTimeout on` && |\n| &&
             `      // older browsers, so the client-side timeout backstop works everywhere.` && |\n| &&
             `      // (Exposed on the module for the unit specs.)` && |\n| &&
             `      createTimeoutSignal(ms) {` && |\n| &&
             `        if (AbortSignal.timeout) {` && |\n| &&
             `          return { signal: AbortSignal.timeout(ms), cancel: () => {} };` && |\n| &&
             `        }` && |\n| &&
             `        const controller = new AbortController();` && |\n| &&
             `        const handle = setTimeout(() => controller.abort(), ms);` && |\n| &&
             `        return {` && |\n| &&
             `          signal: controller.signal,` && |\n| &&
             `          cancel: () => clearTimeout(handle),` && |\n| &&
             `        };` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Abort every still-in-flight request. Called when a newer request is` && |\n| &&
             `      // dispatched: the older fetches reject with AbortError, which the` && |\n| &&
             `      // isStale guard in readHttp's catch swallows silently.` && |\n| &&
             `      _abortInflight() {` && |\n| &&
             `        for (const controller of this._inflight) controller.abort();` && |\n| &&
             `        this._inflight.clear();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Merge two abort signals into one for fetch: the fetch is aborted when` && |\n| &&
             `      // either fires (the timeout backstop or a superseding request). Uses` && |\n| &&
             `      // AbortSignal.any where available (2024+) and forwards manually on older` && |\n| &&
             `      // browsers, so the abort works everywhere createTimeoutSignal does.` && |\n| &&
             `      _combineSignals(a, b) {` && |\n| &&
             `        if (AbortSignal.any) return AbortSignal.any([a, b]);` && |\n| &&
             `        const controller = new AbortController();` && |\n| &&
             `        const forward = (sig) => {` && |\n| &&
             `          if (sig.aborted) controller.abort(sig.reason);` && |\n| &&
             `          else {` && |\n| &&
             `            sig.addEventListener("abort", () => controller.abort(sig.reason), {` && |\n| &&
             `              once: true,` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `        };` && |\n| &&
             `        forward(a);` && |\n| &&
             `        forward(b);` && |\n| &&
             `        return controller.signal;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async readHttp(oBody) {` && |\n| &&
             `        const timeoutMs =` && |\n| &&
             `          AppState.getGlobal("requestTimeoutMs") || REQUEST_TIMEOUT_MS;` && |\n| &&
             `        // The signal guards the fetch and the response body reads below; the` && |\n| &&
             `        // finally releases the fallback timer once the roundtrip settled.` && |\n| &&
             `        const { signal: timeoutSignal, cancel } =` && |\n| &&
             `          this.createTimeoutSignal(timeoutMs);` && |\n| &&
             `        // A network blip or timeout may mean the request never reached the` && |\n| &&
             `        // server, so the error overlay offers a retry that re-sends the` && |\n| &&
             `        // exact same request body instead of forcing a full app restart.` && |\n| &&
             `        // Re-arm the busy state first - responseError cleared it, and an` && |\n| &&
             `        // unguarded click during the retry would abort it silently.` && |\n| &&
             `        const oRetry = {` && |\n| &&
             `          onRetry: () => {` && |\n| &&
             `            AppState.state.isBusy = true;` && |\n| &&
             `            BusyIndicator.show(0);` && |\n| &&
             `            this.readHttp(oBody);` && |\n| &&
             `          },` && |\n| &&
             `        };` && |\n| &&
             `` && |\n| &&
             `        // Stamp this request and treat its response as stale once a newer` && |\n| &&
             `        // request has been dispatched. With parallel requests allowed` && |\n| &&
             `        // (check_allow_multi_req) responses can arrive out of order; only the` && |\n| &&
             `        // newest may commit its result, so a slow older response never` && |\n| &&
             `        // overwrites a newer view, caret or session id. In the default` && |\n| &&
             `        // blocking mode only one request is ever in flight, so this never` && |\n| &&
             `        // fires. The check is repeated before every state mutation because the` && |\n| &&
             `        // body reads below (text/json) each yield the event loop, giving a` && |\n| &&
             `        // newer request the chance to supersede this one mid-parse.` && |\n| &&
             `        const seq = ++this._requestSeq;` && |\n| &&
             `        const isStale = () => seq !== this._requestSeq;` && |\n| &&
             `` && |\n| &&
             `        // Cancel any request still in flight - this one supersedes them - then` && |\n| &&
             `        // register this request's own controller so a later one can cancel it.` && |\n| &&
             `        // The fetch aborts on either the timeout or a superseding request.` && |\n| &&
             `        this._abortInflight();` && |\n| &&
             `        const superseder = new AbortController();` && |\n| &&
             `        this._inflight.add(superseder);` && |\n| &&
             `        const signal = this._combineSignals(timeoutSignal, superseder.signal);` && |\n| &&
             `        try {` && |\n| &&
             `          // Step 1: send the request.` && |\n| &&
             `          let response;` && |\n| &&
             `          try {` && |\n| &&
             `            // Only forward "sap-contextid" once we actually own a valid` && |\n| &&
             `            // session id - otherwise omit the header entirely (never send ""` && |\n| &&
             `            // or "undefined"; see isValidContextId).` && |\n| &&
             `            const headers = {` && |\n| &&
             `              "Content-Type": "application/json",` && |\n| &&
             `              "sap-contextid-accept": "header",` && |\n| &&
             `            };` && |\n| &&
             `            if (Lib.isValidContextId(AppState.state.contextId)) {` && |\n| &&
             `              headers["sap-contextid"] = AppState.state.contextId;` && |\n| &&
             `            }` && |\n| &&
             `            response = await fetch(AppState.getGlobal("url"), {` && |\n| &&
             `              method: "POST",` && |\n| &&
             `              headers,` && |\n| &&
             `              body: JSON.stringify({ value: oBody }),` && |\n| &&
             `              signal,` && |\n| &&
             `            });` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            // A superseded request that fails is not the user's concern - the` && |\n| &&
             `            // newer request owns the outcome, so swallow it without an overlay.` && |\n| &&
             `            if (isStale()) return;` && |\n| &&
             `            if (e.name === "TimeoutError" || e.name === "AbortError") {` && |\n| &&
             `              this.responseError(` && |\n| &&
             `                ``No backend response within ${timeoutMs / 1000} seconds - request aborted``,` && |\n| &&
             `                undefined,` && |\n| &&
             `                oRetry,` && |\n| &&
             `              );` && |\n| &&
             `            } else {` && |\n| &&
             `              this.responseError(` && |\n| &&
             `                ``Network error: ${e.message}``,` && |\n| &&
             `                undefined,` && |\n| &&
             `                oRetry,` && |\n| &&
             `              );` && |\n| &&
             `            }` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          // A newer request went out while this one was in flight - drop it` && |\n| &&
             `          // whole: no session id adoption, no error overlay, no render.` && |\n| &&
             `          if (isStale()) return;` && |\n| &&
             `          // Keep the last valid session id; a response without the header` && |\n| &&
             `          // (returns null) must not wipe an established session.` && |\n| &&
             `          const contextId = response.headers.get("sap-contextid");` && |\n| &&
             `          if (Lib.isValidContextId(contextId)) {` && |\n| &&
             `            AppState.state.contextId = contextId;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Step 2: if the HTTP status is not 2xx, treat the body as error` && |\n| &&
             `          // text.` && |\n| &&
             `          if (!response.ok) {` && |\n| &&
             `            let text;` && |\n| &&
             `            try {` && |\n| &&
             `              text = await response.text();` && |\n| &&
             `            } catch {` && |\n| &&
             `              text = ``HTTP ${response.status}: could not read error body``;` && |\n| &&
             `            }` && |\n| &&
             `            if (isStale()) return;` && |\n| &&
             `            // An empty error body would render an empty overlay - fall back` && |\n| &&
             `            // to the status code so the user sees at least what failed.` && |\n| &&
             `            this.responseError(text || ``HTTP ${response.status}``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Step 3: parse the JSON body.` && |\n| &&
             `          let responseData;` && |\n| &&
             `          try {` && |\n| &&
             `            responseData = await response.json();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            if (isStale()) return;` && |\n| &&
             `            this.responseError(``Invalid JSON response: ${e.message}``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          // Last check before committing: a newer request may have arrived` && |\n| &&
             `          // while the body was being parsed.` && |\n| &&
             `          if (isStale()) return;` && |\n| &&
             `          if (!responseData || !responseData.S_FRONT) {` && |\n| &&
             `            this.responseError("Invalid response: missing S_FRONT");` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Step 4: hand the parsed response to the success handler.` && |\n| &&
             `          AppState.state.responseData = responseData;` && |\n| &&
             `          // This request won (it passed the stale guard above), so the edits` && |\n| &&
             `          // it carried have reached the backend - clear exactly the model it` && |\n| &&
             `          // shipped. A stale response returns before this point and clears` && |\n| &&
             `          // nothing, so a slower older response can never wipe newer edits;` && |\n| &&
             `          // and edits made in a different model stay pending for their own` && |\n| &&
             `          // roundtrip.` && |\n| &&
             `          AppState.state.oSentModel?._z2ui5ChangedPaths?.clear();` && |\n| &&
             `          AppState.state.oSentModel = null;` && |\n| &&
             `          this.responseSuccess(` && |\n| &&
             `            {` && |\n| &&
             `              ID: responseData.S_FRONT.ID,` && |\n| &&
             `              S_ACTION: responseData.S_FRONT.S_ACTION,` && |\n| &&
             `              // A response whose model did not change carries no MODEL key` && |\n| &&
             `              // at all; every consumer downstream sees the empty object it` && |\n| &&
             `              // used to be sent explicitly.` && |\n| &&
             `              OVIEWMODEL: responseData.MODEL ?? {},` && |\n| &&
             `              // Class name of the rendered app - used by the hash router to` && |\n| &&
             `              // keep the URL route "#/app/<CLASS>" in sync (View1).` && |\n| &&
             `              APP: responseData.S_FRONT.APP,` && |\n| &&
             `            },` && |\n| &&
             `            seq,` && |\n| &&
             `          );` && |\n| &&
             `        } finally {` && |\n| &&
             `          this._inflight.delete(superseder);` && |\n| &&
             `          cancel();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async responseSuccess(response, reqSeq) {` && |\n| &&
             `        const oController = ViewSlots.getController("MAIN");` && |\n| &&
             `        try {` && |\n| &&
             `          AppState.state.oResponse = response;` && |\n| &&
             `` && |\n| &&
             `          // The backend can send follow-up actions to run after the response.` && |\n| &&
             `          // Each entry is a real JSON array ["EVENT", ...args] (framework` && |\n| &&
             `          // actions, pure data), a legacy "eF(...)" call string, or a raw JS` && |\n| &&
             `          // expression - see FrontendAction.runCustom. They are stashed` && |\n| &&
             `          // here and executed at the end of _processAfterRendering, i.e. once` && |\n| &&
             `          // the (possibly freshly built) view is actually rendered. Running` && |\n|.
    result = result &&
             `          // them earlier would break render-dependent actions such as` && |\n| &&
             `          // SET_FOCUS on the initial view, where the target control does not` && |\n| &&
             `          // exist in the DOM yet.` && |\n| &&
             `          const followUp = response.S_ACTION;` && |\n| &&
             `          // carried on the response record, not on shared state: with` && |\n| &&
             `          // parallel responses a single global would let the older render` && |\n| &&
             `          // consume the newer response's snippets (and lose its own)` && |\n| &&
             `          response._pendingCustomJs = followUp?.T_CUSTOM || null;` && |\n| &&
             `` && |\n| &&
             `          // Every view-lifecycle call, the MAIN rebuild included, is a system` && |\n| &&
             `          // action now - so there is nothing slot-specific left here. The` && |\n| &&
             `          // phases are started unconditionally: the MAIN view's own` && |\n| &&
             `          // onAfterRendering used to be what triggered them after a rebuild,` && |\n| &&
             `          // and it cannot be, once the rebuild is one of the actions they run.` && |\n| &&
             `          // It stays harmless - _processAfterRendering marks the response as` && |\n| &&
             `          // processed before the first action, so the render it causes finds` && |\n| &&
             `          // nothing left to do. The request stamp rides along so the display` && |\n| &&
             `          // guards compare against THIS response's request, not whatever is` && |\n| &&
             `          // newest by the time processing starts.` && |\n| &&
             `          oController._processAfterRendering(reqSeq);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          AppState.state.isBusy = false;` && |\n| &&
             `          Lib.logError("responseSuccess: unexpected error", e);` && |\n| &&
             `          const msg = e.message || "";` && |\n| &&
             `          if (msg.includes("openui5") && msg.includes("script load error")) {` && |\n| &&
             `            this._checkSDKcompatibility(e);` && |\n| &&
             `          } else {` && |\n| &&
             `            this.responseError(e);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // A view failed to load a sap.com module: when the page runs on` && |\n| &&
             `      // openui5 (instead of SAPUI5), tell the user which module is missing` && |\n| &&
             `      // so they know to switch SDKs; otherwise show the original error.` && |\n| &&
             `      async _checkSDKcompatibility(err) {` && |\n| &&
             `        let gav;` && |\n| &&
             `        try {` && |\n| &&
             `          const info = await VersionInfo.load();` && |\n| &&
             `          gav = info.gav;` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          // Could not determine the SDK - never swallow the original failure:` && |\n| &&
             `          // fall back to the fatal-error overlay with the underlying error so` && |\n| &&
             `          // every error case still surfaces one error popup.` && |\n| &&
             `          Lib.logError("_checkSDKcompatibility: VersionInfo.load failed", e);` && |\n| &&
             `          this.responseError(err);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!gav || !gav.includes("com.sap.ui5")) {` && |\n| &&
             `          // UI5 loader errors do not expose a stable module field; fall back` && |\n| &&
             `          // to the quoted module path in the message so the hint stays useful` && |\n| &&
             `          // instead of printing "module: undefined".` && |\n| &&
             `          const moduleMatch = /['"]([\w./-]+)['"]/.exec(err?.message || "");` && |\n| &&
             `          const missingModule =` && |\n| &&
             `            err?._modules || moduleMatch?.[1] || "the requested module";` && |\n| &&
             `          this.responseError(` && |\n| &&
             `            ``openui5 SDK is loaded, module: ${missingModule} is not available in openui5``,` && |\n| &&
             `          );` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        this.responseError(err);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Terminate the roundtrip in an unrecoverable state: clear the busy` && |\n| &&
             `      // state and show the fatal-error overlay (core/ErrorView). ``response``` && |\n| &&
             `      // may be a string or an Error object; ``title`` overrides the default` && |\n| &&
             `      // header text; ``oOptions.onRetry`` adds a Retry action to the overlay` && |\n| &&
             `      // (used for network/timeout failures where the request may never have` && |\n| &&
             `      // reached the server).` && |\n| &&
             `      responseError(response, title, oOptions) {` && |\n| &&
             `        BusyIndicator.hide();` && |\n| &&
             `        AppState.state.isBusy = false;` && |\n| &&
             `        ErrorView.show(response, title, oOptions);` && |\n| &&
             `      },` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
