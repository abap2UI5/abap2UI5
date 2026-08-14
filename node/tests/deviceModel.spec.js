// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// model/models.js builds the shared `device>` model every view slot carries.
// It wraps the LIVE sap.ui.Device object, which mutates itself on resize and
// rotation - but a JSONModel only notifies its bindings when told, so without
// the handlers the model builds, a {device>/resize/width} binding renders the
// width at load time and never moves again.
//
// These specs pin the two properties that makes: the handlers are attached to
// Device's own change sources, and /media/range - the one path a live
// breakpoint branch can bind, since Device.media exposes methods only - is
// seeded before the first render and rewritten on every change.

function loadModels({ range = "Desktop" } = {}) {
  const handlers = { resize: [], orientation: [], media: [] };
  const Device = {
    resize: { width: 1400, height: 900, attachHandler: (fn) => handlers.resize.push(fn) },
    orientation: { landscape: true, portrait: false, attachHandler: (fn) => handlers.orientation.push(fn) },
    system: { phone: false, tablet: false, desktop: true },
    media: {
      current: range,
      rangeSets: [],
      hasRangeSet(name) { return this.rangeSets.includes(name); },
      initRangeSet(name) { this.rangeSets.push(name); },
      getCurrentRange() { return { name: this.media_current ?? this.current }; },
      attachHandler: (fn) => handlers.media.push(fn),
    },
  };

  const set = {};
  let refreshed = 0;
  const oModel = {
    setDefaultBindingMode(mode) { this.mode = mode; },
    setProperty(path, value) { set[path] = value; },
    refresh() { refreshed += 1; },
  };

  const { module: models } = loadModule("model/models.js", {
    deps: {
      "sap/ui/model/json/JSONModel": function () { return oModel; },
      "sap/ui/Device": Device,
    },
  });
  return { models, Device, handlers, oModel, set, refreshed: () => refreshed };
}

test.describe("createDeviceModel", () => {
  test("stays a read-only model over the live Device object", () => {
    const { models, oModel } = loadModels();
    const m = models.createDeviceModel();
    expect(m).toBe(oModel);
    expect(oModel.mode).toBe("OneWay");
  });

  test("seeds /media/range before the first render", () => {
    const { models, set, refreshed } = loadModels({ range: "Desktop" });
    models.createDeviceModel();
    // Device.media has no bindable property, so the current range name is
    // published onto the model - and it must already be there on first paint
    expect(set["/media/range"]).toBe("Desktop");
    expect(refreshed()).toBe(1);
  });

  test("initialises the Std range set the bindings read", () => {
    const { models, Device } = loadModels();
    models.createDeviceModel();
    expect(Device.media.rangeSets).toEqual(["Std"]);
  });

  test("leaves an already initialised range set alone", () => {
    const { models, Device } = loadModels();
    // "Std" is UI5's predefined set - whoever touched Device.media first has
    // usually initialised it, and initialising it again logs "Range set Std
    // has already been initialized" into every app start
    Device.media.rangeSets.push("Std");
    models.createDeviceModel();
    expect(Device.media.rangeSets).toEqual(["Std"]);
  });

  test("refreshes on resize, rotation and a range change", () => {
    const { models, handlers, refreshed } = loadModels();
    models.createDeviceModel();
    expect(handlers.resize).toHaveLength(1);
    expect(handlers.orientation).toHaveLength(1);
    expect(handlers.media).toHaveLength(1);

    const before = refreshed();
    handlers.resize[0]();
    handlers.orientation[0]();
    handlers.media[0]();
    // three changes, three notifications - a binding that was stale before
    // this change now moves with the viewport
    expect(refreshed()).toBe(before + 3);
  });

  test("rewrites /media/range when the breakpoint changes", () => {
    const { models, Device, handlers, set } = loadModels({ range: "Desktop" });
    models.createDeviceModel();
    expect(set["/media/range"]).toBe("Desktop");

    Device.media.current = "Phone";
    handlers.resize[0]();
    expect(set["/media/range"]).toBe("Phone");
  });

  test("survives a runtime with no current range", () => {
    const { models, Device, set } = loadModels();
    Device.media.getCurrentRange = () => null;
    models.createDeviceModel();
    expect(set["/media/range"]).toBe("");
  });
});
