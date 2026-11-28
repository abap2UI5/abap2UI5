#!/usr/bin/env node
// vendor-mirror - copies ajson and S-RTTI from the mirror repositories of
// abap-util into this repository, under this repository's own names.
//
//   node .github/scripts/vendor-mirror.mjs                  clone the mirrors, write the copy
//   node .github/scripts/vendor-mirror.mjs --check          clone, compare, write nothing
//   node .github/scripts/vendor-mirror.mjs <dir> [<dir>]    the same from local checkouts,
//                                                           in the order of the config
//
// What is copied, and under which name, is .github/vendor-mirror.json:
//
//   segment    every name is z2ui5_cl_<segment>_..., z2ui5_if_<segment>_...
//              or z2ui5_cx_<segment>_... - the repository's own object naming
//   maxLength  the longest name allowed: the namespace rename of the
//              repository adds up to 5 characters to the 30 of ABAP
//   tests      false leaves the copy's unit tests out (they run in the mirror
//              and in abap-util) - the test classes go, and the XML no longer
//              declares them
//   mirrors    [{ repo, target, names: { zabaputil_name: own_name }, dropped }]
//
// The mirrors (abap-util/mirror-ajson, abap-util/mirror-srtti) rename their
// upstream to abap-util's prefix and apply their local patches; abap-util
// vendors them as they are. A consumer takes the objects it uses and renames
// each one. The names are a table, not a pattern: a pattern cannot keep every
// name within maxLength (z2ui5_cl_ui5_srt_complexdescr would have 29).
//
// Every object of a mirror has to be in names or in dropped - one the mirror
// adds fails the run until somebody decides which of the two it is. A kept
// file that still names a dropped object fails it too: no zabaputil_ may
// survive the copy.
//
// The same file in abap2UI5 and in every addon that vendors ajson or S-RTTI;
// only .github/vendor-mirror.json differs.

import { readdirSync, readFileSync, writeFileSync, rmSync, existsSync, mkdirSync, mkdtempSync } from "node:fs";
import { join } from "node:path";
import { tmpdir } from "node:os";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const config = JSON.parse(readFileSync(join(ROOT, ".github/vendor-mirror.json"), "utf8"));
const { segment, maxLength = 25, tests = true, mirrors } = config;

const args = process.argv.slice(2);
const check = args.includes("--check");
let sources = args.filter((a) => a !== "--check");
if (sources.length === 0) {
  const tmp = mkdtempSync(join(tmpdir(), "vendor-mirror-"));
  sources = mirrors.map((m, i) => {
    const dir = join(tmp, String(i));
    execFileSync("git", ["clone", "--quiet", "--depth", "1", `https://github.com/${m.repo}.git`, dir], { stdio: "inherit" });
    return dir;
  });
}
if (sources.length !== mirrors.length) {
  console.error(`usage: vendor-mirror.mjs [--check] [${mirrors.map((m) => `<${m.repo} checkout>`).join(" ")}]`);
  process.exit(2);
}

const problems = [];
const own = new RegExp(`^z2ui5_(cl|if|cx)_${segment}_`);
for (const [name, renamed] of mirrors.flatMap((m) => Object.entries(m.names))) {
  if (renamed.length > maxLength) problems.push(`${renamed}: ${renamed.length} characters, at most ${maxLength}`);
  if (!own.test(renamed)) problems.push(`${renamed}: not z2ui5_(cl|if|cx)_${segment}_... (for ${name})`);
}

// every name of every mirror, longest first; \b does not stop at `_`, so a
// name never matches inside a longer one anyway
const table = Object.fromEntries(mirrors.flatMap((m) => Object.entries(m.names)));
const pattern = new RegExp(`\\b(${Object.keys(table).sort((a, b) => b.length - a.length).join("|")})\\b`, "gi");
const rename = (text) =>
  text.replace(pattern, (hit) => {
    const to = table[hit.toLowerCase()];
    return hit === hit.toUpperCase() ? to.toUpperCase() : to;
  });

const objectOf = (file) => file.split(".")[0].toLowerCase();
const output = [];

mirrors.forEach((mirror, i) => {
  const src = join(sources[i], "src");
  if (!existsSync(src)) {
    problems.push(`${sources[i]}: no src/ - is it a checkout of ${mirror.repo}?`);
    return;
  }
  const dropped = mirror.dropped ?? [];
  let files = readdirSync(src).filter((f) => f.toLowerCase().startsWith("zabaputil_"));
  if (!tests) files = files.filter((f) => !f.endsWith(".testclasses.abap"));
  const objects = new Set(files.map(objectOf));
  for (const o of objects) {
    if (!mirror.names[o] && !dropped.includes(o)) {
      problems.push(`${mirror.repo}: ${o} is new - add it to names or dropped in .github/vendor-mirror.json`);
    }
  }
  for (const o of [...Object.keys(mirror.names), ...dropped]) {
    if (!objects.has(o)) problems.push(`${mirror.repo}: ${o} is listed but not in the mirror any more`);
  }
  const out = new Map();
  for (const f of files) {
    const o = objectOf(f);
    if (!mirror.names[o]) continue;
    let content = rename(readFileSync(join(src, f), "utf8"));
    if (!tests && f.endsWith(".xml")) content = content.replace(/^[ \t]*<WITH_UNIT_TESTS>X<\/WITH_UNIT_TESTS>\r?\n/m, "");
    const left = content.match(/zabaputil_\w+/i);
    if (left) problems.push(`${f}: still names ${left[0]} - a dropped object, or one missing from names`);
    out.set(mirror.names[o] + f.slice(o.length), content);
  }
  output.push({ target: mirror.target, files: out });
});

if (problems.length) {
  for (const p of problems) console.error(`vendor-mirror: ${p}`);
  process.exit(1);
}

let drift = 0;
for (const { target, files } of output) {
  const dir = join(ROOT, target);
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  const present = readdirSync(dir).filter((f) => f.startsWith("z"));
  if (check) {
    for (const f of present) {
      if (!files.has(f)) { console.error(`${target}/${f}: not in the mirror`); drift++; }
    }
    for (const [f, content] of files) {
      if (!present.includes(f)) { console.error(`${target}/${f}: missing`); drift++; }
      else if (readFileSync(join(dir, f), "utf8") !== content) { console.error(`${target}/${f}: differs from the mirror`); drift++; }
    }
    continue;
  }
  for (const f of present) rmSync(join(dir, f));
  for (const [f, content] of files) writeFileSync(join(dir, f), content);
  console.log(`vendor-mirror: ${target} - ${files.size} files`);
}

if (check) {
  if (drift) {
    console.error(`vendor-mirror: ${drift} difference(s) - run it without --check and commit; the copy is never edited by hand`);
    process.exit(1);
  }
  console.log("vendor-mirror: the copy matches the mirrors");
}
