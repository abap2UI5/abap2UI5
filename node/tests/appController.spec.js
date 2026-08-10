// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// controller/App.controller.js: the shell controller's one-time startup
// wiring. Under test: the backend-URL decision (manifest URI vs. the page
// URL in local mode), one View1 controller instance per view slot (driven
// by the ViewSlots table, not a hardcoded list), the app container lookup,
// and the initial roundtrip kick-off.
function load({ manifest, globals = {}, href = "http://localhost:3000/" } = {}) {
  const state = {};
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
      "z2ui5/core/Server": { roundtrip: () => roundtrips.push(1) },
      "z2ui5/core/AppState": {
        state,
        getGlobal: (name) => globals[name],
        setGlobal: (name, value) => (globals[name] = value),
      },
      "z2ui5/core/ViewSlots": { slots },
    },
    sandbox: { window: { location: { href } } },
  });

  const component = { getManifest: () => manifest };
  const byIdCalls = [];
  const view = {
    byId: (id) => {
      byIdCalls.push(id);
      return { id };
    },
  };
  const inst = Object.create(AppController);
  inst.getOwnerComponent = () => component;
  inst.getView = () => view;

  return {
    inst,
    state,
    globals,
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
  const { inst, globals } = load({ manifest: MANIFEST });

  inst.onInit();

  expect(globals.url).toBe("/sap/bc/z2ui5");
});

test("local mode (checkLocal global) uses the page URL instead", () => {
  const { inst, globals } = load({
    manifest: MANIFEST,
    globals: { checkLocal: true },
    href: "http://localhost:3000/?app_start=x",
  });

  inst.onInit();

  expect(globals.url).toBe("http://localhost:3000/?app_start=x");
});

test("a manifest without the data source does not blow up", () => {
  const { inst, globals } = load({ manifest: {} });

  inst.onInit();

  expect(globals.url).toBeUndefined();
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
