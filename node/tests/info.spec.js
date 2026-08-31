// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/Info.js (obsolete, replaced by client.get().s_device / s_ui5): reports
// the UI5 version/theme and the device info back to the backend once, via
// its bindable properties, then fires `finished`. The one behavior worth
// pinning is the ONE-SHOT: the pending flag is armed in init(), not by the
// renderer - the renderer version re-fired `finished` per render, and an
// app that answers the event with a roundtrip that rebuilds the view closed
// a loop (render -> finished -> roundtrip -> rebuild -> render). The values
// are session-constant, so once is also all the event can ever say.

const DEVICE_DATA = {
  system: { phone: false, desktop: true, tablet: false, combi: false },
  resize: { height: 1080, width: 1920 },
  os: { name: "win" },
  browser: { name: "cr" },
};

function load({ deviceData = DEVICE_DATA, oConfig } = {}) {
  const { Lib, sandbox: libSandbox } = loadLib();

  // the device model reaches the control via MAIN-view model propagation;
  // a spec can start without it (first render of a freshly built view)
  let model = deviceData ? { getData: () => deviceData } : undefined;

  const { module: InfoDef } = loadModule("cc/Info.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": {
        getView: (key) =>
          key === "MAIN"
            ? { getModel: (name) => (name === "device" ? model : undefined) }
            : undefined,
      },
      "z2ui5/core/AppState": {
        getGlobal: (name) => (name === "oConfig" ? oConfig : undefined),
      },
    },
  });

  const instance = () => {
    const inst = Object.create(InfoDef);
    inst._set = {};
    inst.setProperty = (prop, val, suppress) => {
      inst._set[prop] = { val, suppress };
    };
    inst.fired = 0;
    inst.fireFinished = () => inst.fired++;
    return inst;
  };

  return {
    instance,
    attachDeviceModel: () => {
      model = { getData: () => DEVICE_DATA };
    },
    errors: () => libSandbox.z2ui5.errors || [],
  };
}

test("reports the device and UI5 info once and fires finished", () => {
  const { instance } = load({
    oConfig: { S_UI5: { VERSION: "1.144.0", THEME: "sap_horizon", GAV: "g" } },
  });
  const inst = instance();
  inst.init();

  inst.onAfterRendering();

  expect(inst.fired).toBe(1);
  const values = Object.fromEntries(
    Object.entries(inst._set).map(([k, v]) => [k, v.val]),
  );
  expect(values).toEqual({
    ui5_version: "1.144.0",
    device_phone: "false",
    device_desktop: "true",
    device_tablet: "false",
    device_combi: "false",
    device_height: "1080",
    device_width: "1920",
    ui5_theme: "sap_horizon",
    ui5_gav: "g",
    device_systemtype: "desktop",
    device_os: "win",
    device_browser: "cr",
  });
  // invisible control - every write suppresses the no-op invalidation
  for (const entry of Object.values(inst._set)) {
    expect(entry.suppress).toBe(true);
  }
});

test("one-shot: a re-render does not fire finished again", () => {
  const { instance } = load();
  const inst = instance();
  inst.init();

  inst.onAfterRendering();
  inst.onAfterRendering();

  expect(inst.fired).toBe(1);
});

// The device model arrives by propagation and may not be attached on the
// very first rendering of a freshly built view - the pending flag must
// survive that pass so the next rendering retries, instead of being
// consumed with `finished` never firing at all.
test("no device model yet: the pending pass is kept for the next render", () => {
  const { instance, attachDeviceModel } = load({ deviceData: null });
  const inst = instance();
  inst.init();

  inst.onAfterRendering();
  expect(inst.fired).toBe(0);

  attachDeviceModel();
  inst.onAfterRendering();
  expect(inst.fired).toBe(1);
});

test("a missing oConfig reports empty UI5 fields, not 'undefined'", () => {
  const { instance } = load();
  const inst = instance();
  inst.init();

  inst.onAfterRendering();

  expect(inst._set.ui5_version.val).toBe("");
  expect(inst._set.ui5_theme.val).toBe("");
  expect(inst._set.ui5_gav.val).toBe("");
});

test("exit() disarms the pending pass", () => {
  const { instance } = load();
  const inst = instance();
  inst.init();
  inst.exit();

  inst.onAfterRendering();

  expect(inst.fired).toBe(0);
});

test("a throwing device model is logged, never thrown", () => {
  const { instance, errors } = load({
    deviceData: {
      get system() {
        throw new Error("model gone");
      },
    },
  });
  const inst = instance();
  inst.init();

  expect(() => inst.onAfterRendering()).not.toThrow();
  expect(errors().some((e) => e.message.includes("Info"))).toBe(true);
});
