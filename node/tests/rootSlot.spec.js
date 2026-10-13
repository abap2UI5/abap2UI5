// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { classEnv } = require("./loadLibModule");

// core/RootSlot.js: the place of the root control in the shell view. An
// XMLView renders what its XML declared, so the slot is declared there and
// renders the one control App.controller gives it (a sap.m.App, or a
// sap.m.NavContainer when embedded) inside one element that fills the view.
function load() {
  const { module: RootSlot } = loadModule("core/RootSlot.js", {
    deps: {
      "sap/ui/core/Control": { extend: (_name, def) => def },
      "z2ui5/core/Env": classEnv,
    },
  });
  return RootSlot;
}

function renderLog(slot) {
  const log = [];
  const rm = {
    openStart: (tag, control) => log.push(["openStart", tag, control]),
    style: (name, value) => log.push(["style", name, value]),
    openEnd: () => log.push(["openEnd"]),
    renderControl: (control) => log.push(["renderControl", control]),
    close: (tag) => log.push(["close", tag]),
  };
  load().renderer.render(rm, slot);
  return log;
}

test("one aggregation, the root, which is also the default one", () => {
  const def = load();
  expect(def.metadata.aggregations).toEqual({
    root: { type: "sap.ui.core.Control", multiple: false },
  });
  expect(def.metadata.defaultAggregation).toBe("root");
  expect(def.renderer.apiVersion).toBe(2);
});

test("renders the root inside one element that fills the view", () => {
  const root = { id: "root" };
  const slot = { getAggregation: (name) => (name === "root" ? root : null) };
  expect(renderLog(slot)).toEqual([
    ["openStart", "div", slot],
    ["style", "width", "100%"],
    ["style", "height", "100%"],
    ["openEnd"],
    ["renderControl", root],
    ["close", "div"],
  ]);
});

test("without a root, the element alone", () => {
  const slot = { getAggregation: () => null };
  expect(renderLog(slot).map((entry) => entry[0])).toEqual([
    "openStart",
    "style",
    "style",
    "openEnd",
    "close",
  ]);
});
