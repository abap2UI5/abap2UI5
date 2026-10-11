#!/usr/bin/env node
/*
 * run-concurrent — a few independent npm scripts at once, every result
 * reported.
 *
 * abaplint.yaml runs four full parses of the sources on one runner
 * (check:standard, check:cloud, check:format, rename), each ~18 s and each
 * independent of the others: four sequential steps were a minute of wall
 * time for what two cores finish in half. A matrix would halve it too, but
 * at the price the workflow's own header names - the install paid once per
 * leg instead of once. So the pairs run here, in one step, as children of
 * one process.
 *
 * The output of each child is BUFFERED and printed after the join, in the
 * order the commands were given and under a log group per command, so the
 * step reads like the two sequential steps it replaces and the failing
 * check is named - interleaved abaplint output from two parses is not a
 * report anybody can read. The exit code is 1 when any child failed, after
 * every child has finished and been printed: one red parse must not hide
 * the other one's findings. The same buffered-pool shape run-gates.mjs and
 * run-verify.mjs use locally.
 *
 *   node .github/scripts/run-concurrent.mjs "npm run check:standard" "npm run check:cloud"
 */
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));
const commands = process.argv.slice(2);
if (commands.length === 0) {
  console.error('run-concurrent: pass the commands to run, e.g. "npm run check:standard" "npm run check:cloud"');
  process.exit(2);
}

// A GitHub Actions log group when the output lands in a job log, a plain
// heading anywhere else - the grouping is what makes two ~hundred-line
// abaplint reports in one step legible.
const onActions = Boolean(process.env.GITHUB_ACTIONS);

function run(cmd) {
  return new Promise((resolve) => {
    const chunks = [];
    // through the shell: these are npm invocations, and npm is npm.cmd on
    // Windows (the reason run-verify.mjs spawns through a shell there)
    const child = spawn(cmd, { cwd: ROOT, shell: true, stdio: ["ignore", "pipe", "pipe"] });
    child.stdout.on("data", (d) => chunks.push(d));
    child.stderr.on("data", (d) => chunks.push(d));
    child.on("error", (e) => resolve({ cmd, code: 1, output: `${e.message}\n` }));
    child.on("close", (code, signal) => resolve({ cmd, code: code ?? 1, signal, output: Buffer.concat(chunks).toString("utf8") }));
  });
}

const started = Date.now();
const results = await Promise.all(commands.map(run));
for (const r of results) {
  const status = r.code === 0 ? "ok" : `FAILED (exit ${r.signal ?? r.code})`;
  console.log(onActions ? `::group::${r.cmd} - ${status}` : `─── ${r.cmd} - ${status} ───`);
  process.stdout.write(r.output.endsWith("\n") || r.output === "" ? r.output : `${r.output}\n`);
  if (onActions) console.log("::endgroup::");
}
const failed = results.filter((r) => r.code !== 0);
const seconds = ((Date.now() - started) / 1000).toFixed(1);
if (failed.length) {
  console.log(`\nrun-concurrent: ${failed.length} of ${results.length} failed in ${seconds}s:`);
  for (const r of failed) console.log(`  ${r.cmd}`);
  process.exit(1);
}
console.log(`\nrun-concurrent: ${results.length} of ${results.length} ok in ${seconds}s`);
