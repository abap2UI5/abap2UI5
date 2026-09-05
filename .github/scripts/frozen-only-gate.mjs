#!/usr/bin/env node
/*
 * Gate: nothing in src/00 - src/02 may call a symbol marked FROZEN-ONLY.
 *
 * `z2ui5_cl_ui5_util_context` is the single door to every system and platform
 * call (AGENTS.md, "Utilities"), and 23 of its public symbols exist for one
 * reason only: the frozen `src/99` package still calls them on real systems.
 * They carry
 *
 *     " FROZEN-ONLY: no caller in src/00 - src/02, kept for src/99
 *
 * and the class header says what that buys - when `src/99` finally goes, every
 * FROZEN-ONLY symbol goes with it, in one change, without reading 2,600 lines
 * again to work out which. AGENTS.md says "do not add new callers on them".
 *
 * Nothing enforced it. A framework method reaching for `conv_encode_x_base64`
 * or `itab_filter_by_val` compiles, lints, transpiles and passes every gate -
 * and the only sign that the removal plan just got a new blocker would be the
 * marker still sitting above a symbol that is no longer frozen-only. That is
 * exactly the shape of claim that rots: prose about which code calls which,
 * true when it was written.
 *
 * What is reported:
 *
 *   - a reference from any .abap under src/00, src/01 or src/02 outside the
 *     declaring class's own files. Every FROZEN-ONLY symbol is CLASS-DATA or a
 *     CLASS-METHOD, so a caller elsewhere writes `<class>=>name`.
 *   - a reference from a NON-frozen method of the declaring class itself.
 *     A frozen method calling another one is not a finding - they are one
 *     removal unit, and `boolean_check_by_data` calls `boolean_check_by_name`
 *     today - but a live method reaching into the set is the same defect from
 *     inside.
 *
 * What is not:
 *
 *   - `src/99`, which is the whole point of the markers.
 *   - the declaration itself and the METHOD line that implements it.
 *   - `class_constructor`, which fills every CLASS-DATA of the class including
 *     the marked ones. That is the declaration's own initialisation, not a
 *     consumer, and it goes with the symbol.
 *   - `*.testclasses.abap`. A test asserting what a frozen symbol does is
 *     coverage, not a caller: it ships with the symbol, goes with it, and
 *     removing the tests to satisfy this gate would be the exact trade
 *     AGENTS.md forbids everywhere else.
 *
 * The marker is also the input, so this gate cannot be satisfied by deleting
 * the comment: dropping a marker without dropping the symbol is a claim that
 * the symbol is part of the framework's utility surface, which is a decision a
 * reviewer sees in the diff.
 *
 * Run: node .github/scripts/frozen-only-gate.mjs   (npm run check:frozen-only)
 */
import { fileURLToPath } from "url";
import { readFileSync } from "node:fs";
import { basename } from "node:path";
import { walk } from "./lib/walk.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const MARKER = "FROZEN-ONLY:";
const SCOPE = [/^src\/00\//, /^src\/01\//, /^src\/02\//];

/* The declaration the marker sits above. A `"` comment line between the two
 * is normal - several symbols carry a paragraph of their own first. */
const DECLARATION =
  /^\s*(?:CLASS-METHODS|METHODS|CLASS-DATA|DATA|CONSTANTS|TYPES)\s+([a-z_0-9]+)/i;

const files = walk(ROOT, "src")
  .filter((f) => f.endsWith(".abap"))
  .filter((f) => SCOPE.some((re) => re.test(f)))
  .sort();

/* Test classes are scanned for markers (they carry none today) but never for
 * callers - see the header. */
const isTestClass = (f) => f.endsWith(".testclasses.abap");

/* The class's own initialisation of its CLASS-DATA. */
const SETUP_METHOD = "class_constructor";

/* Step 1: collect the marked symbols, per declaring class. */
const marked = new Map(); // symbol -> { file, class, line }
const sources = new Map();

for (const file of files) {
  const text = readFileSync(ROOT + file, "utf8");
  sources.set(file, text);
  if (!text.includes(MARKER)) continue;
  const lines = text.split("\n");
  const cls = basename(file).replace(/\.clas\..*$/, "");
  lines.forEach((line, i) => {
    if (!line.includes(MARKER)) return;
    let j = i + 1;
    while (j < lines.length && (!lines[j].trim() || /^\s*"/.test(lines[j]))) j += 1;
    const m = DECLARATION.exec(lines[j] ?? "");
    if (!m) {
      console.error(
        `frozen-only: ${file}:${i + 1}: the marker sits above no declaration`
        + `\n    ${(lines[j] ?? "").trim()}`
        + "\n    put it directly above the CLASS-METHODS / CLASS-DATA line it marks",
      );
      process.exit(1);
    }
    marked.set(m[1].toLowerCase(), { file, cls, line: i + 1 });
  });
}

if (marked.size === 0) {
  console.log("frozen-only: no FROZEN-ONLY marker in src/00 - src/02 - nothing to guard");
  process.exit(0);
}

/* Step 2: which methods of a declaring class are themselves frozen - a call
 * between two of them is one removal unit, not a new caller. */
const ownerFiles = new Set([...marked.values()].map((m) => m.file));

/* Code only: a name inside a comment or a string literal is not a call. */
function stripNoise(line) {
  if (/^\s*[*]/.test(line)) return "";
  let out = "";
  let quote = null;
  for (const c of line) {
    if (quote) {
      if (c === quote) quote = null;
      continue;
    }
    if (c === "`" || c === "'") {
      quote = c;
      continue;
    }
    if (c === '"') break;
    out += c;
  }
  return out;
}

const NAMES = new RegExp(`\\b(${[...marked.keys()].join("|")})\\b`, "gi");
// a trailing comment after the period is still the same statement
const METHOD_START = /^\s*METHOD\s+([a-z_0-9~]+)\s*\.\s*(?:".*)?$/i;

const findings = [];

for (const file of files) {
  if (isTestClass(file)) continue;
  const text = sources.get(file);
  if (!NAMES.test(text)) {
    NAMES.lastIndex = 0;
    continue;
  }
  NAMES.lastIndex = 0;

  const own = ownerFiles.has(file);
  // A class's test classes and locals live in sibling files of the same stem;
  // treat them as the class's own, since they ship and go with it.
  const stem = basename(file).replace(/\.clas\..*$/, "");
  const ownStem = [...marked.values()].some((m) => m.cls === stem);

  const lines = text.split("\n");
  let inMethod = null;

  lines.forEach((raw, i) => {
    const start = METHOD_START.exec(raw);
    if (start) inMethod = start[1].toLowerCase();
    else if (/^\s*ENDMETHOD\b/i.test(raw)) inMethod = null;

    const code = stripNoise(raw);
    if (!code) return;

    for (const m of code.matchAll(NAMES)) {
      const name = m[1].toLowerCase();
      const owner = marked.get(name);

      if (own || ownStem) {
        // The declaration itself, and the METHOD line that implements it.
        if (inMethod === name || start) continue;
        // One frozen symbol reaching for another is the same removal unit.
        if (inMethod && marked.has(inMethod)) continue;
        // class_constructor fills every CLASS-DATA the class declares.
        if (inMethod === SETUP_METHOD) continue;
        // Outside any method body: the declaration block and the class header.
        if (!inMethod) continue;
        findings.push({
          file,
          line: i + 1,
          name,
          text: raw.trim(),
          why: `\`${inMethod}( )\` is not FROZEN-ONLY, so this is a live caller`,
        });
        continue;
      }

      findings.push({
        file,
        line: i + 1,
        name,
        text: raw.trim(),
        why: `declared FROZEN-ONLY at ${owner.file}:${owner.line}`,
      });
    }
  });
}

console.log(
  `frozen-only: ${marked.size} marked symbol(s), ${files.length} file(s) in src/00 - src/02 checked`,
);

if (findings.length === 0) {
  console.log("no live caller on a FROZEN-ONLY symbol - OK");
  process.exit(0);
}

console.error(`\n${findings.length} problem(s):`);
for (const f of findings) {
  console.error(`  ${f.file}:${f.line}: references \`${f.name}\``);
  console.error(`    ${f.text}`);
  console.error(`    ${f.why}`);
}
console.error(
  "\nA FROZEN-ONLY symbol survives only because the frozen src/99 package still"
  + "\ncalls it, and goes when src/99 goes (AGENTS.md, \"Utilities\"). Solve the"
  + "\nproblem without it, or - if the framework genuinely needs it - drop the"
  + "\nmarker in the same change and say in the pull request why the symbol is"
  + "\npart of the utility surface after all.",
);
process.exit(1);
