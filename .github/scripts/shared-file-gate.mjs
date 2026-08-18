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
/* The guide's declared deviations, and the reader that cuts the mirrored half
 * out of it. In `.github/shared/` rather than in this file because app-template
 * now GENERATES its copy from the same two functions — see the entry for
 * `app-guide-deviations.mjs` below. */
import { applyGuideDeviations, guideBody } from '../shared/app-guide-deviations.mjs';

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
     * left over is compared. Declaring one is deliberately a diff in
     * `.github/shared/app-guide-deviations.mjs`: it says "this sentence is
     * repository-specific", which is a decision about the guide, not about the
     * copy.
     *
     * The mirror is no longer maintained by hand on the other side.
     * app-template GENERATES its half with `npm run agents`, from this guide
     * and from that same deviation list, and its `npm run check:agents` fails
     * on drift — so the copy is produced rather than transcribed, and this
     * gate is the second opinion rather than the only one.
     */
    file: 'docs/agents/building-apps.md',
    consumers: ['app-template'],
    consumerFile: 'AGENTS.md',
    why: 'the app-building guide every new project briefs its agent with —'
      + ' mirrored so the template needs no framework checkout',
    section: (text) => guideBody(text),
    mine: (text) => applyGuideDeviations(guideBody(text)),
  },
  {
    /* The deviation list itself, and the two functions that execute it.
     *
     * It has to be shared because it has two executors in two repositories:
     * this gate applies it to compare, and app-template's
     * `scripts/generate-agents.mjs` applies it to WRITE. Two transcriptions of
     * the same three substitutions would move the drift one level down, into
     * the least visible place there is — a generator and a gate that disagree
     * produce a file that fails a check nobody can fix from either side alone.
     *
     * Whole file, no deviations of its own: it is a declaration plus two pure
     * functions and names no path that differs between the two repositories.
     */
    file: '.github/shared/app-guide-deviations.mjs',
    consumers: ['app-template'],
    consumerFile: 'scripts/app-guide-deviations.mjs',
    why: 'the declared deviations of the guide above — applied by this gate to'
      + " compare, and by app-template's generator to write",
  },
  {
    /* The frontend repository's front page. It is the same document as this
     * one — the build copies THIS file into every generated branch (see
     * `tools/build-branches.mjs`), so `main` was the only copy nothing wrote,
     * and it drifted: five paragraphs reworded on one side or the other, and
     * a table naming the reserved resourceRoots `z2ui5cc`/`z2ui5ext` in BOTH,
     * when `app/webapp/manifest.json` has reserved `z2ui5_cci`/`z2ui5_ccc`
     * since the day the roots existed. A reader following that table installs
     * a BSP the loader never asks for.
     *
     * Wrong in both copies is what an unchecked mirror looks like: nobody
     * compares them, so nobody reads them side by side, so nobody reads them
     * against the manifest either. Gating it does not make the text true, but
     * it makes the next divergence a failing check instead of a discovery.
     */
    file: 'frontend/common/README.md',
    consumers: ['frontend'],
    consumerFile: 'README.md',
    why: "the frontend repository's front page — this file is what the build"
      + ' copies into every generated branch, so `main` must say the same',
    /* Whole file, and the one declared deviation is a badge: `main` carries no
     * generated tree, so the `frontend_deploy` badge on it would report on
     * something that is not there. Everything below line 1 is compared. */
    section: (text) => text,
    mine: (text) => applyDeviations(text, README_DEVIATIONS),
  },
  {
    /* The metadata convention — what belongs on the class (`DESCRIPT`,
     * `@summary`, `@keywords`) and what belongs in a `meta/` sidecar. It says
     * so itself, in its first line: "Shared across abap2UI5/samples,
     * abap2UI5/samples-controls and abap2UI5/samples-stack. Decided once, so
     * nobody has to decide it again per repository."
     *
     * Which was true of the text and not of the arrangement: three copies,
     * pasted, none of them the source. A convention that lives in three
     * unowned copies is decided once and then re-decided every time one of
     * them is edited, which is the case the whole gate exists for.
     *
     * The source is here rather than in one of the three for the same reason
     * `app-rules.json` is: picking one consumer as the owner makes the other
     * two guess whose copy is right.
     *
     * Compared section for section, from the `## Metadata` heading down to the
     * next `##`, so each repository keeps its own AGENTS.md around it. A
     * consumer may ADD a `###` subsection of its own — samples-controls
     * documents its `@keywords` / `@summary` generators there — which is
     * declared below and dropped before comparing. An addition is a decision,
     * a reword of a shared subsection is drift; the split is what makes them
     * distinguishable.
     */
    /* The checker for the rule set two entries up. The rule set had one owner
     * and the program reading it had three unowned copies — which is the
     * arrangement `check-app-rules` was itself written to replace, one
     * directory over: it says so in its own header, about the peer comparison
     * it took the place of.
     *
     * A copy of a CHECKER drifting is worse than a copy of a document doing
     * it, because a checker that has quietly stopped checking still prints
     * that it passed. Nothing here would have noticed the three going
     * different ways.
     *
     * Whole file, no deviations: the script resolves everything it needs from
     * its own location, so the three copies have nothing repository-specific
     * left to say. The framework does not run it — it is the source of the
     * rule set, not a consumer of it — which is the same trade
     * `app-rules.json` and `agents-metadata.md` already make.
     */
    file: '.github/shared/check-app-rules.mjs',
    consumers: ['samples', 'samples-controls', 'samples-stack'],
    consumerFile: 'scripts/check-app-rules.mjs',
    why: 'the checker that holds each app repository to the shared abaplint'
      + ' rule set — three copies of it, none of them the source',
  },
  {
    /* The cross-repository name check. `prose-name-gate.mjs` here is NOT this
     * program and is not a candidate to be merged with it: that one reads one
     * repository's tree and puts every foreign name on an allowlist, and this
     * one exists precisely because the names that go stale are the foreign
     * ones — it resolves them against the owning repository's catalogue
     * instead of exempting them. Two jobs, two programs, and only the second
     * is shared.
     *
     * Whole file. `scripts/prose-absent.json` beside it is deliberately NOT
     * shared and is not listed here: it is each repository's own allowlist of
     * names it means to write in the past tense, and unifying it would be the
     * opposite of the point. The script says so where it reads the file.
     */
    file: '.github/shared/check-prose-names.mjs',
    consumers: ['samples', 'samples-controls', 'samples-stack'],
    consumerFile: 'scripts/check-prose-names.mjs',
    why: 'the check that a class named in one repository\'s prose still exists'
      + ' in the repository that owns it',
  },
  {
    /* The builder-chain formatter — the executable half of the
     * `view-chain-layout` skill that heads this list. Two repositories run it;
     * neither owned it. Both being byte-equal today is the state this gate
     * makes checkable rather than a fact somebody re-verifies by hand.
     *
     * This repository does not run it: the framework formats its own chains
     * with the linter's `chain-house-layout` rule, and its copy of the script
     * is gone. The script's own header used to claim otherwise, naming a path
     * that had not existed since — which is what an unchecked shared file
     * looks like from the inside.
     *
     * It is scheduled for deletion. `view-chain-layout` says when: both
     * consumers pin the linter at a version predating the rule, and the day
     * that pin can move the script goes away and the rule replaces it. Until
     * then it is a formatter two corpora format ABAP by, and one line here is
     * a cheaper way to hold it than trusting that nobody edits one copy.
     */
    file: '.github/shared/chain-format.mjs',
    consumers: ['samples', 'samples-controls'],
    consumerFile: 'scripts/chain-format.mjs',
    /* The source carries no skip, so its side of the comparison is the file
     * as it stands; only a consumer that declares one has anything cut. */
    section: (text, side) => dropSandboxSkip(text, side),
    mine: (text) => text,
    why: 'the builder-chain formatter the two sample corpora are laid out by,'
      + ' until the linter pin can move and the rule replaces it',
  },
  {
    file: '.github/shared/agents-metadata.md',
    consumers: ['samples', 'samples-controls', 'samples-stack'],
    consumerFile: 'AGENTS.md',
    why: 'the metadata convention the three app repositories are written by —'
      + ' what goes on the class, what goes in the `meta/` sidecar',
    section: (text, side) => dropSubsections(metadataBlock(text), METADATA_EXTENSIONS[side] ?? [], side),
    mine: (text) => metadataBlock(text),
  },
];

const METADATA_HEADING = '## Metadata: what goes on the class, and what goes beside it';

/* The shared block, from its heading down to the next top-level heading. The
 * source file carries only this block (under a provenance comment); each
 * consumer carries it inside its own AGENTS.md, where everything around it is
 * that repository's own and must not be compared. */
function metadataBlock(text) {
  const lines = text.split('\n');
  const at = lines.indexOf(METADATA_HEADING);
  if (at === -1) throw new Error(`no ${JSON.stringify(METADATA_HEADING)} heading on a line of its own`);
  let end = at + 1;
  while (end < lines.length && !/^## /.test(lines[end])) end += 1;
  return lines.slice(at, end).join('\n');
}

/* `### <heading>` subsections a named consumer adds to the shared block, cut
 * out before the comparison.
 *
 * Declared per repository rather than "anything unrecognised passes": the
 * whole point of the block is that a repository does not get to re-decide it,
 * and a rule that lets any extra heading through cannot tell an addition from
 * a shared subsection somebody retitled. */
const METADATA_EXTENSIONS = {
  'samples-controls': ['### In this repository'],
};

/* samples-controls' chain formatter skips one directory the other consumer's
 * does not, and the difference is real rather than drift.
 *
 * `src/zz_dev` is where abap2UI5/mcp-server's `deploy_app` writes the class an
 * agent is working on. It is gitignored scratch, but every script here walks
 * `src/` on the filesystem and the filesystem does not read `.gitignore`, so
 * the loop this ecosystem recommends to agents left four classes where the
 * gates look. samples-controls is the ONLY repository that happens to:
 * `deploy_app` resolves the samples-controls checkout and writes nowhere else
 * (mcp-server `lib/runtime.mjs`). Carrying the skip into `samples` would be a
 * branch that can never be taken, plus a `lib/src-tree.mjs` beside it that
 * exists to list nothing.
 *
 * So it is declared, the way `scripts/prose-absent.json` is left per
 * repository for the same reason: the shared thing is the program, and what
 * each repository excludes from its own tree is not. Removing the skip over
 * there fails this gate by name rather than passing quietly. */
const SANDBOX_SKIP = {
  'samples-controls': [
    "import { isSkippedDir } from './lib/src-tree.mjs';\n",
    '    if (isSkippedDir(e.name)) continue;\n',
  ],
};

function dropSandboxSkip(text, side) {
  const lines = SANDBOX_SKIP[side] ?? [];
  return lines.reduce((s, line) => {
    if (!s.includes(line)) {
      throw new Error(
        `declared sandbox skip is no longer in ${side}'s copy:\n      ${JSON.stringify(line)}\n`
        + '      it was removed or rewritten — update SANDBOX_SKIP',
      );
    }
    return s.split(line).join('');
  }, text);
}

function dropSubsections(block, headings, side) {
  const lines = block.split('\n');
  for (const heading of headings) {
    const at = lines.indexOf(heading);
    if (at === -1) {
      throw new Error(
        `declared extension ${JSON.stringify(heading)} is no longer in ${side}'s copy —`
        + ' it was removed or retitled; update METADATA_EXTENSIONS',
      );
    }
    let end = at + 1;
    while (end < lines.length && !/^###? /.test(lines[end])) end += 1;
    lines.splice(at, end - at);
  }
  return lines.join('\n');
}

/* Applies a declared deviation list to THIS side, so what is compared is what
 * the consumer is actually expected to carry.
 *
 * A deviation that no longer matches anything here is a finding, not a
 * silently skipped rewrite: it means somebody edited a passage a consumer is
 * known to reword, and the two copies have to be reconciled by hand. */
function applyDeviations(text, deviations) {
  return deviations.reduce((s, [from, to]) => {
    if (!s.includes(from)) {
      throw new Error(
        `declared deviation no longer matches this repository's copy:\n      ${JSON.stringify(from)}\n`
        + '      the text it rewrites was edited or removed — update the deviation list',
      );
    }
    return s.split(from).join(to);
  }, text);
}

/* [what the shipped copy carries, what `frontend`'s `main` carries] — the
 * badge line and nothing else. Kept whole-line so removing it leaves no blank
 * line behind, and so a reviewer can see that the deviation is a badge rather
 * than a sentence about how the frontend works. */
const README_DEVIATIONS = [
  [
    '[![frontend_deploy](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_deploy.yaml'
      + '/badge.svg?branch=main)](https://github.com/abap2UI5/abap2UI5/actions/workflows/frontend_deploy.yaml)\n',
    '',
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
