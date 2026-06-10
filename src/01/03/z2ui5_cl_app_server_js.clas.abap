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
             `    "z2ui5/cc/Util",` && |\n| &&
             `  ],` && |\n| &&
             `  (BusyIndicator, Device, Element, Util) => {` && |\n| &&
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
             `    // A usable stateful session id ("sap-contextid"). We must never put a` && |\n| &&
             `    // missing value on the wire: an empty or - via string coercion of a` && |\n| &&
             `    // JS ``undefined`` - the literal "undefined" makes the SAP Web Dispatcher /` && |\n| &&
             `    // ICM log "invalid w3c session id" / "HttpExtractSID: SID wrong len: 9"` && |\n| &&
             `    // on every roundtrip. Only forward a real, non-empty id.` && |\n| &&
             `    function isValidContextId(id) {` && |\n| &&
             `      return typeof id === "string" && id !== "" && id !== "undefined";` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    return {` && |\n| &&
             `      endSession() {` && |\n| &&
             `        if (!isValidContextId(z2ui5.contextId)) return;` && |\n| &&
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
             `          const views = [` && |\n| &&
             `            z2ui5.oView,` && |\n| &&
             `            z2ui5.oViewNest,` && |\n| &&
             `            z2ui5.oViewNest2,` && |\n| &&
             `            z2ui5.oViewPopup,` && |\n| &&
             `            z2ui5.oViewPopover,` && |\n| &&
             `          ];` && |\n| &&
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
             `      _getScrollInfo() {` && |\n| &&
             `        // For each visible view, find the scrollable descendant that is` && |\n| &&
             `        // actually scrolled (typically a sap.m.Page) and return its current` && |\n| &&
             `        // scroll offsets. X = scrollLeft, Y = scrollTop.` && |\n| &&
             `        //` && |\n| &&
             `        // Multiple controls in the tree expose getScrollDelegate (App,` && |\n| &&
             `        // NavContainer, Page, ScrollContainer, ...). findAggregatedObjects` && |\n| &&
             `        // returns them in pre-order, so the outer App/NavContainer comes` && |\n| &&
             `        // first - but its delegate never scrolls visible content. We pick` && |\n| &&
             `        // the first candidate whose container is actually scrolled, with` && |\n| &&
             `        // the deepest overflowing container as a fallback.` && |\n| &&
             `        //` && |\n| &&
             `        // Reading the position directly from the container's DOM avoids` && |\n| &&
             `        // relying on the delegate's cached _scrollY/_scrollX which can lag` && |\n| &&
             `        // until a scroll event fires.` && |\n| &&
             `        const containerOf = (control) => {` && |\n| &&
             `          try {` && |\n| &&
             `            const d = control.getScrollDelegate();` && |\n| &&
             `            if (d && d.getContainerDomRef) {` && |\n| &&
             `              const dom = d.getContainerDomRef();` && |\n| &&
             `              if (dom) return dom;` && |\n| &&
             `            }` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            // ignored` && |\n| &&
             `          }` && |\n| &&
             `          // Fallback to known ID suffixes for common controls.` && |\n| &&
             `          const id = control.getId();` && |\n| &&
             `          return (` && |\n| &&
             `            document.getElementById(``${id}-cont``) || // sap.m.Page` && |\n| &&
             `            document.getElementById(``${id}-scroll``) || // sap.m.ScrollContainer` && |\n| &&
             `            null` && |\n| &&
             `          );` && |\n| &&
             `        };` && |\n| &&
             `        const getOne = (view) => {` && |\n| &&
             `          if (!view || !view.findAggregatedObjects) return null;` && |\n| &&
             `          let candidates;` && |\n| &&
             `          try {` && |\n| &&
             `            candidates = view.findAggregatedObjects(true, (c) => {` && |\n| &&
             `              try {` && |\n| &&
             `                return c.getScrollDelegate && c.getScrollDelegate();` && |\n| &&
             `              } catch (e) {` && |\n| &&
             `                return false;` && |\n| &&
             `              }` && |\n| &&
             `            });` && |\n| &&
             `          } catch (e) {` && |\n| &&
             `            return null;` && |\n| &&
             `          }` && |\n| &&
             `          if (!candidates || !candidates.length) return null;` && |\n| &&
             `` && |\n| &&
             `          let chosen = null;` && |\n| &&
             `          let fallback = null;` && |\n| &&
             `          for (const c of candidates) {` && |\n| &&
             `            const dom = containerOf(c);` && |\n| &&
             `            if (!dom) continue;` && |\n| &&
             `            const x = dom.scrollLeft || 0;` && |\n| &&
             `            const y = dom.scrollTop || 0;` && |\n| &&
             `            if (x || y) {` && |\n| &&
             `              chosen = { control: c, x, y };` && |\n| &&
             `              break;` && |\n| &&
             `            }` && |\n| &&
             `            // Prefer the deepest container that actually overflows.` && |\n| &&
             `            const overflows =` && |\n| &&
             `              dom.scrollHeight > dom.clientHeight ||` && |\n| &&
             `              dom.scrollWidth > dom.clientWidth;` && |\n| &&
             `            if (overflows || !fallback) {` && |\n| &&
             `              fallback = { control: c, x, y };` && |\n| &&
             `            }` && |\n| &&
             `          }` && |\n| &&
             `          const pick = chosen || fallback;` && |\n| &&
             `          if (!pick) return null;` && |\n| &&
             `          let id = pick.control.getId();` && |\n| &&
             `          const prefix = view.getId() + "--";` && |\n| &&
             `          if (id.startsWith(prefix)) id = id.slice(prefix.length);` && |\n| &&
             `          return { ID: id, X: pick.x, Y: pick.y };` && |\n| &&
             `        };` && |\n| &&
             `        const out = {};` && |\n| &&
             `        const slots = [` && |\n| &&
             `          ["MAIN", z2ui5.oView],` && |\n| &&
             `          ["NEST", z2ui5.oViewNest],` && |\n| &&
             `          ["NEST2", z2ui5.oViewNest2],` && |\n| &&
             `          ["POPUP", z2ui5.oViewPopup],` && |\n| &&
             `          ["POPOVER", z2ui5.oViewPopover],` && |\n| &&
             `        ];` && |\n| &&
             `        for (const [key, view] of slots) {` && |\n| &&
             `          const v = getOne(view);` && |\n| &&
             `          if (v) out[key] = v;` && |\n| &&
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
             `          if (isValidContextId(z2ui5.contextId)) {` && |\n| &&
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
             `        if (isValidContextId(contextId)) {` && |\n| &&
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
             `          const updateTargets = [` && |\n| &&
             `            ["S_VIEW", z2ui5.oView],` && |\n| &&
             `            ["S_VIEW_NEST", z2ui5.oViewNest],` && |\n| &&
             `            ["S_VIEW_NEST2", z2ui5.oViewNest2],` && |\n| &&
             `            ["S_POPUP", z2ui5.oViewPopup],` && |\n| &&
             `            ["S_POPOVER", z2ui5.oViewPopover],` && |\n| &&
             `          ];` && |\n| &&
             `          for (const [key, view] of updateTargets) {` && |\n| &&
             `            oController.updateModelIfRequired(key, view);` && |\n| &&
             `          }` && |\n| &&
             `          oController._processAfterRendering();` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          BusyIndicator.hide();` && |\n| &&
             `          z2ui5.isBusy = false;` && |\n| &&
             `          Util.logError("responseSuccess: unexpected error", e);` && |\n| &&
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
             |\n|.
    result = result &&
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
             `          Util.logError("customJs: execution failed", e);` && |\n| &&
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
