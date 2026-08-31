#!/usr/bin/env node
/*
 * transpile-pins-gate — every library the transpiler consumes is pinned.
 *
 * `node/setup/abap_transpile.json` names the git libraries the transpiler
 * folds into the build (`libs[].folder` under node/deps/), and
 * `node/setup/fetch-deps.mjs` is what materializes node/deps at PINNED shas
 * so a build cannot turn red because an upstream moved. Nothing held the two
 * lists together: a library added to abap_transpile.json and forgotten in
 * fetch-deps.mjs is cloned by the transpiler tooling at floating HEAD —
 * silently, and discovered only when that upstream breaks, which is the
 * exact failure fetch-deps.mjs exists to rule out.
 *
 * The reverse direction is NOT checked: fetch-deps.mjs legitimately pins
 * more than the transpiler consumes (the abaplint API intersection).
 *
 *   node .github/scripts/transpile-pins-gate.mjs      (npm run check:pins)
 */
import { readFileSync } from "fs";
import { join, basename } from "path";
import { fileURLToPath } from "url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

const transpile = JSON.parse(
  readFileSync(join(ROOT, "node/setup/abap_transpile.json"), "utf8"),
);

// fetch-deps.mjs is a script, not data — read the PINS entries out of its
// source. The `name:` lines inside the PINS array literal are the contract.
const fetchDeps = readFileSync(join(ROOT, "node/setup/fetch-deps.mjs"), "utf8");
const pinsBlock = /const PINS = \[([\s\S]*?)\];/.exec(fetchDeps)?.[1] ?? "";
const pinned = new Set(
  [...pinsBlock.matchAll(/name:\s*"([^"]+)"/g)].map((m) => m[1]),
);

if (pinned.size === 0) {
  console.error("transpile-pins: no PINS found in node/setup/fetch-deps.mjs - the parser or the file changed shape");
  process.exit(1);
}

const problems = [];
let checked = 0;
for (const lib of transpile.libs ?? []) {
  checked += 1;
  const name = basename(lib.folder ?? "");
  if (!pinned.has(name)) {
    problems.push(
      `abap_transpile.json names ${lib.folder} but fetch-deps.mjs has no pin "${name}" - the transpiler would clone it at floating HEAD`,
    );
  }
}

if (checked === 0) {
  console.error("transpile-pins: abap_transpile.json declares no libs - nothing was checked");
  process.exit(1);
}

if (problems.length) {
  console.error(`${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log(`transpile-pins: ${checked} transpiler lib(s), every one pinned in fetch-deps.mjs - OK`);
