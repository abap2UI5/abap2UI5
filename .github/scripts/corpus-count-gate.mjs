#!/usr/bin/env node
/*
 * corpus-count-gate — a number about ANOTHER repository's corpus, held to that
 * repository's own generated count.
 *
 * The agent-facing files here tell an agent how big the example corpora are,
 * and that number is the reason it goes and looks instead of writing from
 * scratch: "416 ported demo-kit samples" is an argument, "some ports exist" is
 * not. So the numbers earn their place — and then they rot, because the corpus
 * they describe grows in a repository whose CI cannot see this prose.
 *
 * They had rotted. docs/agents/building-apps.md said ~280 ports in two places
 * while the corpus was at 416, and llms.txt said ~400. Nothing was wrong with
 * the writing; there was simply no way to notice.
 *
 * This is the same problem check:prose solves for NAMES (a Z2UI5_* name in
 * markdown that no longer exists) and check:version for the release number.
 * The pattern those established: a claim a script can check is worth more than
 * a claim a reviewer has to remember. AGENTS.md puts it as "a number repeated
 * here is a number that goes stale".
 *
 * TRUTH comes from the consumer repository's GENERATED artefact, never from
 * counting files here:
 *   samples, samples-stack   SAMPLES.md's "<n> of them" — the catalogue header
 *   samples-controls         STATUS.md's state block, "**<n>** sidecars"
 * Those blocks sit between generated markers and are gated in their own
 * repositories, so they are the closest thing to a fact this side can read.
 * Counting *.clas.abap here would invent a fourth answer to a question that
 * already has three definitions (sidecars, catalogue rows, class files).
 *
 * Comparison, in order — borrowed whole from shared-file-gate, including the
 * part that matters most:
 *   a sibling CHECKOUT next to this one   (offline, and what a local run sees)
 *   raw.githubusercontent.com/<repo>/main (CI, and what is actually published)
 * When neither is reachable the run SAYS SO and passes. A gate must not go red
 * because github.com is unreachable, and must not claim to have verified
 * something it did not.
 *
 *   node .github/scripts/corpus-count-gate.mjs     (npm run check:counts)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

/* How to read the truth out of each corpus repository.
 *
 * `metric` is what the number MEANS, and the name is deliberately explicit:
 * samples-controls can be honestly described as 411 (in-scope coverage), 416
 * (ports) or 430 (catalogue rows), and a claim has to say which one it is
 * making before it can be checked at all.
 */
const CORPORA = {
  'samples/apps': {
    repo: 'samples',
    file: 'SAMPLES.md',
    /* "…150 apps, 152 of them…" — the catalogue's own header count. */
    read: (text) => text.match(/(\d+)\s+of them/)?.[1],
    what: 'catalogue entries in SAMPLES.md',
  },
  'samples-controls/ports': {
    repo: 'samples-controls',
    file: 'STATUS.md',
    /* "| Ports | **416** sidecars in `meta/` (…)" inside the generated state
     * block. The sidecar count is the port count: one meta/*.json per port. */
    read: (text) => text.match(/\|\s*Ports\s*\|\s*\*\*(\d+)\*\*\s+sidecars/)?.[1],
    what: 'port sidecars in meta/, per STATUS.md',
  },
};
/* samples-stack states no count here yet. Adding one is an entry above plus a
 * claim below — the fetch costs nothing until something actually cites it. */

/* Every cross-repo corpus number this repository states, and where.
 *
 * A list rather than a scan of all digits: this file must not have an opinion
 * about "1.71", "187 rules" or "702", and a claim becoming checked should cost
 * one line here so that it is a decision. `near: true` accepts a rounded claim
 * (written "~400") within 5 % — precise claims must be exact.
 */
const CLAIMS = [
  {
    file: 'llms.txt',
    metric: 'samples/apps',
    find: /(\d+) curated example apps/,
  },
  {
    file: 'llms.txt',
    metric: 'samples-controls/ports',
    find: /(\d+) gate-verified ports/,
  },
  {
    file: 'docs/agents/building-apps.md',
    metric: 'samples-controls/ports',
    find: /conventions proven over the (\d+) ported UI5/,
  },
  {
    file: 'docs/agents/building-apps.md',
    metric: 'samples-controls/ports',
    find: /(\d+) gate-verified\s+demo-kit ports/,
  },
  {
    file: '.claude/skills/build-an-app/SKILL.md',
    metric: 'samples/apps',
    find: /holds (\d+) working apps/,
  },
  {
    file: '.claude/skills/build-an-app/SKILL.md',
    metric: 'samples-controls/ports',
    find: /samples-controls' (\d+) ports/,
  },
];

const raw = (repo, file) => `https://raw.githubusercontent.com/abap2UI5/${repo}/main/${file}`;

const problems = [];
const notes = [];

/* Resolve each corpus once — several claims share one metric. */
const truth = {};
for (const [metric, spec] of Object.entries(CORPORA)) {
  const local = path.join(ROOT, '..', spec.repo, spec.file);
  let text = null;
  let from = '';

  if (fs.existsSync(local)) {
    text = fs.readFileSync(local, 'utf8');
    from = 'checkout';
  } else {
    try {
      const res = await fetch(raw(spec.repo, spec.file), { signal: AbortSignal.timeout(15000) });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      text = await res.text();
      from = 'github';
    } catch (err) {
      notes.push(`${metric}: not resolved (${err.message})`);
      continue;
    }
  }

  const value = spec.read(text);
  if (!value) {
    /* The generated block changed shape. That is a real failure and not a
     * missing network: reporting it as "unreachable" would let the gate go
     * quiet exactly when the thing it reads has moved. */
    problems.push(
      `${metric}: could not read the count from ${spec.repo}/${spec.file} (read from ${from})\n`
      + `    the generated block this gate parses has changed shape — fix the reader here`,
    );
    continue;
  }
  truth[metric] = { value: Number(value), from, spec };
}

let checked = 0;
for (const claim of CLAIMS) {
  const file = path.join(ROOT, claim.file);
  if (!fs.existsSync(file)) {
    problems.push(`${claim.file}: declared to carry a corpus count, but the file is not here`);
    continue;
  }
  const found = fs.readFileSync(file, 'utf8').match(claim.find);
  if (!found) {
    /* The sentence was rewritten. Better to fail than to silently stop
     * checking a number that is still on the page. */
    problems.push(
      `${claim.file}: no match for ${claim.find}\n`
      + '    the sentence carrying this count was rewritten — update the pattern here,'
      + ' or drop the claim if the number is gone',
    );
    continue;
  }

  const known = truth[claim.metric];
  if (!known) continue; // corpus unreachable, already noted

  checked += 1;
  const stated = Number(found[1]);
  const ok = claim.near
    ? Math.abs(stated - known.value) / known.value <= 0.05
    : stated === known.value;
  if (ok) continue;

  problems.push(
    `${claim.file}: says ${stated}, ${claim.metric} is ${known.value}`
    + ` (${known.spec.what}, read from ${known.spec.repo}/${known.spec.file} via ${known.from})`,
  );
}

console.log(
  `corpus-count: ${CLAIMS.length} claim(s) declared, ${checked} checked`
  + ` against ${Object.keys(truth).length} of ${Object.keys(CORPORA).length} corpus/corpora`,
);
for (const n of notes) console.log(`  ${n}`);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
if (!checked) {
  console.log('nothing reachable to compare against — not a failure, but nothing was verified');
} else {
  console.log('every corpus count matches the corpus - OK');
}
