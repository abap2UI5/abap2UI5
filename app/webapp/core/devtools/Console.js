// Console capture of the developer tools.
//
// Brings into the app what you would otherwise have to open the browser's
// own devtools for. On a locked-down desktop, on a tablet, or in a
// customer's system where F12 is not an option, that difference is the
// difference between diagnosing a problem and not.
//
// Three sources, in increasing order of invasiveness:
//
//  1. UI5's own log (sap/base/Log). An OFFICIAL listener API - nothing is
//     patched. This is where the messages live that explain most broken
//     views: unresolved binding paths, unknown aggregations, controls that
//     could not be found, deprecated API warnings.
//
//  2. Uncaught errors and unhandled promise rejections (window listeners).
//     Also non-invasive, and the one class of failure that leaves no trace
//     anywhere else in the app.
//
//  3. console.log / info / warn / error / debug. This one DOES replace the
//     console methods. The originals are kept and always called through, so
//     the browser console keeps working exactly as before and uninstall()
//     puts them back. The one visible cost is that the browser console's
//     source link then points at this file instead of the calling line -
//     see the note on install().
//
// Like the rest of core/devtools/ this module is outside the framework: no
// framework module knows it exists, and core/devtools/DevTools.js is what
// installs it. It depends on nothing at all - not even on the rest of
// core/devtools/ - it observes the browser and UI5 and hands back a string.
sap.ui.define([], () => {
  "use strict";

  // Ring size. Console output is far chattier than the roundtrip history,
  // so this is bigger - but every entry is a short string, which keeps the
  // whole buffer in the same order of magnitude as the error log.
  const MAX_ENTRIES = 300;

  // Per-entry cap. A single console.log of a large table would otherwise
  // put megabytes into the ring.
  const MAX_TEXT_CHARS = 2000;

  // Depth at which an argument stops being expanded.
  const MAX_DEPTH = 4;

  // The console methods that are captured. Kept as a list so uninstall()
  // restores exactly what install() replaced.
  const METHODS = ["log", "info", "warn", "error", "debug"];

  // Oldest first: { ts, level, source, text }.
  let entries = [];
  let dropped = 0;

  const originals = {};
  let installed = false;
  let ui5Listener = null;
  let onWindowError = null;
  let onRejection = null;

  // Re-entrancy guard: formatting an argument must never end up calling a
  // captured console method again (a getter that logs, a toJSON that
  // warns). One flag is enough - capture is synchronous.
  let capturing = false;

  function push(level, source, text) {
    if (entries.length >= MAX_ENTRIES) {
      entries.shift();
      dropped += 1;
    }
    let body = text;
    if (body.length > MAX_TEXT_CHARS) {
      body = `${body.slice(0, MAX_TEXT_CHARS)}... (${body.length} chars)`;
    }
    entries.push({
      ts: new Date().toISOString(),
      level,
      source,
      text: body,
    });
  }

  // Errors are recognised by SHAPE, not with `instanceof Error`: an error
  // thrown in another realm (an iframe, a worker, a library bundled with
  // its own Error) is not an instance of this realm's Error, and losing
  // its stack is exactly the case this capture exists for.
  function isErrorLike(value) {
    if (!value || typeof value !== "object") return false;
    if (Object.prototype.toString.call(value) === "[object Error]") return true;
    return typeof value.stack === "string" && typeof value.message === "string";
  }

  // Render one console argument the way the browser console would - but as
  // a string, and without ever throwing. Errors keep their stack, which is
  // the whole point of capturing them.
  function renderArg(value, depth) {
    if (value === undefined) return "undefined";
    if (value === null) return "null";
    const type = typeof value;
    if (type === "string") return value;
    if (type === "number" || type === "boolean" || type === "bigint") {
      return String(value);
    }
    if (type === "function") return `[function ${value.name || "anonymous"}]`;
    if (type === "symbol") return String(value);
    if (isErrorLike(value)) {
      return value.stack || `${value.name || "Error"}: ${value.message}`;
    }
    if ((depth || 0) >= MAX_DEPTH) return "[...]";
    try {
      // A plain stringify covers arrays and objects; the replacer keeps a
      // circular graph (a UI5 control reaches its parent) from throwing.
      const seen = new WeakSet();
      return JSON.stringify(value, (key, val) => {
        if (typeof val === "object" && val !== null) {
          if (seen.has(val)) return "[Circular]";
          seen.add(val);
        }
        if (isErrorLike(val)) return val.stack || String(val);
        return val;
      });
    } catch {
      try {
        return String(value);
      } catch {
        return "[unrenderable]";
      }
    }
  }

  function renderArgs(args) {
    const parts = [];
    for (const arg of args) parts.push(renderArg(arg, 0));
    return parts.join(" ");
  }

  // ------------------------------------------------------------------
  // Sources
  // ------------------------------------------------------------------

  function captureConsole(level, args) {
    if (capturing) return;
    capturing = true;
    try {
      push(level, "console", renderArgs(args));
    } catch {
      // capture must never break the call it is observing
    } finally {
      capturing = false;
    }
  }

  // UI5 log levels are numeric (Log.Level): 1 FATAL, 2 ERROR, 3 WARNING,
  // 4 INFO, 5 DEBUG, 6 TRACE. Mapped onto the console level names so one
  // rendering serves both sources.
  const UI5_LEVELS = {
    1: "error",
    2: "error",
    3: "warn",
    4: "info",
    5: "debug",
    6: "debug",
  };

  function captureUi5(logEntry) {
    try {
      const level = UI5_LEVELS[logEntry?.level] || "info";
      const component = logEntry?.component ? `[${logEntry.component}] ` : "";
      const details = logEntry?.details ? ` - ${logEntry.details}` : "";
      push(level, "ui5", `${component}${logEntry?.message || ""}${details}`);
    } catch {
      // never let a malformed log entry escape
    }
  }

  // ------------------------------------------------------------------
  // Install / uninstall
  // ------------------------------------------------------------------

  function installConsole() {
    for (const name of METHODS) {
      const original = window.console?.[name];
      if (typeof original !== "function") continue;
      originals[name] = original;
      // The original is called FIRST and always, so the browser console
      // behaves exactly as it did before - this only adds a copy. The cost
      // is that the console's source link now resolves to this wrapper
      // rather than the calling line; capturing the call at all is what
      // buys the in-app log, and uninstall() restores the native methods.
      window.console[name] = function (...args) {
        try {
          original.apply(window.console, args);
        } finally {
          captureConsole(name, args);
        }
      };
    }
  }

  function uninstallConsole() {
    for (const name of Object.keys(originals)) {
      window.console[name] = originals[name];
      delete originals[name];
    }
  }

  function installUi5Log() {
    const Log = sap.ui.require("sap/base/Log");
    if (!Log?.addLogListener) return;
    ui5Listener = { onLogEntry: captureUi5 };
    try {
      Log.addLogListener(ui5Listener);
    } catch {
      ui5Listener = null;
    }
  }

  function uninstallUi5Log() {
    if (!ui5Listener) return;
    const Log = sap.ui.require("sap/base/Log");
    try {
      Log?.removeLogListener?.(ui5Listener);
    } catch {
      // listener already gone
    }
    ui5Listener = null;
  }

  function install() {
    if (installed) return;
    installed = true;

    onWindowError = (event) => {
      const stack = event?.error?.stack;
      // A stack already carries the position. Appending it anyway put it at
      // the end of the LAST stack line, where it reads as part of the
      // deepest frame - only add it when there is no stack to place it in.
      if (stack) {
        push("error", "uncaught", stack);
        return;
      }
      const where = event?.filename
        ? ` (${event.filename}:${event.lineno || 0}:${event.colno || 0})`
        : "";
      push("error", "uncaught", `${event?.message || "unknown error"}${where}`);
    };
    onRejection = (event) => {
      const reason = event?.reason;
      push(
        "error",
        "rejection",
        reason?.stack || renderArg(reason, 0) || "unhandled rejection",
      );
    };
    window.addEventListener("error", onWindowError);
    window.addEventListener("unhandledrejection", onRejection);

    installUi5Log();
    installConsole();
  }

  function uninstall() {
    if (!installed) return;
    installed = false;
    uninstallConsole();
    uninstallUi5Log();
    if (onWindowError) window.removeEventListener("error", onWindowError);
    if (onRejection) {
      window.removeEventListener("unhandledrejection", onRejection);
    }
    onWindowError = null;
    onRejection = null;
    entries = [];
    dropped = 0;
  }

  // ------------------------------------------------------------------
  // Rendering
  // ------------------------------------------------------------------

  // Column width of the source marker ("console", "ui5", "uncaught",
  // "rejection"). Not 9: "rejection" is exactly nine characters and ran
  // straight into the message text with no separating space.
  const SOURCE_WIDTH = 10;

  // Indent of a wrapped line (a stack trace) so it lines up under the
  // message instead of under the timestamp.
  const CONTINUATION_INDENT = " ".repeat(23 + SOURCE_WIDTH);

  const LEVEL_LABEL = {
    error: "ERROR",
    warn: "WARN ",
    info: "INFO ",
    log: "LOG  ",
    debug: "DEBUG",
  };

  function counts() {
    const out = { error: 0, warn: 0, info: 0, log: 0, debug: 0 };
    for (const entry of entries) {
      if (out[entry.level] !== undefined) out[entry.level] += 1;
    }
    return out;
  }

  function format() {
    const lines = ["abap2UI5 Developer Tools - Console"];
    lines.push("");
    lines.push(
      "  Captured in the app, so the browser's own devtools do not have to be",
    );
    lines.push(
      "  open: UI5's log (binding and control problems), uncaught errors and",
    );
    lines.push("  unhandled rejections, plus every console.* call.");
    lines.push("");
    const c = counts();
    lines.push(
      `  ${entries.length} entr(ies) - ${c.error} error, ${c.warn} warn,` +
        ` ${c.info} info, ${c.log} log, ${c.debug} debug` +
        (dropped ? ` (${dropped} older dropped)` : ""),
    );
    lines.push("");
    if (!entries.length) {
      lines.push("  (nothing logged yet)");
      return lines.join("\n");
    }
    for (const entry of entries) {
      const label = LEVEL_LABEL[entry.level] || entry.level.toUpperCase();
      const head =
        `  ${entry.ts.slice(11, 23)}  ${label}  ` +
        `${entry.source.padEnd(SOURCE_WIDTH)}`;
      const [first, ...rest] = entry.text.split("\n");
      lines.push(`${head}${first}`);
      // a stack trace keeps its own lines, indented under its message
      for (const line of rest)
        lines.push(`${CONTINUATION_INDENT}${line.trim()}`);
    }
    return lines.join("\n");
  }

  function getEntries() {
    return entries;
  }

  // True when anything was captured at error level - lets the dialog point
  // at this tab rather than making the developer go looking.
  function hasErrors() {
    return entries.some((entry) => entry.level === "error");
  }

  return {
    install,
    uninstall,
    format,
    getEntries,
    hasErrors,
    // exposed for the unit specs
    _internals: { renderArg, MAX_ENTRIES, MAX_TEXT_CHARS },
  };
});
