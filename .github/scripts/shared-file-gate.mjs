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
  {
    /* Not a whole file: the consumers keep their own `abaplint.jsonc` with
     * their own `object_naming`, and share the 187 rules around it. So the
     * comparison is on a SECTION, extracted and parsed from both sides.
     *
     * The source here is not a config this repository uses — abap2UI5's own
     * abaplint.jsonc governs FRAMEWORK code and is legitimately different.
     * It sits here because this is where "how to write an abap2UI5 app" lives:
     * the build-an-app and view-chain-layout skills, docs/agents/building-apps.md,
     * abap-check and ui5-check. The app rule set is one more of those.
     *
     * What that costs, stated once: an app author outside these three
     * repositories cannot `npm install` it, which they could if it shipped
     * with @abap2ui5/linter. Publishing it from there later is compatible with
     * this — the source would move, the gate would not.
     */
    file: '.github/abaplint/app-rules.json',
    consumers: ['samples', 'samples-controls', 'samples-stack'],
    consumerFile: 'abaplint.jsonc',
    why: 'the abaplint rule set every abap2UI5 APP repository is judged by —'
      + ' 187 rules, byte-equal across the three when this was written',
    /* Compared as PARSED SETTINGS, not as text and not as a list of names.
     * The checker this replaces compared rule NAMES only, so `"rule": true`
     * and `"rule": false` looked identical to it — and switching a rule off is
     * precisely the drift its own header warned about. */
    section: (text, side) => {
      const rules = parseJsonc(text)?.rules;
      if (!rules) throw new Error(`${side}: no \`rules\` block`);
      const out = {};
      // each repository names its own object prefixes
      for (const k of Object.keys(rules).sort()) if (k !== 'object_naming') out[k] = rules[k];
      return out;
    },
    mine: (text) => parseJsonc(text).rules,
  },
  {
    /* The app-building guide, mirrored into app-template's AGENTS.md so a new
     * project needs no framework checkout to brief an agent. It had drifted
     * both ways within a fortnight — the dispatcher branches in the wrong
     * order there, a corpus count and a claim about samples' baseline stale
     * here — because the file SAYS it is a mirror and nothing checked it.
     *
     * Not a byte comparison, and it cannot be one: the mirrored text names
     * `npm run fmt:chains` and `.github/abaplint/auto_abaplint_fix.jsonc`,
     * which exist in THIS repository and not in a project made from the
     * template. A consumer that must rewrite three sentences to stay true
     * cannot also be byte-equal.
     *
     * So the deviations are declared, applied to this side, and only what is
     * left over is compared. Declaring one is deliberately a diff here: it
     * says "this sentence is repository-specific", which is a decision about
     * the guide, not about the copy. If a deviation ever grows past a few
     * lines, that is the signal to move the sentence out of the mirrored half
     * instead of maintaining a translation of it.
     */
    file: 'docs/agents/building-apps.md',
    consumers: ['app-template'],
    consumerFile: 'AGENTS.md',
    why: 'the app-building guide every new project briefs its agent with —'
      + ' mirrored so the template needs no framework checkout',
    section: (text) => guideBody(text),
    mine: (text) => DEVIATIONS.reduce((s, [from, to]) => {
      if (!s.includes(from)) {
        throw new Error(
          `declared deviation no longer matches this repository's guide:\n      ${JSON.stringify(from)}\n`
          + '      the sentence it rewrites was edited or removed — update DEVIATIONS',
        );
      }
      return s.split(from).join(to);
    }, guideBody(text)),
  },
];

/* Everything from section 1 down: the part app-template mirrors. Above it each
 * repository says what IT is, which is not shared and must not be compared. */
function guideBody(text) {
  /* Anchored to the start of a line, because the consumer's provenance block
   * NAMES this heading when it explains how to re-sync — and an unanchored
   * search found that sentence instead, then reported the whole guide as
   * different from line 1. A heading is a line, so the pattern says so. */
  const at = text.search(/^## 1\. The model in one paragraph$/m);
  if (at === -1) throw new Error('no "## 1. The model in one paragraph" heading on a line of its own');
  return text.slice(at);
}

/* [what this repository says, what a template repository says] — each one a
 * name that exists here and not there. Kept to whole sentences so a reviewer
 * can see what was traded. */
const DEVIATIONS = [
  [
    '`npm run check:abap2ui5` reports and `npm run fmt:chains` applies.',
    '`npm run check:abap2ui5` reports and `npm run fix` applies.',
  ],
  [
    "`.github/abaplint/auto_abaplint_fix.jsonc` excludes the shipped apps from",
    "the framework repository's `.github/abaplint/auto_abaplint_fix.jsonc`"
      + ' excludes its shipped apps from',
  ],
  [
    'and `npm run check:formatter` enforces them.',
    "and the framework's own `check:formatter` gate enforces them there.",
  ],
];

/* JSONC: strip block and line comments, keeping anything inside a string.
 * A naive strip eats the `//` of a URL in a `dependencies` entry, which both
 * consumer configs have. */
function parseJsonc(text) {
  let out = '';
  let inString = false;
  let quote = '';
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    const next = text[i + 1];
    if (inString) {
      out += c;
      if (c === '\\') { out += next; i += 1; continue; }
      if (c === quote) inString = false;
      continue;
    }
    if (c === '"' || c === "'") { inString = true; quote = c; out += c; continue; }
    if (c === '/' && next === '/') { while (i < text.length && text[i] !== '\n') i += 1; out += '\n'; continue; }
    if (c === '/' && next === '*') { i += 2; while (i < text.length && !(text[i] === '*' && text[i + 1] === '/')) i += 1; i += 1; continue; }
    out += c;
  }
  // trailing commas are legal in JSONC and common in these files
  return JSON.parse(out.replace(/,(\s*[}\]])/g, '$1'));
}

const raw = (repo, file) => `https://raw.githubusercontent.com/abap2UI5/${repo}/main/${file}`;

/* Trailing-whitespace and final-newline differences are not what this is for;
 * a real edit never looks like one, and reporting them would train everyone to
 * ignore the gate. */
const normalise = (s) => s.replace(/\r\n/g, '\n').replace(/[ \t]+$/gm, '').trimEnd();

/* A `section` may return settings to compare (the rule block) or the text of a
 * shared passage (the guide). Both end up as lines, because the report names
 * the first LINE that differs — JSON.stringify on a 500-line passage makes one
 * line of it, and then the report is the whole file. */
const comparable = (v) => (typeof v === 'string' ? normalise(v) : JSON.stringify(v, null, 1));

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
  const sourceText = fs.readFileSync(source, 'utf8');
  /* A source-side reader can refuse: the guide entry checks that every
   * declared deviation still matches a sentence here. That is a finding to
   * report like any other, not a stack trace — it means somebody edited a
   * sentence that a consumer is known to rewrite. */
  let mine;
  try {
    mine = entry.section ? comparable(entry.mine(sourceText)) : normalise(sourceText);
  } catch (err) {
    problems.push(`${entry.file}: ${err.message}`);
    continue;
  }

  const consumerFile = entry.consumerFile || entry.file;

  for (const repo of entry.consumers) {
    expected += 1;
    const local = path.join(ROOT, '..', repo, consumerFile);
    let theirs = null;
    let from = '';

    let text = null;
    if (fs.existsSync(local)) {
      text = fs.readFileSync(local, 'utf8');
      from = 'checkout';
    } else {
      try {
        const res = await fetch(raw(repo, consumerFile), { signal: AbortSignal.timeout(15000) });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        text = await res.text();
        from = 'github';
      } catch (err) {
        notes.push(`${repo}: not compared (${err.message})`);
        continue;
      }
    }
    try {
      theirs = entry.section ? comparable(entry.section(text, repo)) : normalise(text);
    } catch (err) {
      problems.push(`${repo}/${consumerFile}: ${err.message}`);
      continue;
    }

    compared += 1;
    if (theirs === mine) continue;

    /* Naming the first differing line is the difference between a report
     * somebody acts on and one somebody closes. */
    const a = mine.split('\n');
    const b = theirs.split('\n');
    const at = a.findIndex((line, i) => line !== b[i]);
    problems.push(
      `${entry.file} differs in ${repo}/${consumerFile} (read from ${from})\n`
      + (at === -1
        ? `    same first ${Math.min(a.length, b.length)} line(s), then one file ends`
        : `    first difference at line ${at + 1}\n`
          + `      here:      ${JSON.stringify(a[at] ?? '<end of file>')}\n`
          + `      ${repo}:    ${JSON.stringify(b[at] ?? '<end of file>')}`)
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
