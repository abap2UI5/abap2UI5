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
    const _CTX_2D_OPTS = { willReadFrequently: true };
    const _THUMB_W = 300;
    return Control.extend("z2ui5.cc.CameraPicture", {
      metadata: {
        properties: {
          id: { type: "string" },
          value: { type: "string" },
          thumbnail: { type: "string" },
          press: { type: "string" },
          width: { type: "string", defaultValue: "200" },
          height: { type: "string", defaultValue: "200" },
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
                content: `<video style="width:100%;height:100%;object-fit:contain;" autoplay="true" id="${this.getId()}-video">`,
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
            if (!md || !md.getUserMedia) return;
            const stream = await md.getUserMedia(options);
            if (!stream) return;
            // Guard: the control could have been destroyed during the
            // getUserMedia await. Release the camera if so.
            if (Lib.isDestroyed(this)) {
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
      renderer: {
        apiVersion: 2,
        render(oRm, oControl) {
          if (!oControl._oButton) {
            oControl._oButton = new Button({
              icon: "sap-icon://camera",
              text: "Camera",
              press: oControl.onPicture.bind(oControl),
            });
          }
          oRm.renderControl(oControl._oButton);
        },
      },
    });
  },
);
