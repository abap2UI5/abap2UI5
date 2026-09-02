// Invisible control that keeps a WebSocket connection to an ABAP Push
// Channel (APC) open and hands every inbound message to the backend: the
// message text lands in the bound `value` property and the
// `received` event triggers the roundtrip that lets the app process it.
// Sending is deliberately NOT part of the control - an app publishes to the
// AMC channel from ABAP, so consuming a push channel needs no app JavaScript.
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/AppState"],
  (Control, Lib, AppState) => {
    "use strict";

    // A roundtrip already in flight makes View1.eB DROP the event (its
    // isBusy guard), so everything the control reports is queued and
    // delivered one item per roundtrip instead of being lost in a burst.
    // This is the retry interval of the drain loop - it only runs while
    // items are actually waiting.
    const DRAIN_RETRY_MS = 50;

    // Reconnect policy for a connection the app did not close: exponential
    // backoff starting here, capped there, and after MAX_CONNECT_ATTEMPTS
    // consecutive failed handshakes the control stops trying until the app
    // changes path/checkActive (each failure already fired `error`, so the
    // backend heard about every one). Without this, an app that answers the
    // error event with a view-rebuilding roundtrip re-entered _connect on
    // every render - an unbounded reconnect storm against an inactive ICF
    // node.
    const RECONNECT_BASE_MS = 500;
    const RECONNECT_MAX_MS = 30000;
    const MAX_CONNECT_ATTEMPTS = 5;

    // The queue is bounded like every other buffer in the frontend
    // (Lib.MAX_ERRORS, Console.MAX_ENTRIES, Recorder.MAX_RECORDS): a fast
    // APC channel against a busy backend otherwise grows it without limit,
    // one item drained per roundtrip.
    const MAX_QUEUE = 100;

    return Control.extend("z2ui5.cc.Websocket", {
      metadata: {
        properties: {
          // APC path ("/sap/bc/apc/sap/z2ui5_apc_smp_2"), resolved against
          // the current origin; a full ws:// or wss:// URL is taken as is.
          path: {
            type: "string",
            defaultValue: "",
          },
          // Text of the message currently reported to the backend.
          value: {
            type: "string",
            defaultValue: "",
          },
          checkActive: {
            type: "boolean",
            defaultValue: true,
          },
          // false -> close the connection after the first message.
          checkRepeat: {
            type: "boolean",
            defaultValue: true,
          },
        },
        events: {
          received: {
            allowPreventDefault: true,
            parameters: {},
          },
          // Fired when the connection could not be opened or ended without
          // the app asking for it, so a backend can react. `code` is the
          // WebSocket close code ("1006" for a handshake that never
          // completed - inactive ICF node, rejected authentication, unknown
          // APC application) or "CONSTRUCT" when the constructor itself
          // threw. The control never surfaces any UI on its own - handling
          // is delegated entirely to whoever binds this event.
          error: {
            parameters: {
              code: { type: "string" },
              message: { type: "string" },
            },
          },
        },
      },
      init() {
        this._queue = [];
        this._failedAttempts = 0;
        this._dropped = 0;
      },
      // Every state change (checkActive toggled, path rebound) invalidates
      // the control, so this single hook is where the connection is brought
      // in line with the properties - no setter override needed.
      onAfterRendering() {
        const url = this._resolveUrl();
        if (url !== this._url) {
          this._disconnect();
          // a NEW target gets a fresh set of attempts - the give-up above
          // is about hammering the same dead endpoint
          this._failedAttempts = 0;
        }
        this._url = url;
        const active = this.getProperty("checkActive");
        // checkActive switched back on is the app asking for a new attempt
        // (the ICF node was activated meanwhile) - the give-up is about
        // hammering the same dead endpoint unasked, and this is the second
        // trigger the contract above promises next to a path change
        if (active && this._wasInactive) {
          this._failedAttempts = 0;
        }
        this._wasInactive = !active;
        if (active) {
          this._connect();
        } else {
          this._disconnect();
        }
      },
      exit() {
        clearTimeout(this._drainId);
        clearTimeout(this._reconnectId);
        this._disconnect();
      },
      _resolveUrl() {
        const path = this.getProperty("path");
        if (!path) return "";
        if (/^wss?:\/\//i.test(path)) return path;
        // https -> wss, http -> ws
        const origin = window.location.origin.replace(/^http/i, "ws");
        return path.charAt(0) === "/" ? origin + path : origin + "/" + path;
      },
      _connect() {
        if (this._ws || !this._url) return;
        if (this._failedAttempts >= MAX_CONNECT_ATTEMPTS) return;
        const url = this._url;
        let ws;
        try {
          ws = new WebSocket(url);
        } catch (err) {
          const message = "Cannot open " + url + ": " + (err.message || err);
          Lib.logError("Websocket: " + message, err);
          this._report({ kind: "error", code: "CONSTRUCT", message });
          return;
        }
        this._ws = ws;
        this._opened = false;
        ws.onopen = () => {
          if (this._ws === ws) {
            this._opened = true;
            this._failedAttempts = 0;
          }
        };
        ws.onmessage = (event) => {
          // The control may have been torn down, or replaced by a newer
          // connection, while this socket was still open.
          if (Lib.isDestroyed(this) || this._ws !== ws) return;
          if (typeof event.data !== "string") {
            Lib.logError("Websocket: ignored a non-text message");
            return;
          }
          if (!this.getProperty("checkRepeat")) this._disconnect();
          this._report({ kind: "message", value: event.data });
        };
        ws.onerror = () => {
          // The WebSocket error event carries no detail by specification -
          // it is always followed by onclose, which is where the actual
          // reason (the close code) becomes available and is reported.
          Lib.logError("Websocket: connection error on " + url);
        };
        // A close the app asked for never gets here: _disconnect() drops the
        // handlers first. So every close reaching this point is one the
        // server or the network caused, and the backend should hear about it.
        ws.onclose = (event) => {
          if (this._ws !== ws) return;
          this._ws = null;
          if (Lib.isDestroyed(this)) return;
          const cause = this._opened
            ? "Connection to " + url + " was closed"
            : "Connection to " + url + " could not be established";
          const message = event.reason ? cause + ": " + event.reason : cause;
          Lib.logError("Websocket (" + event.code + "): " + message);
          if (!this._opened) {
            this._failedAttempts += 1;
            if (this._failedAttempts >= MAX_CONNECT_ATTEMPTS) {
              Lib.logError(
                "Websocket: " +
                  MAX_CONNECT_ATTEMPTS +
                  " failed connection attempts to " +
                  url +
                  " - giving up until path or checkActive changes",
              );
            }
          }
          this._report({
            kind: "error",
            code: String(event.code),
            message: message,
          });
          this._scheduleReconnect();
        };
      },
      // Try again on our own timer, not only on the next render: a model-only
      // response never re-renders, and the push channel used to stay silently
      // dead until something else happened to rebuild the view.
      _scheduleReconnect() {
        if (this._failedAttempts >= MAX_CONNECT_ATTEMPTS) return;
        const delay = Math.min(
          RECONNECT_MAX_MS,
          RECONNECT_BASE_MS * 2 ** this._failedAttempts,
        );
        clearTimeout(this._reconnectId);
        this._reconnectId = setTimeout(() => {
          if (Lib.isDestroyed(this)) return;
          if (!this.getProperty("checkActive")) return;
          this._connect();
        }, delay);
      },
      _disconnect() {
        const ws = this._ws;
        if (!ws) return;
        this._ws = null;
        ws.onopen = null;
        ws.onmessage = null;
        ws.onerror = null;
        ws.onclose = null;
        try {
          ws.close();
        } catch (err) {
          Lib.logError("Websocket: close failed", err);
        }
      },
      // Queue one item for the backend and start draining. Messages and
      // errors share the queue so they reach the app in the order they
      // happened - an error after three messages is reported after them.
      _report(item) {
        if (this._queue.length >= MAX_QUEUE) {
          // drop the NEW item and count it, the Console.getDropped shape -
          // reordering or silently shifting the oldest would deliver a
          // sequence the channel never sent
          this._dropped += 1;
          Lib.logError(
            "Websocket: queue full (" +
              MAX_QUEUE +
              "), dropped " +
              this._dropped +
              " item(s) so far",
          );
          return;
        }
        this._queue.push(item);
        this._drain();
      },
      // Hand the oldest queued item to the backend and round-trip once.
      // While the backend is busy nothing is consumed - the queue is retried
      // until the event can actually get through, so nothing is dropped.
      _drain() {
        if (!this._queue.length) return;
        if (AppState.state.isBusy) {
          this._scheduleDrain();
          return;
        }
        const item = this._queue.shift();
        if (item.kind === "error") {
          this.fireError({
            code: item.code,
            message: item.message,
          });
        } else {
          this.setProperty("value", item.value, true);
          this.fireReceived();
        }
        if (this._queue.length) this._scheduleDrain();
      },
      _scheduleDrain() {
        clearTimeout(this._drainId);
        this._drainId = setTimeout(() => {
          if (Lib.isDestroyed(this)) return;
          this._drain();
        }, DRAIN_RETRY_MS);
      },
      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          Lib.renderInvisibleSpan(oRm, oControl);
        },
      },
    });
  },
);
