// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");

// Tests FrontendAction.runCustom - the follow-up-action path. A backend
// entry is a JSON array ["EVENT", ...args] (the structured form every
// follow-up action travels in - serialized and escaped entirely in ABAP by
// z2ui5_cl_ui5_srv_event=>get_event_client_ajson). Anything else - a raw
// JavaScript string included - is not run.

// Load FrontendAction with every domain handler map stubbed empty (override
// individual maps via `deps`).
function loadFrontendAction(deps = {}, sandbox = {}) {
  const noHandlers = { handlers: {} };
  const { module } = loadModule("core/FrontendAction.js", {
    autoLoad: true,
    sandbox,
    deps: {
      "z2ui5/core/actions/ControlCall": noHandlers,
      "z2ui5/core/actions/Browser": noHandlers,
      "z2ui5/core/actions/Launchpad": noHandlers,
      "z2ui5/core/actions/Variants": noHandlers,
      "z2ui5/core/actions/Shortcuts": noHandlers,
      "z2ui5/core/actions/ViewOps": noHandlers,
      "z2ui5/core/Lib": {
        logError: () => {},
        runCallbacks: () => {},
        isControllerAlive: () => true,
      },
      "z2ui5/core/AppState": { state: { onBeforeEventFrontend: [] } },
      ...deps,
    },
  });
  return module;
}

// Collects the arguments a snippet dispatches to eF( ).
function controllerStub() {
  const calls = [];
  return { calls, eF: (...args) => calls.push(args) };
}

test.describe("runSystem", () => {
  function loadWithHandler(handler) {
    return loadFrontendAction({
      "z2ui5/core/actions/ViewOps": { handlers: { TEST_ACTION: handler } },
    });
  }

  test("runs a real-array action and threads the context through", () => {
    const seen = [];
    const FrontendAction = loadWithHandler((oController, args, ctx) =>
      seen.push([oController, args, ctx]),
    );
    const oController = {};
    FrontendAction.runSystem(["TEST_ACTION", "a1"], oController, { seq: 3 });
    expect(seen).toEqual([[oController, ["TEST_ACTION", "a1"], { seq: 3 }]]);
  });

  test("still parses the stringified form of a skewed backend", () => {
    const seen = [];
    const FrontendAction = loadWithHandler((_c, args) => seen.push(args));
    FrontendAction.runSystem('["TEST_ACTION","a1"]', null, {});
    expect(seen).toEqual([["TEST_ACTION", "a1"]]);
  });
});

test.describe("runCustom structured JSON actions", () => {
  test("dispatches a REAL array as an eF event (the wire form)", () => {
    // the backend embeds framework actions into the response as real nested
    // arrays (z2ui5_cl_ui5_handler=>actions_serialize) - no parse, no escaping
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(["SET_FOCUS", "myInput"], oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("a real array keeps objects and positional empties intact", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
      oController,
    );

    expect(oController.calls).toEqual([
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
    ]);
  });

  test("dispatches a JSON array as an eF event", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // the structured form the backend emits for framework follow-up actions
    // (z2ui5_cl_ui5_srv_event=>get_event_client_ajson): pure data, one
    // JSON.parse, no code parsing
    FrontendAction.runCustom('["SET_FOCUS","myInput"]', oController);

    expect(oController.calls).toEqual([["SET_FOCUS", "myInput"]]);
  });

  test("keeps embedded objects and positional empties intact", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    FrontendAction.runCustom(
      '["CONTROL_BY_ID","tab","","setHiddenInPopin",{"A":1}]',
      oController,
    );

    expect(oController.calls).toEqual([
      ["CONTROL_BY_ID", "tab", "", "setHiddenInPopin", { A: 1 }],
    ]);
  });

  test("special characters survive the JSON round trip", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // the backend JSON-escapes quotes, backslashes and line breaks - they
    // must arrive as the original characters, decoded by JSON.parse alone
    FrontendAction.runCustom(
      '["CLIPBOARD_COPY","line1\\nline2 \\"quoted\\" C:\\\\dir"]',
      oController,
    );

    expect(oController.calls).toEqual([
      ["CLIPBOARD_COPY", 'line1\nline2 "quoted" C:\\dir'],
    ]);
  });

  test("a raw JS expression starting with [ is not misread as an action", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerStub();

    // not a JSON array - JSON.parse fails, so nothing is dispatched
    FrontendAction.runCustom("[1, 2].concat([3]).length", oController);

    expect(oController.calls).toEqual([]);
  });
});

// ---------------------------------------------------------------------
// The CSP boundary. AGENTS.md rule 19: a follow-up action is DATA, never
// code - which is what lets an app run under a Content-Security-Policy
// that does not allow 'unsafe-eval'. No entry may ever reach
// Function/eval, not even a JavaScript string an app handed the backend.
// Pinned here because the regression is invisible at runtime: a snippet
// that starts going through Function still WORKS on a permissive CSP and
// only breaks on the strict one the framework promises to support.
// ---------------------------------------------------------------------
test.describe("runCustom stays clear of eval", () => {
  // Shadows the sandbox's code-constructing globals with counting stubs, so
  // a module that ever called them again would resolve to these.
  function loadCountingEval(deps = {}) {
    const reached = [];
    const FrontendAction = loadFrontendAction(deps, {
      Function: function (...args) {
        reached.push(["Function", String(args[args.length - 1])]);
        return () => {};
      },
      eval: (src) => {
        reached.push(["eval", String(src)]);
      },
    });
    return { FrontendAction, reached };
  }

  test("a structured JSON action never constructs code", () => {
    const { FrontendAction, reached } = loadCountingEval();
    const oController = controllerStub();

    FrontendAction.runCustom(["SET_FOCUS", "myInput"], oController);
    FrontendAction.runCustom('["SET_FOCUS","myInput"]', oController);
    // an argument that spells JavaScript is still just a string argument
    FrontendAction.runCustom('["CLIPBOARD_COPY","alert(1);//"]', oController);

    expect(reached).toEqual([]);
    expect(oController.calls.length).toBe(3);
  });

  test("a raw JavaScript string is not run at all", () => {
    const { FrontendAction, reached } = loadCountingEval();
    const oController = controllerStub();

    FrontendAction.runCustom("alert(1)", oController);
    FrontendAction.runCustom("eF('SET_FOCUS','myInput')", oController);

    expect(reached).toEqual([]);
    expect(oController.calls).toEqual([]);
  });
});
