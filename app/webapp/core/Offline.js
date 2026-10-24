sap.ui.define(["z2ui5/core/Lib"], (Lib) => {
  "use strict";

  // The offline queue: events of the app's choosing that are kept in the
  // browser when the backend cannot be reached, and sent once it can again.
  //
  // Opt-in, per app and per event. The app names the events with the
  // follow-up action cs_event-offline_queue (handler: actions/Browser.js),
  // typically on the view it captures data with - SAVE of a form, a scan, a
  // count. Every other event is untouched: a network failure on it still ends
  // in the error overlay with Retry, exactly as before.
  //
  // What is kept is the request body as Server.roundtrip built it - the event,
  // its arguments, the model delta - under the endpoint's URL in
  // localStorage, so a closed tab or a reload does not lose it. What it does
  // NOT do (the design and the open questions are docs/concepts/offline.md):
  // load the page without a network, render a view the backend has not sent,
  // or decide anything about the data - the backend sees each event as if it
  // had arrived late, in order, and decides there.
  //
  // Sending them again is Server.replayOffline's: in order, each one on the
  // draft the previous answer left, the last one rendered.

  const PREFIX = "z2ui5-offline:";

  function storageKey(ctx) {
    return PREFIX + (ctx.state.url || "");
  }

  function read(ctx) {
    try {
      const raw = window.localStorage.getItem(storageKey(ctx));
      const list = raw ? JSON.parse(raw) : [];
      return Array.isArray(list) ? list : [];
    } catch (e) {
      Lib.logError("offline queue: could not be read", e);
      return [];
    }
  }

  function write(ctx, list) {
    try {
      if (list.length) {
        window.localStorage.setItem(storageKey(ctx), JSON.stringify(list));
      } else {
        window.localStorage.removeItem(storageKey(ctx));
      }
      return true;
    } catch (e) {
      // private mode, a full quota, storage switched off: the event cannot
      // be kept, and the caller reports the network failure as before
      Lib.logError("offline queue: could not be written", e);
      return false;
    }
  }

  return {
    // The events the app allows to queue, and the toast text it shows when
    // one was kept. An empty list switches the queue off for this app; what
    // is already queued stays and is still sent. `onOnline` is called when
    // the browser reports the network back.
    configure(ctx, events, text, onOnline) {
      const rec = ctx.offline;
      rec.events = new Set(events.filter(Boolean));
      rec.text = text || "";
      if (!rec.listener && typeof window !== "undefined") {
        rec.listener = () => onOnline();
        window.addEventListener("online", rec.listener);
      }
    },

    canQueue(ctx, oBody) {
      const event = oBody?.S_FRONT?.EVENT;
      return !!event && ctx.offline.events.has(event);
    },

    // Keeps one request body; returns how many are waiting, 0 when it could
    // not be kept.
    queue(ctx, oBody) {
      const list = read(ctx);
      list.push({ at: new Date().toISOString(), body: oBody });
      return write(ctx, list) ? list.length : 0;
    },

    pending(ctx) {
      return read(ctx).length;
    },

    // Hands over everything waiting and empties the store - the caller sends
    // it and puts back (putBack) what it could not send.
    take(ctx) {
      const list = read(ctx);
      if (list.length) write(ctx, []);
      return list;
    },

    putBack(ctx, entries) {
      write(ctx, [...entries, ...read(ctx)]);
    },

    text(ctx) {
      return ctx.offline.text;
    },

    // Component teardown: the listener goes, the queue in storage stays -
    // the next start of the app sends it.
    reset(ctx) {
      const rec = ctx.offline;
      if (rec.listener && typeof window !== "undefined") {
        window.removeEventListener("online", rec.listener);
      }
      rec.listener = null;
      rec.events = new Set();
      rec.text = "";
      rec.replaying = false;
    },
  };
});
