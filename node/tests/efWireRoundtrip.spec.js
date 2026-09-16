// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");
const { loadModule } = require("./loadModule");

// ---------------------------------------------------------------------
// The eF( ) wire, end to end, with BOTH real implementations.
//
// An argument the backend puts into a follow-up action is escaped by
// z2ui5_cl_ui5_srv_event=>escape_js_string (the backslash, the single quote,
// and the line breaks it rewrites to \n / \r) and read back by
// core/actions/LegacyCustomJs's parseEfArgs. The two are each other's
// inverse, and each side is pinned on its own: the ABAP suite against wire
// strings written by hand, actionRunner.spec.js against the same strings
// written by hand again.
//
// Hand-written on both sides is the gap. Change one escape, change the
// fixture next to it, and both suites stay green while the other side -
// untouched - now reads that wire wrongly. So this spec runs the REAL
// backend into the REAL frontend parser and asserts that what comes out is
// what went in. Nothing about the wire format is written down here, which is
// the whole point: it cannot be updated to match a regression.
// ---------------------------------------------------------------------

const OUTPUT = path.join(__dirname, "..", "output", "init.mjs");
const HELPER = path.join(__dirname, "helpers", "efWire.mjs");

// `npm run check:js` is meant to run on a tree that was never transpiled
// (node/output is built by `npm run downport && npm run auto_transpile` and
// is not in the repository), so this one spec skips instead of failing.
test.skip(
  !fs.existsSync(OUTPUT),
  "needs the transpiled backend: npm run downport && npm run auto_transpile",
);

// Everything escape_js_string names, everything next to it, and the shapes
// that broke the parser before: a trailing backslash, an escaped backslash
// followed by an "n", a lone CR.
const VALUES = [
  "plain",
  "it's here",
  "it's \\ both",
  "C:\\new",
  "\\\\server\\share",
  "ends with a backslash\\",
  "'",
  "\\",
  "\\'",
  "'\\",
  "line1\nline2",
  "line1\rline2",
  "tab\there",
  '"double quoted"',
  "{binding}",
  "$expression",
  ".eB('NESTED')",
  "a,b,c",
  "(paren) [bracket] {brace}",
  "\u00fcml\u00e4ut \u2013 \u2713",
  "</script>",
  "x".repeat(2000),
];

// The REAL backend builds the snippets, in a child process - helpers/efWire.mjs
// says why it cannot run inside this one.
function backendSnippets(argumentLists) {
  return JSON.parse(
    execFileSync(process.execPath, [HELPER], {
      input: JSON.stringify(argumentLists),
      encoding: "utf8",
      maxBuffer: 16 * 1024 * 1024,
    }),
  );
}

// FrontendAction with every domain handler map stubbed empty: runCustom and
// the LegacyCustomJs parser under it are the units here, so eF( ) is recorded
// rather than dispatched.
function loadFrontendAction() {
  const noHandlers = { handlers: {} };
  const { module } = loadModule("core/FrontendAction.js", {
    autoLoad: true,
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
    },
  });
  return module;
}

test.describe("the eF( ) wire, backend to frontend", () => {
  test("every argument arrives as it was sent", () => {
    const FrontendAction = loadFrontendAction();
    const snippets = backendSnippets(VALUES.map((v) => [v]));

    VALUES.forEach((value, i) => {
      const calls = [];
      FrontendAction.runCustom(snippets[i], {
        eF: (...args) => calls.push(args),
      });

      expect(calls, `no dispatch for ${JSON.stringify(value)}`).toHaveLength(1);
      expect(calls[0]).toEqual(["TEST_EVENT", value]);
    });
  });

  test("an empty argument between two filled ones keeps its position", () => {
    const FrontendAction = loadFrontendAction();
    const [snippet] = backendSnippets([["first", "", "third"]]);

    const calls = [];
    FrontendAction.runCustom(snippet, { eF: (...args) => calls.push(args) });

    expect(calls).toEqual([["TEST_EVENT", "first", "", "third"]]);
  });

  test("a trailing empty argument is dropped, not sent as an empty one", () => {
    const FrontendAction = loadFrontendAction();
    const [snippet] = backendSnippets([["first", ""]]);

    const calls = [];
    FrontendAction.runCustom(snippet, { eF: (...args) => calls.push(args) });

    // the backend's documented positional trim, stated here because the round
    // trip above would otherwise read as "everything survives"
    expect(calls).toEqual([["TEST_EVENT", "first"]]);
  });
});
