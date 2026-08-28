#!/usr/bin/env node
/*
 * generate-backlog — the four backlogs, written from the items instead of by hand.
 *
 * A finding that outlives the change it came from has to go somewhere, and for
 * a long time it went into whichever file the author happened to be in: an
 * upstream compiler bug into `samples-controls/STATUS.md`, a linter rule
 * candidate into a skill's prose, a framework request into `samples-controls/pr/`.
 * Three shapes, three repositories, and no way to answer "what is there to file
 * against abaplint" without reading all of them.
 *
 * So the stock is ONE shape now — `backlog/items/<id>.md`, front matter plus the
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
 *   **Backlog:** abaplint · abaplint-delete-index-in-loop, abaplint-subrc-after-assign
 *   **Backlog:** open-abap · TODO: the transpiler's DELETE INDEX raises where ABAP sets sy-subrc
 *
 * The first form has to resolve to an item of that target - so a renamed or
 * deleted item is reported here rather than leaving the skill pointing at
 * nothing. The second is the raw form: a candidate somebody saw and did not
 * work out, listed in the backlog as raw stock so it is visible without
 * pretending to be ready.
 *
 *   node .github/scripts/generate-backlog.mjs          write the four pages
 *   node .github/scripts/generate-backlog.mjs --check  fail if stale (npm run check:backlog)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const BACKLOG = path.join(ROOT, 'backlog');
const ITEMS = path.join(BACKLOG, 'items');
const PROBES = path.join(BACKLOG, 'probes.json');
const MINED = path.join(BACKLOG, 'mined.json');
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

const REQUIRED = ['target', 'title', 'summary', 'priority', 'state', 'first_seen'];

/* How long an OPEN item may sit before the stock is lying about itself. Not a
 * failure - the point of a backlog is that things wait in it - but a printed
 * warning, because an item nobody has filed in three months is either not
 * important (delete it) or blocked (say by what). This is what `pr/` lacked:
 * five requests sat there for weeks and nothing ever said so. */
const STALE_DAYS = 90;

/* How long an OPEN item may sit before its `checked_upstream:` stops being
 * optional.
 *
 * backlog/README.md step 2 of "converting an item" says to search the upstream
 * tracker first and record the date, because filing a duplicate costs a
 * maintainer more than not filing at all - and the stock already inherited one
 * item whose "filed upstream" claim carried no link and could not be verified.
 * The field was optional, and NOT ONE item carried it: an instruction that
 * nothing asks for is an instruction nobody follows.
 *
 * It stays optional for a fresh item, because the first days of an item are
 * spent writing it rather than filing it, and a search done then is stale by
 * the time anyone acts on it. Past this age the item is a standing claim that
 * nothing exists upstream, and a claim nobody has re-checked in a month is one
 * the stock cannot stand behind. */
const UPSTREAM_CHECK_DAYS = 30;

const DAY = 86400000;
const ageInDays = (date) => Math.round((Date.now() - new Date(date)) / DAY);

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

/* A skill section's `**Backlog:**` line. Section level, like the `**Linter:**`
 * and `**Gate:**` lines next to it — a marker per bullet would be unreadable
 * and the decision is per section anyway. */
const MARKER = /^\*\*Backlog:\*\*\s+([a-z0-9-]+)\s+·\s+(.+?)\s*$/;

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
  const where = `backlog/items/${item.id}.md`;
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
  /* An open item older than UPSTREAM_CHECK_DAYS has to say when somebody last
   * looked upstream - see the constant. Only for `open`: a `filed` item names
   * the issue it produced, and a `deferred` one is not going to be filed. */
  if (
    item.meta.state === 'open'
    && item.meta.first_seen
    && ageInDays(item.meta.first_seen) > UPSTREAM_CHECK_DAYS
    && !item.meta.checked_upstream
  ) {
    problems.push(
      `${where}: open for ${ageInDays(item.meta.first_seen)} days with no \`checked_upstream:\`\n`
      + `    an item this old is a standing claim that nothing exists upstream. Search\n`
      + `    ${item.meta.upstream || targets.get(item.meta.target)?.upstream || 'the upstream tracker'} and record the date, or file it and set \`state: filed\``,
    );
  }
  if (!(item.meta.evidence || []).length) {
    problems.push(
      `${where}: no \`evidence:\` entries\n`
      + '    an item without a case that happened is a wish — name the app, commit, PR or run',
    );
  }
}

const probes = fs.existsSync(PROBES) ? JSON.parse(fs.readFileSync(PROBES, 'utf8')) : {};
const mined = fs.existsSync(MINED) ? JSON.parse(fs.readFileSync(MINED, 'utf8')) : { candidates: [] };

const { refs, raw } = readMarkers();
for (const ref of refs) {
  const item = byId.get(ref.id);
  if (!item) {
    problems.push(
      `${ref.where.file}:${ref.where.line}: names \`${ref.id}\`, which is no item under backlog/items/\n`
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

/* One markdown table cell. The backslash goes first: escaping only the pipe
 * turns a cell that already ends in a backslash into `\\|`, which is an
 * escaped backslash followed by a LIVE column separator - the row the
 * escaping exists to keep intact is the row it breaks. */
const cell = (s) => String(s ?? '').replace(/\\/g, '\\\\').replace(/\|/g, '\\|').trim();

function row(item, target) {
  const upstream = item.meta.upstream || target.upstream;
  const where = (refsById.get(item.id) || [])
    .map((w) => `[${w.heading || w.file}](../${w.file})`)
    .join(', ');
  /* The measurement, where the item ships a detector. This is the half a
   * maintainer reads first on a rule proposal — "would fire N times, and here
   * are the M places that look identical and are correct" — so it belongs in
   * the row, not only in the item. */
  const p = probes[item.id];
  const measured = p
    ? `<br><sub>measured ${p.ran}: fires on <b>${p.sites}</b> site(s)`
      + `${p.repos.length ? ` in ${p.repos.join(', ')}` : ''}`
      + `, ${p.negatives} correct look-alike(s)</sub>`
    : '';
  return `| [\`${item.id}\`](items/${item.id}.md) | ${cell(item.meta.summary)}`
    + `${where ? `<br><sub>written up in ${where}</sub>` : ''}`
    + `${measured}`
    + `${item.meta.filed ? `<br><sub>${cell(item.meta.filed)}</sub>` : ''}`
    + ` | ${cell(item.meta.priority)} | ${cell(item.meta.first_seen)} | ${cell(upstream)} |`;
}

function table(rows) {
  return ['| Item | What | Priority | In stock since | Upstream |',
    '|---|---|---|---|---|', ...rows].join('\n');
}

/* Age is deliberately NOT rendered. It would change every day, so every page
 * would go stale overnight and `check:backlog` would fail on a tree nobody
 * touched. The DATE is stable; the aging is reported to the console below,
 * where it can be as current as it likes. */

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
  const mineMined = (mined.candidates || []).filter((c) => c.target === target.key);
  if (mineRaw.length || mineMined.length) {
    const rows = [
      ...mineRaw.map((r) => `| ${cell(r.text)} | [${r.where.heading || r.where.file}](../${r.where.file}) |`),
      ...mineMined.map((c) => `| ${cell(c.text)} | ${cell(c.where)} |`),
    ];
    blocks.push(
      '## Raw stock\n\n'
      + '_Candidates nobody has worked out yet — named in a skill, or found by '
      + '`npm run backlog:mine`. Listed so they are visible, not so they can be '
      + 'filed: an item file has to be written first._\n\n'
      + ['| Candidate | Found in |', '|---|---|', ...rows].join('\n'),
    );
  }

  if (!blocks.length) blocks.push('_Empty. Nothing is waiting to be filed against this one._');

  counts.push(`${target.key} ${mine.length}+${mineRaw.length + mineMined.length}`);

  const page = `<!-- Generated by .github/scripts/generate-backlog.mjs. Do not edit by hand:
     edit backlog/items/<id>.md, run \`npm run backlog\` and commit the result. -->

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

_Generated from \`backlog/items/*.md\` and the \`**Backlog:**\` lines in
\`.claude/skills/\` — \`npm run backlog\`._
`;

  const out = path.join(BACKLOG, target.file);
  if (CHECK) {
    const current = fs.existsSync(out) ? fs.readFileSync(out, 'utf8') : '';
    if (current !== page) {
      console.error(`backlog/${target.file} is stale — run \`npm run backlog\` and commit the result.`);
      process.exit(1);
    }
  } else {
    fs.writeFileSync(out, page);
  }
}

console.log(
  `backlog: ${items.length} item(s), ${raw.length + (mined.candidates || []).length} raw candidate(s), `
  + `${refs.length} skill marker(s) — ${counts.join(' · ')}`
  + `${CHECK ? ' — pages current' : ' — pages written'}`,
);

/* Does the stock actually drain? A backlog nobody empties is a graveyard, and
 * the way you find out is not by reading it — it is by asking how old the
 * oldest thing in it is. Printed rather than gated: waiting is what a backlog
 * is for, and only a person can say whether a given wait is still reasonable. */
const byState = {};
for (const i of items) byState[i.meta.state] = (byState[i.meta.state] || 0) + 1;
const today = new Date();
const ageOf = (d) => Math.round((today - new Date(d)) / 86400000);

console.log(`  ${[...STATES].map(([s, spec]) => `${spec.label.toLowerCase()}: ${byState[s] || 0}`).join(' · ')}`);

const stale = items
  .filter((i) => i.meta.state === 'open' && ageOf(i.meta.first_seen) > STALE_DAYS)
  .sort((a, b) => ageOf(b.meta.first_seen) - ageOf(a.meta.first_seen));
if (stale.length) {
  console.log(`\n  ${stale.length} open item(s) older than ${STALE_DAYS} days — file it, or delete it:`);
  for (const i of stale) console.log(`    ${i.id}  ${ageOf(i.meta.first_seen)} days  (${i.meta.upstream || TARGETS.find((x) => x.key === i.meta.target).upstream})`);
} else {
  const open = items.filter((i) => i.meta.state === 'open');
  const oldest = open.sort((a, b) => ageOf(b.meta.first_seen) - ageOf(a.meta.first_seen))[0];
  if (oldest) console.log(`  oldest open: ${oldest.id}, ${ageOf(oldest.meta.first_seen)} days`);
}

/* A probe result that predates the item it measures is a number about code
 * that has since changed. Reported, not failed: the sibling checkouts are not
 * in CI, so re-running is a local act. */
const restale = items.filter((i) => probes[i.id] && probes[i.id].ran < i.meta.first_seen);
for (const i of restale) console.log(`  ${i.id}: probe ran ${probes[i.id].ran}, before the item — re-run \`npm run backlog:probe\``);
