// Invisible control that keeps a WebSocket connection to an ABAP Push
// Channel (APC) open and hands every inbound message to the backend: the
// message text lands in the two-way bound `value` property and the
// `received` event triggers the roundtrip that lets the app process it.
// Sending is deliberately NOT part of the control - an app publishes to the
// AMC channel from ABAP, so consuming a push channel needs no app JavaScript.
sap.ui.define(
  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/AppState"],
  (Control, Lib, AppState) => {
    "use strict";

    // A roundtrip already in flight makes View1.eB DROP the event (its
    // isBusy guard), so inbound messages are queued and reported one per
    // roundtrip instead of being lost in a burst. This is the retry interval
    // of the drain loop - it only runs while messages are actually waiting.
    const DRAIN_RETRY_MS = 50;

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
        },
      },
      init() {
        this._queue = [];
      },
      // Every state change (checkActive toggled, path rebound) invalidates
      // the control, so this single hook is where the connection is brought
      // in line with the properties - no setter override needed.
      onAfterRendering() {
        const url = this._resolveUrl();
        if (url !== this._url) this._disconnect();
        this._url = url;
        if (this.getProperty("checkActive")) {
          this._connect();
        } else {
          this._disconnect();
        }
      },
      exit() {
        clearTimeout(this._drainId);
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
        let ws;
        try {
          ws = new WebSocket(this._url);
        } catch (err) {
          Lib.logError("Websocket: cannot open " + this._url, err);
          return;
        }
        this._ws = ws;
        ws.onmessage = (event) => {
          // The control may have been torn down, or replaced by a newer
          // connection, while this socket was still open.
          if (Lib.isDestroyed(this) || this._ws !== ws) return;
          if (typeof event.data !== "string") {
            Lib.logError("Websocket: ignored a non-text message");
            return;
          }
          this._queue.push(event.data);
          if (!this.getProperty("checkRepeat")) this._disconnect();
          this._drain();
        };
        ws.onerror = () => {
          Lib.logError("Websocket: connection error on " + this._url);
        };
        ws.onclose = () => {
          if (this._ws === ws) this._ws = null;
        };
      },
      _disconnect() {
        const ws = this._ws;
        if (!ws) return;
        this._ws = null;
        ws.onmessage = null;
        ws.onerror = null;
        ws.onclose = null;
        try {
          ws.close();
        } catch (err) {
          Lib.logError("Websocket: close failed", err);
        }
      },
      // Report the oldest queued message and round-trip once. While the
      // backend is busy nothing is consumed - the queue is retried until the
      // event can actually get through, so no message is dropped.
      _drain() {
        if (!this._queue.length) return;
        if (AppState.state.isBusy) {
          this._scheduleDrain();
          return;
        }
        this.setProperty("value", this._queue.shift(), true);
        this.fireReceived();
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
