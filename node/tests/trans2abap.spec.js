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
const WEBAPP_FILE = path.join(
  __dirname,
  "..",
  "..",
  "app",
  "webapp",
  "probe.js",
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
