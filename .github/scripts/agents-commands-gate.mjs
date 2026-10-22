#!/usr/bin/env node
/*
 * agents-commands-gate — every npm script is documented where an agent looks
 * for one.
 *
 * docs/agents/commands.md is the command inventory AGENTS.md points every
 * session at (its "Build & Validation" chapter is now a compact pointer - the
 * inventory itself moved out of the always-loaded file). A script that is not
 * in it does not exist as far as that reader is concerned: they will not run
 * `npm run check:downport` before pushing, and they will re-derive by hand
 * what `npm run backlog:probe` already answers.
 *
 * That is not hypothetical. Twenty-one scripts were missing when this gate was
 * written - every cross-repository gate (check:shared, check:mirrors,
 * check:prose, check:skills, check:samples-md, check:changelog),
 * every backlog command, and five of the six frontend build commands. The list
 * had simply stopped being maintained, and nothing said so, because a
 * documentation table cannot notice what is absent from it.
 *
 * The rule is the same one run-gates.mjs applies to its own list: the question
 * is decidable from package.json, so it is decided from package.json rather
 * than by remembering. Staying undocumented is still allowed - it just has to
 * be said here, with the reason, so that the omission is a decision.
 *
 * Scope: docs/agents/commands.md, the whole file - it exists for nothing but
 * this inventory. A command named in passing in a paragraph of some other
 * document is not a command a reader can find, and this gate would otherwise
 * be satisfied by a mention that helps nobody.
 */
import { fileURLToPath } from "url";
import { readFileSync } from "fs";
import { join } from "path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const FILE = "docs/agents/commands.md";

/* Scripts deliberately not in the inventory, each with the reason. */
const UNDOCUMENTED = {};

const scripts = JSON.parse(readFileSync(join(ROOT, "package.json"), "utf8")).scripts ?? {};
let chapter;
try {
  chapter = readFileSync(join(ROOT, FILE), "utf8");
} catch {
  console.error(`agents-commands: ${FILE} is missing`);
  console.error("  the command inventory was moved or removed - point this gate at the new place");
  process.exit(1);
}

/* A script counts as documented when the chapter names it AS A COMMAND: a
 * line of a fenced block that starts with `npm run x`, or a table row holding
 * `npm run x` / `npm x` / `npm --prefix app run x` in code formatting (with or
 * without arguments), or - in the row's first cell only - one alternative of
 * a row that lists several (`... / `frontend:cloud_v2` / ...`). A bare
 * backticked token anywhere in the file used to count, which let `test`,
 * `check:cloud` and the `frontend:*` scripts pass on an incidental mention in
 * a paragraph - a mention that helps nobody, which is the case the header
 * says this gate exists to refuse.
 *
 * The names are collected so the gate can also go the other way: a row that
 * documents a command package.json no longer has is a lie the reader acts
 * on, and nothing else notices one. */
/* `npm run x`, and the two scripts npm runs without `run` (`npm start`,
 * `npm test`); `npm ci` / `npm audit` are npm's own, not scripts. */
const SCRIPT = "(?:run ([a-z0-9:_-]+)|(start|test)\\b)";
const COMMAND = new RegExp(`\`npm(?: --prefix app)? ${SCRIPT}(?: [^\`]*)?\``, "g");
const ALTERNATIVE = /(?:^|\/ )`([a-z0-9:_-]+)`/g;
const BLOCK_LINE = new RegExp(`^npm(?: --prefix app)? ${SCRIPT}(?:\\s|$)`);
const scriptOf = (m) => m[1] ?? m[2];
const documentedNames = new Set();
let fenced = false;
for (const line of chapter.split("\n")) {
  if (line.startsWith("```")) {
    fenced = !fenced;
    continue;
  }
  if (fenced) {
    const m = line.match(BLOCK_LINE);
    if (m) documentedNames.add(scriptOf(m));
    continue;
  }
  if (!line.startsWith("|")) continue;
  for (const m of line.matchAll(COMMAND)) documentedNames.add(scriptOf(m));
  const first = line.split("|")[1] ?? "";
  for (const m of first.matchAll(ALTERNATIVE)) documentedNames.add(m[1]);
}
/* The app/ table documents app/package.json's scripts (`npm --prefix app run
 * …`), which the root package.json does not have - they are not stale rows. */
let appScripts = {};
try {
  appScripts = JSON.parse(readFileSync(join(ROOT, "app", "package.json"), "utf8")).scripts ?? {};
} catch {
  // no app/package.json - then no row may name one either
}

const missing = [];
const stale = [];
const gone = [];

for (const name of Object.keys(scripts)) {
  if (name in UNDOCUMENTED) continue;
  if (!documentedNames.has(name)) missing.push(name);
}
for (const name of Object.keys(UNDOCUMENTED)) {
  if (!(name in scripts)) stale.push(name);
}
for (const name of documentedNames) {
  if (!(name in scripts) && !(name in appScripts)) gone.push(name);
}

if (missing.length === 0 && stale.length === 0 && gone.length === 0) {
  console.log(
    `agents-commands: ${Object.keys(scripts).length} npm script(s), all named in ${FILE} - OK`,
  );
  process.exit(0);
}

console.log(`agents-commands: package.json and ${FILE} disagree about which commands exist.`);
console.log("");
if (missing.length > 0) {
  console.log(`  not named in ${FILE}:`);
  for (const name of missing) console.log(`    npm run ${name}`);
  console.log("");
  console.log("  Add a row to its command table saying what it does (the first cell");
  console.log("  names it as `npm run <name>`), or add it to UNDOCUMENTED in this");
  console.log("  script with the reason it stays out.");
  console.log("");
}
if (gone.length > 0) {
  console.log(`  named in a table row of ${FILE} but not a script of package.json or app/package.json:`);
  for (const name of gone) console.log(`    ${name}`);
  console.log("");
  console.log("  Drop or fix the row - a documented command that does not exist sends");
  console.log("  the reader to an error instead of to the command that replaced it.");
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
