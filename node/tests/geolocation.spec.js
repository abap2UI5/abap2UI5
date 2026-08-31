// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// cc/Geolocation.js: reads the device position once after rendering into its
// bindable properties and fires `finished`. The contract under test:
//   - "delegate, never decide" (AGENTS.md rule 10): a failure is logged via
//     Lib.logError and reported through the `error` EVENT (code/message) -
//     the control never throws and never shows a MessageBox.
//   - destroyed-guard: the async geolocation callbacks landing after the
//     control was torn down must be silent no-ops.
//   - the read runs exactly once per control lifetime.
function load({ navigator } = {}) {
  const errors = [];
  // The real Lib so toText/isDestroyed are the shipped ones; only logError
  // is replaced to capture the messages.
  const Lib = { ...loadLib().Lib, logError: (m) => errors.push(m) };
  const { module: Geolocation } = loadModule("cc/Geolocation.js", {
    deps: {
      "sap/ui/core/Control": {
        extend(_name, def) {
          function Ctrl() {}
          Object.assign(Ctrl.prototype, def);
          return Ctrl;
        },
      },
      "z2ui5/core/Lib": Lib,
    },
    sandbox: { navigator: navigator ?? {} },
  });

  function makeInstance(props = {}) {
    const inst = new Geolocation();
    inst._props = {
      longitude: "",
      latitude: "",
      altitude: "",
      accuracy: "",
      altitudeAccuracy: "",
      speed: "",
      heading: "",
      enableHighAccuracy: false,
      timeout: "5000",
      ...props,
    };
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => (inst._props[k] = v);
    inst.finished = 0;
    inst.errorEvents = [];
    inst.fireFinished = () => inst.finished++;
    inst.fireError = (p) => inst.errorEvents.push(p);
    inst._destroyed = false;
    inst.isDestroyed = () => inst._destroyed;
    inst.init();
    return inst;
  }

  return { makeInstance, errors };
}

// A geolocation API stub that records the getCurrentPosition calls so the
// specs can inspect the options and drive the callbacks by hand.
function geoApi() {
  const calls = [];
  return {
    calls,
    navigator: {
      geolocation: {
        getCurrentPosition: (ok, err, opts) => calls.push({ ok, err, opts }),
      },
    },
  };
}

test("a position lands in the properties as text and fires finished", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance } = load({ navigator });
  const inst = makeInstance();

  inst.onAfterRendering();
  calls[0].ok({
    coords: {
      longitude: 11.57,
      latitude: 48.13,
      altitude: null, // Coordinates fields are null when unsupported
      accuracy: 20,
      altitudeAccuracy: null,
      speed: 0,
      heading: null,
    },
  });

  expect(inst._props.longitude).toBe("11.57");
  expect(inst._props.latitude).toBe("48.13");
  // null must become the empty string (Lib.toText), never "null"
  expect(inst._props.altitude).toBe("");
  expect(inst._props.altitudeAccuracy).toBe("");
  expect(inst._props.heading).toBe("");
  // a legitimate zero is kept
  expect(inst._props.speed).toBe("0");
  expect(inst.finished).toBe(1);
});

test("a geolocation error is logged and fired as event - never thrown, no UI", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance, errors } = load({ navigator });
  const inst = makeInstance();

  inst.onAfterRendering();
  calls[0].err({ code: 1, message: "User denied Geolocation" });

  expect(errors.some((m) => m.includes("Geolocation error (1)"))).toBe(true);
  expect(inst.errorEvents).toEqual([
    { code: "1", message: "User denied Geolocation" },
  ]);
  expect(inst.finished).toBe(0);
});

test("a missing geolocation API is a silent no-op", () => {
  const { makeInstance, errors } = load({ navigator: {} });
  const inst = makeInstance();

  inst.onAfterRendering();

  expect(inst.finished).toBe(0);
  expect(inst.errorEvents).toHaveLength(0);
  expect(errors).toHaveLength(0);
});

test("a synchronously throwing getCurrentPosition is logged, not thrown", () => {
  const { makeInstance, errors } = load({
    navigator: {
      geolocation: {
        getCurrentPosition: () => {
          throw new Error("insecure context");
        },
      },
    },
  });
  const inst = makeInstance();

  inst.onAfterRendering();

  expect(errors.some((m) => m.includes("getCurrentPosition failed"))).toBe(
    true,
  );
});

test("callbacks landing after destroy are silent no-ops", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance, errors } = load({ navigator });
  const inst = makeInstance();
  inst.onAfterRendering();

  // the control was torn down while the geolocation API was busy
  inst._destroyed = true;
  calls[0].ok({ coords: { longitude: 1 } });
  calls[0].err({ code: 3, message: "Timeout" });

  expect(inst._props.longitude).toBe("");
  expect(inst.finished).toBe(0);
  expect(inst.errorEvents).toHaveLength(0);
  expect(errors).toHaveLength(0);
});

test("the position is read exactly once per control lifetime", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance } = load({ navigator });
  const inst = makeInstance();

  inst.onAfterRendering();
  inst.onAfterRendering();

  expect(calls).toHaveLength(1);
});

test("exit() cancels a pending read", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance } = load({ navigator });
  const inst = makeInstance();

  inst.exit();
  inst.onAfterRendering();

  expect(calls).toHaveLength(0);
});

test("options pass enableHighAccuracy and the numeric timeout through", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance } = load({ navigator });
  makeInstance({ enableHighAccuracy: true, timeout: "250" }).onAfterRendering();

  expect(calls[0].opts).toEqual({ enableHighAccuracy: true, timeout: 250 });
});

test("an empty or non-numeric timeout falls back to the default", () => {
  const { calls, navigator } = geoApi();
  const { makeInstance } = load({ navigator });
  makeInstance({ timeout: "" }).onAfterRendering();
  makeInstance({ timeout: "soon" }).onAfterRendering();

  // NaN or 0 would make getCurrentPosition fail immediately
  expect(calls[0].opts.timeout).toBe(5000);
  expect(calls[1].opts.timeout).toBe(5000);
});
