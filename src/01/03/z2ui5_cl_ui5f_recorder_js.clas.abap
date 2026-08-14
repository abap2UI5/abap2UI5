* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_ui5f_recorder_js DEFINITION
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


CLASS z2ui5_cl_ui5f_recorder_js IMPLEMENTATION.

  METHOD get.

    result = `// Roundtrip recorder of the developer tools.` && |\n| &&
             `//` && |\n| &&
             `// SELF-CONTAINED BY DESIGN: this module is the ONLY place that knows how` && |\n| &&
             `// roundtrip history is collected. It observes the framework from the` && |\n| &&
             `// outside - through the public callback arrays (Lib.registerCallback) and` && |\n| &&
             `// the browser's Resource Timing API - and never asks the framework to` && |\n| &&
             `// carry anything for it. Server.js, View1.controller.js, AppState.js and` && |\n| &&
             `// Lib.js contain no recorder code and no recorder-shaped hooks; the whole` && |\n| &&
             `// feature can be deleted by removing this file and its tabs in` && |\n| &&
             `// core/devtools/DeveloperTools.js - core/devtools/DevTools.js is what` && |\n| &&
             `// installs it, and that is the framework's only entry point here.` && |\n| &&
             `//` && |\n| &&
             `// Two tiers, because they cost very different amounts:` && |\n| &&
             `//` && |\n| &&
             `//  TIER 1 - metadata, always on. One small record per roundtrip: timing,` && |\n| &&
             `//    byte sizes, event name, draft id, action counts. A record is a handful` && |\n| &&
             `//    of numbers and short strings, and MAX_RECORDS caps the ring - the` && |\n| &&
             `//    whole history stays in the tens of kilobytes, the same order of` && |\n| &&
             `//    magnitude the error log (Lib.MAX_ERRORS) already keeps.` && |\n| &&
             `//` && |\n| &&
             `//  TIER 2 - payloads, opt-in. The request body and the response object of` && |\n| &&
             `//    each roundtrip. These are the expensive part: a model with a few` && |\n| &&
             `//    thousand table rows is megabytes of parsed objects, so retaining 50 of` && |\n| &&
             `//    them is not something a production session may pay for silently. Off` && |\n| &&
             `//    unless the developer switches it on (sessionStorage, so it survives a` && |\n| &&
             `//    reload), and capped by a BYTE BUDGET rather than a record count - a` && |\n| &&
             `//    "last 20 roundtrips" limit is meaningless when one entry weighs 8 MB.` && |\n| &&
             `//` && |\n| &&
             `// Why payloads can be kept as plain REFERENCES (no structuredClone):` && |\n| &&
             `// actions/Slots.js hands the response's MODEL object straight to` && |\n| &&
             `// JSONModel.setData(), so the live model data IS response.MODEL and the` && |\n| &&
             `// two-way binding mutates it in place. That only lasts until the NEXT` && |\n| &&
             `// roundtrip calls setData() with the new response's MODEL - from that` && |\n| &&
             `// moment the old object is unbound and frozen. So every record except the` && |\n| &&
             `// newest is stable, and the newest one is the current state the existing` && |\n| &&
             `// tabs show anyway. Retention is the only cost; there is no copying.` && |\n| &&
             `sap.ui.define(["z2ui5/core/AppState", "z2ui5/core/Lib"], (AppState, Lib) => {` && |\n| &&
             `  "use strict";` && |\n| &&
             `` && |\n| &&
             `  // Tier 1 ring size. 50 records of metadata are far below the error log's` && |\n| &&
             `  // footprint and cover a long debugging session.` && |\n| &&
             `  const MAX_RECORDS = 50;` && |\n| &&
             `` && |\n| &&
             `  // Tier 2 ceiling, in bytes of measured payload (see recordBytes below).` && |\n| &&
             `  // Oldest payloads are dropped first; their metadata records survive, so` && |\n| &&
             `  // the history stays complete and only the deep content thins out.` && |\n| &&
             `  const PAYLOAD_BUDGET_BYTES = 2 * 1024 * 1024;` && |\n| &&
             `` && |\n| &&
             `  // sessionStorage key of the Tier 2 opt-in. sessionStorage (not local)` && |\n| &&
             `  // so the switch survives a reload but not the tab - a developer cannot` && |\n| &&
             `  // leave payload recording on for a colleague by accident.` && |\n| &&
             `  const PAYLOAD_FLAG_KEY = "z2ui5.devtools.recordPayloads";` && |\n| &&
             `` && |\n| &&
             `  // sessionStorage key of the metadata carried across a page reload, and` && |\n| &&
             `  // how many records travel. When an app dies and the user reloads, the` && |\n| &&
             `  // evidence is exactly what a fresh page throws away - so the METADATA` && |\n| &&
             `  // (never the payloads, which is what makes this affordable) is written` && |\n| &&
             `  // on pagehide and read back on install, flagged as a previous load.` && |\n| &&
             `  const RELOAD_KEY = "z2ui5.devtools.history";` && |\n| &&
             `  const RELOAD_MAX_RECORDS = 30;` && |\n| &&
             `` && |\n| &&
             `  // A network observation is paired with the render that followed it only` && |\n| &&
             `  // if the render came after the response ended. Roundtrips whose entry is` && |\n| &&
             `  // older than this (and never got a render) are flushed as "no render" -` && |\n| &&
             `  // an error response, an abort, or a superseded parallel request.` && |\n| &&
             `  const UNPAIRED_FLUSH_MS = 5000;` && |\n| &&
             `` && |\n| &&
             `  // Backend messages are kept as TIER 1 metadata, not as payloads: the` && |\n| &&
             `  // text of a toast or message box is a short string, and "what did the` && |\n| &&
             `  // app tell the user three roundtrips ago" is exactly the kind of` && |\n| &&
             `  // question the history exists for. Capped so a pathological message` && |\n| &&
             `  // cannot grow a record without bound.` && |\n| &&
             `  const MAX_MESSAGE_CHARS = 500;` && |\n| &&
             `` && |\n| &&
             `  // Rendering caps for the history / diff text output.` && |\n| &&
             `  const MAX_DIFF_ENTRIES = 200;` && |\n| &&
             `  const MAX_DIFF_DEPTH = 12;` && |\n| &&
             `  const MAX_DIFF_VALUE_CHARS = 120;` && |\n| &&
             `` && |\n| &&
             `  // Oldest first. Each entry:` && |\n| &&
             `  //   seq          running number, 1-based` && |\n| &&
             `  //   ts           wall-clock ISO timestamp of the render` && |\n| &&
             `  //   event        the EVENT name the request carried ("" for app start)` && |\n| &&
             `  //   idSent       draft id sent with the request` && |\n| &&
             `  //   idReceived   draft id the response returned` && |\n| &&
             `  //   app          app class name the response named` && |\n| &&
             `  //   reqBytes     serialized request size, null when not measured` && |\n| &&
             `  //   respBytes    decoded response size, null when Resource Timing is absent` && |\n| &&
             `  //   backendMs    request start -> response end (network + ABAP)` && |\n| &&
             `  //   renderMs     response end -> rendered, null when unpaired` && |\n| &&
             `  //   totalMs      request start -> rendered` && |\n| &&
             `  //   systemActions / customActions   action counts of the response` && |\n| &&
             `  //   rendered     false for a roundtrip that never reached the render phase` && |\n| &&
             `  //   request / response   Tier 2 payload references, null when not kept` && |\n| &&
             `  let records = [];` && |\n| &&
             `` && |\n| &&
             `  // Running number handed to the next record. Not records.length: the ring` && |\n| &&
             `  // drops old entries, and the numbers must stay stable across evictions.` && |\n| &&
             `  let nextSeq = 1;` && |\n| &&
             `` && |\n| &&
             `  // Network observations not yet paired with a render, oldest first. Filled` && |\n| &&
             `  // by the PerformanceObserver and the synchronous sweep, drained by` && |\n| &&
             `  // onAfterRendering. Each: { start, end, bytes }.` && |\n| &&
             `  let unpaired = [];` && |\n| &&
             `` && |\n| &&
             `  // High-water mark of consumed Resource Timing entries. The observer and` && |\n| &&
             `  // the sweep both feed ``unpaired``, so the same entry must not be taken` && |\n| &&
             `  // twice; entries arrive in chronological order from both sources, which` && |\n| &&
             `  // makes a single startTime watermark enough.` && |\n| &&
             `  let lastEntryStart = -1;` && |\n| &&
             `` && |\n| &&
             `  // Sum of reqBytes + respBytes over the records that still hold payloads.` && |\n| &&
             `  // The measured sizes double as the budget accounting - no separate` && |\n| &&
             `  // estimation pass is needed.` && |\n| &&
             `  let payloadBytes = 0;` && |\n| &&
             `` && |\n| &&
             `  let observer = null;` && |\n| &&
             `  let installed = false;` && |\n| &&
             `  let afterRenderingHook = null;` && |\n| &&
             `  let onPageHide = null;` && |\n| &&
             `` && |\n| &&
             `  // Absolute form of the backend endpoint, so it can be compared against` && |\n| &&
             `  // the absolute names Resource Timing reports. Recomputed per call: the` && |\n| &&
             `  // url global is set by the backend page and may not exist yet at install` && |\n| &&
             `  // time. Returns "" when unknown or unparsable.` && |\n| &&
             `  function backendUrl() {` && |\n| &&
             `    const url = AppState.getGlobal("url");` && |\n| &&
             `    if (!url) return "";` && |\n| &&
             `    try {` && |\n| &&
             `      return new URL(url, window.location.href).href;` && |\n| &&
             `    } catch {` && |\n| &&
             `      return "";` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function now() {` && |\n| &&
             `    return typeof performance !== "undefined" && performance.now` && |\n| &&
             `      ? performance.now()` && |\n| &&
             `      : 0;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Accept one Resource Timing entry as a roundtrip observation. Entries` && |\n| &&
             `  // older than the watermark were already taken (the observer and the sweep` && |\n| &&
             `  // overlap on purpose - see lastEntryStart).` && |\n| &&
             `  function acceptEntry(entry) {` && |\n| &&
             `    if (!entry || entry.startTime <= lastEntryStart) return;` && |\n| &&
             `    lastEntryStart = entry.startTime;` && |\n| &&
             `    unpaired.push({` && |\n| &&
             `      start: entry.startTime,` && |\n| &&
             `      end: entry.responseEnd || entry.startTime,` && |\n| &&
             `      // decodedBodySize is the uncompressed payload - the number that` && |\n| &&
             `      // answers "is this response too big", which transferSize (compressed,` && |\n| &&
             `      // 0 from cache) does not. 0 means "not exposed", reported as null.` && |\n| &&
             `      bytes: entry.decodedBodySize || null,` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Pull any Resource Timing entries for the backend endpoint that the` && |\n| &&
             `  // observer has not delivered yet. The observer's callback is queued as a` && |\n| &&
             `  // task and may well run AFTER the render it belongs to, so the render` && |\n| &&
             `  // path sweeps synchronously first and ordering stops mattering.` && |\n| &&
             `  //` && |\n| &&
             `  // The sweep alone would not be enough: once the browser's resource buffer` && |\n| &&
             `  // is full it silently drops NEW entries, which a long-running SPA reaches.` && |\n| &&
             `  // PerformanceObserver delivery is not bound by that buffer, so the two` && |\n| &&
             `  // together cover both the ordering and the overflow case.` && |\n| &&
             `  function sweepEntries() {` && |\n| &&
             `    if (typeof performance === "undefined" || !performance.getEntriesByName) {` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    const url = backendUrl();` && |\n| &&
             `    if (!url) return;` && |\n| &&
             `    let entries;` && |\n| &&
             `    try {` && |\n| &&
             `      entries = performance.getEntriesByName(url, "resource");` && |\n| &&
             `    } catch {` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    for (const entry of entries) acceptEntry(entry);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Take the network observation belonging to a render that happened at` && |\n| &&
             `  // ``tRendered``: the newest one that finished before it. Everything older` && |\n| &&
             `  // than that never rendered - those are flushed as their own records so a` && |\n| &&
             `  // failed or superseded roundtrip stays visible in the history.` && |\n| &&
             `  function takeNetworkFor(tRendered) {` && |\n| &&
             `    let index = -1;` && |\n| &&
             `    for (let i = unpaired.length - 1; i >= 0; i--) {` && |\n| &&
             `      if (unpaired[i].end <= tRendered) {` && |\n| &&
             `        index = i;` && |\n| &&
             `        break;` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `    if (index === -1) return null;` && |\n| &&
             `    const stale = unpaired.slice(0, index);` && |\n| &&
             `    const match = unpaired[index];` && |\n| &&
             `    unpaired = unpaired.slice(index + 1);` && |\n| &&
             `    for (const entry of stale) pushUnrendered(entry);` && |\n| &&
             `    return match;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Flush network observations that never got a render and are old enough` && |\n| &&
             `  // that none is coming. Called from the render path and when the history` && |\n| &&
             `  // is read, so a failing roundtrip shows up without needing a next one.` && |\n| &&
             `  function flushStaleUnpaired() {` && |\n| &&
             `    if (!unpaired.length) return;` && |\n| &&
             `    const cutoff = now() - UNPAIRED_FLUSH_MS;` && |\n| &&
             `    const stale = unpaired.filter((entry) => entry.end < cutoff);` && |\n| &&
             `    if (!stale.length) return;` && |\n| &&
             `    unpaired = unpaired.filter((entry) => entry.end >= cutoff);` && |\n| &&
             `    for (const entry of stale) pushUnrendered(entry);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // A roundtrip observed on the wire that never reached the render phase:` && |\n| &&
             `  // an error response, an aborted request, or a parallel request whose` && |\n| &&
             `  // result was discarded as stale. Worth a record of its own - these are` && |\n| &&
             `  // exactly the roundtrips a developer is looking for.` && |\n| &&
             `  function pushUnrendered(entry) {` && |\n| &&
             `    pushRecord({` && |\n| &&
             `      ts: new Date().toISOString(),` && |\n| &&
             `      event: "",` && |\n| &&
             `      idSent: "",` && |\n| &&
             `      idReceived: "",` && |\n| &&
             `      app: "",` && |\n| &&
             `      reqBytes: null,` && |\n| &&
             `      respBytes: entry.bytes,` && |\n| &&
             `      backendMs: Math.round(entry.end - entry.start),` && |\n| &&
             `      renderMs: null,` && |\n| &&
             `      totalMs: null,` && |\n| &&
             `      systemActions: 0,` && |\n| &&
             `      customActions: 0,` && |\n| &&
             `      messages: [],` && |\n| &&
             `      rendered: false,` && |\n| &&
             `      request: null,` && |\n| &&
             `      response: null,` && |\n| &&
             `    });` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Pull the user-visible backend messages out of a response's app action` && |\n| &&
             `  // list. A message travels as a whitelisted global call` && |\n| &&
             `  // ["CONTROL_GLOBAL", "MESSAGE_TOAST"|"MESSAGE_BOX", <method>, <text>, ...]` && |\n| &&
             `  // (see core/actions/ControlCall.js); the legacy raw-string entries in` && |\n| &&
             `  // T_CUSTOM carry no structured message and are skipped.` && |\n| &&
             `  function extractMessages(response) {` && |\n| &&
             `    const custom = response?.S_FRONT?.S_ACTION?.T_CUSTOM;` && |\n| &&
             `    if (!Array.isArray(custom)) return [];` && |\n| &&
             `    const out = [];` && |\n| &&
             `    for (const item of custom) {` && |\n| &&
             `      if (!Array.isArray(item) || item[0] !== "CONTROL_GLOBAL") continue;` && |\n| &&
             `      const target = item[1];` && |\n| &&
             `      if (target !== "MESSAGE_TOAST" && target !== "MESSAGE_BOX") continue;` && |\n| &&
             `      let text = typeof item[3] === "string" ? item[3] : "";` && |\n| &&
             `      if (text.length > MAX_MESSAGE_CHARS) {` && |\n| &&
             `        text = ``${text.slice(0, MAX_MESSAGE_CHARS)}...``;` && |\n| &&
             `      }` && |\n| &&
             `      out.push({ target, method: item[2] || "", text });` && |\n| &&
             `    }` && |\n| &&
             `    return out;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Measured weight of a record's retained payloads. Sizes that were not` && |\n| &&
             `  // measured count as 0 - the budget then errs towards keeping more, which` && |\n| &&
             `  // is the harmless direction for a diagnostic buffer.` && |\n| &&
             `  function recordBytes(record) {` && |\n| &&
             `    if (!record.request && !record.response) return 0;` && |\n| &&
             `    return (record.reqBytes || 0) + (record.respBytes || 0);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Drop payloads from the oldest records until the retained set fits the` && |\n| &&
             `  // budget. The records themselves stay - the history keeps showing that` && |\n| &&
             `  // roundtrip 3 took 900 ms and sent 4 MB, only its content is gone.` && |\n| &&
             `  function enforcePayloadBudget() {` && |\n| &&
             `    for (const record of records) {` && |\n| &&
             `      if (payloadBytes <= PAYLOAD_BUDGET_BYTES) return;` && |\n| &&
             `      if (!record.request && !record.response) continue;` && |\n| &&
             `      payloadBytes -= recordBytes(record);` && |\n| &&
             `      record.request = null;` && |\n| &&
             `      record.response = null;` && |\n| &&
             `      record.payloadEvicted = true;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function pushRecord(record) {` && |\n| &&
             `    record.seq = nextSeq++;` && |\n| &&
             `    records.push(record);` && |\n| &&
             `    payloadBytes += recordBytes(record);` && |\n| &&
             `    while (records.length > MAX_RECORDS) {` && |\n| &&
             `      const dropped = records.shift();` && |\n| &&
             `      payloadBytes -= recordBytes(dropped);` && |\n| &&
             `    }` && |\n| &&
             `    enforcePayloadBudget();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // True when the developer switched Tier 2 on. Guarded: sessionStorage` && |\n| &&
             `  // throws in some embedded/privacy configurations, and a diagnostic tool` && |\n| &&
             `  // must never be the thing that breaks the app.` && |\n| &&
             `  function isRecordingPayloads() {` && |\n| &&
             `    try {` && |\n| &&
             `      return window.sessionStorage?.getItem(PAYLOAD_FLAG_KEY) === "X";` && |\n| &&
             `    } catch {` && |\n| &&
             `      return false;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function setRecordingPayloads(enabled) {` && |\n| &&
             `    try {` && |\n| &&
             `      if (enabled) {` && |\n| &&
             `        window.sessionStorage?.setItem(PAYLOAD_FLAG_KEY, "X");` && |\n| &&
             `      } else {` && |\n| &&
             `        window.sessionStorage?.removeItem(PAYLOAD_FLAG_KEY);` && |\n| &&
             `      }` && |\n| &&
             `    } catch {` && |\n| &&
             `      // storage unavailable - the switch then simply does not persist` && |\n| &&
             `    }` && |\n| &&
             `    if (!enabled) dropAllPayloads();` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function dropAllPayloads() {` && |\n| &&
             `    for (const record of records) {` && |\n| &&
             `      record.request = null;` && |\n| &&
             `      record.response = null;` && |\n| &&
             `    }` && |\n| &&
             `    payloadBytes = 0;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Serialized size of the request body. This is the one number the` && |\n| &&
             `  // recorder cannot get for free: Resource Timing exposes no request body` && |\n| &&
             `  // size, so the body is serialized a second time here (Server.readHttp` && |\n| &&
             `  // does the first one for the actual send). It is a DELTA - only the model` && |\n| &&
             `  // paths the user edited travel - so the common case is a few hundred` && |\n| &&
             `  // bytes. Returns null if it cannot be serialized.` && |\n| &&
             `  function measureRequest(oBody) {` && |\n| &&
             `    if (!oBody) return null;` && |\n| &&
             `    try {` && |\n| &&
             `      return JSON.stringify({ value: oBody }).length;` && |\n| &&
             `    } catch {` && |\n| &&
             `      return null;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Completes one roundtrip: called once the response has been processed` && |\n| &&
             `  // and its view is rendered (the onAfterRendering callback array, which` && |\n| &&
             `  // View1._processAfterRendering runs at the end of every roundtrip -` && |\n| &&
             `  // including the app start and Back/Forward route restores, which never` && |\n| &&
             `  // pass through eB and therefore have no other observable entry point).` && |\n| &&
             `  function onAfterRendering() {` && |\n| &&
             `    try {` && |\n| &&
             `      const state = AppState.state;` && |\n| &&
             `      const tRendered = now();` && |\n| &&
             `      sweepEntries();` && |\n| &&
             `      const net = takeNetworkFor(tRendered);` && |\n| &&
             `      const response = state.responseData;` && |\n| &&
             `      const sFront = response?.S_FRONT;` && |\n| &&
             `      const keepPayloads = isRecordingPayloads();` && |\n| &&
             `      const reqBytes = measureRequest(state.oBody);` && |\n| &&
             `` && |\n| &&
             `      pushRecord({` && |\n| &&
             `        ts: new Date().toISOString(),` && |\n| &&
             `        event: state.oBody?.S_FRONT?.EVENT || "",` && |\n| &&
             `        idSent: state.oBody?.S_FRONT?.ID || "",` && |\n| &&
             `        idReceived: sFront?.ID || "",` && |\n| &&
             `        app: sFront?.APP || "",` && |\n| &&
             `        reqBytes: reqBytes,` && |\n| &&
             `        respBytes: net?.bytes ?? null,` && |\n| &&
             `        backendMs: net ? Math.round(net.end - net.start) : null,` && |\n| &&
             `        renderMs: net ? Math.round(tRendered - net.end) : null,` && |\n| &&
             `        totalMs: net ? Math.round(tRendered - net.start) : null,` && |\n| &&
             `        systemActions: sFront?.S_ACTION?.T_SYSTEM?.length || 0,` && |\n| &&
             `        customActions: sFront?.S_ACTION?.T_CUSTOM?.length || 0,` && |\n| &&
             `        // Tier 1 on purpose - see MAX_MESSAGE_CHARS.` && |\n| &&
             `        messages: extractMessages(response),` && |\n| &&
             `        rendered: true,` && |\n| &&
             `        // Plain references, never clones - see the module header for why` && |\n| &&
             `        // that is safe and why it costs nothing but retention.` && |\n| &&
             `        request: keepPayloads ? state.oBody : null,` && |\n| &&
             `        response: keepPayloads ? response : null,` && |\n| &&
             `      });` && |\n| &&
             `      flushStaleUnpaired();` && |\n| &&
             `    } catch (e) {` && |\n| &&
             `      // The recorder is a diagnostic aid; it may never take the app down.` && |\n| &&
             `      Lib.logError("DevTools Recorder: onAfterRendering failed", e);` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Write the metadata of the newest records away for the next page load.` && |\n| &&
             `  // Payload references are dropped on purpose: they are the expensive part` && |\n| &&
             `  // and would not survive serialization usefully anyway.` && |\n| &&
             `  function persist() {` && |\n| &&
             `    try {` && |\n| &&
             `      const slim = records.slice(-RELOAD_MAX_RECORDS).map((record) => {` && |\n| &&
             `        const copy = { ...record, previousLoad: true };` && |\n| &&
             `        delete copy.request;` && |\n| &&
             `        delete copy.response;` && |\n| &&
             `        return copy;` && |\n| &&
             `      });` && |\n| &&
             `      if (!slim.length) return;` && |\n| &&
             `      window.sessionStorage?.setItem(RELOAD_KEY, JSON.stringify(slim));` && |\n| &&
             `    } catch {` && |\n| &&
             `      // storage full or unavailable - the history simply does not survive` && |\n| &&
             `    }` && |\n|.
    result = result &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Adopt what the previous page load left behind, oldest first, so the` && |\n| &&
             `  // history reads as one timeline across the reload.` && |\n| &&
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
             `      if (!Array.isArray(parsed)) return;` && |\n| &&
             `      records = parsed.slice(-RELOAD_MAX_RECORDS);` && |\n| &&
             `      // Continue the numbering after the restored ones so the two halves` && |\n| &&
             `      // of the timeline cannot collide.` && |\n| &&
             `      nextSeq = (records[records.length - 1]?.seq || 0) + 1;` && |\n| &&
             `    } catch {` && |\n| &&
             `      records = [];` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function install() {` && |\n| &&
             `    if (installed) return;` && |\n| &&
             `    installed = true;` && |\n| &&
             `    restore();` && |\n| &&
             `    afterRenderingHook = onAfterRendering;` && |\n| &&
             `    Lib.registerCallback("onAfterRendering", afterRenderingHook);` && |\n| &&
             `` && |\n| &&
             `    // "pagehide", not "beforeunload" - same reasoning as Component.js: it` && |\n| &&
             `    // is the event that fires reliably, iOS Safari included. A browser` && |\n| &&
             `    // killed outright loses the history, which is the accepted limit here.` && |\n| &&
             `    onPageHide = persist;` && |\n| &&
             `    window.addEventListener("pagehide", onPageHide);` && |\n| &&
             `` && |\n| &&
             `    if (typeof PerformanceObserver === "undefined") return;` && |\n| &&
             `    try {` && |\n| &&
             `      observer = new PerformanceObserver((list) => {` && |\n| &&
             `        const url = backendUrl();` && |\n| &&
             `        if (!url) return;` && |\n| &&
             `        for (const entry of list.getEntries()) {` && |\n| &&
             `          if (entry.name === url) acceptEntry(entry);` && |\n| &&
             `        }` && |\n| &&
             `      });` && |\n| &&
             `      // buffered: entries recorded before this observer existed (the app` && |\n| &&
             `      // start roundtrip fires before Component.init finishes) are replayed.` && |\n| &&
             `      observer.observe({ type: "resource", buffered: true });` && |\n| &&
             `    } catch {` && |\n| &&
             `      // No resource observation available - the history still records` && |\n| &&
             `      // every roundtrip, only without timing and response sizes.` && |\n| &&
             `      observer = null;` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function uninstall() {` && |\n| &&
             `    if (!installed) return;` && |\n| &&
             `    installed = false;` && |\n| &&
             `    Lib.unregisterCallback("onAfterRendering", afterRenderingHook);` && |\n| &&
             `    afterRenderingHook = null;` && |\n| &&
             `    if (onPageHide) {` && |\n| &&
             `      window.removeEventListener("pagehide", onPageHide);` && |\n| &&
             `      onPageHide = null;` && |\n| &&
             `    }` && |\n| &&
             `    if (observer) {` && |\n| &&
             `      try {` && |\n| &&
             `        observer.disconnect();` && |\n| &&
             `      } catch {` && |\n| &&
             `        // already gone` && |\n| &&
             `      }` && |\n| &&
             `      observer = null;` && |\n| &&
             `    }` && |\n| &&
             `    records = [];` && |\n| &&
             `    unpaired = [];` && |\n| &&
             `    payloadBytes = 0;` && |\n| &&
             `    nextSeq = 1;` && |\n| &&
             `    lastEntryStart = -1;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function getRecords() {` && |\n| &&
             `    flushStaleUnpaired();` && |\n| &&
             `    return records;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // Text rendering for the developer tools tabs. Plain text rather than a` && |\n| &&
             `  // control tree: it drops straight into the existing CodeEditor and into` && |\n| &&
             `  // the Export blob, so one implementation serves both.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  function pad(value, width, right) {` && |\n| &&
             `    const text = value === null || value === undefined ? "-" : String(value);` && |\n| &&
             `    if (text.length >= width) return text;` && |\n| &&
             `    const fill = " ".repeat(width - text.length);` && |\n| &&
             `    return right ? fill + text : text + fill;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function formatBytes(bytes) {` && |\n| &&
             `    if (bytes === null || bytes === undefined) return "-";` && |\n| &&
             `    if (bytes < 1024) return ``${bytes} B``;` && |\n| &&
             `    if (bytes < 1024 * 1024) return ``${Math.round(bytes / 1024)} KB``;` && |\n| &&
             `    return ``${(bytes / (1024 * 1024)).toFixed(1)} MB``;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function formatMs(ms) {` && |\n| &&
             `    return ms === null || ms === undefined ? "-" : ``${ms} ms``;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Short form of a draft id: the ids are 32-character UUIDs and only the` && |\n| &&
             `  // tail is needed to tell two of them apart in a list.` && |\n| &&
             `  function shortId(id) {` && |\n| &&
             `    if (!id) return "-";` && |\n| &&
             `    return id.length > 8 ? ``..${id.slice(-6)}`` : id;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The app navigation as OBSERVED in this session. The real draft chain` && |\n| &&
             `  // (id_prev / id_prev_app_stack) lives in the backend and never reaches` && |\n| &&
             `  // the browser, but every app switch is visible here: the response names` && |\n| &&
             `  // its app, so a change between two consecutive records is a navigation.` && |\n| &&
             `  // Answers "how did I get here" and, with the draft ids, why` && |\n| &&
             `  // nav_app_leave( ) returns where it does.` && |\n| &&
             `  function navigationLines(list) {` && |\n| &&
             `    const hops = [];` && |\n| &&
             `    let previous = null;` && |\n| &&
             `    for (const record of list) {` && |\n| &&
             `      if (!record.app || record.app === previous) continue;` && |\n| &&
             `      hops.push({` && |\n| &&
             `        seq: record.seq,` && |\n| &&
             `        from: previous,` && |\n| &&
             `        to: record.app,` && |\n| &&
             `        event: record.event,` && |\n| &&
             `        draft: record.idReceived,` && |\n| &&
             `      });` && |\n| &&
             `      previous = record.app;` && |\n| &&
             `    }` && |\n| &&
             `    if (hops.length < 2) return [];` && |\n| &&
             `    const out = ["App navigation observed this session"];` && |\n| &&
             `    for (const hop of hops) {` && |\n| &&
             `      out.push(` && |\n| &&
             `        ``  #${String(hop.seq).padEnd(4)}`` +` && |\n| &&
             `          ``${hop.from ? ``${hop.from} -> `` : "start "}${hop.to}`` +` && |\n| &&
             `          ``${hop.event ? ``   via ${hop.event}`` : ""}`` +` && |\n| &&
             `          ``   draft ${shortId(hop.draft)}``,` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    out.push("");` && |\n| &&
             `    return out;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Aggregate the recorded roundtrips into the handful of numbers that` && |\n| &&
             `  // answer "is this app slow, and where". A per-row table alone does not:` && |\n| &&
             `  // spotting that the average backend time is fine but ONE event is a` && |\n| &&
             `  // second means reading 50 rows by eye.` && |\n| &&
             `  function summaryLines(list) {` && |\n| &&
             `    const timed = list.filter((r) => r.backendMs !== null);` && |\n| &&
             `    if (!timed.length) return [];` && |\n| &&
             `    const out = ["Summary"];` && |\n| &&
             `    const backend = timed.map((r) => r.backendMs);` && |\n| &&
             `    const avg = Math.round(backend.reduce((a, b) => a + b, 0) / backend.length);` && |\n| &&
             `    const slowest = timed.reduce((a, b) => (b.backendMs > a.backendMs ? b : a));` && |\n| &&
             `    out.push(` && |\n| &&
             `      ``  Backend: avg ${avg} ms over ${timed.length} roundtrip(s),`` +` && |\n| &&
             `        `` slowest #${slowest.seq} ${slowest.event || "(start)"}`` +` && |\n| &&
             `        `` at ${slowest.backendMs} ms``,` && |\n| &&
             `    );` && |\n| &&
             `    const sized = list.filter((r) => r.respBytes !== null);` && |\n| &&
             `    if (sized.length) {` && |\n| &&
             `      const biggest = sized.reduce((a, b) =>` && |\n| &&
             `        b.respBytes > a.respBytes ? b : a,` && |\n| &&
             `      );` && |\n| &&
             `      const total = sized.reduce((sum, r) => sum + r.respBytes, 0);` && |\n| &&
             `      out.push(` && |\n| &&
             `        ``  Response: ${formatBytes(total)} total,`` +` && |\n| &&
             `          `` largest #${biggest.seq} ${biggest.event || "(start)"}`` +` && |\n| &&
             `          `` at ${formatBytes(biggest.respBytes)}``,` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    const failed = list.filter((r) => !r.rendered).length;` && |\n| &&
             `    if (failed) {` && |\n| &&
             `      out.push(``  ${failed} roundtrip(s) never reached the render phase.``);` && |\n| &&
             `    }` && |\n| &&
             `    return out;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function formatHistory() {` && |\n| &&
             `    const list = getRecords();` && |\n| &&
             `    const lines = [];` && |\n| &&
             `    lines.push(` && |\n| &&
             `      ``Roundtrip history - ${list.length} of max ${MAX_RECORDS} records``,` && |\n| &&
             `    );` && |\n| &&
             `    lines.push(` && |\n| &&
             `      ``Payload recording: ${isRecordingPayloads() ? "ON" : "OFF"}`` +` && |\n| &&
             `        `` (retained ${formatBytes(payloadBytes)} of `` +` && |\n| &&
             `        ``${formatBytes(PAYLOAD_BUDGET_BYTES)} budget)``,` && |\n| &&
             `    );` && |\n| &&
             `    if (!isRecordingPayloads()) {` && |\n| &&
             `      lines.push(` && |\n| &&
             `        ``Switch "Record Payloads" on to keep request/response bodies and`` +` && |\n| &&
             `          `` enable the Model Diff tab.``,` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    lines.push("");` && |\n| &&
             `    if (!list.length) {` && |\n| &&
             `      lines.push("(no roundtrip recorded yet)");` && |\n| &&
             `      return lines.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    lines.push(` && |\n| &&
             `      pad("#", 5) +` && |\n| &&
             `        pad("TIME", 14) +` && |\n| &&
             `        pad("EVENT", 22) +` && |\n| &&
             `        pad("TOTAL", 10, true) +` && |\n| &&
             `        pad("BACKEND", 10, true) +` && |\n| &&
             `        pad("RENDER", 10, true) +` && |\n| &&
             `        pad("REQ", 10, true) +` && |\n| &&
             `        pad("RESP", 10, true) +` && |\n| &&
             `        "  " +` && |\n| &&
             `        pad("DRAFT", 10) +` && |\n| &&
             `        pad("ACT", 8) +` && |\n| &&
             `        "PAYLOAD",` && |\n| &&
             `    );` && |\n| &&
             `    lines.push("-".repeat(118));` && |\n| &&
             `` && |\n| &&
             `    for (const record of list) {` && |\n| &&
             `      // ISO timestamp -> "HH:MM:SS.mmm", the part that matters when` && |\n| &&
             `      // correlating with a backend trace.` && |\n| &&
             `      const time = record.ts.slice(11, 23);` && |\n| &&
             `      const actions = ``${record.systemActions}/${record.customActions}``;` && |\n| &&
             `      let payload = "-";` && |\n| &&
             `      if (record.request || record.response) payload = "kept";` && |\n| &&
             `      else if (record.payloadEvicted) payload = "evicted";` && |\n| &&
             `      lines.push(` && |\n| &&
             `        pad(record.previousLoad ? ``${record.seq}*`` : record.seq, 5) +` && |\n| &&
             `          pad(time, 14) +` && |\n| &&
             `          pad(record.rendered ? record.event || "(start)" : "(no render)", 22) +` && |\n| &&
             `          pad(formatMs(record.totalMs), 10, true) +` && |\n| &&
             `          pad(formatMs(record.backendMs), 10, true) +` && |\n| &&
             `          pad(formatMs(record.renderMs), 10, true) +` && |\n| &&
             `          pad(formatBytes(record.reqBytes), 10, true) +` && |\n| &&
             `          pad(formatBytes(record.respBytes), 10, true) +` && |\n| &&
             `          "  " +` && |\n| &&
             `          pad(shortId(record.idReceived), 10) +` && |\n| &&
             `          pad(actions, 8) +` && |\n| &&
             `          payload,` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    lines.push("");` && |\n| &&
             `    lines.push(...navigationLines(list));` && |\n| &&
             `    lines.push(...summaryLines(list));` && |\n| &&
             `    lines.push("");` && |\n| &&
             `    lines.push(` && |\n| &&
             `      "TOTAL = request start to rendered, BACKEND = network + ABAP," +` && |\n| &&
             `        " RENDER = response end to rendered.",` && |\n| &&
             `    );` && |\n| &&
             `    lines.push(` && |\n| &&
             `      "ACT = system/custom action counts. A '(no render)' row is a" +` && |\n| &&
             `        " roundtrip that never reached the render phase",` && |\n| &&
             `    );` && |\n| &&
             `    if (list.some((record) => record.previousLoad)) {` && |\n| &&
             `      lines.push(` && |\n| &&
             `        "A '*' after the number marks a roundtrip of the PREVIOUS page" +` && |\n| &&
             `          " load, carried across the reload.",` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    lines.push(` && |\n| &&
             `      "(error response, aborted request, or a parallel request whose" +` && |\n| &&
             `        " result was discarded as stale).",` && |\n| &&
             `    );` && |\n| &&
             `    return lines.join("\n");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // Model diff between the two most recent recorded responses.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  function isPlainObject(value) {` && |\n| &&
             `    return value !== null && typeof value === "object" && !Array.isArray(value);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function renderValue(value) {` && |\n| &&
             `    let text;` && |\n| &&
             `    if (value === undefined) return "(absent)";` && |\n| &&
             `    if (value === null) return "null";` && |\n| &&
             `    if (typeof value === "object") {` && |\n| &&
             `      try {` && |\n| &&
             `        text = JSON.stringify(value);` && |\n| &&
             `      } catch {` && |\n| &&
             `        text = String(value);` && |\n| &&
             `      }` && |\n| &&
             `    } else {` && |\n| &&
             `      text = String(value);` && |\n| &&
             `    }` && |\n| &&
             `    if (text.length > MAX_DIFF_VALUE_CHARS) {` && |\n| &&
             `      return ``${text.slice(0, MAX_DIFF_VALUE_CHARS)}... (${text.length} chars)``;` && |\n| &&
             `    }` && |\n| &&
             `    return text;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Walk two model trees in parallel and collect the differing paths.` && |\n| &&
             `  // Arrays are compared by index - a table row inserted at the top does` && |\n| &&
             `  // report every following row as changed, which is the honest answer for` && |\n| &&
             `  // a model the backend rebuilds wholesale anyway.` && |\n| &&
             `  function collectDiff(before, after, path, out, depth) {` && |\n| &&
             `    if (out.length >= MAX_DIFF_ENTRIES) return;` && |\n| &&
             `    if (before === after) return;` && |\n| &&
             `    if (depth > MAX_DIFF_DEPTH) {` && |\n| &&
             `      out.push({ path, type: "changed", before: "(too deep)", after: "" });` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    const bothObjects = isPlainObject(before) && isPlainObject(after);` && |\n| &&
             `    const bothArrays = Array.isArray(before) && Array.isArray(after);` && |\n| &&
             `` && |\n| &&
             `    if (bothObjects) {` && |\n| &&
             `      const keys = new Set([...Object.keys(before), ...Object.keys(after)]);` && |\n| &&
             `      for (const key of keys) {` && |\n| &&
             `        collectDiff(before[key], after[key], ``${path}/${key}``, out, depth + 1);` && |\n| &&
             `      }` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    if (bothArrays) {` && |\n| &&
             `      const length = Math.max(before.length, after.length);` && |\n| &&
             `      for (let i = 0; i < length; i++) {` && |\n| &&
             `        collectDiff(before[i], after[i], ``${path}/${i}``, out, depth + 1);` && |\n| &&
             `      }` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `` && |\n| &&
             `    if (before === undefined) {` && |\n| &&
             `      out.push({ path, type: "added", before: undefined, after });` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    if (after === undefined) {` && |\n| &&
             `      out.push({ path, type: "removed", before, after: undefined });` && |\n| &&
             `      return;` && |\n| &&
             `    }` && |\n| &&
             `    out.push({ path, type: "changed", before, after });` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `  // View XML diff between the two most recent responses that rebuilt a` && |\n| &&
             `  // slot. The model diff answers "what data changed"; this answers "why` && |\n| &&
             `  // does the layout look different", which is the other half.` && |\n| &&
             `  // ------------------------------------------------------------------` && |\n| &&
             `` && |\n| &&
             `  // Lines compared before the diff gives up - a generated view can be` && |\n| &&
             `  // thousands of lines and this walk is deliberately cheap.` && |\n| &&
             `  const MAX_DIFF_LINES = 4000;` && |\n| &&
             `` && |\n| &&
             `  // How far ahead the walk looks for a line to resync on. A view change is` && |\n| &&
             `  // local (an inserted control, a changed attribute), so a small window` && |\n| &&
             `  // finds the anchor; a wholesale rebuild resyncs on nothing and is` && |\n| &&
             `  // reported as a full replacement, which is the honest answer for it.` && |\n| &&
             `  const DIFF_LOOKAHEAD = 25;` && |\n| &&
             `` && |\n| &&
             `  // The XML a response displayed into ``slotKey``, or "" when it rebuilt no` && |\n| &&
             `  // such slot. Shape per the backend's own unit tests:` && |\n| &&
             `  // ["VIEW_SLOTS","display","MAIN","<View/>"].` && |\n| &&
             `  function displayedXml(response, slotKey) {` && |\n| &&
             `    const system = response?.S_FRONT?.S_ACTION?.T_SYSTEM;` && |\n| &&
             `    if (!Array.isArray(system)) return "";` && |\n| &&
             `    for (const item of system) {` && |\n| &&
             `      if (!Array.isArray(item)) continue;` && |\n| &&
             `      if (item[0] !== "VIEW_SLOTS" || item[1] !== "display") continue;` && |\n| &&
             `      if (item[2] !== slotKey) continue;` && |\n| &&
             `      if (typeof item[3] === "string") return item[3];` && |\n| &&
             `    }` && |\n| &&
             `    return "";` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // Line diff with a bounded resync window. Not an LCS: a full one is` && |\n| &&
             `  // quadratic, and for view XML - where edits are local - a lookahead` && |\n| &&
             `  // walk produces the same reading at a fraction of the cost.` && |\n| &&
             `  function diffLines(beforeText, afterText) {` && |\n| &&
             `    const a = beforeText.split("\n").slice(0, MAX_DIFF_LINES);` && |\n| &&
             `    const b = afterText.split("\n").slice(0, MAX_DIFF_LINES);` && |\n| &&
             `    const out = [];` && |\n| &&
             `    let i = 0;` && |\n| &&
             `    let j = 0;` && |\n| &&
             `    while ((i < a.length || j < b.length) && out.length < MAX_DIFF_ENTRIES) {` && |\n| &&
             `      if (i < a.length && j < b.length && a[i] === b[j]) {` && |\n| &&
             `        i += 1;` && |\n| &&
             `        j += 1;` && |\n| &&
             `        continue;` && |\n| &&
             `      }` && |\n| &&
             `      let addedRun = -1;` && |\n| &&
             `      let removedRun = -1;` && |\n| &&
             `      for (let k = 1; k <= DIFF_LOOKAHEAD; k += 1) {` && |\n| &&
             `        if (` && |\n| &&
             `          addedRun < 0 &&` && |\n| &&
             `          i < a.length &&` && |\n| &&
             `          j + k < b.length &&` && |\n| &&
             `          a[i] === b[j + k]` && |\n| &&
             `        ) {` && |\n| &&
             `          addedRun = k;` && |\n| &&
             `        }` && |\n|.
    result = result &&
             `        if (` && |\n| &&
             `          removedRun < 0 &&` && |\n| &&
             `          j < b.length &&` && |\n| &&
             `          i + k < a.length &&` && |\n| &&
             `          b[j] === a[i + k]` && |\n| &&
             `        ) {` && |\n| &&
             `          removedRun = k;` && |\n| &&
             `        }` && |\n| &&
             `        if (addedRun >= 0 || removedRun >= 0) break;` && |\n| &&
             `      }` && |\n| &&
             `      if (addedRun >= 0 && (removedRun < 0 || addedRun <= removedRun)) {` && |\n| &&
             `        for (let k = 0; k < addedRun; k += 1) {` && |\n| &&
             `          out.push({ type: "+", line: b[j + k], number: j + k + 1 });` && |\n| &&
             `        }` && |\n| &&
             `        j += addedRun;` && |\n| &&
             `      } else if (removedRun >= 0) {` && |\n| &&
             `        for (let k = 0; k < removedRun; k += 1) {` && |\n| &&
             `          out.push({ type: "-", line: a[i + k], number: i + k + 1 });` && |\n| &&
             `        }` && |\n| &&
             `        i += removedRun;` && |\n| &&
             `      } else {` && |\n| &&
             `        // nothing to resync on - report the pair as a replacement` && |\n| &&
             `        if (i < a.length) {` && |\n| &&
             `          out.push({ type: "-", line: a[i], number: i + 1 });` && |\n| &&
             `          i += 1;` && |\n| &&
             `        }` && |\n| &&
             `        if (j < b.length) {` && |\n| &&
             `          out.push({ type: "+", line: b[j], number: j + 1 });` && |\n| &&
             `          j += 1;` && |\n| &&
             `        }` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `    return out;` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The two most recent records whose response rebuilt ``slotKey``.` && |\n| &&
             `  function lastTwoViews(slotKey) {` && |\n| &&
             `    const withView = records` && |\n| &&
             `      .map((record) => ({` && |\n| &&
             `        record,` && |\n| &&
             `        xml: displayedXml(record.response, slotKey),` && |\n| &&
             `      }))` && |\n| &&
             `      .filter((entry) => entry.xml);` && |\n| &&
             `    return withView.length < 2 ? null : withView.slice(-2);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function formatViewDiff() {` && |\n| &&
             `    if (!isRecordingPayloads()) {` && |\n| &&
             `      return (` && |\n| &&
             `        "View diff needs payload recording.\n\n" +` && |\n| &&
             `        'Switch "Record Payloads" on in the dialog footer, then trigger at' +` && |\n| &&
             `        " least two roundtrips that rebuild the view - the diff compares the\n" +` && |\n| &&
             `        "view XML of the two most recently recorded rebuilds."` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    // Only MAIN: it is the slot a roundtrip normally rebuilds, and a` && |\n| &&
             `    // popup/popover diff would compare two different dialogs more often` && |\n| &&
             `    // than two versions of one.` && |\n| &&
             `    const pair = lastTwoViews("MAIN");` && |\n| &&
             `    if (!pair) {` && |\n| &&
             `      return (` && |\n| &&
             `        "Not enough recorded view rebuilds yet - the diff needs two.\n\n" +` && |\n| &&
             `        "Only a response that actually rebuilt the MAIN view counts; a\n" +` && |\n| &&
             `        "roundtrip that only pushed the model does not."` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    const [previous, current] = pair;` && |\n| &&
             `    const out = [` && |\n| &&
             `      ``View XML diff: roundtrip #${previous.record.seq}`` +` && |\n| &&
             `        `` (${previous.record.event || "(start)"}) ->`` +` && |\n| &&
             `        `` #${current.record.seq} (${current.record.event || "(start)"})``,` && |\n| &&
             `      "",` && |\n| &&
             `    ];` && |\n| &&
             `    const changes = diffLines(` && |\n| &&
             `      prettifyForDiff(previous.xml),` && |\n| &&
             `      prettifyForDiff(current.xml),` && |\n| &&
             `    );` && |\n| &&
             `    if (!changes.length) {` && |\n| &&
             `      out.push("(the two rebuilds produced identical view XML)");` && |\n| &&
             `      return out.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `    out.push(` && |\n| &&
             `      ``${changes.length}${changes.length >= MAX_DIFF_ENTRIES ? "+" : ""} changed line(s):``,` && |\n| &&
             `    );` && |\n| &&
             `    out.push("");` && |\n| &&
             `    for (const change of changes) {` && |\n| &&
             `      out.push(` && |\n| &&
             `        ``  ${change.type} ${String(change.number).padStart(5)}  `` +` && |\n| &&
             `          ``${change.line.trim()}``,` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    if (changes.length >= MAX_DIFF_ENTRIES) {` && |\n| &&
             `      out.push("");` && |\n| &&
             `      out.push(``(stopped after ${MAX_DIFF_ENTRIES} changes)``);` && |\n| &&
             `    }` && |\n| &&
             `    return out.join("\n");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The backend sends a view as one long line, which would make every diff` && |\n| &&
             `  // a single "everything changed". Break it at tag boundaries so the walk` && |\n| &&
             `  // has lines to anchor on. Deliberately not the dialog's XSLT prettifier:` && |\n| &&
             `  // this must not depend on a DOM.` && |\n| &&
             `  function prettifyForDiff(xml) {` && |\n| &&
             `    return String(xml).replace(/></g, ">\n<");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The two most recent records that actually carry a response payload.` && |\n| &&
             `  function lastTwoResponses() {` && |\n| &&
             `    const withPayload = records.filter((record) => record.response);` && |\n| &&
             `    if (withPayload.length < 2) return null;` && |\n| &&
             `    return withPayload.slice(-2);` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  function formatModelDiff() {` && |\n| &&
             `    if (!isRecordingPayloads()) {` && |\n| &&
             `      return (` && |\n| &&
             `        "Model diff needs payload recording.\n\n" +` && |\n| &&
             `        'Switch "Record Payloads" on in the dialog footer, then trigger at' +` && |\n| &&
             `        " least two roundtrips - the diff compares the MODEL of the two most\n" +` && |\n| &&
             `        "recently recorded responses."` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    const pair = lastTwoResponses();` && |\n| &&
             `    if (!pair) {` && |\n| &&
             `      return (` && |\n| &&
             `        "Not enough recorded responses yet - the diff needs two.\n\n" +` && |\n| &&
             `        "Trigger another roundtrip and reopen this tab."` && |\n| &&
             `      );` && |\n| &&
             `    }` && |\n| &&
             `    const [previous, current] = pair;` && |\n| &&
             `    const out = [];` && |\n| &&
             `    collectDiff(previous.response?.MODEL, current.response?.MODEL, "", out, 0);` && |\n| &&
             `` && |\n| &&
             `    const header = [` && |\n| &&
             `      ``Model diff: roundtrip #${previous.seq} (${previous.event || "(start)"})`` +` && |\n| &&
             `        `` -> #${current.seq} (${current.event || "(start)"})``,` && |\n| &&
             `      "",` && |\n| &&
             `    ];` && |\n| &&
             `    if (!out.length) {` && |\n| &&
             `      header.push("(the two responses carry an identical MODEL)");` && |\n| &&
             `      return header.join("\n");` && |\n| &&
             `    }` && |\n| &&
             `    header.push(` && |\n| &&
             `      ``${out.length}${out.length >= MAX_DIFF_ENTRIES ? "+" : ""}`` +` && |\n| &&
             `        `` differing path(s):``,` && |\n| &&
             `    );` && |\n| &&
             `    header.push("");` && |\n| &&
             `    for (const entry of out) {` && |\n| &&
             `      const path = entry.path || "/";` && |\n| &&
             `      if (entry.type === "added") {` && |\n| &&
             `        header.push(``+ ${path}``);` && |\n| &&
             `        header.push(``    ${renderValue(entry.after)}``);` && |\n| &&
             `      } else if (entry.type === "removed") {` && |\n| &&
             `        header.push(``- ${path}``);` && |\n| &&
             `        header.push(``    ${renderValue(entry.before)}``);` && |\n| &&
             `      } else {` && |\n| &&
             `        header.push(``~ ${path}``);` && |\n| &&
             `        header.push(``    before: ${renderValue(entry.before)}``);` && |\n| &&
             `        header.push(``    after:  ${renderValue(entry.after)}``);` && |\n| &&
             `      }` && |\n| &&
             `    }` && |\n| &&
             `    if (out.length >= MAX_DIFF_ENTRIES) {` && |\n| &&
             `      header.push("");` && |\n| &&
             `      header.push(``(stopped after ${MAX_DIFF_ENTRIES} differences)``);` && |\n| &&
             `    }` && |\n| &&
             `    return header.join("\n");` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  // The recorded history as JSON, for download. With payload recording on` && |\n| &&
             `  // this carries the actual request/response bodies, which is what makes a` && |\n| &&
             `  // bug reproducible for someone who cannot click through the app - the` && |\n| &&
             `  // shareable half of "record and replay". Replaying it back INTO a system` && |\n| &&
             `  // is deliberately not offered: the recorded requests reference draft ids` && |\n| &&
             `  // that only exist in the session that produced them, and re-sending them` && |\n| &&
             `  // would drive real backend state.` && |\n| &&
             `  function exportJson() {` && |\n| &&
             `    const payload = {` && |\n| &&
             `      exportedAt: new Date().toISOString(),` && |\n| &&
             `      payloadsRecorded: isRecordingPayloads(),` && |\n| &&
             `      records: getRecords(),` && |\n| &&
             `    };` && |\n| &&
             `    try {` && |\n| &&
             `      return JSON.stringify(payload, null, 2);` && |\n| &&
             `    } catch {` && |\n| &&
             `      // A payload that cannot be serialized must not lose the whole` && |\n| &&
             `      // export - fall back to the metadata, which is always plain data.` && |\n| &&
             `      const metaOnly = records.map((record) => {` && |\n| &&
             `        const copy = { ...record };` && |\n| &&
             `        delete copy.request;` && |\n| &&
             `        delete copy.response;` && |\n| &&
             `        return copy;` && |\n| &&
             `      });` && |\n| &&
             `      return JSON.stringify({ ...payload, records: metaOnly }, null, 2);` && |\n| &&
             `    }` && |\n| &&
             `  }` && |\n| &&
             `` && |\n| &&
             `  return {` && |\n| &&
             `    install,` && |\n| &&
             `    uninstall,` && |\n| &&
             `    getRecords,` && |\n| &&
             `    exportJson,` && |\n| &&
             `    isRecordingPayloads,` && |\n| &&
             `    setRecordingPayloads,` && |\n| &&
             `    formatHistory,` && |\n| &&
             `    formatModelDiff,` && |\n| &&
             `    formatViewDiff,` && |\n| &&
             `    // exposed for the unit specs` && |\n| &&
             `    _internals: { MAX_RECORDS, PAYLOAD_BUDGET_BYTES, PAYLOAD_FLAG_KEY },` && |\n| &&
             `  };` && |\n| &&
             `});` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
