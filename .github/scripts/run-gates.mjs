#!/usr/bin/env node
/*
 * run-gates — the static gates, in one command, reporting every failure.
 *
 * Two problems, one script.
 *
 * The first is arithmetic. Each gate is a Node script that reads the sources
 * and decides one rule, and together they do about 1.7 seconds of work. Run
 * through `npm run`, each one costs ~700ms of wrapper before it starts, so
 * `verify` was paying ~11 seconds of npm to do 1.7 seconds of checking.
 *
 * The second is the one check_gates.yaml already solved for CI and nothing
 * had solved locally. That workflow marks every step `if: ${{ !cancelled() }}`
 * on purpose: a pull request that trips three gates reports all three at
 * once. `verify` chained the same gates with `&&`, which does the opposite —
 * fix one, re-run the whole chain, discover the next. So the local run
 * disagreed with CI about how much you were told per attempt.
 *
 * The gates run as child processes rather than imports. They are standalone
 * scripts that signal failure with process.exit(1); imported into this one,
 * the first failure would take the runner down with it and there would be
 * nothing left to collect. A spawn per gate keeps ~50ms of the ~700ms and
 * needs no change to any gate.
 *
 * CI does NOT use this. check_gates.yaml keeps one named step per gate,
 * because a step name is what makes a red check legible in the checks list,
 * and its per-step `!cancelled()` already reports everything. This is the
 * local half of that same behaviour.
 *
 * A gate belongs here when it is plain Node over the working tree. The ones
 * that shell out to abaplint (check:standard, check:cloud, check:abap2ui5)
 * stay in `verify` as their own commands - they are seconds each, so the
 * wrapper is noise, and their output is long enough to want its own place.
 */
import { spawn } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import { fileURLToPath } from "node:url";
import path from "node:path";

const SCRIPTS = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(SCRIPTS, "..", "..");

// `npm` is the command a developer reruns to reproduce one failure on its
// own - the same contract check_gates.yaml's step names carry.
const GATES = [
  { npm: "check:frozen", script: "frozen-paths-gate.mjs" },
  { npm: "check:frozen-only", script: "frozen-only-gate.mjs" },
  { npm: "check:abapgit", script: "abapgit-format-gate.mjs" },
  { npm: "check:atc", script: "extended-check-gate.mjs" },
  { npm: "check:cause", script: "exception-cause-gate.mjs" },
  { npm: "check_visibility", script: "testclass-visibility-gate.mjs" },
  { npm: "check:naming", script: "object-naming-gate.mjs" },
  { npm: "check:dynamic", script: "dynamic-name-gate.mjs" },
  { npm: "check:prose", script: "prose-name-gate.mjs" },
  { npm: "check:skills", script: "skill-rule-gate.mjs" },
  { npm: "check:shared", script: "shared-file-gate.mjs" },
  { npm: "check:mirrors", script: "linter-mirror-gate.mjs" },
  { npm: "check:conventions", script: "conventions-gate.mjs" },
  { npm: "check:commands", script: "agents-commands-gate.mjs" },
  { npm: "check:scripts", script: "scripts-gate.mjs" },
  { npm: "check:toolchain", script: "toolchain-gate.mjs" },
  { npm: "check:counts", script: "corpus-count-gate.mjs" },
  { npm: "check:samples-md", script: "samples-md-gate.mjs" },
  { npm: "check:changelog", script: "changelog-gate.mjs" },
  { npm: "check:backlog", script: "generate-backlog.mjs", args: ["--check"] },
  { npm: "check:version", script: "version-sync-gate.mjs" },
  { npm: "check:icons", script: "ui5-icon-gate.mjs" },
  { npm: "check:modules", script: "frontend-module-gate.mjs" },
  { npm: "check:guide", script: "check-guide-api.mjs" },
  { npm: "check:formatter", script: "formatter-scope-gate.mjs" },
  { npm: "check:asserts", script: "assertion-gate.mjs" },
  { npm: "check:specs", script: "spec-inventory-gate.mjs" },
  { npm: "check:downport", script: "downport-operand-gate.mjs" },
  { npm: "check:pins", script: "transpile-pins-gate.mjs" },
  { npm: "check:draftowner", script: "draft-owner-gate.mjs" },
  { npm: "check:api", script: "api-snapshot.mjs" },
];

/*
 * GATES has to stay COMPLETE, and package.json is what can decide that.
 *
 * The inclusion rule above - "plain Node over the working tree" - lived only
 * in that comment, so nothing noticed when two gates did not follow it.
 * check:mirrors and check:conventions were steps in check_gates.yaml and in
 * neither list a contributor can run, so `npm run verify` reported "gates: 22
 * checked - all OK" on a change whose check_gates went red in CI. Both were
 * legitimately green locally; the gate that would have caught them was not
 * reachable from any command they ran.
 *
 * A `check…` script whose body is ONE `node .github/scripts/<x>.mjs [args]`
 * run IS plain Node over the working tree, by construction - so the rule is
 * decidable from package.json rather than by reading a workflow, which
 * scripts-gate.mjs declines to do for good reasons of its own (its header
 * says why, and is right about the workflow).
 *
 * Staying out is still allowed. It just has to be said here, with the reason,
 * so that omission becomes a decision.
 */
const NOT_A_VERIFY_GATE = {
  "check:ui5": "shells out to the UI5 linter and needs app/node_modules - run-verify runs it as a member of its own in --full mode (npm run verify:full), the way check:standard and check:cloud are members of the default run",
  "check:release": "release-time only: it judges a version bump against the changelog, not the working tree",
  "check:changelog-entry": "CI-only: it judges a pull request's DIFF against a base ref the working tree does not have - check_gates.yaml passes BASE_REF on pull requests",
};

// One command, no && / | / ; - a chain (check:app2abap) is two runs and falls
// out here on its own, which is the right answer for a different reason.
const ONE_NODE_RUN = /^node \.github\/scripts\/[\w-]+\.mjs(?:\s+[^&|;<>]*)?$/;

{
  const scripts = JSON.parse(fs.readFileSync(path.join(ROOT, "package.json"), "utf8")).scripts ?? {};
  const listed = new Set(GATES.map((g) => g.npm));
  const drift = [];

  for (const [name, body] of Object.entries(scripts)) {
    if (!/^check[:_]/.test(name)) continue;
    if (!ONE_NODE_RUN.test(body.trim())) continue;
    if (listed.has(name) || name in NOT_A_VERIFY_GATE) continue;
    drift.push(`  ${name} is a plain-Node gate and is in neither GATES nor NOT_A_VERIFY_GATE`);
  }
  for (const gate of GATES) {
    if (!(gate.npm in scripts)) drift.push(`  ${gate.npm} is in GATES but is no longer a script in package.json`);
  }

  if (drift.length) {
    console.log("run-gates: this list and package.json disagree about which gates exist —\n");
    for (const line of drift) console.log(line);
    console.log("\nAdd it to GATES, or to NOT_A_VERIFY_GATE with the reason it stays out.");
    process.exit(1);
  }
}

const failed = [];
const started = Date.now();

/*
 * Run the gates concurrently, and report them in GATES order regardless of the
 * order they finish in.
 *
 * The header above is an argument about arithmetic - "~11 seconds of npm to do
 * 1.7 seconds of checking" - and then spent the saved time serially. Four of
 * these gates read from sibling repositories over the network with a 15-second
 * per-request timeout (check:shared walks a whole list of them, and
 * check:counts, check:mirrors and check:samples-md each do their own reads),
 * so wall time is dominated by requests that are waiting, not computing. They
 * parallelise perfectly because no gate reads what another writes: every one
 * of them is a pure check.
 *
 * Output is buffered per child and printed after the join, in GATES order, so
 * a failing run reads identically to the serial version - which matters, since
 * reporting EVERY failure rather than the first is the whole point of this
 * runner (and of check_gates.yaml's per-step `!cancelled()`).
 */
const CONCURRENCY = Math.min(8, Math.max(2, os.cpus().length));

function runGate(gate) {
  return new Promise((resolve) => {
    const child = spawn(
      process.execPath,
      [path.join(SCRIPTS, gate.script), ...(gate.args ?? [])],
      { cwd: ROOT },
    );
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (d) => { stdout += d; });
    child.stderr.on("data", (d) => { stderr += d; });
    child.on("error", (error) => resolve({ gate, status: null, stdout, stderr, error }));
    child.on("close", (status, signal) => resolve({ gate, status, stdout, stderr, signal }));
  });
}

const results = new Array(GATES.length);
let next = 0;
await Promise.all(
  Array.from({ length: Math.min(CONCURRENCY, GATES.length) }, async () => {
    for (;;) {
      const index = next++;
      if (index >= GATES.length) return;
      results[index] = await runGate(GATES[index]);
    }
  }),
);

for (const result of results) {
  // A gate killed by a signal, or one that could not be spawned at all, has
  // no exit code - that is a failure of this runner, not a clean verdict,
  // and it must not read as a pass.
  const ok = result.status === 0;
  if (!ok) {
    failed.push(result.gate);
    process.stdout.write(`\n─── ${result.gate.npm} ───\n`);
    process.stdout.write(result.stdout ?? "");
    process.stderr.write(result.stderr ?? "");
    if (result.error) process.stdout.write(`${result.error.message}\n`);
    if (result.status === null) {
      process.stdout.write(`(no exit code${result.signal ? `, signal ${result.signal}` : ""})\n`);
    }
  }
}

const seconds = ((Date.now() - started) / 1000).toFixed(1);

if (failed.length === 0) {
  console.log(`\ngates: ${GATES.length} checked in ${seconds}s - all OK`);
  process.exit(0);
}

console.log(`\ngates: ${failed.length} of ${GATES.length} failed in ${seconds}s`);
console.log("");
console.log("Rerun one on its own with:");
for (const gate of failed) console.log(`  npm run ${gate.npm}`);
process.exit(1);
