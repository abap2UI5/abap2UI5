sap.ui.define(
  [
    "sap/ui/core/Control",
    "sap/m/Dialog",
    "sap/m/Button",
    "sap/ui/core/HTML",
    "z2ui5/core/Lib",
  ],
  (Control, Dialog, Button, HTML, Lib) => {
    "use strict";
    // Camera button: opens a dialog with the live camera stream, captures
    // a photo on demand and hands it to the backend as a base64 JPEG in
    // `value` (plus a small preview thumbnail) via the OnPhoto event.
    const _CTX_2D_OPTS = { willReadFrequently: true };
    const _THUMB_W = 300;
    // width/height size the trigger button; a bare number is treated as px.
    const toCssSize = (val) => (/^\d+$/.test(val) ? `${val}px` : val);
    return Control.extend("z2ui5.cc.CameraPicture", {
      metadata: {
        properties: {
          id: { type: "string" },
          value: { type: "string" },
          thumbnail: { type: "string" },
          // Empty default leaves the trigger button auto-sized; a bare
          // number is treated as px (see renderer / onAfterRendering).
          width: { type: "string", defaultValue: "" },
          height: { type: "string", defaultValue: "" },
          autoplay: { type: "boolean", defaultValue: true },
          facingMode: { type: "string" },
          deviceId: { type: "string" },
        },
        events: {
          OnPhoto: {
            allowPreventDefault: true,
            parameters: {
              photo: {
                type: "string",
              },
            },
          },
          // Fired when the trigger button is pressed (the backend binds it
          // via the `press` attribute, the same way as OnPhoto).
          press: {
            allowPreventDefault: true,
            parameters: {},
          },
        },
      },

      capture() {
        const video = document.getElementById(`${this.getId()}-video`);
        const canvas = document.getElementById(`${this.getId()}-canvas`);
        if (!video || !canvas) return;

        const videoWidth = video.videoWidth;
        const videoHeight = video.videoHeight;
        canvas.width = videoWidth;
        canvas.height = videoHeight;

        const ctx = canvas.getContext("2d", _CTX_2D_OPTS);
        if (!ctx) return;
        ctx.drawImage(video, 0, 0, videoWidth, videoHeight);

        // Full-resolution JPEG (quality 0.85) for the value, plus a small
        // thumbnail (max width _THUMB_W) at lower quality for previews.
        let resultb64;
        try {
          resultb64 = canvas.toDataURL("image/jpeg", 0.85);
        } catch (e) {
          Lib.logError("CameraPicture: canvas toDataURL failed", e);
          return;
        }

        const thumbH = videoWidth
          ? Math.round((videoHeight * _THUMB_W) / videoWidth)
          : _THUMB_W;
        const thumbCanvas = document.createElement("canvas");
        thumbCanvas.width = _THUMB_W;
        thumbCanvas.height = thumbH;
        const thumbCtx = thumbCanvas.getContext("2d", _CTX_2D_OPTS);
        if (thumbCtx) thumbCtx.drawImage(canvas, 0, 0, _THUMB_W, thumbH);

        let thumbB64 = "";
        try {
          thumbB64 = thumbCanvas.toDataURL("image/jpeg", 0.7);
        } catch (e) {
          Lib.logError("CameraPicture: thumb toDataURL failed", e);
        }

        if (Lib.isDestroyed(this)) return;
        this.setProperty("value", resultb64);
        this.setProperty("thumbnail", thumbB64);
        this.fireOnPhoto({ photo: resultb64 });
        this._stopCamera();
      },

      _stopCamera() {
        // Stop every track of the active stream so the OS frees the camera.
        if (this._stream) {
          for (const track of this._stream.getTracks()) track.stop();
        }
        this._stream = null;
        const video = document.getElementById(`${this.getId()}-video`);
        if (video) video.srcObject = null;
      },

      onPicture() {
        if (this._oScanDialog?.isOpen()) return;
        if (!this._oScanDialog) {
          this._oScanDialog = new Dialog({
            title: "Device Photo Function",
            contentWidth: "640px",
            contentHeight: "480px",
            horizontalScrolling: false,
            verticalScrolling: false,
            stretch: true,
            afterClose: () => this._stopCamera(),
            content: [
              new HTML({
                id: `${this.getId()}PictureContainer`,
                content: `<video style="width:100%;height:100%;object-fit:contain;"${this.getAutoplay() ? " autoplay" : ""} id="${this.getId()}-video">`,
              }),
              new Button({
                text: "Capture",
                press: () => {
                  this.capture();
                  this._oScanDialog.close();
                },
              }),
              new HTML({
                content: `<canvas hidden id="${this.getId()}-canvas" style="overflow:auto"></canvas>`,
              }),
            ],
            endButton: new Button({
              text: "Cancel",
              press: () => {
                this._stopCamera();
                this._oScanDialog.close();
              },
            }),
          });
        }

        this._oScanDialog.attachEventOnce("afterOpen", async () => {
          if (Lib.isDestroyed(this)) return;
          const video = document.getElementById(`${this.getId()}-video`);
          if (!video) {
            Lib.logError(
              "CameraPicture: video element not found after dialog open",
            );
            return;
          }
          const facingMode = this.getProperty("facingMode");
          const deviceId = this.getProperty("deviceId");
          const options = {
            video: { width: { ideal: 1920 }, height: { ideal: 1080 } },
          };
          if (deviceId) options.video.deviceId = deviceId;
          if (facingMode) options.video.facingMode = { exact: facingMode };

          try {
            const md = navigator.mediaDevices;
            if (!md?.getUserMedia) {
              Lib.logError("CameraPicture: mediaDevices API not available");
              return;
            }
            const stream = await md.getUserMedia(options);
            if (!stream) return;
            // Guard: during the getUserMedia await the control could have
            // been destroyed, or the user could have closed the dialog
            // (Cancel/afterClose). In both cases afterClose's _stopCamera()
            // has already run with no stream to stop, so release the camera
            // here instead of leaving it active.
            if (Lib.isDestroyed(this) || !this._oScanDialog?.isOpen()) {
              for (const t of stream.getTracks()) t.stop();
              return;
            }
            this._stream = stream;
            video.srcObject = stream;
          } catch (error) {
            Lib.logError("CameraPicture: getUserMedia failed", error);
          }
        });
        this._oScanDialog.open();
      },

      exit() {
        this._stopCamera();
        if (this._oButton) this._oButton.destroy();
        if (this._oScanDialog) this._oScanDialog.destroy();
      },

      // sap.m.Button has no height property, so apply it to the DOM here.
      onAfterRendering() {
        const h = this.getHeight();
        const dom = this._oButton?.getDomRef();
        if (h && dom) dom.style.height = toCssSize(h);
      },

      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          if (!oControl._oButton) {
            oControl._oButton = new Button({
              icon: "sap-icon://camera",
              text: "Camera",
              // Pressing the trigger notifies the backend (press event, when
              // bound) and opens the local camera dialog.
              press: () => {
                oControl.firePress();
                oControl.onPicture();
              },
            });
          }
          oControl._oButton.setWidth(toCssSize(oControl.getWidth()));
          oRm.renderControl(oControl._oButton);
        },
      },
    });
  },
);
