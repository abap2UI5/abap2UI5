#!/usr/bin/env node
/*
 * skill-rule-gate — every linter rule a skill names has to exist.
 *
 * The skills under `.claude/skills/` are staging areas: an entry describes a
 * defect, and its `Linter:` / `Gate:` line says whether a rule already decides
 * it and which one. That line is the whole point of the file — it is how a
 * reader knows what is enforced and what is still on them.
 *
 * And it is a claim about ANOTHER repository. `abap2ui5lint` renames rules,
 * splits them and retires them on its own schedule; nothing here moves when it
 * does. A skill that says "moved — `unknown-icon`" after that rule was renamed
 * is worse than a skill that says nothing: it tells a reader the case is
 * covered when the id it names resolves to no rule at all, and prose has no
 * compiler to notice.
 *
 * So every backticked kebab-case token in the skills is either
 *
 *   - a rule id the PINNED linter knows (node_modules/@abap2ui5/linter), or
 *   - a rule announced for a version this repository has not pinned yet
 *     (PENDING below — it must be gone once the pin catches up), or
 *   - not a rule id at all, and named in NOT_A_RULE with the reason.
 *
 * The third list is the point of the design: a new token cannot slip through
 * as "probably fine". It either resolves, or somebody writes one line saying
 * what it is.
 *
 *   node .github/scripts/skill-rule-gate.mjs        (npm run check:skills)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const SKILLS = path.join(ROOT, '.claude', 'skills');

/* Tokens that look like a rule id and are not one. Kept explicit rather than
 * pattern-matched: every entry here is a decision somebody made once, and a
 * pattern would quietly absorb the next typo. */
const NOT_A_RULE = new Map([
  ['abap-check', 'a skill in this directory'],
  ['build-an-app', 'a skill in this directory'],
  ['ui5-check', 'a skill in this directory'],
  ['view-chain-layout', 'a skill in this directory'],
  ['samples-controls', 'the repository abap2UI5/samples-controls'],
  ['redundant-conv-i', "a rule of samples-controls' own scripts/pattern-lint.mjs, not of the linter - SLIN's redundant-conversion finding, gated there because the corpus is where it appears"],
  ['clear-all', 'a UI5 icon name (sap-icon://clear-all)'],
  ['message-information', 'a UI5 icon name'],
  ['text-align', 'a CSS property named in a view example'],
  ['text-formatting', 'a UI5 control property'],
  ['non-binary', 'prose — a non-binary MIME type'],
  ['steampunk-2305-api', 'an ABAP Cloud release name'],
  ['sy-subrc', 'an ABAP system field'],
  ['sy-tabix', 'an ABAP system field'],
  ['sy-sysid', 'an ABAP system field'],
  ['unit-tests', 'the abapGit round-trip rule name in this skill\'s own table'],
]);

/* Rules that exist upstream but not in the linter this repository has pinned -
 * either released under a version not pinned yet, or merged on the linter's
 * main and not published at all. Same semantics either way: once the pin
 * catches up the rule is known, and an entry left behind here FAILS rather
 * than lingering.
 *
 * The second case is why the wording above says "upstream" rather than
 * "released". #2686 documented seven rules the linter shipped on 2026-08-30,
 * but npm `latest` is 0.5.1 (published 2026-08-27) and package.json pins
 * `^0.5.1` - so five of those names were true statements about the linter and
 * still unknown here, and check:skills went red on main for every pull
 * request until they were listed. */
const PENDING = new Map([
  // Empty, and it stayed empty for about an hour. `frozen-view-builder` was
  // listed here while this repository pinned 0.1.1; the bump to 0.2.0 made the
  // rule known, this gate reported the entry as stale on the same commit, and
  // it came out. That is the mechanism working, not an accident of timing.
  //
  // The 2026-08-30 round (#2686). Each of these ships in the linter's main and
  // in no published version, so `bump-linter.yaml` removes them here as soon as
  // a release past 0.5.1 lands - this gate fails on the entry the moment the
  // pinned linter knows the rule.
  ['class-constructor-visibility', 'linter main, unreleased - was check:abapgit only before'],
  ['value-header-default-reassigned', 'linter main, unreleased - was an open gate before'],
  ['into-corresponding-inline-decl', 'linter main, unreleased - was an open gate before'],
  ['validating-setter-out-of-range', 'linter main, unreleased - fires on target release 1.149+'],
  ['absent-boolean-overrides-default', 'linter main, unreleased - companion of the setter rule'],
]);

const TOKEN = /`([a-z][a-z0-9]*(?:-[a-z0-9]+)+)`/g;

function markdownFiles(dir, out = []) {
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name);
    if (fs.statSync(full).isDirectory()) markdownFiles(full, out);
    else if (full.endsWith('.md')) out.push(full);
  }
  return out;
}

const { RULES } = await import(
  path.join(ROOT, 'node_modules', '@abap2ui5', 'linter', 'lib', 'findings.mjs')
);
const known = new Set(RULES);

const problems = [];
const seen = new Map(); // token -> first file that used it
let checked = 0;

for (const file of markdownFiles(SKILLS)) {
  const rel = path.relative(ROOT, file);
  const text = fs.readFileSync(file, 'utf8');
  for (const [, token] of text.matchAll(TOKEN)) {
    checked += 1;
    if (!seen.has(token)) seen.set(token, rel);
    if (known.has(token) || NOT_A_RULE.has(token)) continue;
    if (PENDING.has(token)) continue;
    problems.push(
      `${rel}: \`${token}\` is not a rule of the pinned abap2ui5lint\n`
      + '    if it is a rule, it was renamed or retired — fix the line\n'
      + '    if it is not, add it to NOT_A_RULE in this script with what it is',
    );
  }
}

/* A pending entry that the pin has caught up with is a stale exemption, and a
 * stale exemption is how a list like this rots into decoration. */
for (const [token, why] of PENDING) {
  if (known.has(token)) {
    problems.push(
      `PENDING lists \`${token}\` (${why}), but the pinned linter now has it\n`
      + '    remove the entry — it exempts nothing and hides the next one',
    );
  }
}
for (const [token, why] of NOT_A_RULE) {
  if (known.has(token)) {
    problems.push(
      `NOT_A_RULE lists \`${token}\` (${why}), but it IS a rule now\n`
      + '    remove the entry, or the gate stops checking a real rule id',
    );
  }
}
for (const token of [...NOT_A_RULE.keys(), ...PENDING.keys()]) {
  if (!seen.has(token)) {
    problems.push(
      `\`${token}\` is exempted but appears in no skill — drop the exemption`,
    );
  }
}

const rules = [...seen.keys()].filter((t) => known.has(t));
console.log(
  `skill-rule: ${checked} token(s) in ${markdownFiles(SKILLS).length} skill file(s); `
  + `${rules.length} name a rule of the pinned linter (${RULES.length} known), `
  + `${NOT_A_RULE.size} are not rules, ${PENDING.size} pending a pin bump`,
);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log('every rule id a skill names exists - OK');
