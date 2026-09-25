// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// reuse/Container.js - the control a HOST app places to run an abap2UI5 app
// between its own controls (z2ui5.reuse.Container). It is thin on purpose,
// and each of its few decisions is a way embedding goes wrong:
//   - the stylesheet is included once, by module load, not per instance
//   - nothing starts while `app` is empty
//   - app, endpoint and params are START properties: a change throws the
//     running component away (ending its backend session) instead of
//     patching it, and an unchanged value keeps it
//   - the component data is the launchpad's shape - one array per startup
//     parameter, app_start among them - and `endpoint` goes on the TOP level,
//     the only place Component.init reads it from (componentData.spec.js pins
//     that side)
//
// UI5 is stubbed: Control.extend hands back the definition, a property bag
// stands in for ManagedObject, and ComponentContainer records its settings.
function load() {
  const stylesheets = [];
  const containers = [];
  class ComponentContainerStub {
    constructor(settings) {
      this.settings = settings;
      containers.push(this);
    }
  }
  const { module: Def } = loadModule("reuse/Container.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "sap/ui/core/ComponentContainer": ComponentContainerStub,
      "sap/ui/dom/includeStylesheet": (url, id) => stylesheets.push({ url, id }),
    },
    sandbox: { sap: { ui: { require: { toUrl: (p) => `/resources/${p}` } } } },
  });

  function instance(props = {}) {
    const inst = Object.create(Def);
    const defaults = Object.fromEntries(
      Object.entries(Def.metadata.properties).map(([k, v]) => [k, v.defaultValue]),
    );
    inst._props = { ...defaults, ...props };
    inst._aggr = {};
    inst.destroyed = 0;
    inst.getProperty = (k) => inst._props[k];
    inst.setProperty = (k, v) => ((inst._props[k] = v), inst);
    for (const k of Object.keys(defaults)) {
      const cap = k[0].toUpperCase() + k.slice(1);
      if (!inst[`get${cap}`]) inst[`get${cap}`] = () => inst._props[k];
    }
    inst.getAggregation = (k) => inst._aggr[k] ?? null;
    inst.setAggregation = (k, v) => ((inst._aggr[k] = v), inst);
    inst.destroyAggregation = (k) => {
      if (inst._aggr[k]) inst.destroyed++;
      delete inst._aggr[k];
      return inst;
    };
    inst.fireComponentCreated = () => {};
    inst.fireComponentFailed = () => {};
    return inst;
  }
  return { Def, instance, stylesheets, containers };
}

test("the stylesheet is included once, at module load, under a fixed id", () => {
  const { stylesheets } = load();
  expect(stylesheets).toEqual([
    { url: "/resources/z2ui5/reuse/Container.css", id: "z2ui5-reuse-container-css" },
  ]);
});

test("nothing starts while app is empty", () => {
  const { instance, containers } = load();
  const c = instance();
  c.onBeforeRendering();
  expect(containers).toHaveLength(0);
  expect(c.getAggregation("_container")).toBeNull();
});

test("the component data: app_start and the params in the launchpad's shape, endpoint on the top level", () => {
  const { instance, containers } = load();
  const c = instance({ app: "ZCL_MY_APP", endpoint: "/sap/bc/z2ui5_other", params: { customer: 4711 } });
  c.onBeforeRendering();
  expect(containers).toHaveLength(1);
  const s = containers[0].settings;
  expect(s.name).toBe("z2ui5");
  expect(s.lifecycle).toBe("Container");
  expect(s.propagateModel).toBe(false);
  expect(s.settings.componentData).toEqual({
    startupParameters: { customer: ["4711"], app_start: ["ZCL_MY_APP"] },
    endpoint: "/sap/bc/z2ui5_other",
  });
});

test("without an endpoint the component data carries none - the manifest's default applies", () => {
  const { instance, containers } = load();
  instance({ app: "ZCL_MY_APP" }).onBeforeRendering();
  expect(containers[0].settings.settings.componentData).toEqual({
    startupParameters: { app_start: ["ZCL_MY_APP"] },
  });
});

test("a changed start property replaces the component, an unchanged one keeps it", () => {
  const { instance, containers } = load();
  const c = instance({ app: "ZCL_A" });
  c.onBeforeRendering();
  expect(containers).toHaveLength(1);

  c.setApp("ZCL_A");
  c.onBeforeRendering();
  expect(c.destroyed).toBe(0);
  expect(containers).toHaveLength(1);

  for (const [setter, value] of [["setApp", "ZCL_B"], ["setEndpoint", "/x"], ["setParams", { a: 1 }]]) {
    c[setter](value);
    c.onBeforeRendering();
  }
  expect(c.destroyed).toBe(3);
  expect(containers).toHaveLength(4);
});
