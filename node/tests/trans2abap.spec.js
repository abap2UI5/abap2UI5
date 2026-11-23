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

// The proof minifyJs runs, checked on its own; minifyJs itself is below.
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

// The embedded copy of a module: comments and whitespace go, nothing else.
test("minifyJs drops comments and layout and keeps every identifier", () => {
  const src =
    "// a comment\n" +
    "sap.ui.define([], () => {\n" +
    '  "use strict";\n' +
    "  /* a block */\n" +
    "  function longAndTellingName(firstArgument) {\n" +
    "    const localValue = firstArgument + 1;\n" +
    "    return localValue;\n" +
    "  }\n" +
    "  return { longAndTellingName };\n" +
    "});\n";
  const out = GEN.minifyJs(src, "probe.js");
  expect(out).not.toContain("a comment");
  expect(out).not.toContain("a block");
  // one line, and a line break at its end like every embedded file
  expect(out.trimEnd().split("\n")).toHaveLength(1);
  expect(out.endsWith("\n")).toBe(true);
  for (const name of ["longAndTellingName", "firstArgument", "localValue"]) {
    expect(out).toContain(name);
  }
  expect(out).toContain('"use strict"');
  expect(out).toContain("{longAndTellingName}");
  expect(out.length).toBeLessThan(src.length);
});

test("minifyJs keeps a multi-line template literal's text, and what it prints survives the class", () => {
  const src = "const text = `first line\n  second line\n`;\nexport_(text);\n";
  const out = GEN.minifyJs(src, "probe.js");
  // the proof inside minifyJs compared the class's value with the source;
  // here: the value a class of that text hands back is the print itself
  expect(abapGetValue(textClass(out))).toBe(out);
});

test("minifyJs names the file of a source that does not parse", () => {
  expect(() => GEN.minifyJs("const = ;\n", "broken.js")).toThrow(/broken\.js: does not parse/);
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

// The custom controls are the third bundle: every file under cc/, served on
// ?z2ui5-bundle=cc and loaded by core/CustomControls.js when a view names a
// control. About one app in forty uses one, and every page paid for all of
// them. Nothing of them is eager, so no module outside cc/ may name one as
// a sap.ui.define dependency - the loader would ask the node for it before
// the bundle is in.
test.describe("the custom controls bundle split", () => {
  const fs = require("fs");
  const webapp = path.join(__dirname, "..", "..", "bundle", "webapp");

  test("every file under cc/ is deferred, and nothing else is", () => {
    for (const control of fs.readdirSync(path.join(webapp, "cc"))) {
      expect(GEN.isDeferredCc(`cc/${control}`), control).toBe(true);
      expect(GEN.deferredBundleOf(`cc/${control}`), control).toBe("cc");
    }
    // the module that loads them is the frontend bundle's
    expect(GEN.deferredBundleOf("core/CustomControls.js")).toBe(null);
    expect(GEN.deferredBundleOf("core/Lib.js")).toBe(null);
    expect(GEN.deferredBundleOf("Component.js")).toBe(null);
    // the two deferred bundles are two
    expect(GEN.deferredBundleOf("devtools/Tabs.js")).toBe("devtools");
    expect(GEN.deferredBundleOf("devtools/DevTools.js")).toBe(null);
    expect(GEN.isDeferredCc("devtools/Tabs.js")).toBe(false);
  });

  test("the frontend bundle's tail has the place the bundle's version goes", () => {
    // z2ui5/core/CustomControls reads it off the z2ui5/embed module: it is
    // the version the bundle is asked for by, and how the frontend knows
    // there is a bundle to ask for
    const tail = fs.readFileSync(
      path.join(__dirname, "..", "..", "bundle", "tail", "embed.js"),
      "utf8",
    );
    expect(tail).toContain(`ccBundle: "${GEN.CC_VERSION_TOKEN}"`);
    // ...and where it asks: the URL the frontend bundle's own script was
    // loaded from, read while that script runs
    expect(tail).toContain("document.currentScript");
    expect(tail).toContain("bundleUrl: bundleUrl");
  });

  test("refuses a module outside cc/ that depends on a control", () => {
    const sources = new Map([
      // a control depends on the shell, and may depend on another control
      ["cc/Dirty.js", 'sap.ui.define(["z2ui5/core/Lib", "z2ui5/core/Context"], () => {});'],
      ["cc/InputExt.js", 'sap.ui.define(["sap/m/Input", "z2ui5/cc/Dirty"], () => {});'],
      // the shell talks to a control through the one-id probe, never a dependency
      ["Component.js", 'sap.ui.define(["z2ui5/core/Lib"], () => { sap.ui.require("z2ui5/cc/Dirty"); });'],
    ]);
    expect(() => GEN.assertNoEagerDependencyOnDeferred(sources)).not.toThrow();
    sources.set(
      "Component.js",
      'sap.ui.define(["z2ui5/core/Lib", "z2ui5/cc/Dirty"], () => {});',
    );
    expect(() => GEN.assertNoEagerDependencyOnDeferred(sources)).toThrow(
      /Component\.js: sap\.ui\.define names z2ui5\/cc\/Dirty, a module of the custom controls bundle/,
    );
  });

  test("refuses a dependency between the two deferred bundles, either way", () => {
    // the developer tools open on a page that never loaded the controls,
    // and a view with a control builds on a page that never opened the tools
    expect(() =>
      GEN.assertNoEagerDependencyOnDeferred(
        new Map([["devtools/Inspect.js", 'sap.ui.define(["z2ui5/cc/Tree"], () => {});']]),
      ),
    ).toThrow(/devtools\/Inspect\.js: sap\.ui\.define names z2ui5\/cc\/Tree/);
    expect(() =>
      GEN.assertNoEagerDependencyOnDeferred(
        new Map([["cc/Tree.js", 'sap.ui.define(["z2ui5/devtools/Inspect"], () => {});']]),
      ),
    ).toThrow(/cc\/Tree\.js: sap\.ui\.define names z2ui5\/devtools\/Inspect, a module of the devtools bundle/);
    // the eager half of the tools is the frontend bundle's - a control may name it
    expect(() =>
      GEN.assertNoEagerDependencyOnDeferred(
        new Map([["cc/Tree.js", 'sap.ui.define(["z2ui5/devtools/Format"], () => {});']]),
      ),
    ).not.toThrow();
  });
});
