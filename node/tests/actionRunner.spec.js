// @ts-check
const { test, expect } = require("@playwright/test");
const { loadModule } = require("./loadModule");
const { loadLib } = require("./loadLibModule");

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
        // the shipped parser: runCustom resolves the `${/X}` arguments of a
        // handler-queued action with it
        bindingPathOf: loadLib().Lib.bindingPathOf,
      },
      // the framework model of the calling view, as the runner reads it
      "z2ui5/core/ViewSlots": { trackedModel: (view) => view?.__tracked },
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

// ---------------------------------------------------------------------
// A bound value as an argument. Wired into a VIEW, `${/X}` is an expression
// binding UI5 evaluates when the view is built, so the handler receives the
// value. Queued from a HANDLER the action is data (T_CUSTOM), and every
// action used to receive the literal string "${/X}" - the title showed it,
// the clipboard copied it, a filter searched for it. The runner reads it
// from the framework model now, once for every action, so the same call
// means the same in both places.
// ---------------------------------------------------------------------
test.describe("runCustom resolves bound arguments", () => {
  // every frontend action of z2ui5_if_client=>cs_event that runs in the
  // browser, under its wire name, plus the system names an app can reach
  const ACTIONS = [
    "CROSS_APP_NAV_TO_EXT",
    "CROSS_APP_NAV_TO_PREV_APP",
    "SET_SIZE_LIMIT",
    "SET_ODATA_MODEL",
    "CLIPBOARD_COPY",
    "SET_TITLE",
    "SET_TITLE_LAUNCHPAD",
    "SET_FAVICON",
    "SET_FOCUS",
    "SCROLL_TO",
    "SCROLL_INTO_VIEW",
    "START_TIMER",
    "SYSTEM_LOGOUT",
    "KEYBOARD_SHORTCUT",
    "OPEN_NEW_TAB",
    "LOCATION_RELOAD",
    "DOWNLOAD_B64_FILE",
    "URLHELPER",
    "STORE_DATA",
    "PLAY_AUDIO",
    "SMART_VARIANT_INIT",
    "FILTER_BAR_VARIANT_INIT",
    "CONTROL_BY_ID",
    "CONTROL_GLOBAL",
    "BINDING_CALL",
    "BIND_ELEMENT",
    "HASH_BACK",
  ];

  function controllerWithModel(data) {
    const calls = [];
    const model = { getProperty: (path) => data[path] };
    return {
      calls,
      eF: (...args) => calls.push(args),
      getView: () => ({ __tracked: model }),
    };
  }

  for (const action of ACTIONS) {
    test(`${action}: a \${/X} argument from a handler arrives as the bound value`, () => {
      const FrontendAction = loadFrontendAction();
      const oController = controllerWithModel({
        "/S_DATA": { NAME: "n", T_ROWS: [{ A: 1 }] },
        "/T_ROWS": [{ A: 1 }, { A: 2 }],
        "/LV_TEXT": "bound text",
        "/LV_NUM": 7,
        "/LV_FLAG": false,
      });

      FrontendAction.runCustom(
        [
          action,
          "plain",
          "${/S_DATA}",
          "${/T_ROWS}",
          "${ /LV_TEXT }",
          "${http>/LV_NUM}",
          "${/LV_FLAG}",
        ],
        oController,
      );

      expect(oController.calls).toEqual([
        [
          action,
          "plain",
          { NAME: "n", T_ROWS: [{ A: 1 }] },
          [{ A: 1 }, { A: 2 }],
          "bound text",
          7,
          false,
        ],
      ]);
    });
  }

  test("only the expression-binding spelling is read - every other text stays", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerWithModel({ "/X": "bound" });

    FrontendAction.runCustom(
      [
        "PLAY_AUDIO",
        // a URL, a hash, a _bind( ) without $, a relative and an event
        // parameter binding, a binding inside text, an expression
        "/X",
        "{/X}",
        "${X}",
        "${$parameters>/value}",
        "see ${/X}",
        "${/X} === 'a'",
      ],
      oController,
    );

    expect(oController.calls).toEqual([
      [
        "PLAY_AUDIO",
        "/X",
        "{/X}",
        "${X}",
        "${$parameters>/value}",
        "see ${/X}",
        "${/X} === 'a'",
      ],
    ]);
  });

  test("nothing bound at the path is logged and the argument kept", () => {
    const errors = [];
    const FrontendAction = loadFrontendAction({
      "z2ui5/core/Lib": {
        logError: (m) => errors.push(m),
        runCallbacks: () => {},
        isControllerAlive: () => true,
        bindingPathOf: loadLib().Lib.bindingPathOf,
      },
    });
    const oController = controllerWithModel({});

    FrontendAction.runCustom(["SET_TITLE", "${/NOPE}"], oController);

    expect(oController.calls).toEqual([["SET_TITLE", "${/NOPE}"]]);
    expect(errors).toEqual([
      "FrontendAction: 'SET_TITLE' - nothing bound at '${/NOPE}', passed on as text",
    ]);
  });

  test("the action name itself is never read as a path", () => {
    const FrontendAction = loadFrontendAction();
    const oController = controllerWithModel({ "/X": "bound" });

    FrontendAction.runCustom(["${/X}", "a"], oController);

    expect(oController.calls).toEqual([["${/X}", "a"]]);
  });
});
