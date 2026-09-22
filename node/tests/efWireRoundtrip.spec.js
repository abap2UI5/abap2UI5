// @ts-check
const { test, expect } = require("@playwright/test");
const fs = require("fs");
const path = require("path");
const vm = require("vm");
const { execFileSync } = require("child_process");

// ---------------------------------------------------------------------
// The eF( ) wire, end to end, with BOTH real implementations.
//
// An argument the backend wires into a view event handler is escaped by
// z2ui5_cl_ui5_srv_event=>escape_js_string (the backslash, the single quote,
// and the line breaks it rewrites to \n / \r) and read back as a JavaScript
// string literal - by UI5's event-handler parser, which follows the
// JavaScript literal rules. The ABAP suite pins the escaping against wire
// strings written by hand, and hand-written is the gap: change one escape,
// change the fixture next to it, and the suite stays green while the wire
// no longer reads back as what went in.
//
// So this spec runs the REAL backend and evaluates each snippet as the
// JavaScript expression it claims to be, with eF( ) recorded, and asserts
// that what comes out is what went in. Nothing about the wire format is
// written down here, which is the whole point: it cannot be updated to match
// a regression.
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
  "a,b,c",
  "(paren) [bracket] {brace}",
  "\u00fcml\u00e4ut \u2013 \u2713",
  "</script>",
  "x".repeat(2000),
];

// A value starting with `{` or `$`, or an .eB( / .eF( expression, is NOT a
// string on this wire: the backend hands it over unquoted, for UI5 to
// resolve as a binding or an expression when the view is built.
const RAW = ["{binding}", "$expression", ".eB('NESTED')"];

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

// Evaluates one snippet as JavaScript with eF( ) recorded - the decoding
// end of the round trip. A wired handler is a controller-relative call
// (".eF(...)"), so the leading dot is bound to the recorder.
function decode(snippet) {
  const calls = [];
  const self = { eF: (...args) => calls.push(args) };
  vm.runInNewContext(snippet.trim().replace(/^\./, "self."), { self });
  return calls;
}

test.describe("the eF( ) wire, backend to frontend", () => {
  test("every argument arrives as it was sent", () => {
    const snippets = backendSnippets(VALUES.map((v) => [v]));

    VALUES.forEach((value, i) => {
      const calls = decode(snippets[i]);

      expect(calls, `no dispatch for ${JSON.stringify(value)}`).toHaveLength(1);
      expect(calls[0]).toEqual(["TEST_EVENT", value]);
    });
  });

  test("a binding or an expression travels unquoted, as written", () => {
    const snippets = backendSnippets(RAW.map((v) => [v]));

    RAW.forEach((value, i) => {
      expect(snippets[i]).toContain(`, ${value})`);
    });
  });

  test("an empty argument between two filled ones keeps its position", () => {
    const [snippet] = backendSnippets([["first", "", "third"]]);

    const calls = decode(snippet);

    expect(calls).toEqual([["TEST_EVENT", "first", "", "third"]]);
  });

  test("a trailing empty argument is dropped, not sent as an empty one", () => {
    const [snippet] = backendSnippets([["first", ""]]);

    const calls = decode(snippet);

    // the backend's documented positional trim, stated here because the round
    // trip above would otherwise read as "everything survives"
    expect(calls).toEqual([["TEST_EVENT", "first"]]);
  });
});
