// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the CONTROL_GLOBAL / CONTROL_BY_ID handlers in the real
// app/webapp/core/FrontendAction.js (loaded via a stubbed sap.ui.define).
// The focus is the whitelist boundary and the argument casting.

function load({ sandbox } = {}) {
  const calls = [];
  const errors = [];
  const rec =
    (name) =>
    (...a) =>
      calls.push([name, ...a]);
  const MessageToast = { show: rec("toast.show") };
  const MessageBox = { show: rec("box.show"), error: rec("box.error") };
  const BusyIndicator = { show: rec("busy.show"), hide: rec("busy.hide") };
  const Theming = { setTheme: rec("theme.set") };
  const Popup = { setWithinArea: rec("popup.setWithinArea") };
  const controls = {};
  const views = {};
  const ViewSlots = {
    resolveById: (id) => controls[id] || null,
    byId: (_key, id) => controls[id] || null,
    getView: (key) => views[key] || null,
  };
  // whenRendered runs its callback once the control is in the DOM; the real
  // one defers to onAfterRendering when it is not. The stub runs it straight
  // away (the specs treat the anchor as already rendered).
  const Lib = {
    logError: (m) => errors.push(m),
    runCallbacks: () => {},
    toText: (val) => (val == null ? "" : String(val)),
    whenRendered: (_control, _owner, fn) => fn(),
    isDestroyed: (o) => Boolean(o?.isDestroyed && o.isDestroyed()),
  };
  const AppState = { state: { onBeforeEventFrontend: [], shortcuts: {} } };
  function Filter(path, operator, value1, value2) {
    Object.assign(this, { path, operator, value1, value2 });
  }
  function Sorter(path, descending, group) {
    Object.assign(this, { path, descending, group });
  }
  const FilterOperator = new Proxy({}, { get: (_t, op) => op });
  const { module, sandbox: ctx } = loadModule("core/FrontendAction.js", {
    deps: {
      "sap/m/MessageBox": MessageBox,
      "sap/m/MessageToast": MessageToast,
      "sap/ui/core/BusyIndicator": BusyIndicator,
      "sap/ui/core/Theming": Theming,
      "sap/ui/model/odata/v2/ODataModel": function () {},
      "sap/ui/model/Filter": Filter,
      "sap/ui/model/FilterOperator": FilterOperator,
      "sap/ui/model/Sorter": Sorter,
      "sap/m/library": {},
      "sap/ui/util/Storage": function () {},
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
      "z2ui5/core/AppState": AppState,
    },
    sandbox,
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
    expect(calls).toEqual([["toast.show", "Action triggered on item: Franchise Store"]]);
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
    const { FrontendAction, calls, controls, Popup, ctx } = load();
    const area = { id: "withinArea" };
    controls.withinArea = area;
    ctx.sap.ui.require = (name) =>
      name === "sap/ui/core/Popup" ? Popup : null;
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
    const { FrontendAction, calls, Popup, ctx } = load();
    ctx.sap.ui.require = (name) =>
      name === "sap/ui/core/Popup" ? Popup : null;
    FrontendAction.execute(null, ["CONTROL_GLOBAL", "POPUP", "setWithinArea", ""]);
    expect(calls).toEqual([["popup.setWithinArea", null]]);
  });

  test("POPUP.setWithinArea reports an older runtime instead of throwing", () => {
    const { FrontendAction, calls, errors, ctx } = load();
    // UI5 1.71 has sap/ui/core/Popup but not setWithinArea (@since 1.89)
    ctx.sap.ui.require = () => ({});
    FrontendAction.execute(null, [
      "CONTROL_GLOBAL",
      "POPUP",
      "setWithinArea",
      "withinArea",
    ]);
    expect(calls).toHaveLength(0);
    expect(errors).toEqual(["CONTROL_GLOBAL: 'POPUP.setWithinArea' not available"]);
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

  test("FORMATTING.setCustomCurrencies parses its JSON payload", () => {
    const { FrontendAction, ctx } = load();
    const set = [];
    ctx.sap.ui.require = (name) =>
      name === "sap/ui/core/Formatting"
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

  test("resolves a controlId argument to the control (to)", () => {
    const { FrontendAction, calls, controls } = load();
    const page2 = { id: "page2" };
    controls.page2 = page2;
    controls.NavCon = { to: (ctrl) => calls.push(["to", ctrl]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "NavCon", "", "to", "page2"]);
    expect(calls).toEqual([["to", page2]]);
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
        "CONTROL_BY_ID", "car", "", "setActivePage", "car/pages/2",
      ]);
      expect(calls).toEqual([["setActivePage", pages[2]]]);
    });

    test("index 0 is an item, not an empty argument", () => {
      const { FrontendAction, calls, controls } = load();
      const pages = carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID", "car", "", "setActivePage", "car/pages/0",
      ]);
      expect(calls).toEqual([["setActivePage", pages[0]]]);
    });

    test("a plain id still resolves exactly as before", () => {
      const { FrontendAction, calls, controls } = load();
      const page2 = { id: "page2" };
      controls.page2 = page2;
      controls.NavCon = { to: (ctrl) => calls.push(["to", ctrl]) };
      FrontendAction.execute(null, ["CONTROL_BY_ID", "NavCon", "", "to", "page2"]);
      expect(calls).toEqual([["to", page2]]);
    });

    test("an out-of-range index is reported, not silently passed as undefined", () => {
      const { FrontendAction, calls, errors, controls } = load();
      carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID", "car", "", "setActivePage", "car/pages/9",
      ]);
      expect(calls).toEqual([["setActivePage", null]]);
      expect(errors.join(" ")).toContain("3 item(s)");
    });

    test("a single-valued aggregation is refused", () => {
      const { FrontendAction, calls, errors, controls } = load();
      carousel(calls, controls);
      FrontendAction.execute(null, [
        "CONTROL_BY_ID", "car", "", "setActivePage", "car/footer/0",
      ]);
      expect(errors.join(" ")).toContain("no multiple aggregation");
    });

    test("an unknown owner control is reported", () => {
      const { FrontendAction, errors, controls } = load();
      controls.car = { setActivePage: () => {} };
      FrontendAction.execute(null, [
        "CONTROL_BY_ID", "car", "", "setActivePage", "nosuch/pages/0",
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
      "setAggregation", "addAggregation", "insertAggregation",
      "removeAggregation", "removeAllAggregation", "destroyAggregation",
      "setAssociation", "addAssociation", "removeAssociation",
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
      "removeAllSelectedDates", "removeAllItems", "removeAllContent",
      "destroySpecialDates", "destroyItems", "removeItem",
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "feed", "", "enablePostButton", "X"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "feed", "", "enablePostButton", " "]);
    expect(calls).toEqual([
      ["enablePostButton", true],
      ["enablePostButton", false],
    ]);
  });

  test("infers arg types for an unlisted method (X/space->bool, else string)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.c = { setValueState: (...a) => calls.push(["setValueState", ...a]) };
    // a genuine string arg passes through; only the ABAP bool tokens convert
    FrontendAction.execute(null, ["CONTROL_BY_ID", "c", "", "setValueState", "Error"]);
    expect(calls).toEqual([["setValueState", "Error"]]);
  });

  test("a listed method still wins over inference (explicit kinds)", () => {
    const { FrontendAction, calls, controls } = load();
    // setHiddenInPopin is listed as ["object"] -> arg is JSON.parsed, not left a string
    controls.t = { setHiddenInPopin: (a) => calls.push(["setHiddenInPopin", a]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "t", "", "setHiddenInPopin", '["High"]']);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "vsd", "", "open", "filter"]);
    expect(calls).toEqual([["open", "filter"]]);
  });

  test("to passes the optional transitionName (NavContainer animation)", () => {
    const { FrontendAction, calls, controls } = load();
    const page2 = { id: "page2" };
    controls.page2 = page2;
    controls.NavCon = { to: (...a) => calls.push(["to", ...a]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "NavCon", "", "to", "page2", "fade"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "NavCon", "", "to", "page2"]);
    expect(calls).toEqual([
      ["to", page2, "fade"],
      ["to", page2],
    ]);
  });

  test("goToStep resolves the step and casts the focus flag (Wizard)", () => {
    const { FrontendAction, calls, controls } = load();
    const step2 = { id: "STEP2" };
    controls.STEP2 = step2;
    controls.wiz = { goToStep: (s, b) => calls.push(["goToStep", s, b]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "wiz", "", "goToStep", "STEP2", "X"]);
    expect(calls).toEqual([["goToStep", step2, true]]);
  });

  test("openBy anchors to the resolved control (not its DOM ref)", () => {
    // Every sap.m openBy accepts a control, and MessagePopover.openBy needs
    // one (it dereferences getParent()), so the anchor is the control itself.
    const { FrontendAction, calls, controls } = load();
    const anchor = { getDomRef: () => ({ tagName: "BUTTON" }) };
    controls.anchorBtn = anchor;
    controls.HiddenDP = { openBy: (ref) => calls.push(["openBy", ref]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "HiddenDP", "", "openBy", "anchorBtn"]);
    expect(calls).toEqual([["openBy", anchor]]);
  });

  test("openBy anchors to the control even when it is not rendered yet", () => {
    const { FrontendAction, calls, controls } = load();
    const anchor = { getDomRef: () => null };
    controls.anchorBtn = anchor;
    controls.HiddenDP = { openBy: (ref) => calls.push(["openBy", ref]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "HiddenDP", "", "openBy", "anchorBtn"]);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "theMenu", "", "toggleBy", "anchorBtn"]);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "theMenu", "", "toggleBy", "anchorBtn"]);
    expect(calls).toEqual([["close"]]);
  });

  test("setActivePage resolves the page control (Carousel)", () => {
    const { FrontendAction, calls, controls } = load();
    const page2 = { id: "carPage2" };
    controls.carPage2 = page2;
    controls.carousel = { setActivePage: (p) => calls.push(["setActivePage", p]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "carousel", "", "setActivePage", "carPage2"]);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "panel", "", "setExpanded", "X"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "panel", "", "setExpanded", ""]);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "dlg", "", "addStyleClass", "myClass"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "dlg", "", "removeStyleClass", "myClass"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "dlg", "", "toggleStyleClass", "myClass"]);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "split", "", "toDetail", "detailDetail"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "split", "", "toMaster", "master2"]);
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
    FrontendAction.execute(null, ["CONTROL_BY_ID", "split", "", "setMode", "StretchCompressMode"]);
    expect(calls).toEqual([["setMode", "StretchCompressMode"]]);
  });

  test("navigateBack stays a no-arg call (QuickView/QuickViewCard)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.qv = { navigateBack: (...a) => calls.push(["navigateBack", a.length]) };
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
    controls.idList = { getBinding: (agg) => (agg === "items" ? binding : null) };
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
      [["CATEGORY", "EQ", "Accessories"], ["CATEGORY", "EQ", "Laptops"]],
      [["SUPPLIER_NAME", "EQ", "Technocom"]],
    ]);
    FrontendAction.execute(null, ["BINDING_CALL", "idList", "items", "filter", json]);
    expect(calls).toHaveLength(1);
    const [name, filters] = calls[0];
    expect(name).toBe("filter");
    expect(filters).toHaveLength(1);
    const root = filters[0]; // mock Filter stores (aFilters, bAnd) as (path, operator)
    expect(root.operator).toBe(true); // AND across groups
    expect(root.path).toHaveLength(2);
    expect(root.path[0].operator).toBe(false); // OR inside the group
    expect(root.path[0].path).toHaveLength(2);
    expect(root.path[0].path[0]).toMatchObject({ path: "CATEGORY", operator: "EQ", value1: "Accessories" });
    expect(root.path[1].path[0]).toMatchObject({ path: "SUPPLIER_NAME", operator: "EQ", value1: "Technocom" });
  });

  test("empty compound groups clear the filter; empty inner groups are skipped", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, ["BINDING_CALL", "idList", "items", "filter", "[]"]);
    FrontendAction.execute(null, ["BINDING_CALL", "idList", "items", "filter", "[[],[]]"]);
    expect(calls).toEqual([
      ["filter", []],
      ["filter", []],
    ]);
  });

  test("compound groups reject bad operators and malformed JSON", () => {
    const { FrontendAction, calls, errors, controls } = load();
    withListBinding(controls, calls);
    FrontendAction.execute(null, [
      "BINDING_CALL", "idList", "items", "filter",
      JSON.stringify([[["NAME", "DROP TABLE", "x"]]]),
    ]);
    FrontendAction.execute(null, ["BINDING_CALL", "idList", "items", "filter", "[not json"]);
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
    FrontendAction.execute(null, ["BIND_ELEMENT", "POPOVER", "5", "/T_PRODUCTS"]);
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
    FrontendAction.execute(null, ["BIND_ELEMENT", "POPOVER", "5", "/T_PRODUCTS"]);
    expect(errors.some((e) => String(e).includes("no view for slot"))).toBe(true);
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
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE_POPOVER", "POPOVER",
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
        ["SAVE", ""], ["SAVE_NEST", "NEST"], ["SAVE_POPOVER", "POPOVER"],
      ]) {
        FrontendAction.execute(
          oController,
          ["KEYBOARD_SHORTCUT", "Ctrl+S", event, scope].filter((a, i) => i < 3 || a),
        );
      }
      views.NEST = {};
      views.POPOVER = {};
      doc.press("s", { ctrlKey: true });
      expect(fired).toEqual([["SAVE_POPOVER"]]);
    });

    test("a scoped registration with no open slot falls back to the unscoped one", () => {
      const { FrontendAction, doc, fired, oController } = loadWithDoc();
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE_POPUP", "POPUP",
      ]);
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);
    });

    test("unregistering one scope leaves the other alone", () => {
      const { FrontendAction, doc, fired, views, oController } = loadWithDoc();
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE_POPOVER", "POPOVER",
      ]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "", "POPOVER",
      ]);
      views.POPOVER = {};
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);
    });

    test("removing the last scope stops swallowing the browser default", () => {
      const { FrontendAction, doc, fired, oController } = loadWithDoc();
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
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
      const { FrontendAction, doc, fired, controls, oController } = loadWithDoc();
      let open = false;
      controls.popoverCommand = { isOpen: () => open };
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "PSAVE", "popoverCommand",
      ]);

      doc.press("s", { ctrlKey: true });          // closed -> the page command
      open = true;
      doc.press("s", { ctrlKey: true });          // open -> the popover's own
      open = false;
      doc.press("s", { ctrlKey: true });          // closed again
      expect(fired).toEqual([["SAVE"], ["PSAVE"], ["SAVE"]]);
    });

    test("a control scope beats a slot scope - it is the more specific statement", () => {
      const { FrontendAction, doc, fired, controls, views, oController } = loadWithDoc();
      controls.dlg = { isOpen: () => true };
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "SLOT", "POPOVER",
      ]);
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "CTRL", "dlg"]);
      views.POPOVER = {};
      doc.press("s", { ctrlKey: true });
      expect(fired).toEqual([["CTRL"]]);
    });

    test("a control scope whose control is gone falls back to the unscoped one", () => {
      const { FrontendAction, doc, fired, oController } = loadWithDoc();
      FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
      FrontendAction.execute(oController, [
        "KEYBOARD_SHORTCUT", "Ctrl+S", "PSAVE", "nosuchcontrol",
      ]);
      expect(doc.press("s", { ctrlKey: true })).toBe(true);
      expect(fired).toEqual([["SAVE"]]);
    });
  });

  test("fires the registered event and swallows the browser default", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
    expect(doc.press("s", { ctrlKey: true })).toBe(true);
    expect(fired).toEqual([["SAVE"]]);
  });

  test("ignores a combination that was not registered", () => {
    const { FrontendAction, doc, fired, oController } = loadWithDoc();
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
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
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
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
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+S", "SAVE"]);
    expect(doc.press("Control", { ctrlKey: true })).toBe(false);
    expect(fired).toEqual([]);
  });

  test("rejects a combination that names no key", () => {
    const { FrontendAction, errors, oController } = loadWithDoc();
    FrontendAction.execute(oController, ["KEYBOARD_SHORTCUT", "Ctrl+", "SAVE"]);
    expect(errors[0]).toContain("names no key");
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

  test("a missing argument clears the href instead of writing 'undefined'", () => {
    const { FrontendAction, doc } = loadWithDoc("icon");
    FrontendAction.execute(null, ["SET_FAVICON"]);
    expect(doc.head).toEqual([{ rel: "icon", href: "" }]);
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
