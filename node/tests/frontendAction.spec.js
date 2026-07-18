// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the control_call / control_call_by_id handlers in the real
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
  const Lib = { logError: (m) => errors.push(m), runCallbacks: () => {} };
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

test.describe("control_call (global objects)", () => {
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

test.describe("control_call_by_id", () => {
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

  test("open/close take no args (popup-mode PDFViewer, Dialog)", () => {
    const { FrontendAction, calls, controls } = load();
    controls.pdfViewer = {
      open: () => calls.push(["open"]),
      close: () => calls.push(["close"]),
    };
    FrontendAction.execute(null, ["CONTROL_BY_ID", "pdfViewer", "", "open"]);
    FrontendAction.execute(null, ["CONTROL_BY_ID", "pdfViewer", "", "close"]);
    expect(calls).toEqual([["open"], ["close"]]);
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

test.describe("binding_call", () => {
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

  test("an empty (or dropped) value1 clears the filter", () => {
    const { FrontendAction, calls, controls } = load();
    withListBinding(controls, calls);
    // the backend arg serializer drops empty strings, so the cleared-query
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
