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
import { fileURLToPath } from "url";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const SPECS = join(ROOT, "node", "tests");
const INVENTORY = "docs/agents/test-inventory.md";
const WEBAPP = join(ROOT, "app", "webapp");

/*
 * The THIRD direction, and the one the header above describes without
 * checking: "the controls had no spec at all and the list is what would have
 * said so". Spec -> inventory and inventory -> spec both compare the list
 * against node/tests, so a module with no spec at all is invisible to both -
 * it appears in neither set. Five modules were in exactly that state when this
 * was added.
 *
 * A module is answered for when the inventory names its path, whether that row
 * says a dedicated spec covers it or that it is exercised through a composed
 * one. What is refused is silence. An uncovered module is recorded here, with
 * why - the same shape as the KNOWN lists of the other gates, and a list that
 * is meant to shrink.
 */
const NO_SPEC = new Map([
  [
    "cc/Title.js",
    "a 30-line custom control that only renders a heading tag - the four "
      + "controls with behaviour have specs (see the inventory)",
  ],
]);

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

/* Every frontend module, relative to app/webapp - the set the inventory is a
 * statement about. */
function modules(dir, prefix = "") {
  const out = [];
  for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : 1))) {
    const rel = prefix ? `${prefix}/${entry.name}` : entry.name;
    if (entry.isDirectory()) out.push(...modules(join(dir, entry.name), rel));
    else if (entry.name.endsWith(".js")) out.push(rel);
  }
  return out;
}

const allModules = modules(WEBAPP);
const uncovered = allModules.filter((m) => !text.includes(m) && !NO_SPEC.has(m));
/* A NO_SPEC entry for a module that is now in the inventory is stale in the
 * other direction: the list is meant to shrink, and an entry nobody removes
 * after writing the spec is what makes it stop shrinking. */
const excused = [...NO_SPEC.keys()].filter((m) => text.includes(m) || !allModules.includes(m)).sort();

if (missing.length === 0 && stale.length === 0 && uncovered.length === 0 && excused.length === 0) {
  console.log(
    `spec-inventory: ${onDisk.length} spec(s) and ${allModules.length} module(s), `
    + `all in ${INVENTORY} (${NO_SPEC.size} recorded without one) - OK`,
  );
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
  console.error("");
}
if (uncovered.length) {
  console.error("  frontend module(s) the inventory does not mention at all:");
  for (const f of uncovered) console.error(`    app/webapp/${f}`);
  console.error("");
  console.error("  The list answers \"is this module covered?\", so a module");
  console.error("  missing from it answers \"no spec\" by omission rather than");
  console.error("  by anybody deciding that. Add a row naming what covers it -");
  console.error("  a dedicated spec, or the composed spec that exercises it -");
  console.error("  or record it in NO_SPEC in this script with the reason.");
  console.error("");
}
if (excused.length) {
  console.error("  NO_SPEC entry/entries that are no longer true:");
  for (const f of excused) console.error(`    app/webapp/${f}`);
  console.error("");
  console.error("  The module is in the inventory now, or gone. Drop the entry.");
}
process.exit(1);
