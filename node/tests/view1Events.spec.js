// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

// Tests the two event-side helpers on View1.controller that the backend binds
// into a view attribute:
//  - eBP: the roundtrip that first cancels the control's built-in default
//    (client->_event with s_ctrl-check_prevent_default), the only way to reach
//    oEvent.preventDefault() - a follow-up action from the response runs long
//    after the control acted on its own default
//  - textPath: the ancestor-text breadcrumb of a control resolved in an event
//    argument (`$controller.textPath(${$parameters>/item})`), a control-tree
//    walk that no binding path can express
// plus the response-side behavior that lives on the same controller:
//  - the updateModel fan-out over the open model-owning slots
//  - _processAfterRendering (stale-response guards, implicit teardown)

function loadController() {
  const Lib = loadLib().Lib;
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

// A MODEL key in the response IS the model push: no updateModel action
// travels on the wire - View1 dispatches ONE updateModel naming no slot, and
// actions/Slots fans it out over the open model-owning slots itself.
// Asserting the dispatch alone is not enough - what matters is that the data
// actually lands in every open slot and in none of the others.
// `slotApps` names the app each open slot was filled by and `responseApp` the
// app the response belongs to - the pair the cross-app guard reads. Left out,
// both are undefined and the guard stays out of the way, which is also the
// real behaviour for a slot no response has claimed.
// `builtFrom` names the open slots whose model was built from THIS response
// (Slots.createViewModel stamps the response record on it) - the push must
// leave those alone, they hold the data already.
function withSlots(
  openKeys,
  model,
  { slotApps = {}, responseApp, builtFrom = [] } = {},
) {
  const applied = [];
  const views = {};
  const oResponse = { OVIEWMODEL: model, APP: responseApp };
  for (const key of openKeys) {
    // each open slot carries its own framework-owned (tracked) model; a
    // push must land as setData on exactly that model
    const tracked = {
      _z2ui5Tracked: true,
      setData: (data) => applied.push({ key, data }),
    };
    if (builtFrom.includes(key)) tracked._z2ui5BuiltFrom = oResponse;
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
    getViewApp: (key) => slotApps[key],
    destroy: () => {},
    // mirrors the real resolver (core/ViewSlots.js): only a model
    // carrying the _z2ui5Tracked marker is the framework's
    trackedModel: (owner) => {
      const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
      if (!owner?.getModel) return undefined;
      return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
    },
  };
  const { module: Slots } = loadModule("core/actions/Slots.js", {
    deps: {
      "z2ui5/core/Server": {},
      "z2ui5/core/Lib": {
        effectiveSizeLimit: () => undefined,
        // the root slots share one model, a standalone slot gets a copy
        // (Slots.dataForSlot) - the shipped helper's answer, as a stub
        isRootModelSlot: (k) => k === "MAIN" || k === "NEST" || k === "NEST2",
      },
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": {
        state: {
          oResponse,
          viewSizeLimits: {},
        },
      },
    },
  });
  return { Slots, applied, views };
}

test.describe("updateModel (one dispatch, every open model slot)", () => {
  test("pushes into each OPEN slot that owns a model", () => {
    const model = { A: 1 };
    const { Slots, applied } = withSlots(["MAIN", "POPOVER"], model);
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([
      { key: "MAIN", data: model },
      { key: "POPOVER", data: model },
    ]);
  });

  test("a standalone slot binds a COPY of the data, MAIN the object itself", () => {
    // JSONModel copies in neither its constructor nor setData( ), so MAIN
    // and a dialog used to share one oData - MAIN's restored unsent edits
    // showed up in the dialog, and a dialog edit changed MAIN's data behind
    // its bindings (Slots.dataForSlot)
    const model = { A: 1, T: [{ X: "row" }] };
    const { Slots, applied } = withSlots(["MAIN", "POPUP"], model);
    Slots.action("updateModel", undefined, undefined, {});
    const main = applied.find((a) => a.key === "MAIN").data;
    const popup = applied.find((a) => a.key === "POPUP").data;
    expect(main).toBe(model);
    expect(popup).not.toBe(model);
    expect(popup).toEqual(model);
    expect(popup.T).not.toBe(model.T);
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

  test("a slot built from this response is not pushed to again", () => {
    // the backend ships MODEL with every display; the model a display just
    // built from it holds the data already - pushing it again was a full
    // binding sweep on MAIN and a second whole-model clone per dialog open
    const model = { A: 1 };
    const { Slots, applied } = withSlots(["MAIN", "POPUP"], model, {
      builtFrom: ["MAIN", "POPUP"],
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([]);
  });

  test("a slot built from an EARLIER response is still pushed to", () => {
    // a popup left open across a roundtrip that rebuilt no view: its model
    // came from the previous response and needs this one's data
    const model = { A: 2 };
    const { Slots, applied, views } = withSlots(["MAIN", "POPUP"], model, {
      builtFrom: ["MAIN"],
    });
    views.POPUP.getModel()._z2ui5BuiltFrom = { OVIEWMODEL: { A: 1 } };
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied.map((a) => a.key)).toEqual(["POPUP"]);
  });

  test("a slot's unsent edits survive the push and stay pending", () => {
    // the winning request shipped MAIN's edits (its set is cleared before
    // the push - Server.readHttp); the popup's typed value is still pending
    // and must not be overwritten by the backend's stale copy
    const response = { name: "old", count: 1 };
    const { Slots, views } = withSlots(["MAIN", "POPUP"], response);
    const popup = views.POPUP.getModel();
    let data = { name: "typed", count: 1 };
    popup._z2ui5ChangedPaths = new Set(["/name"]);
    popup.getProperty = (path) => data[path.slice(1)];
    popup.setData = (next) => (data = { ...next });
    const set = [];
    popup.setProperty = (path, value) => {
      set.push([path, value]);
      data[path.slice(1)] = value;
    };

    Slots.action("updateModel", undefined, undefined, {});

    expect(data).toEqual({ name: "typed", count: 1 });
    expect(set).toEqual([["/name", "typed"]]);
    // still pending - the popup's own next roundtrip ships it
    expect([...popup._z2ui5ChangedPaths]).toEqual(["/name"]);
  });

  // A response carries the model of ONE app. An app called only to open a
  // dialog (nav_app_call to a popup app) displays no main view, so MAIN still
  // holds the CALLER's view - and the callee's model does not contain the
  // caller's binding paths at all. Pushing it there emptied the screen behind
  // the dialog.
  test("skips a slot the response's app did not fill", () => {
    const model = { MS_ROW: { A: 1 } };
    const { Slots, applied } = withSlots(["MAIN", "POPUP"], model, {
      slotApps: { MAIN: "ZCL_LIST", POPUP: "ZCL_LIST_POPUP" },
      responseApp: "ZCL_LIST_POPUP",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([{ key: "POPUP", data: model }]);
  });

  test("pushes into every slot the responding app itself filled", () => {
    const model = { MT_TAB: [] };
    const { Slots, applied } = withSlots(["MAIN", "POPUP"], model, {
      slotApps: { MAIN: "ZCL_LIST", POPUP: "ZCL_LIST" },
      responseApp: "ZCL_LIST",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied.map((a) => a.key)).toEqual(["MAIN", "POPUP"]);
  });

  test("a slot with no recorded owner keeps the unconditional push", () => {
    const { Slots, applied } = withSlots(["MAIN"], {}, {
      responseApp: "ZCL_LIST_POPUP",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied.map((a) => a.key)).toEqual(["MAIN"]);
  });

  // the same guard for a POPOVER: a called app that opens one over the
  // caller's screen owns that slot and nothing else
  test("a popover opened by a called app is the only slot it pushes to", () => {
    const model = { MS_ROW: { A: 1 } };
    const { Slots, applied } = withSlots(["MAIN", "POPOVER"], model, {
      slotApps: { MAIN: "ZCL_LIST", POPOVER: "ZCL_LIST_POPUP" },
      responseApp: "ZCL_LIST_POPUP",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([{ key: "POPOVER", data: model }]);
  });

  // the nested slots inherit MAIN's model and belong to whoever filled
  // MAIN - a popup app's response leaves them alone with it
  test("nested slots stay with the caller while a popup app answers", () => {
    const model = { MS_ROW: { A: 1 } };
    const { Slots, applied } = withSlots(["MAIN", "NEST", "NEST2", "POPUP"], model, {
      slotApps: { MAIN: "ZCL_LIST", NEST: "ZCL_LIST", POPUP: "ZCL_LIST_POPUP" },
      responseApp: "ZCL_LIST_POPUP",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([{ key: "POPUP", data: model }]);
  });

  // a called app that takes the screen (displays MAIN itself) owns MAIN
  // from then on - the record follows the display, so its pushes land
  test("a called app that displayed MAIN pushes into it", () => {
    const model = { MT_DETAIL: [] };
    const { Slots, applied } = withSlots(["MAIN"], model, {
      slotApps: { MAIN: "ZCL_DETAIL" },
      responseApp: "ZCL_DETAIL",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([{ key: "MAIN", data: model }]);
  });

  // ...and the caller's response after nav_app_leave, when it re-displayed
  // MAIN, is pushed the same way: the record carries the caller again while
  // the popup the callee left open (a self-closing dialog) is not touched
  test("after a leave the caller owns MAIN again and only MAIN", () => {
    const model = { MT_TAB: [1, 2, 3] };
    const { Slots, applied } = withSlots(["MAIN", "POPUP"], model, {
      slotApps: { MAIN: "ZCL_LIST", POPUP: "ZCL_LIST_POPUP" },
      responseApp: "ZCL_LIST",
    });
    Slots.action("updateModel", undefined, undefined, {});
    expect(applied).toEqual([{ key: "MAIN", data: model }]);
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
    expect(controller.textPath(item)).toBe("Create New Site > Official Store");
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
    // the request stamp lives on Server: a spec bumps it to dispatch a newer
    // request mid-phase, which is what "superseded" means BEFORE that
    // request's own response has landed
    const server = { _requestSeq: 1, responseError: () => {} };
    const pushes = [];
    const syncs = [];
    const hooks = [];
    const destroys = [];
    const busy = [];
    const pendingHash = [];
    const state = { onAfterRendering: [() => hooks.push("ran")], isBusy: true };
    const { module: ctrl } = loadModule("controller/View1.controller.js", {
      deps: {
        "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
        "sap/ui/core/BusyIndicator": { hide: () => busy.push("hide") },
        "sap/m/MessageBox": {},
        "z2ui5/core/Server": server,
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          isControllerAlive: () => true,
          runCallbacks: (arr) => (arr || []).forEach((f) => f()),
          logError: () => {},
        },
        "z2ui5/core/FrontendAction": {
          // a spec may replace the response mid-phase, the way a parallel
          // request does while the system actions are still awaiting
          runSystem: () => hooks.onRunSystem?.(),
          runCustom: () => {},
        },
        "z2ui5/core/actions/Slots": { action: (method) => pushes.push(method) },
        "z2ui5/core/ViewSlots": { destroy: (key) => destroys.push(key) },
        "z2ui5/core/Router": {
          sync: (o) => syncs.push(o),
          dispatchPendingAppHash: () => pendingHash.push("delivered"),
        },
        "z2ui5/core/AppState": { state },
      },
    });
    return {
      ctrl,
      state,
      server,
      pushes,
      syncs,
      hooks,
      destroys,
      busy,
      pendingHash,
    };
  }

  test("a superseded response leaves busy, custom JS and the parked hash to the newer one", async () => {
    const { ctrl, state, pushes, syncs, hooks, busy, pendingHash } = loadForAfterRendering();
    state.oResponse = {
      ID: "D1",
      MODELPRESENT: true,
      S_ACTION: { T_SYSTEM: [{}] },
      _pendingCustomJs: [["TOAST"]],
    };
    // a newer request replaces the response while this one's system
    // actions are still running
    hooks.onRunSystem = () => {
      state.oResponse = { ID: "D2", MODELPRESENT: false };
    };

    await ctrl._processAfterRendering(1);

    // nothing of this response reached the screen ...
    expect(pushes).toEqual([]);
    expect(syncs).toEqual([]);
    // ... and it did not end the busy state the newer request relies on,
    // ran no custom JS and delivered no parked hash - the newer response does
    expect(busy).toEqual([]);
    expect(state.isBusy).toBe(true);
    expect(pendingHash).toEqual([]);
  });

  // The display phase stops on the request STAMP, the phase-2 guard used to
  // ask the response RECORD - and the record only flips once the newer
  // request's response lands. In between (a Back/Forward restore is exactly
  // that window) a response whose system actions were cut short still ran
  // phase 2: it ended the busy state the restore relies on and let Router.sync
  // consume the restore's navFromHash flag. ONE stamp answers both phases.
  test("a response cut short by a newer REQUEST stops before phase 2", async () => {
    const { ctrl, state, server, pushes, syncs, hooks, busy, pendingHash } =
      loadForAfterRendering();
    state.oResponse = {
      ID: "D1",
      MODELPRESENT: true,
      S_ACTION: { T_SYSTEM: [{}] },
      _pendingCustomJs: [["TOAST"]],
    };
    // the restore dispatches its request while the system actions run - the
    // response record still points at THIS response, only the stamp moved
    hooks.onRunSystem = () => {
      server._requestSeq = 2;
    };

    await ctrl._processAfterRendering(1);

    expect(state.oResponse.ID).toBe("D1");
    expect(pushes).toEqual([]);
    expect(syncs).toEqual([]);
    expect(busy).toEqual([]);
    expect(state.isBusy).toBe(true);
    expect(pendingHash).toEqual([]);
  });

  // the same stamp is what the onAfterRendering entry falls back to, so a
  // response processed without one is never read as superseded
  test("no stamp handed in: the newest request is the response's own", async () => {
    const { ctrl, state, syncs, busy } = loadForAfterRendering();
    state.oResponse = { ID: "D1", S_ACTION: { T_SYSTEM: [{}] } };

    await ctrl._processAfterRendering();

    expect(syncs).toEqual([{ id: "D1" }]);
    expect(busy).toEqual(["hide"]);
  });

  test("the winning response ends the busy state and delivers the parked hash", async () => {
    const { ctrl, state, busy, pendingHash } = loadForAfterRendering();
    state.oResponse = { ID: "D1", MODELPRESENT: false };

    await ctrl._processAfterRendering(1);

    expect(busy).toEqual(["hide"]);
    expect(state.isBusy).toBe(false);
    expect(pendingHash).toEqual(["delivered"]);
  });

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

  test("an APP switch tears the popup/popover down implicitly, once", async () => {
    const { ctrl, state, destroys } = loadForAfterRendering();
    // first app ever rendered: nothing of a previous app can be open
    state.oResponse = { ID: "D1", APP: "Z2UI5_CL_A" };
    await ctrl._processAfterRendering(1);
    expect(destroys).toEqual([]);

    // switch to another class: the standalone slots live outside MAIN's
    // control tree, so no destroy action travels - the switch itself,
    // visible right here, kills them before the new app's system actions
    state.oResponse = { ID: "D2", APP: "Z2UI5_CL_B" };
    await ctrl._processAfterRendering(1);
    expect(destroys).toEqual(["POPUP", "POPOVER"]);

    // an event roundtrip of the SAME app tears nothing down
    state.oResponse = { ID: "D3", APP: "Z2UI5_CL_B" };
    await ctrl._processAfterRendering(1);
    expect(destroys).toEqual(["POPUP", "POPOVER"]);
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

// A new roundtrip overrides every pending backend timer, and EVERY path that
// starts one owes that cancel: View1.eB had the loop written out and
// Server.restoreFromRoute (the Back/Forward restore) had nothing at all, so a
// poll armed one screen back kept ticking into the restored app. One helper -
// Lib.cancelPendingTimers - and it is the shipped one that runs here.
test.describe("eB cancels the pending timers before it dispatches", () => {
  function loadForDispatch() {
    const cleared = [];
    const state = { timers: {} };
    const { Lib } = loadLib({
      z2ui5: state,
      clearTimeout: (handle) => cleared.push(handle),
    });
    const bodies = [];
    const { module: ctrl } = loadModule("controller/View1.controller.js", {
      deps: {
        "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
        "sap/ui/core/BusyIndicator": { show: () => {}, hide: () => {} },
        "sap/m/MessageBox": { alert: () => {} },
        "z2ui5/core/Server": { roundtrip: (oBody) => bodies.push(oBody) },
        "z2ui5/core/Lib": Lib,
        "z2ui5/core/FrontendAction": {},
        "z2ui5/core/actions/Slots": {},
        // no slot owns this controller: _pickModelForRoundtrip bails out and
        // the request carries no model delta, which is not what is under test
        "z2ui5/core/ViewSlots": { keyOfController: () => undefined },
        "z2ui5/core/Router": {},
        "z2ui5/core/AppState": { state },
      },
      sandbox: { navigator: { onLine: true } },
    });
    return { ctrl, state, cleared, bodies };
  }

  test("every armed timer is cleared and forgotten", () => {
    const { ctrl, state, cleared, bodies } = loadForDispatch();
    state.timers = { START_TIMER: 7, POLL: 9 };

    ctrl.eB(["SAVE", false]);

    expect(cleared).toEqual([7, 9]);
    expect(state.timers).toEqual({});
    expect(bodies).toHaveLength(1);
  });

  test("no timer armed: the dispatch is unaffected", () => {
    const { ctrl, state, cleared, bodies } = loadForDispatch();

    ctrl.eB(["SAVE", false]);

    expect(cleared).toEqual([]);
    expect(state.timers).toEqual({});
    expect(bodies).toHaveLength(1);
  });

  // the drop-on-busy path returns BEFORE the cancel: the roundtrip in flight
  // still owns those timers, and clearing them here would silence a poll the
  // response is about to re-arm
  test("an event dropped by the busy guard cancels nothing", () => {
    const { ctrl, state, cleared, bodies } = loadForDispatch();
    state.timers = { START_TIMER: 7 };
    state.isBusy = true;

    ctrl.eB(["SAVE", false]);

    expect(cleared).toEqual([]);
    expect(state.timers).toEqual({ START_TIMER: 7 });
    expect(bodies).toEqual([]);
  });
});

test.describe("a MAIN display takes the standalone slots with it", () => {
  // A new main view is a new screen: POPUP and POPOVER live OUTSIDE the MAIN
  // control tree, so nothing else closes them - a dialog of the previous
  // screen would float on top of the new one. The backend relies on this and
  // sends no teardown for them next to a MAIN display.
  function loadSlots(requestSeq) {
    const destroyed = [];
    const pages = [];
    const oView = { destroy: () => {} };
    function JSONModel() {
      this.attachPropertyChange = () => {};
      this.destroy = () => {};
      this.setSizeLimit = () => {};
    }
    const { module: Slots } = loadModule("core/actions/Slots.js", {
      deps: {
        "sap/ui/core/mvc/XMLView": { create: async () => oView },
        "sap/ui/model/json/JSONModel": JSONModel,
        "z2ui5/core/Server": { _requestSeq: requestSeq },
        "z2ui5/core/Lib": {
          effectiveSizeLimit: () => undefined,
          isRootModelSlot: (k) => k === "MAIN" || k === "NEST" || k === "NEST2",
          isAlive: () => true,
          logError: () => {},
        },
        "z2ui5/core/ViewSlots": {
          slots: [],
          getView: () => undefined,
          getController: () => undefined,
          setView: () => {},
          destroy: (key) => destroyed.push(key),
        },
        "z2ui5/core/AppState": {
          state: {
            viewSizeLimits: {},
            // the shipped default - displayMain empties it on every rebuild
            odataClients: new Set(),
            oApp: {
              removeAllPages: () => {},
              insertPage: (v) => pages.push(v),
            },
          },
        },
      },
    });
    return { Slots, destroyed, pages, oView };
  }

  test("displaying MAIN destroys MAIN, POPUP and POPOVER", async () => {
    const { Slots, destroyed, pages, oView } = loadSlots(1);

    await Slots.action("display", "MAIN", "<View/>", {}, 1);

    expect(destroyed).toEqual(["MAIN", "POPUP", "POPOVER"]);
    // the teardown is part of the build, not something that replaced it
    expect(pages).toEqual([oView]);
  });

  test("displaying a POPUP leaves the other slots alone", async () => {
    const { Slots, destroyed } = loadSlots(1);

    // every display tears its OWN slot down first - it replaces it - but
    // only MAIN stands for a whole new screen
    await Slots.action("display", "POPUP", "<Dialog/>", {}, 1).catch(() => {});

    expect(destroyed).toEqual(["POPUP"]);
  });

  test("a superseded MAIN display tears nothing down", async () => {
    const { Slots, destroyed } = loadSlots(2);

    // a newer parallel request already claimed the screen: this build is
    // dropped before the teardown, so it cannot close a popup the newer
    // response opened
    await Slots.action("display", "MAIN", "<View/>", {}, 1);

    expect(destroyed).toEqual([]);
  });
});

test.describe("framework-created OData clients die with the MAIN view", () => {
  // A model is no aggregation, so it does NOT die with the view it sits on.
  // The framework builds OData clients in two places - the switch-mode
  // default model of a MAIN display (actions/Slots) and SET_ODATA_MODEL
  // (actions/ViewOps) - and both record theirs in ONE inventory
  // (AppState.state.odataClients) that the next MAIN rebuild empties. The
  // rebuild used to inspect the default model alone, so a NAMED
  // SET_ODATA_MODEL client survived its view and the next re-issue found
  // nothing to destroy. The two modules are loaded on one shared state
  // object here because that is the only place the leak is visible.
  function loadODataOwnership() {
    const clients = [];
    const destroyed = [];
    class ODataModel {
      constructor({ serviceUrl }) {
        this.serviceUrl = serviceUrl;
        clients.push(this);
      }
      setSizeLimit() {}
      destroy() {
        destroyed.push(this);
      }
    }
    function JSONModel() {
      this.attachPropertyChange = () => {};
      this.setSizeLimit = () => {};
      this.destroy = () => {};
    }
    function makeView(id) {
      const models = {};
      return {
        getId: () => id,
        getModel: (name) => models[name],
        setModel: (model, name) => {
          models[name] = model;
        },
        destroy: () => {},
      };
    }
    const state = {
      oResponse: { OVIEWMODEL: { A: 1 }, APP: "ZCL_APP" },
      viewSizeLimits: {},
      odataClients: new Set(),
      oApp: { removeAllPages: () => {}, insertPage: () => {} },
    };
    const openSlots = { MAIN: makeView("mainView") };
    const shared = {
      "sap/ui/model/odata/v2/ODataModel": ODataModel,
      "z2ui5/core/Lib": {
        effectiveSizeLimit: () => undefined,
        isRootModelSlot: (k) => k === "MAIN",
        isAlive: () => true,
        logError: () => {},
      },
      "z2ui5/core/ViewSlots": {
        slots: [{ key: "MAIN", ownsModel: true }],
        getView: (key) => openSlots[key],
        getController: () => undefined,
        setView: (key, view) => (openSlots[key] = view),
        destroy: (key) => delete openSlots[key],
        trackedModel: () => undefined,
      },
      "z2ui5/core/AppState": { state },
    };
    const { module: Slots } = loadModule("core/actions/Slots.js", {
      deps: {
        ...shared,
        "sap/ui/core/mvc/XMLView": {
          // as UI5 does it: the `models` config lands as the DEFAULT model
          // of the new view - which is where the switch-mode OData client
          // ends up
          create: async (cfg) => {
            const view = makeView("mainView");
            if (cfg.models) view.setModel(cfg.models);
            return view;
          },
        },
        "sap/ui/core/Fragment": {},
        "sap/ui/model/json/JSONModel": JSONModel,
        "z2ui5/core/Server": {},
      },
    });
    const { module: ViewOps } = loadModule("core/actions/ViewOps.js", {
      deps: shared,
    });
    return { Slots, ViewOps, state, clients, destroyed, openSlots };
  }

  const setOData = (ViewOps, url, name) =>
    ViewOps.handlers.SET_ODATA_MODEL(null, ["SET_ODATA_MODEL", url, name]);

  test("a NAMED SET_ODATA_MODEL client is destroyed on the next MAIN rebuild", async () => {
    const { Slots, ViewOps, clients, destroyed } = loadODataOwnership();

    setOData(ViewOps, "/sap/opu/odata/sap/ORDERS/", "orders");
    expect(clients).toHaveLength(1);

    await Slots.action("display", "MAIN", "<View/>", {}, undefined);

    expect(destroyed).toEqual([clients[0]]);
  });

  test("the switch-mode default client is destroyed on the next MAIN rebuild", async () => {
    const { Slots, clients, destroyed } = loadODataOwnership();

    await Slots.action(
      "display",
      "MAIN",
      "<View/>",
      { switchDefaultModelPath: "/sap/opu/odata/sap/MAIN/" },
      undefined,
    );
    expect(clients).toHaveLength(1);

    await Slots.action("display", "MAIN", "<View/>", {}, undefined);

    expect(destroyed).toEqual([clients[0]]);
  });

  test("a re-issue destroys the client it replaces, an app's own model never", () => {
    const { ViewOps, state, clients, destroyed, openSlots } =
      loadODataOwnership();
    // a model the app itself put on the view is in no inventory
    const appOwned = { destroy: () => destroyed.push(appOwned) };
    openSlots.MAIN.setModel(appOwned, "app");

    setOData(ViewOps, "/svc/one/", "orders");
    setOData(ViewOps, "/svc/two/", "orders");
    expect(destroyed).toEqual([clients[0]]);

    setOData(ViewOps, "/svc/three/", "app");
    expect(destroyed).toEqual([clients[0]]);
    expect(state.odataClients.size).toBe(2);
  });
});
