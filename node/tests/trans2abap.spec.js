// @ts-check
const { test, expect } = require("@playwright/test");
const path = require("path");

// tools/app2abap/trans2abap.js - every app/webapp file becomes an ABAP class
// whose get( ) hands the file back. The value it hands back is what the
// browser runs and what the CSP hash is taken over, so it has to be the same
// PROGRAM as the source, byte for byte where it matters.

const GEN = require(
  path.join(__dirname, "..", "..", "tools", "app2abap", "trans2abap.js"),
);

/** Read the string get( ) builds back out of the generated ABAP: backtick
 * literals (a doubled backtick is one) joined, |\n| as a newline. */
function abapGetValue(abap) {
  const body = abap.split("METHOD get.")[1].split("ENDMETHOD.")[0];
  const re = /`((?:[^`]|``)*)`|\|\\n\|/g;
  let out = "";
  let m;
  while ((m = re.exec(body))) {
    out += m[1] !== undefined ? m[1].replace(/``/g, "`") : "\n";
  }
  return out;
}

test("backticks, pipes and braces round-trip through the ABAP literal", () => {
  const src = 'const a = `x${1}|{y}|`;\nconst b = "``";\n';
  const abap = GEN.formatAsAbapClass(src, "z2ui5_cl_ui5f_x", false, "x.js");
  expect(abapGetValue(abap)).toBe(GEN.embeddedValue(src, false));
  expect(abapGetValue(abap)).toBe(`${src}\n`);
});

// The proof stripJsComments runs, checked on its own: stripJsComments
// itself needs the app toolchain (app/node_modules/prettier), which the
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
    const webapp = path.join(__dirname, "..", "..", "app", "webapp");
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
