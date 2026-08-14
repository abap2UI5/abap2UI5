// Roundtrip recorder of the developer tools.
//
// SELF-CONTAINED BY DESIGN: this module is the ONLY place that knows how
// roundtrip history is collected. It observes the framework from the
// outside - through the public callback arrays (Lib.registerCallback) and
// the browser's Resource Timing API - and never asks the framework to
// carry anything for it. Server.js, View1.controller.js, AppState.js and
// Lib.js contain no recorder code and no recorder-shaped hooks; the whole
// feature can be deleted by removing this file and its tabs in
// core/devtools/DeveloperTools.js - core/devtools/DevTools.js is what
// installs it, and that is the framework's only entry point here.
//
// Two tiers, because they cost very different amounts:
//
//  TIER 1 - metadata, always on. One small record per roundtrip: timing,
//    byte sizes, event name, draft id, action counts. A record is a handful
//    of numbers and short strings, and MAX_RECORDS caps the ring - the
//    whole history stays in the tens of kilobytes, the same order of
//    magnitude the error log (Lib.MAX_ERRORS) already keeps.
//
//  TIER 2 - payloads, opt-in. The request body and the response object of
//    each roundtrip. These are the expensive part: a model with a few
//    thousand table rows is megabytes of parsed objects, so retaining 50 of
//    them is not something a production session may pay for silently. Off
//    unless the developer switches it on (sessionStorage, so it survives a
//    reload), and capped by a BYTE BUDGET rather than a record count - a
//    "last 20 roundtrips" limit is meaningless when one entry weighs 8 MB.
//
// Why payloads can be kept as plain REFERENCES (no structuredClone):
// actions/Slots.js hands the response's MODEL object straight to
// JSONModel.setData(), so the live model data IS response.MODEL and the
// two-way binding mutates it in place. That only lasts until the NEXT
// roundtrip calls setData() with the new response's MODEL - from that
// moment the old object is unbound and frozen. So every record except the
// newest is stable, and the newest one is the current state the existing
// tabs show anyway. Retention is the only cost; there is no copying.
sap.ui.define(["z2ui5/core/AppState", "z2ui5/core/Lib"], (AppState, Lib) => {
  "use strict";

  // Tier 1 ring size. 50 records of metadata are far below the error log's
  // footprint and cover a long debugging session.
  const MAX_RECORDS = 50;

  // Tier 2 ceiling, in bytes of measured payload (see recordBytes below).
  // Oldest payloads are dropped first; their metadata records survive, so
  // the history stays complete and only the deep content thins out.
  const PAYLOAD_BUDGET_BYTES = 2 * 1024 * 1024;

  // sessionStorage key of the Tier 2 opt-in. sessionStorage (not local)
  // so the switch survives a reload but not the tab - a developer cannot
  // leave payload recording on for a colleague by accident.
  const PAYLOAD_FLAG_KEY = "z2ui5.devtools.recordPayloads";

  // A network observation is paired with the render that followed it only
  // if the render came after the response ended. Roundtrips whose entry is
  // older than this (and never got a render) are flushed as "no render" -
  // an error response, an abort, or a superseded parallel request.
  const UNPAIRED_FLUSH_MS = 5000;

  // Backend messages are kept as TIER 1 metadata, not as payloads: the
  // text of a toast or message box is a short string, and "what did the
  // app tell the user three roundtrips ago" is exactly the kind of
  // question the history exists for. Capped so a pathological message
  // cannot grow a record without bound.
  const MAX_MESSAGE_CHARS = 500;

  // Rendering caps for the history / diff text output.
  const MAX_DIFF_ENTRIES = 200;
  const MAX_DIFF_DEPTH = 12;
  const MAX_DIFF_VALUE_CHARS = 120;

  // Oldest first. Each entry:
  //   seq          running number, 1-based
  //   ts           wall-clock ISO timestamp of the render
  //   event        the EVENT name the request carried ("" for app start)
  //   idSent       draft id sent with the request
  //   idReceived   draft id the response returned
  //   app          app class name the response named
  //   reqBytes     serialized request size, null when not measured
  //   respBytes    decoded response size, null when Resource Timing is absent
  //   backendMs    request start -> response end (network + ABAP)
  //   renderMs     response end -> rendered, null when unpaired
  //   totalMs      request start -> rendered
  //   systemActions / customActions   action counts of the response
  //   rendered     false for a roundtrip that never reached the render phase
  //   request / response   Tier 2 payload references, null when not kept
  let records = [];

  // Running number handed to the next record. Not records.length: the ring
  // drops old entries, and the numbers must stay stable across evictions.
  let nextSeq = 1;

  // Network observations not yet paired with a render, oldest first. Filled
  // by the PerformanceObserver and the synchronous sweep, drained by
  // onAfterRendering. Each: { start, end, bytes }.
  let unpaired = [];

  // High-water mark of consumed Resource Timing entries. The observer and
  // the sweep both feed `unpaired`, so the same entry must not be taken
  // twice; entries arrive in chronological order from both sources, which
  // makes a single startTime watermark enough.
  let lastEntryStart = -1;

  // Sum of reqBytes + respBytes over the records that still hold payloads.
  // The measured sizes double as the budget accounting - no separate
  // estimation pass is needed.
  let payloadBytes = 0;

  let observer = null;
  let installed = false;
  let afterRenderingHook = null;

  // Absolute form of the backend endpoint, so it can be compared against
  // the absolute names Resource Timing reports. Recomputed per call: the
  // url global is set by the backend page and may not exist yet at install
  // time. Returns "" when unknown or unparsable.
  function backendUrl() {
    const url = AppState.getGlobal("url");
    if (!url) return "";
    try {
      return new URL(url, window.location.href).href;
    } catch {
      return "";
    }
  }

  function now() {
    return typeof performance !== "undefined" && performance.now
      ? performance.now()
      : 0;
  }

  // Accept one Resource Timing entry as a roundtrip observation. Entries
  // older than the watermark were already taken (the observer and the sweep
  // overlap on purpose - see lastEntryStart).
  function acceptEntry(entry) {
    if (!entry || entry.startTime <= lastEntryStart) return;
    lastEntryStart = entry.startTime;
    unpaired.push({
      start: entry.startTime,
      end: entry.responseEnd || entry.startTime,
      // decodedBodySize is the uncompressed payload - the number that
      // answers "is this response too big", which transferSize (compressed,
      // 0 from cache) does not. 0 means "not exposed", reported as null.
      bytes: entry.decodedBodySize || null,
    });
  }

  // Pull any Resource Timing entries for the backend endpoint that the
  // observer has not delivered yet. The observer's callback is queued as a
  // task and may well run AFTER the render it belongs to, so the render
  // path sweeps synchronously first and ordering stops mattering.
  //
  // The sweep alone would not be enough: once the browser's resource buffer
  // is full it silently drops NEW entries, which a long-running SPA reaches.
  // PerformanceObserver delivery is not bound by that buffer, so the two
  // together cover both the ordering and the overflow case.
  function sweepEntries() {
    if (typeof performance === "undefined" || !performance.getEntriesByName) {
      return;
    }
    const url = backendUrl();
    if (!url) return;
    let entries;
    try {
      entries = performance.getEntriesByName(url, "resource");
    } catch {
      return;
    }
    for (const entry of entries) acceptEntry(entry);
  }

  // Take the network observation belonging to a render that happened at
  // `tRendered`: the newest one that finished before it. Everything older
  // than that never rendered - those are flushed as their own records so a
  // failed or superseded roundtrip stays visible in the history.
  function takeNetworkFor(tRendered) {
    let index = -1;
    for (let i = unpaired.length - 1; i >= 0; i--) {
      if (unpaired[i].end <= tRendered) {
        index = i;
        break;
      }
    }
    if (index === -1) return null;
    const stale = unpaired.slice(0, index);
    const match = unpaired[index];
    unpaired = unpaired.slice(index + 1);
    for (const entry of stale) pushUnrendered(entry);
    return match;
  }

  // Flush network observations that never got a render and are old enough
  // that none is coming. Called from the render path and when the history
  // is read, so a failing roundtrip shows up without needing a next one.
  function flushStaleUnpaired() {
    if (!unpaired.length) return;
    const cutoff = now() - UNPAIRED_FLUSH_MS;
    const stale = unpaired.filter((entry) => entry.end < cutoff);
    if (!stale.length) return;
    unpaired = unpaired.filter((entry) => entry.end >= cutoff);
    for (const entry of stale) pushUnrendered(entry);
  }

  // A roundtrip observed on the wire that never reached the render phase:
  // an error response, an aborted request, or a parallel request whose
  // result was discarded as stale. Worth a record of its own - these are
  // exactly the roundtrips a developer is looking for.
  function pushUnrendered(entry) {
    pushRecord({
      ts: new Date().toISOString(),
      event: "",
      idSent: "",
      idReceived: "",
      app: "",
      reqBytes: null,
      respBytes: entry.bytes,
      backendMs: Math.round(entry.end - entry.start),
      renderMs: null,
      totalMs: null,
      systemActions: 0,
      customActions: 0,
      messages: [],
      rendered: false,
      request: null,
      response: null,
    });
  }

  // Pull the user-visible backend messages out of a response's app action
  // list. A message travels as a whitelisted global call
  // ["CONTROL_GLOBAL", "MESSAGE_TOAST"|"MESSAGE_BOX", <method>, <text>, ...]
  // (see core/actions/ControlCall.js); the legacy raw-string entries in
  // T_CUSTOM carry no structured message and are skipped.
  function extractMessages(response) {
    const custom = response?.S_FRONT?.S_ACTION?.T_CUSTOM;
    if (!Array.isArray(custom)) return [];
    const out = [];
    for (const item of custom) {
      if (!Array.isArray(item) || item[0] !== "CONTROL_GLOBAL") continue;
      const target = item[1];
      if (target !== "MESSAGE_TOAST" && target !== "MESSAGE_BOX") continue;
      let text = typeof item[3] === "string" ? item[3] : "";
      if (text.length > MAX_MESSAGE_CHARS) {
        text = `${text.slice(0, MAX_MESSAGE_CHARS)}...`;
      }
      out.push({ target, method: item[2] || "", text });
    }
    return out;
  }

  // Measured weight of a record's retained payloads. Sizes that were not
  // measured count as 0 - the budget then errs towards keeping more, which
  // is the harmless direction for a diagnostic buffer.
  function recordBytes(record) {
    if (!record.request && !record.response) return 0;
    return (record.reqBytes || 0) + (record.respBytes || 0);
  }

  // Drop payloads from the oldest records until the retained set fits the
  // budget. The records themselves stay - the history keeps showing that
  // roundtrip 3 took 900 ms and sent 4 MB, only its content is gone.
  function enforcePayloadBudget() {
    for (const record of records) {
      if (payloadBytes <= PAYLOAD_BUDGET_BYTES) return;
      if (!record.request && !record.response) continue;
      payloadBytes -= recordBytes(record);
      record.request = null;
      record.response = null;
      record.payloadEvicted = true;
    }
  }

  function pushRecord(record) {
    record.seq = nextSeq++;
    records.push(record);
    payloadBytes += recordBytes(record);
    while (records.length > MAX_RECORDS) {
      const dropped = records.shift();
      payloadBytes -= recordBytes(dropped);
    }
    enforcePayloadBudget();
  }

  // True when the developer switched Tier 2 on. Guarded: sessionStorage
  // throws in some embedded/privacy configurations, and a diagnostic tool
  // must never be the thing that breaks the app.
  function isRecordingPayloads() {
    try {
      return window.sessionStorage?.getItem(PAYLOAD_FLAG_KEY) === "X";
    } catch {
      return false;
    }
  }

  function setRecordingPayloads(enabled) {
    try {
      if (enabled) {
        window.sessionStorage?.setItem(PAYLOAD_FLAG_KEY, "X");
      } else {
        window.sessionStorage?.removeItem(PAYLOAD_FLAG_KEY);
      }
    } catch {
      // storage unavailable - the switch then simply does not persist
    }
    if (!enabled) dropAllPayloads();
  }

  function dropAllPayloads() {
    for (const record of records) {
      record.request = null;
      record.response = null;
    }
    payloadBytes = 0;
  }

  // Serialized size of the request body. This is the one number the
  // recorder cannot get for free: Resource Timing exposes no request body
  // size, so the body is serialized a second time here (Server.readHttp
  // does the first one for the actual send). It is a DELTA - only the model
  // paths the user edited travel - so the common case is a few hundred
  // bytes. Returns null if it cannot be serialized.
  function measureRequest(oBody) {
    if (!oBody) return null;
    try {
      return JSON.stringify({ value: oBody }).length;
    } catch {
      return null;
    }
  }

  // Completes one roundtrip: called once the response has been processed
  // and its view is rendered (the onAfterRendering callback array, which
  // View1._processAfterRendering runs at the end of every roundtrip -
  // including the app start and Back/Forward route restores, which never
  // pass through eB and therefore have no other observable entry point).
  function onAfterRendering() {
    try {
      const state = AppState.state;
      const tRendered = now();
      sweepEntries();
      const net = takeNetworkFor(tRendered);
      const response = state.responseData;
      const sFront = response?.S_FRONT;
      const keepPayloads = isRecordingPayloads();
      const reqBytes = measureRequest(state.oBody);

      pushRecord({
        ts: new Date().toISOString(),
        event: state.oBody?.S_FRONT?.EVENT || "",
        idSent: state.oBody?.S_FRONT?.ID || "",
        idReceived: sFront?.ID || "",
        app: sFront?.APP || "",
        reqBytes: reqBytes,
        respBytes: net?.bytes ?? null,
        backendMs: net ? Math.round(net.end - net.start) : null,
        renderMs: net ? Math.round(tRendered - net.end) : null,
        totalMs: net ? Math.round(tRendered - net.start) : null,
        systemActions: sFront?.S_ACTION?.T_SYSTEM?.length || 0,
        customActions: sFront?.S_ACTION?.T_CUSTOM?.length || 0,
        // Tier 1 on purpose - see MAX_MESSAGE_CHARS.
        messages: extractMessages(response),
        rendered: true,
        // Plain references, never clones - see the module header for why
        // that is safe and why it costs nothing but retention.
        request: keepPayloads ? state.oBody : null,
        response: keepPayloads ? response : null,
      });
      flushStaleUnpaired();
    } catch (e) {
      // The recorder is a diagnostic aid; it may never take the app down.
      Lib.logError("DevTools Recorder: onAfterRendering failed", e);
    }
  }

  function install() {
    if (installed) return;
    installed = true;
    afterRenderingHook = onAfterRendering;
    Lib.registerCallback("onAfterRendering", afterRenderingHook);

    if (typeof PerformanceObserver === "undefined") return;
    try {
      observer = new PerformanceObserver((list) => {
        const url = backendUrl();
        if (!url) return;
        for (const entry of list.getEntries()) {
          if (entry.name === url) acceptEntry(entry);
        }
      });
      // buffered: entries recorded before this observer existed (the app
      // start roundtrip fires before Component.init finishes) are replayed.
      observer.observe({ type: "resource", buffered: true });
    } catch {
      // No resource observation available - the history still records
      // every roundtrip, only without timing and response sizes.
      observer = null;
    }
  }

  function uninstall() {
    if (!installed) return;
    installed = false;
    Lib.unregisterCallback("onAfterRendering", afterRenderingHook);
    afterRenderingHook = null;
    if (observer) {
      try {
        observer.disconnect();
      } catch {
        // already gone
      }
      observer = null;
    }
    records = [];
    unpaired = [];
    payloadBytes = 0;
    nextSeq = 1;
    lastEntryStart = -1;
  }

  function getRecords() {
    flushStaleUnpaired();
    return records;
  }

  // ------------------------------------------------------------------
  // Text rendering for the developer tools tabs. Plain text rather than a
  // control tree: it drops straight into the existing CodeEditor and into
  // the Export blob, so one implementation serves both.
  // ------------------------------------------------------------------

  function pad(value, width, right) {
    const text = value === null || value === undefined ? "-" : String(value);
    if (text.length >= width) return text;
    const fill = " ".repeat(width - text.length);
    return right ? fill + text : text + fill;
  }

  function formatBytes(bytes) {
    if (bytes === null || bytes === undefined) return "-";
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  function formatMs(ms) {
    return ms === null || ms === undefined ? "-" : `${ms} ms`;
  }

  // Short form of a draft id: the ids are 32-character UUIDs and only the
  // tail is needed to tell two of them apart in a list.
  function shortId(id) {
    if (!id) return "-";
    return id.length > 8 ? `..${id.slice(-6)}` : id;
  }

  // Aggregate the recorded roundtrips into the handful of numbers that
  // answer "is this app slow, and where". A per-row table alone does not:
  // spotting that the average backend time is fine but ONE event is a
  // second means reading 50 rows by eye.
  function summaryLines(list) {
    const timed = list.filter((r) => r.backendMs !== null);
    if (!timed.length) return [];
    const out = ["Summary"];
    const backend = timed.map((r) => r.backendMs);
    const avg = Math.round(backend.reduce((a, b) => a + b, 0) / backend.length);
    const slowest = timed.reduce((a, b) => (b.backendMs > a.backendMs ? b : a));
    out.push(
      `  Backend: avg ${avg} ms over ${timed.length} roundtrip(s),` +
        ` slowest #${slowest.seq} ${slowest.event || "(start)"}` +
        ` at ${slowest.backendMs} ms`,
    );
    const sized = list.filter((r) => r.respBytes !== null);
    if (sized.length) {
      const biggest = sized.reduce((a, b) =>
        b.respBytes > a.respBytes ? b : a,
      );
      const total = sized.reduce((sum, r) => sum + r.respBytes, 0);
      out.push(
        `  Response: ${formatBytes(total)} total,` +
          ` largest #${biggest.seq} ${biggest.event || "(start)"}` +
          ` at ${formatBytes(biggest.respBytes)}`,
      );
    }
    const failed = list.filter((r) => !r.rendered).length;
    if (failed) {
      out.push(`  ${failed} roundtrip(s) never reached the render phase.`);
    }
    return out;
  }

  function formatHistory() {
    const list = getRecords();
    const lines = [];
    lines.push(
      `Roundtrip history - ${list.length} of max ${MAX_RECORDS} records`,
    );
    lines.push(
      `Payload recording: ${isRecordingPayloads() ? "ON" : "OFF"}` +
        ` (retained ${formatBytes(payloadBytes)} of ` +
        `${formatBytes(PAYLOAD_BUDGET_BYTES)} budget)`,
    );
    if (!isRecordingPayloads()) {
      lines.push(
        `Switch "Record Payloads" on to keep request/response bodies and` +
          ` enable the Model Diff tab.`,
      );
    }
    lines.push("");
    if (!list.length) {
      lines.push("(no roundtrip recorded yet)");
      return lines.join("\n");
    }

    lines.push(
      pad("#", 5) +
        pad("TIME", 14) +
        pad("EVENT", 22) +
        pad("TOTAL", 10, true) +
        pad("BACKEND", 10, true) +
        pad("RENDER", 10, true) +
        pad("REQ", 10, true) +
        pad("RESP", 10, true) +
        "  " +
        pad("DRAFT", 10) +
        pad("ACT", 8) +
        "PAYLOAD",
    );
    lines.push("-".repeat(118));

    for (const record of list) {
      // ISO timestamp -> "HH:MM:SS.mmm", the part that matters when
      // correlating with a backend trace.
      const time = record.ts.slice(11, 23);
      const actions = `${record.systemActions}/${record.customActions}`;
      let payload = "-";
      if (record.request || record.response) payload = "kept";
      else if (record.payloadEvicted) payload = "evicted";
      lines.push(
        pad(record.seq, 5) +
          pad(time, 14) +
          pad(record.rendered ? record.event || "(start)" : "(no render)", 22) +
          pad(formatMs(record.totalMs), 10, true) +
          pad(formatMs(record.backendMs), 10, true) +
          pad(formatMs(record.renderMs), 10, true) +
          pad(formatBytes(record.reqBytes), 10, true) +
          pad(formatBytes(record.respBytes), 10, true) +
          "  " +
          pad(shortId(record.idReceived), 10) +
          pad(actions, 8) +
          payload,
      );
    }

    lines.push("");
    lines.push(...summaryLines(list));
    lines.push("");
    lines.push(
      "TOTAL = request start to rendered, BACKEND = network + ABAP," +
        " RENDER = response end to rendered.",
    );
    lines.push(
      "ACT = system/custom action counts. A '(no render)' row is a" +
        " roundtrip that never reached the render phase",
    );
    lines.push(
      "(error response, aborted request, or a parallel request whose" +
        " result was discarded as stale).",
    );
    return lines.join("\n");
  }

  // ------------------------------------------------------------------
  // Model diff between the two most recent recorded responses.
  // ------------------------------------------------------------------

  function isPlainObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
  }

  function renderValue(value) {
    let text;
    if (value === undefined) return "(absent)";
    if (value === null) return "null";
    if (typeof value === "object") {
      try {
        text = JSON.stringify(value);
      } catch {
        text = String(value);
      }
    } else {
      text = String(value);
    }
    if (text.length > MAX_DIFF_VALUE_CHARS) {
      return `${text.slice(0, MAX_DIFF_VALUE_CHARS)}... (${text.length} chars)`;
    }
    return text;
  }

  // Walk two model trees in parallel and collect the differing paths.
  // Arrays are compared by index - a table row inserted at the top does
  // report every following row as changed, which is the honest answer for
  // a model the backend rebuilds wholesale anyway.
  function collectDiff(before, after, path, out, depth) {
    if (out.length >= MAX_DIFF_ENTRIES) return;
    if (before === after) return;
    if (depth > MAX_DIFF_DEPTH) {
      out.push({ path, type: "changed", before: "(too deep)", after: "" });
      return;
    }

    const bothObjects = isPlainObject(before) && isPlainObject(after);
    const bothArrays = Array.isArray(before) && Array.isArray(after);

    if (bothObjects) {
      const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
      for (const key of keys) {
        collectDiff(before[key], after[key], `${path}/${key}`, out, depth + 1);
      }
      return;
    }

    if (bothArrays) {
      const length = Math.max(before.length, after.length);
      for (let i = 0; i < length; i++) {
        collectDiff(before[i], after[i], `${path}/${i}`, out, depth + 1);
      }
      return;
    }

    if (before === undefined) {
      out.push({ path, type: "added", before: undefined, after });
      return;
    }
    if (after === undefined) {
      out.push({ path, type: "removed", before, after: undefined });
      return;
    }
    out.push({ path, type: "changed", before, after });
  }

  // The two most recent records that actually carry a response payload.
  function lastTwoResponses() {
    const withPayload = records.filter((record) => record.response);
    if (withPayload.length < 2) return null;
    return withPayload.slice(-2);
  }

  function formatModelDiff() {
    if (!isRecordingPayloads()) {
      return (
        "Model diff needs payload recording.\n\n" +
        'Switch "Record Payloads" on in the dialog footer, then trigger at' +
        " least two roundtrips - the diff compares the MODEL of the two most\n" +
        "recently recorded responses."
      );
    }
    const pair = lastTwoResponses();
    if (!pair) {
      return (
        "Not enough recorded responses yet - the diff needs two.\n\n" +
        "Trigger another roundtrip and reopen this tab."
      );
    }
    const [previous, current] = pair;
    const out = [];
    collectDiff(previous.response?.MODEL, current.response?.MODEL, "", out, 0);

    const header = [
      `Model diff: roundtrip #${previous.seq} (${previous.event || "(start)"})` +
        ` -> #${current.seq} (${current.event || "(start)"})`,
      "",
    ];
    if (!out.length) {
      header.push("(the two responses carry an identical MODEL)");
      return header.join("\n");
    }
    header.push(
      `${out.length}${out.length >= MAX_DIFF_ENTRIES ? "+" : ""}` +
        ` differing path(s):`,
    );
    header.push("");
    for (const entry of out) {
      const path = entry.path || "/";
      if (entry.type === "added") {
        header.push(`+ ${path}`);
        header.push(`    ${renderValue(entry.after)}`);
      } else if (entry.type === "removed") {
        header.push(`- ${path}`);
        header.push(`    ${renderValue(entry.before)}`);
      } else {
        header.push(`~ ${path}`);
        header.push(`    before: ${renderValue(entry.before)}`);
        header.push(`    after:  ${renderValue(entry.after)}`);
      }
    }
    if (out.length >= MAX_DIFF_ENTRIES) {
      header.push("");
      header.push(`(stopped after ${MAX_DIFF_ENTRIES} differences)`);
    }
    return header.join("\n");
  }

  // The recorded history as JSON, for download. With payload recording on
  // this carries the actual request/response bodies, which is what makes a
  // bug reproducible for someone who cannot click through the app - the
  // shareable half of "record and replay". Replaying it back INTO a system
  // is deliberately not offered: the recorded requests reference draft ids
  // that only exist in the session that produced them, and re-sending them
  // would drive real backend state.
  function exportJson() {
    const payload = {
      exportedAt: new Date().toISOString(),
      payloadsRecorded: isRecordingPayloads(),
      records: getRecords(),
    };
    try {
      return JSON.stringify(payload, null, 2);
    } catch {
      // A payload that cannot be serialized must not lose the whole
      // export - fall back to the metadata, which is always plain data.
      const metaOnly = records.map((record) => {
        const copy = { ...record };
        delete copy.request;
        delete copy.response;
        return copy;
      });
      return JSON.stringify({ ...payload, records: metaOnly }, null, 2);
    }
  }

  return {
    install,
    uninstall,
    getRecords,
    exportJson,
    isRecordingPayloads,
    setRecordingPayloads,
    formatHistory,
    formatModelDiff,
    // exposed for the unit specs
    _internals: { MAX_RECORDS, PAYLOAD_BUDGET_BYTES, PAYLOAD_FLAG_KEY },
  };
});
