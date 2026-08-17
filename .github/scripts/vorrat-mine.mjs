#!/usr/bin/env node
/*
 * vorrat-mine — find backlog candidates nobody thought to write down.
 *
 * The `**Vorrat:**` markers in the skills are collection, not discovery:
 * somebody still has to notice a finding and record it. This is the other
 * half — a source that already knows about gaps and has never been asked.
 *
 * `abap2UI5/samples-controls` records, per port, every place the rebuild does
 * something the original UI5 sample does not: an `IMPROVISED` deviation in
 * `meta/<class>.json`. That set is the corpus' whole reason to exist ("expose
 * the functional gaps so they can be closed"), and a subset of it is by
 * definition *"the framework could not express this"* — which is the abap2UI5
 * backlog, written down weeks before anybody files anything.
 *
 * The classification is NOT redone here. `scripts/probes/improvised-cluster.mjs`
 * over there sorts every deviation into GAP / PROBE / REWORK / BOUNDARY /
 * POLICY and is the authority; this reads its `--json` and keeps the two
 * verdicts that mean "possibly a framework gap":
 *
 *   GAP    a framework gap
 *   PROBE  a SUSPECTED gap whose premise is unverified — measure before filing
 *
 * A family that already has an item is dropped, so what comes out is what
 * nobody has picked up. The result lands in `vorrat/mined.json` (committed)
 * and the generator renders it as raw stock — visible, and not pretending to
 * be ready: a candidate still needs an item file, and a PROBE still needs its
 * premise measured. Twice now a PROBE family has turned out to rest on a
 * premise that was simply wrong.
 *
 * Like the probes, this cannot run in CI — it needs the sibling checkout — so
 * the result records when it ran and against what.
 *
 *   node .github/scripts/vorrat-mine.mjs
 */
import fs from 'fs';
import path from 'path';
import { execFileSync } from 'child_process';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const ITEMS = path.join(ROOT, 'vorrat', 'items');
const OUT = path.join(ROOT, 'vorrat', 'mined.json');

const CORPUS = ['samples-controls', 'abap2UI5-api', 'ai-demokit']
  .map((d) => path.join(ROOT, '..', d))
  .find((d) => fs.existsSync(path.join(d, 'scripts', 'probes', 'improvised-cluster.mjs')));

if (!CORPUS) {
  console.error(
    'vorrat-mine: no samples-controls checkout next to this one\n'
    + '    clone https://github.com/abap2UI5/samples-controls as a sibling, or skip mining',
  );
  process.exit(1);
}

/* Verdicts worth surfacing. The other three are deliberately not mined:
 * REWORK is that repository's own port backlog, BOUNDARY is outside abap2UI5
 * by nature (browser-only APIs, sample-local JS) and POLICY is a corpus rule
 * working as decided — mining those would bury the two that matter. */
const WANTED = new Set(['GAP', 'PROBE']);

const raw = execFileSync(
  process.execPath,
  [path.join(CORPUS, 'scripts', 'probes', 'improvised-cluster.mjs'), '--json'],
  { cwd: CORPUS, encoding: 'utf8', maxBuffer: 32 * 1024 * 1024 },
);
const report = JSON.parse(raw);

if (!report.rows?.length) {
  console.error('vorrat-mine: the cluster probe reported no rows — has its output changed?');
  process.exit(1);
}
/* The verdict has to come from over there. Reconstructing it here would mean
 * two places deciding what counts as a framework gap, and they would disagree
 * within a month. */
if (report.rows.some((r) => r.verdict === undefined)) {
  console.error(
    'vorrat-mine: the cluster probe\'s --json carries no `verdict` per row\n'
    + '    update the samples-controls checkout (git pull) — without it, mining\n'
    + '    would have to re-classify here, which is exactly what it must not do',
  );
  process.exit(1);
}

const known = new Set(
  fs.readdirSync(ITEMS).filter((n) => n.endsWith('.md')).map((n) => n.replace(/\.md$/, '')),
);

// one candidate per FAMILY, not per deviation: a family is the thing somebody
// would file, and its ports are the evidence
const families = new Map();
const filed = new Set();
for (const row of report.rows) {
  if (!WANTED.has(row.verdict)) continue;
  /* A family that NAMES a request has already been through this: it was
   * filed, and (since a shipped request has its folder deleted) most likely
   * implemented, with the sidecar text left standing. Mining it would re-file
   * a closed gap - which `event-veto` did on the first run of this script. */
  if (row.pr) { filed.add(`${row.family} → ${row.pr}`); continue; }
  if (!families.has(row.family)) {
    families.set(row.family, { family: row.family, verdict: row.verdict, ports: [], label: row.label || '' });
  }
  families.get(row.family).ports.push(row.port);
}

const candidates = [];
const covered = [];
for (const f of [...families.values()].sort((a, b) => b.ports.length - a.ports.length)) {
  /* A family whose name already IS an item, or whose name the cluster probe
   * points at an item by, is picked up — no re-filing what is in the stock. */
  const item = [...known].find((id) => id.endsWith(f.family) || f.family.endsWith(id));
  if (item) { covered.push(`${f.family} → ${item}`); continue; }
  candidates.push({
    target: 'abap2ui5',
    text: `**${f.family}** (${f.verdict}) — ${f.label || 'no label'} · ${f.ports.length} port(s): ${f.ports.join(' ')}`,
    where: `mined from samples-controls \`meta/\` (IMPROVISED, verdict ${f.verdict})`,
  });
}

const ran = new Date().toISOString().slice(0, 10);
fs.writeFileSync(OUT, `${JSON.stringify({ ran, source: 'samples-controls improvised-cluster', total: report.total, candidates }, null, 2)}\n`);

console.log(`vorrat-mine: ${report.total} IMPROVISED deviation(s) classified over there`);
console.log(`  ${families.size} family/families with verdict ${[...WANTED].join('/')}`);
for (const c of filed) console.log(`    already filed as a request: ${c}`);
for (const c of covered) console.log(`    already in the stock: ${c}`);
console.log(`  ${candidates.length} candidate(s) written to vorrat/mined.json`);
if (!candidates.length) {
  console.log('  nothing new — the IMPROVISED mine is drained, which is what a closed');
  console.log('  gap harvest looks like. Re-run after the next porting batch.');
}
