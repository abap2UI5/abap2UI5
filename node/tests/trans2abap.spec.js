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

test("trailing whitespace inside a template literal is refused, not silently dropped", async () => {
  // the embedded copy strips every line's trailing blanks - inside a
  // template literal they are part of the string, so the program changes
  const src = "const s = `a  \nb`;\n";
  await expect(GEN.stripJsComments(src, WEBAPP_FILE, "probe.js")).rejects.toThrow(
    /embedding changed the program/,
  );
});

test("comments and trailing blanks outside a literal are stripped and accepted", async () => {
  const code = await GEN.stripJsComments(
    "const s = 1;   // note\nconst t = `a\nb`;\n",
    WEBAPP_FILE,
    "probe.js",
  );
  expect(code).not.toContain("note");
});
