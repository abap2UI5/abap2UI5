CLASS z2ui5_cl_app_lib_js DEFINITION
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


CLASS z2ui5_cl_app_lib_js IMPLEMENTATION.

  METHOD get.

    result = `// The global ``z2ui5`` object holds the shared frontend state. It is declared` && |\n| &&
             `// by the backend-generated HTML (or created by Component.init when running` && |\n| &&
             `// standalone). Field inventory - writer in parentheses:` && |\n| &&
             `//` && |\n| &&
             `// Bootstrap / configuration` && |\n| &&
             `//   checkLocal        true when served by the backend GET page (backend HTML)` && |\n| &&
             `//   url               backend endpoint for roundtrips (App.controller)` && |\n| &&
             `//   oConfig           { S_UI5: version info, ComponentData } (Component)` && |\n| &&
             `//   oLaunchpad        FLP services when running inside the launchpad, else` && |\n| &&
             `//                     null (Component._initLaunchpad)` && |\n| &&
             `//   Util              PUBLIC date helpers for view formatters - apps rely on` && |\n| &&
             `//                     this global and on the z2ui5/Util module (Component)` && |\n| &&
             `//   requestTimeoutMs  optional override for the roundtrip timeout (apps)` && |\n| &&
             `//` && |\n| &&
             `// Views / controllers / UI5 objects` && |\n| &&
             `//   oApp              sap.m.App hosting the main view (App.controller)` && |\n| &&
             `//   oOwnerComponent, oRouter, oDeviceModel (Component / App.controller)` && |\n| &&
             `//   oView, oViewNest, oViewNest2, oViewPopup, oViewPopover` && |\n| &&
             `//                     the five view slots, see viewSlots below (View1)` && |\n| &&
             `//   oController, oControllerNest, oControllerNest2, oControllerPopup,` && |\n| &&
             `//   oControllerPopover  controller instance per slot (App.controller)` && |\n| &&
             `//` && |\n| &&
             `// Roundtrip state` && |\n| &&
             `//   oBody             request payload being assembled (View1.eB / Server)` && |\n| &&
             `//   oResponse         last processed response { ID, PARAMS, OVIEWMODEL }` && |\n| &&
             `//   responseData      raw parsed response JSON (Server.readHttp)` && |\n| &&
             `//   contextId         stateful session id, header transport (Server)` && |\n| &&
             `//   isBusy            roundtrip in flight (View1.eB / Server)` && |\n| &&
             `//   xxChangedPaths    Set of edited /XX/ model paths for the delta (View1)` && |\n| &&
             `//   checkNestAfter, checkNestAfter2  nested views rebuilt this roundtrip` && |\n| &&
             `//   search            overrides location.search in S_FRONT (History control)` && |\n| &&
             `//   pendingCustomJs   follow-up JS to run after rendering (Server)` && |\n| &&
             `//` && |\n| &&
             `// Control / helper state` && |\n| &&
             `//   errors            capped error log, see logError below` && |\n| &&
             `//   timers            single pending backend timer (FrontendAction)` && |\n| &&
             `//   lastScrolled      last scrolled element per slot (Server.onScrollCapture)` && |\n| &&
             `//   viewSizeLimits    per-slot model size limits (FrontendAction)` && |\n| &&
             `//   treeState         tree binding state across rebuilds (Tree control)` && |\n| &&
             `//   debugTool         DebugTool instance (Component, Ctrl+F12)` && |\n| &&
             `//   onBeforeRoundtrip, onAfterRoundtrip, onAfterRendering,` && |\n| &&
             `//   onBeforeEventFrontend  callback arrays, see registerCallback below` && |\n| &&
             `//   <custom>          apps can register functions via the js_loader popup` && |\n| &&
             `//                     and call them through the Z2UI5 frontend event` && |\n| &&
             `//` && |\n| &&
             `// Shared rendering pattern of the custom controls (Timer.js, Focus.js,` && |\n| &&
             `// Scrolling.js, Tree.js, ...): the renderer only *marks* work by setting a` && |\n| &&
             `// ``_pending*`` flag on the control instance, and onAfterRendering() consumes` && |\n| &&
             `// the flag and performs the actual DOM work (focus, scrolling, timers, tree` && |\n| &&
             `// state). Renderers must stay cheap and free of visible side effects` && |\n| &&
             `// (rendering API v2); deferring to onAfterRendering also guarantees the` && |\n| &&
             `// control's DOM exists.` && |\n| &&
             `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Cap the error log so a long-running session cannot grow it unbounded.` && |\n| &&
             `  const MAX_ERRORS = 100;` && |\n| &&
             `` && |\n| &&
             `  // Append an entry to the global error log. We create the array on first` && |\n| &&
             `  // use and drop the oldest entry once the cap is reached.` && |\n| &&
             `  function logError(message, error) {` && |\n| &&
             `    if (!z2ui5.errors) z2ui5.errors = [];` && |\n| &&
             `    const entry = { message: message, ts: new Date().toISOString() };` && |\n| &&
             `    if (error !== undefined) entry.error = error;` && |\n| &&
             `    z2ui5.errors.push(entry);` && |\n| &&
             `    if (z2ui5.errors.length > MAX_ERRORS) z2ui5.errors.shift();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the object supports isDestroyed() and reports destroyed.` && |\n| &&
             `  function isDestroyed(obj) {` && |\n| &&
             `    return !!(obj?.isDestroyed && obj.isDestroyed());` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the object exists and is not destroyed. Used to guard` && |\n| &&
             `  // async continuations (await, FileReader, getUserMedia, ...) against` && |\n| &&
             `  // controls or views that were torn down in the meantime.` && |\n| &&
             `  function isAlive(obj) {` && |\n| &&
             `    return !!obj && !isDestroyed(obj);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Helpers for managing z2ui5 callback arrays (onBeforeRoundtrip,` && |\n| &&
             `  // onAfterRendering, ...). Several custom controls register hooks here in` && |\n| &&
             `  // init() and remove them in exit().` && |\n| &&
             `  function registerCallback(name, fn) {` && |\n| &&
             `    if (!z2ui5[name]) z2ui5[name] = [];` && |\n| &&
             `    z2ui5[name].push(fn);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function unregisterCallback(name, fn) {` && |\n| &&
             `    if (!z2ui5[name]) return;` && |\n| &&
             `    z2ui5[name] = z2ui5[name].filter((f) => f !== fn);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Read a File object as a data URL and hand the result to onLoaded.` && |\n| &&
             `  // The callback is skipped when ``owner`` was destroyed while the` && |\n| &&
             `  // FileReader was busy; read errors are logged under ``errorContext``.` && |\n| &&
             `  function readFileAsDataURL(file, owner, onLoaded, errorContext) {` && |\n| &&
             `    const reader = new FileReader();` && |\n| &&
             `    reader.onload = () => {` && |\n| &&
             `      if (isDestroyed(owner)) return;` && |\n| &&
             `      onLoaded(reader.result);` && |\n| &&
             `    };` && |\n| &&
             `    reader.onerror = () =>` && |\n| &&
             `      logError(``${errorContext}: FileReader failed``, reader.error);` && |\n| &&
             `    reader.readAsDataURL(file);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Shared tokenUpdate handling for the multi-input extensions: map the` && |\n| &&
             `  // added/removed UI5 tokens to plain objects and store them in the` && |\n| &&
             `  // control's addedTokens/removedTokens properties.` && |\n| &&
             `  function applyTokenUpdate(control, oEvent) {` && |\n| &&
             `    const isRemoved = oEvent.getParameter("type") === "removed";` && |\n| &&
             `    const rawList =` && |\n| &&
             `      oEvent.getParameter(isRemoved ? "removedTokens" : "addedTokens") || [];` && |\n| &&
             `    const tokens = rawList.map((item) => ({` && |\n| &&
             `      KEY: item.getKey(),` && |\n| &&
             `      TEXT: item.getText(),` && |\n| &&
             `    }));` && |\n| &&
             `    control.setProperty("addedTokens", isRemoved ? [] : tokens);` && |\n| &&
             `    control.setProperty("removedTokens", isRemoved ? tokens : []);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Run every callback in ``callbacks`` (the z2ui5 callback arrays above),` && |\n| &&
             `  // swallowing individual failures so one bad callback cannot break the` && |\n| &&
             `  // whole event sequence.` && |\n| &&
             `  function runCallbacks(callbacks, ...args) {` && |\n| &&
             `    if (!callbacks) return;` && |\n| &&
             `    for (const fn of callbacks) {` && |\n| &&
             `      if (!fn) continue;` && |\n| &&
             `      try {` && |\n| &&
             `        fn(...args);` && |\n| &&
             `      } catch (e) {` && |\n| &&
             `        logError("runCallbacks: callback failed", e);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Runs ``fn`` once ``control`` has a DOM reference: immediately when it is` && |\n| &&
             `  // already rendered, otherwise once after its next rendering. The call` && |\n| &&
             `  // is skipped when ``owner`` was destroyed in the meantime.` && |\n| &&
             `  function whenRendered(control, owner, fn) {` && |\n| &&
             `    if (control.getDomRef()) {` && |\n| &&
             `      fn();` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    const delegate = {` && |\n| &&
             `      onAfterRendering: () => {` && |\n| &&
             `        control.removeEventDelegate(delegate);` && |\n| &&
             `        if (!isDestroyed(owner)) fn();` && |\n| &&
             `      },` && |\n| &&
             `    };` && |\n| &&
             `    control.addEventDelegate(delegate);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Copy text to the clipboard, preferring the async clipboard API with a` && |\n| &&
             `  // fallback to the legacy textarea + execCommand approach.` && |\n| &&
             `  function copyToClipboard(textToCopy) {` && |\n| &&
             `    if (navigator.clipboard?.writeText) {` && |\n| &&
             `      navigator.clipboard.writeText(textToCopy).catch((err) => {` && |\n| &&
             `        logError("Clipboard: writeText failed, falling back", err);` && |\n| &&
             `        copyToClipboardFallback(textToCopy);` && |\n| &&
             `      });` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    copyToClipboardFallback(textToCopy);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function copyToClipboardFallback(textToCopy) {` && |\n| &&
             `    const textarea = document.createElement("textarea");` && |\n| &&
             `    textarea.value = textToCopy;` && |\n| &&
             `    textarea.setAttribute("readonly", "");` && |\n| &&
             `    textarea.style.position = "fixed";` && |\n| &&
             `    textarea.style.top = "-1000px";` && |\n| &&
             `    textarea.style.opacity = "0";` && |\n| &&
             `    document.body.appendChild(textarea);` && |\n| &&
             `    textarea.select();` && |\n| &&
             `    try {` && |\n| &&
             `      if (!document.execCommand("copy")) {` && |\n| &&
             `        logError("Clipboard: execCommand('copy') returned false");` && |\n| &&
             `      }` && |\n| &&
             `    } catch (err) {` && |\n| &&
             `      logError("Clipboard: execCommand('copy') threw", err);` && |\n| &&
             `    } finally {` && |\n| &&
             `      document.body.removeChild(textarea);` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // Pure helpers - free of UI5 dependencies so the Node specs under` && |\n| &&
             `  // node/tests/ can load this module with a stubbed sap.ui.define and` && |\n| &&
             `  // test the real implementation instead of a copy.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  const SAFE_PROTOCOLS = ["http:", "https:"];` && |\n| &&
             `` && |\n| &&
             `  // Normalizes any value for display: null and undefined become the empty` && |\n| &&
             `  // string, everything else its string representation.` && |\n| &&
             `  function toText(val) {` && |\n| &&
             `    return val == null ? "" : String(val);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns true only if the URL is on the same origin and uses http/https.` && |\n| &&
             `  function isValidRedirectURL(url) {` && |\n| &&
             `    if (!url) return false;` && |\n| &&
             `    try {` && |\n| &&
             `      const parsed = new URL(url, window.location.origin);` && |\n| &&
             `      if (parsed.origin !== window.location.origin) {` && |\n| &&
             `        logError(``Security: Blocked redirect to different origin: ${url}``);` && |\n| &&
             `        return false;` && |\n| &&
             `      }` && |\n| &&
             `      if (!SAFE_PROTOCOLS.includes(parsed.protocol)) {` && |\n| &&
             `        logError(` && |\n| &&
             `          ``Security: Blocked redirect with invalid protocol: ${parsed.protocol}``,` && |\n| &&
             `        );` && |\n| &&
             `        return false;` && |\n| &&
             `      }` && |\n| &&
             `      return true;` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns true if the URL uses a safe (http/https) protocol. Unlike` && |\n| &&
             `  // isValidRedirectURL this allows cross-origin targets, so it fits` && |\n| &&
             `  // outbound redirects to external sites while still blocking dangerous` && |\n| &&
             `  // schemes such as javascript:, data: or vbscript:.` && |\n| &&
             `  function isSafeRedirectProtocol(url) {` && |\n| &&
             `    if (!url) return false;` && |\n| &&
             `    try {` && |\n| &&
             `      const parsed = new URL(url, window.location.origin);` && |\n| &&
             `      if (!SAFE_PROTOCOLS.includes(parsed.protocol)) {` && |\n| &&
             `        logError(` && |\n| &&
             `          ``Security: Blocked redirect with invalid protocol: ${parsed.protocol}``,` && |\n| &&
             `        );` && |\n| &&
             `        return false;` && |\n| &&
             `      }` && |\n| &&
             `      return true;` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns true for URLs that are safe as download targets: data: and` && |\n| &&
             `  // blob: (generated content) plus http(s). Blocks javascript: and other` && |\n| &&
             `  // active schemes, consistent with the redirect validators above.` && |\n| &&
             `  function isSafeDownloadURL(url) {` && |\n| &&
             `    if (!url) return false;` && |\n| &&
             `    try {` && |\n| &&
             `      const parsed = new URL(url, window.location.origin);` && |\n| &&
             `      return (` && |\n| &&
             `        parsed.protocol === "data:" ||` && |\n| &&
             `        parsed.protocol === "blob:" ||` && |\n| &&
             `        SAFE_PROTOCOLS.includes(parsed.protocol)` && |\n| &&
             `      );` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // A usable stateful session id ("sap-contextid"). We must never put a` && |\n| &&
             `  // missing value on the wire: an empty or - via string coercion of a` && |\n| &&
             `  // JS ``undefined`` - the literal "undefined" makes the SAP Web Dispatcher /` && |\n| &&
             `  // ICM log "invalid w3c session id" / "HttpExtractSID: SID wrong len: 9"` && |\n| &&
             `  // on every roundtrip. Only forward a real, non-empty id.` && |\n| &&
             `  function isValidContextId(id) {` && |\n| &&
             `    return typeof id === "string" && id !== "" && id !== "undefined";` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Build the delta object sent to the backend. ``paths`` is the set of` && |\n| &&
             `  // /XX/... paths that the user edited; ``xx`` is the full XX model data.` && |\n| &&
             `  function buildDeltaFromPaths(paths, xx) {` && |\n| &&
             `    const delta = {};` && |\n| &&
             `    for (const path of paths) {` && |\n| &&
             `      // path looks like "/XX/<attr>" or "/XX/<attr>/<row>/<field>"` && |\n| &&
             `      const parts = path.slice(4).split("/");` && |\n| &&
             `      const [attr, rowIdx, field] = parts;` && |\n| &&
             `      // Only a flat table cell (exactly attr/row/field) qualifies for a` && |\n| &&
             `      // delta. Deeper paths (e.g. tree tables: attr/row/<subtable>/<row>/<field>)` && |\n| &&
             `      // fall back to shipping the whole attribute, which the backend applies` && |\n| &&
             `      // via corresponding-based deserialization.` && |\n| &&
             `      const isRowField = parts.length === 3 && rowIdx !== "" && !isNaN(rowIdx);` && |\n| &&
             `      if (isRowField) {` && |\n| &&
             `        // Table cell change -> ship only the changed cell.` && |\n| &&
             `        if (!delta[attr] || !delta[attr].__delta) {` && |\n| &&
             `          delta[attr] = { __delta: {} };` && |\n| &&
             `        }` && |\n| &&
             `        const attrDelta = delta[attr].__delta;` && |\n| &&
             `        if (!attrDelta[rowIdx]) attrDelta[rowIdx] = {};` && |\n| &&
             `        const row = xx[attr] && xx[attr][+rowIdx];` && |\n| &&
             `        attrDelta[rowIdx][field] = row ? row[field] : undefined;` && |\n| &&
             `      } else {` && |\n| &&
             `        // Scalar change -> ship the whole attribute.` && |\n| &&
             `        delta[attr] = xx[attr];` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `    return delta;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Turns an HTML "details" snippet from the backend into safe HTML.` && |\n| &&
             `  // Bullet lists are preserved; everything else is reduced to plain text.` && |\n| &&
             `  // The DOM helpers are created lazily so loading this module does not` && |\n| &&
             `  // require a DOM (the Node specs never call this function).` && |\n| &&
             `  let _msgParser = null;` && |\n| &&
             `  let _sanitizeEl = null;` && |\n| &&
             `  function sanitizeMessageDetails(html) {` && |\n| &&
             `    if (!_msgParser) {` && |\n| &&
             `      _msgParser = new DOMParser();` && |\n| &&
             `      _sanitizeEl = document.createElement("div");` && |\n| &&
             `    }` && |\n| &&
             `    const doc = _msgParser.parseFromString(html, "text/html");` && |\n| &&
             `    const items = Array.from(doc.querySelectorAll("li"));` && |\n| &&
             `    if (items.length > 0) {` && |\n| &&
             `      const safeItems = items.map((li) => {` && |\n| &&
             `        _sanitizeEl.textContent = li.textContent;` && |\n| &&
             `        return ``<li>${_sanitizeEl.innerHTML}</li>``;` && |\n| &&
             `      });` && |\n| &&
             `      return ``<ul>${safeItems.join("")}</ul>``;` && |\n| &&
             `    }` && |\n| &&
             `    _sanitizeEl.textContent = doc.body.textContent;` && |\n| &&
             `    return _sanitizeEl.innerHTML;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The five view slots of the multi-view architecture. ``param`` is the` && |\n| &&
             `  // key used in the backend response PARAMS, ``key`` the short slot name` && |\n| &&
             `  // used in frontend events, ``prop`` the z2ui5 property holding the live` && |\n| &&
             `  // view instance.` && |\n| &&
             `  const viewSlots = [` && |\n| &&
             `    { key: "MAIN", param: "S_VIEW", prop: "oView" },` && |\n| &&
             `    { key: "NEST", param: "S_VIEW_NEST", prop: "oViewNest" },` && |\n| &&
             `    { key: "NEST2", param: "S_VIEW_NEST2", prop: "oViewNest2" },` && |\n| &&
             `    { key: "POPUP", param: "S_POPUP", prop: "oViewPopup" },` && |\n| &&
             `    { key: "POPOVER", param: "S_POPOVER", prop: "oViewPopover" },` && |\n| &&
             `  ];` && |\n| &&
             `` && |\n| &&
             `  // Returns the live view instance for a slot key ("MAIN", "POPUP", ...).` && |\n| &&
             `  function getViewByKey(key) {` && |\n| &&
             `    const slot = viewSlots.find((s) => s.key === key);` && |\n| &&
             `    return slot ? z2ui5[slot.prop] : undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns the slot key for a response param key ("S_VIEW" -> "MAIN").` && |\n| &&
             `  function slotKeyByParam(param) {` && |\n| &&
             `    const slot = viewSlots.find((s) => s.param === param);` && |\n| &&
             `    return slot ? slot.key : undefined;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    logError,` && |\n| &&
             `    isDestroyed,` && |\n| &&
             `    isAlive,` && |\n| &&
             `    registerCallback,` && |\n| &&
             `    unregisterCallback,` && |\n| &&
             `    readFileAsDataURL,` && |\n| &&
             `    applyTokenUpdate,` && |\n| &&
             `    runCallbacks,` && |\n| &&
             `    whenRendered,` && |\n| &&
             `    copyToClipboard,` && |\n| &&
             `    toText,` && |\n| &&
             `    isValidRedirectURL,` && |\n| &&
             `    isSafeRedirectProtocol,` && |\n| &&
             `    isSafeDownloadURL,` && |\n| &&
             `    isValidContextId,` && |\n| &&
             `    buildDeltaFromPaths,` && |\n| &&
             `    sanitizeMessageDetails,` && |\n| &&
             `    viewSlots,` && |\n| &&
             `    getViewByKey,` && |\n| &&
             `    slotKeyByParam,` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
