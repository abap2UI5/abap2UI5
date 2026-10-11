#!/usr/bin/env node
/*
 * readme-facts — the one line of numbers under the README badges, counted
 * from this repository instead of typed into it.
 *
 * The README makes claims about the engineering behind the framework: unit
 * tests, browser tests, CI gates, the release range. A number typed by hand
 * is right on the day it is written and wrong a quarter later, in the one
 * place a first-time visitor reads before anything else — and nobody notices,
 * because a stale "1,200 tests" looks exactly like a current one. The
 * removal plan had that problem with its blocker counts (docs/removal-plan.md
 * says how), and the fix is the same: count, do not remember.
 *
 * What is counted, and from where:
 *
 *   ABAP unit tests     `METHODS <name> FOR TESTING` under src/ — every
 *                       package, src/99 included: its test classes are the
 *                       maintained part of it and run in CI
 *   JS unit specs       node/tests/*.spec.js (the real app/webapp modules
 *                       through loadModule.js, no browser)
 *   browser suites      node/tests/e2e/*.spec.js (Playwright against the dev
 *                       server, on UI5 1.71 and the pinned 1.144)
 *   CI gates            the `check:*` scripts of package.json — each is one
 *                       question a pull request has to answer with yes
 *   workflows           .github/workflows/*.yaml
 *
 * The ABAP floor is read from .github/abaplint/abap_702.jsonc and the UI5
 * floor from app/AGENTS.md's 1.71 contract is a constant here on purpose:
 * neither is a count, and both are already gated elsewhere (the downport
 * workflow and frontend-module-gate). This script writes between the two
 * markers in README.md and nowhere else; `--check` compares instead of
 * writing and fails when the line is stale, so the number a visitor reads is
 * the number the repository holds.
 *
 *   node .github/scripts/readme-facts.mjs           (npm run facts)
 *   node .github/scripts/readme-facts.mjs --check   (npm run check:facts)
 */
import { fileURLToPath } from "url";
import { readFileSync, readdirSync, writeFileSync, statSync } from "fs";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const README = join(ROOT, "README.md");
const START = "<!-- facts:start -->";
const END = "<!-- facts:end -->";

const check = process.argv.includes("--check");

/* Every *.abap file under a directory, recursively. */
function walk(dir, ext, out = []) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) walk(full, ext, out);
    else if (name.endsWith(ext)) out.push(full);
  }
  return out;
}

const abapTests = walk(join(ROOT, "src"), ".abap").reduce((n, file) => {
  const text = readFileSync(file, "utf8");
  return n + (text.match(/^\s*METHODS?\s+\w+\s+FOR\s+TESTING\b/gim) ?? []).length;
}, 0);

const specs = (dir) =>
  readdirSync(join(ROOT, dir)).filter((f) => f.endsWith(".spec.js")).length;
const jsUnit = specs("node/tests");
const browser = specs("node/tests/e2e");

const pkg = JSON.parse(readFileSync(join(ROOT, "package.json"), "utf8"));
const gates = Object.keys(pkg.scripts ?? {}).filter((s) => s.startsWith("check:")).length;

const workflows = readdirSync(join(ROOT, ".github/workflows")).filter((f) =>
  /\.ya?ml$/.test(f),
).length;

const floor = JSON.parse(
  readFileSync(join(ROOT, ".github/abaplint/abap_702.jsonc"), "utf8").replace(
    /^\s*\/\/.*$/gm,
    "",
  ),
).syntax.version; // "v702"
const abapFloor = floor.replace(/^v(\d)(\d\d)$/, "$1.$2");

const fmt = (n) => n.toLocaleString("en-US");

const line =
  `${START}\n` +
  `<p align="center">\n` +
  `  <sub>${fmt(abapTests)} ABAP unit tests · ${fmt(jsUnit)} JS unit specs · ` +
  `${fmt(browser)} browser test suites · ${fmt(gates)} CI gates · ` +
  `${fmt(workflows)} workflows · ABAP ${abapFloor} → Cloud · UI5 1.71 → 2.x ` +
  `— counted from this repository by <code>npm run facts</code></sub>\n` +
  `</p>\n` +
  END;

const readme = readFileSync(README, "utf8");
const from = readme.indexOf(START);
const to = readme.indexOf(END);
if (from < 0 || to < 0 || to < from) {
  console.error(`readme-facts: README.md has no ${START} … ${END} block`);
  console.error("  the facts line lives between those two markers - put them back");
  process.exit(1);
}

const current = readme.slice(from, to + END.length);
const next = readme.slice(0, from) + line + readme.slice(to + END.length);

if (current === line) {
  console.log(
    `readme-facts: ${fmt(abapTests)} ABAP unit tests, ${jsUnit} JS specs, ${browser} browser suites, ` +
      `${gates} gates, ${workflows} workflows - README.md is current - OK`,
  );
  process.exit(0);
}

if (check) {
  console.error("readme-facts: the facts line in README.md is stale.");
  console.error("");
  console.error("  README.md says:");
  console.error("    " + current.split("\n").slice(1, -1).join("\n    "));
  console.error("  the repository holds:");
  console.error("    " + line.split("\n").slice(1, -1).join("\n    "));
  console.error("");
  console.error("  run `npm run facts` and commit README.md");
  process.exit(1);
}

writeFileSync(README, next);
console.log("readme-facts: README.md updated");
