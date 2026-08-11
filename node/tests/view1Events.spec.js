// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the two event-side helpers on View1.controller that the backend binds
// into a view attribute:
//  - eBP: the roundtrip that first cancels the control's built-in default
//    (client->_event with s_ctrl-check_prevent_default), the only way to reach
//    oEvent.preventDefault() - a follow-up action from the response runs long
//    after the control acted on its own default
//  - textPath: the ancestor-text breadcrumb of a control resolved in an event
//    argument (`$controller.textPath(${$parameters>/item})`), a control-tree
//    walk that no binding path can express

function loadController() {
  const { module: Lib } = loadModule("core/Lib.js", {
    deps: { "z2ui5/core/AppState": { state: {} }, "sap/ui/core/Element": {} },
  });
  const { module: ctrl } = loadModule("controller/View1.controller.js", {
    deps: {
      "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
      "sap/ui/core/routing/HashChanger": { getInstance: () => ({}) },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/AppState": { state: {} },
    },
  });
  return ctrl;
}

// the controller with eB replaced by a recorder: eBP's contract is "cancel the
// default, then round-trip exactly like eB"
function withRecordedEB() {
  const sent = [];
  const controller = Object.create(loadController());
  controller.eB = (...args) => sent.push(args);
  return { controller, sent };
}

// The model push: the backend sends ONE updateModel action naming no slot,
// so the controller has to fan it out over the open model-owning slots
// itself. Asserting the dispatch alone is not enough - what matters is that
// the data actually lands in every open slot and in none of the others.
function withSlots(openKeys, model) {
  const applied = [];
  const views = {};
  for (const key of openKeys) views[key] = { key };
  const ViewSlots = {
    slots: [
      { key: "MAIN", ownsModel: true },
      { key: "NEST" },
      { key: "NEST2" },
      { key: "POPUP", ownsModel: true },
      { key: "POPOVER", ownsModel: true },
    ],
    getView: (key) => views[key],
    destroy: () => {},
  };
  const { module: Lib } = loadModule("core/Lib.js", {
    deps: { "z2ui5/core/AppState": { state: {} }, "sap/ui/core/Element": {} },
  });
  const { module: ctrl } = loadModule("controller/View1.controller.js", {
    deps: {
      "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
      "sap/ui/core/routing/HashChanger": { getInstance: () => ({}) },
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": { state: { oResponse: { OVIEWMODEL: model } } },
    },
  });
  const controller = Object.create(ctrl);
  // stand in for the real model resolution - the point here is WHICH slots
  // get pushed to, not how a slot's model is reused
  controller.updateModelIfRequired = (slotKey) => {
    if (!views[slotKey]) return;
    applied.push(slotKey);
  };
  return { controller, applied };
}

test.describe("updateModel (one action, every open model slot)", () => {
  test("pushes into each OPEN slot that owns a model", () => {
    const { controller, applied } = withSlots(["MAIN", "POPOVER"], { A: 1 });
    controller.slotAction("updateModel", undefined, undefined, {});
    expect(applied).toEqual(["MAIN", "POPOVER"]);
  });

  test("skips the nested slots - they inherit MAIN's model", () => {
    const { controller, applied } = withSlots(["MAIN", "NEST", "NEST2"], {});
    controller.slotAction("updateModel", undefined, undefined, {});
    expect(applied).toEqual(["MAIN"]);
  });

  test("a closed slot is simply not pushed to", () => {
    const { controller, applied } = withSlots([], {});
    controller.slotAction("updateModel", undefined, undefined, {});
    expect(applied).toEqual([]);
  });
});

test.describe("eBP (roundtrip with preventDefault)", () => {
  test("cancels the default and forwards the unchanged eB payload", () => {
    const { controller, sent } = withRecordedEB();
    let prevented = false;
    const oEvent = { preventDefault: () => (prevented = true) };
    // the flag form: the backend sends the constant true as the condition
    controller.eBP(oEvent, true, ["ITEM_PRESS"], "__item0");
    expect(prevented).toBe(true);
    expect(sent).toEqual([[["ITEM_PRESS"], "__item0"]]);
  });

  test("still round-trips when no event object arrives", () => {
    const { controller, sent } = withRecordedEB();
    controller.eBP(undefined, true, ["ITEM_PRESS"]);
    expect(sent).toEqual([[["ITEM_PRESS"]]]);
  });

  test("does not call a non-function preventDefault", () => {
    const { controller, sent } = withRecordedEB();
    controller.eBP({ preventDefault: "not a function" }, true, ["ITEM_PRESS"]);
    expect(sent).toEqual([[["ITEM_PRESS"]]]);
  });

  // s_ctrl-prevent_default_expr: the condition is an expression UI5 resolves
  // per firing, so ONE wire can veto one row/column and let the rest through.
  // Whatever it resolves to, the event is always sent - the backend stays in
  // charge, exactly as with the flag.
  test("a falsy condition lets the control's default through", () => {
    const { controller, sent } = withRecordedEB();
    let prevented = false;
    const oEvent = { preventDefault: () => (prevented = true) };
    controller.eBP(oEvent, false, ["COLUMN_RESIZE"], "100px");
    expect(prevented).toBe(false);
    expect(sent).toEqual([[["COLUMN_RESIZE"], "100px"]]);
  });

  test("the same wire vetoes or not, per firing", () => {
    const { controller, sent } = withRecordedEB();
    const fire = (bVeto) => {
      let prevented = false;
      controller.eBP({ preventDefault: () => (prevented = true) }, bVeto, [
        "COLUMN_RESIZE",
      ]);
      return prevented;
    };
    expect(fire(true)).toBe(true);
    expect(fire(false)).toBe(false);
    // both firings round-tripped with an identical payload
    expect(sent).toEqual([[["COLUMN_RESIZE"]], [["COLUMN_RESIZE"]]]);
  });
});

test.describe("textPath (ancestor-text breadcrumb)", () => {
  test("joins the pressed item's text with its ancestors'", () => {
    const controller = loadController();
    const menu = { getParent: () => null }; // sap.m.Menu - no getText
    const parent = { getText: () => "Create New Site", getParent: () => menu };
    const item = { getText: () => "Official Store", getParent: () => parent };
    expect(controller.textPath(item)).toBe(
      "Create New Site > Official Store",
    );
    expect(controller.textPath(item, " | ")).toBe(
      "Create New Site | Official Store",
    );
  });
});
