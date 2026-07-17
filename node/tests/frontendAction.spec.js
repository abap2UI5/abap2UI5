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
  const { module } = loadModule("core/FrontendAction.js", {
    deps: {
      "sap/m/MessageBox": MessageBox,
      "sap/m/MessageToast": MessageToast,
      "sap/ui/core/BusyIndicator": BusyIndicator,
      "sap/ui/core/Theming": Theming,
      "sap/ui/model/odata/v2/ODataModel": function () {},
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
});
