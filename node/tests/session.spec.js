// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests Session.config: what a browser tells the backend about ITSELF
// travels once per page load, not with every roundtrip. The backend stores it
// with the draft, so a follow-up request omits it - but two device fields are
// not session-constant and have to keep going out.

function loadSession(Device) {
  const { module: Session } = loadModule("core/Session.js", {
    deps: {
      "sap/ui/Device": Device,
      "z2ui5/core/Lib": loadLib().Lib,
    },
    sandbox: { window: { innerWidth: 1024, innerHeight: 768 } },
  });
  return Session;
}

function device({ portrait = true, width = 400, height = 800 } = {}) {
  return {
    system: { desktop: true },
    browser: { name: "chrome", version: 120 },
    os: { name: "Windows", version: 11 },
    support: { touch: false, pointer: true, retina: false },
    orientation: { portrait },
    resize: { width, height },
  };
}

const CONFIG = { S_UI5: { VERSION: "1.120.0" }, ComponentData: { a: 1 } };

test("the first roundtrip carries the whole block", () => {
  const Session = loadSession(device());
  const out = Session.config(CONFIG);
  expect(out.S_UI5).toEqual({ VERSION: "1.120.0" });
  expect(out.ComponentData).toEqual({ a: 1 });
  expect(out.S_DEVICE.OS).toEqual({ NAME: "Windows", VERSION: "11" });
  expect(out.S_DEVICE.ORIENTATION).toBe("portrait");
});

test("a later roundtrip sends only what can still change", () => {
  const Session = loadSession(device({ portrait: false, width: 900 }));
  Session.config(CONFIG);
  const out = Session.config(CONFIG);
  expect(out.S_UI5).toBeUndefined();
  expect(out.ComponentData).toBeUndefined();
  // no OS/BROWSER/SUPPORT/SYSTEM - the backend answers those from the draft
  expect(Object.keys(out.S_DEVICE).sort()).toEqual(["ORIENTATION", "RESIZE"]);
  expect(out.S_DEVICE.ORIENTATION).toBe("landscape");
  expect(out.S_DEVICE.RESIZE.WIDTH).toBe(900);
});

test("keeps sending until the version info has actually arrived", () => {
  // _initVersionInfo is async, so the first roundtrip can fire before
  // oConfig.S_UI5 exists. Stopping after one send would mean the backend
  // never receives it at all.
  const Session = loadSession(device());
  const first = Session.config({});
  expect(first.S_DEVICE.SYSTEM).toBeDefined();

  const second = Session.config({});
  expect(second.S_DEVICE.SYSTEM).toBeDefined();

  Session.config(CONFIG);
  const fourth = Session.config(CONFIG);
  expect(fourth.S_DEVICE.SYSTEM).toBeUndefined();
});
