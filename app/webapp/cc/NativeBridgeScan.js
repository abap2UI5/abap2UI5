// Scan button for an app running inside the abap2UI5 native mobile shell
// (abap2UI5/mobile-shell). The shell injects `window.abap2ui5Native` (bridge
// contract v1, documented in that repository's bridge/README.md); pressing
// the button calls its scanBarcode( ), writes the result into `value` and
// fires OnScan, so the backend reads the scanned code as an ordinary event
// argument. A failure or a cancelled scan fires OnError with the bridge's
// message ("cancelled", "unsupported", ...) - the control shows nothing of
// its own (AGENTS.md rule 10).
//
// Outside the shell there is no bridge: the control renders an invisible
// placeholder, so the same view runs unchanged in a browser. showInBrowser
// renders the button anyway, and a press then fires OnError.
//
// The Android shell injects the bridge once the page has loaded, which can
// be after this control's first render. The shim announces itself with the
// window event below; a control that rendered without the bridge listens
// for it and renders again.
sap.ui.define(
  ["sap/ui/core/Control", "sap/m/Button", "z2ui5/core/Lib", "z2ui5/core/Env"],
  (Control, Button, Lib, Env) => {
    "use strict";

    const READY_EVENT = "abap2ui5native:ready";

    // The bridge object, or undefined in a plain browser - and also when a
    // page merely put something under the name: only an object that can
    // scan counts.
    function bridge() {
      const native = /** @type {any} */ (window).abap2ui5Native;
      return native && typeof native.scanBarcode === "function"
        ? native
        : undefined;
    }

    const NativeBridgeScan = Control.extend("z2ui5.cc.NativeBridgeScan", {
      metadata: {
        properties: {
          value: { type: "string", defaultValue: "" },
          text: { type: "string", defaultValue: "Scan" },
          icon: { type: "string", defaultValue: "sap-icon://bar-code" },
          enabled: { type: "boolean", defaultValue: true },
          showInBrowser: { type: "boolean", defaultValue: false },
        },
        events: {
          OnScan: {
            parameters: {
              value: { type: "string" },
            },
          },
          OnError: {
            parameters: {
              message: { type: "string" },
            },
          },
        },
      },

      init() {
        this._onReady = () => {
          this._stopWaiting();
          if (!Lib.isDestroyed(this)) this.invalidate();
        };
        this._waiting = false;
      },

      exit() {
        this._stopWaiting();
        if (this._oButton) this._oButton.destroy();
      },

      // `value` is not drawn by the renderer: written without invalidating
      // (AGENTS.md rule 10), the binding still carries it to the backend.
      setValue(val) {
        this.setProperty("value", val, true);
        return this;
      },

      _waitForBridge() {
        if (this._waiting) return;
        this._waiting = true;
        window.addEventListener(READY_EVENT, this._onReady);
      },

      _stopWaiting() {
        if (!this._waiting) return;
        this._waiting = false;
        window.removeEventListener(READY_EVENT, this._onReady);
      },

      _fail(message) {
        if (Lib.isDestroyed(this)) return;
        this.fireOnError({ message });
      },

      // Returns the scan promise (or undefined when nothing was started) so
      // a caller can wait for it - the press handler does not.
      scan() {
        const native = bridge();
        if (!native) {
          this._fail("native shell not available");
          return undefined;
        }
        if (this._scanning) return undefined;
        this._scanning = true;
        let pending;
        try {
          pending = Promise.resolve(native.scanBarcode());
        } catch (e) {
          pending = Promise.reject(e);
        }
        return pending.then(
          (value) => {
            this._scanning = false;
            if (Lib.isDestroyed(this)) return;
            const text = Lib.toText(value);
            this.setProperty("value", text, true);
            this.fireOnScan({ value: text });
          },
          (e) => {
            this._scanning = false;
            const message = Lib.toText(e?.message ?? e) || "scan failed";
            // A cancelled scan is the user's choice, not an error worth a
            // log line; everything else is.
            if (message !== "cancelled") {
              Lib.logError(`NativeBridgeScan: ${message}`);
            }
            this._fail(message);
          },
        );
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          if (!bridge()) oControl._waitForBridge();
          if (!bridge() && !oControl.getShowInBrowser()) {
            Lib.renderInvisibleSpan(oRm, oControl);
            return;
          }
          if (!oControl._oButton) {
            oControl._oButton = new Button({
              press: () => {
                oControl.scan();
              },
            });
          }
          oControl._oButton.setText(oControl.getText());
          oControl._oButton.setIcon(oControl.getIcon());
          oControl._oButton.setEnabled(oControl.getEnabled());
          oRm.renderControl(oControl._oButton);
        },
      },
    });
    return Env.ownClass(NativeBridgeScan);
  },
);
