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

    result = `// Shared helper module of the z2ui5 frontend. core/AppState.js owns the` && |\n| &&
             `// shared frontend state and documents the complete field inventory` && |\n| &&
             `// (public contract vs. internal fields, plus their defaults); the helpers` && |\n| &&
             `// here reach it via AppState.state instead of the z2ui5 global.` && |\n| &&
             `//` && |\n| &&
             `// Shared rendering pattern of the custom controls (Timer.js, Focus.js,` && |\n| &&
             `// Scrolling.js, Tree.js, ...): the renderer only *marks* work by setting a` && |\n| &&
             `// ``_pending*`` flag on the control instance, and onAfterRendering() consumes` && |\n| &&
             `// the flag and performs the actual DOM work (focus, scrolling, timers, tree` && |\n| &&
             `// state). Renderers must stay cheap and free of visible side effects` && |\n| &&
             `// (rendering API v2); deferring to onAfterRendering also guarantees the` && |\n| &&
             `// control's DOM exists.` && |\n| &&
             `sap.ui.define(["z2ui5/core/AppState"], (AppState) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Cap the error log so a long-running session cannot grow it unbounded.` && |\n| &&
             `  const MAX_ERRORS = 100;` && |\n| &&
             `` && |\n| &&
             `  // Append an entry to the shared error log and drop the oldest entry once` && |\n| &&
             `  // the cap is reached. In the app the array always exists (AppState` && |\n| &&
             `  // default); the guard keeps the helper usable standalone, e.g. in the` && |\n| &&
             `  // Node specs that load this module with a bare AppState stub.` && |\n| &&
             `  function logError(message, error) {` && |\n| &&
             `    const state = AppState.state;` && |\n| &&
             `    if (!state.errors) state.errors = [];` && |\n| &&
             `    const entry = { message, ts: new Date().toISOString() };` && |\n| &&
             `    if (error !== undefined) entry.error = error;` && |\n| &&
             `    state.errors.push(entry);` && |\n| &&
             `    if (state.errors.length > MAX_ERRORS) state.errors.shift();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the object supports isDestroyed() and reports destroyed.` && |\n| &&
             `  function isDestroyed(obj) {` && |\n| &&
             `    return Boolean(obj?.isDestroyed && obj.isDestroyed());` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the object exists and is not destroyed. Used to guard` && |\n| &&
             `  // async continuations (await, FileReader, getUserMedia, ...) against` && |\n| &&
             `  // controls or views that were torn down in the meantime.` && |\n| &&
             `  function isAlive(obj) {` && |\n| &&
             `    return Boolean(obj) && !isDestroyed(obj);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Helpers for managing the shared callback arrays (onBeforeRoundtrip,` && |\n| &&
             `  // onAfterRendering, ...). Several custom controls register hooks here in` && |\n| &&
             `  // init() and remove them in exit(). The arrays always exist in the app` && |\n| &&
             `  // (AppState defaults); the guard keeps the helper standalone-safe.` && |\n| &&
             `  function registerCallback(name, fn) {` && |\n| &&
             `    const state = AppState.state;` && |\n| &&
             `    if (!state[name]) state[name] = [];` && |\n| &&
             `    state[name].push(fn);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function unregisterCallback(name, fn) {` && |\n| &&
             `    const state = AppState.state;` && |\n| &&
             `    if (!state[name]) return;` && |\n| &&
             `    state[name] = state[name].filter((f) => f !== fn);` && |\n| &&
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
             `  // Run every callback in ``callbacks`` (the shared callback arrays above),` && |\n| &&
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
             `  // Collapse a UI5 Device ``system`` flag object into a single label. The` && |\n| &&
             `  // order matters - phone/tablet/combi are mutually exclusive with the` && |\n| &&
             `  // desktop fallback. Shared by Server._getDeviceInfo (request payload) and` && |\n| &&
             `  // the Info control so both report the same value.` && |\n| &&
             `  function deriveSystemType(system) {` && |\n| &&
             `    if (!system) return "desktop";` && |\n| &&
             `    if (system.phone) return "phone";` && |\n| &&
             `    if (system.tablet) return "tablet";` && |\n| &&
             `    if (system.combi) return "combi";` && |\n| &&
             `    return "desktop";` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Shared first step of the URL validators below: resolve the URL against` && |\n| &&
             `  // the current origin, log and return null when it is empty or malformed.` && |\n| &&
             `  function parseUrl(url) {` && |\n| &&
             `    if (!url) return null;` && |\n| &&
             `    try {` && |\n| &&
             `      return new URL(url, window.location.origin);` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      logError(``Security: Invalid URL format: ${url}``, e);` && |\n| &&
             `      return null;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function hasSafeProtocol(parsed) {` && |\n| &&
             `    if (SAFE_PROTOCOLS.includes(parsed.protocol)) return true;` && |\n| &&
             `    logError(` && |\n| &&
             `      ``Security: Blocked redirect with invalid protocol: ${parsed.protocol}``,` && |\n| &&
             `    );` && |\n| &&
             `    return false;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns true only if the URL is on the same origin and uses http/https.` && |\n| &&
             `  function isValidRedirectURL(url) {` && |\n| &&
             `    const parsed = parseUrl(url);` && |\n| &&
             `    if (!parsed) return false;` && |\n| &&
             `    if (parsed.origin !== window.location.origin) {` && |\n| &&
             `      logError(``Security: Blocked redirect to different origin: ${url}``);` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `    return hasSafeProtocol(parsed);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns true if the URL uses a safe (http/https) protocol. Unlike` && |\n| &&
             `  // isValidRedirectURL this allows cross-origin targets, so it fits` && |\n| &&
             `  // outbound redirects to external sites while still blocking dangerous` && |\n| &&
             `  // schemes such as javascript:, data: or vbscript:.` && |\n| &&
             `  function isSafeRedirectProtocol(url) {` && |\n| &&
             `    const parsed = parseUrl(url);` && |\n| &&
             `    return parsed !== null && hasSafeProtocol(parsed);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Returns true for URLs that are safe as download targets: data: and` && |\n| &&
             `  // blob: (generated content) plus http(s). Blocks javascript: and other` && |\n| &&
             `  // active schemes, consistent with the redirect validators above.` && |\n| &&
             `  function isSafeDownloadURL(url) {` && |\n| &&
             `    const parsed = parseUrl(url);` && |\n| &&
             `    return (` && |\n| &&
             `      parsed !== null &&` && |\n| &&
             `      (parsed.protocol === "data:" ||` && |\n| &&
             `        parsed.protocol === "blob:" ||` && |\n| &&
             `        SAFE_PROTOCOLS.includes(parsed.protocol))` && |\n| &&
             `    );` && |\n| &&
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
             `  // Parse the path segments behind the attribute into (row, field) steps.` && |\n| &&
             `  // Returns null when the segments do not follow the alternating` && |\n| &&
             `  // <numeric row>/<field name> shape - the caller then ships the whole` && |\n| &&
             `  // attribute. A non-numeric segment after a field (a struct member, e.g.` && |\n| &&
             `  // attr/3/S_ADR/CITY) marks the field as leaf: the whole current value at` && |\n| &&
             `  // row/field is shipped, which always covers the deeper edit too.` && |\n| &&
             `  function parseDeltaSteps(segs) {` && |\n| &&
             `    const steps = [];` && |\n| &&
             `    let i = 0;` && |\n| &&
             `    while (i < segs.length) {` && |\n| &&
             `      const row = segs[i];` && |\n| &&
             `      if (row === "" || Number.isNaN(Number(row))) return null;` && |\n| &&
             `      const field = segs[i + 1];` && |\n| &&
             `      if (field === undefined || field === "" || !Number.isNaN(Number(field))) {` && |\n| &&
             `        return null;` && |\n| &&
             `      }` && |\n| &&
             `      i += 2;` && |\n| &&
             `      if (i >= segs.length || Number.isNaN(Number(segs[i]))) {` && |\n| &&
             `        steps.push({ row, field, leaf: true });` && |\n| &&
             `        return steps;` && |\n| &&
             `      }` && |\n| &&
             `      // a numeric segment follows -> field is a nested table, walk deeper` && |\n| &&
             `      steps.push({ row, field, leaf: false });` && |\n| &&
             `    }` && |\n| &&
             `    return null;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Build the delta object sent to the backend. ``paths`` is the set of` && |\n| &&
             `  // /XX/... paths that the user edited; ``xx`` is the full XX model data.` && |\n| &&
             `  // Table edits become (recursively nested) __delta structures, so a cell` && |\n| &&
             `  // edit in a nested/tree table ships only the changed cell instead of` && |\n| &&
             `  // the whole outer table.` && |\n| &&
             `  function buildDeltaFromPaths(paths, xx) {` && |\n| &&
             `    const delta = {};` && |\n| &&
             `    for (const path of paths) {` && |\n| &&
             `      // path looks like "/XX/<attr>" or "/XX/<attr>/<row>/<field>" with` && |\n| &&
             `      // arbitrarily deep <row>/<subtable> repetitions for nested tables` && |\n| &&
             `      const parts = path.slice(4).split("/");` && |\n| &&
             `      const attr = parts[0];` && |\n| &&
             `      const steps = parseDeltaSteps(parts.slice(1));` && |\n| &&
             `      if (!steps) {` && |\n| &&
             `        // Scalar or unrecognized shape -> ship the whole attribute. The` && |\n| &&
             `        // full value always wins over any queued delta: both read the` && |\n| &&
             `        // same current model data, so it is a superset of every delta.` && |\n| &&
             `        delta[attr] = xx[attr];` && |\n| &&
             `        continue;` && |\n| &&
             `      }` && |\n| &&
             `      // A full attribute queued by another path already carries every` && |\n| &&
             `      // cell (both read the same current model data) - never downgrade` && |\n| &&
             `      // it to a partial delta, regardless of Set iteration order.` && |\n| &&
             `      if (attr in delta && !delta[attr]?.__delta) continue;` && |\n| &&
             `      if (!delta[attr]?.__delta) delta[attr] = { __delta: {} };` && |\n| &&
             `      let node = delta[attr];` && |\n| &&
             `      let model = xx[attr];` && |\n| &&
             `      for (const { row, field, leaf } of steps) {` && |\n| &&
             `        const rows = node.__delta;` && |\n| &&
             `        if (!rows[row]) rows[row] = {};` && |\n| &&
             `        const rowDelta = rows[row];` && |\n| &&
             `        model = model?.[Number(row)]?.[field];` && |\n| &&
             `        if (leaf) {` && |\n| &&
             `          // The leaf value (cell, struct or whole sub-table) replaces any` && |\n| &&
             `          // nested delta queued for the same field - it reads the same` && |\n| &&
             `          // current model data and therefore carries those edits too.` && |\n| &&
             `          rowDelta[field] = model;` && |\n| &&
             `          break;` && |\n| &&
             `        }` && |\n| &&
             `        // Nested table step - a whole sub-value queued by another path` && |\n| &&
             `        // already covers this deeper edit.` && |\n| &&
             `        if (field in rowDelta && !rowDelta[field]?.__delta) break;` && |\n| &&
             `        if (!rowDelta[field]?.__delta) rowDelta[field] = { __delta: {} };` && |\n| &&
             `        node = rowDelta[field];` && |\n| &&
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
             `    // Only top-level list items: a nested <li>'s text is already part of` && |\n| &&
             `    // its ancestor's textContent, so including it too would duplicate it.` && |\n| &&
             `    const items = Array.from(doc.querySelectorAll("li")).filter(` && |\n| &&
             `      (li) => !li.parentElement?.closest("li"),` && |\n| &&
             `    );` && |\n| &&
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
             `    deriveSystemType,` && |\n| &&
             `    isValidRedirectURL,` && |\n| &&
             `    isSafeRedirectProtocol,` && |\n| &&
             `    isSafeDownloadURL,` && |\n| &&
             `    isValidContextId,` && |\n| &&
             `    buildDeltaFromPaths,` && |\n| &&
             `    sanitizeMessageDetails,` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
