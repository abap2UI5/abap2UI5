// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib, specContext, contextStub } = require("./loadLibModule");

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

// Every View1 controller carries its component's context (`ctx`, set by
// App.controller); the specs give the controller definition the spec's one
// context, the way the app gives each instance the component's.
function loadController(extraDeps) {
  const { Lib, ctx } = loadLib();
  const { module: ctrl } = loadModule("controller/View1.controller.js", {
    deps: {
      "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
      "sap/ui/core/routing/HashChanger": { getInstance: () => ({}) },
      "z2ui5/core/Lib": Lib,
      ...(extraDeps || {}),
    },
  });
  ctrl.ctx = ctx;
  return ctrl;
}

// A controller whose ViewSlots is a stub, plus the console errors Lib wrote.
// slotById/slotValue are about resolving across SLOTS, so the slot table is
// the thing under test and has to be substitutable. Named ...Stub because the
// response-side block further down already owns `withSlots` for the OPEN-slot
// fixture, which is a different thing entirely.
function withSlotStub(byId, resolveById) {
  const errors = [];
  const { Lib, ctx } = loadLib();
  const realLogError = Lib.logError;
  Lib.logError = (...args) => errors.push(args[0]);
  const { module: controller } = loadModule("controller/View1.controller.js", {
    deps: {
      "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
      "sap/ui/core/routing/HashChanger": { getInstance: () => ({}) },
      "z2ui5/core/Lib": Lib,
      // the slot registry takes the context first; the stubs ignore it
      "z2ui5/core/ViewSlots": {
        byId: (_ctx, ...a) => (byId || (() => undefined))(...a),
        resolveById: (_ctx, ...a) => (resolveById || (() => null))(...a),
      },
    },
  });
  controller.ctx = ctx;
  return { controller, errors, restore: () => (Lib.logError = realLogError) };
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
    getView: (_ctx, key) => views[key],
    getViewApp: (_ctx, key) => slotApps[key],
    destroy: () => {},
    // mirrors the real resolver (core/ViewSlots.js): only a model
    // carrying the _z2ui5Tracked marker is the framework's
    trackedModel: (owner) => {
      const isOurs = (m) => (m?._z2ui5Tracked ? m : undefined);
      if (!owner?.getModel) return undefined;
      return isOurs(owner.getModel()) ?? isOurs(owner.getModel("http"));
    },
  };
  const ctx = specContext({ oResponse });
  const { module: SlotsModule } = loadModule("core/actions/Slots.js", {
    deps: {
      "z2ui5/core/Context": contextStub(ctx),
      "z2ui5/core/Lib": {
        // no view in these specs uses XML templating (Slots.templatePreprocessors)
        usesXmlTemplating: () => false,
        effectiveSizeLimit: () => undefined,
        // the root slots share one model, a standalone slot gets a copy
        // (Slots.dataForSlot) - the shipped helper's answer, as a stub
        isRootModelSlot: (k) => k === "MAIN" || k === "NEST" || k === "NEST2",
      },
      "z2ui5/core/ViewSlots": ViewSlots,
    },
  });
  // the action takes the context first; bound to the spec's one
  const Slots = {
    action: (...a) => SlotsModule.action(ctx, ...a),
  };
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
    const { Slots, applied } = withSlots(
      ["MAIN"],
      {},
      {
        responseApp: "ZCL_LIST_POPUP",
      },
    );
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
    const { Slots, applied } = withSlots(
      ["MAIN", "NEST", "NEST2", "POPUP"],
      model,
      {
        slotApps: {
          MAIN: "ZCL_LIST",
          NEST: "ZCL_LIST",
          POPUP: "ZCL_LIST_POPUP",
        },
        responseApp: "ZCL_LIST_POPUP",
      },
    );
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
    const renderErrors = [];
    const server = {
      responseError: () => {},
      showRenderError: (_ctx, e, title) => renderErrors.push({ e, title }),
    };
    const logged = [];
    const pushes = [];
    const syncs = [];
    const hooks = [];
    const destroys = [];
    const busy = [];
    const pendingHash = [];
    const customs = [];
    // the request stamp lives on the context (ctx.server.requestSeq): a
    // spec bumps it to dispatch a newer request mid-phase
    const ctx = specContext({
      onAfterRendering: [() => hooks.push("ran")],
      isBusy: true,
    });
    ctx.server.requestSeq = 1;
    const state = ctx.state;
    // mutable: a spec tears the app down mid-phase (reset / FLP re-launch),
    // which is the OTHER way this response's screen can be gone
    const app = { alive: true };
    const { module: ctrl } = loadModule("controller/View1.controller.js", {
      deps: {
        "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
        "sap/ui/core/BusyIndicator": { hide: () => busy.push("hide") },
        "sap/m/MessageBox": {},
        "z2ui5/core/Server": server,
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          isControllerAlive: () => app.alive,
          runCallbacks: (arr) => (arr || []).forEach((f) => f()),
          logError: (m) => logged.push(m),
        },
        "z2ui5/core/FrontendAction": {
          // a spec may replace the response mid-phase, the way a parallel
          // request does while the system actions are still awaiting
          runSystem: () => hooks.onRunSystem?.(),
          // ... and hand an action's result back - a promise for the async
          // ones (SET_ODATA_MODEL), which the runner awaits
          runCustom: (item) => {
            customs.push(item);
            return hooks.onRunCustom?.(item);
          },
        },
        "z2ui5/core/actions/Slots": {
          action: (_ctx, method) => pushes.push(method),
        },
        "z2ui5/core/ViewSlots": { destroy: (_ctx, key) => destroys.push(key) },
        "z2ui5/core/Router": {
          sync: (_ctx, o) => syncs.push(o),
          dispatchPendingAppHash: () => pendingHash.push("delivered"),
        },
      },
    });
    ctrl.ctx = ctx;
    return {
      ctrl,
      ctx,
      state,
      server,
      pushes,
      syncs,
      hooks,
      destroys,
      busy,
      pendingHash,
      customs,
      app,
      renderErrors,
      logged,
    };
  }

  // The app-owned hash listener (cs_event-hash_attach_changed) belongs to
  // the app that registered it: the backend keeps no record of it and the
  // client interface promises it dies with the app switch - but only
  // AppState.reset( ), the component teardown, ever cleared it. So app A's
  // listener kept dispatching A's event name into app B on every Back /
  // hash edit, and Router.sync skipped B's app-state URL upkeep meanwhile.
  test("a response naming another app drops the leaving app's hash listener", async () => {
    const { ctrl, state, destroys } = loadForAfterRendering();
    state.renderedApp = "Z2UI5_CL_APP_A";
    state.shortcuts = { "ctrl+s": {} };
    state.hashEvent = "NAV";
    state.appHash = "/page2";
    state.pendingAppHash = "/page3";
    // ... and the keystroke a check_queue_last wire of app A kept while
    // the roundtrip that switched to B was in flight: dispatched after
    // this response it went out under B's draft id, an event B never
    // registered
    const queuedDispatches = [];
    state.oQueuedEvent = {
      controller: { eB: (...a) => queuedDispatches.push(a) },
      args: [["LIVE_CHANGE", false, false, false, true], "abc"],
    };
    state.oResponse = { ID: "D2", APP: "Z2UI5_CL_APP_B", MODELPRESENT: false };

    await ctrl._processAfterRendering(1);

    expect(state.renderedApp).toBe("Z2UI5_CL_APP_B");
    expect(state.shortcuts).toEqual({});
    expect(state.hashEvent).toBe(null);
    expect(state.appHash).toBe("");
    expect(state.pendingAppHash).toBe(null);
    expect(state.oQueuedEvent).toBe(null);
    expect(queuedDispatches).toEqual([]);
    // the standalone slots of the leaving app go with it
    expect(destroys).toEqual(["POPUP", "POPOVER"]);
  });

  test("a same-app response still dispatches the queued event", async () => {
    // the counterpart: the drop is about the app SWITCH, not about every
    // response - a roundtrip of the same app hands the kept keystroke on
    const { ctrl, state } = loadForAfterRendering();
    state.renderedApp = "Z2UI5_CL_APP_A";
    const queuedDispatches = [];
    state.oQueuedEvent = {
      controller: { eB: (...a) => queuedDispatches.push(a) },
      args: [["LIVE_CHANGE"], "abc"],
    };
    state.oResponse = { ID: "D2", APP: "Z2UI5_CL_APP_A", MODELPRESENT: false };

    await ctrl._processAfterRendering(1);

    expect(state.oQueuedEvent).toBe(null);
    expect(queuedDispatches).toEqual([[["LIVE_CHANGE"], "abc"]]);
  });

  // FrontendAction.execute promises that a failing handler is logged, never
  // thrown - and kept it for the synchronous ones only. An async action
  // (SET_ODATA_MODEL loading its client) that REJECTED escaped the await in
  // _runPendingCustomJs: the actions behind it never ran, the queued event
  // and the parked hash were skipped, and a screen that had rendered fine
  // ended in the fatal "App Terminated" overlay plus an unhandled rejection.
  test("a rejected async follow-up action is logged and the rest still runs", async () => {
    const { ctrl, state, hooks, customs, logged, renderErrors, pendingHash } =
      loadForAfterRendering();
    const queuedDispatches = [];
    state.oQueuedEvent = {
      controller: { eB: (...a) => queuedDispatches.push(a) },
      args: [["LIVE_CHANGE"], "abc"],
    };
    state.oResponse = {
      ID: "D1",
      _pendingCustomJs: [["SET_ODATA_MODEL", "/svc"], ["SET_FOCUS", "inp"]],
    };
    hooks.onRunCustom = (item) =>
      item[0] === "SET_ODATA_MODEL"
        ? Promise.reject(new Error("datajs 404"))
        : undefined;

    await ctrl._processAfterRendering(1);

    expect(customs).toEqual([["SET_ODATA_MODEL", "/svc"], ["SET_FOCUS", "inp"]]);
    expect(
      logged.some((m) => m.includes("async action 'SET_ODATA_MODEL' failed")),
    ).toBe(true);
    expect(renderErrors).toEqual([]);
    expect(queuedDispatches).toEqual([[["LIVE_CHANGE"], "abc"]]);
    expect(pendingHash).toEqual(["delivered"]);
    expect(state.isBusy).toBe(false);
  });

  // The display phase of a response a newer REQUEST superseded (a
  // Back/Forward restore mid-build) may well fail - a slot the restore tore
  // down, a duplicate id - and that failure is the newer request's to own,
  // as Server.readHttp swallows a stale request's own. It used to raise the
  // fatal overlay over the screen the restore's response was building, and
  // the overlay ends the app. Busy stays with the newer request, exactly as
  // for a superseded response that did not throw.
  test("a superseded response's failed build raises no overlay", async () => {
    const { ctrl, ctx, state, hooks, busy, renderErrors, logged, customs } =
      loadForAfterRendering();
    state.oResponse = {
      ID: "D1",
      S_ACTION: { T_SYSTEM: [{}] },
      _pendingCustomJs: [["TOAST"]],
    };
    hooks.onRunSystem = () => {
      ctx.server.requestSeq = 2;
      throw new Error("adding element with duplicate id 'popupId'");
    };

    await ctrl._processAfterRendering(1);

    expect(renderErrors).toEqual([]);
    expect(logged.some((m) => m.includes("unexpected error"))).toBe(true);
    expect(busy).toEqual([]);
    expect(state.isBusy).toBe(true);
    // merely superseded, not replaced: the screen is still this one's, so
    // its own follow-up actions run as for the non-throwing case above
    expect(customs).toEqual([["TOAST"]]);
  });

  test("the winning response's failed build still raises the overlay", async () => {
    const { ctrl, state, hooks, busy, renderErrors } = loadForAfterRendering();
    state.oResponse = { ID: "D1", S_ACTION: { T_SYSTEM: [{}] } };
    const boom = new Error("view XML broken");
    hooks.onRunSystem = () => {
      throw boom;
    };

    await ctrl._processAfterRendering(1);

    expect(renderErrors).toEqual([
      { e: boom, title: "Unexpected Error Occurred - App Terminated" },
    ]);
    expect(busy).toEqual(["hide"]);
    expect(state.isBusy).toBe(false);
  });

  test("a REPLACED response leaves busy, custom JS and the parked hash to the newer one", async () => {
    const { ctrl, state, pushes, syncs, hooks, busy, pendingHash, customs } =
      loadForAfterRendering();
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
    // ran no custom JS and delivered no parked hash - the newer response does.
    // The custom JS is ASSERTED, not only claimed in the title: the newer
    // response has LANDED here, so the screen this one queued its actions for
    // is gone. (The stamp-only case below is the other half of the pair.)
    expect(busy).toEqual([]);
    expect(state.isBusy).toBe(true);
    expect(pendingHash).toEqual([]);
    expect(customs).toEqual([]);
  });

  // The display phase stops on the request STAMP, the phase-2 guard used to
  // ask the response RECORD - and the record only flips once the newer
  // request's response lands. In between (a Back/Forward restore is exactly
  // that window) a response whose system actions were cut short still ran
  // phase 2: it ended the busy state the restore relies on and let Router.sync
  // consume the restore's navFromHash flag. ONE stamp answers both phases.
  test("a response cut short by a newer REQUEST stops before phase 2", async () => {
    const {
      ctrl,
      ctx,
      state,
      pushes,
      syncs,
      hooks,
      busy,
      pendingHash,
      customs,
    } = loadForAfterRendering();
    state.oResponse = {
      ID: "D1",
      MODELPRESENT: true,
      S_ACTION: { T_SYSTEM: [{}] },
      _pendingCustomJs: [["TOAST"]],
    };
    // the restore dispatches its request while the system actions run - the
    // response record still points at THIS response, only the stamp moved
    hooks.onRunSystem = () => {
      ctx.server.requestSeq = 2;
    };

    await ctrl._processAfterRendering(1);

    expect(state.oResponse.ID).toBe("D1");
    expect(pushes).toEqual([]);
    expect(syncs).toEqual([]);
    expect(busy).toEqual([]);
    expect(state.isBusy).toBe(true);
    expect(pendingHash).toEqual([]);
    // ... but its OWN follow-up actions still ran: the newer request is
    // merely DISPATCHED, so the screen they were queued for is still the one
    // on display, and nothing else will ever run them - the superseding
    // request answers with its own T_CUSTOM. This is what the app's first
    // roundtrip lost every time a control fired an event while the initial
    // view rendered (samples-controls 350: ICON_POOL registerFont; 534:
    // eight Wizard setNextStep calls).
    expect(customs).toEqual([["TOAST"]]);
  });

  // The app torn down mid-phase is the other half of "the screen is gone":
  // there is no screen left to act on, so the queued actions are dropped -
  // the case the stamp-only test above must NOT be confused with.
  test("an app torn down mid-phase runs no follow-up actions", async () => {
    const { ctrl, state, hooks, busy, customs, app } = loadForAfterRendering();
    state.oResponse = {
      ID: "D1",
      S_ACTION: { T_SYSTEM: [{}] },
      _pendingCustomJs: [["TOAST"]],
    };
    hooks.onRunSystem = () => {
      app.alive = false;
    };

    await ctrl._processAfterRendering(1);

    expect(busy).toEqual([]);
    expect(state.isBusy).toBe(true);
    expect(customs).toEqual([]);
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
    const { Lib, state, ctx } = loadLib({
      clearTimeout: (handle) => cleared.push(handle),
    });
    const bodies = [];
    const { module: ctrl } = loadModule("controller/View1.controller.js", {
      deps: {
        "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
        "sap/ui/core/BusyIndicator": { show: () => {}, hide: () => {} },
        "sap/m/MessageBox": { alert: () => {} },
        "z2ui5/core/Server": { roundtrip: (_ctx, oBody) => bodies.push(oBody) },
        "z2ui5/core/Lib": Lib,
        "z2ui5/core/FrontendAction": {},
        "z2ui5/core/actions/Slots": {},
        // no slot owns this controller: _pickModelForRoundtrip bails out and
        // the request carries no model delta, which is not what is under test
        "z2ui5/core/ViewSlots": { keyOfController: () => undefined },
        "z2ui5/core/Router": {},
      },
      sandbox: { navigator: { onLine: true } },
    });
    ctrl.ctx = ctx;
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

  // A wire hand-written as eB('SAVE') used to be destructured character by
  // character: the event went out as "S", the flags read from the letters,
  // and the backend answered with nothing an app could recognise. There is
  // no event to send - say so and stop.
  test("a first argument that is no event array is logged, not sent", () => {
    const { ctrl, state, bodies } = loadForDispatch();

    ctrl.eB("SAVE");
    ctrl.eB();

    expect(bodies).toEqual([]);
    expect(state.isBusy).toBe(false);
    expect(state.errors.map((e) => e.message)).toEqual([
      'eB: the first argument must be the event array, got "SAVE"',
      "eB: the first argument must be the event array, got undefined",
    ]);
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
    const ctx = specContext({
      // the shipped default - displayMain empties it on every rebuild
      oApp: {
        removeAllPages: () => {},
        insertPage: (v) => pages.push(v),
      },
    });
    ctx.server.requestSeq = requestSeq;
    const { module: SlotsModule } = loadModule("core/actions/Slots.js", {
      deps: {
        "sap/ui/core/mvc/XMLView": { create: async () => oView },
        "sap/ui/model/json/JSONModel": JSONModel,
        "z2ui5/core/Context": contextStub(ctx),
        "z2ui5/core/Lib": {
          usesXmlTemplating: () => false,
          effectiveSizeLimit: () => undefined,
          isRootModelSlot: (k) => k === "MAIN" || k === "NEST" || k === "NEST2",
          isAlive: () => true,
          logError: () => {},
        },
        "z2ui5/core/ViewSlots": {
          // the real module prefixes with the owner component; no owner here
          ownId: (_ctx, id) => id,
          fragmentIdOf: (_ctx, slot) => slot.fragmentId,
          slots: [],
          getView: () => undefined,
          getController: () => undefined,
          setView: () => {},
          destroy: (_ctx, key) => destroyed.push(key),
        },
      },
    });
    const Slots = { action: (...a) => SlotsModule.action(ctx, ...a) };
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
    const odataCtx = specContext({
      oResponse: { OVIEWMODEL: { A: 1 }, APP: "ZCL_APP" },
      oApp: { removeAllPages: () => {}, insertPage: () => {} },
    });
    const state = odataCtx.state;
    const openSlots = { MAIN: makeView("mainView") };
    // the client is loaded on first use through Lib.requireODataModel,
    // which probes sap.ui.require( id ) - seeded here, so the stub is
    // handed back synchronously, as a loaded module would be
    const sandbox = {
      sap: {
        ui: {
          require: (id) =>
            id === "sap/ui/model/odata/v2/ODataModel" ? ODataModel : undefined,
        },
      },
    };
    const shared = {
      "z2ui5/core/Lib": {
        // no view in these specs uses XML templating (Slots.templatePreprocessors)
        usesXmlTemplating: () => false,
        effectiveSizeLimit: () => undefined,
        isRootModelSlot: (k) => k === "MAIN",
        isAlive: () => true,
        isControllerAlive: () => true,
        logError: () => {},
        requireODataModel: () => Promise.resolve(ODataModel),
      },
      "z2ui5/core/ViewSlots": {
        // the real module prefixes with the owner component; no owner here
        ownId: (_ctx, id) => id,
        fragmentIdOf: (_ctx, slot) => slot.fragmentId,
        slots: [{ key: "MAIN", ownsModel: true }],
        getView: (_ctx, key) => openSlots[key],
        getController: () => undefined,
        setView: (_ctx, key, view) => (openSlots[key] = view),
        destroy: (_ctx, key) => delete openSlots[key],
        trackedModel: () => undefined,
      },
      "z2ui5/core/Context": contextStub(odataCtx),
    };
    const { module: SlotsModule } = loadModule("core/actions/Slots.js", {
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
      },
    });
    const Slots = { action: (...a) => SlotsModule.action(odataCtx, ...a) };
    const { module: ViewOps } = loadModule("core/actions/ViewOps.js", {
      deps: shared,
      sandbox,
    });
    return {
      Slots,
      ViewOps,
      ctx: odataCtx,
      state,
      clients,
      destroyed,
      openSlots,
    };
  }

  // SET_ODATA_MODEL is async since the client loads on first use - awaited,
  // as the custom-action runner awaits it. The handler reads the context
  // off the calling controller.
  const setOData = (ViewOps, ctx, url, name) =>
    ViewOps.handlers.SET_ODATA_MODEL({ ctx }, ["SET_ODATA_MODEL", url, name]);

  test("a NAMED SET_ODATA_MODEL client is destroyed on the next MAIN rebuild", async () => {
    const { Slots, ViewOps, ctx, clients, destroyed } = loadODataOwnership();

    await setOData(ViewOps, ctx, "/sap/opu/odata/sap/ORDERS/", "orders");
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

  test("a re-issue destroys the client it replaces, an app's own model never", async () => {
    const { ViewOps, ctx, state, clients, destroyed, openSlots } =
      loadODataOwnership();
    // a model the app itself put on the view is in no inventory
    const appOwned = { destroy: () => destroyed.push(appOwned) };
    openSlots.MAIN.setModel(appOwned, "app");

    await setOData(ViewOps, ctx, "/svc/one/", "orders");
    await setOData(ViewOps, ctx, "/svc/two/", "orders");
    expect(destroyed).toEqual([clients[0]]);

    await setOData(ViewOps, ctx, "/svc/three/", "app");
    expect(destroyed).toEqual([clients[0]]);
    expect(state.odataClients.size).toBe(2);
  });
});

test.describe("eB busy guard with check_queue_last (queued last event)", () => {
  // The wire of client->_event( s_ctrl-check_queue_last ): the event array
  // carries the flag at position [4], behind two reserved placeholders and
  // useMainModel (z2ui5_cl_ui5_srv_event=>get_event).
  const QUEUED = ["LIVE_CHANGE", false, false, false, true];
  const PLAIN = ["PRESS"];

  // One harness for BOTH sides of the slot: eB (the write side - the busy
  // guard that keeps instead of drops) and _processAfterRendering (the
  // read side - the dispatch once the roundtrip landed), on the same
  // controller, with a model whose edits the dispatch has to carry.
  function loadForQueue() {
    const roundtrips = [];
    const busy = [];
    const pendingHash = [];
    const ctx = specContext();
    ctx.server.requestSeq = 1;
    const state = ctx.state;
    const values = { VALUE: "" };
    const model = {
      _z2ui5ChangedPaths: new Set(),
      getData: () => values,
      getProperty: (path) => values[path.slice(1)],
    };
    const app = { alive: true };
    const { module: ctrl } = loadModule("controller/View1.controller.js", {
      deps: {
        "sap/ui/core/mvc/Controller": { extend: (name, methods) => methods },
        "sap/ui/core/BusyIndicator": {
          show: (delay) => busy.push(delay === 0 ? "show(0)" : "show"),
          hide: () => busy.push("hide"),
        },
        "sap/m/MessageBox": {},
        "z2ui5/core/Server": {
          responseError: () => {},
          roundtrip: (_ctx, body) => roundtrips.push(body),
        },
        "z2ui5/core/Lib": {
          isDestroyed: () => false,
          isControllerAlive: (c) => app.alive && c === ctrl,
          runCallbacks: (arr) => (arr || []).forEach((f) => f()),
          logError: () => {},
          cancelPendingTimers: () => {},
          // the shipped helper returns a fresh array and leaves plain data
          // alone - which is all a queued event holds
          normalizeEventArgs: (args) => args.slice(),
          buildDeltaFromPaths: (paths, data) => {
            const delta = {};
            for (const p of paths) delta[p.slice(1)] = data[p.slice(1)];
            return delta;
          },
          isRootModelSlot: () => true,
        },
        "z2ui5/core/FrontendAction": {
          runSystem: () => {},
          runCustom: () => {},
        },
        "z2ui5/core/actions/Slots": {
          action: () => {},
          resolveTrackedModel: () => model,
        },
        "z2ui5/core/ViewSlots": {
          keyOfController: () => "MAIN",
          getView: () => ({}),
          destroy: () => {},
        },
        "z2ui5/core/Router": {
          sync: () => {},
          dispatchPendingAppHash: () => pendingHash.push("delivered"),
        },
      },
      sandbox: { navigator: { onLine: true } },
    });
    ctrl.ctx = ctx;
    // typing into the bound field: the control writes the model and the
    // change tracker (actions/Slots trackChanges) records the path
    const type = (text) => {
      values.VALUE = text;
      model._z2ui5ChangedPaths.add("/VALUE");
    };
    return { ctrl, state, roundtrips, busy, pendingHash, model, type, app };
  }

  test("a queued wire fired while busy keeps the LAST event only, and shows the indicator", () => {
    const { ctrl, state, roundtrips, busy } = loadForQueue();
    state.isBusy = true;

    ctrl.eB(QUEUED, "a");
    ctrl.eB(QUEUED, "ab");
    ctrl.eB(QUEUED, "abc");

    expect(roundtrips).toEqual([]);
    expect(state.oQueuedEvent.controller).toBe(ctrl);
    expect(state.oQueuedEvent.args).toEqual([QUEUED, "abc"]);
    // the same steady overlay a dropped click shows, once per firing
    expect(busy).toEqual(["show(0)", "show(0)", "show(0)"]);
  });

  test("a wire without the flag is dropped as before", () => {
    const { ctrl, state, roundtrips, busy } = loadForQueue();
    state.isBusy = true;

    ctrl.eB(PLAIN);

    expect(roundtrips).toEqual([]);
    expect(state.oQueuedEvent).toBeNull();
    expect(busy).toEqual(["show(0)"]);
  });

  test("the queued event is dispatched through eB once the response has landed", async () => {
    const { ctrl, state, roundtrips, pendingHash, type } = loadForQueue();

    // keystroke 1 goes out at once ...
    type("a");
    ctrl.eB(QUEUED, "a");
    expect(roundtrips).toHaveLength(1);
    expect(roundtrips[0].MODEL).toEqual({ VALUE: "a" });
    expect(state.isBusy).toBe(true);

    // ... keystrokes 2 and 3 meet the roundtrip in flight
    type("ab");
    ctrl.eB(QUEUED, "ab");
    type("abc");
    ctrl.eB(QUEUED, "abc");
    expect(roundtrips).toHaveLength(1);

    // the response lands: the winning request's clear keeps /VALUE pending,
    // because the model no longer holds the value that went out (the
    // Server side of that rule is serverRequestSeq.spec.js)
    state.oResponse = { ID: "D1", MODELPRESENT: false };
    await ctrl._processAfterRendering(1);

    // the last keystroke went out as a roundtrip of its own, carrying the
    // control's current value both as its argument and in the model delta
    expect(roundtrips).toHaveLength(2);
    expect(roundtrips[1].ARGUMENTS).toEqual([QUEUED, "abc"]);
    expect(roundtrips[1].MODEL).toEqual({ VALUE: "abc" });
    expect(state.oQueuedEvent).toBeNull();
    // one roundtrip in flight at a time: the app is busy again ...
    expect(state.isBusy).toBe(true);
    // ... and the parked hash was still offered to the router (which
    // re-parks it while busy)
    expect(pendingHash).toEqual(["delivered"]);
  });

  test("the queued event's own dispatch is not swallowed by the guard", async () => {
    const { ctrl, state, roundtrips } = loadForQueue();
    state.isBusy = true;
    ctrl.eB(QUEUED, "abc");

    state.oResponse = { ID: "D1", MODELPRESENT: false };
    await ctrl._processAfterRendering(1);

    expect(roundtrips).toHaveLength(1);
    expect(roundtrips[0].ARGUMENTS).toEqual([QUEUED, "abc"]);
  });

  test("a superseded response leaves the queued event to the newer request", async () => {
    const { ctrl, state, roundtrips } = loadForQueue();
    state.isBusy = true;
    ctrl.eB(QUEUED, "abc");

    // a newer request went out while this response's actions ran
    state.oResponse = { ID: "D1", MODELPRESENT: false };
    await ctrl._processAfterRendering(0);

    expect(roundtrips).toEqual([]);
    expect(state.oQueuedEvent.args).toEqual([QUEUED, "abc"]);
    expect(state.isBusy).toBe(true);
  });

  test("a queued event whose controller is gone is dropped, not dispatched", async () => {
    const { ctrl, state, roundtrips } = loadForQueue();
    state.isBusy = true;
    ctrl.eB(QUEUED, "abc");
    // the popup the keystroke was typed into was closed by the response
    state.oQueuedEvent.controller = { eB: () => roundtrips.push("dead") };

    state.oResponse = { ID: "D1", MODELPRESENT: false };
    await ctrl._processAfterRendering(1);

    expect(roundtrips).toEqual([]);
    expect(state.oQueuedEvent).toBeNull();
  });

  test("the reserved slot [2] is ignored - a truthy value there never bypasses the busy guard", () => {
    const { ctrl, state, roundtrips } = loadForQueue();
    state.isBusy = true;

    // a wire rendered by an older backend can still carry true here; eB must
    // read straight past it and queue on the flag at [4] as usual
    ctrl.eB(["LIVE_CHANGE", false, true, false, true], "abc");

    expect(roundtrips).toEqual([]);
    expect(state.oQueuedEvent).not.toBeNull();
  });

  // ------------------------------------------------------------------
  // check_no_busy - the same wire, with the overlay left down. What is
  // suppressed is ONLY the two BusyIndicator.show calls; the roundtrip,
  // the busy state, the guard and the queue behave exactly as above.
  // ------------------------------------------------------------------
  // position [5], behind queueLast - which is written as false rather than
  // left out, so [5] is [5] for a wire that carries only this flag
  const SILENT = ["LIVE_CHANGE", false, false, false, false, true];
  const SILENT_QUEUED = ["LIVE_CHANGE", false, false, false, true, true];

  test("a check_no_busy wire round-trips without raising the indicator", () => {
    const { ctrl, state, roundtrips, busy, type } = loadForQueue();

    type("a");
    ctrl.eB(SILENT, "a");

    // the request went out and the app IS busy - only the overlay stayed down
    expect(roundtrips).toHaveLength(1);
    expect(roundtrips[0].MODEL).toEqual({ VALUE: "a" });
    expect(state.isBusy).toBe(true);
    expect(busy).toEqual([]);
  });

  test("a check_no_busy wire that meets a roundtrip in flight shows nothing", () => {
    const { ctrl, state, busy } = loadForQueue();
    state.isBusy = true;

    // the show(0) of the busy guard is the one this flag is really about:
    // every keystroke typed during a roundtrip raised the overlay instantly
    ctrl.eB(SILENT_QUEUED, "ab");
    ctrl.eB(SILENT_QUEUED, "abc");

    expect(busy).toEqual([]);
    // suppressed, not exempted: the keystroke is still kept, last wins
    expect(state.oQueuedEvent.args).toEqual([SILENT_QUEUED, "abc"]);
  });

  test("the flag travels with the queued event - its own dispatch is silent too", async () => {
    const { ctrl, state, roundtrips, busy } = loadForQueue();
    state.isBusy = true;
    ctrl.eB(SILENT_QUEUED, "abc");

    state.oResponse = { ID: "D1", MODELPRESENT: false };
    await ctrl._processAfterRendering(1);

    expect(roundtrips).toHaveLength(1);
    expect(roundtrips[0].ARGUMENTS).toEqual([SILENT_QUEUED, "abc"]);
    // the response's own hide, and no show from the re-dispatch behind it
    expect(busy).toEqual(["hide"]);
  });

  test("a PLAIN wire dropped during a silent roundtrip still gets its overlay", () => {
    const { ctrl, busy, type } = loadForQueue();

    type("a");
    ctrl.eB(SILENT, "a");
    expect(busy).toEqual([]);

    // the flag is per WIRE, not per roundtrip: a click dropped while the
    // silent roundtrip runs needs the feedback the click always got
    ctrl.eB(PLAIN);
    expect(busy).toEqual(["show(0)"]);
  });
});

// ---------------------------------------------------------------------------
// slotById / slotValue: reaching a control in ANOTHER view slot from an event
// argument. An id is local to the view or fragment it was written in, and a
// `${...}` is a binding path, which addresses data and not controls - so
// before these two there was no way to read what a control in a dialog holds
// into the event that closes it. cs_event-image_editor_popup_close existed
// for exactly one instance of that problem and is removed with them.
// ---------------------------------------------------------------------------

test.describe("slotById (a control in a named slot)", () => {
  test("resolves in the named slot", () => {
    const editor = { id: "imageEditor" };
    const { controller, restore } = withSlotStub((slot, id) =>
      slot === "POPUP" && id === "imageEditor" ? editor : undefined,
    );
    expect(controller.slotById("POPUP", "imageEditor")).toBe(editor);
    restore();
  });

  test("an empty slot searches every open one, like cs_view-main", () => {
    const anywhere = { id: "x" };
    const { controller, restore } = withSlotStub(
      () => undefined,
      (id) => (id === "x" ? anywhere : null),
    );
    expect(controller.slotById("", "x")).toBe(anywhere);
    expect(controller.slotById(undefined, "x")).toBe(anywhere);
    restore();
  });

  test("a miss is null and is logged, not thrown", () => {
    const { controller, errors, restore } = withSlotStub();
    expect(controller.slotById("POPUP", "ghost")).toBe(null);
    expect(errors).toEqual(["slotById: no control 'ghost' in slot 'POPUP'"]);
    restore();
  });
});

test.describe("slotValue (the null-safe read)", () => {
  test("calls the getter and hands the value over", () => {
    const editor = { getImagePngDataURL: () => "data:image/png;base64,AAA" };
    const { controller, restore } = withSlotStub((slot, id) =>
      slot === "POPUP" && id === "imageEditor" ? editor : undefined,
    );
    expect(
      controller.slotValue("POPUP", "imageEditor", "getImagePngDataURL"),
    ).toBe("data:image/png;base64,AAA");
    restore();
  });

  // the whole reason this exists beside slotById: an argument expression is
  // evaluated while UI5 dispatches the handler, so a throw there loses the
  // EVENT - the button does nothing and the app cannot tell
  test("a closed slot is the empty string, logged, never a throw", () => {
    const { controller, errors, restore } = withSlotStub();
    expect(controller.slotValue("POPUP", "ghost", "getText")).toBe("");
    expect(errors).toEqual(["slotValue: no control 'ghost' in slot 'POPUP'"]);
    restore();
  });

  test("a method the control does not have is the empty string", () => {
    const { controller, errors, restore } = withSlotStub(() => ({}));
    expect(controller.slotValue("POPUP", "x", "getNothing")).toBe("");
    expect(errors).toEqual([
      "slotValue: 'getNothing' is not a method of control 'x'",
    ]);
    restore();
  });

  test("a getter that throws is caught, not propagated", () => {
    const { controller, errors, restore } = withSlotStub(() => ({
      boom() {
        throw new Error("nope");
      },
    }));
    expect(controller.slotValue("POPUP", "x", "boom")).toBe("");
    expect(errors).toEqual(["slotValue: 'boom' on 'x' failed"]);
    restore();
  });

  test("undefined and null come back as the empty string, not as themselves", () => {
    const { controller, restore } = withSlotStub(() => ({
      getUndef: () => undefined,
      getNull: () => null,
      getEmpty: () => "",
      getFalse: () => false,
      getZero: () => 0,
    }));
    expect(controller.slotValue("MAIN", "x", "getUndef")).toBe("");
    expect(controller.slotValue("MAIN", "x", "getNull")).toBe("");
    expect(controller.slotValue("MAIN", "x", "getEmpty")).toBe("");
    // a falsy VALUE is still a value and must travel as itself
    expect(controller.slotValue("MAIN", "x", "getFalse")).toBe(false);
    expect(controller.slotValue("MAIN", "x", "getZero")).toBe(0);
    restore();
  });
});
