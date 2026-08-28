#!/usr/bin/env node
/*
 * scripts-gate — every repository in the ecosystem answers to `npm run check`
 * and `npm test`.
 *
 * Those are the two commands somebody types before they have read anything.
 * Until 2026-08-18 five of the ten repositories answered "Missing script",
 * and which five was not knowable from any one of them: the rule lived in
 * `.github/shared/CONVENTIONS.md` as prose, and prose is not a thing that
 * fails a pull request. This is the same file's section 3, as a program.
 *
 * It deliberately checks only that the two scripts EXIST and are non-empty.
 * What `check` should run is a judgement per repository - a browser download
 * or a full downport is a legitimate omission, and CONVENTIONS section 3 asks
 * for those to be named in that repository's AGENTS.md rather than counted
 * here. A gate that tried to compare a script body against a workflow would
 * be guessing, and it would go red on every unrelated CI edit.
 *
 * Comparison, in order - the shape shared-file-gate uses, for the same
 * reasons:
 *   a sibling CHECKOUT next to this one   (offline, and what a local run sees)
 *   raw.githubusercontent.com/<repo>/main (CI, and what is actually published)
 *
 * When neither is reachable the run SAYS SO and passes. A repository's gates
 * must not go red because github.com is unreachable, and they must not claim
 * to have verified something they did not.
 *
 *   node .github/scripts/scripts-gate.mjs        (npm run check:scripts)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { REPOS } from './lib-ecosystem.mjs';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

/* The ecosystem list lives in `lib-ecosystem.mjs`, because `toolchain-gate.mjs`
 * needs the same one. Two hand-maintained copies of "which repositories the
 * rules apply to" is exactly the drift both gates exist to catch. */

const REQUIRED = ['check', 'test'];

const raw = ({ org, repo }) => `https://raw.githubusercontent.com/${org}/${repo}/main/package.json`;

const problems = [];
const notes = [];
let checked = 0;

for (const entry of REPOS) {
  const { repo } = entry;
  /* This repository is the checkout the gate runs in, not a sibling of it. */
  const local = repo === 'abap2UI5'
    ? path.join(ROOT, 'package.json')
    : path.join(ROOT, '..', repo, 'package.json');

  let text;
  let from;
  if (fs.existsSync(local)) {
    text = fs.readFileSync(local, 'utf8');
    from = 'checkout';
  } else {
    try {
      const res = await fetch(raw(entry), { signal: AbortSignal.timeout(15000) });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      text = await res.text();
      from = 'github';
    } catch (err) {
      notes.push(`${repo}: not checked (${err.message})`);
      continue;
    }
  }

  let scripts;
  try {
    scripts = JSON.parse(text).scripts ?? {};
  } catch (err) {
    problems.push(`${repo}/package.json (read from ${from}): not valid JSON - ${err.message}`);
    continue;
  }

  checked += 1;
  const missing = REQUIRED.filter((s) => !String(scripts[s] ?? '').trim());
  if (missing.length) {
    problems.push(
      `${repo} has no ${missing.map((m) => `\`npm run ${m}\``).join(' and no ')}`
      + ` (read from ${from})\n`
      + `    CONVENTIONS section 3: every repository answers to both. Where there is no\n`
      + `    separate test suite, \`test\` is \`npm run check\` - the command still answers.`,
    );
  }
}

for (const note of notes) console.log(`  note: ${note}`);
console.log(
  `\nscripts: ${REQUIRED.map((r) => `\`${r}\``).join(' + ')} in ${checked} of ${REPOS.length} repositories`,
);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log('every repository answers to both - OK');
