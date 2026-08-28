#!/usr/bin/env node
/*
 * check-prose-names — an app class named in prose here is an app class that
 * exists, including when it lives in a sibling repository.
 *
 * The three sample READMEs carry the same learning-path table, and two of its
 * three rows name the OTHER repositories' overview apps. When samples-controls
 * renamed its overview to z2ui5_cl_smpc_app_000, its own README followed and
 * the two copies did not: `samples` and `samples-stack` went on telling every
 * reader to run `z2ui5_cl_dmo_app_overview`, a class that no longer exists
 * anywhere. Nothing failed, because nothing here reads the other repository.
 *
 * abap2UI5's prose-name-gate is the same idea one repository over, and it
 * stops exactly where this has to keep going: a name it does not own goes on
 * an EXTERNAL allowlist, which exempts it rather than checking it. The names
 * that go stale are precisely the foreign ones — a local rename breaks a local
 * gate, a foreign rename breaks nothing.
 *
 * So a foreign name is resolved against the repository that owns it, through
 * its generated SAMPLES.md — the catalogue that lists every class it ships,
 * and the same page a reader would look the name up in.
 *
 * Resolution, in order (shared-file-gate's, including the part that matters):
 *   a sibling CHECKOUT next to this one   (offline, and what a local run sees)
 *   raw.githubusercontent.com/<repo>/main (CI, and what is actually published)
 * When neither is reachable the run SAYS SO and passes: a gate must not go red
 * because github.com is unreachable, and must not claim to have verified
 * something it did not.
 *
 * ONE SOURCE, AND IT IS abap2UI5's `.github/shared/check-prose-names.mjs`. The
 * three repositories that run it carry it byte-equal as
 * `scripts/check-prose-names.mjs`; change the source first and copy it to all
 * three, and abap2UI5's `npm run check:shared` is what notices when that did
 * not happen. Its `scripts/prose-absent.json` is NOT shared — see below.
 *
 * The framework does not run this script. Its own `prose-name-gate.mjs` is a
 * different program for a different job: it reads one repository's tree and
 * puts every FOREIGN name on an allowlist, which is exactly the case this one
 * exists to resolve rather than exempt. They are not two copies of one check
 * and must not be merged.
 *
 *   node scripts/check-prose-names.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

/* Which repository owns which class prefix. The prefix IS the owner here —
 * that is what the namespace tokens were chosen for. */
const OWNER = [
  { re: /^z2ui5_cl_smpc_/i, repo: 'samples-controls' },
  { re: /^z2ui5_cl_smps_/i, repo: 'samples-stack' },
  { re: /^z2ui5_cl_smp_/i, repo: 'samples' },
  /* Everything else in the namespace is the framework's. Resolved by file,
   * since abap2UI5 ships no catalogue - and only from a checkout, because a
   * raw URL cannot list a directory. Unreachable is a note, not a failure. */
  { re: /^z2ui5_/i, repo: 'abap2UI5', byFile: true },
];

/* Prose only. src/ is ABAP and belongs to abaplint; the generated catalogue is
 * written FROM the classes, so checking it would only ever confirm itself. */
const PROSE = ['README.md', 'CONTRIBUTING.md', 'AGENTS.md', 'CLAUDE.md', 'TRAINING.md', 'STATUS.md', 'CAPABILITIES.md', 'E2E.md'];

/* And every markdown file under docs/, recursively.
 *
 * The root list above is a closed set of file names, which is why `docs/` was
 * outside the gate entirely: a page moved into that folder left the check
 * without anything saying so. samples-controls' `docs/upstream-requests.md`
 * cites class and control names in almost every paragraph and had never been
 * read by this script - it is where a stale pin claim survived - and its
 * journal moved to `docs/history.md` from a root file the exclusion below
 * still named.
 *
 * A directory rather than more file names on purpose: the failure this fixes
 * is a page being ADDED or MOVED, and a closed list cannot notice either. A
 * repository without a `docs/` folder contributes nothing, so this is inert
 * in the consumers that do not have one. */
const PROSE_DIRS = ['docs'];

/* A journal records what a class was called when the entry was written; that
 * is history, not drift. Same reasoning as abap2UI5's changelog cut-off.
 *
 * It used to name `STATUS-history.md`, a root file that no longer exists in
 * any consumer - so the exclusion had quietly stopped excluding anything, and
 * would have started reporting the moment `docs/` came into scope:
 * samples-controls' `docs/history.md` names `z2ui5_cl_smpc_app_overview`
 * three times, in entries written before that class was renamed, and every
 * one of them is correct as a record of what happened. */
const HISTORY = /(^|\/)history\.md$/i;

/* The other half of the prose, and in a sample repository the bigger half.
 * Every port carries a `meta/<class>.json` whose `deviations[].what`,
 * `audit.note` and `checked.note` are long-form sentences — samples-controls'
 * own AGENTS.md calls a deviation "a log entry about a process" and puts it
 * there BECAUSE it is prose — and those sentences cite sibling ports
 * constantly. They were out of scope until 2026-08-24, which is how
 * `meta/z2ui5_cl_smpc_app_038.json` kept citing the retired
 * `z2ui5_cl_demo_app_038` through a corpus-wide sweep that reported itself
 * finished. It travels further than a sidecar suggests: generate-overview.mjs
 * bakes these texts into ABAP that gets pulled into a customer system.
 *
 * Read as a second scope rather than as more entries in PROSE, because the
 * files are JSON and the reader differs. NOT the sidecar's own `class` field,
 * which names the port the file belongs to and would double every port into
 * the count. A repository with no `meta/` contributes nothing, so this is
 * inert in the consumers that do not use sidecars. */
const SIDECARS = 'meta';
const SIDECAR_PROSE = (file) => {
  const out = [];
  let doc;
  try { doc = JSON.parse(fs.readFileSync(file, 'utf8')); } catch { return out; }
  const at = path.relative(ROOT, file);
  (doc.deviations ?? []).forEach((d, i) => {
    if (typeof d?.what === 'string') out.push({ label: `${at} deviations[${i}].what`, text: d.what });
  });
  for (const [key, holder] of [['audit', doc.audit], ['checked', doc.checked]]) {
    if (typeof holder?.note === 'string') out.push({ label: `${at} ${key}.note`, text: holder.note });
  }
  return out;
};

/* Names that are meant to be absent, from `scripts/prose-absent.json` — one
 * per repository, because what a repository deliberately names in the past
 * tense is its own business. Each needs its reason, so an entry cannot become
 * a silent hole; a blank reason fails the run. abap2UI5's prose-name-gate
 * carries the same rule, for the same reason: an allowlist without a why is a
 * way to make a gate stop asking.
 *
 * The SCRIPT is byte-identical in samples, samples-controls and samples-stack
 * (as check-app-rules.mjs is) - only this file differs, and deliberately: it
 * is the one part of the check each repository decides for itself. */
const ABSENT = (() => {
  const at = path.join(ROOT, 'scripts', 'prose-absent.json');
  if (!fs.existsSync(at)) return new Map();
  const raw = JSON.parse(fs.readFileSync(at, 'utf8'));
  const bad = Object.entries(raw).filter(([, why]) => !String(why).trim());
  if (bad.length) {
    console.error(`prose-absent.json: ${bad.map(([n]) => n).join(', ')} carry no reason`);
    process.exit(1);
  }
  return new Map(Object.entries(raw).map(([n, why]) => [n.toLowerCase(), why]));
})();

const here = (() => {
  const names = new Set();
  const walk = (dir) => {
    if (!fs.existsSync(dir)) return;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const f = path.join(dir, e.name);
      if (e.isDirectory()) walk(f);
      else if (e.name.endsWith('.clas.abap')) names.add(e.name.replace('.clas.abap', '').toLowerCase());
    }
  };
  walk(path.join(ROOT, 'src'));
  return names;
})();

/* Where a sibling repository is, if it is here at all. The environment wins,
 * the way it does for abap2UI5/mcp-server's resolvers - and it has to: a CI runner
 * cannot check a repository out ABOVE the workspace, so `../<repo>` is a local
 * convenience and the variable is what CI uses. */
const HOMES = {
  samples: 'SAMPLES_HOME',
  'samples-controls': 'SAMPLES_CONTROLS_HOME',
  'samples-stack': 'SAMPLES_STACK_HOME',
  abap2UI5: 'A2UI5_HOME',
};

function checkoutOf(repo) {
  const fromEnv = process.env[HOMES[repo]];
  if (fromEnv && fs.existsSync(fromEnv)) return fromEnv;
  const sibling = path.join(ROOT, '..', repo);
  return fs.existsSync(sibling) ? sibling : null;
}

const raw = (repo) => `https://raw.githubusercontent.com/abap2UI5/${repo}/main/SAMPLES.md`;

/* Every class a checkout ships, by file name. Read once. */
let frameworkCache = null;
function frameworkClasses(root) {
  if (frameworkCache) return frameworkCache;
  const names = new Set();
  const walk = (dir) => {
    if (!fs.existsSync(dir)) return;
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const f = path.join(dir, e.name);
      if (e.isDirectory()) walk(f);
      else if (e.name.endsWith('.clas.abap')) names.add(e.name.replace('.clas.abap', '').toLowerCase());
    }
  };
  walk(path.join(root, 'src'));
  frameworkCache = names;
  return names;
}
const notes = [];
const catalogues = new Map();

async function catalogueOf(repo) {
  if (catalogues.has(repo)) return catalogues.get(repo);
  const at = checkoutOf(repo);
  const local = at && path.join(at, 'SAMPLES.md');
  let text = null;
  if (local && fs.existsSync(local)) text = fs.readFileSync(local, 'utf8');
  else {
    try {
      const res = await fetch(raw(repo), { signal: AbortSignal.timeout(15000) });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      text = await res.text();
    } catch (err) {
      notes.push(`${repo}: not reachable (${err.message}) — names it owns were not checked`);
    }
  }
  const set = text ? new Set([...text.matchAll(/\b(z2ui5_cl_[a-z0-9_]+)\b/gi)].map((m) => m[1].toLowerCase())) : null;
  catalogues.set(repo, set);
  return set;
}

const problems = [];
let checked = 0;

/* Both scopes reduce to the same thing: a labelled piece of prose. Everything
 * below — the regex, ABSENT, the ecosystem-wide resolution including the
 * foreign SAMPLES.md lookup — then runs over sidecar text unchanged, which is
 * the whole reason to do this in the shared script rather than beside it. */
const sources = [];

/* Repo-relative and forward-slashed, so a label reads the same on every
 * platform and HISTORY can be written as one pattern. */
const rel = (at) => path.relative(ROOT, at).split(path.sep).join('/');

const markdownUnder = (dir, out = []) => {
  if (!fs.existsSync(dir)) return out;
  for (const e of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const at = path.join(dir, e.name);
    if (e.isDirectory()) markdownUnder(at, out);
    else if (e.name.endsWith('.md')) out.push(at);
  }
  return out;
};

const proseFiles = [
  ...PROSE.map((file) => path.join(ROOT, file)),
  ...PROSE_DIRS.flatMap((dir) => markdownUnder(path.join(ROOT, dir))),
];

for (const at of proseFiles) {
  const label = rel(at);
  if (!fs.existsSync(at) || HISTORY.test(label)) continue;
  sources.push({ label, text: fs.readFileSync(at, 'utf8') });
}
const proseCount = sources.length;
const sidecarDir = path.join(ROOT, SIDECARS);
let sidecarFiles = 0;
if (fs.existsSync(sidecarDir)) {
  for (const name of fs.readdirSync(sidecarDir).sort()) {
    if (!name.endsWith('.json')) continue;
    sidecarFiles += 1;
    sources.push(...SIDECAR_PROSE(path.join(sidecarDir, name)));
  }
}

for (const { label: file, text } of sources) {
  const seen = new Set();

  /* Two shapes look like a name and are not one; both are a PREFIX standing for
   * a family: `z2ui5_cl_smps_bp_*` (a glob) and `z2ui5_cl_smpc_app_<n>` (a
   * placeholder). An ABAP class name never ends in an underscore, so requiring
   * the last character to be a letter or digit rules out every one of them and
   * nothing real. */
  for (const m of text.matchAll(/\b(z2ui5_cl_[a-z0-9_]*[a-z0-9])\b(?!\*|_|<)/gi)) {
    const name = m[1].toLowerCase();
    if (seen.has(name)) continue;
    seen.add(name);

    if (ABSENT.has(name)) continue;
    if (here.has(name)) { checked += 1; continue; }

    const owner = OWNER.find((o) => o.re.test(name));
    /* No owner at all means the name carries a token no repository here uses -
     * which is what a name left behind by a rename looks like. That was the
     * hole this gate shipped with: `z2ui5_cl_dmo_app_overview` matched no
     * prefix, so it was skipped silently, which is the one outcome a gate
     * against stale names must not have. */
    if (!owner) {
      problems.push(`${file}: names \`${name}\`, whose prefix belongs to no repository here\n`
        + '    a leftover from a rename, or a name to add to ABSENT with its reason');
      continue;
    }
    if (owner.repo === path.basename(ROOT)) {
      problems.push(`${file}: names \`${name}\`, which this repository does not have`);
      continue;
    }
    if (owner.byFile) {
      const at = checkoutOf(owner.repo);
      if (!at) {
        if (!notes.some((n) => n.startsWith(owner.repo))) {
          notes.push(`${owner.repo}: no checkout next to this one — framework names were not checked`);
        }
        continue;
      }
      checked += 1;
      const found = frameworkClasses(at).has(name);
      if (!found) {
        problems.push(`${file}: names \`${name}\`, which ${owner.repo} does not ship`);
      }
      continue;
    }
    // eslint-disable-next-line no-await-in-loop
    const cat = await catalogueOf(owner.repo);
    if (!cat) continue;                          // unreachable, already noted
    checked += 1;
    if (!cat.has(name)) {
      problems.push(
        `${file}: names \`${name}\`, which is not in ${owner.repo}'s SAMPLES.md\n`
        + `    renamed or removed over there — look it up and correct the sentence`,
      );
    }
  }
}

console.log(`prose-names: ${checked} class name(s) checked in ${proseCount} prose file(s)`
  + (sidecarFiles ? ` and ${sidecarFiles} ${SIDECARS}/ sidecar(s)` : ''));
for (const n of notes) console.log(`  ${n}`);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log(checked ? 'every class name in prose exists - OK' : 'nothing reachable to check against');
