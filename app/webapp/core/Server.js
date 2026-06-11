sap.ui.define(
  [
    "sap/ui/core/BusyIndicator",
    "sap/ui/Device",
    "sap/ui/core/Element",
    "z2ui5/core/Lib",
  ],
  (BusyIndicator, Device, Element, Lib) => {
    "use strict";

    // Errors longer than this are truncated before being shown to the user,
    // so a stack trace from the backend cannot blow up the error overlay.
    const ERROR_MAX_LENGTH = 50000;
    const _MSG_TYPES = Object.freeze(["S_MSG_TOAST", "S_MSG_BOX"]);

    // Last-resort client-side timeout for backend roundtrips. Infrastructure
    // timeouts (ICM, web dispatcher, proxies) usually fire much earlier and
    // surface as a regular error response; this backstop only ensures that a
    // completely hung connection cannot leave the busy indicator spinning
    // forever. Override via z2ui5.requestTimeoutMs.
    const REQUEST_TIMEOUT_MS = 600000;

    // Roundtrip lifecycle (spans this file and View1.controller.js):
    //   1. View1.eB(...)              collects the model delta into z2ui5.oBody
    //   2. Server.roundtrip()         adds S_FRONT (device/focus/scroll info)
    //   3. Server.readHttp()          POSTs { value: oBody }, parses the JSON
    //   4. Server.responseSuccess()   shows messages, rebuilds/updates views
    //   5. View1._processAfterRendering()  popups, nested views, history,
    //      then runs pending follow-up JS once rendering is done
    // State is handed between the steps via the z2ui5 globals oBody,
    // oResponse and pendingCustomJs.
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
        delete z2ui5.contextId;
      },

      _getDeviceInfo() {
        const d = Device;
        const sys = d.system;
        let system = "desktop";
        if (sys.phone) {
          system = "phone";
        } else if (sys.tablet) {
          system = "tablet";
        } else if (sys.combi) {
          system = "combi";
        }
        return {
          SYSTEM: system,
          ORIENTATION: d.orientation.portrait ? "portrait" : "landscape",
          BROWSER: {
            NAME: d.browser.name || "",
            VERSION: String(d.browser.version || ""),
          },
          OS: {
            NAME: d.os.name || "",
            VERSION: String(d.os.version || ""),
          },
          RESIZE: {
            WIDTH: d.resize.width || window.innerWidth,
            HEIGHT: d.resize.height || window.innerHeight,
          },
          SUPPORT: {
            TOUCH: d.support.touch || false,
            POINTER: d.support.pointer || false,
            RETINA: d.support.retina || false,
          },
        };
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
          const views = Lib.viewSlots.map((slot) => z2ui5[slot.prop]);
          let id = fullId;
          for (const v of views) {
            if (!v) continue;
            const prefix = v.getId() + "--";
            if (fullId.startsWith(prefix)) {
              id = fullId.slice(prefix.length);
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
        const ui5El = Element.closestTo?.(target) ?? null;
        if (!ui5El) return;

        // Walk up the control tree to find the view slot the scrolled
        // element belongs to (innermost slot wins, e.g. nested views).
        let current = ui5El;
        while (current) {
          for (const slot of Lib.viewSlots) {
            if (z2ui5[slot.prop] === current) {
              if (!z2ui5.lastScrolled) z2ui5.lastScrolled = {};
              z2ui5.lastScrolled[slot.key] = { control: ui5El, dom: target };
              return;
            }
          }
          current = current.getParent?.();
        }
      },

      _getScrollInfo() {
        // Reads scrollLeft/scrollTop straight from the DOM element the user
        // last scrolled in each view slot (recorded by onScrollCapture).
        // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are
        // absent from the result - restoring 0/0 would be a no-op anyway.
        const store = z2ui5.lastScrolled;
        if (!store) return undefined;

        const out = {};
        for (const slot of Lib.viewSlots) {
          const entry = store[slot.key];
          if (!entry) continue;

          // Drop stale references, e.g. after the view was replaced.
          if (!entry.dom.isConnected) {
            delete store[slot.key];
            continue;
          }

          let id = entry.control.getId();
          const view = z2ui5[slot.prop];
          const prefix = view ? `${view.getId()}--` : "";
          if (prefix && id.startsWith(prefix)) id = id.slice(prefix.length);
          out[slot.key] = {
            ID: id,
            X: entry.dom.scrollLeft || 0,
            Y: entry.dom.scrollTop || 0,
          };
        }
        // Returning undefined lets JSON.stringify omit S_SCROLL entirely.
        return Object.keys(out).length ? out : undefined;
      },

      roundtrip() {
        z2ui5.checkNestAfter = false;
        z2ui5.checkNestAfter2 = false;

        if (!z2ui5.oBody) z2ui5.oBody = {};
        const oBody = z2ui5.oBody;

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

        this.readHttp();
      },

      async readHttp() {
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
            body: JSON.stringify({ value: z2ui5.oBody }),
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
        const oController = z2ui5.oController;
        try {
          z2ui5.oResponse = response;
          const params = response.PARAMS;
          const sView = params?.S_VIEW;

          if (sView?.CHECK_DESTROY) oController.destroyView();

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

          for (const t of _MSG_TYPES) oController.showMessage(t, params);

          // Full view replacement -> destroy & rebuild, nothing more to do.
          if (sView?.XML) {
            oController.destroyView();
            await oController.displayView(sView.XML, response.OVIEWMODEL);
            return;
          }

          // Partial response: refresh whichever existing views the backend
          // sent updates for.
          for (const slot of Lib.viewSlots) {
            oController.updateModelIfRequired(slot.param, z2ui5[slot.prop]);
          }
          oController._processAfterRendering();
        } catch (e) {
          BusyIndicator.hide();
          z2ui5.isBusy = false;
          Lib.logError("responseSuccess: unexpected error", e);
          const msg = e.message || "";
          if (msg.includes("openui5") && msg.includes("script load error")) {
            oController.checkSDKcompatibility(e);
          } else {
            this.responseError(e);
          }
        }
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

      _getOrCreateErrorContainer() {
        const existing = document.getElementById("serverErrorContainer");
        if (existing) return existing;

        const container = document.createElement("div");
        container.id = "serverErrorContainer";
        container.style.cssText = `
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          width: 90%;
          height: 90%;
          background: white;
          border: 2px solid #d32f2f;
          border-radius: 4px;
          box-shadow: 0 4px 6px rgba(0,0,0,0.3);
          z-index: 9999;
          display: flex;
          flex-direction: column;
        `;
        document.body.appendChild(container);
        return container;
      },

      // Unified fatal-error overlay. Shown whenever the app reaches an
      // unrecoverable state - a failed roundtrip (network, HTTP != 2xx, bad
      // JSON, backend dump) or a client-side failure (invalid view XML,
      // post-render crash, missing SDK module). The only way out is a restart,
      // hence the Refresh / Logout actions. Built from raw DOM so it still
      // works when the UI5 core itself is in a broken state.
      // `response` may be a string or an Error object; `title` overrides the
      // default header text.
      responseError(response, title) {
        BusyIndicator.hide();
        z2ui5.isBusy = false;

        const full = response?.stack
          ? String(response.stack)
          : String(response);
        let errorMessage;
        if (full.length > ERROR_MAX_LENGTH) {
          errorMessage =
            full.slice(0, ERROR_MAX_LENGTH) +
            "\n\n<!-- Content truncated - too long -->";
        } else {
          errorMessage = full;
        }

        const errorContainer = this._getOrCreateErrorContainer();
        errorContainer.textContent = "";

        // Header bar with title and action buttons.
        const headerDiv = document.createElement("div");
        headerDiv.style.cssText =
          "padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;";

        const h3 = document.createElement("h3");
        h3.textContent = title || "Application Error - Please Restart The App";
        h3.style.cssText = "margin: 0";
        headerDiv.appendChild(h3);

        const btnStyle =
          "padding: 6px 14px; background: white; color: #d32f2f; border: none; border-radius: 3px; cursor: pointer; font-weight: bold;";

        const actionsDiv = document.createElement("div");
        actionsDiv.style.cssText = "display: flex; gap: 8px;";

        const refreshBtn = document.createElement("button");
        refreshBtn.type = "button";
        refreshBtn.textContent = "Refresh";
        refreshBtn.style.cssText = btnStyle;
        refreshBtn.addEventListener("click", () => window.location.reload());
        actionsDiv.appendChild(refreshBtn);

        const logoutBtn = document.createElement("button");
        logoutBtn.type = "button";
        logoutBtn.textContent = "Logout";
        logoutBtn.style.cssText = btnStyle;
        logoutBtn.addEventListener("click", () => this._handleLogout());
        actionsDiv.appendChild(logoutBtn);

        headerDiv.appendChild(actionsDiv);
        errorContainer.appendChild(headerDiv);

        // The error text itself lives inside a sandboxed iframe so any HTML
        // in the backend response cannot execute or affect the main page.
        const iframe = document.createElement("iframe");
        iframe.id = "errorIframe";
        iframe.style.cssText =
          "width: 100%; height: 100%; border: none; flex: 1;";
        iframe.setAttribute("sandbox", "allow-same-origin");
        errorContainer.appendChild(iframe);

        const contentDocument = iframe.contentDocument;
        if (contentDocument) {
          const pre = contentDocument.createElement("pre");
          pre.style.cssText =
            "margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all;";
          pre.textContent = errorMessage;
          const target =
            contentDocument.body || contentDocument.documentElement;
          target.appendChild(pre);
        }
      },

      // Logout via the launchpad if available; otherwise hit the SAP logoff URL.
      _handleLogout() {
        const fallback = () => {
          window.location.href = "/sap/public/bc/icf/logoff";
        };
        try {
          const launchpadLogout =
            z2ui5.oLaunchpad?.Container && z2ui5.oLaunchpad.Container.logout;
          if (launchpadLogout) {
            z2ui5.oLaunchpad.Container.logout();
          } else {
            fallback();
          }
        } catch (e) {
          fallback();
        }
      },
    };
  },
);
