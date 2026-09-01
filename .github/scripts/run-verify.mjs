#!/usr/bin/env node
/*
 * run-verify — `npm run verify` with the reporting semantics of run-gates.
 *
 * verify used to be thirteen `&&`-chained npm scripts, which is exactly the
 * shape run-gates.mjs was written to end: fix one failure, re-run the whole
 * chain, discover the next. The CHECK members are independent of each other,
 * so they all run and every failure is reported in one pass — and since they
 * are independent they also run CONCURRENTLY, with the same buffered worker
 * pool run-gates uses: output is collected per child and printed after the
 * join in declaration order, so a run reads identically to the serial version
 * while the wall time is the longest member instead of the sum. The BUILD
 * members are a pipeline (downport feeds transpile feeds the unit suite) and
 * stay sequential with an abort on the first failure — a transpile over a
 * broken downport reports garbage, not a second finding.
 *
 * One prerequisite is hoisted out of the pool: `npm run deps`. Three of the
 * checks lint against the pinned dependency checkouts in node/deps/, and only
 * `check` fetches them itself — run concurrently, check:standard could read a
 * half-materialized clone. Fetched once up front it is a ~50ms no-op for
 * everyone downstream (fetch-deps re-runs idempotently).
 *
 * `--full` is `npm run verify:full`: the same run plus the frontend gates —
 * the ui5lint zero-error gate (check:ui5) and the app ESLint — which need
 * app/node_modules. The runner installs that itself when it is missing, the
 * way check:app2abap already does (ensure-app-deps.mjs), and only in --full
 * mode: the default `verify` stays free of the Fiori toolchain install.
 *
 * Each member is still the command a developer reruns on its own; the report
 * names it. The npm wrapper cost is irrelevant here — the members are
 * seconds to minutes each.
 */
import { spawn, spawnSync } from "node:child_process";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const SCRIPTS = path.dirname(fileURLToPath(import.meta.url));
const full = process.argv.includes("--full");

// independent checks: all of them run concurrently, failures are collected.
// `cmd` is what a developer types to rerun one on its own.
const CHECKS = [
  "check",
  "gates",
  "check:abap2ui5",
  "check:eslint",
  "check:format",
  "check:standard",
  "check:cloud",
].map((script) => ({ cmd: `npm run ${script}`, argv: ["npm", "run", script] }));

if (full) {
  CHECKS.push(
    { cmd: "npm run check:ui5", argv: ["npm", "run", "check:ui5"] },
    { cmd: "npm --prefix app run lint", argv: ["npm", "--prefix", "app", "run", "lint"] },
  );
}

// dependent pipeline: sequential, first failure aborts
const BUILD = [
  "downport",
  "auto_transpile",
  "unit",
  "check:js",
  "check:app2abap",
  "check:frontend",
];

const runSync = (label, argv) => {
  console.log(`\n=== ${label} ===`);
  const res = spawnSync(argv[0], argv.slice(1), { cwd: ROOT, stdio: "inherit" });
  return res.status === 0;
};

// the hoisted prerequisites (see header): deps for the abaplint members, the
// app toolchain for the --full members
if (!runSync("npm run deps", ["npm", "run", "deps"])) {
  console.error("\nverify: npm run deps failed — nothing that lints can run without the pinned checkouts");
  process.exit(1);
}
if (full && !runSync("ensure app/node_modules", ["node", path.join(SCRIPTS, "ensure-app-deps.mjs")])) {
  console.error("\nverify: the app toolchain install failed — check:ui5 and the app lint need it");
  process.exit(1);
}

// run-gates' pool: bounded concurrency, per-child buffering, report in
// declaration order regardless of finish order
const CONCURRENCY = Math.min(8, Math.max(2, os.cpus().length));

function runCheck(member) {
  return new Promise((resolve) => {
    const child = spawn(member.argv[0], member.argv.slice(1), { cwd: ROOT });
    let out = "";
    child.stdout.on("data", (d) => { out += d; });
    child.stderr.on("data", (d) => { out += d; });
    child.on("error", (error) => resolve({ member, status: null, out, error }));
    child.on("close", (status, signal) => resolve({ member, status, out, signal }));
  });
}

const results = new Array(CHECKS.length);
let next = 0;
await Promise.all(
  Array.from({ length: Math.min(CONCURRENCY, CHECKS.length) }, async () => {
    for (;;) {
      const index = next++;
      if (index >= CHECKS.length) return;
      results[index] = await runCheck(CHECKS[index]);
    }
  }),
);

const failed = [];
for (const result of results) {
  console.log(`\n=== ${result.member.cmd} ===`);
  process.stdout.write(result.out ?? "");
  if (result.error) console.log(result.error.message);
  // no exit code (a signal, a spawn failure) is a failure of this runner,
  // not a clean verdict - it must not read as a pass
  if (result.status !== 0) {
    failed.push(result.member);
    if (result.status === null) {
      console.log(`(no exit code${result.signal ? `, signal ${result.signal}` : ""})`);
    }
  }
}

if (failed.length) {
  console.error(`\nverify: ${failed.length} check(s) failed — fix and rerun each on its own:`);
  for (const member of failed) console.error(`  ${member.cmd}`);
  console.error("\n(the build/test pipeline was not started on a failing tree)");
  process.exit(1);
}

for (const script of BUILD) {
  if (!runSync(`npm run ${script}`, ["npm", "run", script])) {
    console.error(`\nverify: npm run ${script} failed — the pipeline stops here (later members depend on it)`);
    process.exit(1);
  }
}

console.log(`\nverify: everything green${full ? " (full: frontend gates included)" : ""}`);
