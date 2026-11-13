// @ts-check
const { test, expect } = require("@playwright/test");
const path = require("path");

// tools/app2abap/trans2abap.js - the texts the node serves (the frontend
// bundle, the devtools bundle, the page's script, the control's stylesheet)
// each become ONE ABAP class whose get( ) hands the text back. What it hands
// back is what the browser runs and what the CSP hash is taken over, so it
// has to be the text byte for byte.

const GEN = require(
  path.join(__dirname, "..", "..", "tools", "app2abap", "trans2abap.js"),
);

/** Read the string get( ) builds back out of the generated ABAP: the
 * backtick literals of every part method (a doubled backtick is one)
 * joined in order, |\n| as a newline. */
function abapGetValue(abap) {
  const body = abap.slice(abap.indexOf("METHOD part_01."));
  const re = /`((?:[^`]|``)*)`|\|\\n\|/g;
  let out = "";
  let m;
  while ((m = re.exec(body))) {
    out += m[1] !== undefined ? m[1].replace(/``/g, "`") : "\n";
  }
  return out;
}

const textClass = (text) =>
  GEN.abapTextClass("z2ui5_cl_ui5f_x", text, ["a probe"]);

test("backticks, pipes and braces round-trip through the ABAP literal", () => {
  const src = 'const a = `x${1}|{y}|`;\nconst b = "``";\n';
  expect(abapGetValue(textClass(src))).toBe(src);
});

test("a text is handed back byte for byte, whatever its lines look like", () => {
  const long = `${"x ".repeat(450)}end`;
  for (const text of [
    // a line far beyond ABAP's 255, cut into several literals - blanks at
    // the cuts included
    `first\n${long}\nlast\n`,
    // no line break at the end, and none at all
    "one\ntwo",
    long,
    // empty lines, trailing blanks
    "a  \n\n\n  b\n",
    "",
  ]) {
    expect(abapGetValue(textClass(text))).toBe(text);
  }
});

test("no generated line outgrows ABAP's 255, and no method grows with the text", () => {
  const text = `${"y".repeat(5000)}\n`.repeat(200);
  const abap = textClass(text);
  expect(Math.max(...abap.split("\n").map((l) => l.length))).toBeLessThan(255);
  // 200 lines of 25 literals each: more than one part of 2000
  expect(abap).toContain("METHOD part_03.");
  expect(abap).toContain("result = part_01( ) &&");
  expect(abapGetValue(abap)).toBe(text);
});

// The proof stripJsComments runs, checked on its own: stripJsComments
// itself needs the app toolchain (bundle/node_modules/prettier), which the
// JS unit job does not install - npm run check:app2abap covers that path
// over every real file.
test("trailing whitespace inside a template literal is refused, not silently dropped", () => {
  // the embedded copy strips every line's trailing blanks - inside a
  // template literal they are part of the string, so the program changes
  const src = "const s = `a  \nb`;\n";
  expect(() =>
    GEN.assertSameProgram(src, GEN.embeddedValue(src, false), "probe.js"),
  ).toThrow(/embedding changed the program/);
});

test("trailing blanks outside a literal are dropped and accepted", () => {
  const src = "const s = 1;   \nconst t = `a\nb`;\n";
  const value = GEN.embeddedValue(src, false);
  expect(value).not.toContain("1;   ");
  expect(() => GEN.assertSameProgram(src, value, "probe.js")).not.toThrow();
});

// The developer tools are split in two at generation time: the eager half
// stays in the shell's script, the rest is the devtools bundle
// (DEVTOOLS_EAGER). A module of the shell that named a bundled one as a
// sap.ui.define dependency would be fetched from the ICF node - which
// answers every GET with the page - and take the component down, so the
// generation refuses it.
test.describe("the devtools bundle split", () => {
  test("the facade, the capture, the recorder and their leaves stay eager", () => {
    for (const eager of [
      "devtools/DevTools.js",
      "devtools/Console.js",
      "devtools/Recorder.js",
      "devtools/Persist.js",
      "devtools/Format.js",
      "devtools/Diff.js",
    ]) {
      expect(GEN.isDeferredDevtools(eager), eager).toBe(false);
    }
    for (const deferred of [
      "devtools/DeveloperTools.js",
      "devtools/DeveloperTools.fragment.xml",
      "devtools/Inspect.js",
      "devtools/Tabs.js",
      "devtools/Picker.js",
    ]) {
      expect(GEN.isDeferredDevtools(deferred), deferred).toBe(true);
    }
    expect(GEN.isDeferredDevtools("core/Lib.js")).toBe(false);
    expect(GEN.isDeferredDevtools("Component.js")).toBe(false);
  });

  test("reads the sap.ui.define dependencies of a module", () => {
    expect(
      GEN.defineDependencies(
        'sap.ui.define(\n  ["z2ui5/core/Lib", \'sap/m/Button\'],\n  (Lib, Button) => {},\n);',
      ),
    ).toEqual(["z2ui5/core/Lib", "sap/m/Button"]);
    expect(GEN.defineDependencies("sap.ui.define([], () => {});")).toEqual([]);
    expect(GEN.defineDependencies("const x = 1;")).toEqual([]);
  });

  test("refuses a module outside the bundle that depends on one inside it", () => {
    const sources = new Map([
      ["devtools/DevTools.js", 'sap.ui.define(["z2ui5/core/Lib", "z2ui5/devtools/Console"], () => {});'],
      // a bundled module may depend on another bundled one, and on the shell
      ["devtools/Tabs.js", 'sap.ui.define(["z2ui5/devtools/Inspect", "z2ui5/core/Lib"], () => {});'],
    ]);
    expect(() => GEN.assertNoEagerDependencyOnDeferred(sources)).not.toThrow();
    sources.set(
      "devtools/DevTools.js",
      'sap.ui.define(["z2ui5/core/Lib", "z2ui5/devtools/DeveloperTools"], () => {});',
    );
    expect(() => GEN.assertNoEagerDependencyOnDeferred(sources)).toThrow(
      /devtools\/DevTools\.js: sap\.ui\.define names z2ui5\/devtools\/DeveloperTools/,
    );
  });

  test("the shipped sources pass the guard", () => {
    const fs = require("fs");
    const webapp = path.join(__dirname, "..", "..", "bundle", "webapp");
    const sources = new Map();
    const walk = (dir) => {
      for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) walk(full);
        else if (entry.name.endsWith(".js")) {
          sources.set(path.relative(webapp, full).split(path.sep).join("/"), fs.readFileSync(full, "utf8"));
        }
      }
    };
    walk(webapp);
    expect(sources.has("devtools/DevTools.js")).toBe(true);
    expect(() => GEN.assertNoEagerDependencyOnDeferred(sources)).not.toThrow();
  });
});
