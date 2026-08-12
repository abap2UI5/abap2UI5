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
// so actions/Slots has to fan it out over the open model-owning slots
// itself. Asserting the dispatch alone is not enough - what matters is that
// the data actually lands in every open slot and in none of the others.
function withSlots(openKeys, model) {
  const applied = [];
  const views = {};
  for (const key of openKeys) {
    // each open slot carries its own framework-owned (tracked) model; a
    // push must land as setData on exactly that model
    const tracked = {
      _z2ui5Tracked: true,
      setData: (data) => applied.push({ key, data }),
    };
    views[key] = { getModel: (name) => (name ? undefined : tracked) };
  }
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
  const { module: Slots } = loadModule("core/actions/Slots.js", {
    deps: {
      "z2ui5/core/Server": {},
      "z2ui5/core/Lib": { effectiveSizeLimit: () => undefined },
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": {
        state: { oResponse: { OVIEWMODEL: model }, viewSizeLimits: {} },
      },
    },
  });
  return { Slots, applied };
}

test.describe("updateModel (one action, every open model slot)", () => {
  test("pushes into each OPEN slot that owns a model", () => {
    const model = { A: 1 };
    const { Slots, applied } = withSlots(["MAIN", "POPOVER"], model);
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([
      { key: "MAIN", data: model },
      { key: "POPOVER", data: model },
    ]);
  });

  test("skips the nested slots - they inherit MAIN's model", () => {
    const { Slots, applied } = withSlots(["MAIN", "NEST", "NEST2"], {});
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied.map((a) => a.key)).toEqual(["MAIN"]);
  });

  test("a closed slot is simply not pushed to", () => {
    const { Slots, applied } = withSlots([], {});
    Slots.action("updateModel", undefined, undefined, {});
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

test.describe("_processAfterRendering (action-free responses)", () => {
  // With the ROUTER and updateModel actions derived/gated away, a response
  // without any action is the COMMON case - it must still get its model
  // push, its hash sync and the after-render hooks.
  function loadForAfterRendering() {
    const pushes = [];
    const syncs = [];
    const hooks = [];
    const state = { onAfterRendering: [() => hooks.push("ran")] };
    const { module: ctrl } = loadModule("controller/View1.controller.js", {
      deps: {
        "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
        "sap/ui/core/BusyIndicator": { hide: () => {} },
        "sap/m/MessageBox": {},
        "z2ui5/core/Server": { _requestSeq: 1, responseError: () => {} },
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          runCallbacks: (arr) => (arr || []).forEach((f) => f()),
          logError: () => {},
        },
        "z2ui5/core/FrontendAction": {
          runSystem: () => {},
          runCustom: () => {},
        },
        "z2ui5/core/actions/Slots": { action: (method) => pushes.push(method) },
        "z2ui5/core/ViewSlots": {},
        "z2ui5/core/Router": { sync: (o) => syncs.push(o) },
        "z2ui5/core/AppState": { state },
      },
    });
    return { ctrl, state, pushes, syncs, hooks };
  }

  test("no actions at all: model push, router sync and hooks still run", async () => {
    const { ctrl, state, pushes, syncs, hooks } = loadForAfterRendering();
    state.oResponse = { ID: "D1", MODELPRESENT: true };

    await ctrl._processAfterRendering(1);

    expect(pushes).toEqual(["updateModel"]);
    expect(syncs).toEqual([{ id: "D1" }]);
    expect(hooks).toEqual(["ran"]);
  });

  test("no MODEL key: nothing is pushed, the sync still runs", async () => {
    const { ctrl, state, pushes, syncs } = loadForAfterRendering();
    state.oResponse = { ID: "D2", MODELPRESENT: false };

    await ctrl._processAfterRendering(1);

    expect(pushes).toEqual([]);
    expect(syncs).toEqual([{ id: "D2" }]);
  });

  test("a travelling ROUTER action's options reach the one per-response sync", async () => {
    const { ctrl, state, syncs } = loadForAfterRendering();
    // the ControlCall hook stashes the options on the response record; the
    // stash is consumed by the sync, which injects the response id
    state.oResponse = { ID: "D3", _routerOptions: { setNavRouting: "KEEP" } };

    await ctrl._processAfterRendering(1);

    expect(syncs).toEqual([{ setNavRouting: "KEEP", id: "D3" }]);
  });
});
