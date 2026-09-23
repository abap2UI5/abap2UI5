// Roundtrip recorder of the developer tools.
//
// SELF-CONTAINED BY DESIGN: this module is the ONLY place that knows how
// roundtrip history is collected. It observes the framework from the
// outside - through the public callback arrays (Lib.registerCallback) and
// the browser's Resource Timing API - and never asks the framework to
// carry anything for it. Server.js, View1.controller.js, Context.js and
// Lib.js contain no recorder code and no recorder-shaped hooks; the whole
// feature can be deleted by removing this file and its tab entries in
// devtools/Tabs.js - devtools/DevTools.js is what
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
// binding mutates it in place. That only lasts until the NEXT
// roundtrip calls setData() with the new response's MODEL - from that
// moment the old object is unbound and frozen. So every record except the
// newest is stable, and the newest one is the current state the existing
// tabs show anyway. Retention is the only cost; there is no copying.
//
// PER COMPONENT CONTEXT (core/Context.js): a roundtrip belongs to the
// component that made it, so the history is one per context and every
// function takes the context first. install(ctx) creates the record on
// `ctx.devtools.recorder` (see recorderOf for its fields) and registers
// the render hook on THAT context's callback array; uninstall(ctx) takes
// exactly that down and leaves a second context's recorder untouched. Two
// things stay page-wide on purpose: the Tier 2 opt-in flag (sessionStorage
// - a setting, not data) and the reload carry-over (one sessionStorage
// key, consumed by whichever context installs first after the reload).
sap.ui.define(
  [
    "z2ui5/core/Lib",
    "z2ui5/devtools/Format",
    "z2ui5/devtools/Persist",
    "z2ui5/devtools/Diff",
  ],
  (Lib, Format, Persist, Diff) => {
    "use strict";

    const { formatBytes, renderValue } = Format;
    const { collectDiff, diffLines, MAX_DIFF_ENTRIES } = Diff;

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

    // sessionStorage key of the metadata carried across a page reload, and
    // how many records travel. When an app dies and the user reloads, the
    // evidence is exactly what a fresh page throws away - so the METADATA
    // (never the payloads, which is what makes this affordable) is written
    // on pagehide and read back on install, flagged as a previous load.
    const RELOAD_KEY = "z2ui5.devtools.history";
    const RELOAD_MAX_RECORDS = 30;

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

    // Longest value rendered inline in the model diff.
    const MAX_DIFF_VALUE_CHARS = 120;

    // The per-context record, `ctx.devtools.recorder` - null until
    // install(ctx) created it, null again after uninstall(ctx):
    //   records           the history, oldest first (see the entry shape
    //                     below)
    //   nextSeq           running number handed to the next record. Not
    //                     records.length: the ring drops old entries, and
    //                     the numbers must stay stable across evictions
    //   unpaired          network observations not yet paired with a
    //                     render, oldest first. Filled by the
    //                     PerformanceObserver and the synchronous sweep,
    //                     drained by onAfterRendering. Each:
    //                     { start, end, bytes }
    //   lastEntryStart    high-water mark of consumed Resource Timing
    //                     entries. The observer and the sweep both feed
    //                     `unpaired`, so the same entry must not be taken
    //                     twice; entries arrive in chronological order from
    //                     both sources, which makes a single startTime
    //                     watermark enough
    //   payloadBytes      sum of reqBytes + respBytes over the records
    //                     that still hold payloads. The measured sizes
    //                     double as the budget accounting - no separate
    //                     estimation pass is needed
    //   observer          the PerformanceObserver, null where unavailable
    //   afterRenderingHook  the onAfterRendering callback registered on
    //                     the context's state
    //   onPageHide        the window pagehide listener (persist)
    function recorderOf(ctx) {
      return ctx?.devtools?.recorder || null;
    }

    function createRecorder() {
      return {
        records: [],
        nextSeq: 1,
        unpaired: [],
        lastEntryStart: -1,
        payloadBytes: 0,
        observer: null,
        afterRenderingHook: null,
        onPageHide: null,
      };
    }

    // Each entry of `records`:
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

    // Absolute form of the backend endpoint, so it can be compared against
    // the absolute names Resource Timing reports. Recomputed per call: the
    // url is set by the shell controller and may not exist yet at install
    // time. Returns "" when unknown or unparsable.
    function backendUrl(ctx) {
      const url = ctx?.state?.url;
      if (!url) return "";
      try {
        return new URL(url, window.location.href).href;
      } catch {
        return "";
      }
    }

    // A performance-timeline mark (what Resource Timing reports) as a
    // wall-clock ISO timestamp, so a record built from an observation can
    // carry the time of the request instead of the time it was written.
    function wallClockIso(mark) {
      const origin =
        typeof performance !== "undefined" ? performance.timeOrigin : undefined;
      if (typeof origin === "number" && typeof mark === "number") {
        return new Date(origin + mark).toISOString();
      }
      return new Date().toISOString();
    }

    function now() {
      return typeof performance !== "undefined" && performance.now
        ? performance.now()
        : 0;
    }

    // Accept one Resource Timing entry as a roundtrip observation. Entries
    // older than the watermark were already taken (the observer and the sweep
    // overlap on purpose - see lastEntryStart).
    function acceptEntry(rec, entry) {
      if (!entry || entry.startTime <= rec.lastEntryStart) return;
      rec.lastEntryStart = entry.startTime;
      rec.unpaired.push({
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
    function sweepEntries(ctx, rec) {
      if (typeof performance === "undefined" || !performance.getEntriesByName) {
        return;
      }
      const url = backendUrl(ctx);
      if (!url) return;
      let entries;
      try {
        entries = performance.getEntriesByName(url, "resource");
      } catch {
        return;
      }
      // backwards, stopping at the watermark: getEntriesByName returns the
      // browser's WHOLE buffer for this url (chronological), and after N
      // roundtrips the loop was N accept calls per roundtrip for at most a
      // handful of new entries at the tail
      const fresh = [];
      for (let i = entries.length - 1; i >= 0; i -= 1) {
        if (entries[i].startTime <= rec.lastEntryStart) break;
        fresh.push(entries[i]);
      }
      for (let i = fresh.length - 1; i >= 0; i -= 1) acceptEntry(rec, fresh[i]);
    }

    // Take the network observation belonging to a render that happened at
    // `tRendered`: the newest one that finished before it. Everything older
    // than that never rendered - those are flushed as their own records so a
    // failed or superseded roundtrip stays visible in the history.
    function takeNetworkFor(rec, tRendered) {
      const unpaired = rec.unpaired;
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
      rec.unpaired = unpaired.slice(index + 1);
      for (const entry of stale) pushUnrendered(rec, entry);
      return match;
    }

    // Flush network observations that never got a render and are old enough
    // that none is coming. Called from the render path and when the history
    // is read, so a failing roundtrip shows up without needing a next one.
    function flushStaleUnpaired(rec) {
      if (!rec.unpaired.length) return;
      const cutoff = now() - UNPAIRED_FLUSH_MS;
      const stale = rec.unpaired.filter((entry) => entry.end < cutoff);
      if (!stale.length) return;
      rec.unpaired = rec.unpaired.filter((entry) => entry.end >= cutoff);
      for (const entry of stale) pushUnrendered(rec, entry);
    }

    // A roundtrip observed on the wire that never reached the render phase:
    // an error response, an aborted request, or a parallel request whose
    // result was discarded as stale. Worth a record of its own - these are
    // exactly the roundtrips a developer is looking for.
    function pushUnrendered(rec, entry) {
      pushRecord(rec, {
        // the time the REQUEST went out, not the time of this flush: the
        // flush runs on the next render or when the history is read, at
        // least UNPAIRED_FLUSH_MS later, so the failed roundtrip used to show
        // a timestamp seconds late and sat below roundtrips that happened
        // after it. Resource Timing marks are relative to the page's time
        // origin; without one (an old browser, a test double) the flush time
        // stays the best available
        ts: wallClockIso(entry.start),
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
      // ... and in its place in time: the flush appends, but the roundtrip
      // happened before the records written since. seq stays the arrival
      // order - it is the stable number the diff views refer to
      rec.records.sort((a, b) => (a.ts < b.ts ? -1 : a.ts > b.ts ? 1 : 0));
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
    function enforcePayloadBudget(rec) {
      for (const record of rec.records) {
        if (rec.payloadBytes <= PAYLOAD_BUDGET_BYTES) return;
        if (!record.request && !record.response) continue;
        rec.payloadBytes -= recordBytes(record);
        record.request = null;
        record.response = null;
        record.payloadEvicted = true;
      }
    }

    function pushRecord(rec, record) {
      record.seq = rec.nextSeq++;
      rec.records.push(record);
      rec.payloadBytes += recordBytes(record);
      while (rec.records.length > MAX_RECORDS) {
        const dropped = rec.records.shift();
        rec.payloadBytes -= recordBytes(dropped);
      }
      enforcePayloadBudget(rec);
    }

    // True when the developer switched Tier 2 on (the guarded read is
    // devtools/Persist.js's - a diagnostic tool must never be the thing
    // that breaks the app).
    function isRecordingPayloads() {
      return Persist.readFlag(PAYLOAD_FLAG_KEY);
    }

    // The flag is page-wide (a setting); what is dropped on switching it
    // off is the history of the context whose dialog switched it.
    function setRecordingPayloads(ctx, enabled) {
      Persist.writeFlag(PAYLOAD_FLAG_KEY, enabled);
      if (!enabled) dropAllPayloads(recorderOf(ctx));
    }

    function dropAllPayloads(rec) {
      if (!rec) return;
      for (const record of rec.records) {
        record.request = null;
        record.response = null;
      }
      rec.payloadBytes = 0;
    }

    // Serialized size of the request body. Server.readHttp already computed
    // it for the actual send and parks the NUMBER on shared state
    // (lastRequestBytes) - reading it is free. The stringify below is only
    // the fallback for a body that never went through readHttp: the body is
    // usually a small delta, but buildDeltaFromPaths falls back to a WHOLE
    // attribute for non-cell paths, and re-serializing a multi-MB table once
    // per roundtrip in the render phase - with payload recording off - was
    // the recorder's one measurable standing cost.
    function measureRequest(ctx, oBody) {
      if (!oBody) return null;
      const known = ctx.state.lastRequestBytes;
      if (typeof known === "number") return known;
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
    function onAfterRendering(ctx) {
      try {
        const rec = recorderOf(ctx);
        if (!rec) return;
        const state = ctx.state;
        const tRendered = now();
        sweepEntries(ctx, rec);
        const net = takeNetworkFor(rec, tRendered);
        const response = state.responseData;
        const sFront = response?.S_FRONT;
        const keepPayloads = isRecordingPayloads();
        const reqBytes = measureRequest(ctx, state.oBody);

        pushRecord(rec, {
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
        flushStaleUnpaired(rec);
      } catch (e) {
        // The recorder is a diagnostic aid; it may never take the app down.
        Lib.logError("DevTools Recorder: onAfterRendering failed", e);
      }
    }

    // Write the metadata of the newest records away for the next page load.
    // Payload references are dropped on purpose: they are the expensive part
    // and would not survive serialization usefully anyway.
    // A record without its payload references - what survives a reload and
    // what the export falls back to. Same key order as the record itself.
    function withoutPayloads(record) {
      const copy = { ...record };
      delete copy.request;
      delete copy.response;
      return copy;
    }

    function persist(rec) {
      const slim = rec.records.slice(-RELOAD_MAX_RECORDS).map((record) => ({
        ...withoutPayloads(record),
        previousLoad: true,
      }));
      Persist.saveList(RELOAD_KEY, slim);
    }

    // Adopt what the previous page load left behind, oldest first, so the
    // history reads as one timeline across the reload.
    function restore(rec) {
      const stored = Persist.takeList(RELOAD_KEY);
      if (!stored.length) return;
      rec.records = stored.slice(-RELOAD_MAX_RECORDS);
      // Continue the numbering after the restored ones so the two halves
      // of the timeline cannot collide.
      rec.nextSeq = (rec.records[rec.records.length - 1]?.seq || 0) + 1;
    }

    function install(ctx) {
      if (!ctx?.devtools || recorderOf(ctx)) return;
      const rec = createRecorder();
      ctx.devtools.recorder = rec;
      restore(rec);
      rec.afterRenderingHook = () => onAfterRendering(ctx);
      Lib.registerCallback(ctx, "onAfterRendering", rec.afterRenderingHook);

      // "pagehide", not "beforeunload" - same reasoning as Component.js: it
      // is the event that fires reliably, iOS Safari included. A browser
      // killed outright loses the history, which is the accepted limit here.
      rec.onPageHide = () => persist(rec);
      window.addEventListener("pagehide", rec.onPageHide);

      if (typeof PerformanceObserver === "undefined") return;
      try {
        rec.observer = new PerformanceObserver((list) => {
          const url = backendUrl(ctx);
          if (!url) return;
          for (const entry of list.getEntries()) {
            if (entry.name === url) acceptEntry(rec, entry);
          }
        });
        // buffered: entries recorded before this observer existed (the app
        // start roundtrip fires before Component.init finishes) are replayed.
        rec.observer.observe({ type: "resource", buffered: true });
      } catch {
        // No resource observation available - the history still records
        // every roundtrip, only without timing and response sizes.
        rec.observer = null;
      }
    }

    function uninstall(ctx) {
      const rec = recorderOf(ctx);
      if (!rec) return;
      ctx.devtools.recorder = null;
      Lib.unregisterCallback(ctx, "onAfterRendering", rec.afterRenderingHook);
      rec.afterRenderingHook = null;
      if (rec.onPageHide) {
        window.removeEventListener("pagehide", rec.onPageHide);
        rec.onPageHide = null;
      }
      if (rec.observer) {
        try {
          rec.observer.disconnect();
        } catch {
          // already gone
        }
        rec.observer = null;
      }
    }

    // The history of a context, oldest first - [] for a context whose
    // recorder is not installed.
    function getRecords(ctx) {
      const rec = recorderOf(ctx);
      if (!rec) return [];
      flushStaleUnpaired(rec);
      return rec.records;
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

    function formatMs(ms) {
      return ms === null || ms === undefined ? "-" : `${ms} ms`;
    }

    // Short form of a draft id: the ids are 32-character UUIDs and only the
    // tail is needed to tell two of them apart in a list.
    function shortId(id) {
      if (!id) return "-";
      return id.length > 8 ? `..${id.slice(-6)}` : id;
    }

    // The app navigation as OBSERVED in this session. The real draft chain
    // (id_prev / id_prev_app_stack) lives in the backend and never reaches
    // the browser, but every app switch is visible here: the response names
    // its app, so a change between two consecutive records is a navigation.
    // Answers "how did I get here" and, with the draft ids, why
    // nav_app_leave( ) returns where it does.
    function navigationLines(list) {
      const hops = [];
      let previous = null;
      for (const record of list) {
        if (!record.app || record.app === previous) continue;
        hops.push({
          seq: record.seq,
          from: previous,
          to: record.app,
          event: record.event,
          draft: record.idReceived,
        });
        previous = record.app;
      }
      if (hops.length < 2) return [];
      const out = ["App navigation observed this session"];
      for (const hop of hops) {
        out.push(
          `  #${String(hop.seq).padEnd(4)}` +
            `${hop.from ? `${hop.from} -> ` : "start "}${hop.to}` +
            `${hop.event ? `   via ${hop.event}` : ""}` +
            `   draft ${shortId(hop.draft)}`,
        );
      }
      out.push("");
      return out;
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
      const avg = Math.round(
        backend.reduce((a, b) => a + b, 0) / backend.length,
      );
      const slowest = timed.reduce((a, b) =>
        b.backendMs > a.backendMs ? b : a,
      );
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

    function formatHistory(ctx) {
      const list = getRecords(ctx);
      const lines = [];
      lines.push(
        `Roundtrip history - ${list.length} of max ${MAX_RECORDS} records`,
      );
      const recording = isRecordingPayloads();
      lines.push(
        `Payload recording: ${recording ? "ON" : "OFF"}` +
          ` (retained ${formatBytes(recorderOf(ctx)?.payloadBytes || 0)} of ` +
          `${formatBytes(PAYLOAD_BUDGET_BYTES)} budget)`,
      );
      if (!recording) {
        lines.push(
          `Switch "Record Payloads" on to keep request/response bodies and` +
            ` enable the Model Diff and View Diff tabs.`,
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
          pad(record.previousLoad ? `${record.seq}*` : record.seq, 5) +
            pad(time, 14) +
            pad(
              record.rendered ? record.event || "(start)" : "(no render)",
              22,
            ) +
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
      lines.push(...navigationLines(list));
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
      // The second half of that sentence, kept next to its first half: the
      // optional '*' note below used to be pushed between the two, so the
      // footnote read as a fragment on exactly the sessions that survived a
      // reload.
      lines.push(
        "(error response, aborted request, or a parallel request whose" +
          " result was discarded as stale).",
      );
      if (list.some((record) => record.previousLoad)) {
        lines.push(
          "A '*' after the number marks a roundtrip of the PREVIOUS page" +
            " load, carried across the reload.",
        );
      }
      return lines.join("\n");
    }

    // ------------------------------------------------------------------
    // View XML diff between the two most recent responses that rebuilt a
    // slot. The model diff answers "what data changed"; this answers "why
    // does the layout look different", which is the other half. Both
    // walks are devtools/Diff.js's; this module picks the two inputs and
    // renders the result.
    // ------------------------------------------------------------------

    // The XML a response displayed into `slotKey`, or "" when it rebuilt no
    // such slot. Shape per the backend's own unit tests:
    // ["VIEW_SLOTS","display","MAIN","<View/>"].
    function displayedXml(response, slotKey) {
      const system = response?.S_FRONT?.S_ACTION?.T_SYSTEM;
      if (!Array.isArray(system)) return "";
      for (const item of system) {
        if (!Array.isArray(item)) continue;
        if (item[0] !== "VIEW_SLOTS" || item[1] !== "display") continue;
        if (item[2] !== slotKey) continue;
        if (typeof item[3] === "string") return item[3];
      }
      return "";
    }

    // The two most recent records whose response rebuilt `slotKey`.
    function lastTwoViews(ctx, slotKey) {
      // from the newest record backwards, stopping at the second hit - the
      // whole history used to be mapped and filtered to keep two entries
      const records = getRecords(ctx);
      const withView = [];
      for (let i = records.length - 1; i >= 0 && withView.length < 2; i--) {
        const xml = displayedXml(records[i].response, slotKey);
        if (xml) withView.unshift({ record: records[i], xml });
      }
      return withView.length < 2 ? null : withView;
    }

    function formatViewDiff(ctx) {
      if (!isRecordingPayloads()) {
        return (
          "View diff needs payload recording.\n\n" +
          'Switch "Record Payloads" on in the Roundtrips action bar, then' +
          " trigger at least two roundtrips that rebuild the view - the diff\n" +
          "compares the view XML of the two most recently recorded rebuilds."
        );
      }
      // Only MAIN: it is the slot a roundtrip normally rebuilds, and a
      // popup/popover diff would compare two different dialogs more often
      // than two versions of one.
      const pair = lastTwoViews(ctx, "MAIN");
      if (!pair) {
        return (
          "Not enough recorded view rebuilds yet - the diff needs two.\n\n" +
          "Only a response that actually rebuilt the MAIN view counts; a\n" +
          "roundtrip that only pushed the model does not."
        );
      }
      const [previous, current] = pair;
      const out = [
        `View XML diff: roundtrip #${previous.record.seq}` +
          ` (${previous.record.event || "(start)"}) ->` +
          ` #${current.record.seq} (${current.record.event || "(start)"})`,
        "",
      ];
      const changes = diffLines(
        prettifyForDiff(previous.xml),
        prettifyForDiff(current.xml),
      );
      if (!changes.length) {
        out.push("(the two rebuilds produced identical view XML)");
        return out.join("\n");
      }
      out.push(
        `${changes.length}${changes.length >= MAX_DIFF_ENTRIES ? "+" : ""} changed line(s):`,
      );
      out.push("");
      for (const change of changes) {
        out.push(
          `  ${change.type} ${String(change.number).padStart(5)}  ` +
            `${change.line.trim()}`,
        );
      }
      if (changes.length >= MAX_DIFF_ENTRIES) {
        out.push("");
        out.push(`(stopped after ${MAX_DIFF_ENTRIES} changes)`);
      }
      return out.join("\n");
    }

    // The backend sends a view as one long line, which would make every diff
    // a single "everything changed". Break it at tag boundaries so the walk
    // has lines to anchor on. Deliberately not the dialog's XSLT prettifier:
    // this must not depend on a DOM.
    function prettifyForDiff(xml) {
      return xml.replace(/></g, ">\n<");
    }

    // ------------------------------------------------------------------
    // Model diff between the two most recent recorded responses.
    // ------------------------------------------------------------------

    // The two most recent records that actually carry a response payload.
    function lastTwoResponses(ctx) {
      const withPayload = getRecords(ctx).filter((record) => record.response);
      if (withPayload.length < 2) return null;
      return withPayload.slice(-2);
    }

    function formatModelDiff(ctx) {
      if (!isRecordingPayloads()) {
        return (
          "Model diff needs payload recording.\n\n" +
          'Switch "Record Payloads" on in the Roundtrips action bar, then' +
          " trigger at least two roundtrips - the diff compares the MODEL of\n" +
          "the two most recently recorded responses."
        );
      }
      const pair = lastTwoResponses(ctx);
      if (!pair) {
        return (
          "Not enough recorded responses yet - the diff needs two.\n\n" +
          "Trigger another roundtrip and reopen this tab."
        );
      }
      const [previous, current] = pair;
      const out = collectDiff(
        previous.response?.MODEL,
        current.response?.MODEL,
      );

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
          header.push(`    ${renderValue(entry.after, MAX_DIFF_VALUE_CHARS)}`);
        } else if (entry.type === "removed") {
          header.push(`- ${path}`);
          header.push(`    ${renderValue(entry.before, MAX_DIFF_VALUE_CHARS)}`);
        } else {
          header.push(`~ ${path}`);
          header.push(
            `    before: ${renderValue(entry.before, MAX_DIFF_VALUE_CHARS)}`,
          );
          header.push(
            `    after:  ${renderValue(entry.after, MAX_DIFF_VALUE_CHARS)}`,
          );
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
    function exportJson(ctx) {
      const records = getRecords(ctx);
      const payload = {
        exportedAt: new Date().toISOString(),
        payloadsRecorded: isRecordingPayloads(),
        records,
      };
      try {
        return JSON.stringify(payload, null, 2);
      } catch {
        // A payload that cannot be serialized must not lose the whole
        // export - fall back to the metadata, which is always plain data.
        const metaOnly = records.map(withoutPayloads);
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
      formatViewDiff,
      // exposed for the unit specs
      _internals: { MAX_RECORDS, PAYLOAD_BUDGET_BYTES, PAYLOAD_FLAG_KEY },
    };
  },
);
