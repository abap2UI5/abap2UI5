#!/usr/bin/env node
/*
 * toolchain-gate — CONVENTIONS §4, as a program.
 *
 * §4 is three sentences a script can decide:
 *
 *   `engines.node` is `>=22` and `.nvmrc` says `22`.
 *   `license` is set in every `package.json`.
 *
 * It was the one section of CONVENTIONS.md that `conventions-gate.mjs` did not
 * touch. That gate decides workflow file names (§2), the AGENTS.md/CLAUDE.md
 * pairing (§6) and `.gitattributes` (§6) — and it decides all three for the
 * checkout it runs in, so it has never had an opinion about a sibling.
 *
 * What that cost, measured on 2026-08-28: **seven of the nine** `abap2UI5`
 * repositories had no `.nvmrc` at all. Only this one and `linter` did.
 * `playground` had neither `.nvmrc` nor `engines`, while its AGENTS.md asserted
 * "Node 22, matching the rest of the organisation" in prose. Nothing was wrong
 * with the rule; nothing was reading it.
 *
 * That is the failure mode the document names about itself — "prose is not a
 * thing that fails a pull request" — and it is the same one `scripts-gate.mjs`
 * was written for, one section further down the same file.
 *
 * The repository list and the reader are shared with that gate
 * (`lib-ecosystem.mjs`): two hand-maintained copies of "which repositories the
 * rules apply to" is exactly the drift both gates exist to catch.
 *
 * A repository that cannot be REACHED is a note and a pass. A repository that
 * is reached and does not carry the file is a finding — those are different
 * answers and conflating them is how a gate passes by checking less.
 *
 *   node .github/scripts/toolchain-gate.mjs      (npm run check:toolchain)
 */
import { REPOS, read } from './lib-ecosystem.mjs';

const WANT_ENGINES = '>=22';
const WANT_NVMRC = '22';

/* Drift that predates the gate, named rather than waived silently — the shape
 * `conventions-gate.mjs` already uses for the workflow names that predate ITS
 * rule, and for the same reason: a gate that starts green over known-bad state
 * is a gate nobody has to keep green.
 *
 * The list only SHRINKS. An entry for a repository that now complies fails, so
 * a fix drops its exception in the same change and the drift cannot quietly
 * come back under cover of its own exception.
 *
 * Every entry here is a repository outside the eleven this workstream can open
 * a pull request against. They are real findings, deliberately not fixed here.
 */
const EXCEPTIONS = [
  { repo: 'app-template', missing: ['.nvmrc'] },
  { repo: 'web-abap2UI5', missing: ['.nvmrc', 'engines.node'] },
  { repo: 'custom-controls', missing: ['.nvmrc'] },
];

const excepted = (repo, what) =>
  EXCEPTIONS.some((e) => e.repo === repo && e.missing.includes(what));
const used = new Set();
const note = (repo, what) => { used.add(`${repo}:${what}`); };

const problems = [];
const notes = [];
let checked = 0;

for (const entry of REPOS) {
  const { repo } = entry;

  const pkg = await read(entry, 'package.json');
  if (pkg.note) { notes.push(`${repo}: not checked (${pkg.note})`); continue; }
  if (pkg.missing) {
    problems.push(`${repo}: no package.json (read from ${pkg.from}) — it is on the ecosystem list, so it is expected to have one`);
    continue;
  }

  let json;
  try {
    json = JSON.parse(pkg.text);
  } catch (err) {
    problems.push(`${repo}/package.json (read from ${pkg.from}): not valid JSON - ${err.message}`);
    continue;
  }

  checked += 1;

  const engines = json.engines?.node;
  if (engines !== WANT_ENGINES) {
    if (excepted(repo, 'engines.node')) note(repo, 'engines.node');
    else problems.push(
      `${repo}: engines.node is ${engines === undefined ? 'not set' : JSON.stringify(engines)},`
      + ` CONVENTIONS §4 wants ${JSON.stringify(WANT_ENGINES)} (read from ${pkg.from})`,
    );
  } else if (excepted(repo, 'engines.node')) {
    problems.push(`${repo}: engines.node is correct now — drop its EXCEPTIONS entry in this file`);
  }

  if (!String(json.license ?? '').trim()) {
    problems.push(`${repo}: package.json has no \`license\` — CONVENTIONS §4 (read from ${pkg.from})`);
  }

  /* The half that has no second source: `engines` is a range npm enforces at
   * install time, `.nvmrc` is the exact version a human's shell picks. A
   * repository with only the first still lets `nvm use` land on whatever was
   * already loaded, which is how a Node 20 shell runs a Node 22 test suite and
   * blames the suite. */
  const nvmrc = await read(entry, '.nvmrc');
  if (nvmrc.note) {
    notes.push(`${repo}: .nvmrc not checked (${nvmrc.note})`);
  } else if (nvmrc.missing) {
    if (excepted(repo, '.nvmrc')) note(repo, '.nvmrc');
    else problems.push(`${repo}: no .nvmrc — CONVENTIONS §4 wants one saying ${WANT_NVMRC} (read from ${nvmrc.from})`);
  } else if (nvmrc.text.trim() !== WANT_NVMRC) {
    problems.push(
      `${repo}/.nvmrc says ${JSON.stringify(nvmrc.text.trim())}, CONVENTIONS §4 wants`
      + ` ${JSON.stringify(WANT_NVMRC)} (read from ${nvmrc.from})`,
    );
  } else if (excepted(repo, '.nvmrc')) {
    problems.push(`${repo}: .nvmrc is there now — drop its EXCEPTIONS entry in this file`);
  }
}

for (const n of notes) console.log(`  note: ${n}`);
for (const e of EXCEPTIONS) {
  for (const what of e.missing) {
    if (!used.has(`${e.repo}:${what}`)) {
      problems.push(
        `${e.repo}: EXCEPTIONS names ${what}, but the run never found it missing —`
        + ' the repository was unreachable, or the entry is stale and should be dropped',
      );
    } else {
      console.log(`  exception: ${e.repo} has no ${what} (known, outside this repository's reach)`);
    }
  }
}
console.log(
  `\ntoolchain: engines.node + .nvmrc + license in ${checked} of ${REPOS.length} repositories`,
);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log('every repository declares the same toolchain - OK');
