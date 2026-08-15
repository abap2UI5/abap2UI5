// What the unit suite actually covers, per ABAP file.
//
// Why this is possible at all: `npm run unit` runs the TRANSPILED sources, and
// the transpiler emits source maps that point back at the `.clas.abap` files.
// So a JavaScript coverage tool measures ABAP lines, with ABAP line numbers -
// there is nothing ABAP-specific to build.
//
// Why it is a report and not a gate: a coverage threshold is a number a build
// starts optimising for, and the useful question here is never "is it above
// 70" but "which file is the low one, and does that matter". The engine's two
// low ones are named in AGENTS.md with a reason; this command is how you check
// whether that is still true.
//
// Scope - the framework's own engine, which is what the suite is for:
//   out  src/00/01, src/00/02   upstream mirrors, synced by a workflow
//   out  src/99                 frozen legacy code, zero consumers
//   out  src/01/03              the generated frontend carriers: one method
//                               returning a JS/XML literal, so they are 100%
//                               by construction and would be two thirds of
//                               the total, which flatters the number and says
//                               nothing about the engine
//   out  *.testclasses.abap     the tests themselves
//   out  anything not in src/   the transpile harness copies node/srv classes
//                               into the downport tree; they are not shipped
//
// Run:  npm run coverage      (needs `npm run downport && npm run auto_transpile` first)

import { existsSync, readFileSync, rmSync } from "fs";
import { spawnSync } from "child_process";

const OUTPUT = "node/output/index.mjs";
const REPORT_DIR = "node/coverage";
const SUMMARY = `${REPORT_DIR}/coverage-summary.json`;

const SKIP = [/^src\/00\/01\//, /^src\/00\/02\//, /^src\/99\//, /^src\/01\/03\//];

if (!existsSync(OUTPUT)) {
  console.error(`${OUTPUT} is not built.\n\nRun:  npm run downport && npm run auto_transpile`);
  process.exit(1);
}

rmSync(REPORT_DIR, { recursive: true, force: true });

const run = spawnSync(
  "npx",
  ["c8", "--reporter=json-summary", `--report-dir=${REPORT_DIR}`, "--src", "node/output",
    "node", OUTPUT],
  { stdio: ["ignore", "ignore", "inherit"] },
);
if (run.status !== 0) {
  console.error("the unit suite did not run to completion - fix that first");
  process.exit(run.status ?? 1);
}

const summary = JSON.parse(readFileSync(SUMMARY, "utf8"));
const rows = [];
let covered = 0;
let total = 0;

for (const [file, metrics] of Object.entries(summary)) {
  if (file === "total") continue;
  // the map points into the downport copy; the same path under src/ is the
  // file a developer edits
  const inDownport = file.match(/node\/downport\/(.*)$/);
  if (!inDownport) continue;
  const source = `src/${inDownport[1]}`;
  if (/\.testclasses\.abap$/.test(source)) continue;
  if (SKIP.some((rx) => rx.test(source))) continue;
  if (!existsSync(source)) continue;
  rows.push({ source, pct: metrics.lines.pct, covered: metrics.lines.covered, total: metrics.lines.total });
  covered += metrics.lines.covered;
  total += metrics.lines.total;
}

rows.sort((a, b) => a.pct - b.pct || b.total - a.total);

console.log("Lines covered by npm run unit, least covered first:\n");
for (const row of rows) {
  console.log(
    `${`${row.pct}%`.padStart(7)}  ${String(row.covered).padStart(5)}/${String(row.total).padEnd(6)}  ${row.source}`,
  );
}
console.log(
  `\n${((100 * covered) / total).toFixed(1)}% of the engine — ${covered}/${total} lines in ${rows.length} files`,
);
console.log("(src/00/01, src/00/02, src/99 and the src/01/03 frontend carriers are out of scope - see the header)");
