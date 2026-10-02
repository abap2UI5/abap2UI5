// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, classEnv } = require("./loadLibModule");

// cc/NativeBridgeScan.js: scan button for the native mobile shell, which
// injects window.abap2ui5Native (abap2UI5/mobile-shell, bridge contract v1).
// The contract under test:
//   - "delegate, never decide" (AGENTS.md rule 10): a scanned value lands in
//     `value` and fires OnScan; a failure or a cancelled scan fires OnError
//     with the bridge's message - never thrown, no UI.
//   - outside the shell the control renders an invisible placeholder (unless
//     showInBrowser) and renders again once the shim announces itself.
//   - destroyed-guard: a scan settling after teardown is a silent no-op.
function load({ native } = {}) {
  const errors = [];
  const Lib = { ...loadLib().Lib, logError: (m) => errors.push(m) };

  const listeners = new Map();
  const win = {
    abap2ui5Native: native,
    addEventListener: (name, fn) => listeners.set(name, fn),
    removeEventListener: (name, fn) => {
      if (listeners.get(name) === fn) listeners.delete(name);
    },
  };

  const buttons = [];
  class Button {
    constructor(settings) {
      this.settings = settings;
      this.destroyed = false;
      buttons.push(this);
    }
    setText(t) {
      this.text = t;
    }
    setIcon(i) {
      this.icon = i;
    }
    setEnabled(e) {
      this.enabled = e;
    }
    destroy() {
      this.destroyed = true;
    }
  }

  const { module: NativeBridgeScan } = loadModule("cc/NativeBridgeScan.js", {
    deps: {
      "z2ui5/core/Env": classEnv,
      "sap/ui/core/Control": {
        extend(_name, def) {
          function Ctrl() {}
          Object.assign(Ctrl.prototype, def);
          Ctrl.renderer = def.renderer;
          return Ctrl;
        },
      },
      "sap/m/Button": Button,
      "z2ui5/core/Lib": Lib,
    },
    sandbox: { window: win },
  });

  function makeInstance(props = {}) {
    const inst = new NativeBridgeScan();
    inst._props = {
      value: "",
      text: "Scan",
      icon: "sap-icon://bar-code",
      enabled: true,
      showInBrowser: false,
      ...props,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.getText = () => inst._props.text;
    inst.getIcon = () => inst._props.icon;
    inst.getEnabled = () => inst._props.enabled;
    inst.getShowInBrowser = () => inst._props.showInBrowser;
    inst.scans = [];
    inst.errorEvents = [];
    inst.invalidations = 0;
    inst.fireOnScan = (p) => inst.scans.push(p);
    inst.fireOnError = (p) => inst.errorEvents.push(p);
    inst.invalidate = () => inst.invalidations++;
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    inst.init();
    return inst;
  }

  // Renders through the control's renderer into a recording RenderManager.
  function render(inst) {
    const out = [];
    const rm = {
      openStart: (tag) => out.push(`open:${tag}`),
      style: () => {},
      openEnd: () => {},
      close: (tag) => out.push(`close:${tag}`),
      renderControl: (c) => out.push(c),
    };
    NativeBridgeScan.renderer.render(rm, inst);
    return out;
  }

  return { makeInstance, render, errors, win, listeners, buttons };
}

// A bridge whose scanBarcode( ) the spec settles by hand.
function manualBridge() {
  const calls = [];
  return {
    calls,
    native: {
      available: true,
      scanBarcode: () =>
        new Promise((resolve, reject) => calls.push({ resolve, reject })),
    },
  };
}

test("a scanned value lands in value and fires OnScan", async () => {
  const { calls, native } = manualBridge();
  const { makeInstance } = load({ native });
  const inst = makeInstance();

  const done = inst.scan();
  calls[0].resolve("4006381333931");
  await done;

  expect(inst._props.value).toBe("4006381333931");
  expect(inst.scans).toEqual([{ value: "4006381333931" }]);
  expect(inst.errorEvents).toEqual([]);
});

test("a cancelled scan fires OnError without a log line", async () => {
  const { calls, native } = manualBridge();
  const { makeInstance, errors } = load({ native });
  const inst = makeInstance();

  const done = inst.scan();
  calls[0].reject(new Error("cancelled"));
  await done;

  expect(inst.errorEvents).toEqual([{ message: "cancelled" }]);
  expect(inst.scans).toEqual([]);
  expect(errors).toEqual([]);
});

test("a failing scan is logged and fired as OnError - never thrown", async () => {
  const { makeInstance, errors } = load({
    native: {
      scanBarcode: () => {
        throw new Error("unsupported");
      },
    },
  });
  const inst = makeInstance();

  await inst.scan();

  expect(inst.errorEvents).toEqual([{ message: "unsupported" }]);
  expect(errors.some((m) => m.includes("unsupported"))).toBe(true);
});

test("a press outside the shell fires OnError", () => {
  const { makeInstance } = load();
  const inst = makeInstance({ showInBrowser: true });

  expect(inst.scan()).toBeUndefined();
  expect(inst.errorEvents).toEqual([{ message: "native shell not available" }]);
});

test("a second press while a scan is open starts no second scan", async () => {
  const { calls, native } = manualBridge();
  const { makeInstance } = load({ native });
  const inst = makeInstance();

  const first = inst.scan();
  expect(inst.scan()).toBeUndefined();
  expect(calls.length).toBe(1);

  calls[0].resolve("A");
  await first;
  inst.scan();
  expect(calls.length).toBe(2);
});

test("a scan settling after teardown fires nothing", async () => {
  const { calls, native } = manualBridge();
  const { makeInstance } = load({ native });
  const inst = makeInstance();

  const done = inst.scan();
  inst._destroyed = true;
  calls[0].resolve("late");
  await done;

  expect(inst.scans).toEqual([]);
  expect(inst._props.value).toBe("");
});

test("outside the shell the control renders an invisible placeholder", () => {
  const { makeInstance, render, buttons } = load();
  const inst = makeInstance();

  expect(render(inst)).toEqual(["open:span", "close:span"]);
  expect(buttons.length).toBe(0);
});

test("showInBrowser renders the button without a bridge", () => {
  const { makeInstance, render, buttons } = load();
  const inst = makeInstance({ showInBrowser: true, text: "Scan Material" });

  const out = render(inst);
  expect(out).toEqual([buttons[0]]);
  expect(buttons[0].text).toBe("Scan Material");
});

test("inside the shell the button carries text, icon and enabled", () => {
  const { native } = manualBridge();
  const { makeInstance, render, buttons, listeners } = load({ native });
  const inst = makeInstance({ enabled: false });

  render(inst);
  render(inst);
  expect(buttons.length).toBe(1);
  expect(buttons[0].icon).toBe("sap-icon://bar-code");
  expect(buttons[0].enabled).toBe(false);
  // nothing to wait for when the bridge is already there
  expect(listeners.size).toBe(0);
});

// The Android shell injects the shim after the page has loaded - possibly
// after the first render. The control must not stay invisible for good.
test("a bridge arriving after the first render renders the control again", () => {
  const { native } = manualBridge();
  const { makeInstance, render, win, listeners } = load();
  const inst = makeInstance();

  render(inst);
  expect(listeners.has("abap2ui5native:ready")).toBe(true);

  win.abap2ui5Native = native;
  listeners.get("abap2ui5native:ready")();

  expect(inst.invalidations).toBe(1);
  expect(listeners.size).toBe(0);
});

test("exit stops waiting for the bridge and destroys the button", () => {
  const { makeInstance, render, listeners, buttons } = load();
  const inst = makeInstance({ showInBrowser: true });

  render(inst);
  inst.exit();

  expect(listeners.size).toBe(0);
  expect(buttons[0].destroyed).toBe(true);
});

test("an object without scanBarcode under the name is no bridge", () => {
  const { makeInstance, render } = load({ native: { available: true } });
  const inst = makeInstance();

  expect(render(inst)).toEqual(["open:span", "close:span"]);
});
