#!/usr/bin/env node
/*
 * Gate: every JS unit spec is in the inventory, and the inventory names no
 * spec that is gone.
 *
 * `docs/agents/test-inventory.md` is how a reader finds out whether a frontend
 * module is already covered - and therefore whether a change to it can be made
 * with a spec behind it or needs one written first. A list that quietly stops
 * being complete answers "no spec" for a module that has one, which is the
 * expensive direction: it costs a duplicate spec, or a change made blind.
 *
 * It had already happened: `devtoolsFragment.spec.js` shipped and was never
 * added, and the four custom-control specs added alongside this gate were
 * missing for the opposite reason - the controls had no spec at all and the
 * list is what would have said so.
 *
 * The check is deliberately shallow. It asks whether the file name appears,
 * not whether the row describes it correctly - the second is a reader's job,
 * and a gate that tried would be a gate people work around.
 *
 * Run: node .github/scripts/spec-inventory-gate.mjs   (npm run check:specs)
 */
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const ROOT = new URL("../../", import.meta.url).pathname;
const SPECS = join(ROOT, "node", "tests");
const INVENTORY = "docs/agents/test-inventory.md";

const onDisk = readdirSync(SPECS)
  .filter((f) => f.endsWith(".spec.js"))
  .sort();

if (onDisk.length === 0) {
  console.error(`spec-inventory: no *.spec.js under node/tests - this gate would go blind`);
  process.exit(1);
}

const text = readFileSync(join(ROOT, INVENTORY), "utf8");
const named = new Set(text.match(/[A-Za-z0-9_.]+\.spec\.js/g) ?? []);

const missing = onDisk.filter((f) => !named.has(f));
const stale = [...named].filter((f) => !onDisk.includes(f)).sort();

if (missing.length === 0 && stale.length === 0) {
  console.log(`spec-inventory: ${onDisk.length} spec(s), all in ${INVENTORY} - OK`);
  process.exit(0);
}

console.error(`spec-inventory: ${INVENTORY} and node/tests disagree.`);
console.error("");
if (missing.length) {
  console.error("  written but not in the inventory:");
  for (const f of missing) console.error(`    node/tests/${f}`);
  console.error("");
  console.error("  Add a row: the module under test, the spec, and what it pins.");
  console.error("");
}
if (stale.length) {
  console.error("  in the inventory but no longer on disk:");
  for (const f of stale) console.error(`    ${f}`);
  console.error("");
  console.error("  Drop the row - a reader following it finds nothing.");
}
process.exit(1);
