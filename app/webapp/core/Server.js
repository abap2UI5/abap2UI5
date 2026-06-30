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
  ) => {
    "use strict";

    const _MSG_TYPES = Object.freeze(["S_MSG_TOAST", "S_MSG_BOX"]);

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
        if (!Lib.isValidContextId(z2ui5.contextId)) return;
        // Best-effort notify the backend that the session ends. Errors are
        // intentionally swallowed: the browser tab is closing anyway.
        fetch(z2ui5.url, {
          method: "HEAD",
          keepalive: true,
          headers: {
            "sap-terminate": "session",
            "sap-contextid": z2ui5.contextId,
            "sap-contextid-accept": "header",
          },
        }).catch(() => {});
        // Null instead of delete: contextId is an accessor installed by
        // core/AppState, deleting it would remove the accessor itself.
        z2ui5.contextId = null;
      },

      _getDeviceInfo() {
        const d = Device;
        // SYSTEM / BROWSER / OS / SUPPORT are fixed for the lifetime of the
        // session, so resolve them once and reuse the cached block; only
        // ORIENTATION and RESIZE are read fresh on every roundtrip.
        if (!this._deviceStatic) {
          this._deviceStatic = {
            SYSTEM: Lib.deriveSystemType(d.system),
            BROWSER: {
              NAME: d.browser.name || "",
              VERSION: String(d.browser.version || ""),
            },
            OS: {
              NAME: d.os.name || "",
              VERSION: String(d.os.version || ""),
            },
            SUPPORT: {
              TOUCH: d.support.touch || false,
              POINTER: d.support.pointer || false,
              RETINA: d.support.retina || false,
            },
          };
        }
        return {
          ...this._deviceStatic,
          ORIENTATION: d.orientation.portrait ? "portrait" : "landscape",
          RESIZE: {
            WIDTH: d.resize.width || window.innerWidth,
            HEIGHT: d.resize.height || window.innerHeight,
          },
        };
      },

      // Strip the owning view's "<viewId>--" prefix from a control id so the
      // backend gets the id as the app declared it. Returns the id unchanged
      // when it does not belong to that view.
      _stripViewPrefix(fullId, view) {
        if (!view) return fullId;
        const prefix = `${view.getId()}--`;
        return fullId.startsWith(prefix) ? fullId.slice(prefix.length) : fullId;
      },

      _getFocusInfo() {
        try {
          const active = document.activeElement;
          if (!active) return {};
          // Element.closestTo exists as of UI5 1.106; keep the feature check
          // so older releases simply skip the focus restore.
          const ui5El = Element.closestTo?.(active) ?? null;
          if (!ui5El) return {};
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
        } catch (e) {
          return {};
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
        // Resolving the UI5 control (Element.closestTo) and walking it up to
        // its view slot (ViewSlots.containingSlotKey) is the expensive part,
        // so cache that resolution keyed by the element: it runs once per
        // scrolled element instead of once per event. Only the cheap
        // scroll-position record stays per event.
        if (target !== this._lastScrollTarget) {
          const ui5El = Element.closestTo?.(target) ?? null;
          this._lastScrollTarget = target;
          this._lastScrollUi5El = ui5El;
          this._lastScrollSlotKey = ui5El
            ? ViewSlots.containingSlotKey(ui5El)
            : undefined;
        }

        if (this._lastScrollSlotKey) {
          z2ui5.lastScrolled[this._lastScrollSlotKey] = {
            control: this._lastScrollUi5El,
            dom: target,
          };
        }
      },

      _getScrollInfo() {
        // Reads scrollLeft/scrollTop straight from the DOM element the user
        // last scrolled in each view slot (recorded by onScrollCapture).
        // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are
        // absent from the result - restoring 0/0 would be a no-op anyway.
        const store = z2ui5.lastScrolled;
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
        z2ui5.checkNestAfter = false;
        z2ui5.checkNestAfter2 = false;

        // Keep the global record in sync (debug tool "Previous Request",
        // app hooks); the parameter stays the working object. Calls without
        // a body (initial roundtrip, route changes) start from scratch.
        z2ui5.oBody = oBody;

        // Pick the first event argument (event name) safely.
        let eventName;
        if (oBody.ARGUMENTS?.[0]) {
          eventName = oBody.ARGUMENTS[0][0];
        }

        oBody.S_FRONT = {
          CONFIG: {
            S_UI5: z2ui5.oConfig?.S_UI5,
            S_DEVICE: this._getDeviceInfo(),
            S_FOCUS: this._getFocusInfo(),
            S_SCROLL: this._getScrollInfo(),
            ComponentData: z2ui5.oConfig?.ComponentData,
          },
          ID: oBody.ID,
          ORIGIN: window.location.origin,
          PATHNAME: window.location.pathname,
          SEARCH: z2ui5.search || window.location.search,
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
        if (!sFront.T_EVENT_ARG || sFront.T_EVENT_ARG.length === 0) {
          delete sFront.T_EVENT_ARG;
        }
        if (sFront.SEARCH === "") delete sFront.SEARCH;
        if (!oBody.XX) delete oBody.XX;

        this.readHttp(oBody);
      },

      async readHttp(oBody) {
        // Step 1: send the request.
        let response;
        const timeoutMs = z2ui5.requestTimeoutMs || REQUEST_TIMEOUT_MS;
        try {
          // Only forward "sap-contextid" once we actually own a valid session
          // id - otherwise omit the header entirely (never send "" or
          // "undefined"; see isValidContextId).
          const headers = {
            "Content-Type": "application/json",
            "sap-contextid-accept": "header",
          };
          if (Lib.isValidContextId(z2ui5.contextId)) {
            headers["sap-contextid"] = z2ui5.contextId;
          }
          response = await fetch(z2ui5.url, {
            method: "POST",
            headers: headers,
            body: JSON.stringify({ value: oBody }),
            // The signal also guards reading the response body below.
            // Browsers without AbortSignal.timeout simply get no client-side
            // timeout, as before.
            signal: AbortSignal.timeout
              ? AbortSignal.timeout(timeoutMs)
              : undefined,
          });
        } catch (e) {
          if (e.name === "TimeoutError" || e.name === "AbortError") {
            this.responseError(
              `No backend response within ${timeoutMs / 1000} seconds - request aborted`,
            );
          } else {
            this.responseError(`Network error: ${e.message}`);
          }
          return;
        }
        // Keep the last valid session id; a response without the header
        // (returns null) must not wipe an established session.
        const contextId = response.headers.get("sap-contextid");
        if (Lib.isValidContextId(contextId)) {
          z2ui5.contextId = contextId;
        }

        // Step 2: if the HTTP status is not 2xx, treat the body as error text.
        if (!response.ok) {
          let text;
          try {
            text = await response.text();
          } catch (e) {
            text = `HTTP ${response.status}: could not read error body`;
          }
          this.responseError(text);
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
        z2ui5.responseData = responseData;
        z2ui5.xxChangedPaths = new Set();
        this.responseSuccess({
          ID: responseData.S_FRONT.ID,
          PARAMS: responseData.S_FRONT.PARAMS,
          OVIEWMODEL: responseData.MODEL,
        });
      },

      async responseSuccess(response) {
        const oController = ViewSlots.getController("MAIN");
        try {
          z2ui5.oResponse = response;
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
          z2ui5.pendingCustomJs = followUp?.CUSTOM_JS || null;

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
          z2ui5.isBusy = false;
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
      // Format A:  "alert(123)"           -> runs the expression
      // Format B:  "eF('A','B','C')"      -> calls oController.eF('A','B','C')
      //
      // OBSOLETE: this mechanism (including the quote-based argument parsing
      // and the Function() evaluation) only exists for backward compatibility
      // with older apps and will be removed in a future release. Do not
      // extend or change it.
      _runCustomJs(item, oController) {
        try {
          const parts = item.split("'");
          // Arguments live at the odd indices between single quotes.
          const args = parts.filter((_, index) => index % 2 === 1);
          if (args.length > 0) {
            oController.eF(...args);
          } else {
            // eslint-disable-next-line no-new-func
            Function("return " + parts[0])();
          }
        } catch (e) {
          Lib.logError("customJs: execution failed", e);
        }
      },

      // Terminate the roundtrip in an unrecoverable state: clear the busy
      // state and show the fatal-error overlay (core/ErrorView). `response`
      // may be a string or an Error object; `title` overrides the default
      // header text.
      responseError(response, title) {
        BusyIndicator.hide();
        z2ui5.isBusy = false;
        ErrorView.show(response, title);
      },
    };
  },
);
