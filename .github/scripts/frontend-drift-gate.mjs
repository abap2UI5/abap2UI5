#!/usr/bin/env node
/*
 * Gate: the four delivery trees under build/ are what the sources produce.
 *
 * `npm run frontend:build` rebuilds them in place, and this decides whether
 * that changed anything. build/ is committed here on purpose - frontend_deploy
 * ships those trees as they stand, so what reaches an installation is what the
 * pull request reviewed - which only holds if a change under app/webapp,
 * frontend/ or tools/ arrives with the rebuilt trees beside it.
 *
 * It was `git diff --exit-code -- build && test -z "$(git status --porcelain
 * -- build)"`, which needs a POSIX shell: `$(…)` and `test -z` are not
 * commands on Windows, so `npm run check:frontend` - and `npm run verify`
 * through it - could not run there. `git status --porcelain` already reports
 * everything both halves looked at (modified tracked files, staged ones, and
 * files the build newly created), so this is one command rather than two.
 */
import { spawnSync } from "node:child_process";

const ROOT = new URL("../../", import.meta.url).pathname;

const status = spawnSync("git", ["status", "--porcelain", "--", "build"], {
  cwd: ROOT,
  encoding: "utf8",
});

if (status.status !== 0) {
  console.error("frontend-drift: could not read git status");
  process.stderr.write(status.stderr ?? "");
  process.exit(1);
}

const lines = status.stdout.split("\n").filter((l) => l.trim() !== "");

if (lines.length === 0) {
  console.log("frontend-drift: build/ matches what the sources produce - OK");
  process.exit(0);
}

console.log("frontend-drift: build/ does not match what the sources produce.");
console.log("");
for (const line of lines) console.log(`  ${line}`);
console.log("");
console.log("Run 'npm run frontend:build' and commit build/ with the change that caused it.");
process.exit(1);
