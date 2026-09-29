// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// controller/App.controller.js: the shell controller's one-time startup
// wiring. Under test: the backend-URL decision (a host's endpoint vs. the
// page URL in local mode vs. the manifest URI), one View1 controller
// instance per view slot (driven by the ViewSlots table, not a hardcoded
// list), the app container lookup, and the initial roundtrip kick-off.
function load({
  manifest,
  checkLocal = false,
  endpoint = null,
  embedded = false,
  app = { id: "app" },
  href = "http://localhost:3000/",
} = {}) {
  // the controller reads the owner component's context (Context.of)
  const state = { checkLocal, endpoint, embedded };
  const ctx = { state, alive: true };
  const roundtrips = [];
  class View1Controller {}
  const slots = [
    { controllerProp: "oController" },
    { controllerProp: "oControllerNest" },
    { controllerProp: "oControllerNest2" },
  ];

  const { module: AppController } = loadModule("controller/App.controller.js", {
    deps: {
      "sap/ui/core/mvc/Controller": { extend: (_name, def) => def },
      "z2ui5/controller/View1.controller": View1Controller,
      "z2ui5/core/Server": { roundtrip: (c) => roundtrips.push(c) },
      "z2ui5/core/Context": { of: (component) => (component ? ctx : null) },
      "z2ui5/core/ViewSlots": { slots },
    },
    sandbox: { window: { location: { href } } },
  });

  const component = { getManifest: () => manifest };
  const byIdCalls = [];
  const view = {
    byId: (id) => {
      byIdCalls.push(id);
      return app;
    },
  };
  const inst = Object.create(AppController);
  inst.getOwnerComponent = () => component;
  inst.getView = () => view;

  return {
    inst,
    ctx,
    state,
    roundtrips,
    component,
    byIdCalls,
    View1Controller,
    slots,
  };
}

const MANIFEST = {
  "sap.app": { dataSources: { http: { uri: "/sap/bc/z2ui5" } } },
};

test("standalone: the backend URL comes from the manifest data source", () => {
  const { inst, state } = load({ manifest: MANIFEST });

  inst.onInit();

  expect(state.url).toBe("/sap/bc/z2ui5");
});

test("local mode (checkLocal) uses the page URL instead", () => {
  const { inst, state } = load({
    manifest: MANIFEST,
    checkLocal: true,
    href: "http://localhost:3000/?app_start=x",
  });

  inst.onInit();

  expect(state.url).toBe("http://localhost:3000/?app_start=x");
});

// A host app embedding the component names the backend itself
// (componentData.endpoint, split off in Component.init).
test("a host's endpoint wins over the manifest data source", () => {
  const { inst, state } = load({
    manifest: MANIFEST,
    endpoint: "/sap/bc/z2ui5_other",
  });

  inst.onInit();

  expect(state.url).toBe("/sap/bc/z2ui5_other");
});

test("a host's endpoint wins over the page URL of local mode too", () => {
  const { inst, state } = load({
    manifest: MANIFEST,
    checkLocal: true,
    endpoint: "/sap/bc/z2ui5_other",
  });

  inst.onInit();

  expect(state.url).toBe("/sap/bc/z2ui5_other");
});

test("a manifest without the data source does not blow up", () => {
  const { inst, state } = load({ manifest: {} });

  inst.onInit();

  expect(state.url).toBeUndefined();
});

test("one View1 controller is created per view slot from the slot table", () => {
  const { inst, state, View1Controller, slots } = load({ manifest: MANIFEST });

  inst.onInit();

  for (const slot of slots) {
    expect(state[slot.controllerProp]).toBeInstanceOf(View1Controller);
  }
  // each slot gets its OWN instance
  expect(state.oController).not.toBe(state.oControllerNest);
});

test("the owner component and the app container are stored in the state", () => {
  const { inst, state, component, byIdCalls } = load({ manifest: MANIFEST });

  inst.onInit();

  expect(state.oOwnerComponent).toBe(component);
  expect(byIdCalls).toEqual(["app"]);
  expect(state.oApp).toEqual({ id: "app" });
});

test("onInit kicks off exactly one initial roundtrip", () => {
  const { inst, roundtrips } = load({ manifest: MANIFEST });

  inst.onInit();

  expect(roundtrips).toHaveLength(1);
});

// Every View1 controller carries the context: it is how each event handler
// and action reaches the state, and what Lib.isControllerAlive tests.
test("the controllers carry the component's context, and the roundtrip gets it", () => {
  const { inst, ctx, state, roundtrips, slots } = load({ manifest: MANIFEST });

  inst.onInit();

  for (const slot of slots) expect(state[slot.controllerProp].ctx).toBe(ctx);
  expect(roundtrips).toEqual([ctx]);
});

// An EMBEDDED component's sap.m.App must not focus the first input of the
// first page it renders (NavContainer autoFocus): the page is the host's, and
// on 1.136 every app took the focus out of the host field the user was typing
// in. Off until that first page has rendered, back on from there - without an
// invalidation, the property renders nothing - so a page transition later
// still hands the focus on (only when it was in the page being left).
function appStub() {
  const delegates = [];
  const app = {
    autoFocus: true,
    page: null,
    invalidations: 0,
    getAutoFocus() {
      return this.autoFocus;
    },
    setAutoFocus(value) {
      this.autoFocus = value;
      this.invalidations += 1;
    },
    setProperty(name, value, suppressInvalidate) {
      this[name] = value;
      if (!suppressInvalidate) this.invalidations += 1;
    },
    getCurrentPage() {
      return this.page;
    },
    addEventDelegate: (d) => delegates.push(d),
    removeEventDelegate: (d) => delegates.splice(delegates.indexOf(d), 1),
  };
  const render = () => {
    for (const d of delegates.slice()) d.onAfterRendering?.();
  };
  return { app, delegates, render };
}

test("embedded, the App does not focus the first page it renders", () => {
  const { app, delegates, render } = appStub();
  const { inst } = load({ manifest: MANIFEST, embedded: true, app });

  inst.onInit();
  expect(app.autoFocus).toBe(false);

  // the App renders before the first roundtrip answered: no page yet
  render();
  expect(app.autoFocus).toBe(false);
  expect(delegates).toHaveLength(1);

  // the first page has rendered (and was not focused) - on again, for the
  // page changes to come
  app.page = { id: "mainView" };
  render();
  expect(app.autoFocus).toBe(true);
  expect(delegates).toEqual([]);
  // the one invalidation is the switch-off before the first rendering
  expect(app.invalidations).toBe(1);
});

test("on a page of the app's own, the App keeps its autofocus", () => {
  const { app, delegates } = appStub();
  const { inst } = load({ manifest: MANIFEST, app });

  inst.onInit();

  expect(app.autoFocus).toBe(true);
  expect(delegates).toEqual([]);
  expect(app.invalidations).toBe(0);
});
