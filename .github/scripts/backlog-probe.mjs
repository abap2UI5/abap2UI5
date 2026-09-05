#!/usr/bin/env node
/*
 * backlog-probe — measure a proposed rule against the code it would judge.
 *
 * A rule proposal written as prose asks a maintainer to take the author's word
 * for two things: that the defect is real, and that the rule can be written
 * without drowning everyone in false positives. The second is the one that
 * kills proposals, and it is also the one this ecosystem can simply ANSWER —
 * abap2UI5, samples, samples-controls and samples-stack are ~630 working apps
 * plus a framework, all in ABAP, all sitting next to each other on disk.
 *
 * So an item may ship a detector: `backlog/items/<id>.probe.mjs`, exporting
 *
 *   export const describe = 'one line: what this looks for'
 *   export function run(roots) -> { sites: [{repo, file, line, text}],
 *                                   negatives: [...],   // where it must NOT fire
 *                                   notes: [...] }      // limits of the detector
 *
 * `negatives` is the important half. "Fires 8 times" is a statistic; "fires 8
 * times, and here are the 3 places that look identical and are correct" is the
 * scope argument, which is what the proposal actually has to make.
 *
 * The result is written back into the item between markers, so the paste-ready
 * body carries the evidence, and cached in `backlog/probes.json` so the
 * generated pages can show the count. It is NOT re-run by `check:backlog`: the
 * sibling checkouts do not exist in CI, and a probe that silently answers 0
 * because a repository is missing would be worse than no probe. Each result
 * therefore records WHEN it ran and against WHICH checkouts, and says so on the
 * page.
 *
 * A detector is a throwaway approximation of a rule, not the rule. Where it
 * over- or under-approximates, `notes` has to say so — an inflated number that
 * a maintainer disproves in ten minutes costs more than no number at all.
 *
 *   node .github/scripts/backlog-probe.mjs            run every probe
 *   node .github/scripts/backlog-probe.mjs <id> …     run these
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import { roots } from './lib/abap-scan.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const ITEMS = path.join(ROOT, 'backlog', 'items');
const CACHE = path.join(ROOT, 'backlog', 'probes.json');

const want = process.argv.slice(2);
const { found, missing } = roots();
if (!found.length) {
  console.error('backlog-probe: no checkout found — nothing to measure against');
  process.exit(1);
}
if (missing.length) console.log(`not checked out, so not measured: ${missing.join(', ')}`);
console.log(`measuring against ${found.map((f) => f.repo).join(', ')}`);

const probes = fs.readdirSync(ITEMS).filter((n) => n.endsWith('.probe.mjs')).sort();
const cache = fs.existsSync(CACHE) ? JSON.parse(fs.readFileSync(CACHE, 'utf8')) : {};
const ran = new Date().toISOString().slice(0, 10);

for (const name of probes) {
  const id = name.replace(/\.probe\.mjs$/, '');
  if (want.length && !want.includes(id)) continue;
  const item = path.join(ITEMS, `${id}.md`);
  if (!fs.existsSync(item)) {
    console.error(`  ${id}: probe with no item — delete it or write backlog/items/${id}.md`);
    process.exitCode = 1;
    continue;
  }

  const mod = await import(pathToFileURL(path.join(ITEMS, name)).href);
  const result = mod.run(found) || {};
  const sites = result.sites || [];
  const negatives = result.negatives || [];
  const notes = result.notes || [];
  const repos = [...new Set(sites.map((s) => s.repo))];

  cache[id] = {
    describe: mod.describe || '',
    ran,
    checkouts: found.map((f) => f.repo),
    sites: sites.length,
    negatives: negatives.length,
    repos,
  };

  /* The block that goes into the item, i.e. into the issue. A table of
   * sites, then what the detector deliberately did not count.
   *
   * The backslash is escaped before the pipe: escaping only the pipe turns a
   * cell that already ends in a backslash into `\\|`, an escaped backslash
   * followed by a LIVE column separator, which breaks the row the escaping
   * exists to keep intact. */
  const cell = (s) => String(s ?? '').replace(/\\/g, '\\\\').replace(/\|/g, '\\|').trim();
  const table = (rows) => (rows.length
    ? ['| Repository | Where | |', '|---|---|---|',
      ...rows.map((r) => `| ${r.repo} | \`${r.file}\`${r.line ? `:${r.line}` : ''} | ${cell(r.text)} |`),
    ].join('\n')
    : '_none_');

  const block = [
    '<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->',
    '',
    '## Measured',
    '',
    `\`${id}.probe.mjs\` — ${mod.describe || 'no description'}.`,
    `Run **${ran}** against ${found.map((f) => `\`${f.repo}\``).join(', ')}`
      + `${missing.length ? ` (not checked out: ${missing.join(', ')})` : ''}.`,
    '',
    `**Would fire on ${sites.length} site(s)** in ${repos.length} repositor${repos.length === 1 ? 'y' : 'ies'}:`,
    '',
    table(sites),
    '',
    `**Must NOT fire on ${negatives.length} site(s)** that match the shape and are correct:`,
    '',
    table(negatives),
    ...(notes.length
      ? ['', '**Where the detector is an approximation of the rule:**', '',
        ...notes.map((n) => `- ${n}`)]
      : []),
    '',
    '<!-- probe:end -->',
  ].join('\n');

  let text = fs.readFileSync(item, 'utf8');
  const marked = /<!-- probe:start[\s\S]*?<!-- probe:end -->/;
  /* A function replacer, not the string: `block` is BUILT from the source
   * lines a probe found, and `$&`, `$\`` and `$'` in a string replacement are
   * back-references, not text. A quoted ABAP or JS line carrying `$&` - a
   * regex replacement is the obvious way to write one - would expand into the
   * whole block it was replacing, and the item would then say something no
   * probe ever measured. */
  text = marked.test(text) ? text.replace(marked, () => block) : `${text.trimEnd()}\n\n${block}\n`;
  fs.writeFileSync(item, text);

  console.log(`  ${id}: ${sites.length} site(s) in ${repos.join(', ') || '—'}, ${negatives.length} negative(s)`);
}

/* A cached result for an item or probe that is gone is a number nobody can
 * reproduce — the exact thing this file exists to avoid. */
for (const id of Object.keys(cache)) {
  if (!fs.existsSync(path.join(ITEMS, `${id}.probe.mjs`))) delete cache[id];
}

fs.writeFileSync(CACHE, `${JSON.stringify(cache, null, 2)}\n`);
console.log(`backlog-probe: ${Object.keys(cache).length} probe(s) cached in backlog/probes.json`);
