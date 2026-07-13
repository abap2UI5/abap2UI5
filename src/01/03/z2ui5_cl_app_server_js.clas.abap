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
             `    "sap/ui/VersionInfo",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `    "z2ui5/core/ViewSlots",` && |\n| &&
             `    "z2ui5/core/ErrorView",` && |\n| &&
             `    "z2ui5/core/Messages",` && |\n| &&
             `    "z2ui5/core/AppState",` && |\n| &&
             `  ],` && |\n| &&
             `  (` && |\n| &&
             `    BusyIndicator,` && |\n| &&
             `    Device,` && |\n| &&
             `    Element,` && |\n| &&
             `    VersionInfo,` && |\n| &&
             `    Lib,` && |\n| &&
             `    ViewSlots,` && |\n| &&
             `    ErrorView,` && |\n| &&
             `    Messages,` && |\n| &&
             `    AppState,` && |\n| &&
             `  ) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
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
             `    //   1. View1.eB(...)              builds the request body with the model` && |\n| &&
             `    //                                 delta and hands it to roundtrip(oBody)` && |\n| &&
             `    //   2. Server.roundtrip(oBody)    adds S_FRONT (device/focus/scroll info)` && |\n| &&
             `    //   3. Server.readHttp(oBody)     POSTs { value: oBody }, parses the JSON` && |\n| &&
             `    //   4. Server.responseSuccess()   shows messages, rebuilds/updates views` && |\n| &&
             `    //   5. View1._processAfterRendering()  popups, nested views, history,` && |\n| &&
             `    //      then runs pending follow-up JS once rendering is done` && |\n| &&
             `    // The request body travels through the steps as a parameter; it is` && |\n| &&
             `    // mirrored to z2ui5.oBody so onBeforeRoundtrip hooks and the debug tool` && |\n| &&
             `    // can inspect it. Only the response side still crosses an async boundary` && |\n| &&
             `    // (the rendering) via the globals oResponse and pendingCustomJs.` && |\n| &&
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
             `      _getDeviceInfo() {` && |\n| &&
             `        // SYSTEM / BROWSER / OS / SUPPORT are fixed for the lifetime of the` && |\n| &&
             `        // session, so resolve them once and reuse the cached block; only` && |\n| &&
             `        // ORIENTATION and RESIZE are read fresh on every roundtrip.` && |\n| &&
             `        if (!this._deviceStatic) {` && |\n| &&
             `          this._deviceStatic = {` && |\n| &&
             `            SYSTEM: Lib.deriveSystemType(Device.system),` && |\n| &&
             `            BROWSER: {` && |\n| &&
             `              NAME: Device.browser.name || "",` && |\n| &&
             `              VERSION: String(Device.browser.version || ""),` && |\n| &&
             `            },` && |\n| &&
             `            OS: {` && |\n| &&
             `              NAME: Device.os.name || "",` && |\n| &&
             `              VERSION: String(Device.os.version || ""),` && |\n| &&
             `            },` && |\n| &&
             `            SUPPORT: {` && |\n| &&
             `              TOUCH: Device.support.touch || false,` && |\n| &&
             `              POINTER: Device.support.pointer || false,` && |\n| &&
             `              RETINA: Device.support.retina || false,` && |\n| &&
             `            },` && |\n| &&
             `          };` && |\n| &&
             `        }` && |\n| &&
             `        return {` && |\n| &&
             `          ...this._deviceStatic,` && |\n| &&
             `          ORIENTATION: Device.orientation.portrait ? "portrait" : "landscape",` && |\n| &&
             `          RESIZE: {` && |\n| &&
             `            WIDTH: Device.resize.width || window.innerWidth,` && |\n| &&
             `            HEIGHT: Device.resize.height || window.innerHeight,` && |\n| &&
             `          },` && |\n| &&
             `        };` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Resolve the UI5 element owning a DOM node. Element.closestTo exists` && |\n| &&
             `      // as of UI5 1.106; on older bootstraps walk up the DOM to the nearest` && |\n| &&
             `      // rendered control root (marked with the data-sap-ui attribute) and` && |\n| &&
             `      // resolve it via the core registry, so scroll and focus capture also` && |\n| &&
             `      // work there.` && |\n| &&
             `      _closestUi5Element(dom) {` && |\n| &&
             `        if (Element.closestTo) return Element.closestTo(dom) ?? null;` && |\n| &&
             `        let el = dom;` && |\n| &&
             `        while (el && el.getAttribute) {` && |\n| &&
             `          if (el.hasAttribute("data-sap-ui")) {` && |\n| &&
             `            // ui5lint-disable-next-line no-globals, no-deprecated-api -- only resolution path on UI5 < 1.106` && |\n| &&
             `            return sap.ui.getCore().byId(el.id) || null;` && |\n| &&
             `          }` && |\n| &&
             `          el = el.parentElement;` && |\n| &&
             `        }` && |\n| &&
             `        return null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Strip the owning view's "<viewId>--" prefix from a control id so the` && |\n| &&
             `      // backend gets the id as the app declared it. Returns the id unchanged` && |\n| &&
             `      // when it does not belong to that view.` && |\n| &&
             `      _stripViewPrefix(fullId, view) {` && |\n| &&
             `        if (!view) return fullId;` && |\n| &&
             `        const prefix = ``${view.getId()}--``;` && |\n| &&
             `        return fullId.startsWith(prefix) ? fullId.slice(prefix.length) : fullId;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // Returning undefined when no UI5 control owns the focus lets` && |\n| &&
             `      // JSON.stringify omit S_FOCUS from the request entirely, matching` && |\n| &&
             `      // _getScrollInfo (the backend treats a missing key like an empty one).` && |\n| &&
             `      _getFocusInfo() {` && |\n| &&
             `        try {` && |\n| &&
             `          const active = document.activeElement;` && |\n| &&
             `          if (!active) return undefined;` && |\n| &&
             `          const ui5El = this._closestUi5Element(active);` && |\n| &&
             `          if (!ui5El) return undefined;` && |\n| &&
             `          const fullId = ui5El.getId();` && |\n| &&
             `          let id = fullId;` && |\n| &&
             `          for (const slot of ViewSlots.slots) {` && |\n| &&
             `            const local = this._stripViewPrefix(` && |\n| &&
             `              fullId,` && |\n| &&
             `              ViewSlots.getView(slot.key),` && |\n| &&
             `            );` && |\n| &&
             `            if (local !== fullId) {` && |\n| &&
             `              id = local;` && |\n| &&
             `              break;` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `          return {` && |\n| &&
             `            ID: id,` && |\n| &&
             `            SELECTION_START: active.selectionStart || 0,` && |\n| &&
             `            SELECTION_END: active.selectionEnd || 0,` && |\n| &&
             `          };` && |\n| &&
             `        } catch {` && |\n| &&
             `          return undefined;` && |\n| &&
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
             `` && |\n| &&
             `        // Scroll events fire up to once per frame per element while the user` && |\n| &&
             `        // drags, but the same DOM element keeps firing throughout a gesture.` && |\n| &&
             `        // Resolving the UI5 control (_closestUi5Element) and walking it up to` && |\n| &&
             `        // its view slot (ViewSlots.containingSlotKey) is the expensive part,` && |\n| &&
             `        // so cache that resolution keyed by the element: it runs once per` && |\n| &&
             `        // scrolled element instead of once per event. Only the cheap` && |\n| &&
             `        // scroll-position record stays per event.` && |\n| &&
             `        if (target !== this._lastScrollTarget) {` && |\n| &&
             `          const ui5El = this._closestUi5Element(target);` && |\n| &&
             `          this._lastScrollTarget = target;` && |\n| &&
             `          this._lastScrollUi5El = ui5El;` && |\n| &&
             `          this._lastScrollSlotKey = ui5El` && |\n| &&
             `            ? ViewSlots.containingSlotKey(ui5El)` && |\n| &&
             `            : undefined;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (this._lastScrollSlotKey) {` && |\n| &&
             `          AppState.state.lastScrolled[this._lastScrollSlotKey] = {` && |\n| &&
             `            control: this._lastScrollUi5El,` && |\n| &&
             `            dom: target,` && |\n| &&
             `          };` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _getScrollInfo() {` && |\n| &&
             `        // Release the per-element resolution cache of onScrollCapture once` && |\n| &&
             `        // its DOM node left the document (view replaced/destroyed) - the` && |\n| &&
             `        // detached element and its control would otherwise stay referenced` && |\n| &&
             `        // until the user scrolls the next time.` && |\n| &&
             `        if (this._lastScrollTarget && !this._lastScrollTarget.isConnected) {` && |\n| &&
             `          this._lastScrollTarget = undefined;` && |\n| &&
             `          this._lastScrollUi5El = undefined;` && |\n| &&
             `          this._lastScrollSlotKey = undefined;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        // Reads scrollLeft/scrollTop straight from the DOM element the user` && |\n| &&
             `        // last scrolled in each view slot (recorded by onScrollCapture).` && |\n| &&
             `        // X = scrollLeft, Y = scrollTop. Slots the user never scrolled are` && |\n| &&
             `        // absent from the result - restoring 0/0 would be a no-op anyway.` && |\n| &&
             `        const store = AppState.state.lastScrolled;` && |\n| &&
             `        const out = {};` && |\n| &&
             `        for (const slot of ViewSlots.slots) {` && |\n| &&
             `          const entry = store[slot.key];` && |\n| &&
             `          if (!entry) continue;` && |\n| &&
             `` && |\n| &&
             `          // Drop stale references, e.g. after the view was replaced. Also` && |\n| &&
             `          // drop a destroyed control whose DOM is still transiently` && |\n| &&
             `          // connected: entry.control.getId() below would throw and abort the` && |\n| &&
             `          // whole roundtrip (this method, unlike _getFocusInfo, has no outer` && |\n| &&
             `          // try/catch).` && |\n| &&
             `          if (!entry.dom.isConnected || !Lib.isAlive(entry.control)) {` && |\n| &&
             `            delete store[slot.key];` && |\n| &&
             `            continue;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          const id = this._stripViewPrefix(` && |\n| &&
             `            entry.control.getId(),` && |\n| &&
             `            ViewSlots.getView(slot.key),` && |\n| &&
             `          );` && |\n| &&
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
             `      roundtrip(oBody = {}) {` && |\n| &&
             `        const state = AppState.state;` && |\n| &&
             `        state.checkNestAfter = false;` && |\n| &&
             `        state.checkNestAfter2 = false;` && |\n| &&
             `` && |\n| &&
             `        // Keep the shared record in sync (debug tool "Previous Request",` && |\n| &&
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
             `            S_UI5: oConfig?.S_UI5,` && |\n| &&
             `            S_DEVICE: this._getDeviceInfo(),` && |\n| &&
             `            S_FOCUS: this._getFocusInfo(),` && |\n| &&
             `            S_SCROLL: this._getScrollInfo(),` && |\n| &&
             `            ComponentData: oConfig?.ComponentData,` && |\n| &&
             `          },` && |\n| &&
             `          ID: oBody.ID,` && |\n| &&
             `          ORIGIN: window.location.origin,` && |\n| &&
             `          PATHNAME: window.location.pathname,` && |\n| &&
             `          SEARCH: state.search || window.location.search,` && |\n| &&
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
             `        if (!sFront.T_EVENT_ARG?.length) delete sFront.T_EVENT_ARG;` && |\n| &&
             `        if (sFront.SEARCH === "") delete sFront.SEARCH;` && |\n| &&
             `        if (!oBody.XX) delete oBody.XX;` && |\n| &&
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
             `      async readHttp(oBody) {` && |\n| &&
             `        const timeoutMs =` && |\n| &&
             `          AppState.getGlobal("requestTimeoutMs") || REQUEST_TIMEOUT_MS;` && |\n| &&
             `        // The signal guards the fetch and the response body reads below; the` && |\n| &&
             `        // finally releases the fallback timer once the roundtrip settled.` && |\n| &&
             `        const { signal, cancel } = this.createTimeoutSignal(timeoutMs);` && |\n| &&
             `        // A network blip or timeout may mean the request never reached the` && |\n| &&
             `        // server, so the error overlay offers a retry that re-sends the` && |\n| &&
             `        // exact same request body instead of forcing a full app restart.` && |\n| &&
             `        const oRetry = { onRetry: () => this.readHttp(oBody) };` && |\n| &&
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
             `            // An empty error body would render an empty overlay - fall back` && |\n|.
    result = result &&
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
             `            this.responseError(``Invalid JSON response: ${e.message}``);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          if (!responseData || !responseData.S_FRONT) {` && |\n| &&
             `            this.responseError("Invalid response: missing S_FRONT");` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Step 4: hand the parsed response to the success handler.` && |\n| &&
             `          AppState.state.responseData = responseData;` && |\n| &&
             `          AppState.state.xxChangedPaths = new Set();` && |\n| &&
             `          this.responseSuccess({` && |\n| &&
             `            ID: responseData.S_FRONT.ID,` && |\n| &&
             `            PARAMS: responseData.S_FRONT.PARAMS,` && |\n| &&
             `            OVIEWMODEL: responseData.MODEL,` && |\n| &&
             `          });` && |\n| &&
             `        } finally {` && |\n| &&
             `          cancel();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      async responseSuccess(response) {` && |\n| &&
             `        const oController = ViewSlots.getController("MAIN");` && |\n| &&
             `        try {` && |\n| &&
             `          AppState.state.oResponse = response;` && |\n| &&
             `          const params = response.PARAMS;` && |\n| &&
             `          const sView = params?.S_VIEW;` && |\n| &&
             `` && |\n| &&
             `          if (sView?.CHECK_DESTROY) ViewSlots.destroy("MAIN");` && |\n| &&
             `` && |\n| &&
             `          // The backend can send small JS snippets to run after the response.` && |\n| &&
             `          // Each snippet is either a literal expression or an "eF(...)" call` && |\n| &&
             `          // whose arguments are wrapped in single quotes. They are stashed` && |\n| &&
             `          // here and executed at the end of _processAfterRendering, i.e. once` && |\n| &&
             `          // the (possibly freshly built) view is actually rendered. Running` && |\n| &&
             `          // them earlier would break render-dependent actions such as` && |\n| &&
             `          // SET_FOCUS on the initial view, where the target control does not` && |\n| &&
             `          // exist in the DOM yet.` && |\n| &&
             `          const followUp = params?.S_FOLLOW_UP_ACTION;` && |\n| &&
             `          AppState.state.pendingCustomJs = followUp?.CUSTOM_JS || null;` && |\n| &&
             `` && |\n| &&
             `          for (const t of _MSG_TYPES) Messages.show(t, params, oController);` && |\n| &&
             `` && |\n| &&
             `          // Full view replacement -> destroy & rebuild, nothing more to do.` && |\n| &&
             `          if (sView?.XML) {` && |\n| &&
             `            ViewSlots.destroy("MAIN");` && |\n| &&
             `            await oController.displayView(sView.XML, response.OVIEWMODEL);` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `` && |\n| &&
             `          // Partial response: refresh whichever existing views the backend` && |\n| &&
             `          // sent updates for.` && |\n| &&
             `          for (const slot of ViewSlots.slots) {` && |\n| &&
             `            oController.updateModelIfRequired(slot.key);` && |\n| &&
             `          }` && |\n| &&
             `          oController._processAfterRendering();` && |\n| &&
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
             `          Lib.logError("_checkSDKcompatibility: VersionInfo.load failed", e);` && |\n| &&
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
             `          } else {` && |\n| &&
             `            // eslint-disable-next-line no-new-func` && |\n| &&
             `            Function("return " + parts[0])();` && |\n| &&
             `          }` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("customJs: execution failed", e);` && |\n| &&
             `        }` && |\n| &&
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
