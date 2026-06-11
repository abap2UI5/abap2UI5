// The global `z2ui5` object holds the shared frontend state. It is declared
// by the backend-generated HTML (or created by Component.init when running
// standalone). Field inventory - writer in parentheses:
//
// Bootstrap / configuration
//   checkLocal        true when served by the backend GET page (backend HTML)
//   url               backend endpoint for roundtrips (App.controller)
//   oConfig           { S_UI5: version info, ComponentData } (Component)
//   oLaunchpad        FLP services when running inside the launchpad, else
//                     null (Component._initLaunchpad)
//   Util              PUBLIC date helpers for view formatters - apps rely on
//                     this global and on the z2ui5/Util module (Component)
//   requestTimeoutMs  optional override for the roundtrip timeout (apps)
//
// Views / controllers / UI5 objects
//   oApp              sap.m.App hosting the main view (App.controller)
//   oOwnerComponent, oRouter, oDeviceModel (Component / App.controller)
//   oView, oViewNest, oViewNest2, oViewPopup, oViewPopover
//                     the five view slots, see viewSlots below (View1)
//   oController, oControllerNest, oControllerNest2, oControllerPopup,
//   oControllerPopover  controller instance per slot (App.controller)
//
// Roundtrip state
//   oBody             request payload being assembled (View1.eB / Server)
//   oResponse         last processed response { ID, PARAMS, OVIEWMODEL }
//   responseData      raw parsed response JSON (Server.readHttp)
//   contextId         stateful session id, header transport (Server)
//   isBusy            roundtrip in flight (View1.eB / Server)
//   xxChangedPaths    Set of edited /XX/ model paths for the delta (View1)
//   checkNestAfter, checkNestAfter2  nested views rebuilt this roundtrip
//   search            overrides location.search in S_FRONT (History control)
//   pendingCustomJs   follow-up JS to run after rendering (Server)
//
// Control / helper state
//   errors            capped error log, see logError below
//   timers            single pending backend timer (View1._evStartTimer)
//   lastScrolled      last scrolled element per slot (Server.onScrollCapture)
//   viewSizeLimits    per-slot model size limits (View1._evSetSizeLimit)
//   treeState         tree binding state across rebuilds (Tree control)
//   debugTool         DebugTool instance (Component, Ctrl+F12)
//   onBeforeRoundtrip, onAfterRoundtrip, onAfterRendering,
//   onBeforeEventFrontend  callback arrays, see registerCallback below
//   <custom>          apps can register functions via the js_loader popup
//                     and call them through the Z2UI5 frontend event
//
// Shared rendering pattern of the custom controls (Timer.js, Focus.js,
// Scrolling.js, Tree.js, ...): the renderer only *marks* work by setting a
// `_pending*` flag on the control instance, and onAfterRendering() consumes
// the flag and performs the actual DOM work (focus, scrolling, timers, tree
// state). Renderers must stay cheap and free of visible side effects
// (rendering API v2); deferring to onAfterRendering also guarantees the
// control's DOM exists.
sap.ui.define([], () => {
  "use strict";

  // Cap the error log so a long-running session cannot grow it unbounded.
  const MAX_ERRORS = 100;

  // Append an entry to the global error log. We create the array on first
  // use and drop the oldest entry once the cap is reached.
  function logError(message, error) {
    if (!z2ui5.errors) z2ui5.errors = [];
    const entry = { message: message, ts: new Date().toISOString() };
    if (error !== undefined) entry.error = error;
    z2ui5.errors.push(entry);
    if (z2ui5.errors.length > MAX_ERRORS) z2ui5.errors.shift();
  }

  // True when the object supports isDestroyed() and reports destroyed.
  function isDestroyed(obj) {
    return !!(obj?.isDestroyed && obj.isDestroyed());
  }

  // True when the object exists and is not destroyed. Used to guard
  // async continuations (await, FileReader, getUserMedia, ...) against
  // controls or views that were torn down in the meantime.
  function isAlive(obj) {
    return !!obj && !isDestroyed(obj);
  }

  // Helpers for managing z2ui5 callback arrays (onBeforeRoundtrip,
  // onAfterRendering, ...). Several custom controls register hooks here in
  // init() and remove them in exit().
  function registerCallback(name, fn) {
    if (!z2ui5[name]) z2ui5[name] = [];
    z2ui5[name].push(fn);
  }

  function unregisterCallback(name, fn) {
    if (!z2ui5[name]) return;
    z2ui5[name] = z2ui5[name].filter((f) => f !== fn);
  }

  // Read a File object as a data URL and hand the result to onLoaded.
  // The callback is skipped when `owner` was destroyed while the
  // FileReader was busy; read errors are logged under `errorContext`.
  function readFileAsDataURL(file, owner, onLoaded, errorContext) {
    const reader = new FileReader();
    reader.onload = () => {
      if (isDestroyed(owner)) return;
      onLoaded(reader.result);
    };
    reader.onerror = () =>
      logError(`${errorContext}: FileReader failed`, reader.error);
    reader.readAsDataURL(file);
  }

  // Shared tokenUpdate handling for the multi-input extensions: map the
  // added/removed UI5 tokens to plain objects and store them in the
  // control's addedTokens/removedTokens properties.
  function applyTokenUpdate(control, oEvent) {
    const isRemoved = oEvent.getParameter("type") === "removed";
    const rawList =
      oEvent.getParameter(isRemoved ? "removedTokens" : "addedTokens") || [];
    const tokens = rawList.map((item) => ({
      KEY: item.getKey(),
      TEXT: item.getText(),
    }));
    control.setProperty("addedTokens", isRemoved ? [] : tokens);
    control.setProperty("removedTokens", isRemoved ? tokens : []);
  }

  // Run every callback in `callbacks` (the z2ui5 callback arrays above),
  // swallowing individual failures so one bad callback cannot break the
  // whole event sequence.
  function runCallbacks(callbacks, ...args) {
    if (!callbacks) return;
    for (const fn of callbacks) {
      if (!fn) continue;
      try {
        fn(...args);
      } catch (e) {
        logError("runCallbacks: callback failed", e);
      }
    }
  }

  // Runs `fn` once `control` has a DOM reference: immediately when it is
  // already rendered, otherwise once after its next rendering. The call
  // is skipped when `owner` was destroyed in the meantime.
  function whenRendered(control, owner, fn) {
    if (control.getDomRef()) {
      fn();
      return;
    }
    const delegate = {
      onAfterRendering: () => {
        control.removeEventDelegate(delegate);
        if (!isDestroyed(owner)) fn();
      },
    };
    control.addEventDelegate(delegate);
  }

  // Copy text to the clipboard, preferring the async clipboard API with a
  // fallback to the legacy textarea + execCommand approach.
  function copyToClipboard(textToCopy) {
    if (navigator.clipboard?.writeText) {
      navigator.clipboard.writeText(textToCopy).catch((err) => {
        logError("Clipboard: writeText failed, falling back", err);
        copyToClipboardFallback(textToCopy);
      });
      return;
    }
    copyToClipboardFallback(textToCopy);
  }

  function copyToClipboardFallback(textToCopy) {
    const textarea = document.createElement("textarea");
    textarea.value = textToCopy;
    textarea.setAttribute("readonly", "");
    textarea.style.position = "fixed";
    textarea.style.top = "-1000px";
    textarea.style.opacity = "0";
    document.body.appendChild(textarea);
    textarea.select();
    try {
      if (!document.execCommand("copy")) {
        logError("Clipboard: execCommand('copy') returned false");
      }
    } catch (err) {
      logError("Clipboard: execCommand('copy') threw", err);
    } finally {
      document.body.removeChild(textarea);
    }
  }

  // ------------------------------------------------------------------
  // Pure helpers - free of UI5 dependencies so the Node specs under
  // node/tests/ can load this module with a stubbed sap.ui.define and
  // test the real implementation instead of a copy.
  // ------------------------------------------------------------------

  const SAFE_PROTOCOLS = ["http:", "https:"];

  // Normalizes any value for display: null and undefined become the empty
  // string, everything else its string representation.
  function toText(val) {
    return val == null ? "" : String(val);
  }

  // Returns true only if the URL is on the same origin and uses http/https.
  function isValidRedirectURL(url) {
    if (!url) return false;
    try {
      const parsed = new URL(url, window.location.origin);
      if (parsed.origin !== window.location.origin) {
        logError(`Security: Blocked redirect to different origin: ${url}`);
        return false;
      }
      if (!SAFE_PROTOCOLS.includes(parsed.protocol)) {
        logError(
          `Security: Blocked redirect with invalid protocol: ${parsed.protocol}`,
        );
        return false;
      }
      return true;
    } catch (e) {
      logError(`Security: Invalid URL format: ${url}`, e);
      return false;
    }
  }

  // Returns true if the URL uses a safe (http/https) protocol. Unlike
  // isValidRedirectURL this allows cross-origin targets, so it fits
  // outbound redirects to external sites while still blocking dangerous
  // schemes such as javascript:, data: or vbscript:.
  function isSafeRedirectProtocol(url) {
    if (!url) return false;
    try {
      const parsed = new URL(url, window.location.origin);
      if (!SAFE_PROTOCOLS.includes(parsed.protocol)) {
        logError(
          `Security: Blocked redirect with invalid protocol: ${parsed.protocol}`,
        );
        return false;
      }
      return true;
    } catch (e) {
      logError(`Security: Invalid URL format: ${url}`, e);
      return false;
    }
  }

  // Returns true for URLs that are safe as download targets: data: and
  // blob: (generated content) plus http(s). Blocks javascript: and other
  // active schemes, consistent with the redirect validators above.
  function isSafeDownloadURL(url) {
    if (!url) return false;
    try {
      const parsed = new URL(url, window.location.origin);
      return (
        parsed.protocol === "data:" ||
        parsed.protocol === "blob:" ||
        SAFE_PROTOCOLS.includes(parsed.protocol)
      );
    } catch (e) {
      logError(`Security: Invalid URL format: ${url}`, e);
      return false;
    }
  }

  // A usable stateful session id ("sap-contextid"). We must never put a
  // missing value on the wire: an empty or - via string coercion of a
  // JS `undefined` - the literal "undefined" makes the SAP Web Dispatcher /
  // ICM log "invalid w3c session id" / "HttpExtractSID: SID wrong len: 9"
  // on every roundtrip. Only forward a real, non-empty id.
  function isValidContextId(id) {
    return typeof id === "string" && id !== "" && id !== "undefined";
  }

  // Build the delta object sent to the backend. `paths` is the set of
  // /XX/... paths that the user edited; `xx` is the full XX model data.
  function buildDeltaFromPaths(paths, xx) {
    const delta = {};
    for (const path of paths) {
      // path looks like "/XX/<attr>" or "/XX/<attr>/<row>/<field>"
      const parts = path.slice(4).split("/");
      const [attr, rowIdx, field] = parts;
      // Only a flat table cell (exactly attr/row/field) qualifies for a
      // delta. Deeper paths (e.g. tree tables: attr/row/<subtable>/<row>/<field>)
      // fall back to shipping the whole attribute, which the backend applies
      // via corresponding-based deserialization.
      const isRowField = parts.length === 3 && rowIdx !== "" && !isNaN(rowIdx);
      if (isRowField) {
        // Table cell change -> ship only the changed cell.
        if (!delta[attr] || !delta[attr].__delta) {
          delta[attr] = { __delta: {} };
        }
        const attrDelta = delta[attr].__delta;
        if (!attrDelta[rowIdx]) attrDelta[rowIdx] = {};
        const row = xx[attr] && xx[attr][+rowIdx];
        attrDelta[rowIdx][field] = row ? row[field] : undefined;
      } else {
        // Scalar change -> ship the whole attribute.
        delta[attr] = xx[attr];
      }
    }
    return delta;
  }

  // Turns an HTML "details" snippet from the backend into safe HTML.
  // Bullet lists are preserved; everything else is reduced to plain text.
  // The DOM helpers are created lazily so loading this module does not
  // require a DOM (the Node specs never call this function).
  let _msgParser = null;
  let _sanitizeEl = null;
  function sanitizeMessageDetails(html) {
    if (!_msgParser) {
      _msgParser = new DOMParser();
      _sanitizeEl = document.createElement("div");
    }
    const doc = _msgParser.parseFromString(html, "text/html");
    const items = Array.from(doc.querySelectorAll("li"));
    if (items.length > 0) {
      const safeItems = items.map((li) => {
        _sanitizeEl.textContent = li.textContent;
        return `<li>${_sanitizeEl.innerHTML}</li>`;
      });
      return `<ul>${safeItems.join("")}</ul>`;
    }
    _sanitizeEl.textContent = doc.body.textContent;
    return _sanitizeEl.innerHTML;
  }

  // The five view slots of the multi-view architecture. `param` is the
  // key used in the backend response PARAMS, `key` the short slot name
  // used in frontend events, `prop` the z2ui5 property holding the live
  // view instance.
  const viewSlots = [
    { key: "MAIN", param: "S_VIEW", prop: "oView" },
    { key: "NEST", param: "S_VIEW_NEST", prop: "oViewNest" },
    { key: "NEST2", param: "S_VIEW_NEST2", prop: "oViewNest2" },
    { key: "POPUP", param: "S_POPUP", prop: "oViewPopup" },
    { key: "POPOVER", param: "S_POPOVER", prop: "oViewPopover" },
  ];

  // Returns the live view instance for a slot key ("MAIN", "POPUP", ...).
  function getViewByKey(key) {
    const slot = viewSlots.find((s) => s.key === key);
    return slot ? z2ui5[slot.prop] : undefined;
  }

  // Returns the slot key for a response param key ("S_VIEW" -> "MAIN").
  function slotKeyByParam(param) {
    const slot = viewSlots.find((s) => s.param === param);
    return slot ? slot.key : undefined;
  }

  return {
    logError,
    isDestroyed,
    isAlive,
    registerCallback,
    unregisterCallback,
    readFileAsDataURL,
    applyTokenUpdate,
    runCallbacks,
    whenRendered,
    copyToClipboard,
    toText,
    isValidRedirectURL,
    isSafeRedirectProtocol,
    isSafeDownloadURL,
    isValidContextId,
    buildDeltaFromPaths,
    sanitizeMessageDetails,
    viewSlots,
    getViewByKey,
    slotKeyByParam,
  };
});
