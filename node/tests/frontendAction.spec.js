// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the CONTROL_GLOBAL / CONTROL_BY_ID handlers in the real
// app/webapp/core/FrontendAction.js (loaded via a stubbed sap.ui.define).
// The focus is the whitelist boundary and the argument casting.

function load() {
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
  const controls = {};
  const ViewSlots = {
    resolveById: (id) => controls[id] || null,
    byId: (_key, id) => controls[id] || null,
  };
  const Lib = {
    logError: (m) => errors.push(m),
    runCallbacks: () => {},
    isDestroyed: () => false,
    // same contract as the real Lib.whenRendered: run immediately when the
    // control is rendered, otherwise after its next rendering
    whenRendered: (control, _owner, fn) => {
      if (control.getDomRef?.()) {
        fn();
      } else {
        control.addEventDelegate({ onAfterRendering: fn });
      }
    },
  };
  const AppState = { state: { onBeforeEventFrontend: [] } };
  function Filter(path, operator, value1, value2) {
    Object.assign(this, { path, operator, value1, value2 });
  }
  function Sorter(path, descending, group) {
    Object.assign(this, { path, descending, group });
  }
  const FilterOperator = new Proxy({}, { get: (_t, op) => op });
  const { module } = loadModule("core/FrontendAction.js", {
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
  });
  return { FrontendAction: module, calls, errors, controls };
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

  test("rejects a non-whitelisted object or method", () => {
    const { FrontendAction, calls, errors } = load();
    FrontendAction.execute(null, ["CONTROL_GLOBAL", "WINDOW", "close"]);
    FrontendAction.execute(null, ["CONTROL_GLOBAL", "THEMING", "destroy"]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(2);
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

  test("resolves a controlId argument to the control (to)", () => {
    const { FrontendAction, calls, controls } = load();
    const page2 = { id: "page2" };
    controls.page2 = page2;
    controls.NavCon = { to: (ctrl) => calls.push(["to", ctrl]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "NavCon", "", "to", "page2"]);
    expect(calls).toEqual([["to", page2]]);
  });

  test("rejects a non-whitelisted method", () => {
    const { FrontendAction, calls, errors, controls } = load();
    controls.x = { destroy: () => calls.push(["destroy"]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "x", "", "destroy"]);
    expect(calls).toHaveLength(0);
    expect(errors).toHaveLength(1);
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

  test("openBy resolves the anchor to its DOM ref (hidden DatePicker)", () => {
    const { FrontendAction, calls, controls } = load();
    const dom = { tagName: "BUTTON" };
    controls.anchorBtn = { getDomRef: () => dom };
    controls.HiddenDP = { openBy: (ref) => calls.push(["openBy", ref]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "HiddenDP", "", "openBy", "anchorBtn"]);
    expect(calls).toEqual([["openBy", dom]]);
  });

  test("openBy falls back to the control when no DOM ref is rendered", () => {
    const { FrontendAction, calls, controls } = load();
    const anchor = { getDomRef: () => null };
    controls.anchorBtn = anchor;
    controls.HiddenDP = { openBy: (ref) => calls.push(["openBy", ref]) };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "HiddenDP", "", "openBy", "anchorBtn"]);
    expect(calls).toEqual([["openBy", anchor]]);
  });

  test("toggleBy opens the control anchored to the DOM ref when closed", () => {
    const { FrontendAction, calls, controls } = load();
    const dom = { tagName: "BUTTON" };
    controls.anchorBtn = { getDomRef: () => dom };
    controls.theMenu = {
      isOpen: () => false,
      openBy: (ref) => calls.push(["openBy", ref]),
      close: () => calls.push(["close"]),
    };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "theMenu", "", "toggleBy", "anchorBtn"]);
    expect(calls).toEqual([["openBy", dom]]);
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
});

test.describe("SET_FOCUS", () => {
  // Minimal focusable control: rendered DOM, focus info round-trip and the
  // event-delegate API evSetFocus uses for its deferrals.
  function makeInput(controls, calls, { disabled = false, enabled = true } = {}) {
    const delegates = [];
    const control = {
      getDomRef: () => ({}),
      getFocusDomRef: () => ({ disabled }),
      getEnabled: () => enabled,
      getFocusInfo: () => ({ id: "myInput" }),
      applyFocusInfo: (info) => calls.push(["applyFocusInfo", info]),
      addEventDelegate: (d) => delegates.push(d),
      removeEventDelegate: (d) => delegates.splice(delegates.indexOf(d), 1),
    };
    controls.myInput = control;
    return { control, delegates };
  }

  test("applies focus and cursor position on an enabled rendered control", () => {
    const { FrontendAction, calls, controls } = load();
    makeInput(controls, calls);
    FrontendAction.execute(null, ["SET_FOCUS", "myInput", "2", "5"]);
    expect(calls).toEqual([
      ["applyFocusInfo", { id: "myInput", selectionStart: 2, selectionEnd: 5 }],
    ]);
  });

  test("defers focus until after re-rendering when the DOM input is still disabled (field re-enabled via binding)", () => {
    const { FrontendAction, calls, controls } = load();
    const { delegates } = makeInput(controls, calls, { disabled: true });
    FrontendAction.execute(null, ["SET_FOCUS", "myInput", "3", "3"]);
    // stale disabled DOM: nothing applied yet, a rendering delegate waits
    expect(calls).toHaveLength(0);
    expect(delegates).toHaveLength(1);
    // the re-rendering replaces the DOM with the enabled input
    controls.myInput.getFocusDomRef = () => ({ disabled: false });
    delegates[0].onAfterRendering();
    expect(calls).toEqual([
      ["applyFocusInfo", { id: "myInput", selectionStart: 3, selectionEnd: 3 }],
    ]);
    expect(delegates).toHaveLength(0);
  });

  test("does not wait when the control itself is disabled (no re-rendering coming)", () => {
    const { FrontendAction, calls, controls } = load();
    const { delegates } = makeInput(controls, calls, {
      disabled: true,
      enabled: false,
    });
    FrontendAction.execute(null, ["SET_FOCUS", "myInput"]);
    expect(delegates).toHaveLength(0);
    expect(calls).toEqual([["applyFocusInfo", { id: "myInput" }]]);
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
