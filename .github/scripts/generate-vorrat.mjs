#!/usr/bin/env node
/*
 * generate-vorrat — the four backlogs, written from the items instead of by hand.
 *
 * A finding that outlives the change it came from has to go somewhere, and for
 * a long time it went into whichever file the author happened to be in: an
 * upstream compiler bug into `samples-controls/STATUS.md`, a linter rule
 * candidate into a skill's prose, a framework request into `samples-controls/pr/`.
 * Three shapes, three repositories, and no way to answer "what is there to file
 * against abaplint" without reading all of them.
 *
 * So the stock is ONE shape now — `vorrat/items/<id>.md`, front matter plus the
 * body that becomes the issue — and this script sorts it into the four
 * backlogs by the `target` field. The pages are generated because a
 * hand-maintained index is exactly what rots: `pr/README.md` carried an "Open"
 * table that had to be edited in the same change as the folder, and twice it
 * was not.
 *
 * The point of the split is that each backlog is filed somewhere else:
 *
 *   open-abap         the compiler stack under the transpiled build -
 *                     open-abap/open-abap-core and abaplint/transpiler
 *   abaplint          abaplint/abaplint - rules about ABAP as a language
 *   abap2ui5-linter   abap2UI5/linter - rules about an abap2UI5 app and its view
 *   abap2ui5          abap2UI5/abap2UI5 - the framework itself
 *
 * Nothing here converts an item into an issue. That step is deliberately a
 * human one: the stock is assembled automatically so that nothing is lost, and
 * emptied by hand so that nothing is filed nobody stands behind.
 *
 * The skills stay the place a finding is first written down (they are the
 * staging area `skill-rule-gate.mjs` describes). A skill section names what it
 * put in the stock with a line of its own:
 *
 *   **Vorrat:** abaplint · abaplint-delete-index-in-loop, abaplint-subrc-after-assign
 *   **Vorrat:** open-abap · TODO: the transpiler's DELETE INDEX raises where ABAP sets sy-subrc
 *
 * The first form has to resolve to an item of that target - so a renamed or
 * deleted item is reported here rather than leaving the skill pointing at
 * nothing. The second is the raw form: a candidate somebody saw and did not
 * work out, listed in the backlog as raw stock so it is visible without
 * pretending to be ready.
 *
 *   node .github/scripts/generate-vorrat.mjs          write the four pages
 *   node .github/scripts/generate-vorrat.mjs --check  fail if stale (npm run check:vorrat)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const VORRAT = path.join(ROOT, 'vorrat');
const ITEMS = path.join(VORRAT, 'items');
const SKILLS = path.join(ROOT, '.claude', 'skills');
const CHECK = process.argv.includes('--check');

/* One backlog per place a finding gets filed. `upstream` is the default the
 * items of that target inherit; an item may name a different one (the
 * open-abap stock is two repositories, because the compiler and the transpiler
 * that drives it are), and then the row says so. */
const TARGETS = [
  {
    key: 'open-abap',
    file: 'OPEN-ABAP.md',
    title: 'Open ABAP — the compiler stack',
    upstream: 'open-abap/open-abap-core',
    what:
      'Everything the transpiled build hits that a real ABAP system does not. '
      + 'Two upstreams: `open-abap/open-abap-core` is the runtime library, '
      + '`abaplint/transpiler` is what turns ABAP into the JS that calls it — '
      + 'the row names which one.',
    why:
      'These are the expensive ones. The transpiled backend is what the Pages '
      + 'demos, the e2e harness and `npm run unit` all run on, so a divergence '
      + 'here is not a curiosity: it makes correct ABAP fail in the one place '
      + 'anybody can try it without a system.',
  },
  {
    key: 'abaplint',
    file: 'ABAPLINT.md',
    title: 'abaplint — rules about ABAP itself',
    upstream: 'abaplint/abaplint',
    what:
      'Defects that are decidable from ABAP source alone and that no rule of '
      + 'the 188 abaplint ships decides today.',
    why:
      'Everything here shipped once. An entry is not "a rule that would be '
      + 'nice" but "a rule that would have caught this", with the sites it '
      + 'would have fired on named — which is also the honest test of whether '
      + 'it can be written without false positives.',
  },
  {
    key: 'abap2ui5-linter',
    file: 'ABAP2UI5-LINTER.md',
    title: 'abap2UI5 linter — rules about an app and its view',
    upstream: 'abap2UI5/linter',
    what:
      'What the view linter could decide and does not. Its input is app '
      + 'classes and the view they build, so a candidate has to be decidable '
      + 'from those — a rule needing a running app or a system belongs in a '
      + 'skill, not here.',
    why:
      'The linter is the only check that reaches a consumer\'s own app. A '
      + 'defect left as prose is a defect only the people who read the prose '
      + 'avoid.',
  },
  {
    key: 'abap2ui5',
    file: 'ABAP2UI5.md',
    title: 'abap2UI5 — the framework',
    upstream: 'abap2UI5/abap2UI5',
    what:
      'API gaps found by building something the framework could not express. '
      + 'Every one of these came out of a port or an app, never out of a '
      + 'design review.',
    why:
      'This half of the stock used to live in `abap2UI5/samples-controls` '
      + 'under `pr/`, one folder per request, which put a request about THIS '
      + 'repository in another one — findable only by somebody who already '
      + 'knew the corpus existed.',
  },
];

const STATES = new Map([
  ['open', { label: 'Ready to file', order: 0, note: 'nothing exists upstream yet — this is the stock' }],
  ['filed', { label: 'Filed upstream', order: 1, note: 'an issue or PR exists; the item goes when it merges' }],
  ['deferred', { label: 'Deferred', order: 2, note: 'a decision was made not to do this now, and why' }],
]);

const PRIORITIES = ['high', 'medium', 'low'];

const REQUIRED = ['target', 'title', 'summary', 'priority', 'state'];

/* Front matter, minimally: `key: value` and `key:` followed by `  - item`
 * lines. Deliberately not a YAML dependency — the schema is six keys and the
 * gate below is what actually guards it. */
function parseItem(file) {
  const text = fs.readFileSync(file, 'utf8');
  const m = /^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/.exec(text);
  if (!m) throw new Error(`${path.relative(ROOT, file)}: no front matter block`);
  const meta = {};
  let list = null;
  for (const raw of m[1].split(/\r?\n/)) {
    if (!raw.trim()) continue;
    const bullet = /^\s+-\s+(.*)$/.exec(raw);
    if (bullet) {
      if (!list) throw new Error(`${path.relative(ROOT, file)}: list item outside a key: ${raw}`);
      meta[list].push(bullet[1].trim());
      continue;
    }
    const kv = /^([a-z_]+):\s*(.*)$/.exec(raw);
    if (!kv) throw new Error(`${path.relative(ROOT, file)}: cannot read front matter line: ${raw}`);
    if (kv[2] === '') { list = kv[1]; meta[list] = []; continue; }
    list = null;
    meta[kv[1]] = kv[2].trim();
  }
  return { id: path.basename(file, '.md'), file, meta, body: m[2] };
}

/* A skill section's `**Vorrat:**` line. Section level, like the `**Linter:**`
 * and `**Gate:**` lines next to it — a marker per bullet would be unreadable
 * and the decision is per section anyway. */
const MARKER = /^\*\*Vorrat:\*\*\s+([a-z0-9-]+)\s+·\s+(.+?)\s*$/;

function markdownFiles(dir, out = []) {
  for (const name of fs.readdirSync(dir).sort()) {
    const full = path.join(dir, name);
    if (fs.statSync(full).isDirectory()) markdownFiles(full, out);
    else if (full.endsWith('.md')) out.push(full);
  }
  return out;
}

function readMarkers() {
  const refs = [];
  const raw = [];
  for (const file of markdownFiles(SKILLS)) {
    const rel = path.relative(ROOT, file).split(path.sep).join('/');
    const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
    // the nearest heading above the marker — what the backlog row cites as
    // where the finding is written up, so a reader lands on the analysis
    let heading = '';
    lines.forEach((line, i) => {
      const h = /^#{2,4}\s+(.+?)\s*$/.exec(line);
      if (h) { heading = h[1].trim(); return; }
      const m = MARKER.exec(line);
      if (!m) return;
      const [, target, rest] = m;
      const where = { file: rel, line: i + 1, heading };
      if (rest.startsWith('TODO:')) raw.push({ target, text: rest.slice(5).trim(), where });
      else for (const id of rest.split(',').map((s) => s.trim()).filter(Boolean)) refs.push({ target, id, where });
    });
  }
  return { refs, raw };
}

// ---------------------------------------------------------------- read + gate

const problems = [];
const items = [];
for (const name of fs.existsSync(ITEMS) ? fs.readdirSync(ITEMS).sort() : []) {
  if (!name.endsWith('.md')) continue;
  try {
    items.push(parseItem(path.join(ITEMS, name)));
  } catch (e) {
    problems.push(e.message);
  }
}

const byId = new Map(items.map((i) => [i.id, i]));
const targets = new Map(TARGETS.map((t) => [t.key, t]));

for (const item of items) {
  const where = `vorrat/items/${item.id}.md`;
  for (const key of REQUIRED) {
    if (!item.meta[key]) problems.push(`${where}: front matter is missing \`${key}\``);
  }
  if (item.meta.target && !targets.has(item.meta.target)) {
    problems.push(
      `${where}: target \`${item.meta.target}\` is none of ${[...targets.keys()].join(', ')}\n`
      + '    a fifth backlog is a decision — add it to TARGETS in this script with what it is for',
    );
  }
  if (item.meta.priority && !PRIORITIES.includes(item.meta.priority)) {
    problems.push(`${where}: priority \`${item.meta.priority}\` is none of ${PRIORITIES.join(', ')}`);
  }
  if (item.meta.state && !STATES.has(item.meta.state)) {
    problems.push(`${where}: state \`${item.meta.state}\` is none of ${[...STATES.keys()].join(', ')}`);
  }
  /* A filed item without the link is the failure mode this whole file exists
   * to prevent: it reads as handled while nobody can check what happened to
   * it. An implemented one has no state at all — it leaves the stock. */
  if (item.meta.state === 'filed' && !item.meta.filed) {
    problems.push(
      `${where}: state is \`filed\` but no \`filed:\` url\n`
      + '    name the issue or PR, or set the state back to `open`',
    );
  }
  if (!(item.meta.evidence || []).length) {
    problems.push(
      `${where}: no \`evidence:\` entries\n`
      + '    an item without a case that happened is a wish — name the app, commit, PR or run',
    );
  }
}

const { refs, raw } = readMarkers();
for (const ref of refs) {
  const item = byId.get(ref.id);
  if (!item) {
    problems.push(
      `${ref.where.file}:${ref.where.line}: names \`${ref.id}\`, which is no item under vorrat/items/\n`
      + '    the item was renamed or removed — fix the marker, or drop it',
    );
    continue;
  }
  if (item.meta.target !== ref.target) {
    problems.push(
      `${ref.where.file}:${ref.where.line}: files \`${ref.id}\` under \`${ref.target}\`, `
      + `but the item says \`${item.meta.target}\``,
    );
  }
}
for (const r of raw) {
  if (!targets.has(r.target)) {
    problems.push(`${r.where.file}:${r.where.line}: target \`${r.target}\` is not a backlog`);
  }
}

if (problems.length) {
  console.error(`${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}

// -------------------------------------------------------------------- render

const refsById = new Map();
for (const ref of refs) {
  if (!refsById.has(ref.id)) refsById.set(ref.id, []);
  refsById.get(ref.id).push(ref.where);
}

const cell = (s) => String(s ?? '').replace(/\|/g, '\\|').trim();

function row(item, target) {
  const upstream = item.meta.upstream || target.upstream;
  const where = (refsById.get(item.id) || [])
    .map((w) => `[${w.heading || w.file}](../${w.file})`)
    .join(', ');
  return `| [\`${item.id}\`](items/${item.id}.md) | ${cell(item.meta.summary)}`
    + `${where ? `<br><sub>written up in ${where}</sub>` : ''}`
    + `${item.meta.filed ? `<br><sub>${cell(item.meta.filed)}</sub>` : ''}`
    + ` | ${cell(item.meta.priority)} | ${cell(upstream)} |`;
}

function table(rows) {
  return ['| Item | What | Priority | Upstream |', '|---|---|---|---|', ...rows].join('\n');
}

const counts = [];

for (const target of TARGETS) {
  const mine = items.filter((i) => i.meta.target === target.key);
  const blocks = [];

  for (const [state, spec] of [...STATES].sort((a, b) => a[1].order - b[1].order)) {
    const group = mine
      .filter((i) => i.meta.state === state)
      .sort((a, b) => PRIORITIES.indexOf(a.meta.priority) - PRIORITIES.indexOf(b.meta.priority)
        || a.id.localeCompare(b.id));
    if (!group.length) continue;
    blocks.push(`## ${spec.label}\n\n_${spec.note}_\n\n${table(group.map((i) => row(i, target)))}`);
  }

  const mineRaw = raw.filter((r) => r.target === target.key);
  if (mineRaw.length) {
    blocks.push(
      '## Raw stock\n\n'
      + '_Named in a skill and not worked out. Listed so it is visible, not so '
      + 'it can be filed — an item file has to be written first._\n\n'
      + ['| Candidate | Written down in |', '|---|---|',
        ...mineRaw.map((r) => `| ${cell(r.text)} | [${r.where.heading || r.where.file}](../${r.where.file}) |`),
      ].join('\n'),
    );
  }

  if (!blocks.length) blocks.push('_Empty. Nothing is waiting to be filed against this one._');

  counts.push(`${target.key} ${mine.length}+${mineRaw.length}`);

  const page = `<!-- Generated by .github/scripts/generate-vorrat.mjs. Do not edit by hand:
     edit vorrat/items/<id>.md, run \`npm run vorrat\` and commit the result. -->

# ${target.title}

${target.what}

${target.why}

Each item below is a whole file — motivation, current behaviour with source
references, the proposed change, an example — written so it can be **pasted
into an issue as it stands**. Converting one is a human step on purpose: the
stock fills itself so nothing is lost, and empties by hand so nothing is filed
that nobody stands behind. See [README](README.md) for the mechanism.

---

${blocks.join('\n\n---\n\n')}

---

_Generated from \`vorrat/items/*.md\` and the \`**Vorrat:**\` lines in
\`.claude/skills/\` — \`npm run vorrat\`._
`;

  const out = path.join(VORRAT, target.file);
  if (CHECK) {
    const current = fs.existsSync(out) ? fs.readFileSync(out, 'utf8') : '';
    if (current !== page) {
      console.error(`vorrat/${target.file} is stale — run \`npm run vorrat\` and commit the result.`);
      process.exit(1);
    }
  } else {
    fs.writeFileSync(out, page);
  }
}

console.log(
  `vorrat: ${items.length} item(s), ${raw.length} raw candidate(s), `
  + `${refs.length} skill marker(s) — ${counts.join(' · ')}`
  + `${CHECK ? ' — pages current' : ' — pages written'}`,
);
