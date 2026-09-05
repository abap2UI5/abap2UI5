// Gate: a `FOR TESTING` method has to assert something.
//
// Why this exists: a test method with no assertion passes for as long as the
// code it calls does not dump, which is a far weaker claim than the name
// `test_first` makes to the next reader — and a much weaker claim than the
// green run makes to everyone else. It is invisible in a report: 1,071 test
// methods, 1,071 passing, and no way to tell that one of them proved nothing.
// `z2ui5_cl_ui5_app_start`'s `test_first` was exactly that — `factory( )` into
// a `##NEEDED` variable — for as long as the class has existed.
//
// The check is deliberately shallow: it asks only whether the method body
// names `cl_abap_unit_assert`, raises, or hands the decision to a helper of
// its own test class. Anything cleverer would start judging the QUALITY of an
// assertion, which is a review's job.
//
// Scope: this repository's own ABAP. `src/00/01` (AJSON) and `src/00/02`
// (S-RTTI) are upstream mirrors synced by a workflow, and `src/99` is the
// frozen legacy package — a finding in either is not ours to act on, which is
// the same scoping `check:atc` uses.
//
// Run: node .github/scripts/assertion-gate.mjs

import { globSync, readFileSync } from "fs";
import { join } from "path";
import { fileURLToPath } from "url";

// cwd-independent on purpose: run from anywhere, this gate used to answer
// "0 methods, all assert" from a foreign cwd - success over zero files
const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const SKIP = [/^src\/00\/01\//, /^src\/00\/02\//, /^src\/99\//];

/* What counts as making a claim. `assert_*` is the normal form; `abort( )` is
 * the same class and is used in this repository; RAISE/THROW in a test body is
 * a deliberate failure; and a test that delegates to a helper of its own test
 * class (`verify_*`, `assert_*`, `check_*`) asserts through it — the helper is
 * itself a method in the same file and is judged on its own. */
const ASSERTS = /cl_abap_unit_assert|cl_aunit_assert|\bassert\b|\bRAISE\s+(EXCEPTION|SHORTDUMP)\b|\b(verify|assert|check|expect)_\w+\s*\(/i;

/* A method is a test when its DECLARATION carries FOR TESTING. The
 * declaration and the implementation are in different parts of the file, so
 * both are read. */
function testMethodNames(source) {
  const names = new Set();
  for (const m of source.matchAll(/^\s*(?:CLASS-)?METHODS[\s:]+([\w~]+)[^.]*?\bFOR\s+TESTING\b/gim)) {
    names.add(m[1].toLowerCase());
  }
  // the chained form: METHODS: a FOR TESTING, b FOR TESTING.
  for (const chain of source.matchAll(/^\s*(?:CLASS-)?METHODS:\s*([\s\S]*?)\.\s*(?:".*)?$/gim)) {
    for (const part of chain[1].split(",")) {
      const named = part.match(/^\s*([\w~]+)[\s\S]*?\bFOR\s+TESTING\b/i);
      if (named) names.add(named[1].toLowerCase());
    }
  }
  return names;
}

function bodiesOf(source) {
  const bodies = new Map(); // lower-case name -> body text
  // a trailing comment after the period is still the same statement
  const re = /^[ \t]*METHOD[ \t]+([\w~]+)[ \t]*\.[ \t]*(?:".*)?$([\s\S]*?)^[ \t]*ENDMETHOD[ \t]*\.[ \t]*$/gim;
  for (const m of source.matchAll(re)) bodies.set(m[1].toLowerCase(), m[2]);
  return bodies;
}

const findings = [];
let checked = 0;

for (const file of globSync(join(ROOT, "src/**/*.testclasses.abap")).map((f) => f.slice(ROOT.length)).sort()) {
  if (SKIP.some((rx) => rx.test(file))) continue;
  const source = readFileSync(join(ROOT, file), "utf8");
  const tests = testMethodNames(source);
  const bodies = bodiesOf(source);
  for (const name of tests) {
    const body = bodies.get(name);
    if (body === undefined) continue; // declared but not implemented - abaplint's job
    checked++;
    // strip comments first: an assertion named in a comment is not one
    const code = body
      .split("\n")
      .map((line) => (line.trimStart().startsWith("*") ? "" : line.replace(/(^|\s)".*$/, "$1")))
      .join("\n");
    if (!ASSERTS.test(code)) findings.push(`${file} :: ${name}`);
  }
}

if (findings.length) {
  console.error(`A FOR TESTING method has to assert something (${findings.length}):\n`);
  for (const finding of findings) console.error(`  ${finding}`);
  console.error(
    "\nA test that only calls the code proves it does not dump, which is not what its name says."
    + "\nAssert the outcome, or delete the method - a passing report should mean something.",
  );
  process.exit(1);
}

// a floor, not a formality: zero checked methods means the glob found
// nothing (wrong tree, broken pattern), and success over nothing is the
// worse answer - same reasoning as lib/abap-scan.mjs
if (checked === 0) {
  console.error("assertion gate: no FOR TESTING methods found - nothing was checked");
  process.exit(1);
}

console.log(`assertion gate: ${checked} FOR TESTING methods, all of them assert something`);
