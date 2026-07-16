sap.ui.define(
  [
    "sap/ui/core/BusyIndicator",
    "sap/ui/Device",
    "sap/ui/core/Element",
    "sap/ui/VersionInfo",
    "z2ui5/core/Lib",
    "z2ui5/core/ViewSlots",
    "z2ui5/core/ErrorView",
    "z2ui5/core/Messages",
    "z2ui5/core/AppState",
  ],
  (
    BusyIndicator,
    Device,
    Element,
    VersionInfo,
    Lib,
    ViewSlots,
    ErrorView,
    Messages,
    AppState,
  ) => {
    "use strict";

    const _MSG_TYPES = Object.freeze(["S_MSG_TOAST", "S_MSG_BOX"]);

    // Quote characters recognised by the eF( ) argument parser below. The
    // single quote is built from its char code on purpose: keeping a literal
    // single-quote character out of this file avoids confusing the ABAP
    // source generator, which ships this module as an ABAP string literal.
    const CH_SQUOTE = String.fromCharCode(39);
    const CH_DQUOTE = String.fromCharCode(34);

    // Convert a single JS-literal argument (as produced by the backend
    // get_t_arg) into a value WITHOUT eval: single- or double-quoted strings,
    // JSON objects / arrays, numbers, booleans and null.
    function parseEfValue(token) {
      if (token === "") return undefined;
      const first = token[0];
      if (first === CH_SQUOTE) {
        return token.slice(1, -1).replace(/\\([\x27\\])/g, "$1");
      }
      if (first === CH_DQUOTE || first === "{" || first === "[") {
        try {
          return JSON.parse(token);
        } catch {
          return token;
        }
      }
      if (token === "true") return true;
      if (token === "false") return false;
      if (token === "null") return null;
      if (token === "undefined") return undefined;
      const num = Number(token);
      return Number.isNaN(num) ? token : num;
    }

    // Split the argument list of an eF( ) call into its top-level arguments,
    // respecting nested (), {}, [] and quoted strings, and convert each one
    // to a value. Done manually (no eval / Function) so it works under a
    // strict Content-Security-Policy without unsafe-eval, while keeping
    // object, array and quoted-string arguments intact.
    function parseEfArgs(str) {
      const args = [];
      let depth = 0;
      let quote = null;
      let token = "";
      for (let i = 0; i < str.length; i++) {
        const ch = str[i];
        if (quote) {
          token += ch;
          if (ch === "\\" && i + 1 < str.length) token += str[++i];
          else if (ch === quote) quote = null;
          continue;
        }
        if (ch === CH_SQUOTE || ch === CH_DQUOTE) {
          quote = ch;
          token += ch;
        } else if (ch === "{" || ch === "[" || ch === "(") {
          depth++;
          token += ch;
        } else if (ch === "}" || ch === "]" || ch === ")") {
          depth--;
          token += ch;
        } else if (ch === "," && depth === 0) {
          args.push(parseEfValue(token.trim()));
          token = "";
        } else {
          token += ch;
        }
      }
      if (token.trim() !== "") args.push(parseEfValue(token.trim()));
      return args;
    }

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
    //   5. View1._processAfterRendering()  popups, nested views, history,
    //      then runs pending follow-up JS once rendering is done
    // The request body travels through the steps as a parameter; it is
    // mirrored to z2ui5.oBody so onBeforeRoundtrip hooks and the debug tool
    // can inspect it. Only the response side still crosses an async boundary
    // (the rendering) via the globals oResponse and pendingCustomJs.
    //
    // Wire format - request (POST body; VIEWNAME/ARGUMENTS are folded into
    // S_FRONT before sending, empty fields are removed):
    //   { "value": {
    //       "XX": {                        // two-way model delta
    //         "NAME": "new value",         //   scalar: full attribute
    //         "TAB": { "__delta": { "0": { "COL1": "new cell" } } }
    //       },
    //       "S_FRONT": {
    //         "ID": "<draft id of the previous response>",
    //         "EVENT": "SAVE",             // event name
    //         "T_EVENT_ARG": ["arg1"],     // further event arguments
    //         "VIEW": "MAIN",              // which view fired it
    //         "ORIGIN": "https://host", "PATHNAME": "/sap/...",
    //         "SEARCH": "?p=1", "HASH": "#...",
    //         "CONFIG": { "S_UI5": {...}, "S_DEVICE": {...},
    //                     "S_FOCUS": {...}, "S_SCROLL": {...},
    //                     "ComponentData": {...} }
    //   } } }
    //
    // Wire format - response:
    //   { "S_FRONT": {
    //       "ID": "<new draft id>",        // sent back with the next request
    //       "PARAMS": {
    //         "S_VIEW":      { "XML": "<mvc:View...>", "CHECK_DESTROY": "" },
    //         "S_VIEW_NEST", "S_VIEW_NEST2", "S_POPUP", "S_POPOVER": same,
    //         "S_MSG_TOAST": { "TEXT": "...", ... },
    //         "S_MSG_BOX":   { "TEXT": "...", "TYPE": "error", ... },
    //         "S_FOLLOW_UP_ACTION": { "CUSTOM_JS": ["eF('SET_FOCUS','id1')"] },
    //         "SET_PUSH_STATE": "", "SET_APP_STATE_ACTIVE": "",
    //         "SET_NAV_BACK": ""           // browser/history follow-ups
    //       }
    //     },
    //     "MODEL": { "XX": {...}, ... }    // full JSON view model, becomes
    //   }                                  // the view's binding model
    //
    // Inspect live payloads via the debug tool (Ctrl+F12): "Previous
    // Request" and "Response".
    return {
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

      _getDeviceInfo() {
        // SYSTEM / BROWSER / OS / SUPPORT are fixed for the lifetime of the
        // session, so resolve them once and reuse the cached block; only
        // ORIENTATION and RESIZE are read fresh on every roundtrip.
        if (!this._deviceStatic) {
          this._deviceStatic = {
            SYSTEM: Lib.deriveSystemType(Device.system),
            BROWSER: {
              NAME: Device.browser.name || "",
              VERSION: String(Device.browser.version || ""),
            },
            OS: {
              NAME: Device.os.name || "",
              VERSION: String(Device.os.version || ""),
            },
            SUPPORT: {
              TOUCH: Device.support.touch || false,
              POINTER: Device.support.pointer || false,
              RETINA: Device.support.retina || false,
            },
          };
        }
        return {
          ...this._deviceStatic,
          ORIENTATION: Device.orientation.portrait ? "portrait" : "landscape",
          RESIZE: {
            WIDTH: Device.resize.width || window.innerWidth,
            HEIGHT: Device.resize.height || window.innerHeight,
          },
        };
      },

      // Resolve the UI5 element owning a DOM node. Element.closestTo exists
      // as of UI5 1.106; on older bootstraps walk up the DOM to the nearest
      // rendered control root (marked with the data-sap-ui attribute) and
      // resolve it via the core registry, so scroll and focus capture also
      // work there.
      _closestUi5Element(dom) {
        if (Element.closestTo) return Element.closestTo(dom) ?? null;
        let el = dom;
        while (el && el.getAttribute) {
          if (el.hasAttribute("data-sap-ui")) {
            // ui5lint-disable-next-line no-globals, no-deprecated-api -- only resolution path on UI5 < 1.106
            return sap.ui.getCore().byId(el.id) || null;
          }
          el = el.parentElement;
        }
        return null;
      },

      // Strip the owning view's "<viewId>--" prefix from a control id so the
      // backend gets the id as the app declared it. Returns the id unchanged
      // when it does not belong to that view.
      _stripViewPrefix(fullId, view) {
        if (!view) return fullId;
        const prefix = `${view.getId()}--`;
        return fullId.startsWith(prefix) ? fullId.slice(prefix.length) : fullId;
      },

      // Returning undefined when no UI5 control owns the focus lets
      // JSON.stringify omit S_FOCUS from the request entirely, matching
      // _getScrollInfo (the backend treats a missing key like an empty one).
      _getFocusInfo() {
        try {
          const active = document.activeElement;
          if (!active) return undefined;
          const ui5El = this._closestUi5Element(active);
          if (!ui5El) return undefined;
          const fullId = ui5El.getId();
          let id = fullId;
          for (const slot of ViewSlots.slots) {
            const local = this._stripViewPrefix(
              fullId,
              ViewSlots.getView(slot.key),
            );
            if (local !== fullId) {
              id = local;
              break;
            }
          }
          return {
            ID: id,
            SELECTION_START: active.selectionStart || 0,
            SELECTION_END: active.selectionEnd || 0,
          };
        } catch {
          return undefined;
        }
      },

      // Records which element the user actually scrolled, per view slot.
      // Bound to a single document-level capture-phase listener (installed
      // in Component.init): scroll events do not bubble, but they do fire
      // capture listeners on ancestors, so one listener observes every
      // scrollable container - no per-roundtrip walk over the control tree,
      // and no guessing which container "looks scrolled".
      onScrollCapture(event) {
        const target = event.target;
        if (!target || target.nodeType !== 1) return;

        // Scroll events fire up to once per frame per element while the user
        // drags, but the same DOM element keeps firing throughout a gesture.
        // Resolving the UI5 control (_closestUi5Element) and walking it up to
        // its view slot (ViewSlots.containingSlotKey) is the expensive part,
        // so cache that resolution keyed by the element: it runs once per
        // scrolled element instead of once per event. Only the cheap
        // scroll-position record stays per event.
        if (target !== this._lastScrollTarget) {
          const ui5El = this._closestUi5Element(target);
          this._lastScrollTarget = target;
          this._lastScrollUi5El = ui5El;
          this._lastScrollSlotKey = ui5El
            ? ViewSlots.containingSlotKey(ui5El)
            : undefined;
        }

        if (this._lastScrollSlotKey) {
          AppState.state.lastScrolled[this._lastScrollSlotKey] = {
            control: this._lastScrollUi5El,
            dom: target,
          };
        }
      },

      _getScrollInfo() {
        // Release the per-element resolution cache of onScrollCapture once
        // its DOM node left the document (view replaced/destroyed) - the
        // detached element and its control would otherwise stay referenced
        // until the user scrolls the next time.
        if (this._lastScrollTarget && !this._lastScrollTarget.isConnected) {
          this._lastScrollTarget = undefined;
          this._lastScrollUi5El = undefined;
          this._lastScrollSlotKey = undefined;
        }

        // Reads scrollLeft/scrollTop straight from the DOM element the user
        // last scrolled in each view slot (recorded by onScrollCapture).
        // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are
        // absent from the result - restoring 0/0 would be a no-op anyway.
        const store = AppState.state.lastScrolled;
        const out = {};
        for (const slot of ViewSlots.slots) {
          const entry = store[slot.key];
          if (!entry) continue;

          // Drop stale references, e.g. after the view was replaced. Also
          // drop a destroyed control whose DOM is still transiently
          // connected: entry.control.getId() below would throw and abort the
          // whole roundtrip (this method, unlike _getFocusInfo, has no outer
          // try/catch).
          if (!entry.dom.isConnected || !Lib.isAlive(entry.control)) {
            delete store[slot.key];
            continue;
          }

          const id = this._stripViewPrefix(
            entry.control.getId(),
            ViewSlots.getView(slot.key),
          );
          out[slot.key] = {
            ID: id,
            X: entry.dom.scrollLeft || 0,
            Y: entry.dom.scrollTop || 0,
          };
        }
        // Returning undefined lets JSON.stringify omit S_SCROLL entirely.
        return Object.keys(out).length ? out : undefined;
      },

      roundtrip(oBody = {}) {
        const state = AppState.state;
        state.checkNestAfter = false;
        state.checkNestAfter2 = false;

        // Keep the shared record in sync (debug tool "Previous Request",
        // app hooks); the parameter stays the working object. Calls without
        // a body (initial roundtrip, route changes) start from scratch.
        state.oBody = oBody;

        // Pick the first event argument (event name) safely.
        const eventName = oBody.ARGUMENTS?.[0]?.[0];

        const oConfig = AppState.getGlobal("oConfig");
        oBody.S_FRONT = {
          CONFIG: {
            S_UI5: oConfig?.S_UI5,
            S_DEVICE: this._getDeviceInfo(),
            S_FOCUS: this._getFocusInfo(),
            S_SCROLL: this._getScrollInfo(),
            ComponentData: oConfig?.ComponentData,
          },
          ID: oBody.ID,
          ORIGIN: window.location.origin,
          PATHNAME: window.location.pathname,
          SEARCH: state.search || window.location.search,
          VIEW: oBody.VIEWNAME,
          EVENT: eventName,
          HASH: window.location.hash,
        };
        const sFront = oBody.S_FRONT;

        // The first argument was the event name (already stored as EVENT),
        // the remaining entries are the actual event arguments.
        if (oBody.ARGUMENTS) oBody.ARGUMENTS.shift();
        sFront.T_EVENT_ARG = oBody.ARGUMENTS;

        delete oBody.ID;
        delete oBody.VIEWNAME;
        delete oBody.ARGUMENTS;

        // Remove empty / undefined fields so the backend request stays small
        // and these keys are not present in the JSON sent over the wire.
        if (!sFront.T_EVENT_ARG?.length) delete sFront.T_EVENT_ARG;
        if (sFront.SEARCH === "") delete sFront.SEARCH;
        if (!oBody.XX) delete oBody.XX;

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

      async readHttp(oBody) {
        const timeoutMs =
          AppState.getGlobal("requestTimeoutMs") || REQUEST_TIMEOUT_MS;
        // The signal guards the fetch and the response body reads below; the
        // finally releases the fallback timer once the roundtrip settled.
        const { signal, cancel } = this.createTimeoutSignal(timeoutMs);
        // A network blip or timeout may mean the request never reached the
        // server, so the error overlay offers a retry that re-sends the
        // exact same request body instead of forcing a full app restart.
        const oRetry = { onRetry: () => this.readHttp(oBody) };
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
            this.responseError(`Invalid JSON response: ${e.message}`);
            return;
          }
          if (!responseData || !responseData.S_FRONT) {
            this.responseError("Invalid response: missing S_FRONT");
            return;
          }

          // Step 4: hand the parsed response to the success handler.
          AppState.state.responseData = responseData;
          AppState.state.xxChangedPaths = new Set();
          this.responseSuccess({
            ID: responseData.S_FRONT.ID,
            PARAMS: responseData.S_FRONT.PARAMS,
            OVIEWMODEL: responseData.MODEL,
          });
        } finally {
          cancel();
        }
      },

      async responseSuccess(response) {
        const oController = ViewSlots.getController("MAIN");
        try {
          AppState.state.oResponse = response;
          const params = response.PARAMS;
          const sView = params?.S_VIEW;

          if (sView?.CHECK_DESTROY) ViewSlots.destroy("MAIN");

          // The backend can send small JS snippets to run after the response.
          // Each snippet is either a literal expression or an "eF(...)" call
          // whose arguments are wrapped in single quotes. They are stashed
          // here and executed at the end of _processAfterRendering, i.e. once
          // the (possibly freshly built) view is actually rendered. Running
          // them earlier would break render-dependent actions such as
          // SET_FOCUS on the initial view, where the target control does not
          // exist in the DOM yet.
          const followUp = params?.S_FOLLOW_UP_ACTION;
          AppState.state.pendingCustomJs = followUp?.CUSTOM_JS || null;

          for (const t of _MSG_TYPES) Messages.show(t, params, oController);

          // Full view replacement -> destroy & rebuild, nothing more to do.
          if (sView?.XML) {
            ViewSlots.destroy("MAIN");
            await oController.displayView(sView.XML, response.OVIEWMODEL);
            return;
          }

          // Partial response: refresh whichever existing views the backend
          // sent updates for.
          for (const slot of ViewSlots.slots) {
            oController.updateModelIfRequired(slot.key);
          }
          oController._processAfterRendering();
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
          Lib.logError("_checkSDKcompatibility: VersionInfo.load failed", e);
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

      // Executes a single custom-JS snippet from the backend.
      // Format A:  a raw expression such as alert(123) - needs a CSP that
      //            allows unsafe-eval, otherwise it is a no-op.
      // Format B:  a structured eF( ) frontend-event call - dispatched via
      //            oController.eF( ). Its argument list is parsed manually
      //            (no eval / Function) so it runs under a strict CSP while
      //            keeping object / array / string arguments intact.
      _runCustomJs(item, oController) {
        try {
          const snippet = item.trim();
          const match = /^\.?eF\s*\(([\s\S]*)\)\s*;?$/.exec(snippet);
          if (match) {
            oController.eF(...parseEfArgs(match[1]));
          } else {
            // A raw JavaScript expression - only runs when the CSP allows
            // unsafe-eval.
            // eslint-disable-next-line no-new-func
            Function("return " + item)();
          }
        } catch (e) {
          Lib.logError("customJs: execution failed", e);
        }
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
