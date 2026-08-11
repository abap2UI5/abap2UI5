// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests Server._sessionConfig: what a browser tells the backend about ITSELF
// travels once per page load, not with every roundtrip. The backend stores it
// with the draft, so a follow-up request omits it - but two device fields are
// not session-constant and have to keep going out.

function loadServer(Device) {
  const { module: Server } = loadModule("core/Server.js", {
    deps: {
      "sap/ui/Device": Device,
      "sap/ui/core/Element": {},
      "z2ui5/core/Lib": loadLib().Lib,
    },
    sandbox: { window: { innerWidth: 1024, innerHeight: 768 } },
  });
  return Server;
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
  const Server = loadServer(device());
  const out = Server._sessionConfig(CONFIG);
  expect(out.S_UI5).toEqual({ VERSION: "1.120.0" });
  expect(out.ComponentData).toEqual({ a: 1 });
  expect(out.S_DEVICE.OS).toEqual({ NAME: "Windows", VERSION: "11" });
  expect(out.S_DEVICE.ORIENTATION).toBe("portrait");
});

test("a later roundtrip sends only what can still change", () => {
  const Server = loadServer(device({ portrait: false, width: 900 }));
  Server._sessionConfig(CONFIG);
  const out = Server._sessionConfig(CONFIG);
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
  const Server = loadServer(device());
  const first = Server._sessionConfig({});
  expect(first.S_DEVICE.SYSTEM).toBeDefined();

  const second = Server._sessionConfig({});
  expect(second.S_DEVICE.SYSTEM).toBeDefined();

  Server._sessionConfig(CONFIG);
  const fourth = Server._sessionConfig(CONFIG);
  expect(fourth.S_DEVICE.SYSTEM).toBeUndefined();
});
