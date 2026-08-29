#!/usr/bin/env node
/*
 * run-verify — `npm run verify` with the reporting semantics of run-gates.
 *
 * verify used to be thirteen `&&`-chained npm scripts, which is exactly the
 * shape run-gates.mjs was written to end: fix one failure, re-run the whole
 * chain, discover the next. The CHECK members are independent of each other,
 * so they all run and every failure is reported in one pass. The BUILD
 * members are a pipeline (downport feeds transpile feeds the unit suite) and
 * stay sequential with an abort on the first failure — a transpile over a
 * broken downport reports garbage, not a second finding.
 *
 * Each member is still the npm script a developer reruns on its own; the
 * report names it. The npm wrapper cost is irrelevant here — the members are
 * seconds to minutes each.
 */
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

// independent checks: all of them run, failures are collected
const CHECKS = [
  "check",
  "gates",
  "check:abap2ui5",
  "check:eslint",
  "check:format",
  "check:standard",
  "check:cloud",
];

// dependent pipeline: sequential, first failure aborts
const BUILD = [
  "downport",
  "auto_transpile",
  "unit",
  "check:js",
  "check:app2abap",
  "check:frontend",
];

const runNpm = (script) => {
  console.log(`\n=== npm run ${script} ===`);
  const res = spawnSync("npm", ["run", script], { cwd: ROOT, stdio: "inherit" });
  return res.status === 0;
};

const failed = [];
for (const script of CHECKS) {
  if (!runNpm(script)) failed.push(script);
}

if (failed.length) {
  console.error(`\nverify: ${failed.length} check(s) failed — fix and rerun each on its own:`);
  for (const script of failed) console.error(`  npm run ${script}`);
  console.error("\n(the build/test pipeline was not started on a failing tree)");
  process.exit(1);
}

for (const script of BUILD) {
  if (!runNpm(script)) {
    console.error(`\nverify: npm run ${script} failed — the pipeline stops here (later members depend on it)`);
    process.exit(1);
  }
}

console.log("\nverify: everything green");
