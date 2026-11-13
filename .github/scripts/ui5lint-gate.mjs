#!/usr/bin/env node
// Runs the UI5 linter and fails on ANY error - there is no error budget.
//
// Three UI5 projects are linted: bundle/ (the frontend, the source of the
// bundle the backend serves) and the two page apps around the embed control,
// app_source/ and app_npm/. The linter is the one installed in bundle/ - the
// page apps carry no lint tooling of their own - run with each project as
// its working directory.
//
// Design-accepted findings are switched off where they occur: in JS files
// inline via ui5lint-disable comments with a stated reason, whole files
// (manifest.json, the page apps' index.html) in the project's
// ui5lint.config.mjs - see the comments there. Anything the linter still
// reports is a new finding and must be fixed or explicitly suppressed with
// a justification.
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const PROJECTS = ["bundle", "app_source", "app_npm"];
const ui5lint = path.join(
  root,
  "bundle",
  "node_modules",
  ".bin",
  process.platform === "win32" ? "ui5lint.cmd" : "ui5lint",
);

let failed = false;
for (const project of PROJECTS) {
  // ui5lint exits non-zero when it finds anything, so take stdout either way
  const result = await promisify(execFile)(ui5lint, ["--format", "json"], {
    cwd: path.join(root, project),
    maxBuffer: 64 * 1024 * 1024,
    shell: process.platform === "win32",
  }).catch((e) => e);
  // A crashed linter reports itself, rather than dying in JSON.parse.
  // execFile's error object carries stdout as "" - not undefined - whenever
  // the child ran but wrote no JSON (a missing binary, an internal crash, a
  // banner on stdout), so an `=== undefined` guard let an empty string
  // through and the gate failed with "Unexpected end of JSON input" while
  // the real reason sat unread in stderr.
  if (!result.stdout || !result.stdout.trim()) {
    console.error(`ui5lint produced no JSON output for ${project}/ - it did not run to completion:`);
    console.error(result.stderr || result.message || result);
    process.exit(1);
  }

  const files = JSON.parse(result.stdout);
  const errors = files.reduce((sum, f) => sum + f.errorCount, 0);
  const warnings = files.reduce((sum, f) => sum + f.warningCount, 0);

  console.log(`ui5lint ${project}/: ${errors} error(s), ${warnings} warning(s)`);

  if (errors > 0) {
    failed = true;
    console.error(`\nui5lint reports errors in ${project}/ - new findings were introduced:\n`);
    for (const file of files) {
      for (const m of file.messages) {
        if (m.severity === 2) {
          console.error(
            `${project}/${file.filePath}:${m.line}:${m.column} ${m.ruleId} ${m.message}`,
          );
        }
      }
    }
  }
}
if (failed) process.exit(1);
