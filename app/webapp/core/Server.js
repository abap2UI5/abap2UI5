sap.ui.define(
  [
    "sap/ui/core/BusyIndicator",
    "sap/ui/VersionInfo",
    "z2ui5/core/Lib",
    "z2ui5/core/Session",
    "z2ui5/core/ScrollFocus",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/ErrorView",
    "z2ui5/core/AppState",
  ],
  (
    BusyIndicator,
    VersionInfo,
    Lib,
    Session,
    ScrollFocus,
    ViewSlots,
    ErrorView,
    AppState,
  ) => {
    "use strict";

    // Last-resort client-side timeout for backend roundtrips. Infrastructure
    // timeouts (ICM, web dispatcher, proxies) usually fire much earlier and
    // surface as a regular error response; this backstop only ensures that a
    // completely hung connection cannot leave the busy indicator spinning
    // forever. Override via z2ui5.requestTimeoutMs.
    const REQUEST_TIMEOUT_MS = 600000;

    // Roundtrip lifecycle (spans this file and View1.controller.js):
    //   1. View1.eB(...)              builds the request body with the model
    //                                 delta and hands it to roundtrip(oBody)
    //   2. Server.roundtrip(oBody)    adds S_FRONT (device/focus/scroll info)
    //   3. Server.readHttp(oBody)     POSTs { value: oBody }, parses the JSON
    //   4. Server.responseSuccess()   shows messages, rebuilds/updates views
    //   5. View1._processAfterRendering()  system actions (popups, nested
    //      views, model push), history, then the app follow-up actions once
    //      rendering is done
    // The request body travels through the steps as a parameter; it is
    // mirrored to z2ui5.oBody so onBeforeRoundtrip hooks and the developer tools
    // can inspect it. Only the response side still crosses an async boundary
    // (the rendering) via the oResponse global; the app follow-up snippets
    // travel on the response record itself (_pendingCustomJs).
    //
    // Wire format - request (POST body; ARGUMENTS is folded into
    // S_FRONT before sending, empty fields are removed):
    //   { "value": {
    //       "MODEL": {                     // view model delta
    //         "NAME": "new value",         //   scalar: full attribute
    //         "TAB": { "__delta": { "0": { "COL1": "new cell" } } }
    //       },
    //       "S_FRONT": {
    //         "ID": "<draft id of the previous response>",
    //         "EVENT": "SAVE",             // event name
    //         "T_EVENT_ARG": ["arg1"],     // further event arguments
    //         "HASH": "#...",              // live routing state, every request
    //         "ORIGIN": "https://host", "PATHNAME": "/sap/...", "SEARCH": "?p=1",
    //                                      // session-constant location: only on
    //                                      // app-start-shaped requests and the
    //                                      // page load's first roundtrip
    //         "CONFIG": { "S_UI5": {...}, "S_DEVICE": {...},
    //                     "S_FOCUS": {...}, "S_SCROLL": {...},
    //                     "ComponentData": {...} }
    //   } } }
    //
    // Wire format - response. S_FRONT carries nothing but the id, the app
    // and the action lists: every view build, teardown, model push and
    // history update is an action, run by View1/FrontendAction in the
    // documented order.
    //   { "S_FRONT": {
    //       "ID": "<new draft id>",        // sent back with the next request
    //       "APP": "<app class name>",     // rendered app, for the router
    //       "S_ACTION": {
    //           // SYSTEM: the framework's own view-lifecycle calls, run
    //           // first, in order, before the view is rendered. A
    //           // ROUTER/sync call is queued last, and only when the
    //           // roundtrip carries nav intent - View1 syncs the URL once
    //           // per response either way
    //           "T_SYSTEM": [
    //             ["CONTROL_GLOBAL","VIEW_SLOTS","destroy","POPUP"],
    //             ["CONTROL_GLOBAL","VIEW_SLOTS","display","POPOVER","<Popover/>",{"openById":"btn"}]
    //           ],
    //           // APP: what the app queued, run last, once the DOM exists.
    //           // A legacy app-authored raw-JS snippet stays a string entry.
    //           "T_CUSTOM": [["SET_FOCUS","id1"]]
    //       }
    //     },
    //     "MODEL": { "NAME": ..., ... }    // full JSON view model, becomes
    //   }                                  // the view's binding model. Absent
    //                                      // when nothing bound changed.
    //
    // Inspect live payloads via the developer tools (Ctrl+F12): "Previous
    // Request" and "Response".
    return {
      // Monotonic id stamped on every dispatched request (see readHttp). When
      // parallel requests are allowed (check_allow_multi_req), it lets a
      // response tell whether a newer request has since gone out, so only the
      // newest result is committed and stale ones are dropped.
      _requestSeq: 0,

      // Abort controllers of the requests still in flight. A newly dispatched
      // request aborts them all - it supersedes them, so there is no point
      // letting the backend finish work whose response would be dropped anyway.
      _inflight: new Set(),

      // Chain that serializes full MAIN-view rebuilds (see
      // actions/Slots.displayMain): XMLView.create claims the fixed
      // "mainView" id synchronously, so two overlapping builds would throw
      // "duplicate id".
      _viewBuild: null,

      endSession() {
        if (!Lib.isValidContextId(AppState.state.contextId)) return;
        // Best-effort notify the backend that the session ends. Errors are
        // intentionally swallowed: the browser tab is closing anyway.
        fetch(AppState.getGlobal("url"), {
          method: "HEAD",
          keepalive: true,
          headers: {
            "sap-terminate": "session",
            "sap-contextid": AppState.state.contextId,
            "sap-contextid-accept": "header",
          },
        }).catch(() => {});
        AppState.state.contextId = null;
      },

      // Restore the app state a matched hash route points at. Wired into
      // core/Router by Component.js and called when the browser Back/Forward
      // buttons (or a manual URL edit / bookmark) select a different route.
      // An empty body (no ID) makes the backend take the first-start path and
      // read the target class + draft from the hash it receives
      // (request_app_start_route[_draft]).
      restoreFromRoute() {
        // Participate in the normal busy protocol: without it the app looks
        // idle during the restore, and an ordinary click would dispatch a
        // request that aborts the Back/Forward navigation without any
        // feedback. _processAfterRendering / responseError clear it again.
        AppState.state.isBusy = true;
        BusyIndicator.show(0);
        this.roundtrip({});
      },

      roundtrip(oBody = {}) {
        const state = AppState.state;

        // Keep the shared record in sync (developer tools "Previous Request",
        // app hooks); the parameter stays the working object. Calls without
        // a body (initial roundtrip, route changes) start from scratch.
        state.oBody = oBody;

        // Pick the first event argument (event name) safely.
        const eventName = oBody.ARGUMENTS?.[0]?.[0];

        const oConfig = AppState.getGlobal("oConfig");
        // the session-constant block travels once per page load and the
        // live device fields only when they changed (core/Session.js);
        // focus and scroll are per roundtrip by nature (core/ScrollFocus.js)
        const config = {
          ...Session.config(oConfig),
          S_FOCUS: ScrollFocus.getFocusInfo(),
          S_SCROLL: ScrollFocus.getScrollInfo(),
        };
        oBody.S_FRONT = {
          ID: oBody.ID,
          EVENT: eventName,
          // the hash is NOT session-constant - it carries the live routing
          // state (route restore, app-state bookmarks) on every request
          HASH: window.location.hash,
        };
        const sFront = oBody.S_FRONT;
        // an all-empty CONFIG is left off entirely
        if (Object.values(config).some((v) => v !== undefined)) {
          sFront.CONFIG = config;
        }

        // The page location travels on its own session cadence - the latch
        // lives with the rest of the once-per-page-load state in
        // core/Session.js. An event roundtrip gets null, and Object.assign
        // with null adds nothing.
        Object.assign(sFront, Session.location(oBody.ID, state.search));

        // The first argument was the event name (already stored as EVENT),
        // the remaining entries are the actual event arguments.
        if (oBody.ARGUMENTS) oBody.ARGUMENTS.shift();
        sFront.T_EVENT_ARG = oBody.ARGUMENTS;

        delete oBody.ID;
        delete oBody.ARGUMENTS;

        // Remove empty / undefined fields so the backend request stays small
        // and these keys are not present in the JSON sent over the wire.
        if (!sFront.T_EVENT_ARG?.length) delete sFront.T_EVENT_ARG;
        if (sFront.SEARCH === "") delete sFront.SEARCH;
        if (!sFront.HASH) delete sFront.HASH;
        if (!oBody.MODEL) delete oBody.MODEL;

        this.readHttp(oBody);
      },

      // Returns an abort signal that fires after `ms` plus a cancel function
      // that releases the underlying timer. Uses AbortSignal.timeout where
      // available and falls back to a manual AbortController + setTimeout on
      // older browsers, so the client-side timeout backstop works everywhere.
      // (Exposed on the module for the unit specs.)
      createTimeoutSignal(ms) {
        if (AbortSignal.timeout) {
          return { signal: AbortSignal.timeout(ms), cancel: () => {} };
        }
        const controller = new AbortController();
        const handle = setTimeout(() => controller.abort(), ms);
        return {
          signal: controller.signal,
          cancel: () => clearTimeout(handle),
        };
      },

      // Abort every still-in-flight request. Called when a newer request is
      // dispatched: the older fetches reject with AbortError, which the
      // isStale guard in readHttp's catch swallows silently.
      _abortInflight() {
        for (const controller of this._inflight) controller.abort();
        this._inflight.clear();
      },

      // Merge two abort signals into one for fetch: the fetch is aborted when
      // either fires (the timeout backstop or a superseding request). Uses
      // AbortSignal.any where available (2024+) and forwards manually on older
      // browsers, so the abort works everywhere createTimeoutSignal does.
      _combineSignals(a, b) {
        if (AbortSignal.any) return AbortSignal.any([a, b]);
        const controller = new AbortController();
        const forward = (sig) => {
          if (sig.aborted) controller.abort(sig.reason);
          else {
            sig.addEventListener("abort", () => controller.abort(sig.reason), {
              once: true,
            });
          }
        };
        forward(a);
        forward(b);
        return controller.signal;
      },

      async readHttp(oBody) {
        const timeoutMs =
          AppState.getGlobal("requestTimeoutMs") || REQUEST_TIMEOUT_MS;
        // The signal guards the fetch and the response body reads below; the
        // finally releases the fallback timer once the roundtrip settled.
        const { signal: timeoutSignal, cancel } =
          this.createTimeoutSignal(timeoutMs);
        // A network blip or timeout may mean the request never reached the
        // server, so the error overlay offers a retry that re-sends the
        // exact same request body instead of forcing a full app restart.
        // Re-arm the busy state first - responseError cleared it, and an
        // unguarded click during the retry would abort it silently.
        const oRetry = {
          onRetry: () => {
            AppState.state.isBusy = true;
            BusyIndicator.show(0);
            this.readHttp(oBody);
          },
        };

        // Stamp this request and treat its response as stale once a newer
        // request has been dispatched. With parallel requests allowed
        // (check_allow_multi_req) responses can arrive out of order; only the
        // newest may commit its result, so a slow older response never
        // overwrites a newer view, caret or session id. In the default
        // blocking mode only one request is ever in flight, so this never
        // fires. The check is repeated before every state mutation because the
        // body reads below (text/json) each yield the event loop, giving a
        // newer request the chance to supersede this one mid-parse.
        const seq = ++this._requestSeq;
        const isStale = () => seq !== this._requestSeq;

        // Cancel any request still in flight - this one supersedes them - then
        // register this request's own controller so a later one can cancel it.
        // The fetch aborts on either the timeout or a superseding request.
        this._abortInflight();
        const superseder = new AbortController();
        this._inflight.add(superseder);
        const signal = this._combineSignals(timeoutSignal, superseder.signal);
        try {
          // Step 1: send the request.
          let response;
          try {
            // Only forward "sap-contextid" once we actually own a valid
            // session id - otherwise omit the header entirely (never send ""
            // or "undefined"; see isValidContextId).
            const headers = {
              "Content-Type": "application/json",
              "sap-contextid-accept": "header",
            };
            if (Lib.isValidContextId(AppState.state.contextId)) {
              headers["sap-contextid"] = AppState.state.contextId;
            }
            response = await fetch(AppState.getGlobal("url"), {
              method: "POST",
              headers,
              body: JSON.stringify({ value: oBody }),
              signal,
            });
          } catch (e) {
            // A superseded request that fails is not the user's concern - the
            // newer request owns the outcome, so swallow it without an overlay.
            if (isStale()) return;
            if (e.name === "TimeoutError" || e.name === "AbortError") {
              this.responseError(
                `No backend response within ${timeoutMs / 1000} seconds - request aborted`,
                undefined,
                oRetry,
              );
            } else {
              this.responseError(
                `Network error: ${e.message}`,
                undefined,
                oRetry,
              );
            }
            return;
          }
          // A newer request went out while this one was in flight - drop it
          // whole: no session id adoption, no error overlay, no render.
          if (isStale()) return;
          // Keep the last valid session id; a response without the header
          // (returns null) must not wipe an established session.
          const contextId = response.headers.get("sap-contextid");
          if (Lib.isValidContextId(contextId)) {
            AppState.state.contextId = contextId;
          }

          // Step 2: if the HTTP status is not 2xx, treat the body as error
          // text.
          if (!response.ok) {
            let text;
            try {
              text = await response.text();
            } catch {
              text = `HTTP ${response.status}: could not read error body`;
            }
            if (isStale()) return;
            // An empty error body would render an empty overlay - fall back
            // to the status code so the user sees at least what failed.
            this.responseError(text || `HTTP ${response.status}`);
            return;
          }

          // Step 3: parse the JSON body.
          let responseData;
          try {
            responseData = await response.json();
          } catch (e) {
            if (isStale()) return;
            this.responseError(`Invalid JSON response: ${e.message}`);
            return;
          }
          // Last check before committing: a newer request may have arrived
          // while the body was being parsed.
          if (isStale()) return;
          if (!responseData || !responseData.S_FRONT) {
            this.responseError("Invalid response: missing S_FRONT");
            return;
          }

          // Step 4: hand the parsed response to the success handler.
          AppState.state.responseData = responseData;
          // This request won (it passed the stale guard above), so the edits
          // it carried have reached the backend - clear exactly the model it
          // shipped. A stale response returns before this point and clears
          // nothing, so a slower older response can never wipe newer edits;
          // and edits made in a different model stay pending for their own
          // roundtrip.
          AppState.state.oSentModel?._z2ui5ChangedPaths?.clear();
          AppState.state.oSentModel = null;
          this.responseSuccess(
            {
              ID: responseData.S_FRONT.ID,
              S_ACTION: responseData.S_FRONT.S_ACTION,
              // A response whose model did not change carries no MODEL key
              // at all; every consumer downstream sees the empty object it
              // used to be sent explicitly.
              OVIEWMODEL: responseData.MODEL ?? {},
              // A MODEL key in the response IS the model push: View1 pushes
              // it into every open model-owning slot after the system
              // actions ran - no updateModel action travels for it.
              MODELPRESENT: responseData.MODEL !== undefined,
              // Class name of the rendered app - used by the hash router to
              // keep the URL route "#/app/<CLASS>" in sync (View1).
              APP: responseData.S_FRONT.APP,
            },
            seq,
          );
        } finally {
          this._inflight.delete(superseder);
          cancel();
        }
      },

      async responseSuccess(response, reqSeq) {
        const oController = ViewSlots.getController("MAIN");
        try {
          AppState.state.oResponse = response;

          // The backend can send follow-up actions to run after the response.
          // Each entry is a real JSON array ["EVENT", ...args] (framework
          // actions, pure data), a legacy "eF(...)" call string, or a raw JS
          // expression - see FrontendAction.runCustom. They are stashed
          // here and executed at the end of _processAfterRendering, i.e. once
          // the (possibly freshly built) view is actually rendered. Running
          // them earlier would break render-dependent actions such as
          // SET_FOCUS on the initial view, where the target control does not
          // exist in the DOM yet.
          const followUp = response.S_ACTION;
          // carried on the response record, not on shared state: with
          // parallel responses a single global would let the older render
          // consume the newer response's snippets (and lose its own)
          response._pendingCustomJs = followUp?.T_CUSTOM || null;

          // Every view-lifecycle call, the MAIN rebuild included, is a system
          // action now - so there is nothing slot-specific left here. The
          // phases are started unconditionally: the MAIN view's own
          // onAfterRendering used to be what triggered them after a rebuild,
          // and it cannot be, once the rebuild is one of the actions they run.
          // It stays harmless - _processAfterRendering marks the response as
          // processed before the first action, so the render it causes finds
          // nothing left to do. The request stamp rides along so the display
          // guards compare against THIS response's request, not whatever is
          // newest by the time processing starts.
          oController._processAfterRendering(reqSeq);
        } catch (e) {
          BusyIndicator.hide();
          AppState.state.isBusy = false;
          Lib.logError("responseSuccess: unexpected error", e);
          const msg = e.message || "";
          if (msg.includes("openui5") && msg.includes("script load error")) {
            this._checkSDKcompatibility(e);
          } else {
            this.responseError(e);
          }
        }
      },

      // A view failed to load a sap.com module: when the page runs on
      // openui5 (instead of SAPUI5), tell the user which module is missing
      // so they know to switch SDKs; otherwise show the original error.
      async _checkSDKcompatibility(err) {
        let gav;
        try {
          const info = await VersionInfo.load();
          gav = info.gav;
        } catch (e) {
          // Could not determine the SDK - never swallow the original failure:
          // fall back to the fatal-error overlay with the underlying error so
          // every error case still surfaces one error popup.
          Lib.logError("_checkSDKcompatibility: VersionInfo.load failed", e);
          this.responseError(err);
          return;
        }
        if (!gav || !gav.includes("com.sap.ui5")) {
          // UI5 loader errors do not expose a stable module field; fall back
          // to the quoted module path in the message so the hint stays useful
          // instead of printing "module: undefined".
          const moduleMatch = /['"]([\w./-]+)['"]/.exec(err?.message || "");
          const missingModule =
            err?._modules || moduleMatch?.[1] || "the requested module";
          this.responseError(
            `openui5 SDK is loaded, module: ${missingModule} is not available in openui5`,
          );
          return;
        }
        this.responseError(err);
      },

      // Terminate the roundtrip in an unrecoverable state: clear the busy
      // state and show the fatal-error overlay (core/ErrorView). `response`
      // may be a string or an Error object; `title` overrides the default
      // header text; `oOptions.onRetry` adds a Retry action to the overlay
      // (used for network/timeout failures where the request may never have
      // reached the server).
      responseError(response, title, oOptions) {
        BusyIndicator.hide();
        AppState.state.isBusy = false;
        ErrorView.show(response, title, oOptions);
      },
    };
  },
);
