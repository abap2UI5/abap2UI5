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

test.describe("eBP (roundtrip with preventDefault)", () => {
  test("cancels the default and forwards the unchanged eB payload", () => {
    const { controller, sent } = withRecordedEB();
    let prevented = false;
    const oEvent = { preventDefault: () => (prevented = true) };
    controller.eBP(oEvent, ["ITEM_PRESS"], "__item0");
    expect(prevented).toBe(true);
    expect(sent).toEqual([[["ITEM_PRESS"], "__item0"]]);
  });

  test("still round-trips when no event object arrives", () => {
    const { controller, sent } = withRecordedEB();
    controller.eBP(undefined, ["ITEM_PRESS"]);
    expect(sent).toEqual([[["ITEM_PRESS"]]]);
  });

  test("does not call a non-function preventDefault", () => {
    const { controller, sent } = withRecordedEB();
    controller.eBP({ preventDefault: "not a function" }, ["ITEM_PRESS"]);
    expect(sent).toEqual([[["ITEM_PRESS"]]]);
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
