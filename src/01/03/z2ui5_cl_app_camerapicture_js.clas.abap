CLASS z2ui5_cl_app_camerapicture_js DEFINITION
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


CLASS z2ui5_cl_app_camerapicture_js IMPLEMENTATION.

  METHOD get.

    result = `sap.ui.define(` && |\n| &&
             `  [` && |\n| &&
             `    "sap/ui/core/Control",` && |\n| &&
             `    "sap/m/Dialog",` && |\n| &&
             `    "sap/m/Button",` && |\n| &&
             `    "sap/ui/core/HTML",` && |\n| &&
             `    "z2ui5/core/Lib",` && |\n| &&
             `  ],` && |\n| &&
             `  (Control, Dialog, Button, HTML, Lib) => {` && |\n| &&
             `    "use strict";` && |\n| &&
             `    // Camera button: opens a dialog with the live camera stream, captures` && |\n| &&
             `    // a photo on demand and hands it to the backend as a base64 JPEG in` && |\n| &&
             `    // ``value`` (plus a small preview thumbnail) via the OnPhoto event.` && |\n| &&
             `    const _CTX_2D_OPTS = { willReadFrequently: true };` && |\n| &&
             `    const _THUMB_W = 300;` && |\n| &&
             `    // width/height size the trigger button; a bare number is treated as px.` && |\n| &&
             `    const toCssSize = (val) => (/^\d+$/.test(val) ? ``${val}px`` : val);` && |\n| &&
             `    return Control.extend("z2ui5.cc.CameraPicture", {` && |\n| &&
             `      metadata: {` && |\n| &&
             `        properties: {` && |\n| &&
             `          id: { type: "string" },` && |\n| &&
             `          value: { type: "string" },` && |\n| &&
             `          thumbnail: { type: "string" },` && |\n| &&
             `          // Empty default leaves the trigger button auto-sized; a bare` && |\n| &&
             `          // number is treated as px (see renderer / onAfterRendering).` && |\n| &&
             `          width: { type: "string", defaultValue: "" },` && |\n| &&
             `          height: { type: "string", defaultValue: "" },` && |\n| &&
             `          autoplay: { type: "boolean", defaultValue: true },` && |\n| &&
             `          facingMode: { type: "string" },` && |\n| &&
             `          deviceId: { type: "string" },` && |\n| &&
             `        },` && |\n| &&
             `        events: {` && |\n| &&
             `          OnPhoto: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {` && |\n| &&
             `              photo: {` && |\n| &&
             `                type: "string",` && |\n| &&
             `              },` && |\n| &&
             `            },` && |\n| &&
             `          },` && |\n| &&
             `          // Fired when the trigger button is pressed (the backend binds it` && |\n| &&
             `          // via the ``press`` attribute, the same way as OnPhoto).` && |\n| &&
             `          press: {` && |\n| &&
             `            allowPreventDefault: true,` && |\n| &&
             `            parameters: {},` && |\n| &&
             `          },` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      capture() {` && |\n| &&
             `        const video = document.getElementById(``${this.getId()}-video``);` && |\n| &&
             `        const canvas = document.getElementById(``${this.getId()}-canvas``);` && |\n| &&
             `        if (!video || !canvas) return;` && |\n| &&
             `` && |\n| &&
             `        const videoWidth = video.videoWidth;` && |\n| &&
             `        const videoHeight = video.videoHeight;` && |\n| &&
             `        canvas.width = videoWidth;` && |\n| &&
             `        canvas.height = videoHeight;` && |\n| &&
             `` && |\n| &&
             `        const ctx = canvas.getContext("2d", _CTX_2D_OPTS);` && |\n| &&
             `        if (!ctx) return;` && |\n| &&
             `        ctx.drawImage(video, 0, 0, videoWidth, videoHeight);` && |\n| &&
             `` && |\n| &&
             `        // Full-resolution JPEG (quality 0.85) for the value, plus a small` && |\n| &&
             `        // thumbnail (max width _THUMB_W) at lower quality for previews.` && |\n| &&
             `        let resultb64;` && |\n| &&
             `        try {` && |\n| &&
             `          resultb64 = canvas.toDataURL("image/jpeg", 0.85);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("CameraPicture: canvas toDataURL failed", e);` && |\n| &&
             `          return;` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        const thumbH = videoWidth` && |\n| &&
             `          ? Math.round((videoHeight * _THUMB_W) / videoWidth)` && |\n| &&
             `          : _THUMB_W;` && |\n| &&
             `        const thumbCanvas = document.createElement("canvas");` && |\n| &&
             `        thumbCanvas.width = _THUMB_W;` && |\n| &&
             `        thumbCanvas.height = thumbH;` && |\n| &&
             `        const thumbCtx = thumbCanvas.getContext("2d", _CTX_2D_OPTS);` && |\n| &&
             `        if (thumbCtx) thumbCtx.drawImage(canvas, 0, 0, _THUMB_W, thumbH);` && |\n| &&
             `` && |\n| &&
             `        let thumbB64 = "";` && |\n| &&
             `        try {` && |\n| &&
             `          thumbB64 = thumbCanvas.toDataURL("image/jpeg", 0.7);` && |\n| &&
             `        } catch (e) {` && |\n| &&
             `          Lib.logError("CameraPicture: thumb toDataURL failed", e);` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        if (Lib.isDestroyed(this)) return;` && |\n| &&
             `        this.setProperty("value", resultb64);` && |\n| &&
             `        this.setProperty("thumbnail", thumbB64);` && |\n| &&
             `        this.fireOnPhoto({ photo: resultb64 });` && |\n| &&
             `        this._stopCamera();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      _stopCamera() {` && |\n| &&
             `        // Stop every track of the active stream so the OS frees the camera.` && |\n| &&
             `        if (this._stream) {` && |\n| &&
             `          for (const track of this._stream.getTracks()) track.stop();` && |\n| &&
             `        }` && |\n| &&
             `        this._stream = null;` && |\n| &&
             `        const video = document.getElementById(``${this.getId()}-video``);` && |\n| &&
             `        if (video) video.srcObject = null;` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      onPicture() {` && |\n| &&
             `        if (this._oScanDialog?.isOpen()) return;` && |\n| &&
             `        if (!this._oScanDialog) {` && |\n| &&
             `          this._oScanDialog = new Dialog({` && |\n| &&
             `            title: "Device Photo Function",` && |\n| &&
             `            contentWidth: "640px",` && |\n| &&
             `            contentHeight: "480px",` && |\n| &&
             `            horizontalScrolling: false,` && |\n| &&
             `            verticalScrolling: false,` && |\n| &&
             `            stretch: true,` && |\n| &&
             `            afterClose: () => this._stopCamera(),` && |\n| &&
             `            content: [` && |\n| &&
             `              new HTML({` && |\n| &&
             `                id: ``${this.getId()}PictureContainer``,` && |\n| &&
             `                content: ``<video style="width:100%;height:100%;object-fit:contain;"${this.getAutoplay() ? " autoplay" : ""} id="${this.getId()}-video">``,` && |\n| &&
             `              }),` && |\n| &&
             `              new Button({` && |\n| &&
             `                text: "Capture",` && |\n| &&
             `                press: () => {` && |\n| &&
             `                  this.capture();` && |\n| &&
             `                  this._oScanDialog.close();` && |\n| &&
             `                },` && |\n| &&
             `              }),` && |\n| &&
             `              new HTML({` && |\n| &&
             `                content: ``<canvas hidden id="${this.getId()}-canvas" style="overflow:auto"></canvas>``,` && |\n| &&
             `              }),` && |\n| &&
             `            ],` && |\n| &&
             `            endButton: new Button({` && |\n| &&
             `              text: "Cancel",` && |\n| &&
             `              press: () => {` && |\n| &&
             `                this._stopCamera();` && |\n| &&
             `                this._oScanDialog.close();` && |\n| &&
             `              },` && |\n| &&
             `            }),` && |\n| &&
             `          });` && |\n| &&
             `        }` && |\n| &&
             `` && |\n| &&
             `        this._oScanDialog.attachEventOnce("afterOpen", async () => {` && |\n| &&
             `          if (Lib.isDestroyed(this)) return;` && |\n| &&
             `          const video = document.getElementById(``${this.getId()}-video``);` && |\n| &&
             `          if (!video) {` && |\n| &&
             `            Lib.logError(` && |\n| &&
             `              "CameraPicture: video element not found after dialog open",` && |\n| &&
             `            );` && |\n| &&
             `            return;` && |\n| &&
             `          }` && |\n| &&
             `          const facingMode = this.getProperty("facingMode");` && |\n| &&
             `          const deviceId = this.getProperty("deviceId");` && |\n| &&
             `          const options = {` && |\n| &&
             `            video: { width: { ideal: 1920 }, height: { ideal: 1080 } },` && |\n| &&
             `          };` && |\n| &&
             `          if (deviceId) options.video.deviceId = deviceId;` && |\n| &&
             `          if (facingMode) options.video.facingMode = { exact: facingMode };` && |\n| &&
             `` && |\n| &&
             `          try {` && |\n| &&
             `            const md = navigator.mediaDevices;` && |\n| &&
             `            if (!md?.getUserMedia) {` && |\n| &&
             `              Lib.logError("CameraPicture: mediaDevices API not available");` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            const stream = await md.getUserMedia(options);` && |\n| &&
             `            if (!stream) return;` && |\n| &&
             `            // Guard: during the getUserMedia await the control could have` && |\n| &&
             `            // been destroyed, or the user could have closed the dialog` && |\n| &&
             `            // (Cancel/afterClose). In both cases afterClose's _stopCamera()` && |\n| &&
             `            // has already run with no stream to stop, so release the camera` && |\n| &&
             `            // here instead of leaving it active.` && |\n| &&
             `            if (Lib.isDestroyed(this) || !this._oScanDialog?.isOpen()) {` && |\n| &&
             `              for (const t of stream.getTracks()) t.stop();` && |\n| &&
             `              return;` && |\n| &&
             `            }` && |\n| &&
             `            this._stream = stream;` && |\n| &&
             `            video.srcObject = stream;` && |\n| &&
             `          } catch (error) {` && |\n| &&
             `            Lib.logError("CameraPicture: getUserMedia failed", error);` && |\n| &&
             `          }` && |\n| &&
             `        });` && |\n| &&
             `        this._oScanDialog.open();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      exit() {` && |\n| &&
             `        this._stopCamera();` && |\n| &&
             `        if (this._oButton) this._oButton.destroy();` && |\n| &&
             `        if (this._oScanDialog) this._oScanDialog.destroy();` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      // sap.m.Button has no height property, so apply it to the DOM here.` && |\n| &&
             `      onAfterRendering() {` && |\n| &&
             `        const h = this.getHeight();` && |\n| &&
             `        const dom = this._oButton?.getDomRef();` && |\n| &&
             `        if (h && dom) dom.style.height = toCssSize(h);` && |\n| &&
             `      },` && |\n| &&
             `` && |\n| &&
             `      renderer: {` && |\n| &&
             `        apiVersion: 2,` && |\n| &&
             `        render(oRm, oControl) {` && |\n| &&
             `          if (!oControl._oButton) {` && |\n| &&
             `            oControl._oButton = new Button({` && |\n| &&
             `              icon: "sap-icon://camera",` && |\n| &&
             `              text: "Camera",` && |\n| &&
             `              // Pressing the trigger notifies the backend (press event, when` && |\n| &&
             `              // bound) and opens the local camera dialog.` && |\n| &&
             `              press: () => {` && |\n| &&
             `                oControl.firePress();` && |\n| &&
             `                oControl.onPicture();` && |\n| &&
             `              },` && |\n| &&
             `            });` && |\n| &&
             `          }` && |\n| &&
             `          oControl._oButton.setWidth(toCssSize(oControl.getWidth()));` && |\n| &&
             `          oRm.renderControl(oControl._oButton);` && |\n| &&
             `        },` && |\n| &&
             `      },` && |\n| &&
             `    });` && |\n| &&
             `  },` && |\n| &&
             `);` && |\n| &&
             `` && |\n| &&
              ``.

  ENDMETHOD.

ENDCLASS.
