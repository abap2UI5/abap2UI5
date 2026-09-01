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
 * The same discipline for the OTHER kind of claim those lines make: a
 * `check:<name>` npm script named in a Gate:/Linter: paragraph has to exist
 * in package.json (that claim is about THIS repository, and a script that
 * does not exist enforces nothing), and a line that says a gate is "not
 * being built" / "still open" / "not gated" while naming a check script
 * that DOES exist is a claim that rotted the other way — the ui5-check
 * module entry said exactly that about check:modules after the gate had
 * shipped.
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

/* Rules that exist in a released linter this repository has NOT pinned yet.
 * Same semantics as a baseline entry: once the pin catches up the rule is
 * known, and an entry left behind here FAILS rather than lingering. */
const PENDING = new Map([
  // Empty, and it has been twice now. `frozen-view-builder` was listed here
  // while this repository pinned 0.1.1; the bump to 0.2.0 made the rule known,
  // this gate reported the entry as stale on the same commit, and it came out.
  // Five more were needed for about as long on 2026-08-30: #2686 recorded the
  // staging entries abap2UI5/linter#80 had just closed, and the rules it names
  // existed on that repository's main and in no published version. Moving the
  // pin to that commit made them known and this gate asked for the entries
  // back out on the spot — along with the NOT_A_RULE line for
  // `redundant-conv-i`, which #80 had promoted out of samples-controls'
  // pattern-lint into a real rule.
  //
  // That is the mechanism working, not an accident of timing: an entry here
  // is an exemption the pin has not caught up with, and the loop below FAILS
  // on it the moment it has.
]);

const TOKEN = /`([a-z][a-z0-9]*(?:-[a-z0-9]+)+)`/g;

/* An npm-script claim: the colon form bare (`check:modules`) or any check
 * script behind an explicit `npm run` (`npm run check_visibility`). The bare
 * underscore form is deliberately NOT matched — `check_syntax` is an abaplint
 * RULE id the skills also name, and only the `npm run` prefix separates a
 * script claim from a rule one. */
const SCRIPT_TOKEN = /`(?:npm run (check[:_][a-z0-9:_-]+)|(check:[a-z0-9:_-]+))`/g;
/* The rotten-the-other-way claim: a gate declared missing on the same line
 * as a check script that exists. */
const STALE_CLAIM = /not (?:being )?built|still open|not gated/i;

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
const scripts = new Set(Object.keys(
  JSON.parse(fs.readFileSync(path.join(ROOT, 'package.json'), 'utf8')).scripts ?? {},
));

const problems = [];
const seen = new Map(); // token -> first file that used it
let checked = 0;
let scriptChecked = 0;

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

  /* The Gate:/Linter: paragraphs, line by line. A script named there is a
   * claim about THIS repository's package.json; elsewhere in a skill a
   * `npm run check:…` may legitimately belong to a sibling repository
   * (samples-stack's check:abapdoc, samples-controls' check:chains), so the
   * scope stays the lines whose whole point is "what decides this here". */
  const lines = text.split('\n');
  const inParagraph = new Set();
  for (let i = 0; i < lines.length; i++) {
    if (!/\*\*(Gate|Linter):/.test(lines[i])) continue;
    for (let j = i; j < lines.length && lines[j].trim() !== ''; j++) inParagraph.add(j);
  }
  for (const i of inParagraph) {
    for (const m of lines[i].matchAll(SCRIPT_TOKEN)) {
      const name = m[1] ?? m[2];
      scriptChecked += 1;
      if (!scripts.has(name)) {
        problems.push(
          `${rel}:${i + 1}: the Gate:/Linter: line names \`${name}\`, which is no npm script here\n`
          + '    the line is how a reader learns what is enforced, and a script that\n'
          + '    does not exist enforces nothing — fix the name, or drop the claim',
        );
      }
    }
  }

  /* The claim that rotted the other way: "not being built" / "still open" /
   * "not gated" on the same line as a check script that EXISTS. Checked on
   * every line, not only the Gate:/Linter: ones — the stale ui5-check claim
   * sat in a follow-on paragraph. */
  for (let i = 0; i < lines.length; i++) {
    if (!STALE_CLAIM.test(lines[i])) continue;
    for (const m of lines[i].matchAll(SCRIPT_TOKEN)) {
      const name = m[1] ?? m[2];
      if (scripts.has(name)) {
        problems.push(
          `${rel}:${i + 1}: claims a gate is missing on the same line as \`${name}\`,\n`
          + '    which exists in package.json — the claim rotted; rewrite the line to\n'
          + '    say what the gate covers and what actually remains open',
        );
      }
    }
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
  + `${NOT_A_RULE.size} are not rules, ${PENDING.size} pending a pin bump; `
  + `${scriptChecked} npm-script claim(s) on Gate:/Linter: lines`,
);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  process.exit(1);
}
console.log('every rule id a skill names exists - OK');
