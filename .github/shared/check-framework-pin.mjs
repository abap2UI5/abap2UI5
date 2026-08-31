#!/usr/bin/env node
/*
 * check-framework-pin — the sample repositories compile against abap2UI5's
 * MAIN branch, and this is what says so.
 *
 * ONE SOURCE, and it is abap2UI5's `.github/shared/check-framework-pin.mjs`.
 * The repositories that run it carry it byte-equal; abap2UI5's
 * `npm run check:shared` is what notices when that did not happen.
 *
 * WHY: abaplint resolves a git dependency by URL, and without a `"branch"` key
 * it clones the DEFAULT branch — an IMPLICIT state nothing reviews. This check
 * makes the resolution explicit and uniform, and it exists for two incidents:
 * a stale feature-branch `"branch"` key that survived its merge (the branch
 * was deleted, the clone failed), and duplicate `"branch"` keys silently
 * shadowing each other (JSON parsing takes the last one).
 *
 * Until 2026-08-31 the policy asked for a RELEASE TAG here, answering "does
 * the corpus compile for a reader who installed the release". That coupled
 * every corpus merge that uses new framework API to a framework RELEASE — and
 * the maintainer's release cadence is monthly while merges land daily (the
 * hash_* API wave sat behind by-design red lint for what would have been
 * weeks). So the configs resolve `main` now: merges gate on the framework as
 * it IS, the nightly canaries keep watching the tip, and what a sample needs
 * beyond the latest release stays documented in prose next to the sample
 * ("needs abap2UI5 newer than x.y.z"). A framework change on main that
 * reddens a corpus overnight is accepted as exactly that canary signal.
 * abaplint's `"branch"` feeds `git clone --branch` (a branch or a tag, never
 * a commit), so `main` is the closest checkable statement.
 *
 * Policy:
 *   1. Every abaplint config's abap2UI5 dependency carries a `"branch"` key.
 *      No key means the default branch, which is the implicit drift this
 *      exists for.
 *   2. Never two `"branch"` keys in one dependency entry. JSON parsing takes
 *      the LAST of duplicate keys, so a stale pin left NEXT to the intended
 *      one is invisible to every consumer that just parses the file.
 *   3. Every non-allowlisted config names `main` — explicit, identical, and a
 *      feature-branch re-point that survives a merge fails here.
 *      ALLOWED_BRANCHES carries the exceptions.
 *
 * The 702 exception: the downported build must resolve the framework against
 * its downported branch. abap2UI5 force-pushes `702` from main on every push
 * (auto_downport), so it is the only branch whose content is v702-parseable
 * at all, and main is not.
 *
 * Run:  node scripts/check-framework-pin.mjs              (offline, exit 1)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// config path (repo-relative) -> the branch value its abap2UI5 dependency must
// carry INSTEAD of main. Absent = must carry "main".
const ALLOWED_BRANCHES = new Map([
  ['.github/abaplint/abap_702.jsonc', '702'],
]);

// every non-allowlisted config resolves the framework here (see the header:
// the release-tag policy ended 2026-08-31 — releases are monthly snapshots
// and never gate a merge)
const REQUIRED_BRANCH = 'main';

/* The framework dependency, identified by its url VALUE rather than by a
 * substring of the entry.
 *
 * `/github\.com\/abap2UI5\/abap2UI5/` matched anywhere in the object slice and
 * stopped at the repository name without closing it, so
 * `https://github.com/abap2UI5/abap2UI5-local` - a different repository in
 * the same organisation, and a plausible thing for a config to depend on -
 * was read as the framework and had its "branch" key checked as if it were.
 * Anchoring at the key and closing at the quote leaves only the framework. */
const A2UI5_URL_RE = /"url"\s*:\s*"https:\/\/github\.com\/abap2UI5\/abap2UI5(?:\.git)?\/?"/i;

let errors = 0;
const err = (m) => { console.log(`ERROR ${m}`); errors++; };

/* Comment-stripping that leaves string contents alone — the configs are
 * .jsonc and a `//` inside a URL must survive. */
const stripComments = (s) => s
  .replace(/\/\*[\s\S]*?\*\//g, '')
  .replace(/([,{[\s])\/\/.*$/gm, '$1');

// balanced top-level {...} slices of an array body (strings are quote-aware)
function objectSlices(body) {
  const out = [];
  let depth = 0;
  let start = -1;
  let inStr = false;
  for (let i = 0; i < body.length; i++) {
    const c = body[i];
    if (inStr) {
      if (c === '\\') i++;
      else if (c === '"') inStr = false;
      continue;
    }
    if (c === '"') { inStr = true; continue; }
    if (c === '{') { if (depth === 0) start = i; depth++; }
    else if (c === '}') { depth--; if (depth === 0 && start >= 0) { out.push(body.slice(start, i + 1)); start = -1; } }
  }
  return out;
}

function configFiles() {
  const files = ['abaplint.jsonc'];
  const dir = path.join(ROOT, '.github', 'abaplint');
  if (fs.existsSync(dir)) {
    for (const f of fs.readdirSync(dir).sort()) {
      if (f.endsWith('.jsonc') || f.endsWith('.json')) files.push(path.posix.join('.github/abaplint', f));
    }
  }
  return files.filter((f) => fs.existsSync(path.join(ROOT, f)));
}

let checked = 0;

for (const rel of configFiles()) {
  const txt = stripComments(fs.readFileSync(path.join(ROOT, rel), 'utf8'));
  const depsM = txt.match(/"dependencies"\s*:\s*\[([\s\S]*?)\]/);
  if (!depsM) continue;
  for (const entry of objectSlices(depsM[1])) {
    if (!A2UI5_URL_RE.test(entry)) continue;
    checked++;
    const branches = [...entry.matchAll(/"branch"\s*:\s*"([^"]*)"/g)].map((m) => m[1]);
    const expected = ALLOWED_BRANCHES.get(rel);

    if (branches.length > 1) {
      err(`${rel}: abap2UI5 dependency carries ${branches.length} "branch" keys (${branches.map((b) => JSON.stringify(b)).join(', ')}) — duplicate keys silently shadow each other; keep exactly one`);
      continue;
    }
    if (branches.length === 0) {
      err(`${rel}: abap2UI5 dependency carries no "branch" key — an implicit default is exactly the silent state this check forbids; this config wants "branch": ${JSON.stringify(expected ?? REQUIRED_BRANCH)}`);
      continue;
    }

    const [branch] = branches;
    if (expected !== undefined) {
      if (branch !== expected) {
        err(`${rel}: abap2UI5 dependency carries "branch": ${JSON.stringify(branch)}, but this config is allowlisted for ${JSON.stringify(expected)} — change ALLOWED_BRANCHES in the same commit if that is deliberate`);
      }
      continue;
    }
    if (branch !== REQUIRED_BRANCH) {
      err(`${rel}: abap2UI5 dependency is pinned to ${JSON.stringify(branch)} — the syntax builds resolve the framework's ${JSON.stringify(REQUIRED_BRANCH)} (releases are monthly snapshots and never gate a merge; a deliberate re-point must edit ALLOWED_BRANCHES in the same commit)`);
      continue;
    }
  }
}

if (!checked) {
  err('no abap2UI5 dependency entry found in any abaplint config — did the dependency URL change? (this check would go blind)');
}

if (errors) {
  console.log(`check-framework-pin: ${errors} error(s).`);
  process.exit(1);
}
console.log(`check-framework-pin: ok (${checked} abap2UI5 dependency entr${checked === 1 ? 'y' : 'ies'} on ${REQUIRED_BRANCH}${ALLOWED_BRANCHES.size ? `, ${ALLOWED_BRANCHES.size} allowlisted branch pin(s)` : ''})`);
