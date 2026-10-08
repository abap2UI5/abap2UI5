// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, classEnv } = require("./loadLibModule");

// cc/CameraSelector.js: a ComboBox pre-filled with the device's cameras.
// The contract under test:
//   - init() is a UI5 lifecycle listener and must not be async (AGENTS.md
//     rule 10) - it kicks off _loadCameras separately and stays sync.
//   - "log, never throw": a missing/rejecting mediaDevices API is logged
//     via Lib.logError, never surfaced or thrown.
//   - destroyed-guard: the control may be destroyed during the await; no
//     item may be added afterwards.
function load({ mediaDevices } = {}) {
  const errors = [];
  // The real Lib so isDestroyed is the shipped one; only logError is
  // replaced to capture the messages.
  const Lib = { ...loadLib().Lib, logError: (m) => errors.push(m) };

  // Base ComboBox stub: the control chains ComboBox.prototype.init.
  function ComboBoxBase() {}
  ComboBoxBase.prototype.init = function () {
    this.baseInitCalls = (this.baseInitCalls || 0) + 1;
  };
  ComboBoxBase.extend = (_name, def) => {
    function Ctrl() {}
    Ctrl.prototype = Object.create(ComboBoxBase.prototype);
    Object.assign(Ctrl.prototype, def);
    return Ctrl;
  };
  // the settings object of a real Item parses its strings as binding
  // syntax; `parsed` records whether anything came in that way
  class Item {
    constructor(settings) {
      this.key = settings?.key;
      this.text = settings?.text;
      this.parsed = settings !== undefined;
    }
    setKey(key) {
      this.key = key;
    }
    setText(text) {
      this.text = text;
    }
  }

  const { module: CameraSelector } = loadModule("cc/CameraSelector.js", {
    deps: {
      "z2ui5/core/Env": classEnv,
      "sap/m/ComboBox": ComboBoxBase,
      "sap/ui/core/Item": Item,
      "sap/m/ComboBoxRenderer": {},
      "z2ui5/core/Lib": Lib,
    },
    sandbox: { navigator: { mediaDevices } },
  });

  function makeInstance() {
    const inst = new CameraSelector();
    inst.items = [];
    inst.addItem = (item) => inst.items.push(item);
    inst.destroyItems = () => (inst.items = []);
    inst.loadItemsHandlers = [];
    inst.attachLoadItems = (fn) => inst.loadItemsHandlers.push(fn);
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    return inst;
  }

  return { makeInstance, errors };
}

const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

test("init chains the base init synchronously and fills only video inputs", async () => {
  const { makeInstance } = load({
    mediaDevices: {
      enumerateDevices: async () => [
        { kind: "audioinput", deviceId: "mic1", label: "Microphone" },
        { kind: "videoinput", deviceId: "cam1", label: "Front Camera" },
        { kind: "videoinput", deviceId: "cam2", label: "Back Camera" },
      ],
    },
  });
  const inst = makeInstance();

  // must not return a value (an async init would return a Promise, which
  // UI5 2.x _enforceNoReturnValue treats as FUTURE FATAL)
  expect(inst.init()).toBeUndefined();
  expect(inst.baseInitCalls).toBe(1);

  await tick();
  expect(inst.items.map((i) => ({ key: i.key, text: i.text }))).toEqual([
    { key: "cam1", text: "Front Camera" },
    { key: "cam2", text: "Back Camera" },
  ]);
});

test("a missing mediaDevices API is a silent no-op", async () => {
  const { makeInstance, errors } = load({ mediaDevices: undefined });
  const inst = makeInstance();

  inst.init();
  await tick();

  expect(inst.items).toHaveLength(0);
  expect(errors).toHaveLength(0);
});

test("a rejecting enumerateDevices is logged, never thrown", async () => {
  const { makeInstance, errors } = load({
    mediaDevices: {
      enumerateDevices: async () => {
        throw new Error("not allowed");
      },
    },
  });
  const inst = makeInstance();

  inst.init();
  await tick();

  expect(inst.items).toHaveLength(0);
  expect(errors.some((m) => m.includes("enumerateDevices failed"))).toBe(true);
});

test("no items are added when the control was destroyed during the await", async () => {
  let resolveDevices;
  const { makeInstance } = load({
    mediaDevices: {
      enumerateDevices: () =>
        new Promise((resolve) => (resolveDevices = resolve)),
    },
  });
  const inst = makeInstance();
  inst.init();

  // torn down while enumerateDevices was still pending
  inst._destroyed = true;
  resolveDevices([{ kind: "videoinput", deviceId: "cam1", label: "Cam" }]);
  await tick();

  expect(inst.items).toHaveLength(0);
});

test("an empty or undefined device list adds nothing", async () => {
  const { makeInstance, errors } = load({
    mediaDevices: { enumerateDevices: async () => undefined },
  });
  const inst = makeInstance();

  inst.init();
  await tick();

  expect(inst.items).toHaveLength(0);
  expect(errors).toHaveLength(0);
});

// Before the permission a browser lists each camera with an empty id and
// label; granting it fires no devicechange in Chromium. Read once, the list
// kept one blank entry - it is read again when the dropdown opens.
test("cameras listed before the permission are skipped, and the list is re-read on open", async () => {
  let devices = [{ kind: "videoinput", deviceId: "", label: "" }];
  const { makeInstance } = load({
    mediaDevices: { enumerateDevices: async () => devices },
  });
  const inst = makeInstance();
  inst.init();
  await tick();
  expect(inst.items).toHaveLength(0);

  // the permission was granted meanwhile (CameraPicture's getUserMedia)
  devices = [{ kind: "videoinput", deviceId: "cam1", label: "Cam {front}" }];
  for (const fn of inst.loadItemsHandlers) fn();
  await tick();
  expect(inst.items.map((i) => [i.key, i.text, i.parsed])).toEqual([
    ["cam1", "Cam {front}", false],
  ]);
});
