#!/usr/bin/env node
/*
 * shared-file-gate — a file that lives in more than one repository has ONE
 * source, and it is here.
 *
 * `.claude/skills/view-chain-layout/SKILL.md` exists in four repositories,
 * byte-identical, and nothing checks it. That is the same setup
 * `samples-controls/scripts/check-rule-block.mjs` was written for, and its
 * description of the failure is exact: copies drift "not with a bang but with
 * somebody switching one rule off to get a pull request through and never
 * coming back". Then the shared thing is a claim nobody can falsify.
 *
 * The rule block at least has a checker. The skill has none, and it is the
 * file that tells four repositories how to lay out a builder chain — the rules
 * the linter's `chain-house-layout` then enforces. Four copies of that
 * quietly disagreeing is four repositories formatting differently while each
 * one's CI stays green.
 *
 * So abap2UI5 declares itself the SOURCE. Not because the framework owns app
 * formatting — it does not — but because a shared file needs one owner, this
 * is the repository every other one already depends on, and the alternative
 * (peer-to-peer comparison) has no answer to "which of you is right".
 *
 * The consumers need no change: they keep their copy, and this gate is what
 * notices when one of them stops matching. A repository that wants to check
 * from its own side can run the same comparison against the raw URL below.
 *
 * Comparison, in order:
 *   a sibling CHECKOUT next to this one   (offline, and what a local run sees)
 *   raw.githubusercontent.com/<repo>/main (CI, and what is actually published)
 *
 * When neither is reachable the run SAYS SO and passes. A repository's own
 * gates must not go red because github.com is unreachable, and they must not
 * claim to have verified something they did not — the rule this borrows,
 * along with the shape, from check-rule-block.
 *
 *   node .github/scripts/shared-file-gate.mjs     (npm run check:shared)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

/* Every file this repository is the source of, and who carries a copy.
 *
 * Deliberately a list rather than a directory convention: a file becoming
 * shared across repositories is a decision, and it should cost one line here
 * so that it is made rather than drifted into.
 */
const SHARED = [
  {
    file: '.claude/skills/view-chain-layout/SKILL.md',
    consumers: ['samples', 'samples-controls', 'samples-stack'],
    why: 'the builder-chain layout rules the linter\'s chain-house-layout enforces —'
      + ' four repositories format ABAP by this file',
  },
];

const raw = (repo, file) => `https://raw.githubusercontent.com/abap2UI5/${repo}/main/${file}`;

/* Trailing-whitespace and final-newline differences are not what this is for;
 * a real edit never looks like one, and reporting them would train everyone to
 * ignore the gate. */
const normalise = (s) => s.replace(/\r\n/g, '\n').replace(/[ \t]+$/gm, '').trimEnd();

const problems = [];
const notes = [];
let compared = 0;
let expected = 0;

for (const entry of SHARED) {
  const source = path.join(ROOT, entry.file);
  if (!fs.existsSync(source)) {
    problems.push(`${entry.file}: declared shared, but this repository does not have it`);
    continue;
  }
  const mine = normalise(fs.readFileSync(source, 'utf8'));

  for (const repo of entry.consumers) {
    expected += 1;
    const local = path.join(ROOT, '..', repo, entry.file);
    let theirs = null;
    let from = '';

    if (fs.existsSync(local)) {
      theirs = normalise(fs.readFileSync(local, 'utf8'));
      from = 'checkout';
    } else {
      try {
        const res = await fetch(raw(repo, entry.file), { signal: AbortSignal.timeout(15000) });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        theirs = normalise(await res.text());
        from = 'github';
      } catch (err) {
        notes.push(`${repo}: not compared (${err.message})`);
        continue;
      }
    }

    compared += 1;
    if (theirs === mine) continue;

    /* Naming the first differing line is the difference between a report
     * somebody acts on and one somebody closes. */
    const a = mine.split('\n');
    const b = theirs.split('\n');
    const at = a.findIndex((line, i) => line !== b[i]);
    problems.push(
      `${entry.file} differs in ${repo} (read from ${from})\n`
      + (at === -1
        ? `    same first ${Math.min(a.length, b.length)} line(s), then one file ends`
        : `    first difference at line ${at + 1}\n`
          + `      here:      ${JSON.stringify(a[at] ?? '<end of file>')}\n`
          + `      ${repo}: ${JSON.stringify(b[at] ?? '<end of file>')}`)
      + `\n    this repository is the source — copy it there, or change it here first`,
    );
  }
}

console.log(
  `shared-file: ${SHARED.length} shared file(s), compared against ${compared} of ${expected} copy/copies`,
);
for (const n of notes) console.log(`  ${n}`);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
if (!compared) {
  console.log('nothing reachable to compare against — not a failure, but nothing was verified');
} else {
  console.log('every copy matches its source here - OK');
}
