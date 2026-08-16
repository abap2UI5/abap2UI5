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
// "which file is the low one" is the question the list answers. The next one
// is always "and WHICH PART of it", so:
//
//   npm run coverage -- --detail src/02/z2ui5_cl_ui5_http_handler.clas.abap
//
// prints the uncovered line ranges of that file with their ABAP source, which
// is what a test has to be written against.
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

const detailArg = (() => {
  const i = process.argv.indexOf("--detail");
  return i === -1 ? null : process.argv[i + 1] || null;
})();

const run = spawnSync(
  "npx",
  ["c8", `--reporter=${detailArg ? "json" : "json-summary"}`, `--report-dir=${REPORT_DIR}`,
    "--src", "node/output", "node", OUTPUT],
  { stdio: ["ignore", "ignore", "inherit"] },
);
if (run.status !== 0) {
  console.error("the unit suite did not run to completion - fix that first");
  process.exit(run.status ?? 1);
}

if (detailArg) { detail(detailArg); process.exit(0); }

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

/* The uncovered line ranges of one ABAP file, with the source. c8's `json`
 * report carries per-statement hit counts against the mapped ABAP positions,
 * which is the same mapping the summary is built from - so this is the same
 * measurement, only not summed up. */
function detail(wanted) {
  const report = JSON.parse(readFileSync(`${REPORT_DIR}/coverage-final.json`, "utf8"));
  const want = wanted.replace(/^src\//, "");
  const entry = Object.entries(report)
    .find(([file]) => file.endsWith(`node/downport/${want}`));
  if (!entry) {
    console.error(`no coverage for ${wanted}.\n\n`
      + "Give a path as the report prints it, e.g.\n"
      + "  npm run coverage -- --detail src/02/z2ui5_cl_ui5_http_handler.clas.abap");
    process.exit(1);
  }
  const [, data] = entry;
  /* The line numbers belong to the DOWNPORT copy - that is the file the
   * transpiler read and the file its source map points at. Printing them
   * against src/ would be off by however much the downport moved, which is
   * exactly the kind of quietly-wrong output that sends someone testing the
   * wrong method. */
  const shown = `node/downport/${want}`;
  const cold = new Set();
  for (const [id, count] of Object.entries(data.s)) {
    if (count) continue;
    const loc = data.statementMap[id];
    for (let l = loc.start.line; l <= loc.end.line; l++) cold.add(l);
  }
  const hot = new Set();
  for (const [id, count] of Object.entries(data.s)) {
    if (!count) continue;
    const loc = data.statementMap[id];
    for (let l = loc.start.line; l <= loc.end.line; l++) hot.add(l);
  }
  const lines = readFileSync(shown, "utf8").split("\n");
  const missing = [...cold].filter((l) => !hot.has(l)).sort((a, b) => a - b);
  if (!missing.length) { console.log(`${wanted}: every mapped line is covered`); return; }

  console.log(`${shown} — ${missing.length} line(s) the unit suite never runs.`);
  console.log(`(the downport of ${wanted}; the transpiler read that copy, so the`);
  console.log(" line numbers are its own)\n");
  let from = missing[0];
  let prev = missing[0];
  const flush = () => {
    console.log(from === prev ? `  line ${from}` : `  lines ${from}-${prev}`);
    for (let l = from; l <= prev; l++) console.log(`    ${String(l).padStart(4)}  ${lines[l - 1] ?? ""}`);
    console.log("");
  };
  for (const l of missing.slice(1)) {
    if (l === prev + 1) { prev = l; continue; }
    flush();
    from = l;
    prev = l;
  }
  flush();
}
