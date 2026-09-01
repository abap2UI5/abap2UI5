#!/usr/bin/env node
/*
 * changelog-gate — this repository's changelog.txt and the release notes page
 * in abap2UI5/docs describe the same releases. They must at least agree on
 * WHICH releases those are, and on what day each one shipped.
 *
 * They are deliberately not the same document. changelog.txt is machine-read:
 * release.yaml and release-gate.mjs parse it to build the release notes and to
 * prove the tag, the package version and the changelog agree before anything
 * is published. It is terse by design. The docs page is written for people and
 * carries a paragraph per change - v1.143.0 is one line here and ten bullets
 * there. Generating one from the other would either flatten the prose or force
 * the release machinery to parse markdown, so both stay hand-written.
 *
 * What must NOT happen is the two disagreeing about the facts. That is the
 * failure this gate exists for: a release that is in one list and missing from
 * the other, or the same version carrying two different dates. Both are
 * invisible from inside either repository - each file is internally
 * consistent - and both mislead somebody deciding whether to upgrade.
 *
 * Deliberately NOT checked: the text of an entry, and how many entries a
 * version has. That difference is the point of having two files.
 *
 * Resolution follows shared-file-gate and corpus-count-gate: a sibling
 * checkout first, then raw.githubusercontent, and when neither is reachable
 * the gate says so and passes. A gate that cannot see the other side must not
 * fail a pull request over it.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
import { read as ecoRead, REPOS } from './lib-ecosystem.mjs';

const DOCS_REPO = 'docs';
const DOCS_FILE = 'docs/resources/changelog.md';

/* changelog.txt: "2026-08-16 v1.143.0" followed by an underline of dashes. */
const readChangelogTxt = (text) => {
  const found = new Map();
  const re = /^(\d{4}-\d{2}-\d{2}) v(\d+\.\d+\.\d+)\s*$/gm;
  let m;
  while ((m = re.exec(text)) !== null) found.set(m[2], m[1]);
  return found;
};

/* The docs page: "## 1.143.0" and the date on the line after it. */
const readDocsPage = (text) => {
  const found = new Map();
  const lines = text.split('\n');
  for (let i = 0; i < lines.length; i += 1) {
    const heading = /^## (\d+\.\d+\.\d+)\s*$/.exec(lines[i]);
    if (!heading) continue;
    const date = /^(\d{4}-\d{2}-\d{2})\s*$/.exec(lines[i + 1] ?? '');
    found.set(heading[1], date ? date[1] : null);
  }
  return found;
};

const localTxt = path.join(ROOT, 'changelog.txt');
if (!fs.existsSync(localTxt)) {
  console.error('changelog-gate: changelog.txt not found');
  process.exit(1);
}

const ourText = fs.readFileSync(localTxt, 'utf8');

/* The standing `unreleased` heading. Entries accumulate under it between
 * releases and the release cut moves them under a version heading - the
 * heading itself stays, so the next pull request has a place to write to.
 * The pull-request template, CONTRIBUTING.md, RELEASING.md and release.yaml
 * all point contributors at that heading; the file went without one for a
 * while and every one of those pointers dangled. This gate runs on every
 * pull request, so a missing heading fails between releases, not at the
 * release cut. */
if (!/^unreleased\s*\n-{5,}\s*$/m.test(ourText)) {
  console.error('changelog-gate: changelog.txt has no `unreleased` heading');
  console.error('  The PR template, CONTRIBUTING.md and RELEASING.md all direct entries to it.');
  console.error('  Restore it above the newest release section:\n');
  console.error('    unreleased\n    ----------\n');
  process.exit(1);
}

const ours = readChangelogTxt(ourText);
if (ours.size === 0) {
  /* The format moved. Reporting that as "unreachable" would let this gate go
   * quiet exactly when the file it parses has changed shape. */
  console.error('changelog-gate: read no releases from changelog.txt — the format this gate parses has changed, fix the reader here');
  process.exit(1);
}

/* lib-ecosystem.read - the release-notes page DELETED upstream is a
 * finding (the two documents can then disagree about the facts with nobody
 * noticing), not a silent pass; an unreachable repository stays one. */
let docsText = null;
let from = '';
const docsEntry = REPOS.find((e) => e.org === 'abap2UI5' && e.repo === DOCS_REPO);
const got = await ecoRead(docsEntry, DOCS_FILE);
if (got.text !== undefined) {
  docsText = got.text;
  from = got.from;
} else if (got.missing) {
  console.error(`changelog-gate: abap2UI5/${DOCS_REPO}/${DOCS_FILE} is gone upstream - the release-notes page this changelog is held to no longer exists`);
  process.exit(1);
} else {
  console.log(`changelog-gate: ${ours.size} release(s) here; abap2UI5/${DOCS_REPO} not reachable (${got.note}) - not compared`);
  process.exit(0);
}

const theirs = readDocsPage(docsText);
if (theirs.size === 0) {
  console.error(`changelog-gate: read no releases from ${DOCS_REPO}/${DOCS_FILE} (read from ${from}) — the page this gate parses has changed shape, fix the reader here`);
  process.exit(1);
}

const problems = [];

/* Only versions at or above the oldest one the docs page carries are compared.
 * The page starts where the project started documenting releases for readers,
 * and back-filling it is not what this gate is for. */
const cmp = (a, b) => {
  const [x, y] = [a, b].map((v) => v.split('.').map(Number));
  for (let i = 0; i < 3; i += 1) if (x[i] !== y[i]) return x[i] - y[i];
  return 0;
};
const floor = [...theirs.keys()].sort(cmp)[0];

for (const [version, date] of ours) {
  if (cmp(version, floor) < 0) continue;
  if (!theirs.has(version)) {
    problems.push(
      `${version} is in changelog.txt but not on ${DOCS_REPO}/${DOCS_FILE}\n`
      + '    a release readers cannot find is a release they cannot decide about',
    );
    continue;
  }
  const theirDate = theirs.get(version);
  if (theirDate === null) {
    problems.push(`${version} has no date under its heading on ${DOCS_REPO}/${DOCS_FILE}`);
  } else if (theirDate !== date) {
    problems.push(`${version} shipped ${date} here and ${theirDate} on ${DOCS_REPO}/${DOCS_FILE}`);
  }
}

for (const version of theirs.keys()) {
  if (!ours.has(version)) {
    problems.push(
      `${version} is on ${DOCS_REPO}/${DOCS_FILE} but not in changelog.txt\n`
      + '    release.yaml builds its notes from changelog.txt, so this release would ship without them',
    );
  }
}

if (problems.length > 0) {
  console.error(`changelog-gate: ${problems.length} disagreement(s) with abap2UI5/${DOCS_REPO} (read from ${from})\n`);
  for (const p of problems) console.error(`  ${p}`);
  console.error('\n  Both files are hand-written on purpose - the prose differs, the facts must not.');
  process.exit(1);
}

console.log(`changelog-gate: ${ours.size} release(s) here, ${theirs.size} documented (read from ${from}) - versions and dates agree - OK`);
