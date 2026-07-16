// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the real implementation shipped in app/webapp/core/Messages.js
// (loaded via a stubbed sap.ui.define) instead of a local copy that could
// drift. MessageBox / MessageToast / Lib are stubbed so the specs can
// observe which display function a backend message ends up in.

function loadMessages() {
  const boxCalls = [];
  const toastCalls = [];
  const errors = [];
  const boxFn = (name) => (text, params) => boxCalls.push({ name, text, params });
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
    sanitizeMessageDetails: (html) => html,
  };
  // Stub sap.ui.core.Popup. toDockValue() looks dock positions up by their
  // PascalCase key in Popup.Dock; newer UI5 spells the enum values in the
  // same PascalCase form.
  const Popup = {
    Dock: {
      BeginTop: "BeginTop",
      BeginCenter: "BeginCenter",
      BeginBottom: "BeginBottom",
      CenterTop: "CenterTop",
      CenterCenter: "CenterCenter",
      CenterBottom: "CenterBottom",
      EndTop: "EndTop",
      EndCenter: "EndCenter",
      EndBottom: "EndBottom",
    },
  };
  const { module } = loadModule("core/Messages.js", {
    deps: {
      "sap/m/MessageBox": MessageBox,
      "sap/m/MessageToast": MessageToast,
      "sap/ui/core/Popup": Popup,
      "z2ui5/core/Lib": Lib,
    },
  });
  return { Messages: module, boxCalls, toastCalls, errors };
}

function showBox(msg) {
  const env = loadMessages();
  env.Messages.show("S_MSG_BOX", { S_MSG_BOX: msg }, null);
  return env;
}

test.describe("S_MSG_BOX type resolution", () => {
  test("lowercase type calls the matching MessageBox method", () => {
    const { boxCalls, errors } = showBox({ TEXT: "boom", TYPE: "error" });
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("error");
    expect(boxCalls[0].text).toBe("boom");
    expect(errors).toHaveLength(0);
  });

  test("capitalized type falls back to the lowercase method", () => {
    // The ABAP message formatter sends capitalized types ("Error",
    // "Warning", ...) for multi-message boxes - these must still display.
    const { boxCalls, errors } = showBox({ TEXT: "boom", TYPE: "Error" });
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("error");
    expect(errors).toHaveLength(0);
  });

  test("unknown type falls back to show() and logs", () => {
    const { boxCalls, errors } = showBox({ TEXT: "boom", TYPE: "garbage" });
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("show");
    expect(errors).toHaveLength(1);
    expect(errors[0]).toContain("garbage");
  });

  test("a type matching an enum member is not invoked as a function", () => {
    // MessageBox.Action exists but is an enum object, not a display
    // function - the lookup must skip it and fall back to show().
    const { boxCalls } = showBox({ TEXT: "boom", TYPE: "Action" });
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("show");
  });

  test("a message without TEXT shows nothing", () => {
    const { boxCalls } = showBox({ TYPE: "error" });
    expect(boxCalls).toHaveLength(0);
  });
});

test.describe("S_MSG_TOAST", () => {
  test("numeric duration string is parsed, garbage falls back to default", () => {
    const env = loadMessages();
    env.Messages.show(
      "S_MSG_TOAST",
      { S_MSG_TOAST: { TEXT: "hi", DURATION: "250" } },
      null,
    );
    env.Messages.show(
      "S_MSG_TOAST",
      { S_MSG_TOAST: { TEXT: "ho", DURATION: "abc" } },
      null,
    );
    expect(env.toastCalls[0].opts.duration).toBe(250);
    expect(env.toastCalls[1].opts.duration).toBe(3000);
  });
});
