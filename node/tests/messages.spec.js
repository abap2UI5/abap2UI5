// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/core/Messages.js
// (loaded via a stubbed sap.ui.define) instead of a local copy that could
// drift. MessageBox / MessageToast / Lib are stubbed so the specs can
// observe which display function a backend message ends up in.
//
// The options arrive as a plain object carrying the UI5 option names: the
// backend sends only what the app set, so anything absent here is absent
// because the app left it alone.

function loadMessages(sandbox) {
  const boxCalls = [];
  const toastCalls = [];
  const errors = [];
  const ebCalls = [];
  const boxFn = (name) => (text, params) =>
    boxCalls.push({ name, text, params });
  const MessageBox = {
    show: boxFn("show"),
    alert: boxFn("alert"),
    confirm: boxFn("confirm"),
    error: boxFn("error"),
    information: boxFn("information"),
    success: boxFn("success"),
    warning: boxFn("warning"),
    // Enum-style members that must never be picked as display functions.
    Action: { OK: "OK" },
    Icon: { ERROR: "ERROR" },
  };
  const MessageToast = {
    show: (text, opts) => toastCalls.push({ text, opts }),
  };
  const Lib = {
    logError: (message) => errors.push(message),
    sanitizeMessageDetails: (html) => `sanitized:${html}`,
  };
  // ViewSlots.resolveById maps a control id to its element for the
  // dependentOn option. Only "knownId" resolves here.
  const elements = { knownId: { id: "knownId" } };
  const ViewSlots = {
    resolveById: (sId) => elements[sId] || null,
  };
  const { module } = loadModule("core/Messages.js", {
    sandbox,
    deps: {
      "sap/m/MessageBox": MessageBox,
      "sap/m/MessageToast": MessageToast,
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
    },
  });
  const oController = { eB: (...args) => ebCalls.push(args) };
  return {
    Messages: module,
    boxCalls,
    toastCalls,
    errors,
    ebCalls,
    elements,
    oController,
  };
}

function showBox(sType, mOptions) {
  const env = loadMessages();
  env.Messages.showBox(sType, "boom", mOptions || {}, env.oController);
  return env;
}

test.describe("showBox type resolution", () => {
  test("the type selects the matching MessageBox method", () => {
    const { boxCalls, errors } = showBox("error");
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("error");
    expect(boxCalls[0].text).toBe("boom");
    expect(errors).toHaveLength(0);
  });

  test("unknown type falls back to show() and logs", () => {
    const { boxCalls, errors } = showBox("garbage");
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("show");
    expect(errors).toHaveLength(1);
    expect(errors[0]).toContain("garbage");
  });

  test("a type matching an enum member is not invoked as a function", () => {
    // MessageBox.Action exists but is an enum object, not a display
    // function - the lookup must skip it and fall back to show().
    const { boxCalls } = showBox("Action");
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("show");
  });
});

test.describe("showBox options", () => {
  test("options are forwarded untouched", () => {
    const { boxCalls } = showBox("show", { contentWidth: "20rem" });
    expect(boxCalls[0].params.contentWidth).toBe("20rem");
  });

  test("an option the backend omitted stays absent", () => {
    const { boxCalls } = showBox("show");
    expect(boxCalls[0].params).not.toHaveProperty("contentWidth");
  });

  test("details are sanitized", () => {
    const { boxCalls } = showBox("show", { details: "<b>x</b>" });
    expect(boxCalls[0].params.details).toBe("sanitized:<b>x</b>");
  });

  test("dependentOn resolves a control id to its element", () => {
    const { boxCalls, elements } = showBox("show", { dependentOn: "knownId" });
    expect(boxCalls[0].params.dependentOn).toBe(elements.knownId);
  });

  test("an unresolvable dependentOn id drops the option", () => {
    const { boxCalls } = showBox("show", { dependentOn: "missingId" });
    expect(boxCalls[0].params).not.toHaveProperty("dependentOn");
  });

  test("onClose round-trips the event with the pressed action", () => {
    const { boxCalls, ebCalls } = showBox("confirm", { onClose: "ANSWERED" });
    boxCalls[0].params.onClose("OK");
    // the pressed action rides OUTSIDE the event array - inside it, it would
    // be shifted away with the array and never reach T_EVENT_ARG
    expect(ebCalls).toEqual([[["ANSWERED"], "OK"]]);
  });
});

test.describe("showToast", () => {
  test("options are forwarded untouched", () => {
    const env = loadMessages();
    env.Messages.showToast("hi", { duration: 250 }, env.oController);
    expect(env.toastCalls[0].text).toBe("hi");
    expect(env.toastCalls[0].opts.duration).toBe(250);
  });

  test("no options means no options - UI5 applies its own defaults", () => {
    const env = loadMessages();
    env.Messages.showToast("hi", {}, env.oController);
    expect(env.toastCalls[0].opts).toEqual({});
  });

  test("class lands on the toast DOM node, not in the options", () => {
    // `class` is no MessageToast option: it is applied to the newest toast's
    // DOM node afterwards, so passing it on would be an unknown option.
    const added = [];
    const toastEl = { classList: { add: (...c) => added.push(...c) } };
    const env = loadMessages({
      document: { querySelectorAll: () => [toastEl] },
    });
    env.Messages.showToast("hi", { class: "a b" }, env.oController);
    expect(env.toastCalls[0].opts).not.toHaveProperty("class");
    expect(added).toEqual(["a", "b"]);
  });

  test("onClose round-trips the event", () => {
    const env = loadMessages();
    env.Messages.showToast("hi", { onClose: "CLOSED" }, env.oController);
    env.toastCalls[0].opts.onClose();
    expect(env.ebCalls).toEqual([[["CLOSED"]]]);
  });
});
