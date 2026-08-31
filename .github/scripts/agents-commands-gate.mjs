#!/usr/bin/env node
/*
 * agents-commands-gate — every npm script is documented where an agent looks
 * for one.
 *
 * AGENTS.md is loaded into every session, and its "Build & Validation" chapter
 * is the list of commands a reader is expected to work from. A script that is
 * not in it does not exist as far as that reader is concerned: they will not
 * run `npm run check:downport` before pushing, and they will re-derive by hand
 * what `npm run backlog:probe` already answers.
 *
 * That is not hypothetical. Twenty-one scripts were missing when this gate was
 * written - every cross-repository gate (check:shared, check:mirrors,
 * check:counts, check:prose, check:skills, check:samples-md, check:changelog),
 * every backlog command, and five of the six frontend build commands. The list
 * had simply stopped being maintained, and nothing said so, because a
 * documentation table cannot notice what is absent from it.
 *
 * The rule is the same one run-gates.mjs applies to its own list: the question
 * is decidable from package.json, so it is decided from package.json rather
 * than by remembering. Staying undocumented is still allowed - it just has to
 * be said here, with the reason, so that the omission is a decision.
 *
 * Scope: the "## Build & Validation" chapter only. A command named in passing
 * in a paragraph elsewhere is not a command a reader can find, and this gate
 * would otherwise be satisfied by a mention that helps nobody.
 */
import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const CHAPTER = "## Build & Validation";

/* Scripts deliberately not in the chapter, each with the reason. */
const UNDOCUMENTED = {};

const scripts = JSON.parse(readFileSync(join(ROOT, "package.json"), "utf8")).scripts ?? {};
const agents = readFileSync(join(ROOT, "AGENTS.md"), "utf8");

const at = agents.indexOf(`\n${CHAPTER}\n`);
if (at === -1) {
  console.error(`agents-commands: no ${JSON.stringify(CHAPTER)} heading on a line of its own`);
  console.error("  the chapter was renamed or removed - point this gate at the new one");
  process.exit(1);
}
let end = agents.indexOf("\n## ", at + 1);
if (end === -1) end = agents.length;
const chapter = agents.slice(at, end);

/* A script counts as documented when the chapter names it in code formatting:
 * as its own command (`npm run x`, `npm x`) or as one alternative of a row
 * that lists several (`... / `frontend:cloud_v2` / ...`). */
function documented(name) {
  return (
    chapter.includes(`\`npm run ${name}\``)
    || chapter.includes(`npm run ${name} `)
    || chapter.includes(`\`npm ${name}\``)
    || chapter.includes(`\`${name}\``)
  );
}

const missing = [];
const stale = [];

for (const name of Object.keys(scripts)) {
  if (name in UNDOCUMENTED) continue;
  if (!documented(name)) missing.push(name);
}
for (const name of Object.keys(UNDOCUMENTED)) {
  if (!(name in scripts)) stale.push(name);
}

if (missing.length === 0 && stale.length === 0) {
  console.log(
    `agents-commands: ${Object.keys(scripts).length} npm script(s), all named in "${CHAPTER}" - OK`,
  );
  process.exit(0);
}

console.log(`agents-commands: package.json and AGENTS.md disagree about which commands exist.`);
console.log("");
if (missing.length > 0) {
  console.log(`  not named in "${CHAPTER}":`);
  for (const name of missing) console.log(`    npm run ${name}`);
  console.log("");
  console.log("  Add a row to the chapter's command table saying what it does, or add it");
  console.log("  to UNDOCUMENTED in this script with the reason it stays out.");
  console.log("");
}
if (stale.length > 0) {
  console.log("  declared UNDOCUMENTED but no longer a script:");
  for (const name of stale) console.log(`    ${name}`);
  console.log("");
  console.log("  Drop the entry - an exemption for a command that does not exist hides");
  console.log("  nothing and outlives its reason.");
}
process.exit(1);
