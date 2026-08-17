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
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import path from "node:path";

const SCRIPTS = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.join(SCRIPTS, "..", "..");

// `npm` is the command a developer reruns to reproduce one failure on its
// own - the same contract check_gates.yaml's step names carry.
const GATES = [
  { npm: "check:frozen", script: "frozen-paths-gate.mjs" },
  { npm: "check:abapgit", script: "abapgit-format-gate.mjs" },
  { npm: "check:atc", script: "extended-check-gate.mjs" },
  { npm: "check_visibility", script: "testclass-visibility-gate.mjs" },
  { npm: "check:naming", script: "object-naming-gate.mjs" },
  { npm: "check:dynamic", script: "dynamic-name-gate.mjs" },
  { npm: "check:prose", script: "prose-name-gate.mjs" },
  { npm: "check:skills", script: "skill-rule-gate.mjs" },
  { npm: "check:shared", script: "shared-file-gate.mjs" },
  { npm: "check:counts", script: "corpus-count-gate.mjs" },
  { npm: "check:backlog", script: "generate-backlog.mjs", args: ["--check"] },
  { npm: "check:version", script: "version-sync-gate.mjs" },
  { npm: "check:icons", script: "ui5-icon-gate.mjs" },
  { npm: "check:modules", script: "frontend-module-gate.mjs" },
  { npm: "check:guide", script: "check-guide-api.mjs" },
  { npm: "check:formatter", script: "formatter-scope-gate.mjs" },
  { npm: "check:asserts", script: "assertion-gate.mjs" },
  { npm: "check:api", script: "api-snapshot.mjs" },
];

const failed = [];
const started = Date.now();

for (const gate of GATES) {
  const result = spawnSync(
    process.execPath,
    [path.join(SCRIPTS, gate.script), ...(gate.args ?? [])],
    { cwd: ROOT, encoding: "utf8" },
  );

  // A gate killed by a signal, or one that could not be spawned at all, has
  // no exit code - that is a failure of this runner, not a clean verdict,
  // and it must not read as a pass.
  const ok = result.status === 0;
  if (!ok) {
    failed.push(gate);
    process.stdout.write(`\n─── ${gate.npm} ───\n`);
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
