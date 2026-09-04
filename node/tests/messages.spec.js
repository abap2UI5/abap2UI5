// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests the MESSAGE_TOAST / MESSAGE_BOX display path shipped in
// app/webapp/core/actions/ControlCall.js, driven through the same
// CONTROL_GLOBAL dispatch a backend action arrives on. The options travel as
// the call's last argument, a plain object already carrying the UI5 option
// names: the backend sends only what the app set, so anything absent here is
// absent because the app left it alone.

function loadControlCall(sandbox) {
  const boxCalls = [];
  const toastCalls = [];
  const errors = [];
  const ebCalls = [];
  const boxFn = (name) => (text, params) => {
    boxCalls.push({ name, text, params });
    // UI5 builds the dialog and its content synchronously inside show( ),
    // before the opening animation - which is what lets showBox reach the
    // details right after the call returns
    if (params?.details) openDialog(params.id);
  };
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
  // The message boxes this stub "opens": showBox gives a box with details an
  // id and reaches back for it through Lib.getElementById, exactly as it does
  // against a real MessageBox - so the stub answers with the layout UI5
  // builds, [message, "Show details" link, FormattedText(hidden)].
  const dialogs = {};
  const control = (type, visible) => ({
    type,
    visible,
    isA: (sType) => sType === type,
    setVisible(bVisible) {
      this.visible = bVisible;
    },
  });
  const openDialog = (sId) => {
    const items = [
      control("sap.m.Text", true),
      control("sap.m.Link", true),
      control("sap.m.FormattedText", false),
    ];
    dialogs[sId] = { items, getContent: () => [{ getItems: () => items }] };
    return dialogs[sId];
  };
  const Lib = {
    logError: (message) => errors.push(message),
    sanitizeMessageDetails: (html) => `sanitized:${html}`,
    whenRendered: (_control, _owner, fn) => fn(),
    getElementById: (sId) => dialogs[sId] || null,
  };
  // ViewSlots.resolveById maps a control id to its element for the
  // dependentOn option. Only "knownId" resolves here.
  const elements = { knownId: { id: "knownId" } };
  const ViewSlots = {
    resolveById: (sId) => elements[sId] || null,
    byId: () => null,
    getView: () => null,
  };
  const { module } = loadModule("core/actions/ControlCall.js", {
    // MessageToast is no longer a define-dependency: the module requires it
    // lazily at factory time (Popup.Dock capture order), so the stub arrives
    // through a seeded sap.ui.require instead of the deps map
    sandbox: {
      ...(sandbox || {}),
      sap: {
        ui: {
          require: (vDep, fnCb) => {
            if (Array.isArray(vDep) && vDep[0] === "sap/m/MessageToast" && fnCb)
              fnCb(MessageToast);
            return null;
          },
        },
      },
    },
    deps: {
      "sap/m/MessageBox": MessageBox,
      "sap/ui/core/BusyIndicator": {},
      "sap/ui/model/Filter": function () {},
      "sap/ui/model/FilterOperator": {},
      "sap/ui/model/Sorter": function () {},
      "z2ui5/core/Router": {},
      "z2ui5/core/Lib": Lib,
      "z2ui5/core/ViewSlots": ViewSlots,
    },
  });
  const oController = { eB: (...args) => ebCalls.push(args) };
  // dispatch exactly like a backend action: the options object is the call's
  // last argument and arrives already parsed
  const dispatch = (target, method, text, mOptions) => {
    const args = ["CONTROL_GLOBAL", target, method, text];
    if (mOptions) args.push(mOptions);
    module.handlers.CONTROL_GLOBAL(oController, args);
  };
  return { dispatch, boxCalls, toastCalls, errors, ebCalls, elements, dialogs };
}

function showBox(sType, mOptions) {
  const env = loadControlCall();
  env.dispatch("MESSAGE_BOX", sType, "boom", mOptions);
  return env;
}

test.describe("message box type resolution", () => {
  test("the type selects the matching MessageBox method", () => {
    const { boxCalls, errors } = showBox("error");
    expect(boxCalls).toHaveLength(1);
    expect(boxCalls[0].name).toBe("error");
    expect(boxCalls[0].text).toBe("boom");
    expect(errors).toHaveLength(0);
  });

  test("a type the whitelist does not carry is rejected", () => {
    // the backend guarantees a MessageBox display method (falls back to
    // `show` itself), so an unknown type can only be a forged payload - the
    // CONTROL_GLOBAL whitelist rejects it like any other unlisted method
    const { boxCalls, errors } = showBox("garbage");
    expect(boxCalls).toHaveLength(0);
    expect(errors).toHaveLength(1);
    expect(errors[0]).toContain("garbage");
  });
});

test.describe("message box options", () => {
  test("options are forwarded untouched", () => {
    const { boxCalls } = showBox("show", { contentWidth: "20rem" });
    expect(boxCalls[0].params.contentWidth).toBe("20rem");
  });

  test("no options at all means a bare call - UI5 owns every default", () => {
    const { boxCalls } = showBox("show");
    expect(boxCalls[0].params).toBeUndefined();
  });

  test("details are sanitized", () => {
    const { boxCalls } = showBox("show", { details: "<b>x</b>" });
    expect(boxCalls[0].params.details).toBe("sanitized:<b>x</b>");
  });

  test("details are shown at once - no 'Show details' to click", () => {
    // sap.m.MessageBox hides the details behind a link and has no option that
    // opens them. What message_box_display( ) renders out of a table or a
    // structure IS the message, so the box arrives with them unfolded.
    const { boxCalls, dialogs } = showBox("show", { details: "<ul><li>x</li></ul>" });

    const items = dialogs[boxCalls[0].params.id].items;
    expect(items.find((i) => i.type === "sap.m.FormattedText").visible).toBe(true);
    // ... and the link that would have revealed them is gone with them
    expect(items.find((i) => i.type === "sap.m.Link").visible).toBe(false);
  });

  test("a box without details is not given an id and opens untouched", () => {
    const { boxCalls } = showBox("show", { contentWidth: "20rem" });
    expect(boxCalls[0].params.id).toBeUndefined();
  });

  test("an id the caller set is kept - the box stays in its own reach", () => {
    const { boxCalls } = showBox("show", { details: "<p>x</p>", id: "myBox" });
    expect(boxCalls[0].params.id).toBe("myBox");
  });

  test("a layout the expand does not recognize leaves the box alone", () => {
    // a UI5 release that lays the details out differently must degrade to the
    // collapsed box, not throw inside the display path
    const env = loadControlCall();
    env.dispatch("MESSAGE_BOX", "show", "boom", { details: "<p>x</p>" });
    expect(env.errors).toEqual([]);
    expect(env.boxCalls).toHaveLength(1);
  });

  test("dependentOn resolves a control id to its element", () => {
    const { boxCalls, elements } = showBox("show", { dependentOn: "knownId" });
    expect(boxCalls[0].params.dependentOn).toBe(elements.knownId);
  });

  test("an unresolvable dependentOn id drops the option", () => {
    // dependentOn was the only option, so dropping it leaves no options at
    // all and the box falls back to the bare per-method call
    const { boxCalls } = showBox("show", { dependentOn: "missingId" });
    expect(boxCalls[0].params?.dependentOn).toBeUndefined();
  });

  test("onClose round-trips the event with the pressed action", () => {
    const { boxCalls, ebCalls } = showBox("confirm", { onClose: "ANSWERED" });
    boxCalls[0].params.onClose("OK");
    // the pressed action rides OUTSIDE the event array - inside it, it would
    // be shifted away with the array and never reach T_EVENT_ARG
    expect(ebCalls).toEqual([[["ANSWERED"], "OK"]]);
  });
});

test.describe("message toast", () => {
  test("options are forwarded untouched", () => {
    const env = loadControlCall();
    env.dispatch("MESSAGE_TOAST", "show", "hi", { duration: 250 });
    expect(env.toastCalls[0].text).toBe("hi");
    expect(env.toastCalls[0].opts.duration).toBe(250);
  });

  test("no options means a bare show() - UI5 applies its own defaults", () => {
    const env = loadControlCall();
    env.dispatch("MESSAGE_TOAST", "show", "hi");
    expect(env.toastCalls[0].opts).toBeUndefined();
  });

  test("class lands on the toast DOM node, not in the options", () => {
    // `class` is no MessageToast option: it is applied to the newest toast's
    // DOM node afterwards, so passing it on would be an unknown option.
    const added = [];
    const toastEl = { classList: { add: (...c) => added.push(...c) } };
    const env = loadControlCall({
      document: { querySelectorAll: () => [toastEl] },
    });
    env.dispatch("MESSAGE_TOAST", "show", "hi", { class: "a b" });
    expect(env.toastCalls[0].opts).toBeUndefined();
    expect(added).toEqual(["a", "b"]);
  });

  test("onClose round-trips the event", () => {
    const env = loadControlCall();
    env.dispatch("MESSAGE_TOAST", "show", "hi", { onClose: "CLOSED" });
    env.toastCalls[0].opts.onClose();
    expect(env.ebCalls).toEqual([[["CLOSED"]]]);
  });
});
