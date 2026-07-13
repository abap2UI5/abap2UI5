// Shared helper module of the z2ui5 frontend. core/AppState.js owns the
// shared frontend state and documents the complete field inventory
// (public contract vs. internal fields, plus their defaults); the helpers
// here reach it via AppState.state instead of the z2ui5 global.
//
// Shared rendering pattern of the custom controls (Timer.js, Focus.js,
// Scrolling.js, Tree.js, ...): the renderer only *marks* work by setting a
// `_pending*` flag on the control instance, and onAfterRendering() consumes
// the flag and performs the actual DOM work (focus, scrolling, timers, tree
// state). Renderers must stay cheap and free of visible side effects
// (rendering API v2); deferring to onAfterRendering also guarantees the
// control's DOM exists.
sap.ui.define(["z2ui5/core/AppState"], (AppState) => {
  "use strict";

  // Cap the error log so a long-running session cannot grow it unbounded.
  const MAX_ERRORS = 100;

  // Append an entry to the shared error log and drop the oldest entry once
  // the cap is reached. In the app the array always exists (AppState
  // default); the guard keeps the helper usable standalone, e.g. in the
  // Node specs that load this module with a bare AppState stub.
  function logError(message, error) {
    const state = AppState.state;
    if (!state.errors) state.errors = [];
    const entry = { message, ts: new Date().toISOString() };
    if (error !== undefined) entry.error = error;
    state.errors.push(entry);
    if (state.errors.length > MAX_ERRORS) state.errors.shift();
  }

  // True when the object supports isDestroyed() and reports destroyed.
  function isDestroyed(obj) {
    return Boolean(obj?.isDestroyed && obj.isDestroyed());
  }

  // True when the object exists and is not destroyed. Used to guard
  // async continuations (await, FileReader, getUserMedia, ...) against
  // controls or views that were torn down in the meantime.
  function isAlive(obj) {
    return Boolean(obj) && !isDestroyed(obj);
  }

  // Helpers for managing the shared callback arrays (onBeforeRoundtrip,
  // onAfterRendering, ...). Several custom controls register hooks here in
  // init() and remove them in exit(). The arrays always exist in the app
  // (AppState defaults); the guard keeps the helper standalone-safe.
  function registerCallback(name, fn) {
    const state = AppState.state;
    if (!state[name]) state[name] = [];
    state[name].push(fn);
  }

  function unregisterCallback(name, fn) {
    const state = AppState.state;
    if (!state[name]) return;
    state[name] = state[name].filter((f) => f !== fn);
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

  // Run every callback in `callbacks` (the shared callback arrays above),
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

  // Collapse a UI5 Device `system` flag object into a single label. The
  // order matters - phone/tablet/combi are mutually exclusive with the
  // desktop fallback. Shared by Server._getDeviceInfo (request payload) and
  // the Info control so both report the same value.
  function deriveSystemType(system) {
    if (!system) return "desktop";
    if (system.phone) return "phone";
    if (system.tablet) return "tablet";
    if (system.combi) return "combi";
    return "desktop";
  }

  // Shared first step of the URL validators below: resolve the URL against
  // the current origin, log and return null when it is empty or malformed.
  function parseUrl(url) {
    if (!url) return null;
    try {
      return new URL(url, window.location.origin);
    } catch (e) {
      logError(`Security: Invalid URL format: ${url}`, e);
      return null;
    }
  }

  function hasSafeProtocol(parsed) {
    if (SAFE_PROTOCOLS.includes(parsed.protocol)) return true;
    logError(
      `Security: Blocked redirect with invalid protocol: ${parsed.protocol}`,
    );
    return false;
  }

  // Returns true only if the URL is on the same origin and uses http/https.
  function isValidRedirectURL(url) {
    const parsed = parseUrl(url);
    if (!parsed) return false;
    if (parsed.origin !== window.location.origin) {
      logError(`Security: Blocked redirect to different origin: ${url}`);
      return false;
    }
    return hasSafeProtocol(parsed);
  }

  // Returns true if the URL uses a safe (http/https) protocol. Unlike
  // isValidRedirectURL this allows cross-origin targets, so it fits
  // outbound redirects to external sites while still blocking dangerous
  // schemes such as javascript:, data: or vbscript:.
  function isSafeRedirectProtocol(url) {
    const parsed = parseUrl(url);
    return parsed !== null && hasSafeProtocol(parsed);
  }

  // Returns true for URLs that are safe as download targets: data: and
  // blob: (generated content) plus http(s). Blocks javascript: and other
  // active schemes, consistent with the redirect validators above.
  function isSafeDownloadURL(url) {
    const parsed = parseUrl(url);
    return (
      parsed !== null &&
      (parsed.protocol === "data:" ||
        parsed.protocol === "blob:" ||
        SAFE_PROTOCOLS.includes(parsed.protocol))
    );
  }

  // A usable stateful session id ("sap-contextid"). We must never put a
  // missing value on the wire: an empty or - via string coercion of a
  // JS `undefined` - the literal "undefined" makes the SAP Web Dispatcher /
  // ICM log "invalid w3c session id" / "HttpExtractSID: SID wrong len: 9"
  // on every roundtrip. Only forward a real, non-empty id.
  function isValidContextId(id) {
    return typeof id === "string" && id !== "" && id !== "undefined";
  }

  // Parse the path segments behind the attribute into (row, field) steps.
  // Returns null when the segments do not follow the alternating
  // <numeric row>/<field name> shape - the caller then ships the whole
  // attribute. A non-numeric segment after a field (a struct member, e.g.
  // attr/3/S_ADR/CITY) marks the field as leaf: the whole current value at
  // row/field is shipped, which always covers the deeper edit too.
  function parseDeltaSteps(segs) {
    const steps = [];
    let i = 0;
    while (i < segs.length) {
      const row = segs[i];
      if (row === "" || Number.isNaN(Number(row))) return null;
      const field = segs[i + 1];
      if (field === undefined || field === "" || !Number.isNaN(Number(field))) {
        return null;
      }
      i += 2;
      if (i >= segs.length || Number.isNaN(Number(segs[i]))) {
        steps.push({ row, field, leaf: true });
        return steps;
      }
      // a numeric segment follows -> field is a nested table, walk deeper
      steps.push({ row, field, leaf: false });
    }
    return null;
  }

  // Build the delta object sent to the backend. `paths` is the set of
  // /XX/... paths that the user edited; `xx` is the full XX model data.
  // Table edits become (recursively nested) __delta structures, so a cell
  // edit in a nested/tree table ships only the changed cell instead of
  // the whole outer table.
  function buildDeltaFromPaths(paths, xx) {
    const delta = {};
    for (const path of paths) {
      // path looks like "/XX/<attr>" or "/XX/<attr>/<row>/<field>" with
      // arbitrarily deep <row>/<subtable> repetitions for nested tables
      const parts = path.slice(4).split("/");
      const attr = parts[0];
      const steps = parseDeltaSteps(parts.slice(1));
      if (!steps) {
        // Scalar or unrecognized shape -> ship the whole attribute. The
        // full value always wins over any queued delta: both read the
        // same current model data, so it is a superset of every delta.
        delta[attr] = xx[attr];
        continue;
      }
      // A full attribute queued by another path already carries every
      // cell (both read the same current model data) - never downgrade
      // it to a partial delta, regardless of Set iteration order.
      if (attr in delta && !delta[attr]?.__delta) continue;
      if (!delta[attr]?.__delta) delta[attr] = { __delta: {} };
      let node = delta[attr];
      let model = xx[attr];
      for (const { row, field, leaf } of steps) {
        const rows = node.__delta;
        if (!rows[row]) rows[row] = {};
        const rowDelta = rows[row];
        model = model?.[Number(row)]?.[field];
        if (leaf) {
          // The leaf value (cell, struct or whole sub-table) replaces any
          // nested delta queued for the same field - it reads the same
          // current model data and therefore carries those edits too.
          rowDelta[field] = model;
          break;
        }
        // Nested table step - a whole sub-value queued by another path
        // already covers this deeper edit.
        if (field in rowDelta && !rowDelta[field]?.__delta) break;
        if (!rowDelta[field]?.__delta) rowDelta[field] = { __delta: {} };
        node = rowDelta[field];
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
    // Only top-level list items: a nested <li>'s text is already part of
    // its ancestor's textContent, so including it too would duplicate it.
    const items = Array.from(doc.querySelectorAll("li")).filter(
      (li) => !li.parentElement?.closest("li"),
    );
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
    deriveSystemType,
    isValidRedirectURL,
    isSafeRedirectProtocol,
    isSafeDownloadURL,
    isValidContextId,
    buildDeltaFromPaths,
    sanitizeMessageDetails,
  };
});
