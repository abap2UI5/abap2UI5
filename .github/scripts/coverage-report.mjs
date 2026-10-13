// What the unit suite actually covers, per ABAP file.
//
// Why this is possible at all: `npm run unit` runs the TRANSPILED sources, and
// the transpiler emits source maps that point back at the `.clas.abap` files.
// So V8's own coverage of the JavaScript, mapped back line by line, measures
// ABAP lines with ABAP line numbers - there is nothing ABAP-specific to build.
//
// Why V8's raw coverage and our own map decoding, not c8: c8 maps the JS
// coverage through the source map with v8-to-istanbul, and with the maps
// `@abaplint/transpiler-cli` 2.14 writes that answered 97% for the engine,
// with a cloud-only method (`rtti_get_dtel_texts_by_xco`, which calls XCO
// dynamically and can never run here) at 72 of 72 statements hit (2026-10-13;
// 2.13.99 had answered 72.6%). The raw V8 data has no such ambiguity: a
// function that never ran has count 0 over its whole range, and a block that
// never ran inside a function that did has a zero-count range of its own.
// Decoding the map ourselves is forty lines (base64 VLQ, one segment per JS
// line), and the ABAP line is covered when ANY JS line it maps to ran - which
// also folds the one-line instance wrapper the transpiler emits for every
// static method back onto the method it wraps.
//
// Why it is a report and not a gate: a coverage threshold is a number a build
// starts optimising for, and the useful question here is never "is it above
// 70" but "which file is the low one, and does that matter". The engine's low
// ones are named in docs/agents/commands.md with a reason; this command is
// how you check whether that is still true.
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
import { existsSync, readFileSync, readdirSync, rmSync, mkdirSync } from "fs";
import { spawnSync } from "child_process";
import { pathToFileURL, fileURLToPath } from "url";
import path from "path";

const OUTPUT = "node/output/index.mjs";
const REPORT_DIR = "node/coverage";
const V8_DIR = `${REPORT_DIR}/v8`;
const SKIP = [/^src\/00\/01\//, /^src\/00\/02\//, /^src\/99\//, /^src\/01\/03\//];

if (!existsSync(OUTPUT)) {
  console.error(`${OUTPUT} is not built.\n\nRun:  npm run downport && npm run auto_transpile`);
  process.exit(1);
}

rmSync(REPORT_DIR, { recursive: true, force: true });
mkdirSync(V8_DIR, { recursive: true });

const detailArg = (() => {
  const i = process.argv.indexOf("--detail");
  return i === -1 ? null : process.argv[i + 1] || null;
})();

const run = spawnSync(process.execPath, [OUTPUT], {
  stdio: ["ignore", "ignore", "inherit"],
  env: { ...process.env, NODE_V8_COVERAGE: path.resolve(V8_DIR) },
});
if (run.status !== 0) {
  console.error("the unit suite did not run to completion - fix that first");
  process.exit(run.status ?? 1);
}

/* ---- the source map: JS line -> ABAP lines ------------------------------ */

const B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/* The "mappings" of a v3 source map, decoded to one array per generated line
 * holding the ORIGINAL line (1-based) of every segment on it. Only the
 * original line is kept: this report counts lines, not columns. */
function decodeMappings(mappings) {
  const lines = [];
  let source = 0;
  let origLine = 0;
  let origCol = 0;
  let name = 0;
  for (const line of mappings.split(";")) {
    const out = [];
    let genCol = 0;
    for (const seg of line.split(",")) {
      if (!seg) continue;
      const fields = [];
      let shift = 0;
      let value = 0;
      for (const ch of seg) {
        const digit = B64.indexOf(ch);
        value += (digit & 31) << shift;
        if (digit & 32) {
          shift += 5;
        } else {
          fields.push(value & 1 ? -(value >> 1) : value >> 1);
          shift = 0;
          value = 0;
        }
      }
      genCol += fields[0];
      if (fields.length > 1) {
        source += fields[1];
        origLine += fields[2];
        origCol += fields[3];
        if (fields.length > 4) name += fields[4];
        out.push(origLine + 1);
      }
    }
    lines.push(out);
  }
  return lines;
}

/* ---- the coverage: which JS lines ran -------------------------------------
 *
 * V8 reports, per function, nested ranges with a count; a range with count 0
 * is code that never ran. A JS line is cold when every character of it that
 * is not blank sits in a zero-count range, hot otherwise. Module code outside
 * any function ran when the module loaded, which it did (the suite imported
 * every test class, and a test class imports what it tests). */
function jsLineHeat(source, functions) {
  // V8's ranges nest: a function's range, blocks inside it, and functions
  // inside those - and the class's `<instance_members_initializer>` spans
  // the whole class body with count 0 when no instance was ever built,
  // while the static methods inside it ran. So the ranges are applied from
  // the outside in, the widest first, and the innermost range decides what
  // a character's count is
  const ranges = [];
  for (const fn of functions) for (const range of fn.ranges) ranges.push(range);
  ranges.sort((a, b) => (b.endOffset - b.startOffset) - (a.endOffset - a.startOffset));
  const cold = new Uint8Array(source.length);
  for (const range of ranges) cold.fill(range.count === 0 ? 1 : 0, range.startOffset, range.endOffset);
  const heat = [];
  let offset = 0;
  for (const line of source.split("\n")) {
    const end = offset + line.length;
    let hot = false;
    let code = false;
    for (let k = offset; k < end; k++) {
      if (source[k] === " " || source[k] === "\t" || source[k] === "\r") continue;
      code = true;
      if (!cold[k]) { hot = true; break; }
    }
    heat.push(code ? hot : null);
    offset = end + 1;
  }
  return heat;
}

/* ---- per ABAP file: covered and uncovered lines --------------------------- */

const scripts = new Map();
for (const file of readdirSync(V8_DIR)) {
  const json = JSON.parse(readFileSync(path.join(V8_DIR, file), "utf8"));
  for (const script of json.result) {
    if (!script.url.startsWith("file://")) continue;
    const prev = scripts.get(script.url);
    if (!prev) {
      scripts.set(script.url, script);
      continue;
    }
    // more than one process reported the same module (not the case for
    // `npm run unit`, which is one process): a range that ran anywhere ran
    for (const fn of script.functions) {
      const match = prev.functions.find((f) => f.ranges[0].startOffset === fn.ranges[0].startOffset
        && f.ranges[0].endOffset === fn.ranges[0].endOffset);
      if (!match) { prev.functions.push(fn); continue; }
      for (const range of fn.ranges) {
        const same = match.ranges.find((r) => r.startOffset === range.startOffset && r.endOffset === range.endOffset);
        if (same) same.count = Math.max(same.count, range.count);
        else match.ranges.push(range);
      }
    }
  }
}

/* abap source path (as the map names it, resolved) -> { hot: Set, cold: Set } */
const perAbap = new Map();
for (const [url, script] of scripts) {
  const jsPath = fileURLToPath(url);
  const mapPath = `${jsPath}.map`;
  if (!existsSync(mapPath)) continue;
  const map = JSON.parse(readFileSync(mapPath, "utf8"));
  if (!map.sources || map.sources.length !== 1) continue;
  const abapPath = path.resolve(path.dirname(jsPath), map.sources[0]);
  const source = readFileSync(jsPath, "utf8");
  const heat = jsLineHeat(source, script.functions);
  // the one-line instance wrapper the transpiler emits for every static
  // method (`async m(INPUT) { return cls.m(INPUT); }`) maps onto the METHOD
  // line and never runs when callers use the static - it is not the
  // method, so it does not vote
  const jsLines = source.split("\n");
  jsLines.forEach((line, i) => {
    if (/^\s+async [a-z0-9_$]+\(INPUT\) \{$/.test(line)
      && /^\s+return [a-z0-9_]+\.[a-z0-9_$]+\(INPUT\);$/.test(jsLines[i + 1] ?? "")
      && /^\s+\}$/.test(jsLines[i + 2] ?? "")) {
      heat[i] = null;
      heat[i + 1] = null;
      heat[i + 2] = null;
    }
  });
  const mapped = decodeMappings(map.mappings);
  const entry = perAbap.get(abapPath) ?? { hot: new Set(), cold: new Set() };
  mapped.forEach((abapLines, jsLine) => {
    const h = heat[jsLine];
    if (h === null || h === undefined) return;
    for (const l of abapLines) (h ? entry.hot : entry.cold).add(l);
  });
  perAbap.set(abapPath, entry);
}

const ROOT = process.cwd();
const rows = [];
let covered = 0;
let total = 0;
for (const [abapPath, { hot, cold }] of perAbap) {
  const rel = path.relative(ROOT, abapPath).split(path.sep).join("/");
  // the map points into the downport copy; the same path under src/ is the
  // file a developer edits
  const inDownport = rel.match(/^node\/downport\/(.*)$/);
  if (!inDownport) continue;
  const source = `src/${inDownport[1]}`;
  if (/\.testclasses\.abap$/.test(source)) continue;
  if (SKIP.some((rx) => rx.test(source))) continue;
  if (!existsSync(source)) continue;
  const missing = [...cold].filter((l) => !hot.has(l)).sort((a, b) => a - b);
  const lines = hot.size + missing.length;
  rows.push({ source, downport: rel, covered: hot.size, total: lines, pct: lines ? (100 * hot.size) / lines : 100, missing });
  covered += hot.size;
  total += lines;
}

if (detailArg) {
  detail(detailArg);
  process.exit(0);
}

rows.sort((a, b) => a.pct - b.pct || b.total - a.total);
console.log("Lines covered by npm run unit, least covered first:\n");
for (const row of rows) {
  console.log(
    `${`${row.pct.toFixed(2)}%`.padStart(7)}  ${String(row.covered).padStart(5)}/${String(row.total).padEnd(6)}  ${row.source}`,
  );
}
console.log(
  `\n${((100 * covered) / total).toFixed(1)}% of the engine — ${covered}/${total} lines in ${rows.length} files`,
);
console.log("(src/00/01, src/00/02, src/99 and the src/01/03 frontend carriers are out of scope - see the header)");

/* The uncovered line ranges of one ABAP file, with the source - the same
 * measurement as the summary, only not summed up. */
function detail(wanted) {
  const want = wanted.replace(/^src\//, "");
  const row = rows.find((r) => r.source === `src/${want}`);
  if (!row) {
    console.error(`no coverage for ${wanted}.\n\n`
      + "Give a path as the report prints it, e.g.\n"
      + "  npm run coverage -- --detail src/02/z2ui5_cl_ui5_http_handler.clas.abap");
    process.exit(1);
  }
  /* The line numbers belong to the DOWNPORT copy - that is the file the
   * transpiler read and the file its source map points at. Printing them
   * against src/ would be off by however much the downport moved, which is
   * exactly the kind of quietly-wrong output that sends someone testing the
   * wrong method. */
  const lines = readFileSync(row.downport, "utf8").split("\n");
  const missing = row.missing;
  if (!missing.length) { console.log(`${wanted}: every mapped line is covered`); return; }
  console.log(`${row.downport} — ${missing.length} line(s) the unit suite never runs.`);
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
