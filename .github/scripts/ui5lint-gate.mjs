#!/usr/bin/env node
// Gates the UI5 linter on a fixed error baseline.
//
// ui5lint cannot deactivate individual rules via its config file yet, and
// most of the existing findings are design-accepted: the z2ui5.* globals are
// the documented public frontend contract (see AGENTS.md / core/AppState.js),
// the sap.ui.getCore() fallbacks keep old UI5 releases working, and the
// manifest v2 migration is pending. This gate keeps CI green on those
// accepted findings but FAILS the build when new errors are introduced.
//
// Lower MAX_ERRORS whenever findings are fixed so the baseline only shrinks.
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { fileURLToPath } from "node:url";

const MAX_ERRORS = 128;

const appDir = path.join(
  path.dirname(fileURLToPath(import.meta.url)),
  "..",
  "..",
  "app",
);

// ui5lint exits non-zero when it finds anything, so take stdout either way
const result = await promisify(execFile)(
  "npx",
  ["ui5lint", "--ignore-pattern", "webapp/index.html", "--format", "json"],
  { cwd: appDir, maxBuffer: 64 * 1024 * 1024 },
).catch((e) => e);
if (result.stdout === undefined) throw result;

const files = JSON.parse(result.stdout);
const errors = files.reduce((sum, f) => sum + f.errorCount, 0);
const warnings = files.reduce((sum, f) => sum + f.warningCount, 0);

const byRule = {};
for (const file of files) {
  for (const m of file.messages) {
    if (m.severity === 2) byRule[m.ruleId] = (byRule[m.ruleId] ?? 0) + 1;
  }
}
console.log(`ui5lint: ${errors} error(s), ${warnings} warning(s)`);
for (const [rule, count] of Object.entries(byRule).sort((a, b) => b[1] - a[1])) {
  console.log(`  ${rule}: ${count}`);
}

if (errors > MAX_ERRORS) {
  console.error(
    `\nui5lint reports ${errors} errors, above the accepted baseline of ` +
      `${MAX_ERRORS} - new findings were introduced:\n`,
  );
  for (const file of files) {
    for (const m of file.messages) {
      if (m.severity === 2) {
        console.error(`${file.filePath}:${m.line}:${m.column} ${m.ruleId} ${m.message}`);
      }
    }
  }
  process.exit(1);
}
if (errors < MAX_ERRORS) {
  console.log(
    `\nNice - only ${errors} errors, below the baseline of ${MAX_ERRORS}. ` +
      `Please lower MAX_ERRORS in .github/scripts/ui5lint-gate.mjs to lock this in.`,
  );
}
