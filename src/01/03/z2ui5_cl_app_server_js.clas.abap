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
             `    "sap/ui/Device",` && |\n| &&
             `    "sap/ui/core/Element",` && |\n| &&
             `    "z2ui5/cc/Lib",` && |\n| &&
             `  ],` && |\n| &&
             `  (BusyIndicator, Device, Element, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // Errors longer than this are truncated before being shown to the user,` && |\n| &&
             `    // so a stack trace from the backend cannot blow up the error overlay.` && |\n| &&
             `    const ERROR_MAX_LENGTH = 50000;` && |\n| &&
             `    const _MSG_TYPES = Object.freeze(["S_MSG_TOAST", "S_MSG_BOX"]);` && |\n| &&
             `` && |\n| &&
             `    // Last-resort client-side timeout for backend roundtrips. Infrastructure` && |\n| &&
             `    // timeouts (ICM, web dispatcher, proxies) usually fire much earlier and` && |\n| &&
             `    // surface as a regular error response; this backstop only ensures that a` && |\n| &&
             `    // completely hung connection cannot leave the busy indicator spinning` && |\n| &&
             `    // forever. Override via z2ui5.requestTimeoutMs.` && |\n| &&
             `    const REQUEST_TIMEOUT_MS = 600000;` && |\n| &&
             `` && |\n| &&
             `    // Roundtrip lifecycle (spans this file and View1.controller.js):` && |\n| &&
             `    //   1. View1.eB(...)              collects the model delta into z2ui5.oBody` && |\n| &&
             `    //   2. Server.Roundtrip()         adds S_FRONT (device/focus/scroll info)` && |\n| &&
             `    //   3. Server.readHttp()          POSTs { value: oBody }, parses the JSON` && |\n| &&
             `    //   4. Server.responseSuccess()   shows messages, rebuilds/updates views` && |\n| &&
             `    //   5. View1._processAfterRendering()  popups, nested views, history,` && |\n| &&
             `    //      then runs pending follow-up JS once rendering is done` && |\n| &&
             `    // State is handed between the steps via the z2ui5 globals oBody,` && |\n| &&
             `    // oResponse and pendingCustomJs.` && |\n| &&
             `    //` && |\n| &&
             `    // Wire format - request (POST body; VIEWNAME/ARGUMENTS are folded into` && |\n| &&
             `    // S_FRONT before sending, empty fields are removed):` && |\n| &&
             `    //   { "value": {` && |\n| &&
             `    //       "XX": {                        // two-way model delta` && |\n| &&
             `    //         "NAME": "new value",         //   scalar: full attribute` && |\n| &&
             `    //         "TAB": { "__delta": { "0": { "COL1": "new cell" } } }` && |\n| &&
             `    //       },` && |\n| &&
             `    //       "S_FRONT": {` && |\n| &&
             `    //         "ID": "<draft id of the previous response>",` && |\n| &&
             `    //         "EVENT": "SAVE",             // event name` && |\n| &&
             `    //         "T_EVENT_ARG": ["arg1"],     // further event arguments` && |\n| &&
             `    //         "VIEW": "MAIN",              // which view fired it` && |\n| &&
             `    //         "ORIGIN": "https://host", "PATHNAME": "/sap/...",` && |\n| &&
             `    //         "SEARCH": "?p=1", "HASH": "#...",` && |\n| &&
             `    //         "CONFIG": { "S_UI5": {...}, "S_DEVICE": {...},` && |\n| &&
             `    //                     "S_FOCUS": {...}, "S_SCROLL": {...},` && |\n| &&
             `    //                     "ComponentData": {...} }` && |\n| &&
             `    //   } } }` && |\n| &&
             `    //` && |\n| &&
             `    // Wire format - response:` && |\n| &&
             `    //   { "S_FRONT": {` && |\n| &&
             `    //       "ID": "<new draft id>",        // sent back with the next request` && |\n| &&
             `    //       "PARAMS": {` && |\n| &&
             `    //         "S_VIEW":      { "XML": "<mvc:View...>", "CHECK_DESTROY": "" },` && |\n| &&
             `    //         "S_VIEW_NEST", "S_VIEW_NEST2", "S_POPUP", "S_POPOVER": same,` && |\n| &&
             `    //         "S_MSG_TOAST": { "TEXT": "...", ... },` && |\n| &&
             `    //         "S_MSG_BOX":   { "TEXT": "...", "TYPE": "error", ... },` && |\n| &&
             `    //         "S_FOLLOW_UP_ACTION": { "CUSTOM_JS": ["eF('SET_FOCUS','id1')"] },` && |\n| &&
             `    //         "SET_PUSH_STATE": "", "SET_APP_STATE_ACTIVE": "",` && |\n| &&
             `    //         "SET_NAV_BACK": ""           // browser/history follow-ups` && |\n| &&
             `    //       }` && |\n| &&
             `    //     },` && |\n| &&
             `    //     "MODEL": { "XX": {...}, ... }    // full JSON view model, becomes` && |\n| &&
             `    //   }                                  // the view's binding model` && |\n| &&
             `    //` && |\n| &&
             `    // Inspect live payloads via the debug tool (Ctrl+F12): "Previous` && |\n| &&
             `    // Request" and "Response".` && |\n| &&
             `    return {` && |\n| &&
             `      endSession() {` && |\n| &&
             `        if (!Lib.isValidContextId(z2ui5.contextId)) return;` && |\n| &&
             `        // Best-effort notify the backend that the session ends. Errors are` && |\n| &&
             `        // intentionally swallowed: the browser tab is closing anyway.` && |\n| &&
             `        fetch(z2ui5.url, {` && |\n| &&
             `          method: "HEAD",` && |\n| &&
             `          keepalive: true,` && |\n| &&
             `          headers: {` && |\n| &&
             `            "sap-terminate": "session",` && |\n| &&
             `            "sap-contextid": z2ui5.contextId,` && |\n| &&
             `            "sap-contextid-accept": "header",` && |\n| &&
             `          },` && |\n| &&
             `        }).catch(() => {});` && |\n| &&
             `        delete z2ui5.contextId;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getDeviceInfo() {` && |\n| &&
             `        const d = Device;` && |\n| &&
             `        const sys = d.system;` && |\n| &&
             `        const system = sys.phone` && |\n| &&
             `          ? "phone"` && |\n| &&
             `          : sys.tablet` && |\n| &&
             `            ? "tablet"` && |\n| &&
             `            : sys.combi` && |\n| &&
             `              ? "combi"` && |\n| &&
             `              : "desktop";` && |\n| &&
             `        return {` && |\n| &&
             `          SYSTEM: system,` && |\n| &&
             `          ORIENTATION: d.orientation.portrait ? "portrait" : "landscape",` && |\n| &&
             `          BROWSER: {` && |\n| &&
             `            NAME: d.browser.name || "",` && |\n| &&
             `            VERSION: String(d.browser.version || ""),` && |\n| &&
             `          },` && |\n| &&
             `          OS: {` && |\n| &&
             `            NAME: d.os.name || "",` && |\n| &&
             `            VERSION: String(d.os.version || ""),` && |\n| &&
             `          },` && |\n| &&
             `          RESIZE: {` && |\n| &&
             `            WIDTH: d.resize.width || window.innerWidth,` && |\n| &&
             `            HEIGHT: d.resize.height || window.innerHeight,` && |\n| &&
             `          },` && |\n| &&
             `          SUPPORT: {` && |\n| &&
             `            TOUCH: d.support.touch || false,` && |\n| &&
             `            POINTER: d.support.pointer || false,` && |\n| &&
             `            RETINA: d.support.retina || false,` && |\n| &&
             `          },` && |\n| &&
             `        };` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getFocusInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const active = document.activeElement;` && |\n| &&
             `          if (!active) return {};` && |\n| &&
             `          // Element.closestTo exists as of UI5 1.106; keep the feature check` && |\n| &&
             `          // so older releases simply skip the focus restore.` && |\n| &&
             `          const ui5El = Element.closestTo ? Element.closestTo(active) : null;` && |\n| &&
             `          if (!ui5El) return {};` && |\n| &&
             `          const fullId = ui5El.getId();` && |\n| &&
             `          const views = Lib.viewSlots.map((slot) => z2ui5[slot.prop]);` && |\n| &&
             `          let id = fullId;` && |\n| &&
             `          for (const v of views) {` && |\n| &&
             `            if (!v) continue;` && |\n| &&
             `            const prefix = v.getId() + "--";` && |\n| &&
             `            if (fullId.startsWith(prefix)) {` && |\n| &&
             `              id = fullId.slice(prefix.length);` && |\n| &&
             `              break;` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `          return {` && |\n| &&
             `            ID: id,` && |\n| &&
             `            SELECTION_START: active.selectionStart || 0,` && |\n| &&
             `            SELECTION_END: active.selectionEnd || 0,` && |\n| &&
             `          };` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          return {};` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Records which element the user actually scrolled, per view slot.` && |\n| &&
             `      // Bound to a single document-level capture-phase listener (installed` && |\n| &&
             `      // in Component.init): scroll events do not bubble, but they do fire` && |\n| &&
             `      // capture listeners on ancestors, so one listener observes every` && |\n| &&
             `      // scrollable container - no per-roundtrip walk over the control tree,` && |\n| &&
             `      // and no guessing which container "looks scrolled".` && |\n| &&
             `      onScrollCapture(event) {` && |\n| &&
             `        const target = event.target;` && |\n| &&
             `        if (!target || target.nodeType !== 1) return;` && |\n| &&
             `        const ui5El = Element.closestTo ? Element.closestTo(target) : null;` && |\n| &&
             `        if (!ui5El) return;` && |\n| &&
             `` && |\n| &&
             `        // Walk up the control tree to find the view slot the scrolled` && |\n| &&
             `        // element belongs to (innermost slot wins, e.g. nested views).` && |\n| &&
             `        let current = ui5El;` && |\n| &&
             `        while (current) {` && |\n| &&
             `          for (const slot of Lib.viewSlots) {` && |\n| &&
             `            if (z2ui5[slot.prop] === current) {` && |\n| &&
             `              if (!z2ui5.lastScrolled) z2ui5.lastScrolled = {};` && |\n| &&
             `              z2ui5.lastScrolled[slot.key] = { control: ui5El, dom: target };` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `          current = current.getParent && current.getParent();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getScrollInfo() {` && |\n| &&
             `        // Reads scrollLeft/scrollTop straight from the DOM element the user` && |\n| &&
             `        // last scrolled in each view slot (recorded by onScrollCapture).` && |\n| &&
             `        // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are` && |\n| &&
             `        // absent from the result - restoring 0/0 would be a no-op anyway.` && |\n| &&
             `        const store = z2ui5.lastScrolled;` && |\n| &&
             `        if (!store) return undefined;` && |\n| &&
             `` && |\n| &&
             `        const out = {};` && |\n| &&
             `        for (const slot of Lib.viewSlots) {` && |\n| &&
             `          const entry = store[slot.key];` && |\n| &&
             `          if (!entry) continue;` && |\n| &&
             `` && |\n| &&
             `          // Drop stale references, e.g. after the view was replaced.` && |\n| &&
             `          if (!entry.dom.isConnected) {` && |\n| &&
             `            delete store[slot.key];` && |\n| &&
             `            continue;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          let id = entry.control.getId();` && |\n| &&
             `          const view = z2ui5[slot.prop];` && |\n| &&
             `          const prefix = view ? ``${view.getId()}--`` : "";` && |\n| &&
             `          if (prefix && id.startsWith(prefix)) id = id.slice(prefix.length);` && |\n| &&
             `          out[slot.key] = {` && |\n| &&
             `            ID: id,` && |\n| &&
             `            X: entry.dom.scrollLeft || 0,` && |\n| &&
             `            Y: entry.dom.scrollTop || 0,` && |\n| &&
             `          };` && |\n| &&
             `        }` && |\n| &&
             `        // Returning undefined lets JSON.stringify omit S_SCROLL entirely.` && |\n| &&
             `        return Object.keys(out).length ? out : undefined;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      Roundtrip() {` && |\n| &&
             `        z2ui5.checkNestAfter = false;` && |\n| &&
             `        z2ui5.checkNestAfter2 = false;` && |\n| &&
             `` && |\n| &&
             `        if (!z2ui5.oBody) z2ui5.oBody = {};` && |\n| &&
             `        const oBody = z2ui5.oBody;` && |\n| &&
             `` && |\n| &&
             `        // Pick the first event argument (event name) safely.` && |\n| &&
             `        let eventName;` && |\n| &&
             `        if (oBody.ARGUMENTS && oBody.ARGUMENTS[0]) {` && |\n| &&
             `          eventName = oBody.ARGUMENTS[0][0];` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        oBody.S_FRONT = {` && |\n| &&
             `          CONFIG: {` && |\n| &&
             `            S_UI5: z2ui5.oConfig && z2ui5.oConfig.S_UI5,` && |\n| &&
             `            S_DEVICE: this._getDeviceInfo(),` && |\n| &&
             `            S_FOCUS: this._getFocusInfo(),` && |\n| &&
             `            S_SCROLL: this._getScrollInfo(),` && |\n| &&
             `            ComponentData: z2ui5.oConfig && z2ui5.oConfig.ComponentData,` && |\n| &&
             `          },` && |\n| &&
             `          ID: oBody.ID,` && |\n| &&
             `          ORIGIN: window.location.origin,` && |\n| &&
             `          PATHNAME: window.location.pathname,` && |\n| &&
             `          SEARCH: z2ui5.search || window.location.search,` && |\n| &&
             `          VIEW: oBody.VIEWNAME,` && |\n| &&
             `          EVENT: eventName,` && |\n| &&
             `          HASH: window.location.hash,` && |\n| &&
             `        };` && |\n| &&
             `        const sFront = oBody.S_FRONT;` && |\n| &&
             `` && |\n| &&
             `        // The first argument was the event name (already stored as EVENT),` && |\n| &&
             `        // the remaining entries are the actual event arguments.` && |\n| &&
             `        if (oBody.ARGUMENTS) oBody.ARGUMENTS.shift();` && |\n| &&
             `        sFront.T_EVENT_ARG = oBody.ARGUMENTS;` && |\n| &&
             `` && |\n| &&
             `        delete oBody.ID;` && |\n| &&
             `        delete oBody.VIEWNAME;` && |\n| &&
             `        delete oBody.ARGUMENTS;` && |\n| &&
             `` && |\n| &&
             `        // Remove empty / undefined fields so the backend request stays small` && |\n| &&
             `        // and these keys are not present in the JSON sent over the wire.` && |\n| &&
             `        if (!sFront.T_EVENT_ARG || sFront.T_EVENT_ARG.length === 0) {` && |\n| &&
             `          delete sFront.T_EVENT_ARG;` && |\n| &&
             `        }` && |\n| &&
             `        if (sFront.SEARCH === "") delete sFront.SEARCH;` && |\n| &&
             `        if (!oBody.XX) delete oBody.XX;` && |\n| &&
             `` && |\n| &&
             `        this.readHttp();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async readHttp() {` && |\n| &&
             `        // Step 1: send the request.` && |\n| &&
             `        let response;` && |\n| &&
             `        const timeoutMs = z2ui5.requestTimeoutMs || REQUEST_TIMEOUT_MS;` && |\n| &&
             `        try {` && |\n| &&
             `          // Only forward "sap-contextid" once we actually own a valid session` && |\n| &&
             `          // id - otherwise omit the header entirely (never send "" or` && |\n| &&
             `          // "undefined"; see isValidContextId).` && |\n| &&
             `          const headers = {` && |\n| &&
             `            "Content-Type": "application/json",` && |\n| &&
             `            "sap-contextid-accept": "header",` && |\n| &&
             `          };` && |\n| &&
             `          if (Lib.isValidContextId(z2ui5.contextId)) {` && |\n| &&
             `            headers["sap-contextid"] = z2ui5.contextId;` && |\n| &&
             `          }` && |\n| &&
             `          response = await fetch(z2ui5.url, {` && |\n| &&
             `            method: "POST",` && |\n| &&
             `            headers: headers,` && |\n| &&
             `            body: JSON.stringify({ value: z2ui5.oBody }),` && |\n| &&
             `            // The signal also guards reading the response body below.` && |\n| &&
             `            // Browsers without AbortSignal.timeout simply get no client-side` && |\n| &&
             `            // timeout, as before.` && |\n| &&
             `            signal: AbortSignal.timeout` && |\n| &&
             `              ? AbortSignal.timeout(timeoutMs)` && |\n| &&
             `              : undefined,` && |\n| &&
             `          });` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          if (e.name === "TimeoutError" || e.name === "AbortError") {` && |\n| &&
             `            this.responseError(` && |\n| &&
             `              ``No backend response within ${timeoutMs / 1000} seconds - request aborted``,` && |\n| &&
             `            );` && |\n| &&
             `          } else {` && |\n| &&
             `            this.responseError(``Network error: ${e.message}``);` && |\n| &&
             `          }` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        // Keep the last valid session id; a response without the header` && |\n| &&
             `        // (returns null) must not wipe an established session.` && |\n| &&
             `        const contextId = response.headers.get("sap-contextid");` && |\n| &&
             `        if (Lib.isValidContextId(contextId)) {` && |\n| &&
             `          z2ui5.contextId = contextId;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Step 2: if the HTTP status is not 2xx, treat the body as error text.` && |\n| &&
             `        if (!response.ok) {` && |\n| &&
             `          let text;` && |\n| &&
             `          try {` && |\n| &&
             `            text = await response.text();` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            text = ``HTTP ${response.status}: could not read error body``;` && |\n| &&
             `          }` && |\n| &&
             `          this.responseError(text);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Step 3: parse the JSON body.` && |\n| &&
             `        let responseData;` && |\n| &&
             `        try {` && |\n| &&
             `          responseData = await response.json();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          this.responseError(``Invalid JSON response: ${e.message}``);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        if (!responseData || !responseData.S_FRONT) {` && |\n| &&
             `          this.responseError("Invalid response: missing S_FRONT");` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Step 4: hand the parsed response to the success handler.` && |\n| &&
             `        z2ui5.responseData = responseData;` && |\n| &&
             `        z2ui5.xxChangedPaths = new Set();` && |\n| &&
             `        this.responseSuccess({` && |\n| &&
             `          ID: responseData.S_FRONT.ID,` && |\n| &&
             `          PARAMS: responseData.S_FRONT.PARAMS,` && |\n| &&
             `          OVIEWMODEL: responseData.MODEL,` && |\n| &&
             `        });` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async responseSuccess(response) {` && |\n| &&
             `        const oController = z2ui5.oController;` && |\n| &&
             `        try {` && |\n| &&
             `          z2ui5.oResponse = response;` && |\n| &&
             `          const params = response.PARAMS;` && |\n| &&
             `          const sView = params && params.S_VIEW;` && |\n| &&
             `` && |\n| &&
             `          if (sView && sView.CHECK_DESTROY) oController.ViewDestroy();` && |\n| &&
             `` && |\n| &&
             `          // The backend can send small JS snippets to run after the response.` && |\n| &&
             `          // Each snippet is either a literal expression or an "eF(...)" call` && |\n| &&
             `          // whose arguments are wrapped in single quotes. They are stashed` && |\n| &&
             `          // here and executed at the end of _processAfterRendering, i.e. once` && |\n| &&
             `          // the (possibly freshly built) view is actually rendered. Running` && |\n| &&
             `          // them earlier would break render-dependent actions such as` && |\n| &&
             `          // SET_FOCUS on the initial view, where the target control does not` && |\n| &&
             `          // exist in the DOM yet.` && |\n| &&
             `          const followUp = params && params.S_FOLLOW_UP_ACTION;` && |\n| &&
             `          z2ui5.pendingCustomJs = (followUp && followUp.CUSTOM_JS) || null;` && |\n| &&
             `` && |\n| &&
             `          for (const t of _MSG_TYPES) oController.showMessage(t, params);` && |\n| &&
             `` && |\n| &&
             `          // Full view replacement -> destroy & rebuild, nothing more to do.` && |\n| &&
             `          if (sView && sView.XML) {` && |\n| &&
             `            oController.ViewDestroy();` && |\n| &&
             `            await oController.displayView(sView.XML, response.OVIEWMODEL);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Partial response: refresh whichever existing views the backend` && |\n| &&
             `          // sent updates for.` && |\n| &&
             `          for (const slot of Lib.viewSlots) {` && |\n| &&
             `            oController.updateModelIfRequired(slot.param, z2ui5[slot.prop]);` && |\n| &&
             `          }` && |\n| &&
             `          oController._processAfterRendering();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          z2ui5.isBusy = false;` && |\n| &&
             `          Lib.logError("responseSuccess: unexpected error", e);` && |\n| &&
             `          const msg = e.message || "";` && |\n| &&
             `          if (msg.includes("openui5") && msg.includes("script load error")) {` && |\n| &&
             `            oController.checkSDKcompatibility(e);` && |\n| &&
             `          } else {` && |\n| &&
             `            this.responseError(e);` && |\n| &&
             `          }` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Executes a single custom-JS snippet from the backend.` && |\n| &&
             `      // Format A:  "alert(123)"           -> runs the expression` && |\n| &&
             `      // Format B:  "eF('A','B','C')"      -> calls oController.eF('A','B','C')` && |\n| &&
             `      //` && |\n| &&
             `      // OBSOLETE: this mechanism (including the quote-based argument parsing` && |\n| &&
             `      // and the Function() evaluation) only exists for backward compatibility` && |\n| &&
             `      // with older apps and will be removed in a future release. Do not` && |\n| &&
             `      // extend or change it.` && |\n| &&
             `      _runCustomJs(item, oController) {` && |\n| &&
             `        try {` && |\n| &&
             `          const parts = item.split("'");` && |\n| &&
             `          // Arguments live at the odd indices between single quotes.` && |\n| &&
             `          const args = parts.filter((_, index) => index % 2 === 1);` && |\n| &&
             `          if (args.length > 0) {` && |\n| &&
             `            oController.eF(...args);` && |\n| &&
             |\n|.
    result = result &&
             `          } else {` && |\n| &&
             `            // eslint-disable-next-line no-new-func` && |\n| &&
             `            Function("return " + parts[0])();` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("customJs: execution failed", e);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getOrCreateErrorContainer() {` && |\n| &&
             `        const existing = document.getElementById("serverErrorContainer");` && |\n| &&
             `        if (existing) return existing;` && |\n| &&
             `` && |\n| &&
             `        const container = document.createElement("div");` && |\n| &&
             `        container.id = "serverErrorContainer";` && |\n| &&
             `        container.style.cssText = ``` && |\n| &&
             `          position: fixed;` && |\n| &&
             `          top: 50%;` && |\n| &&
             `          left: 50%;` && |\n| &&
             `          transform: translate(-50%, -50%);` && |\n| &&
             `          width: 90%;` && |\n| &&
             `          height: 90%;` && |\n| &&
             `          background: white;` && |\n| &&
             `          border: 2px solid #d32f2f;` && |\n| &&
             `          border-radius: 4px;` && |\n| &&
             `          box-shadow: 0 4px 6px rgba(0,0,0,0.3);` && |\n| &&
             `          z-index: 9999;` && |\n| &&
             `          display: flex;` && |\n| &&
             `          flex-direction: column;` && |\n| &&
             `        ``;` && |\n| &&
             `        document.body.appendChild(container);` && |\n| &&
             `        return container;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Unified fatal-error overlay. Shown whenever the app reaches an` && |\n| &&
             `      // unrecoverable state - a failed roundtrip (network, HTTP != 2xx, bad` && |\n| &&
             `      // JSON, backend dump) or a client-side failure (invalid view XML,` && |\n| &&
             `      // post-render crash, missing SDK module). The only way out is a restart,` && |\n| &&
             `      // hence the Refresh / Logout actions. Built from raw DOM so it still` && |\n| &&
             `      // works when the UI5 core itself is in a broken state.` && |\n| &&
             `      // ``response`` may be a string or an Error object; ``title`` overrides the` && |\n| &&
             `      // default header text.` && |\n| &&
             `      responseError(response, title) {` && |\n| &&
             `        BusyIndicator.hide();` && |\n| &&
             `        z2ui5.isBusy = false;` && |\n| &&
             `` && |\n| &&
             `        const full =` && |\n| &&
             `          response && response.stack` && |\n| &&
             `            ? String(response.stack)` && |\n| &&
             `            : String(response);` && |\n| &&
             `        let errorMessage;` && |\n| &&
             `        if (full.length > ERROR_MAX_LENGTH) {` && |\n| &&
             `          errorMessage =` && |\n| &&
             `            full.slice(0, ERROR_MAX_LENGTH) +` && |\n| &&
             `            "\n\n<!-- Content truncated - too long -->";` && |\n| &&
             `        } else {` && |\n| &&
             `          errorMessage = full;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        const errorContainer = this._getOrCreateErrorContainer();` && |\n| &&
             `        errorContainer.textContent = "";` && |\n| &&
             `` && |\n| &&
             `        // Header bar with title and action buttons.` && |\n| &&
             `        const headerDiv = document.createElement("div");` && |\n| &&
             `        headerDiv.style.cssText =` && |\n| &&
             `          "padding: 15px; background: #d32f2f; color: white; display: flex; justify-content: space-between; align-items: center;";` && |\n| &&
             `` && |\n| &&
             `        const h3 = document.createElement("h3");` && |\n| &&
             `        h3.textContent = title || "Application Error - Please Restart The App";` && |\n| &&
             `        h3.style.cssText = "margin: 0";` && |\n| &&
             `        headerDiv.appendChild(h3);` && |\n| &&
             `` && |\n| &&
             `        const btnStyle =` && |\n| &&
             `          "padding: 6px 14px; background: white; color: #d32f2f; border: none; border-radius: 3px; cursor: pointer; font-weight: bold;";` && |\n| &&
             `` && |\n| &&
             `        const actionsDiv = document.createElement("div");` && |\n| &&
             `        actionsDiv.style.cssText = "display: flex; gap: 8px;";` && |\n| &&
             `` && |\n| &&
             `        const refreshBtn = document.createElement("button");` && |\n| &&
             `        refreshBtn.type = "button";` && |\n| &&
             `        refreshBtn.textContent = "Refresh";` && |\n| &&
             `        refreshBtn.style.cssText = btnStyle;` && |\n| &&
             `        refreshBtn.addEventListener("click", () => window.location.reload());` && |\n| &&
             `        actionsDiv.appendChild(refreshBtn);` && |\n| &&
             `` && |\n| &&
             `        const logoutBtn = document.createElement("button");` && |\n| &&
             `        logoutBtn.type = "button";` && |\n| &&
             `        logoutBtn.textContent = "Logout";` && |\n| &&
             `        logoutBtn.style.cssText = btnStyle;` && |\n| &&
             `        logoutBtn.addEventListener("click", () => this._handleLogout());` && |\n| &&
             `        actionsDiv.appendChild(logoutBtn);` && |\n| &&
             `` && |\n| &&
             `        headerDiv.appendChild(actionsDiv);` && |\n| &&
             `        errorContainer.appendChild(headerDiv);` && |\n| &&
             `` && |\n| &&
             `        // The error text itself lives inside a sandboxed iframe so any HTML` && |\n| &&
             `        // in the backend response cannot execute or affect the main page.` && |\n| &&
             `        const iframe = document.createElement("iframe");` && |\n| &&
             `        iframe.id = "errorIframe";` && |\n| &&
             `        iframe.style.cssText =` && |\n| &&
             `          "width: 100%; height: 100%; border: none; flex: 1;";` && |\n| &&
             `        iframe.setAttribute("sandbox", "allow-same-origin");` && |\n| &&
             `        errorContainer.appendChild(iframe);` && |\n| &&
             `` && |\n| &&
             `        const contentDocument = iframe.contentDocument;` && |\n| &&
             `        if (contentDocument) {` && |\n| &&
             `          const pre = contentDocument.createElement("pre");` && |\n| &&
             `          pre.style.cssText =` && |\n| &&
             `            "margin:0;padding:8px;font-family:monospace;font-size:12px;white-space:pre-wrap;word-break:break-all;";` && |\n| &&
             `          pre.textContent = errorMessage;` && |\n| &&
             `          const target =` && |\n| &&
             `            contentDocument.body || contentDocument.documentElement;` && |\n| &&
             `          target.appendChild(pre);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Logout via the launchpad if available; otherwise hit the SAP logoff URL.` && |\n| &&
             `      _handleLogout() {` && |\n| &&
             `        const fallback = () => {` && |\n| &&
             `          window.location.href = "/sap/public/bc/icf/logoff";` && |\n| &&
             `        };` && |\n| &&
             `        try {` && |\n| &&
             `          const launchpadLogout =` && |\n| &&
             `            z2ui5.oLaunchpad &&` && |\n| &&
             `            z2ui5.oLaunchpad.Container &&` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout;` && |\n| &&
             `          if (launchpadLogout) {` && |\n| &&
             `            z2ui5.oLaunchpad.Container.logout();` && |\n| &&
             `          } else {` && |\n| &&
             `            fallback();` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          fallback();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `    };` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
