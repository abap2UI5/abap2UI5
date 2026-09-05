// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/CameraPicture.js: camera button that opens a dialog with the live
// stream and captures a photo into `value`/`thumbnail`. The contract under
// test:
//   - defensive DOM reads (AGENTS.md rule 10): a missing video/canvas, a
//     0-sized frame (camera not ready) or a throwing toDataURL must be
//     logged / reported via the in-dialog status line - never thrown.
//   - the getUserMedia continuation guards: a stream resolving after the
//     control was destroyed or the dialog was closed must be stopped, not
//     leaked.
//   - exit() releases the camera and destroys the owned controls.
function load({ documentElements = {}, mediaDevices } = {}) {
  const errors = [];
  // The real Lib so isDestroyed is the shipped one; only logError is
  // replaced to capture the messages.
  const Lib = { ...loadLib().Lib, logError: (m) => errors.push(m) };

  const created = { thumbCanvases: [] };
  const doc = {
    getElementById: (id) => documentElements[id] || null,
    createElement: (tag) => {
      const el = {
        tag,
        getContext: () => ({ drawImage() {} }),
        toDataURL: () => "data:image/jpeg;base64,THUMB",
      };
      if (tag === "canvas") created.thumbCanvases.push(el);
      return el;
    },
  };

  class Dialog {
    constructor(settings) {
      this.settings = settings;
      this.opened = false;
      this.destroyed = false;
    }
    attachEventOnce(_name, fn) {
      this.afterOpenHandler = fn;
    }
    open() {
      this.opened = true;
    }
    isOpen() {
      return this.opened;
    }
    close() {
      this.opened = false;
      if (this.settings.afterClose) this.settings.afterClose();
    }
    destroy() {
      this.destroyed = true;
    }
  }
  class Button {
    constructor(settings) {
      this.settings = settings;
      this.destroyed = false;
    }
    setWidth(w) {
      this.width = w;
    }
    getDomRef() {
      return this.domRef;
    }
    destroy() {
      this.destroyed = true;
    }
  }
  class Text {
    addStyleClass() {
      return this;
    }
    setText(t) {
      this.text = t;
    }
    isDestroyed() {
      return false;
    }
  }
  class HTML {
    constructor(settings) {
      this.settings = settings;
    }
  }

  const { module: CameraPicture } = loadModule("cc/CameraPicture.js", {
    deps: {
      "sap/ui/core/Control": {
        extend(_name, def) {
          function Ctrl() {}
          Object.assign(Ctrl.prototype, def);
          return Ctrl;
        },
      },
      "sap/m/Dialog": Dialog,
      "sap/m/Button": Button,
      "sap/m/Text": Text,
      "sap/ui/core/HTML": HTML,
      "z2ui5/core/Lib": Lib,
    },
    sandbox: { document: doc, navigator: { mediaDevices } },
  });

  function makeInstance(props = {}) {
    const inst = new CameraPicture();
    inst._props = {
      value: "",
      thumbnail: "",
      width: "",
      height: "",
      autoplay: true,
      facingMode: "",
      deviceId: "",
      ...props,
    };
    inst.getId = () => "cam";
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.getAutoplay = () => inst._props.autoplay;
    inst.getWidth = () => inst._props.width;
    inst.getHeight = () => inst._props.height;
    inst.photos = [];
    inst.fireOnPhoto = (p) => inst.photos.push(p);
    // press is declared allowPreventDefault, so the real firePress( )
    // answers FALSE when a handler vetoed the event and true otherwise -
    // the trigger button acts on that answer.
    inst.pressed = 0;
    inst.pressVetoed = false;
    inst.firePress = () => {
      inst.pressed++;
      return !inst.pressVetoed;
    };
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    return inst;
  }

  return { makeInstance, errors, created };
}

// A video/canvas element pair as capture() reads them from the DOM.
function captureDom({ videoWidth = 640, videoHeight = 480, toDataURL } = {}) {
  const video = { videoWidth, videoHeight, srcObject: {} };
  const canvas = {
    getContext: () => ({ drawImage() {} }),
    toDataURL: toDataURL || (() => "data:image/jpeg;base64,FULL"),
  };
  return { "cam-video": video, "cam-canvas": canvas };
}

const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

test("the trigger fires press and opens the camera dialog", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  const rendered = [];
  inst.renderer.render({ renderControl: (c) => rendered.push(c) }, inst);

  expect(rendered).toEqual([inst._oButton]);
  inst._oButton.settings.press();
  expect(inst.pressed).toBe(1);
  expect(inst._oScanDialog.opened).toBe(true);
});

test("a vetoed press leaves the camera dialog closed", () => {
  const { makeInstance } = load();
  const inst = makeInstance();
  inst.pressVetoed = true;
  inst.renderer.render({ renderControl: () => {} }, inst);

  inst._oButton.settings.press();
  // The backend was still told about the press; only the default action -
  // opening the camera - is what the veto cancels.
  expect(inst.pressed).toBe(1);
  expect(inst._oScanDialog).toBe(undefined);
});

test("capture() without the DOM elements returns false, never throws", () => {
  const { makeInstance } = load();
  expect(makeInstance().capture()).toBe(false);
});

test("capture() before the first frame logs, explains via status and keeps the dialog", () => {
  const { makeInstance, errors } = load({
    documentElements: captureDom({ videoWidth: 0, videoHeight: 0 }),
  });
  const inst = makeInstance();
  inst.onPicture(); // creates the dialog + status line

  expect(inst.capture()).toBe(false);
  expect(errors.some((m) => m.includes("camera not ready"))).toBe(true);
  expect(inst._oStatus.text).toContain("Camera not ready");
  expect(inst.photos).toHaveLength(0);
});

test("capture() stores the JPEG + thumbnail, fires OnPhoto and stops the camera", () => {
  const { makeInstance, created } = load({
    documentElements: captureDom(),
  });
  const inst = makeInstance();
  const track = { stopped: 0, stop() { this.stopped++; } };
  inst._stream = { getTracks: () => [track] };

  expect(inst.capture()).toBe(true);

  expect(inst._props.value).toBe("data:image/jpeg;base64,FULL");
  expect(inst._props.thumbnail).toBe("data:image/jpeg;base64,THUMB");
  expect(inst.photos).toEqual([{ photo: "data:image/jpeg;base64,FULL" }]);
  // the OS camera is released after a successful capture
  expect(track.stopped).toBe(1);
  expect(inst._stream).toBe(null);
  // the thumbnail keeps the aspect ratio at the fixed 300px width
  expect(created.thumbCanvases[0].width).toBe(300);
  expect(created.thumbCanvases[0].height).toBe(225);
});

test("a throwing toDataURL is logged and explained - capture returns false", () => {
  const { makeInstance, errors } = load({
    documentElements: captureDom({
      toDataURL: () => {
        throw new Error("tainted canvas");
      },
    }),
  });
  const inst = makeInstance();
  inst.onPicture();

  expect(inst.capture()).toBe(false);
  expect(errors.some((m) => m.includes("toDataURL failed"))).toBe(true);
  expect(inst._oStatus.text).toContain("Could not read");
});

test("a missing mediaDevices API sets the HTTPS status hint, never throws", async () => {
  const dom = captureDom();
  const { makeInstance, errors } = load({
    documentElements: dom,
    mediaDevices: undefined,
  });
  const inst = makeInstance();

  inst.onPicture();
  expect(inst._oScanDialog.opened).toBe(true);
  await inst._oScanDialog.afterOpenHandler();

  expect(inst._oStatus.text).toContain("secure (HTTPS) connection");
  expect(errors.some((m) => m.includes("mediaDevices API not available"))).toBe(
    true,
  );
});

test("a rejecting getUserMedia lands in the status line and the log", async () => {
  const dom = captureDom();
  const { makeInstance, errors } = load({
    documentElements: dom,
    mediaDevices: {
      getUserMedia: async () => {
        throw Object.assign(new Error("Permission denied"), {
          name: "NotAllowedError",
        });
      },
    },
  });
  const inst = makeInstance();

  inst.onPicture();
  await inst._oScanDialog.afterOpenHandler();

  expect(inst._oStatus.text).toContain("NotAllowedError");
  expect(errors.some((m) => m.includes("getUserMedia failed"))).toBe(true);
});

test("a stream resolving after the dialog was closed is stopped, not leaked", async () => {
  const dom = captureDom();
  const track = { stopped: 0, stop() { this.stopped++; } };
  let resolveStream;
  const { makeInstance } = load({
    documentElements: dom,
    mediaDevices: {
      getUserMedia: () => new Promise((resolve) => (resolveStream = resolve)),
    },
  });
  const inst = makeInstance();
  inst.onPicture();
  const pending = inst._oScanDialog.afterOpenHandler();

  // the user cancels while getUserMedia is still waiting for consent
  inst._oScanDialog.close();
  resolveStream({ getTracks: () => [track] });
  await pending;

  expect(track.stopped).toBe(1);
  expect(inst._stream).toBeFalsy();
});

test("a live stream is wired to the video and playback started", async () => {
  const dom = captureDom();
  dom["cam-video"].play = function () {
    this.played = (this.played || 0) + 1;
    return Promise.resolve();
  };
  const stream = { getTracks: () => [] };
  const { makeInstance } = load({
    documentElements: dom,
    mediaDevices: { getUserMedia: async () => stream },
  });
  const inst = makeInstance();

  inst.onPicture();
  await inst._oScanDialog.afterOpenHandler();
  await tick();

  expect(inst._stream).toBe(stream);
  expect(dom["cam-video"].srcObject).toBe(stream);
  expect(dom["cam-video"].played).toBe(1);
  expect(inst._oStatus.text).toContain("Camera ready");
});

test("the dialog is created once and reused across opens", () => {
  const { makeInstance } = load({ documentElements: captureDom() });
  const inst = makeInstance();

  inst.onPicture();
  const first = inst._oScanDialog;
  inst._oScanDialog.close();
  inst.onPicture();

  expect(inst._oScanDialog).toBe(first);
  // an already-open dialog is not re-opened
  inst.onPicture();
  expect(inst._oScanDialog).toBe(first);
});

test("exit() stops the camera and destroys the owned controls", () => {
  const { makeInstance } = load({ documentElements: captureDom() });
  const inst = makeInstance();
  inst.onPicture();
  const track = { stopped: 0, stop() { this.stopped++; } };
  inst._stream = { getTracks: () => [track] };
  const button = { destroyed: false, destroy() { this.destroyed = true; } };
  inst._oButton = button;

  inst.exit();

  expect(track.stopped).toBe(1);
  expect(button.destroyed).toBe(true);
  expect(inst._oScanDialog.destroyed).toBe(true);
});

test("exit() before any interaction is a no-op", () => {
  const { makeInstance } = load();
  makeInstance().exit();
});

test("onAfterRendering applies the height to the button DOM, px-defaulted", () => {
  const { makeInstance } = load();
  const inst = makeInstance({ height: "48" });
  const domRef = { style: {} };
  inst._oButton = { getDomRef: () => domRef };

  inst.onAfterRendering();
  expect(domRef.style.height).toBe("48px");

  inst._props.height = "3rem";
  inst.onAfterRendering();
  expect(domRef.style.height).toBe("3rem");
});

test("onAfterRendering without a rendered button is a no-op", () => {
  const { makeInstance } = load();
  makeInstance({ height: "48" }).onAfterRendering();
});
