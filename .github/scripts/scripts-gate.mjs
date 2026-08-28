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

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

/* Every repository in the ecosystem that carries a package.json, this one
 * included - it is subject to its own rule, and reading it from disk rather
 * than exempting it is one line cheaper than the exemption.
 *
 * A list rather than a discovery call: the organisation also holds generated
 * channel repositories (`frontend`, `web-abap2UI5-build`) that have no
 * package.json and no contributor to type a command, and an API listing would
 * pull those in and then need an exclusion list anyway. */
const REPOS = [
  'abap2UI5',
  'samples',
  'samples-controls',
  'samples-stack',
  'app-template',
  'mcp-server',
  'vscode-extension',
  'linter',
  'docs',
  'web-abap2UI5',

  /* The addons, which sit in a second organisation and were outside every
   * ecosystem gate until 2026-08-20 - which is how eleven repositories came to
   * disagree with CONVENTIONS on workflow naming, toolchain pins and these two
   * scripts at once, and how one of them shipped for ten days against a class
   * that exists nowhere. They are source repositories with contributors, so
   * the rule is theirs too. */
  { org: 'abap2UI5-addons', repo: 'popups' },
  { org: 'abap2UI5-addons', repo: 'se16n' },
  { org: 'abap2UI5-addons', repo: 'sql-console' },
  { org: 'abap2UI5-addons', repo: 'table-content-loader' },
  { org: 'abap2UI5-addons', repo: 'table-maintenance' },
  { org: 'abap2UI5-addons', repo: 'layout-management' },
  { org: 'abap2UI5-addons', repo: 'selection-screen' },
  { org: 'abap2UI5-addons', repo: 'lock-manager' },
  { org: 'abap2UI5-addons', repo: 'custom-controls' },
  { org: 'abap2UI5-addons', repo: 'rap-ext' },
  { org: 'abap2UI5-addons', repo: 'fork-abapToC' },
].map((e) => (typeof e === 'string' ? { org: 'abap2UI5', repo: e } : e));

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
