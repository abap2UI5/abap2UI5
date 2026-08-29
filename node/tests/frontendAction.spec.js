// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the frontend action handlers (CONTROL_GLOBAL / CONTROL_BY_ID,
// BINDING_CALL, variants, KEYBOARD_SHORTCUT, SET_FOCUS, timers, ...) through
// the real FrontendAction.js merge of the core/actions/* modules (loaded via
// a stubbed sap.ui.define). The focus is the whitelist boundary and the
// argument casting.

// `requires` seeds the sap.ui.require stub for targets that resolve their
// global LAZILY by module id (ICON_POOL, THEMING), which the array form below
// does not cover.
function load({ sandbox, requires = {} } = {}) {
  const calls = [];
  const errors = [];
  const rec =
    (name) =>
    (...a) =>
      calls.push([name, ...a]);
  const MessageToast = { show: rec("toast.show") };
  const MessageBox = {
    show: rec("box.show"),
    alert: rec("box.alert"),
    confirm: rec("box.confirm"),
    information: rec("box.information"),
    warning: rec("box.warning"),
    error: rec("box.error"),
    success: rec("box.success"),
  };
  const BusyIndicator = { show: rec("busy.show"), hide: rec("busy.hide") };
  const Theming = { setTheme: rec("theme.set") };
  const Popup = { setWithinArea: rec("popup.setWithinArea") };
  const controls = {};
  const views = {};
  const ViewSlots = {
    destroy: (key) => calls.push(["slots.destroy", key]),
    resolveById: (id) => controls[id] || null,
    byId: (_key, id) => controls[id] || null,
    getView: (key) => views[key] || null,
  };
  // whenRendered runs its callback once the control is in the DOM; the real
  // one defers to onAfterRendering when it is not. The stub runs it straight
  // away (the specs treat the anchor as already rendered).
  const Router = { sync: (...a) => calls.push(["router.sync", ...a]) };
  const Lib = {
    logError: (m) => errors.push(m),
    runCallbacks: () => {},
    toText: (val) => (val == null ? "" : String(val)),
    whenRendered: (_control, _owner, fn) => fn(),
    isDestroyed: (o) => Boolean(o?.isDestroyed && o.isDestroyed()),
    // same shape as the real validator (core/Lib.js): empty and malformed
    // values are unsafe, data:/blob:/http(s) pass - relative URLs resolve
    isSafeDownloadURL: (url) => {
      if (!url) return false;
      try {
        const p = new URL(url, "http://localhost:3000");
        return ["data:", "blob:", "http:", "https:"].includes(p.protocol);
      } catch {
        return false;
      }
    },
  };
  const AppState = { state: { onBeforeEventFrontend: [], shortcuts: {} } };
  // the VIEW_SLOTS display/updateModel hook routes into actions/Slots; the
  // stub records the routed calls and lets a test swap the behavior
  const slotCalls = [];
  const Slots = {
    action: (...a) => slotCalls.push(a),
  };
  function Filter(path, operator, value1, value2) {
    Object.assign(this, { path, operator, value1, value2 });
  }
  function Sorter(path, descending, group) {
    Object.assign(this, { path, descending, group });
  }
  const FilterOperator = new Proxy({}, { get: (_t, op) => op });
  const { module, sandbox: ctx } = loadModule("core/FrontendAction.js", {
    // the domain modules under core/actions/ load for real - this spec
    // exercises the composed dispatch exactly as it ships. MessageToast is
    // not a define-dependency any more (lazy require, Popup.Dock capture
    // order) - the stub arrives through the seeded sap.ui.require below.
    autoLoad: true,
    sandbox: {
      ...(sandbox || {}),
      sap: {
        ui: {
          require: Object.assign(
            (vDep, fnCb) => {
              if (
                Array.isArray(vDep) &&
                vDep[0] === "sap/m/MessageToast" &&
                fnCb
              )
                fnCb(MessageToast);
              if (typeof vDep === "string") return requires[vDep] ?? null;
              return null;
            },
            // the real one roots a module path against the UI5 resource base;
            // a recognizable prefix is all an assertion needs
            { toUrl: (sPath) => `/resources/${sPath}` },
          ),
        },
      },
    },
    deps: {
      "sap/m/MessageBox": MessageBox,
      "sap/ui/core/BusyIndicator": BusyIndicator,
      "sap/ui/core/Popup": Popup,
      "sap/ui/core/Theming": Theming,
      "sap/ui/model/odata/v2/ODataModel": function () {},
      "sap/ui/model/Filter": Filter,
      "sap/ui/model/FilterOperator": FilterOperator,
      "sap/ui/model/Sorter": Sorter,
      "sap/m/library": {},
      "sap/ui/util/Storage": function () {},
      "z2ui5/core/Router": Router,
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": AppState,
      "z2ui5/core/actions/Slots": Slots,
    },
  });
  return {
    FrontendAction: module,
    calls,
    errors,
    controls,
    views,
    AppState,
    Popup,
    ctx,
    slotCalls,
    Slots,
  };
}

test.describe("CONTROL_GLOBAL (global objects)", () => {
  test("calls a whitelisted global method with its param", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "Saved!",
    ]);
    expect(calls).toEqual([["toast.show", "Saved!"]]);
  });

  test("composes a toast from a template + client-resolved extras", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "Action triggered on item: {0}",
      "Franchise Store",
    ]);
    expect(calls).toEqual([
      ["toast.show", "Action triggered on item: Franchise Store"],
    ]);
  });

  test("substitutes a value-first template ({0} ...) and multiple placeholders", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "{0} selected at {1}",
      "Item A",
      "10:30",
    ]);
    expect(calls).toEqual([["toast.show", "Item A selected at 10:30"]]);
  });

  test("leaves an out-of-range placeholder untouched", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "{0} and {1}",
      "only-one",
    ]);
    expect(calls).toEqual([["toast.show", "only-one and {1}"]]);
  });

  test("an options object rides as the last argument", () => {
    // client->message_toast_display( ) sends the full option set. The backend
    // embeds it as real JSON, so it arrives as an OBJECT while every template
    // value is a string - that is what tells the two apart, no marker needed.
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "Saved!",
      { duration: 250, class: "myCls" },
    ]);
    // `class` is no MessageToast option - it is stripped here and applied to
    // the toast's DOM node instead (see actions/ControlCall showToast)
    expect(calls).toEqual([["toast.show", "Saved!", { duration: 250 }]]);
  });

  test("a template and an options object survive each other", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "{0} saved",
      "Item A",
      { duration: 250 },
    ]);
    expect(calls).toEqual([["toast.show", "Item A saved", { duration: 250 }]]);
  });

  test("the box type is the method, and it takes options too", () => {
    const { FrontendAction, calls } = load();
    const ebCalls = [];
    const oController = { eB: (...a) => ebCalls.push(a) };
    FrontendAction.execute(oController, [
      "CONTROL_GLOBAL",
      "MESSAGE_BOX",
      "confirm",
      "Delete?",
      { onClose: "ANSWERED" },
    ]);
    expect(calls).toHaveLength(1);
    const [name, text, opts] = calls[0];
    expect([name, text]).toEqual(["box.confirm", "Delete?"]);
    // the ONCLOSE event name was turned into the callback that round-trips
    // the pressed action through eB (outside the event array - see
    // actions/ControlCall showBox)
    opts.onClose("OK");
    expect(ebCalls).toEqual([[["ANSWERED"], "OK"]]);
  });

  test("ROUTER/sync hands the whole options object to the router", () => {
    // Router derives ONE outcome from all of it, so it gets the object as it
    // came - the id rides along because the route carries the draft
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "ROUTER",
      "sync",
      { setNavRouting: "KEEP", checkNavAppCall: true, id: "DRAFT1" },
    ]);
    expect(calls).toEqual([
      [
        "router.sync",
        { setNavRouting: "KEEP", checkNavAppCall: true, id: "DRAFT1" },
      ],
    ]);
  });

  test("an unlisted box type is rejected rather than shown", () => {
    const { FrontendAction, calls, errors } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_BOX",
      "notAMethod",
      "x",
    ]);
    expect(calls).toEqual([]);
    expect(errors[0]).toContain("not allowed");
  });

  test("MessageBox variants also accept a template", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_BOX",
      "error",
      "Upload of {0} failed",
      "report.pdf",
    ]);
    expect(calls).toEqual([["box.error", "Upload of report.pdf failed"]]);
  });

  test("a lone string is passed through unchanged (no template parsing)", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "100% {done}",
    ]);
    expect(calls).toEqual([["toast.show", "100% {done}"]]);
  });

  test("a conditional placeholder {N?a:b} picks by truthiness of the value", () => {
    const { FrontendAction, calls } = load();
    // toggle pressed -> "Pressed", not pressed -> "Unpressed" (080 shape)
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "{0} {1?Pressed:Unpressed}",
      "__button0",
      "true",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "{0} {1?Pressed:Unpressed}",
      "__button0",
      "false",
    ]);
    expect(calls).toEqual([
      ["toast.show", "__button0 Pressed"],
      ["toast.show", "__button0 Unpressed"],
    ]);
  });

  test("conditional treats empty/0/null as falsy", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "MESSAGE_TOAST",
      "show",
      "{0?on:off}",
      "",
    ]);
    expect(calls).toEqual([["toast.show", "off"]]);
  });

  test("casts int args (BusyIndicator.show(0))", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "BUSY_INDICATOR",
      "show",
      "0",
    ]);
    expect(calls).toEqual([["busy.show", 0]]);
  });

  test("POPUP.setWithinArea resolves a control id and hands over the CONTROL", () => {
    // sap/ui/core/Popup is a hard dependency now (loading it registers the
    // Popup.Dock enum MessageToast's dock validation needs)
    const { FrontendAction, calls, controls } = load();
    const area = { id: "withinArea" };
    controls.withinArea = area;
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "POPUP",
      "setWithinArea",
      "withinArea",
    ]);
    // the control, not its DOM node: Popup dereferences it when a popup opens,
    // so the area survives a re-render in between
    expect(calls).toEqual([["popup.setWithinArea", area]]);
  });

  test("POPUP.setWithinArea releases the area on an empty argument", () => {
    const { FrontendAction, calls } = load();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "POPUP",
      "setWithinArea",
      "",
    ]);
    expect(calls).toEqual([["popup.setWithinArea", null]]);
  });

  test("POPUP.setWithinArea reports an older runtime instead of throwing", () => {
    const { FrontendAction, calls, errors, Popup } = load();
    // UI5 1.71 has sap/ui/core/Popup but not setWithinArea (@since 1.89)
    delete Popup.setWithinArea;
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "POPUP",
      "setWithinArea",
      "withinArea",
    ]);
    expect(calls).toHaveLength(0);
    expect(errors).toEqual([
      "CONTROL_GLOBAL: 'POPUP.setWithinArea' not available",
    ]);
  });

  test("rejects a non-whitelisted object or method", () => {
    const { FrontendAction, calls, errors } = load();
    FrontendAction.execute(null, ["CONTROL_GLOBAL", "WINDOW", "close"]);
    FrontendAction.execute(null, ["CONTROL_GLOBAL", "THEMING", "destroy"]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(2);
  });

  test("INVISIBLE_MESSAGE.announce goes through the singleton instance", () => {
    const { FrontendAction, calls, ctx } = load();
    const announced = [];
    const instance = { announce: (...a) => announced.push(a) };
    ctx.sap.ui.require = (name) =>
      name === "sap/ui/core/InvisibleMessage"
        ? { getInstance: () => instance }
        : null;
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "INVISIBLE_MESSAGE",
      "announce",
      "New Information Bar of type Warning",
      "Assertive",
    ]);
    expect(announced).toEqual([
      ["New Information Bar of type Warning", "Assertive"],
    ]);
    expect(calls).toHaveLength(0);
  });

  test("INVISIBLE_MESSAGE reports an older runtime instead of throwing", () => {
    const { FrontendAction, errors, ctx } = load();
    // @since 1.78 - on 1.71 the lazy require returns undefined
    ctx.sap.ui.require = () => null;
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "INVISIBLE_MESSAGE",
      "announce",
      "hello",
    ]);
    expect(errors).toEqual([
      "CONTROL_GLOBAL: 'INVISIBLE_MESSAGE.announce' not available",
    ]);
  });

  test("VIEW_SLOTS routes destroy/display/updateModel to actions/Slots", () => {
    // the view slots are the framework's own registry, not a UI5 global -
    // destroy is ViewSlots' own method, display and updateModel live in
    // actions/Slots, and the hook sends all three to Slots.action
    const { FrontendAction, slotCalls } = load();
    const oController = {};
    FrontendAction.execute(oController, [
      "CONTROL_GLOBAL",
      "VIEW_SLOTS",
      "destroy",
      "POPUP",
    ]);
    FrontendAction.execute(oController, [
      "CONTROL_GLOBAL",
      "VIEW_SLOTS",
      "display",
      "POPOVER",
      "<Popover/>",
      { openById: "btn1" },
    ]);
    FrontendAction.execute(oController, [
      "CONTROL_GLOBAL",
      "VIEW_SLOTS",
      "updateModel",
    ]);
    expect(slotCalls).toEqual([
      ["destroy", "POPUP", undefined, {}, undefined],
      // the XML is a positional argument of its own - it must NOT be read as
      // a template value for the slot name
      ["display", "POPOVER", "<Popover/>", { openById: "btn1" }, undefined],
      // no slot: the frontend picks the open ones itself
      ["updateModel", undefined, undefined, {}, undefined],
    ]);
  });

  test("the system phase threads the request stamp into the display", () => {
    // the seq travels as the action CONTEXT (never shared state), so the
    // slot display can discard a build a newer parallel request superseded
    const { FrontendAction, slotCalls } = load();
    FrontendAction.executeSystem(
      null,
      ["CONTROL_GLOBAL", "VIEW_SLOTS", "display", "POPUP", "<Dialog/>"],
      { seq: 7 },
    );
    expect(slotCalls).toEqual([["display", "POPUP", "<Dialog/>", {}, 7]]);
  });

  test("an unlisted VIEW_SLOTS method is rejected", () => {
    const { FrontendAction, errors } = load();
    FrontendAction.execute({}, [
      "CONTROL_GLOBAL",
      "VIEW_SLOTS",
      "wipe",
      "POPUP",
    ]);
    expect(errors[0]).toContain("not allowed");
  });

  test("FORMATTING.setCustomCurrencies parses its JSON payload", () => {
    const { FrontendAction, ctx } = load();
    const set = [];
    // the module id is asserted, not assumed: this stub answered
    // "sap/ui/core/Formatting" until 2026-08-23 - a module no UI5 release has -
    // so the test passed while every real call resolved to undefined and did
    // nothing. A stub that mirrors the code under test proves only that the two
    // agree.
    ctx.sap.ui.require = (name) =>
      name === "sap/base/i18n/Formatting"
        ? { setCustomCurrencies: (v) => set.push(v) }
        : null;
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "FORMATTING",
      "setCustomCurrencies",
      '{"BGN4":{"digits":4},"WWWW":{"digits":5}}',
    ]);
    expect(set).toEqual([{ BGN4: { digits: 4 }, WWWW: { digits: 5 } }]);
  });

  test("FORMATTING asks for the module id UI5 actually ships", () => {
    const { FrontendAction, ctx } = load();
    const asked = [];
    ctx.sap.ui.require = (name) => {
      asked.push(name);
      return { setCustomCurrencies: () => {} };
    };
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "FORMATTING",
      "setCustomCurrencies",
      "{}",
    ]);
    // sap/base/i18n/Formatting is the one Formatting module in OpenUI5 and the
    // one Core.js loads; sap/ui/core/Formatting does not exist
    expect(asked).toContain("sap/base/i18n/Formatting");
  });

  test("a trailing object stays an ARGUMENT on a non-message target", () => {
    // the options extraction applies to a `display` target only - everywhere
    // else a trailing object is a declared argument kind and must reach the
    // method as one
    const { FrontendAction, ctx } = load();
    const added = [];
    ctx.sap.ui.require = (name) =>
      name === "sap/base/i18n/Formatting"
        ? { addCustomCurrencies: (...a) => added.push(a) }
        : null;
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "FORMATTING",
      "addCustomCurrencies",
      { BGN4: { digits: 4 } },
    ]);
    expect(added).toEqual([[{ BGN4: { digits: 4 } }]]);
  });
});

test.describe("executeSystem (the SYSTEM phase entry point)", () => {
  test("returns the handler result so an async display can be awaited", async () => {
    const { FrontendAction, Slots } = load();
    Slots.action = (_m, _slot, xml) => Promise.resolve(`built:${xml}`);
    const result = FrontendAction.executeSystem(null, [
      "CONTROL_GLOBAL",
      "VIEW_SLOTS",
      "display",
      "POPUP",
      "<Dialog/>",
    ]);
    expect(await result).toBe("built:<Dialog/>");
  });

  test("does NOT swallow a failing display", () => {
    // execute( ) logs and moves on; a broken view build has to reach
    // _processAfterRendering and surface the fatal overlay instead
    const { FrontendAction, Slots } = load();
    Slots.action = () => {
      throw new Error("malformed XML");
    };
    expect(() =>
      FrontendAction.executeSystem(null, [
        "CONTROL_GLOBAL",
        "VIEW_SLOTS",
        "display",
        "POPUP",
        "<broken",
      ]),
    ).toThrow("malformed XML");
  });

  test("an unknown system action is reported, not thrown", () => {
    const { FrontendAction, errors } = load();
    FrontendAction.executeSystem(null, ["NO_SUCH_ACTION"]);
    expect(errors[0]).toContain("unknown system action");
  });
});

/* An icon collection outside the default SAP-icons font resolves only after
 * IconPool.registerFont. A normal UI5 app does that in its Component's init;
 * an abap2UI5 app has no Component, and IconPool is a module singleton no
 * other target could reach - so the URI rendered no glyph, silently. */
test.describe("ICON_POOL (registering an icon collection)", () => {
  function withIconPool() {
    const fonts = [];
    const { FrontendAction, errors } = load({
      requires: {
        "sap/ui/core/IconPool": { registerFont: (cfg) => fonts.push(cfg) },
      },
    });
    return { FrontendAction, fonts, errors };
  }

  test("registers the collection, resolving the module path to a URL", () => {
    const { FrontendAction, fonts } = withIconPool();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "ICON_POOL",
      "registerFont",
      "SAP-icons-TNT",
      "sap/tnt/themes/base/fonts/",
    ]);
    expect(fonts.length).toEqual(1);
    expect(fonts[0].fontFamily).toEqual("SAP-icons-TNT");
    // toUrl turned the module path into something rooted, not passed raw
    expect(fonts[0].fontURI).not.toEqual("sap/tnt/themes/base/fonts/");
    expect(fonts[0].fontURI).toContain("sap/tnt/themes/base/fonts/");
  });

  test("an absolute URL is passed through untouched", () => {
    const { FrontendAction, fonts } = withIconPool();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "ICON_POOL",
      "registerFont",
      "MyFont",
      "https://example.org/fonts/",
    ]);
    expect(fonts[0].fontURI).toEqual("https://example.org/fonts/");
  });

  test("the same collection is registered once, not on every roundtrip", () => {
    const { FrontendAction, fonts } = withIconPool();
    const call = () =>
      FrontendAction.execute(null, [
        "CONTROL_GLOBAL",
        "ICON_POOL",
        "registerFont",
        "SAP-icons-TNT",
        "sap/tnt/themes/base/fonts/",
      ]);
    call();
    call();
    call();
    expect(fonts.length).toEqual(1);
  });

  test("a missing fontURI is reported instead of registering a broken font", () => {
    const { FrontendAction, fonts, errors } = withIconPool();
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "ICON_POOL",
      "registerFont",
      "SAP-icons-TNT",
    ]);
    expect(fonts.length).toEqual(0);
    expect(errors.join(" ")).toContain("fontURI");
  });
});

test.describe("CONTROL_BY_ID", () => {
  test("resolves the control and casts the args", () => {
    const { FrontendAction, calls, controls } = load();
    controls.myTable = { scrollToIndex: (i) => calls.push(["scroll", i]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "myTable",
      "",
      "scrollToIndex",
      "42",
    ]);
    expect(calls).toEqual([["scroll", 42]]);
  });

  // sap.m.Tree and sap.ui.table.TreeTable both expand/collapse by INDEX, and
  // only the table hands indices over (getSelectedIndices). The m.Tree route
  // is getSelectedItems() + indexOfItem() - a loop, and a loop in an event
  // argument needs a JS callback the UI5 expression grammar cannot parse at
  // all, so the app has no spelling for this without the synthetic method.
  test("expandSelected maps an m.Tree selection to indices", () => {
    const { FrontendAction, calls, controls } = load();
    const items = [{ k: "a" }, { k: "b" }, { k: "c" }];
    controls.myTree = {
      getSelectedItems: () => [items[2], items[0]],
      indexOfItem: (o) => items.indexOf(o),
      expand: (i) => calls.push(["expand", i]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "myTree",
      "",
      "expandSelected",
    ]);
    expect(calls).toEqual([["expand", [2, 0]]]);
  });

  test("collapseSelected reads a TreeTable's indices directly", () => {
    const { FrontendAction, calls, controls } = load();
    controls.myTable = {
      getSelectedIndices: () => [1, 4],
      collapse: (i) => calls.push(["collapse", i]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "myTable",
      "",
      "collapseSelected",
    ]);
    expect(calls).toEqual([["collapse", [1, 4]]]);
  });

  // an index of -1 means the tree no longer holds that item; expand(-1) is not
  // a smaller mistake than expand(undefined)
  test("expandSelected drops an item the tree no longer holds", () => {
    const { FrontendAction, calls, controls } = load();
    const kept = { k: "a" };
    controls.myTree = {
      getSelectedItems: () => [kept, { k: "gone" }],
      indexOfItem: (o) => (o === kept ? 0 : -1),
      expand: (i) => calls.push(["expand", i]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "myTree",
      "",
      "expandSelected",
    ]);
    expect(calls).toEqual([["expand", [0]]]);
  });

  // nothing selected is not an error - and not a re-render of a tree the user
  // did not touch either
  test("expandSelected on an empty selection calls nothing", () => {
    const { FrontendAction, calls, controls, errors } = load();
    controls.myTree = {
      getSelectedItems: () => [],
      indexOfItem: () => -1,
      expand: (i) => calls.push(["expand", i]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "myTree",
      "",
      "expandSelected",
    ]);
    expect(calls).toEqual([]);
    expect(errors).toEqual([]);
  });

  test("expandSelected on a control with no selection says so", () => {
    const { FrontendAction, calls, controls, errors } = load();
    controls.notATree = { expand: (i) => calls.push(["expand", i]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "notATree",
      "",
      "expandSelected",
    ]);
    expect(calls).toEqual([]);
    expect(errors.join(" ")).toContain("no selection");
  });

  // sap.m.p13n.SelectionPanel/SortPanel/GroupPanel take their items through
  // setP13nData() only - the panels expose no bindable aggregation for them -
  // so seeding a p13n popup used to need hand-written custom JS. The `object`
  // arg kind carries the whole item list as one JSON payload.
  test("casts the setP13nData payload from JSON (p13n panels)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.columnsPanel = {
      setP13nData: (data) => calls.push(["setP13nData", data]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "columnsPanel",
      "",
      "setP13nData",
      '[{"name":"key1","label":"City","visible":true}]',
    ]);
    expect(calls).toEqual([
      ["setP13nData", [{ name: "key1", label: "City", visible: true }]],
    ]);
  });

  // A control CLONED from an aggregation template has no id the backend can
  // spell: UI5 mints it as `<templateId>-<parentId>-<index>` and the parent id
  // carries the runtime view prefix (measured: `v1--tpl-v1--car-0`). So an
  // aggregation item is addressed positionally - "<id>/<aggregation>/<index>" -
  // which is the UI5 controller idiom oCarousel.getPages()[i] no id-based call
  // can express (sap.m.sample.ComparisonPattern, app 012).
  test.describe("aggregation-item addressing", () => {
    function carousel(calls, controls) {
      const pages = [{ id: "p0" }, { id: "p1" }, { id: "p2" }];
      controls.car = {
        getAggregation: (name) => (name === "pages" ? pages : null),
        setActivePage: (p) => calls.push(["setActivePage", p]),
      };
      return pages;
    }

    test("resolves the Nth item of an aggregation", () => {
      const { FrontendAction, calls, controls } = load();
      const pages = carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "car",
        "",
        "setActivePage",
        "car/pages/2",
      ]);
      expect(calls).toEqual([["setActivePage", pages[2]]]);
    });

    test("index 0 is an item, not an empty argument", () => {
      const { FrontendAction, calls, controls } = load();
      const pages = carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "car",
        "",
        "setActivePage",
        "car/pages/0",
      ]);
      expect(calls).toEqual([["setActivePage", pages[0]]]);
    });

    /* castArgAuto has to map ""/" " to false - that is the ABAP boolean
     * contract - which used to leave the EMPTY STRING unspellable on the
     * unlisted-method path. UI5 does not reject a boolean for a string
     * property, it casts it, so setText("") arrived as setText(false) and
     * rendered the word "false". The declared property type settles it now. */
    function labelled(calls, controls, type) {
      controls.lbl = {
        getMetadata: () => ({ getAllProperties: () => ({ text: { type } }) }),
        setText: (v) => calls.push(["setText", v]),
        setVisible: (v) => calls.push(["setVisible", v]),
      };
    }

    test("an empty argument reaches a string property AS the empty string", () => {
      const { FrontendAction, calls, controls } = load();
      labelled(calls, controls, "string");
      FrontendAction.execute(null, ["CONTROL_BY_ID", "lbl", "", "setText", ""]);
      expect(calls).toEqual([["setText", ""]]);
    });

    test("a string property keeps 'X' and 'true' as text, not as booleans", () => {
      const { FrontendAction, calls, controls } = load();
      labelled(calls, controls, "string");
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "lbl",
        "",
        "setText",
        "X",
      ]);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "lbl",
        "",
        "setText",
        "true",
      ]);
      expect(calls).toEqual([
        ["setText", "X"],
        ["setText", "true"],
      ]);
    });

    test("the ABAP boolean contract is untouched where the property is not a string", () => {
      const { FrontendAction, calls, controls } = load();
      labelled(calls, controls, "string");
      // setVisible is not declared in the property map, so nothing overrides
      // the inference: "X" is still true and "" still false
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "lbl",
        "",
        "setVisible",
        "X",
      ]);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "lbl",
        "",
        "setVisible",
        " ",
      ]);
      expect(calls).toEqual([
        ["setVisible", true],
        ["setVisible", false],
      ]);
    });

    test("a plain id still resolves exactly as before", () => {
      // toDetail, not to: `to` takes the pageId kind now (see the
      // page-id navigation describe below), and this test is about the
      // plain-id vs "<id>/<aggregation>/<index>" resolution forms, which
      // both kinds share.
      const { FrontendAction, calls, controls } = load();
      const page2 = { id: "page2" };
      controls.page2 = page2;
      controls.SplitApp = {
        toDetail: (ctrl) => calls.push(["toDetail", ctrl]),
      };
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "SplitApp",
        "",
        "toDetail",
        "page2",
      ]);
      expect(calls).toEqual([["toDetail", page2]]);
    });

    test("an out-of-range index is reported, not silently passed as undefined", () => {
      const { FrontendAction, calls, errors, controls } = load();
      carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "car",
        "",
        "setActivePage",
        "car/pages/9",
      ]);
      expect(calls).toEqual([["setActivePage", null]]);
      expect(errors.join(" ")).toContain("3 item(s)");
    });

    test("a single-valued aggregation is refused", () => {
      const { FrontendAction, calls, errors, controls } = load();
      carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "car",
        "",
        "setActivePage",
        "car/footer/0",
      ]);
      expect(errors.join(" ")).toContain("no multiple aggregation");
    });

    test("an unknown owner control is reported", () => {
      const { FrontendAction, errors, controls } = load();
      controls.car = { setActivePage: () => {} };
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        "car",
        "",
        "setActivePage",
        "nosuch/pages/0",
      ]);
      expect(errors.join(" ")).toContain("nosuch");
    });
  });

  test("rejects a framework-hostile method (destroy is on the denylist)", () => {
    const { FrontendAction, calls, errors, controls } = load();
    controls.x = { destroy: () => calls.push(["destroy"]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "x", "", "destroy"]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(1);
  });

  test("rejects other denied methods (setModel/setParent/bindProperty/attachPress)", () => {
    const { FrontendAction, calls, errors, controls } = load();
    controls.x = {
      setModel: () => calls.push(["setModel"]),
      setParent: () => calls.push(["setParent"]),
      bindProperty: () => calls.push(["bindProperty"]),
      attachPress: () => calls.push(["attachPress"]),
    };
    for (const m of ["setModel", "setParent", "bindProperty", "attachPress"]) {
      FrontendAction.execute(null, ["CONTROL_BY_ID", "x", "", m]);
    }
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(4);
  });

  test("rejects the GENERIC reflection mutators by exact name", () => {
    const { FrontendAction, calls, errors, controls } = load();
    const generic = [
      "setAggregation",
      "addAggregation",
      "insertAggregation",
      "removeAggregation",
      "removeAllAggregation",
      "destroyAggregation",
      "setAssociation",
      "addAssociation",
      "removeAssociation",
      "removeAllAssociation",
    ];
    controls.x = {};
    for (const m of generic) controls.x[m] = () => calls.push([m]);
    for (const m of generic) {
      FrontendAction.execute(null, ["CONTROL_BY_ID", "x", "", m, "items"]);
    }
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(generic.length);
  });

  test("but the NAMED per-aggregation mutators that share their prefix are allowed", () => {
    const { FrontendAction, calls, errors, controls } = load();
    // the deny entries are "removeAllAggregation"/"destroy"/... by exact name,
    // so these keep working: they detach or destroy children the control owns,
    // the same footprint the long-allowed removeItem has (app 307's
    // Calendar.removeAllSelectedDates has no bindable alternative - the
    // control writes the user's selection into that aggregation itself).
    const named = [
      "removeAllSelectedDates",
      "removeAllItems",
      "removeAllContent",
      "destroySpecialDates",
      "destroyItems",
      "removeItem",
    ];
    controls.cal = {};
    for (const m of named) controls.cal[m] = () => calls.push([m]);
    for (const m of named) {
      FrontendAction.execute(null, ["CONTROL_BY_ID", "cal", "", m]);
    }
    expect(calls).toEqual(named.map((m) => [m]));
    expect(errors).toHaveLength(0);
  });

  test("calls an unlisted but safe public method (generalized allowlist)", () => {
    const { FrontendAction, calls, controls } = load();
    // enablePostButton is NOT in CONTROL_METHODS, but it is a public, non-denied
    // setter on a core control -> callable without whitelisting it (app 236).
    controls.feed = {
      enablePostButton: (b) => calls.push(["enablePostButton", b]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "feed",
      "",
      "enablePostButton",
      "X",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "feed",
      "",
      "enablePostButton",
      " ",
    ]);
    expect(calls).toEqual([
      ["enablePostButton", true],
      ["enablePostButton", false],
    ]);
  });

  test("infers arg types for an unlisted method (X/space->bool, else string)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.c = {
      setValueState: (...a) => calls.push(["setValueState", ...a]),
    };
    // a genuine string arg passes through; only the ABAP bool tokens convert
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "c",
      "",
      "setValueState",
      "Error",
    ]);
    expect(calls).toEqual([["setValueState", "Error"]]);
  });

  test("a listed method still wins over inference (explicit kinds)", () => {
    const { FrontendAction, calls, controls } = load();
    // setHiddenInPopin is listed as ["object"] -> arg is JSON.parsed, not left a string
    controls.t = {
      setHiddenInPopin: (a) => calls.push(["setHiddenInPopin", a]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "t",
      "",
      "setHiddenInPopin",
      '["High"]',
    ]);
    expect(calls).toEqual([["setHiddenInPopin", ["High"]]]);
  });

  test("setSticky receives its ARRAY, not the raw string", () => {
    const { FrontendAction, calls, controls } = load();
    // without the ["object"] kind the inference would hand over a string and
    // sap.m.ListBase would reject it
    controls.tab = { setSticky: (a) => calls.push(["setSticky", a]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "tab",
      "",
      "setSticky",
      '["ColumnHeaders","HeaderToolbar"]',
    ]);
    expect(calls).toEqual([["setSticky", ["ColumnHeaders", "HeaderToolbar"]]]);
  });

  test("setSelectedSection clears the association on an EMPTY argument", () => {
    const { FrontendAction, calls, controls } = load();
    const goals = { id: "goals" };
    controls.goals = goals;
    controls.opl = {
      setSelectedSection: (a) => calls.push(["setSelectedSection", a]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "opl",
      "",
      "setSelectedSection",
      "goals",
    ]);
    // empty -> null, NOT the `false` the inference path would produce
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "opl",
      "",
      "setSelectedSection",
      "",
    ]);
    expect(calls).toEqual([
      ["setSelectedSection", goals],
      ["setSelectedSection", null],
    ]);
  });

  test("setSelectedSection still clears when the wire dropped the trailing empty arg", () => {
    const { FrontendAction, calls, controls } = load();
    controls.opl = {
      setSelectedSection: (...a) => calls.push(["setSelectedSection", ...a]),
    };
    // get_t_arg drops a TRAILING empty t_arg entry, so the action arrives with
    // no argument at all - a nullable kind is padded so the call is explicit
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "opl",
      "",
      "setSelectedSection",
    ]);
    expect(calls).toEqual([["setSelectedSection", null]]);
  });

  test("css writes a whitelisted declaration onto the control's DOM node", () => {
    const { FrontendAction, controls } = load();
    const set = [];
    controls.page = {
      getDomRef: () => ({ style: { setProperty: (p, v) => set.push([p, v]) } }),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "page",
      "",
      "css",
      "width",
      "60%",
    ]);
    expect(set).toEqual([["width", "60%"]]);
  });

  test("css rejects a property outside the whitelist and a control with no DOM ref", () => {
    const { FrontendAction, controls, errors } = load();
    const set = [];
    controls.page = {
      getDomRef: () => ({ style: { setProperty: (p, v) => set.push([p, v]) } }),
    };
    controls.hidden = { getDomRef: () => null };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "page",
      "",
      "css",
      "position",
      "absolute",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "hidden",
      "",
      "css",
      "width",
      "60%",
    ]);
    expect(set).toHaveLength(0);
    expect(errors).toHaveLength(2);
  });

  test("open/close without args stay true no-arg calls (popup-mode PDFViewer, Dialog)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.pdfViewer = {
      open: (...a) => calls.push(["open", a.length]),
      close: (...a) => calls.push(["close", a.length]),
    };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "pdfViewer", "", "open"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "pdfViewer", "", "close"]);
    expect(calls).toEqual([
      ["open", 0],
      ["close", 0],
    ]);
  });

  test("open passes the optional page key through (ViewSettingsDialog)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.vsd = { open: (page) => calls.push(["open", page]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "vsd",
      "",
      "open",
      "filter",
    ]);
    expect(calls).toEqual([["open", "filter"]]);
  });

  test("to passes the optional transitionName (NavContainer animation)", () => {
    // the first argument is the RESOLVED page's id (the pageId kind - see
    // the page-id navigation describe at the end of this file); only the
    // trailing transitionName is under test here
    const { FrontendAction, calls, controls } = load();
    const page2 = { getId: () => "v1--page2" };
    controls.page2 = page2;
    controls.NavCon = { to: (...a) => calls.push(["to", ...a]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "NavCon",
      "",
      "to",
      "page2",
      "fade",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "NavCon",
      "",
      "to",
      "page2",
    ]);
    expect(calls).toEqual([
      ["to", "v1--page2", "fade"],
      ["to", "v1--page2"],
    ]);
  });

  test("goToStep resolves the step and casts the focus flag (Wizard)", () => {
    const { FrontendAction, calls, controls } = load();
    const step2 = { id: "STEP2" };
    controls.STEP2 = step2;
    controls.wiz = { goToStep: (s, b) => calls.push(["goToStep", s, b]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "wiz",
      "",
      "goToStep",
      "STEP2",
      "X",
    ]);
    expect(calls).toEqual([["goToStep", step2, true]]);
  });

  test("openBy anchors to the resolved control (not its DOM ref)", () => {
    // Every sap.m openBy accepts a control, and MessagePopover.openBy needs
    // one (it dereferences getParent()), so the anchor is the control itself.
    const { FrontendAction, calls, controls } = load();
    const anchor = { getDomRef: () => ({ tagName: "BUTTON" }) };
    controls.anchorBtn = anchor;
    controls.HiddenDP = { openBy: (ref) => calls.push(["openBy", ref]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "HiddenDP",
      "",
      "openBy",
      "anchorBtn",
    ]);
    expect(calls).toEqual([["openBy", anchor]]);
  });

  test("openBy anchors to the control even when it is not rendered yet", () => {
    const { FrontendAction, calls, controls } = load();
    const anchor = { getDomRef: () => null };
    controls.anchorBtn = anchor;
    controls.HiddenDP = { openBy: (ref) => calls.push(["openBy", ref]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "HiddenDP",
      "",
      "openBy",
      "anchorBtn",
    ]);
    expect(calls).toEqual([["openBy", anchor]]);
  });

  test("toggleBy opens the control anchored to the control when closed", () => {
    const { FrontendAction, calls, controls } = load();
    const anchor = { getDomRef: () => ({ tagName: "BUTTON" }) };
    controls.anchorBtn = anchor;
    controls.theMenu = {
      isOpen: () => false,
      openBy: (ref) => calls.push(["openBy", ref]),
      close: () => calls.push(["close"]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "theMenu",
      "",
      "toggleBy",
      "anchorBtn",
    ]);
    expect(calls).toEqual([["openBy", anchor]]);
  });

  test("toggleBy closes the control when it is already open", () => {
    const { FrontendAction, calls, controls } = load();
    controls.anchorBtn = { getDomRef: () => ({}) };
    controls.theMenu = {
      isOpen: () => true,
      openBy: (ref) => calls.push(["openBy", ref]),
      close: () => calls.push(["close"]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "theMenu",
      "",
      "toggleBy",
      "anchorBtn",
    ]);
    expect(calls).toEqual([["close"]]);
  });

  test("setActivePage resolves the page control (Carousel)", () => {
    const { FrontendAction, calls, controls } = load();
    const page2 = { id: "carPage2" };
    controls.carPage2 = page2;
    controls.carousel = {
      setActivePage: (p) => calls.push(["setActivePage", p]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "carousel",
      "",
      "setActivePage",
      "carPage2",
    ]);
    expect(calls).toEqual([["setActivePage", page2]]);
  });

  test("discardProgress/setNextStep resolve their controlId arg (wizard)", () => {
    const { FrontendAction, calls, controls } = load();
    const step2 = { id: "STEP2" };
    const step22 = { id: "STEP22" };
    controls.STEP2 = step2;
    controls.STEP22 = step22;
    controls.wiz = { discardProgress: (s) => calls.push(["discard", s]) };
    step2.setNextStep = (s) => calls.push(["next", s]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "wiz",
      "",
      "discardProgress",
      "STEP2",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "STEP2",
      "",
      "setNextStep",
      "STEP22",
    ]);
    expect(calls).toEqual([
      ["discard", step2],
      ["next", step22],
    ]);
  });

  test("setExpanded casts the ABAP bool ('X'/'')", () => {
    const { FrontendAction, calls, controls } = load();
    controls.panel = { setExpanded: (b) => calls.push(["expand", b]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "panel",
      "",
      "setExpanded",
      "X",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "panel",
      "",
      "setExpanded",
      "",
    ]);
    expect(calls).toEqual([
      ["expand", true],
      ["expand", false],
    ]);
  });

  test("add/remove/toggleStyleClass pass the class name through", () => {
    const { FrontendAction, calls, controls } = load();
    controls.dlg = {
      addStyleClass: (c) => calls.push(["add", c]),
      removeStyleClass: (c) => calls.push(["remove", c]),
      toggleStyleClass: (c) => calls.push(["toggle", c]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "dlg",
      "",
      "addStyleClass",
      "myClass",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "dlg",
      "",
      "removeStyleClass",
      "myClass",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "dlg",
      "",
      "toggleStyleClass",
      "myClass",
    ]);
    expect(calls).toEqual([
      ["add", "myClass"],
      ["remove", "myClass"],
      ["toggle", "myClass"],
    ]);
  });

  test("toDetail/toMaster resolve their page control (SplitApp/SplitContainer)", () => {
    const { FrontendAction, calls, controls } = load();
    const detail = { id: "detailDetail" };
    const master = { id: "master2" };
    controls.detailDetail = detail;
    controls.master2 = master;
    controls.split = {
      toDetail: (p) => calls.push(["toDetail", p]),
      toMaster: (p) => calls.push(["toMaster", p]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "split",
      "",
      "toDetail",
      "detailDetail",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "split",
      "",
      "toMaster",
      "master2",
    ]);
    expect(calls).toEqual([
      ["toDetail", detail],
      ["toMaster", master],
    ]);
  });

  test("backDetail/backMaster stay no-arg calls (SplitApp/SplitContainer)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.split = {
      backDetail: (...a) => calls.push(["backDetail", a.length]),
      backMaster: (...a) => calls.push(["backMaster", a.length]),
    };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "split", "", "backDetail"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "split", "", "backMaster"]);
    expect(calls).toEqual([
      ["backDetail", 0],
      ["backMaster", 0],
    ]);
  });

  test("setMode passes the SplitAppMode string through", () => {
    const { FrontendAction, calls, controls } = load();
    controls.split = { setMode: (m) => calls.push(["setMode", m]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "split",
      "",
      "setMode",
      "StretchCompressMode",
    ]);
    expect(calls).toEqual([["setMode", "StretchCompressMode"]]);
  });

  test("navigateBack stays a no-arg call (QuickView/QuickViewCard)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.qv = {
      navigateBack: (...a) => calls.push(["navigateBack", a.length]),
    };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "qv", "", "navigateBack"]);
    expect(calls).toEqual([["navigateBack", 0]]);
  });
});

test.describe("BINDING_CALL", () => {
  function withListBinding(controls, calls) {
    const binding = {
      filter: (f) => calls.push(["filter", f]),
      sort: (s) => calls.push(["sort", s]),
    };
    controls.idList = {
      getBinding: (agg) => (agg === "items" ? binding : null),
    };
    return binding;
  }

  test("filter builds a Filter from path/operator/value", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "NAME",
      "Contains",
      "Pro",
    ]);
    expect(calls).toHaveLength(1);
    const [name, filters] = calls[0];
    expect(name).toBe("filter");
    expect(filters).toHaveLength(1);
    expect(filters[0]).toMatchObject({
      path: "NAME",
      operator: "Contains",
      value1: "Pro",
    });
  });

  test("no filter values clears the filter (emptied search field)", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    // the backend arg serializer trims trailing empties, so the cleared-query
    // call arrives without the value argument at all
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "NAME",
      "Contains",
    ]);
    expect(calls).toEqual([["filter", []]]);
  });

  test("a one-sided BT range (empty value1, set value2) is NOT cleared", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    // empty value1 arrives as an '' placeholder because value2 follows it
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "PRICE",
      "BT",
      "",
      "100",
    ]);
    expect(calls).toHaveLength(1);
    const [name, filters] = calls[0];
    expect(name).toBe("filter");
    expect(filters[0]).toMatchObject({
      path: "PRICE",
      operator: "BT",
      value1: "",
      value2: "100",
    });
  });

  test("rejects a non-whitelisted operator or method", () => {
    const { FrontendAction, calls, errors, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "NAME",
      "Any",
      "x",
    ]);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "refresh",
    ]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(2);
  });

  test("sort builds a Sorter and casts the ABAP bools", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "sort",
      "NAME",
      "X",
    ]);
    expect(calls).toHaveLength(1);
    const [name, sorters] = calls[0];
    expect(name).toBe("sort");
    expect(sorters[0]).toMatchObject({
      path: "NAME",
      descending: true,
      group: false,
    });
  });

  test("compound groups JSON builds AND-of-ORs (FacetFilter shape)", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    const json = JSON.stringify([
      [
        ["CATEGORY", "EQ", "Accessories"],
        ["CATEGORY", "EQ", "Laptops"],
      ],
      [["SUPPLIER_NAME", "EQ", "Technocom"]],
    ]);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      json,
    ]);
    expect(calls).toHaveLength(1);
    const [name, filters] = calls[0];
    expect(name).toBe("filter");
    expect(filters).toHaveLength(1);
    const root = filters[0]; // mock Filter stores (aFilters, bAnd) as (path, operator)
    expect(root.operator).toBe(true); // AND across groups
    expect(root.path).toHaveLength(2);
    expect(root.path[0].operator).toBe(false); // OR inside the group
    expect(root.path[0].path).toHaveLength(2);
    expect(root.path[0].path[0]).toMatchObject({
      path: "CATEGORY",
      operator: "EQ",
      value1: "Accessories",
    });
    expect(root.path[1].path[0]).toMatchObject({
      path: "SUPPLIER_NAME",
      operator: "EQ",
      value1: "Technocom",
    });
  });

  test("empty compound groups clear the filter; empty inner groups are skipped", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "[]",
    ]);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "[[],[]]",
    ]);
    expect(calls).toEqual([
      ["filter", []],
      ["filter", []],
    ]);
  });

  test("compound groups reject bad operators and malformed JSON", () => {
    const { FrontendAction, calls, errors, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      JSON.stringify([[["NAME", "DROP TABLE", "x"]]]),
    ]);
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "idList",
      "items",
      "filter",
      "[not json",
    ]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(2);
  });

  test("logs when the control or binding is missing", () => {
    const { FrontendAction, calls, errors } = load();
    FrontendAction.execute(null, [
      "BINDING_CALL",
      "nope",
      "items",
      "filter",
      "NAME",
      "Contains",
      "x",
    ]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(1);
  });
});

test.describe("BIND_ELEMENT", () => {
  test("element-binds the slot view to <path>/<index>", () => {
    const { FrontendAction, views } = load();
    const bound = [];
    views.POPOVER = { bindElement: (p) => bound.push(p) };
    FrontendAction.execute(null, [
      "BIND_ELEMENT",
      "POPOVER",
      "5",
      "/T_PRODUCTS",
    ]);
    expect(bound).toEqual(["/T_PRODUCTS/5"]);
  });

  test("strips braces from the binding path (client->_bind form)", () => {
    const { FrontendAction, views } = load();
    const bound = [];
    views.POPOVER = { bindElement: (p) => bound.push(p) };
    FrontendAction.execute(null, ["BIND_ELEMENT", "POPOVER", "2", "{/MT_TAB}"]);
    expect(bound).toEqual(["/MT_TAB/2"]);
  });

  test("logs and no-ops when the slot view is missing", () => {
    const { FrontendAction, errors } = load();
    FrontendAction.execute(null, [
      "BIND_ELEMENT",
      "POPOVER",
      "5",
      "/T_PRODUCTS",
    ]);
    expect(errors.some((e) => String(e).includes("no view for slot"))).toBe(
      true,
    );
  });
});

test.describe("SMART_VARIANT_INIT (sap.ui.comp variant management)", () => {
  // A SmartVariantManagement stub: records initialise() calls, reports the
  // controls that registered so far and their wrappers' initialised state.
  function svm(registeredIds, initialisedIds = []) {
    const initialised = [];
    return {
      _oPersoControl: null,
      initialised,
      // sap.ui.comp's own setter: anchors the control AND creates the control
      // promise initialise() checks - a page variant never gets this call
      setPersControler(control) {
        this._oPersoControl = control;
        this._oControlPromise = {};
      },
      getPersonalizableControls: () =>
        registeredIds.map((id) => ({ getControl: () => id })),
      _getControlWrapper: (control) =>
        registeredIds.includes(control?.id)
          ? { bInitialized: initialisedIds.includes(control.id) }
          : null,
      initialise: (fn, control) => initialised.push(control),
    };
  }

  test("anchors the perso control the app named", () => {
    const { FrontendAction, controls } = load();
    const oSVM = svm(["smartFilterBar"]);
    controls.pageVariantId = oSVM;
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(oSVM._oPersoControl).toEqual({ id: "smartFilterBar" });
    // the setter, not the field: it also creates the control promise
    expect(oSVM._oControlPromise).toBeTruthy();
  });

  test("falls back to the field when the runtime has no setter", () => {
    const { FrontendAction, controls } = load();
    const oSVM = svm(["smartFilterBar"]);
    delete oSVM.setPersControler;
    controls.pageVariantId = oSVM;
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(oSVM._oPersoControl).toEqual({ id: "smartFilterBar" });
  });

  test("initialises a registered control that nobody initialised yet", () => {
    const { FrontendAction, controls } = load();
    const oSVM = svm(["smartFilterBar"]);
    controls.pageVariantId = oSVM;
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(oSVM.initialised).toEqual([{ id: "smartFilterBar" }]);
  });

  test("does not re-initialise a control that already ran", () => {
    const { FrontendAction, controls } = load();
    // wrapper already initialised: sap.ui.comp answers a second call with
    // "initialise on ... already executed" - the anchor is all that is left to do
    const oSVM = svm(["smartFilterBar"], ["smartFilterBar"]);
    controls.pageVariantId = oSVM;
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(oSVM.initialised).toEqual([]);
    expect(oSVM._oPersoControl).toEqual({ id: "smartFilterBar" });
  });

  test("anchors before the control has registered, initialises after", async () => {
    const { FrontendAction, controls } = load();
    // nothing registered yet - the anchor still has to be placed, because the
    // control's own initialise() aborts without it and marks itself as done
    const registered = [];
    const oSVM = svm(registered);
    controls.pageVariantId = oSVM;
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(oSVM._oPersoControl).toEqual({ id: "smartFilterBar" });
    expect(oSVM.initialised).toEqual([]);
    // the control registers a moment later (its metadata arrived) - the
    // pending wait picks that up and starts the load flow nobody else would
    registered.push("smartFilterBar");
    await new Promise((r) => setTimeout(r, 250));
    expect(oSVM.initialised).toEqual([{ id: "smartFilterBar" }]);
  });

  test("leaves a perso control the runtime set itself untouched", () => {
    const { FrontendAction, controls } = load();
    const oSVM = svm(["smartFilterBar"]);
    const own = { id: "set-by-runtime" };
    oSVM._oPersoControl = own;
    controls.pageVariantId = oSVM;
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(oSVM._oPersoControl).toBe(own);
  });

  test("falls back to the first registered control when none is named", () => {
    const { FrontendAction, controls } = load();
    const oSVM = svm(["smartTable"]);
    controls.pageVariantId = oSVM;
    controls.smartTable = { id: "smartTable" };
    FrontendAction.execute(null, ["SMART_VARIANT_INIT", "pageVariantId"]);
    expect(oSVM._oPersoControl).toEqual({ id: "smartTable" });
  });

  test("logs an error when the id is not a SmartVariantManagement", () => {
    const { FrontendAction, controls, errors } = load();
    controls.pageVariantId = { id: "not-a-variant-control" };
    controls.smartFilterBar = { id: "smartFilterBar" };
    FrontendAction.execute(null, [
      "SMART_VARIANT_INIT",
      "pageVariantId",
      "smartFilterBar",
    ]);
    expect(errors.length).toBe(1);
    expect(errors[0]).toContain("no SmartVariantManagement");
  });
});

test.describe("FILTER_BAR_VARIANT_INIT (classic FilterBar + variant management)", () => {
  const MODULE = "sap/ui/comp/smartvariants/PersonalizableInfo";

  function PersonalizableInfo(settings) {
    Object.assign(this, settings);
  }

  // one filter field: the FilterGroupItem and the input it wraps
  function field(name, value) {
    let changeHandler = null;
    const control = {
      getValue: () => value,
      setValue: (v) => (value = v),
      attachChange: (fn) => (changeHandler = fn),
      fireChange: (oEvent) => changeHandler && changeHandler(oEvent),
    };
    return {
      getName: () => name,
      getGroupName: () => "group1",
      getControl: () => control,
      control,
    };
  }

  function filterBar(fields) {
    return {
      registered: {},
      fired: [],
      getAllFilterItems: () => fields,
      getFilterGroupItems: () => fields,
      determineControlByName: (fieldName) =>
        fields.find((f) => f.getName() === fieldName)?.getControl() || null,
      registerFetchData(fn) {
        this.registered.fetch = fn;
      },
      registerApplyData(fn) {
        this.registered.apply = fn;
      },
      registerGetFiltersWithValues(fn) {
        this.registered.withValues = fn;
      },
      fireFilterChange(oEvent) {
        this.fired.push(oEvent);
      },
    };
  }

  function svm() {
    return {
      _oPersoControl: null,
      added: [],
      modified: [],
      initialised: [],
      addPersonalizableControl(info) {
        this.added.push(info);
      },
      setPersControler(control) {
        this._oPersoControl = control;
      },
      currentVariantSetModified(flag) {
        this.modified.push(flag);
      },
      _getControlWrapper: () => ({ bInitialized: false }),
      initialise(fn, control) {
        this.initialised.push(control);
        fn();
      },
    };
  }

  // wires a SmartVariantManagement and a FilterBar with PersonalizableInfo
  // already loaded (the synchronous sap.ui.require path)
  function wire(fields) {
    const ctxLoad = load();
    ctxLoad.ctx.sap.ui.require = (name) =>
      name === MODULE ? PersonalizableInfo : null;
    const oSVM = svm();
    const oFilterBar = filterBar(fields);
    ctxLoad.controls.svm = oSVM;
    ctxLoad.controls.fbar = oFilterBar;
    ctxLoad.FrontendAction.execute(null, [
      "FILTER_BAR_VARIANT_INIT",
      "svm",
      "fbar",
    ]);
    return { ...ctxLoad, oSVM, oFilterBar };
  }

  test("adds the PersonalizableInfo the variant management needs", () => {
    const { oSVM, oFilterBar } = wire([field("PRODUCT", "table")]);
    expect(oSVM.added.length).toBe(1);
    expect(oSVM.added[0]).toMatchObject({
      type: "filterBar",
      keyName: "persistencyKey",
      control: oFilterBar,
    });
    // and anchors the bar, so saving a variant reaches sap.ui.fl
    expect(oSVM._oPersoControl).toBe(oFilterBar);
    expect(oSVM.initialised).toEqual([oFilterBar]);
    // the load flow's callback drops the "*" the restored values would leave
    expect(oSVM.modified).toEqual([false]);
  });

  test("fetchData collects group, field and value of every filter", () => {
    const { oFilterBar } = wire([
      field("PRODUCT", "table"),
      field("QUANTITY", ""),
    ]);
    expect(oFilterBar.registered.fetch()).toEqual([
      { groupName: "group1", fieldName: "PRODUCT", fieldData: "table" },
      { groupName: "group1", fieldName: "QUANTITY", fieldData: "" },
    ]);
  });

  test("applyData writes a stored variant back into the filter controls", () => {
    const fields = [field("PRODUCT", ""), field("QUANTITY", "")];
    const { oFilterBar } = wire(fields);
    oFilterBar.registered.apply([
      { groupName: "group1", fieldName: "PRODUCT", fieldData: "chair" },
      { groupName: "group1", fieldName: "QUANTITY", fieldData: "123" },
    ]);
    expect(fields.map((f) => f.getControl().getValue())).toEqual([
      "chair",
      "123",
    ]);
  });

  test("getFiltersWithValues reports only the filled filters", () => {
    const fields = [field("PRODUCT", "table"), field("QUANTITY", "")];
    const { oFilterBar } = wire(fields);
    expect(oFilterBar.registered.withValues()).toEqual([fields[0]]);
  });

  test("a filter change marks the variant modified and refreshes the bar", () => {
    const fields = [field("PRODUCT", "table")];
    const { oSVM, oFilterBar } = wire(fields);
    const oEvent = { id: "change" };
    fields[0].control.fireChange(oEvent);
    expect(oSVM.modified).toEqual([false, true]);
    expect(oFilterBar.fired).toEqual([oEvent]);
  });

  test("does not wire the same bar a second time", () => {
    const { FrontendAction, oSVM } = wire([field("PRODUCT", "table")]);
    FrontendAction.execute(null, ["FILTER_BAR_VARIANT_INIT", "svm", "fbar"]);
    expect(oSVM.added.length).toBe(1);
  });

  test("waits for sap.ui.comp when PersonalizableInfo is not loaded yet", () => {
    const { FrontendAction, controls, ctx } = load();
    let pending = null;
    ctx.sap.ui.require = (name, callback) => {
      if (Array.isArray(name)) {
        pending = callback;
        return undefined;
      }
      return null;
    };
    const oSVM = svm();
    const oFilterBar = filterBar([field("PRODUCT", "table")]);
    controls.svm = oSVM;
    controls.fbar = oFilterBar;
    FrontendAction.execute(null, ["FILTER_BAR_VARIANT_INIT", "svm", "fbar"]);
    // the callbacks are in place immediately, only the variant control waits
    expect(typeof oFilterBar.registered.fetch).toBe("function");
    expect(oSVM.added.length).toBe(0);
    pending(PersonalizableInfo);
    expect(oSVM.added.length).toBe(1);
  });

  test("logs when the named control is not a FilterBar", () => {
    const { FrontendAction, controls, errors } = load();
    controls.svm = svm();
    controls.fbar = { id: "not-a-filter-bar" };
    FrontendAction.execute(null, ["FILTER_BAR_VARIANT_INIT", "svm", "fbar"]);
    expect(errors.length).toBe(1);
    expect(errors[0]).toContain("no FilterBar");
  });

  test("logs when the named id is not a SmartVariantManagement", () => {
    const { FrontendAction, controls, errors } = load();
    controls.svm = { id: "not-a-variant-control" };
    controls.fbar = filterBar([field("PRODUCT", "table")]);
    FrontendAction.execute(null, ["FILTER_BAR_VARIANT_INIT", "svm", "fbar"]);
    expect(errors.length).toBe(1);
    expect(errors[0]).toContain("no SmartVariantManagement");
  });
});

test.describe("CONTROL_BY_ID setAsyncURLHandler (MessagePopover URL policy)", () => {
  // the control takes a live callback, so the wire carries a POLICY NAME and
  // the client installs the matching built-in validator
  function popover() {
    let handler = null;
    return {
      setAsyncURLHandler: (fn) => (handler = fn),
      ask: (url) => {
        let result = null;
        handler({ url, id: "msg1", promise: { resolve: (r) => (result = r) } });
        return result;
      },
    };
  }

  test("RELATIVE_ONLY allows in-app links and blocks absolute ones", () => {
    const { FrontendAction, controls } = load();
    const oPopover = popover();
    controls.messagePopover = oPopover;
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "messagePopover",
      "",
      "setAsyncURLHandler",
      "RELATIVE_ONLY",
    ]);
    expect(oPopover.ask("#/details")).toEqual({ allowed: true, id: "msg1" });
    expect(oPopover.ask("/sap/opu/x")).toEqual({ allowed: true, id: "msg1" });
    expect(oPopover.ask("http://example.com")).toEqual({
      allowed: false,
      id: "msg1",
    });
    expect(oPopover.ask("//example.com")).toEqual({
      allowed: false,
      id: "msg1",
    });
    expect(oPopover.ask("mailto:a@b.c")).toEqual({
      allowed: false,
      id: "msg1",
    });
  });

  test("ALLOW_ALL and DENY_ALL are unconditional", () => {
    const { FrontendAction, controls } = load();
    const oAll = popover();
    const oNone = popover();
    controls.allPopover = oAll;
    controls.nonePopover = oNone;
    const call = (id, policy) =>
      FrontendAction.execute(null, [
        "CONTROL_BY_ID",
        id,
        "",
        "setAsyncURLHandler",
        policy,
      ]);
    call("allPopover", "ALLOW_ALL");
    call("nonePopover", "DENY_ALL");
    expect(oAll.ask("http://example.com").allowed).toBe(true);
    expect(oNone.ask("#/details").allowed).toBe(false);
  });

  test("rejects an unknown policy and leaves the control untouched", () => {
    const { FrontendAction, controls, errors } = load();
    let installed = false;
    controls.messagePopover = {
      setAsyncURLHandler: () => (installed = true),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "messagePopover",
      "",
      "setAsyncURLHandler",
      "TRUST_EVERYTHING",
    ]);
    expect(installed).toBe(false);
    expect(errors[0]).toContain("unknown URL policy");
  });

  test("logs an error when the control has no setAsyncURLHandler", () => {
    const { FrontendAction, controls, errors } = load();
    controls.notAPopover = {};
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "notAPopover",
      "",
      "setAsyncURLHandler",
      "ALLOW_ALL",
    ]);
    expect(errors[0]).toContain("not callable");
  });
});

test.describe("KEYBOARD_SHORTCUT (key combination -> backend event)", () => {
  // a minimal document that records the keydown listener the action installs
  function docStub() {
    const listeners = [];
    return {
      document: {
        addEventListener: (type, fn) => {
          if (type === "keydown") listeners.push(fn);
        },
      },
      press: (key, mods = {}) => {
        let prevented = false;
        const oEvent = {
          key,
          ctrlKey: false,
          shiftKey: false,
          altKey: false,
          metaKey: false,
          ...mods,
          preventDefault: () => (prevented = true),
        };
        for (const fn of listeners) fn(oEvent);
        return prevented;
      },
      count: () => listeners.length,
    };
  }

  function loadWithDoc() {
    const doc = docStub();
    const ctx = load({ sandbox: { document: doc.document } });
    const fired = [];
    const oController = { eB: (args) => fired.push(args) };
    return { ...ctx, doc, fired, oController };
  }

  // A shortcut scoped to a view slot shadows the unscoped one while that slot
  // is OPEN - the abap2UI5 equivalent of a UI5 CommandExecution sitting in a
  // Popover's dependents, which shadows the page-level one for the same
  // command (sap.ui.core.sample.Commands). `views` is ViewSlots' open-slot
  // map: a key present there means the slot is showing.
  test.describe("scope", () => {
    test("the scoped registration wins while its slot is open", () => {
      const { FrontendAction, doc, fired, views, oController } = loadWithDoc();
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE_POPOVER",
        "POPOVER",
      ]);

      // popover closed -> the page-level command
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);

      // popover open -> its own command shadows it
      views.POPOVER = {};
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"], ["SAVE_POPOVER"]]);

      // and back again when it closes
      delete views.POPOVER;
      doc.press("s", { ctrlKey: true });
      expect(fired).toEqual([["SAVE"], ["SAVE_POPOVER"], ["SAVE"]]);
    });

    test("the innermost open slot wins", () => {
      const { FrontendAction, doc, fired, views, oController } = loadWithDoc();
      for (const [event, scope] of [
        ["SAVE", ""],
        ["SAVE_NEST", "NEST"],
        ["SAVE_POPOVER", "POPOVER"],
      ]) {
        FrontendAction.execute(
          oController,
          ["KEYBOARD_SHORTCUT", "Ctrl+S", event, scope].filter(
            (a, i) => i < 3 || a,
          ),
        );
      }
      views.NEST = {};
      views.POPOVER = {};
      doc.press("s", { ctrlKey: true });
      expect(fired).toEqual([["SAVE_POPOVER"]]);
    });

    test("a scoped registration with no open slot falls back to the unscoped one", () => {
      const { FrontendAction, doc, fired, oController } = loadWithDoc();
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE_POPUP",
        "POPUP",
      ]);
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);
    });

    test("unregistering one scope leaves the other alone", () => {
      const { FrontendAction, doc, fired, views, oController } = loadWithDoc();
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE_POPOVER",
        "POPOVER",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "",
        "POPOVER",
      ]);
      views.POPOVER = {};
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);
    });

    test("removing the last scope stops swallowing the browser default", () => {
      const { FrontendAction, doc, fired, oController } = loadWithDoc();
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", ""]);
      // Ctrl+S must save the PAGE again, not silently do nothing
      expect(doc.press("s", { ctrlKey: true })).toBe(false);
      expect(fired).toEqual([]);
    });

    // The shape the demo kit's Commands sample actually uses: the Popover is a
    // CONTROL declared in the view's dependents and opened with openBy, so it
    // never enters a framework slot. A control id is therefore a scope too,
    // active while that control is open.
    test("a control-id scope wins while that control is open", () => {
      const { FrontendAction, doc, fired, controls, oController } =
        loadWithDoc();
      let open = false;
      controls.popoverCommand = { isOpen: () => open };
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "PSAVE",
        "popoverCommand",
      ]);

      doc.press("s", { ctrlKey: true }); // closed -> the page command
      open = true;
      doc.press("s", { ctrlKey: true }); // open -> the popover's own
      open = false;
      doc.press("s", { ctrlKey: true }); // closed again
      expect(fired).toEqual([["SAVE"], ["PSAVE"], ["SAVE"]]);
    });

    test("a control scope beats a slot scope - it is the more specific statement", () => {
      const { FrontendAction, doc, fired, controls, views, oController } =
        loadWithDoc();
      controls.dlg = { isOpen: () => true };
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SLOT",
        "POPOVER",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "CTRL",
        "dlg",
      ]);
      views.POPOVER = {};
      doc.press("s", { ctrlKey: true });
      expect(fired).toEqual([["CTRL"]]);
    });

    test("a control scope whose control is gone falls back to the unscoped one", () => {
      const { FrontendAction, doc, fired, oController } = loadWithDoc();
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "SAVE",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT",
        "Ctrl+S",
        "PSAVE",
        "nosuchcontrol",
      ]);
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);
    });
  });

  test("fires the registered event and swallows the browser default", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, [
      "KEYBOARD_SHORTCUT",
      "Ctrl+S",
      "SAVE",
    ]);
    expect(doc.press("s", { ctrlKey: true })).toBe(true);
    expect(fired).toEqual([["SAVE"]]);
  });

  test("ignores a combination that was not registered", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, [
      "KEYBOARD_SHORTCUT",
      "Ctrl+S",
      "SAVE",
    ]);
    expect(doc.press("s")).toBe(false);
    expect(doc.press("d", { ctrlKey: true })).toBe(false);
    expect(doc.press("s", { ctrlKey: true, shiftKey: true })).toBe(false);
    expect(fired).toEqual([]);
  });

  test("normalizes modifier order, case and aliases", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, [
      "KEYBOARD_SHORTCUT",
      "shift + CONTROL + D",
      "DELETE",
    ]);
    expect(doc.press("d", { ctrlKey: true, shiftKey: true })).toBe(true);
    expect(fired).toEqual([["DELETE"]]);
  });

  test("binds a function key without modifiers", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "F2", "EDIT"]);
    expect(doc.press("F2")).toBe(true);
    expect(fired).toEqual([["EDIT"]]);
  });

  test("re-registering rebinds, an empty event name removes", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, [
      "KEYBOARD_SHORTCUT",
      "Ctrl+S",
      "SAVE",
    ]);
    FrontendAction.execute(oController, [
      "KEYBOARD_SHORTCUT",
      "Ctrl+S",
      "SAVE_AS",
    ]);
    expect(doc.press("s", { ctrlKey: true })).toBe(true);
    expect(fired).toEqual([["SAVE_AS"]]);
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", ""]);
    expect(doc.press("s", { ctrlKey: true })).toBe(false);
    expect(fired).toEqual([["SAVE_AS"]]);
    // one listener for any number of registrations
    expect(doc.count()).toBe(1);
  });

  test("a bare modifier press is no shortcut", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, [
      "KEYBOARD_SHORTCUT",
      "Ctrl+S",
      "SAVE",
    ]);
    expect(doc.press("Control", { ctrlKey: true })).toBe(false);
    expect(fired).toEqual([]);
  });

  test("rejects a combination that names no key", () => {
    const { FrontendAction, errors, oController } = loadWithDoc();
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+", "SAVE"]);
    expect(errors[0]).toContain("names no key");
  });
});

test.describe("START_TIMER (backend timer liveness)", () => {
  test("the fired timer dispatches only while the app is alive", () => {
    // deterministic timers: capture the callback instead of waiting it out
    const timers = [];
    const { FrontendAction, AppState } = load({
      sandbox: {
        setTimeout: (fn, ms) => {
          timers.push({ fn, ms });
          return timers.length;
        },
        clearTimeout: () => {},
      },
    });
    AppState.state.timers = {};
    const ebCalls = [];
    let destroyed = false;
    const oController = {
      isDestroyed: () => destroyed,
      eB: (a) => ebCalls.push(a),
    };

    FrontendAction.execute(oController, ["START_TIMER", "POLL", "1000"]);
    expect(timers[0].ms).toBe(1000);
    timers[0].fn();
    // alive: fired as a background event (ignore-busy flag set), slot freed
    expect(ebCalls).toEqual([["POLL", false, true]]);
    expect(AppState.state.timers).toEqual({});

    // re-armed, then the app is torn down (FLP close / re-launch): the
    // pending timer must not fire the old app's event into the new session
    FrontendAction.execute(oController, ["START_TIMER", "POLL", "1000"]);
    destroyed = true;
    timers[1].fn();
    expect(ebCalls).toHaveLength(1);
    expect(AppState.state.timers).toEqual({});
  });
});

test.describe("SET_FOCUS (focus + caret via follow-up action)", () => {
  // Minimal focus fixture: a control whose DOM accepts focus only while
  // `focusable` is true - the disabled-input case of a view_model_update that
  // re-enables a field in the same roundtrip (the control reports the new
  // state, the DOM still carries the old disabled rendering).
  function focusFixture({ focusable }) {
    const body = {};
    const doc = { body, activeElement: body };
    const inner = {};
    const applied = [];
    const delegates = [];
    let isFocusable = focusable;
    const control = {
      getDomRef: () => ({ contains: (el) => el === inner }),
      getFocusInfo: () => ({}),
      applyFocusInfo: (info) => {
        applied.push(info);
        if (isFocusable) doc.activeElement = inner;
      },
      addEventDelegate: (d) => delegates.push(d),
      removeEventDelegate: (d) => {
        const i = delegates.indexOf(d);
        if (i >= 0) delegates.splice(i, 1);
      },
    };
    return {
      doc,
      control,
      applied,
      delegates,
      inner,
      enable: () => {
        isFocusable = true;
      },
    };
  }

  function loadWithFocus(fixture) {
    const loaded = load({ sandbox: { document: fixture.doc } });
    loaded.controls.inp = fixture.control;
    return loaded;
  }

  test("applies focus + selection immediately when the DOM accepts it", () => {
    const fx = focusFixture({ focusable: true });
    const { FrontendAction } = loadWithFocus(fx);
    FrontendAction.execute(null, ["SET_FOCUS", "inp", "0", "4"]);
    expect(fx.applied).toEqual([{ selectionStart: 0, selectionEnd: 4 }]);
    expect(fx.doc.activeElement).toBe(fx.inner);
    // the focus stuck, so no retry delegate may linger on the control
    expect(fx.delegates).toEqual([]);
  });

  const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

  test("re-applies after the pending re-render when the DOM refused the focus", async () => {
    const fx = focusFixture({ focusable: false });
    const { FrontendAction } = loadWithFocus(fx);
    FrontendAction.execute(null, ["SET_FOCUS", "inp", "0", "4"]);
    // first attempt hit the still-disabled DOM: focus did not move, so a
    // one-shot retry waits for the control's re-render
    expect(fx.applied).toHaveLength(1);
    expect(fx.doc.activeElement).toBe(fx.doc.body);
    expect(fx.delegates).toHaveLength(1);
    // UI5 re-renders the control with the new enabled state
    fx.enable();
    fx.delegates[0].onAfterRendering();
    // the delegate is one-shot and the retry waits out the rendering task
    expect(fx.delegates).toEqual([]);
    expect(fx.applied).toHaveLength(1);
    await tick();
    expect(fx.applied).toHaveLength(2);
    expect(fx.applied[1]).toEqual({ selectionStart: 0, selectionEnd: 4 });
    expect(fx.doc.activeElement).toBe(fx.inner);
  });

  test("wins over UI5's own focus restore of a re-rendered trigger button", async () => {
    // The press that triggered the roundtrip left the focus on the button;
    // the re-render also rebuilt the button, so AFTER the retry delegate ran
    // UI5's FocusHandler put the focus back on the button's NEW DOM node.
    const fx = focusFixture({ focusable: false });
    const { FrontendAction } = loadWithFocus(fx);
    fx.doc.activeElement = { id: "btnUnlock" };
    FrontendAction.execute(null, ["SET_FOCUS", "inp", "0", "4"]);
    expect(fx.delegates).toHaveLength(1);
    fx.enable();
    fx.delegates[0].onAfterRendering();
    // UI5 focus restore, after all onAfterRendering delegates: same control,
    // new DOM node
    fx.doc.activeElement = { id: "btnUnlock" };
    await tick();
    // the deferred retry still moves the focus into the input
    expect(fx.applied).toHaveLength(2);
    expect(fx.doc.activeElement).toBe(fx.inner);
  });

  test("does not steal a focus the user moved elsewhere in between", async () => {
    const fx = focusFixture({ focusable: false });
    const { FrontendAction } = loadWithFocus(fx);
    FrontendAction.execute(null, ["SET_FOCUS", "inp", "0", "4"]);
    expect(fx.delegates).toHaveLength(1);
    // the user focused another field before the re-render fired
    const otherField = { id: "otherField" };
    fx.doc.activeElement = otherField;
    fx.enable();
    fx.delegates[0].onAfterRendering();
    await tick();
    expect(fx.applied).toHaveLength(1);
    expect(fx.doc.activeElement).toBe(otherField);
    expect(fx.delegates).toEqual([]);
  });
});

test.describe("SET_FAVICON (browser tab icon)", () => {
  // Minimal <head> stub: enough to see whether the handler reuses an existing
  // icon link or appends one, which is the whole behavior worth pinning down.
  function docStub(existingRel) {
    const head = [];
    if (existingRel !== undefined) head.push({ rel: existingRel, href: "old" });
    return {
      head,
      document: {
        head: {
          querySelector: (selector) => {
            // only the one selector the handler uses
            if (selector !== 'link[rel~="icon"]') return null;
            return (
              head.find((el) => String(el.rel).split(/\s+/).includes("icon")) ||
              null
            );
          },
          appendChild: (el) => head.push(el),
        },
        createElement: () => ({ rel: "", href: "" }),
      },
    };
  }

  function loadWithDoc(existingRel) {
    const doc = docStub(existingRel);
    return { ...load({ sandbox: { document: doc.document } }), doc };
  }

  test("appends an icon link when the page has none", () => {
    const { FrontendAction, doc } = loadWithDoc();
    FrontendAction.execute(null, ["SET_FAVICON", "/icon.png"]);
    expect(doc.head).toEqual([{ rel: "icon", href: "/icon.png" }]);
  });

  test("reuses the existing link instead of appending a second one", () => {
    const { FrontendAction, doc } = loadWithDoc("icon");
    FrontendAction.execute(null, ["SET_FAVICON", "/new.png"]);
    expect(doc.head).toEqual([{ rel: "icon", href: "/new.png" }]);
  });

  test("also finds the legacy rel='shortcut icon'", () => {
    const { FrontendAction, doc } = loadWithDoc("shortcut icon");
    FrontendAction.execute(null, ["SET_FAVICON", "/new.png"]);
    expect(doc.head).toEqual([{ rel: "shortcut icon", href: "/new.png" }]);
  });

  test("a missing argument is refused - the existing link keeps its href", () => {
    const { FrontendAction, doc, errors } = loadWithDoc("icon");
    FrontendAction.execute(null, ["SET_FAVICON"]);
    // the URL validator treats an empty value as unsafe, so nothing is
    // touched (and in particular the string "undefined" is never written)
    expect(doc.head).toEqual([{ rel: "icon", href: "old" }]);
    expect(errors[0]).toContain("SET_FAVICON");
  });

  test("a javascript: URL is refused and logged", () => {
    const { FrontendAction, doc, errors } = loadWithDoc("icon");

    FrontendAction.execute(null, ["SET_FAVICON", "javascript:alert(1)"]);
    expect(doc.head).toEqual([{ rel: "icon", href: "old" }]);
    expect(errors[0]).toContain("refused unsafe URL");
  });

  test("reports a failing DOM instead of throwing", () => {
    const { FrontendAction, errors } = load({
      sandbox: {
        document: {
          head: {
            querySelector: () => {
              throw new Error("no head");
            },
          },
        },
      },
    });
    FrontendAction.execute(null, ["SET_FAVICON", "/icon.png"]);
    expect(errors[0]).toContain("SET_FAVICON");
  });
});

// ---------------------------------------------------------------------
// `to` and the pageId argument kind.
//
// The three containers that own a `to( )` disagree about its first
// argument. sap.m.NavContainer normalises a Control to its id
// (NavContainer.js:782), but sap.f.FlexibleColumnLayout.to
// (FlexibleColumnLayout.js:2873) and sap.m.SplitContainer.to probe their
// columns with getPage( sPageId ), which compares `aPages[i].getId() ==
// pageId` (NavContainer.js:485). A Control never equals an id string, so
// every probe missed and the trailing `else` navigated the LAST column.
// The stubs below are those three lines, so the spec fails the same way
// the real controls did if the kind ever goes back to `controlId`.
// ---------------------------------------------------------------------
function pageStub(sId) {
  return { getId: () => sId, name: sId };
}

function navContainerStub(aPages, aLog, sName) {
  const oStub = {
    getPages: () => aPages,
    // NavContainer.js:485 - the id comparison the FCL/SplitContainer probes
    // depend on
    // Reproduces NavContainer's own loose comparison; tightening it here
    // would stop the stub standing in for the control.
    // eslint-disable-next-line eqeqeq
    getPage: (pageId) => aPages.find((p) => p.getId() == pageId) || null,
    // NavContainer.js:782 - normalises a Control to its id before doing
    // anything else, which is why every plain NavContainer port worked
    to: (vPageIdOrControl, sTransitionName) => {
      const sId =
        vPageIdOrControl && typeof vPageIdOrControl.getId === "function"
          ? vPageIdOrControl.getId()
          : vPageIdOrControl;
      aLog.push([sName, sId, sTransitionName]);
      oStub._pageStack.push(sId);
    },
    // NavContainer.js:1064 + :1201 verbatim. `_backTo` normalises a CONTROL
    // (":1065 if (sRequestedPageId instanceof Control)") exactly like `to`
    // does - but nothing normalises a raw STRING, and
    // `_findClosestPreviousPageInfo` then compares
    // "info.id === sRequestedPreviousPageId" against a stack whose entries
    // were all pushed as `page.getId()`. An unprefixed literal matches no
    // entry, so the method logs and returns WITHOUT navigating.
    backToPage: (vPageIdOrControl) => {
      const sId =
        vPageIdOrControl && typeof vPageIdOrControl.getId === "function"
          ? vPageIdOrControl.getId()
          : vPageIdOrControl;
      const i = oStub._pageStack.lastIndexOf(sId, oStub._pageStack.length - 2);
      if (i < 0) {
        // the miss is silent: UI5 Log.error's and returns `this`
        aLog.push([sName, "MISSED", sId]);
        return;
      }
      oStub._pageStack.length = i + 1;
      aLog.push([sName, "back", sId]);
    },
  };
  // the initial page is on the stack before any navigation, under its
  // RENDERED id (NavContainer.js:493 `_ensurePageStackInitialized`)
  oStub._pageStack = aPages.length ? [aPages[0].getId()] : [];
  return oStub;
}

// FlexibleColumnLayout.js:2873 verbatim: begin, then mid, then the
// unconditional else.
function fclStub(oBegin, oMid, oEnd) {
  return {
    to: (sPageId, sTransitionName) => {
      if (oBegin.getPage(sPageId)) oBegin.to(sPageId, sTransitionName);
      else if (oMid.getPage(sPageId)) oMid.to(sPageId, sTransitionName);
      else oEnd.to(sPageId, sTransitionName);
    },
  };
}

test.describe("page-id navigation (CONTROL_BY_ID 'to')", () => {
  function fcl() {
    const nav = [];
    // the rendered ids carry the view prefix the backend never sees
    const products = pageStub("v1--dynamicPageId");
    const detail = pageStub("v1--midPage");
    const end = pageStub("v1--endPage");
    const begin = navContainerStub([products], nav, "begin");
    const mid = navContainerStub([detail], nav, "mid");
    const endCol = navContainerStub([end], nav, "end");
    return {
      nav,
      products,
      begin,
      mid,
      endCol,
      fcl: fclStub(begin, mid, endCol),
    };
  }

  // the defect this kind exists for, asserted on the stub itself so the
  // spec states what the framework must not hand over any more
  test("handing an FCL the CONTROL navigates the wrong column", () => {
    const { nav, products, fcl: oFcl } = fcl();
    oFcl.to(products);
    // begin and mid probe with getPage( <Control> ) and miss, so the
    // unconditional else runs the END column - which does not own the page
    // either. That is the measured symptom on samples-controls app 578:
    // "Navigation triggered to page with ID 'mainView--dynamicPageId', but
    // this page is not known/aggregated by ... fcl-endColumnNav".
    expect(nav).toEqual([["end", "v1--dynamicPageId", undefined]]);
  });

  test("a 'to' naming a begin-column page moves the BEGIN column", () => {
    const { FrontendAction, controls } = load();
    const env = fcl();
    // the backend spells the id without the view prefix; the slot resolves it
    controls.dynamicPageId = env.products;
    controls.fcl = env.fcl;
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "fcl",
      "",
      "to",
      "dynamicPageId",
    ]);
    expect(env.nav).toEqual([["begin", "v1--dynamicPageId", undefined]]);
  });

  test("the id handed over is the RESOLVED one, never the raw literal", () => {
    const { FrontendAction, calls, controls } = load();
    controls.dynamicPageId = pageStub("v1--dynamicPageId");
    controls.fcl = { to: (...a) => calls.push(["to", ...a]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "fcl",
      "",
      "to",
      "dynamicPageId",
    ]);
    expect(calls).toEqual([["to", "v1--dynamicPageId"]]);
  });

  test("the optional transition name still travels as the second argument", () => {
    const { FrontendAction, controls } = load();
    const env = fcl();
    controls.dynamicPageId = env.products;
    controls.fcl = env.fcl;
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "fcl",
      "",
      "to",
      "dynamicPageId",
      "flip",
    ]);
    expect(env.nav).toEqual([["begin", "v1--dynamicPageId", "flip"]]);
  });

  // the constraint the change was allowed under: NavContainer must observe
  // exactly what it observed before
  test("NavContainer sees the identical id it would have computed itself", () => {
    const { FrontendAction, controls } = load();
    const nav = [];
    const page2 = pageStub("v1--page2");
    controls.page2 = page2;
    controls.NavCon = navContainerStub([page2], nav, "nav");
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "NavCon",
      "",
      "to",
      "page2",
    ]);
    // what the old cast produced, run through NavContainer's own
    // normalisation - the two must be indistinguishable
    controls.NavCon.to(page2);
    expect(nav).toEqual([
      ["nav", "v1--page2", undefined],
      ["nav", "v1--page2", undefined],
    ]);
  });

  test("an aggregation item still addresses a page positionally", () => {
    const { FrontendAction, calls, controls } = load();
    const pages = [pageStub("v1--p0"), pageStub("v1--p1")];
    controls.nav = {
      getAggregation: (name) => (name === "pages" ? pages : null),
      to: (...a) => calls.push(["to", ...a]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "nav",
      "",
      "to",
      "nav/pages/1",
    ]);
    expect(calls).toEqual([["to", "v1--p1"]]);
  });

  // "must not silently swallow a miss": today the container absorbs an
  // unknown page and only UI5 logs about it
  test("a page id no control answers to is reported", () => {
    const { FrontendAction, calls, errors, controls } = load();
    controls.fcl = { to: (...a) => calls.push(["to", ...a]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "fcl", "", "to", "nosuch"]);
    expect(errors.join(" ")).toContain("nosuch");
    // still handed over: an already-qualified id must keep working
    expect(calls).toEqual([["to", "nosuch"]]);
  });
});

/* backToPage is the SAME defect as `to`, one method along, and it was left
 * unmeasured when the `pageId` kind was introduced. Measured 2026-08-27 on
 * samples-controls app 101 against the live Node backend: after
 * `to( wizardReviewPage )` the stack reads
 * ["mainView--wizardContentPage", "mainView--wizardReviewPage"], the port's
 * "Edit" link fires backToPage("wizardContentPage"), and UI5 answers
 *
 *   Element sap.m.NavContainer#mainView--wizardNavContainer: Cannot navigate
 *   backToPage('wizardContentPage') because target page was not found among
 *   the previous pages.
 *
 * with the review page still on screen. The same call with the prefixed id
 * navigates. Unlike the FCL case there is no wrong-target symptom - it is a
 * pure no-op, which is why nothing caught it. */
test.describe("page-id navigation (CONTROL_BY_ID 'backToPage')", () => {
  function wizard() {
    const nav = [];
    // app 101's two pages, under the ids the view actually renders
    const content = pageStub("mainView--wizardContentPage");
    const review = pageStub("mainView--wizardReviewPage");
    return {
      nav,
      content,
      review,
      navCon: navContainerStub([content, review], nav, "nav"),
    };
  }

  // the defect, asserted on the stub itself
  test("a RAW unprefixed id finds no stack entry and navigates nowhere", () => {
    const { nav, navCon } = wizard();
    navCon.to("mainView--wizardReviewPage");
    navCon.backToPage("wizardContentPage");
    expect(nav).toEqual([
      ["nav", "mainView--wizardReviewPage", undefined],
      ["nav", "MISSED", "wizardContentPage"],
    ]);
  });

  test("the id handed over is the RESOLVED one, so the back leg lands", () => {
    const { FrontendAction, controls } = load();
    const env = wizard();
    // the backend spells the id without the view prefix
    controls.wizardContentPage = env.content;
    controls.nav = env.navCon;
    env.navCon.to("mainView--wizardReviewPage");
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "nav",
      "",
      "backToPage",
      "wizardContentPage",
    ]);
    expect(env.nav).toEqual([
      ["nav", "mainView--wizardReviewPage", undefined],
      ["nav", "back", "mainView--wizardContentPage"],
    ]);
    expect(env.navCon._pageStack).toEqual(["mainView--wizardContentPage"]);
  });

  test("the resolved id is what reaches the method, never the raw literal", () => {
    const { FrontendAction, calls, controls } = load();
    controls.wizardContentPage = pageStub("mainView--wizardContentPage");
    controls.nav = { backToPage: (...a) => calls.push(["backToPage", ...a]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "nav",
      "",
      "backToPage",
      "wizardContentPage",
    ]);
    expect(calls).toEqual([["backToPage", "mainView--wizardContentPage"]]);
  });

  test("an aggregation item still addresses a page positionally", () => {
    const { FrontendAction, calls, controls } = load();
    const pages = [pageStub("v1--p0"), pageStub("v1--p1")];
    controls.nav = {
      getAggregation: (name) => (name === "pages" ? pages : null),
      backToPage: (...a) => calls.push(["backToPage", ...a]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "nav",
      "",
      "backToPage",
      "nav/pages/0",
    ]);
    expect(calls).toEqual([["backToPage", "v1--p0"]]);
  });

  // same escape hatch as `to`: a port that already spells the qualified id
  // must keep working, and the miss must be named rather than swallowed
  test("a page id no control answers to is reported and still handed over", () => {
    const { FrontendAction, calls, errors, controls } = load();
    controls.nav = { backToPage: (...a) => calls.push(["backToPage", ...a]) };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "nav",
      "",
      "backToPage",
      "nosuch",
    ]);
    expect(errors.join(" ")).toContain("nosuch");
    expect(calls).toEqual([["backToPage", "nosuch"]]);
  });

  // the zero-arg back-navigation entries stay zero-arg: `back` must not
  // acquire an argument from this change
  test("plain 'back' is still zero-arg", () => {
    const { FrontendAction, calls, controls } = load();
    controls.nav = { back: (...a) => calls.push(["back", ...a]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "nav", "", "back", "x"]);
    expect(calls).toEqual([["back"]]);
  });
});

// ---------------------------------------------------------------------
// sap.m.Button badge bounds. Both setters compare the incoming value
// against the STORED bound (Button.js:339 / :360), so two strings make
// the comparison lexicographic - "50" >= "9" is false and the value is
// dropped into an else whose only effect is a Log.warning. The stub is
// those two guards, with the 1 / 9999 Button.init writes.
// ---------------------------------------------------------------------
function badgedButtonStub(aLog) {
  const state = { min: 1, max: 9999 };
  return {
    state,
    setBadgeMinValue: (iMin) => {
      // Reproduces the control's own loose comparison, as above.
      if (
        iMin &&
        !isNaN(iMin) &&
        iMin >= 1 &&
        // eslint-disable-next-line eqeqeq
        iMin != state.min &&
        iMin <= state.max
      ) {
        state.min = iMin;
        aLog.push(["min", iMin]);
      } else aLog.push(["min-rejected", iMin]);
    },
    setBadgeMaxValue: (iMax) => {
      // As above.
      if (
        iMax &&
        !isNaN(iMax) &&
        iMax <= 9999 &&
        // eslint-disable-next-line eqeqeq
        iMax != state.max &&
        iMax >= state.min
      ) {
        state.max = iMax;
        aLog.push(["max", iMax]);
      } else aLog.push(["max-rejected", iMax]);
    },
  };
}

test.describe("badge bounds (CONTROL_BY_ID setBadgeMinValue/setBadgeMaxValue)", () => {
  // the defect, on the stub: strings are compared as strings
  test("string bounds make the Button reject a valid pair", () => {
    const log = [];
    const btn = badgedButtonStub(log);
    btn.setBadgeMinValue("9");
    btn.setBadgeMaxValue("50");
    expect(log).toEqual([
      ["min", "9"],
      ["max-rejected", "50"],
    ]);
  });

  test("min 9 / max 50 is accepted - both arrive as numbers", () => {
    const { FrontendAction, controls } = load();
    const log = [];
    controls.BadgedButton = badgedButtonStub(log);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "BadgedButton",
      "",
      "setBadgeMinValue",
      "9",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "BadgedButton",
      "",
      "setBadgeMaxValue",
      "50",
    ]);
    expect(log).toEqual([
      ["min", 9],
      ["max", 50],
    ]);
    expect(controls.BadgedButton.state).toEqual({ min: 9, max: 50 });
  });

  test("the values are numbers, not numeric strings", () => {
    const { FrontendAction, calls, controls } = load();
    controls.b = {
      setBadgeMinValue: (v) => calls.push(["min", v, typeof v]),
      setBadgeMaxValue: (v) => calls.push(["max", v, typeof v]),
    };
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "b",
      "",
      "setBadgeMinValue",
      "2",
    ]);
    FrontendAction.execute(null, [
      "CONTROL_BY_ID",
      "b",
      "",
      "setBadgeMaxValue",
      "500",
    ]);
    expect(calls).toEqual([
      ["min", 2, "number"],
      ["max", 500, "number"],
    ]);
  });
});
