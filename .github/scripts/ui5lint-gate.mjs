#!/usr/bin/env node
// Runs the UI5 linter and fails on ANY error - there is no error budget.
//
// Design-accepted findings are switched off where they occur: in JS files
// inline via ui5lint-disable comments with a stated reason, whole files
// (index.html, manifest.json) in app/ui5lint.config.mjs - see the comments
// there. Anything the linter still reports is a new finding and must be
// fixed or explicitly suppressed with a justification.
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { fileURLToPath } from "node:url";

const appDir = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
  "..",
  "app",
);

// ui5lint exits non-zero when it finds anything, so take stdout either way
const result = await promisify(execFile)(
  "npx",
  ["ui5lint", "--format", "json"],
  { cwd: appDir, maxBuffer: 64 * 1024 * 1024 },
).catch((e) => e);
if (result.stdout === undefined) throw result;

const files = JSON.parse(result.stdout);
const errors = files.reduce((sum, f) => sum + f.errorCount, 0);
const warnings = files.reduce((sum, f) => sum + f.warningCount, 0);

console.log(`ui5lint: ${errors} error(s), ${warnings} warning(s)`);

if (errors > 0) {
  console.error("\nui5lint reports errors - new findings were introduced:\n");
  for (const file of files) {
    for (const m of file.messages) {
      if (m.severity === 2) {
        console.error(
          `${file.filePath}:${m.line}:${m.column} ${m.ruleId} ${m.message}`,
        );
      }
    }
  }
  process.exit(1);
}
