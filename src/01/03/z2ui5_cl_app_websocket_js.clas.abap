* =====================================================================
* GENERATED FILE - DO NOT EDIT (AGENTS.md rule 2)
* Embedded frontend resource, generated from app/webapp/ by
* .github/app2abap/trans2abap.js. Change the source under app/webapp/
* and run 'npm run app2abap' to regenerate; the check_app2abap CI gate
* fails any manual edit here.
* =====================================================================
CLASS z2ui5_cl_app_websocket_js DEFINITION
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


CLASS z2ui5_cl_app_websocket_js IMPLEMENTATION.

  METHOD get.

    result = `// Invisible control that keeps a WebSocket connection to an ABAP Push` && |\n| &&
             `// Channel (APC) open and hands every inbound message to the backend: the` && |\n| &&
             `// message text lands in the two-way bound ``value`` property and the` && |\n| &&
             `// ``received`` event triggers the roundtrip that lets the app process it.` && |\n| &&
             `// Sending is deliberately NOT part of the control - an app publishes to the` && |\n| &&
             `// AMC channel from ABAP, so consuming a push channel needs no app JavaScript.` && |\n| &&
             `sap.ui.define(` && |\n| &&
             `  ["sap/ui/core/Control", "z2ui5/core/Lib", "z2ui5/core/AppState"],` && |\n| &&
             `  (Control, Lib, AppState) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `` && |\n| &&
             `    // A roundtrip already in flight makes View1.eB DROP the event (its` && |\n| &&
             `    // isBusy guard), so inbound messages are queued and reported one per` && |\n| &&
             `    // roundtrip instead of being lost in a burst. This is the retry interval` && |\n| &&
             `    // of the drain loop - it only runs while messages are actually waiting.` && |\n| &&
             `    const DRAIN_RETRY_MS = 50;` && |\n| &&
             `` && |\n| &&
             `    return Control.extend("z2ui5.cc.Websocket", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          // APC path ("/sap/bc/apc/sap/z2ui5_apc_smp_2"), resolved against` && |\n| &&
             `          // the current origin; a full ws:// or wss:// URL is taken as is.` && |\n| &&
             `          path: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          // Text of the message currently reported to the backend.` && |\n| &&
             `          value: {` && |\n| &&
             `            type: "string",` && |\n| &&
             `            defaultValue: "",` && |\n| &&
             `          },` && |\n| &&
             `          checkActive: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `          // false -> close the connection after the first message.` && |\n| &&
             `          checkRepeat: {` && |\n| &&
             `            type: "boolean",` && |\n| &&
             `            defaultValue: true,` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          received: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `      init() {` && |\n| &&
             `        this._queue = [];` && |\n| &&
             `      },` && |\n| &&
             `      // Every state change (checkActive toggled, path rebound) invalidates` && |\n| &&
             `      // the control, so this single hook is where the connection is brought` && |\n| &&
             `      // in line with the properties - no setter override needed.` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        const url = this._resolveUrl();` && |\n| &&
             `        if (url !== this._url) this._disconnect();` && |\n| &&
             `        this._url = url;` && |\n| &&
             `        if (this.getProperty("checkActive")) {` && |\n| &&
             `          this._connect();` && |\n| &&
             `        } else {` && |\n| &&
             `          this._disconnect();` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      exit() {` && |\n| &&
             `        clearTimeout(this._drainId);` && |\n| &&
             `        this._disconnect();` && |\n| &&
             `      },` && |\n| &&
             `      _resolveUrl() {` && |\n| &&
             `        const path = this.getProperty("path");` && |\n| &&
             `        if (!path) return "";` && |\n| &&
             `        if (/^wss?:\/\//i.test(path)) return path;` && |\n| &&
             `        // https -> wss, http -> ws` && |\n| &&
             `        const origin = window.location.origin.replace(/^http/i, "ws");` && |\n| &&
             `        return path.charAt(0) === "/" ? origin + path : origin + "/" + path;` && |\n| &&
             `      },` && |\n| &&
             `      _connect() {` && |\n| &&
             `        if (this._ws || !this._url) return;` && |\n| &&
             `        let ws;` && |\n| &&
             `        try {` && |\n| &&
             `          ws = new WebSocket(this._url);` && |\n| &&
             `        } catch (err) {` && |\n| &&
             `          Lib.logError("Websocket: cannot open " + this._url, err);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        this._ws = ws;` && |\n| &&
             `        ws.onmessage = (event) => {` && |\n| &&
             `          // The control may have been torn down, or replaced by a newer` && |\n| &&
             `          // connection, while this socket was still open.` && |\n| &&
             `          if (Lib.isDestroyed(this) || this._ws !== ws) return;` && |\n| &&
             `          if (typeof event.data !== "string") {` && |\n| &&
             `            Lib.logError("Websocket: ignored a non-text message");` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          this._queue.push(event.data);` && |\n| &&
             `          if (!this.getProperty("checkRepeat")) this._disconnect();` && |\n| &&
             `          this._drain();` && |\n| &&
             `        };` && |\n| &&
             `        ws.onerror = () => {` && |\n| &&
             `          Lib.logError("Websocket: connection error on " + this._url);` && |\n| &&
             `        };` && |\n| &&
             `        ws.onclose = () => {` && |\n| &&
             `          if (this._ws === ws) this._ws = null;` && |\n| &&
             `        };` && |\n| &&
             `      },` && |\n| &&
             `      _disconnect() {` && |\n| &&
             `        const ws = this._ws;` && |\n| &&
             `        if (!ws) return;` && |\n| &&
             `        this._ws = null;` && |\n| &&
             `        ws.onmessage = null;` && |\n| &&
             `        ws.onerror = null;` && |\n| &&
             `        ws.onclose = null;` && |\n| &&
             `        try {` && |\n| &&
             `          ws.close();` && |\n| &&
             `        } catch (err) {` && |\n| &&
             `          Lib.logError("Websocket: close failed", err);` && |\n| &&
             `        }` && |\n| &&
             `      },` && |\n| &&
             `      // Report the oldest queued message and round-trip once. While the` && |\n| &&
             `      // backend is busy nothing is consumed - the queue is retried until the` && |\n| &&
             `      // event can actually get through, so no message is dropped.` && |\n| &&
             `      _drain() {` && |\n| &&
             `        if (!this._queue.length) return;` && |\n| &&
             `        if (AppState.state.isBusy) {` && |\n| &&
             `          this._scheduleDrain();` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `        this.setProperty("value", this._queue.shift(), true);` && |\n| &&
             `        this.fireReceived();` && |\n| &&
             `        if (this._queue.length) this._scheduleDrain();` && |\n| &&
             `      },` && |\n| &&
             `      _scheduleDrain() {` && |\n| &&
             `        clearTimeout(this._drainId);` && |\n| &&
             `        this._drainId = setTimeout(() => {` && |\n| &&
             `          if (Lib.isDestroyed(this)) return;` && |\n| &&
             `          this._drain();` && |\n| &&
             `        }, DRAIN_RETRY_MS);` && |\n| &&
             `      },` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          Lib.renderInvisibleSpan(oRm, oControl);` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
