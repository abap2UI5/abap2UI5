* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_console_js DEFINITION
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


CLASS z2ui5_cl_ui5f_console_js IMPLEMENTATION.

  METHOD get.

    result = `// Console capture of the developer tools.` && |\n| &&
             `//` && |\n| &&
             `// Brings into the app what you would otherwise have to open the browser's` && |\n| &&
             `// own devtools for. On a locked-down desktop, on a tablet, or in a` && |\n| &&
             `// customer's system where F12 is not an option, that difference is the` && |\n| &&
             `// difference between diagnosing a problem and not.` && |\n| &&
             `//` && |\n| &&
             `// Three sources, in increasing order of invasiveness:` && |\n| &&
             `//` && |\n| &&
             `//  1. UI5's own log (sap/base/Log). An OFFICIAL listener API - nothing is` && |\n| &&
             `//     patched. This is where the messages live that explain most broken` && |\n| &&
             `//     views: unresolved binding paths, unknown aggregations, controls that` && |\n| &&
             `//     could not be found, deprecated API warnings.` && |\n| &&
             `//` && |\n| &&
             `//  2. Uncaught errors and unhandled promise rejections (window listeners).` && |\n| &&
             `//     Also non-invasive, and the one class of failure that leaves no trace` && |\n| &&
             `//     anywhere else in the app.` && |\n| &&
             `//` && |\n| &&
             `//  3. console.log / info / warn / error / debug. This one DOES replace the` && |\n| &&
             `//     console methods. The originals are kept and always called through, so` && |\n| &&
             `//     the browser console keeps working exactly as before and uninstall()` && |\n| &&
             `//     puts them back. The one visible cost is that the browser console's` && |\n| &&
             `//     source link then points at this file instead of the calling line -` && |\n| &&
             `//     see the note on install().` && |\n| &&
             `//` && |\n| &&
             `// Like the rest of core/devtools/ this module is outside the framework: no` && |\n| &&
             `// framework module knows it exists, and core/devtools/DevTools.js is what` && |\n| &&
             `// installs it. It depends on nothing at all - not even on the rest of` && |\n| &&
             `// core/devtools/ - it observes the browser and UI5 and hands back a string.` && |\n| &&
             `sap.ui.define([], () => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Ring size. Console output is far chattier than the roundtrip history,` && |\n| &&
             `  // so this is bigger - but every entry is a short string, which keeps the` && |\n| &&
             `  // whole buffer in the same order of magnitude as the error log.` && |\n| &&
             `  const MAX_ENTRIES = 300;` && |\n| &&
             `` && |\n| &&
             `  // Per-entry cap. A single console.log of a large table would otherwise` && |\n| &&
             `  // put megabytes into the ring.` && |\n| &&
             `  const MAX_TEXT_CHARS = 2000;` && |\n| &&
             `` && |\n| &&
             `  // Depth at which an argument stops being expanded.` && |\n| &&
             `  const MAX_DEPTH = 4;` && |\n| &&
             `` && |\n| &&
             `  // sessionStorage key of the entries carried across a page reload, and` && |\n| &&
             `  // how many travel. Only ERROR level: an app that died and was reloaded` && |\n| &&
             `  // throws away exactly the evidence you need, and the errors are the` && |\n| &&
             `  // part of it worth the storage.` && |\n| &&
             `  const RELOAD_KEY = "z2ui5.devtools.console";` && |\n| &&
             `  const RELOAD_MAX_ENTRIES = 40;` && |\n| &&
             `` && |\n| &&
             `  // Opt-in: announce an error-level entry to whoever subscribed via` && |\n| &&
             `  // setOnError. The developer tools turn that into "open on the Console` && |\n| &&
             `  // tab"; the setting lives HERE because this is where the errors are, and` && |\n| &&
             `  // because the dialog and the lifecycle facade both need to reach it` && |\n| &&
             `  // without importing each other.` && |\n| &&
             `  const ALERT_KEY = "z2ui5.devtools.openOnError";` && |\n| &&
             `` && |\n| &&
             `  // The console methods that are captured. Kept as a list so uninstall()` && |\n| &&
             `  // restores exactly what install() replaced.` && |\n| &&
             `  const METHODS = ["log", "info", "warn", "error", "debug"];` && |\n| &&
             `` && |\n| &&
             `  // Oldest first: { ts, level, source, text }.` && |\n| &&
             `  let entries = [];` && |\n| &&
             `  let dropped = 0;` && |\n| &&
             `` && |\n| &&
             `  const originals = {};` && |\n| &&
             `  let installed = false;` && |\n| &&
             `  let ui5Listener = null;` && |\n| &&
             `  let onWindowError = null;` && |\n| &&
             `  let onRejection = null;` && |\n| &&
             `  let onPageHide = null;` && |\n| &&
             `` && |\n| &&
             `  // Optional notification of an error-level entry, used by` && |\n| &&
             `  // core/devtools/DevTools.js for its "open on error" option. One` && |\n| &&
             `  // subscriber is enough - the tools are the only consumer.` && |\n| &&
             `  let onErrorEntry = null;` && |\n| &&
             `` && |\n| &&
             `  // Re-entrancy guard: formatting an argument must never end up calling a` && |\n| &&
             `  // captured console method again (a getter that logs, a toJSON that` && |\n| &&
             `  // warns). One flag is enough - capture is synchronous.` && |\n| &&
             `  let capturing = false;` && |\n| &&
             `` && |\n| &&
             `  function push(level, source, text) {` && |\n| &&
             `    if (entries.length >= MAX_ENTRIES) {` && |\n| &&
             `      entries.shift();` && |\n| &&
             `      dropped += 1;` && |\n| &&
             `    }` && |\n| &&
             `    let body = text;` && |\n| &&
             `    if (body.length > MAX_TEXT_CHARS) {` && |\n| &&
             `      body = ``${body.slice(0, MAX_TEXT_CHARS)}... (${body.length} chars)``;` && |\n| &&
             `    }` && |\n| &&
             `    const entry = {` && |\n| &&
             `      ts: new Date().toISOString(),` && |\n| &&
             `      level,` && |\n| &&
             `      source,` && |\n| &&
             `      text: body,` && |\n| &&
             `    };` && |\n| &&
             `    entries.push(entry);` && |\n| &&
             `    if (level === "error" && onErrorEntry && isAlertOnError()) {` && |\n| &&
             `      try {` && |\n| &&
             `        onErrorEntry(entry);` && |\n| &&
             `      } catch {` && |\n| &&
             `        // a subscriber must never break the capture` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function setOnError(fn) {` && |\n| &&
             `    onErrorEntry = fn;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function isAlertOnError() {` && |\n| &&
             `    try {` && |\n| &&
             `      return window.sessionStorage?.getItem(ALERT_KEY) === "X";` && |\n| &&
             `    } catch {` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function setAlertOnError(enabled) {` && |\n| &&
             `    try {` && |\n| &&
             `      if (enabled) {` && |\n| &&
             `        window.sessionStorage?.setItem(ALERT_KEY, "X");` && |\n| &&
             `      } else {` && |\n| &&
             `        window.sessionStorage?.removeItem(ALERT_KEY);` && |\n| &&
             `      }` && |\n| &&
             `    } catch {` && |\n| &&
             `      // storage unavailable - the switch then does not persist` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Carry the error-level entries into the next page load (see RELOAD_KEY).` && |\n| &&
             `  function persist() {` && |\n| &&
             `    try {` && |\n| &&
             `      const errors = entries` && |\n| &&
             `        .filter((entry) => entry.level === "error")` && |\n| &&
             `        .slice(-RELOAD_MAX_ENTRIES)` && |\n| &&
             `        .map((entry) => ({ ...entry, previousLoad: true }));` && |\n| &&
             `      if (!errors.length) return;` && |\n| &&
             `      window.sessionStorage?.setItem(RELOAD_KEY, JSON.stringify(errors));` && |\n| &&
             `    } catch {` && |\n| &&
             `      // storage full or unavailable - they simply do not survive` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function restore() {` && |\n| &&
             `    let stored;` && |\n| &&
             `    try {` && |\n| &&
             `      stored = window.sessionStorage?.getItem(RELOAD_KEY);` && |\n| &&
             `      window.sessionStorage?.removeItem(RELOAD_KEY);` && |\n| &&
             `    } catch {` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    if (!stored) return;` && |\n| &&
             `    try {` && |\n| &&
             `      const parsed = JSON.parse(stored);` && |\n| &&
             `      if (Array.isArray(parsed)) entries = parsed.slice(-RELOAD_MAX_ENTRIES);` && |\n| &&
             `    } catch {` && |\n| &&
             `      entries = [];` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Errors are recognised by SHAPE, not with ``instanceof Error``: an error` && |\n| &&
             `  // thrown in another realm (an iframe, a worker, a library bundled with` && |\n| &&
             `  // its own Error) is not an instance of this realm's Error, and losing` && |\n| &&
             `  // its stack is exactly the case this capture exists for.` && |\n| &&
             `  function isErrorLike(value) {` && |\n| &&
             `    if (!value || typeof value !== "object") return false;` && |\n| &&
             `    if (Object.prototype.toString.call(value) === "[object Error]") return true;` && |\n| &&
             `    return typeof value.stack === "string" && typeof value.message === "string";` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Render one console argument the way the browser console would - but as` && |\n| &&
             `  // a string, and without ever throwing. Errors keep their stack, which is` && |\n| &&
             `  // the whole point of capturing them.` && |\n| &&
             `  function renderArg(value, depth) {` && |\n| &&
             `    if (value === undefined) return "undefined";` && |\n| &&
             `    if (value === null) return "null";` && |\n| &&
             `    const type = typeof value;` && |\n| &&
             `    if (type === "string") return value;` && |\n| &&
             `    if (type === "number" || type === "boolean" || type === "bigint") {` && |\n| &&
             `      return String(value);` && |\n| &&
             `    }` && |\n| &&
             `    if (type === "function") return ``[function ${value.name || "anonymous"}]``;` && |\n| &&
             `    if (type === "symbol") return String(value);` && |\n| &&
             `    if (isErrorLike(value)) {` && |\n| &&
             `      return value.stack || ``${value.name || "Error"}: ${value.message}``;` && |\n| &&
             `    }` && |\n| &&
             `    if ((depth || 0) >= MAX_DEPTH) return "[...]";` && |\n| &&
             `    try {` && |\n| &&
             `      // A plain stringify covers arrays and objects; the replacer keeps a` && |\n| &&
             `      // circular graph (a UI5 control reaches its parent) from throwing.` && |\n| &&
             `      const seen = new WeakSet();` && |\n| &&
             `      return JSON.stringify(value, (key, val) => {` && |\n| &&
             `        if (typeof val === "object" && val !== null) {` && |\n| &&
             `          if (seen.has(val)) return "[Circular]";` && |\n| &&
             `          seen.add(val);` && |\n| &&
             `        }` && |\n| &&
             `        if (isErrorLike(val)) return val.stack || String(val);` && |\n| &&
             `        return val;` && |\n| &&
             `      });` && |\n| &&
             `    } catch {` && |\n| &&
             `      try {` && |\n| &&
             `        return String(value);` && |\n| &&
             `      } catch {` && |\n| &&
             `        return "[unrenderable]";` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function renderArgs(args) {` && |\n| &&
             `    const parts = [];` && |\n| &&
             `    for (const arg of args) parts.push(renderArg(arg, 0));` && |\n| &&
             `    return parts.join(" ");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // Sources` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  function captureConsole(level, args) {` && |\n| &&
             `    if (capturing) return;` && |\n| &&
             `    capturing = true;` && |\n| &&
             `    try {` && |\n| &&
             `      push(level, "console", renderArgs(args));` && |\n| &&
             `    } catch {` && |\n| &&
             `      // capture must never break the call it is observing` && |\n| &&
             `    } finally {` && |\n| &&
             `      capturing = false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // UI5 log levels are numeric (Log.Level): 1 FATAL, 2 ERROR, 3 WARNING,` && |\n| &&
             `  // 4 INFO, 5 DEBUG, 6 TRACE. Mapped onto the console level names so one` && |\n| &&
             `  // rendering serves both sources.` && |\n| &&
             `  const UI5_LEVELS = {` && |\n| &&
             `    1: "error",` && |\n| &&
             `    2: "error",` && |\n| &&
             `    3: "warn",` && |\n| &&
             `    4: "info",` && |\n| &&
             `    5: "debug",` && |\n| &&
             `    6: "debug",` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  function captureUi5(logEntry) {` && |\n| &&
             `    try {` && |\n| &&
             `      const level = UI5_LEVELS[logEntry?.level] || "info";` && |\n| &&
             `      const component = logEntry?.component ? ``[${logEntry.component}] `` : "";` && |\n| &&
             `      const details = logEntry?.details ? `` - ${logEntry.details}`` : "";` && |\n| &&
             `      push(level, "ui5", ``${component}${logEntry?.message || ""}${details}``);` && |\n| &&
             `    } catch {` && |\n| &&
             `      // never let a malformed log entry escape` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // Install / uninstall` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  function installConsole() {` && |\n| &&
             `    for (const name of METHODS) {` && |\n| &&
             `      const original = window.console?.[name];` && |\n| &&
             `      if (typeof original !== "function") continue;` && |\n| &&
             `      originals[name] = original;` && |\n| &&
             `      // The original is called FIRST and always, so the browser console` && |\n| &&
             `      // behaves exactly as it did before - this only adds a copy. The cost` && |\n| &&
             `      // is that the console's source link now resolves to this wrapper` && |\n| &&
             `      // rather than the calling line; capturing the call at all is what` && |\n| &&
             `      // buys the in-app log, and uninstall() restores the native methods.` && |\n| &&
             `      window.console[name] = function (...args) {` && |\n| &&
             `        try {` && |\n| &&
             `          original.apply(window.console, args);` && |\n| &&
             `        } finally {` && |\n| &&
             `          captureConsole(name, args);` && |\n| &&
             `        }` && |\n| &&
             `      };` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function uninstallConsole() {` && |\n| &&
             `    for (const name of Object.keys(originals)) {` && |\n| &&
             `      window.console[name] = originals[name];` && |\n| &&
             `      delete originals[name];` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function installUi5Log() {` && |\n| &&
             `    const Log = sap.ui.require("sap/base/Log");` && |\n| &&
             `    if (!Log?.addLogListener) return;` && |\n| &&
             `    ui5Listener = { onLogEntry: captureUi5 };` && |\n| &&
             `    try {` && |\n| &&
             `      Log.addLogListener(ui5Listener);` && |\n| &&
             `    } catch {` && |\n| &&
             `      ui5Listener = null;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function uninstallUi5Log() {` && |\n| &&
             `    if (!ui5Listener) return;` && |\n| &&
             `    const Log = sap.ui.require("sap/base/Log");` && |\n| &&
             `    try {` && |\n| &&
             `      Log?.removeLogListener?.(ui5Listener);` && |\n| &&
             `    } catch {` && |\n| &&
             `      // listener already gone` && |\n| &&
             `    }` && |\n| &&
             `    ui5Listener = null;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function install() {` && |\n| &&
             `    if (installed) return;` && |\n| &&
             `    installed = true;` && |\n| &&
             `    restore();` && |\n| &&
             `` && |\n| &&
             `    onWindowError = (event) => {` && |\n| &&
             `      const stack = event?.error?.stack;` && |\n| &&
             `      // A stack already carries the position. Appending it anyway put it at` && |\n| &&
             `      // the end of the LAST stack line, where it reads as part of the` && |\n| &&
             `      // deepest frame - only add it when there is no stack to place it in.` && |\n| &&
             `      if (stack) {` && |\n| &&
             `        push("error", "uncaught", stack);` && |\n| &&
             `        return;` && |\n| &&
             `      }` && |\n| &&
             `      const where = event?.filename` && |\n| &&
             `        ? `` (${event.filename}:${event.lineno || 0}:${event.colno || 0})``` && |\n| &&
             `        : "";` && |\n| &&
             `      push("error", "uncaught", ``${event?.message || "unknown error"}${where}``);` && |\n| &&
             `    };` && |\n| &&
             `    onRejection = (event) => {` && |\n| &&
             `      const reason = event?.reason;` && |\n| &&
             `      push(` && |\n| &&
             `        "error",` && |\n| &&
             `        "rejection",` && |\n| &&
             `        reason?.stack || renderArg(reason, 0) || "unhandled rejection",` && |\n| &&
             `      );` && |\n| &&
             `    };` && |\n| &&
             `    onPageHide = persist;` && |\n| &&
             `    window.addEventListener("error", onWindowError);` && |\n| &&
             `    window.addEventListener("unhandledrejection", onRejection);` && |\n| &&
             `    window.addEventListener("pagehide", onPageHide);` && |\n| &&
             `` && |\n| &&
             `    installUi5Log();` && |\n| &&
             `    installConsole();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function uninstall() {` && |\n| &&
             `    if (!installed) return;` && |\n| &&
             `    installed = false;` && |\n| &&
             `    uninstallConsole();` && |\n| &&
             `    uninstallUi5Log();` && |\n| &&
             `    if (onWindowError) window.removeEventListener("error", onWindowError);` && |\n| &&
             `    if (onRejection) {` && |\n| &&
             `      window.removeEventListener("unhandledrejection", onRejection);` && |\n| &&
             `    }` && |\n| &&
             `    if (onPageHide) window.removeEventListener("pagehide", onPageHide);` && |\n| &&
             `    onWindowError = null;` && |\n| &&
             `    onRejection = null;` && |\n| &&
             `    onPageHide = null;` && |\n| &&
             `    onErrorEntry = null;` && |\n| &&
             `    entries = [];` && |\n| &&
             `    dropped = 0;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // Rendering` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  // Column width of the source marker ("console", "ui5", "uncaught",` && |\n| &&
             `  // "rejection"). Not 9: "rejection" is exactly nine characters and ran` && |\n| &&
             `  // straight into the message text with no separating space.` && |\n| &&
             `  const SOURCE_WIDTH = 10;` && |\n| &&
             `` && |\n| &&
             `  // Indent of a wrapped line (a stack trace) so it lines up under the` && |\n| &&
             `  // message instead of under the timestamp.` && |\n| &&
             `  const CONTINUATION_INDENT = " ".repeat(23 + SOURCE_WIDTH);` && |\n| &&
             `` && |\n| &&
             `  const LEVEL_LABEL = {` && |\n| &&
             `    error: "ERROR",` && |\n| &&
             `    warn: "WARN ",` && |\n| &&
             `    info: "INFO ",` && |\n| &&
             `    log: "LOG  ",` && |\n| &&
             `    debug: "DEBUG",` && |\n| &&
             `  };` && |\n| &&
             `` && |\n| &&
             `  function counts() {` && |\n| &&
             `    const out = { error: 0, warn: 0, info: 0, log: 0, debug: 0 };` && |\n| &&
             `    for (const entry of entries) {` && |\n| &&
             `      if (out[entry.level] !== undefined) out[entry.level] += 1;` && |\n| &&
             `    }` && |\n| &&
             `    return out;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function format() {` && |\n| &&
             `    const lines = ["abap2UI5 Developer Tools - Console"];` && |\n| &&
             `    lines.push("");` && |\n| &&
             `    lines.push(` && |\n| &&
             `      "  Captured in the app, so the browser's own devtools do not have to be",` && |\n| &&
             `    );` && |\n| &&
             `    lines.push(` && |\n| &&
             `      "  open: UI5's log (binding and control problems), uncaught errors and",` && |\n|.
    result = result &&
             `    );` && |\n| &&
             `    lines.push("  unhandled rejections, plus every console.* call.");` && |\n| &&
             `    lines.push("");` && |\n| &&
             `    const c = counts();` && |\n| &&
             `    lines.push(` && |\n| &&
             `      ``  ${entries.length} entr(ies) - ${c.error} error, ${c.warn} warn,`` +` && |\n| &&
             `        `` ${c.info} info, ${c.log} log, ${c.debug} debug`` +` && |\n| &&
             `        (dropped ? `` (${dropped} older dropped)`` : ""),` && |\n| &&
             `    );` && |\n| &&
             `    lines.push("");` && |\n| &&
             `    if (!entries.length) {` && |\n| &&
             `      lines.push("  (nothing logged yet)");` && |\n| &&
             `      return lines.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `    for (const entry of entries) {` && |\n| &&
             `      const label = LEVEL_LABEL[entry.level] || entry.level.toUpperCase();` && |\n| &&
             `      const head =` && |\n| &&
             `        ``  ${entry.ts.slice(11, 23)}${entry.previousLoad ? "*" : " "} ${label}  `` +` && |\n| &&
             `        ``${entry.source.padEnd(SOURCE_WIDTH)}``;` && |\n| &&
             `      const [first, ...rest] = entry.text.split("\n");` && |\n| &&
             `      lines.push(``${head}${first}``);` && |\n| &&
             `      // a stack trace keeps its own lines, indented under its message` && |\n| &&
             `      for (const line of rest)` && |\n| &&
             `        lines.push(``${CONTINUATION_INDENT}${line.trim()}``);` && |\n| &&
             `    }` && |\n| &&
             `    return lines.join("\n");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function getEntries() {` && |\n| &&
             `    return entries;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when anything was captured at error level - lets the dialog point` && |\n| &&
             `  // at this tab rather than making the developer go looking.` && |\n| &&
             `  function hasErrors() {` && |\n| &&
             `    return entries.some((entry) => entry.level === "error");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    install,` && |\n| &&
             `    uninstall,` && |\n| &&
             `    setOnError,` && |\n| &&
             `    isAlertOnError,` && |\n| &&
             `    setAlertOnError,` && |\n| &&
             `    format,` && |\n| &&
             `    getEntries,` && |\n| &&
             `    hasErrors,` && |\n| &&
             `    // exposed for the unit specs` && |\n| &&
             `    _internals: { renderArg, MAX_ENTRIES, MAX_TEXT_CHARS },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
