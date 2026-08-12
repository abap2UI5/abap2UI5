// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests Session.config: what a browser tells the backend about ITSELF
// travels once per page load, not with every roundtrip. The backend stores it
// with the draft, so a follow-up request omits it - the two device fields
// that are not session-constant travel again only when they CHANGED. The
// send latches advance in confirmSent( ), called by Server.readHttp once
// the carrying request won its stale guard - a dropped request re-sends.

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

test("a later roundtrip sends the live fields only when they changed", () => {
  const dev = device({ portrait: false, width: 900 });
  const Session = loadSession(dev);
  Session.config(CONFIG);
  Session.confirmSent(Session.takePending());

  // nothing changed - the whole block is left off (event roundtrips carry
  // a draft id)
  expect(Session.config(CONFIG, "DRAFT1")).toEqual({});

  // a rotation/resize travels once...
  dev.orientation.portrait = true;
  dev.resize.width = 400;
  const out = Session.config(CONFIG, "DRAFT1");
  expect(out.S_UI5).toBeUndefined();
  expect(out.ComponentData).toBeUndefined();
  // no OS/BROWSER/SUPPORT/SYSTEM - the backend answers those from the draft
  expect(Object.keys(out.S_DEVICE).sort()).toEqual(["ORIENTATION", "RESIZE"]);
  expect(out.S_DEVICE.ORIENTATION).toBe("portrait");
  expect(out.S_DEVICE.RESIZE.WIDTH).toBe(400);

  // ...and is latched again once the carrying request won
  Session.confirmSent(Session.takePending());
  expect(Session.config(CONFIG, "DRAFT1")).toEqual({});

  // an app-start-shaped request (no draft id) re-sends the WHOLE block: it
  // may start a fresh app whose backend session record is empty
  expect(Session.config(CONFIG, undefined).S_DEVICE.SYSTEM).toBeDefined();
});

test("a dropped request does not latch - the next one re-sends", () => {
  const dev = device({ portrait: false, width: 900 });
  const Session = loadSession(dev);
  Session.config(CONFIG);
  Session.confirmSent(Session.takePending());

  // the rotation's roundtrip is built but never wins (aborted/superseded):
  // confirmSent is not called, so the value must travel again
  dev.orientation.portrait = true;
  expect(Session.config(CONFIG, "D1").S_DEVICE.ORIENTATION).toBe("portrait");
  expect(Session.config(CONFIG, "D1").S_DEVICE.ORIENTATION).toBe("portrait");

  Session.confirmSent(Session.takePending());
  expect(Session.config(CONFIG, "D1")).toEqual({});
});

test("keeps sending until the version info has actually arrived", () => {
  // _initVersionInfo is async, so the first roundtrip can fire before
  // oConfig.S_UI5 exists. Stopping after one send would mean the backend
  // never receives it at all.
  const Session = loadSession(device());
  const first = Session.config({});
  Session.confirmSent(Session.takePending());
  expect(first.S_DEVICE.SYSTEM).toBeDefined();

  const second = Session.config({});
  Session.confirmSent(Session.takePending());
  expect(second.S_DEVICE.SYSTEM).toBeDefined();

  Session.config(CONFIG);
  Session.confirmSent(Session.takePending());
  // stored now - and the unchanged live fields are latched too, so the
  // follow-up event roundtrip sends nothing at all
  expect(Session.config(CONFIG, "DRAFT1")).toEqual({});
});
