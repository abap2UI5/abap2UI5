#!/usr/bin/env node
/*
 * check-framework-pin — the sample repositories compile against a RELEASE of
 * abap2UI5, and this is what says so.
 *
 * ONE SOURCE, and it is abap2UI5's `.github/shared/check-framework-pin.mjs`.
 * The repositories that run it carry it byte-equal; abap2UI5's
 * `npm run check:shared` is what notices when that did not happen.
 *
 * WHY: abaplint resolves a git dependency by URL, and without a `"branch"` key
 * it clones the DEFAULT branch. So every one of these configs was linting the
 * corpus against abap2UI5 main — the development tip — while every reader of
 * these samples has a release installed. Two failure directions, both silent:
 *
 *   a sample uses API that only exists on main, CI is green, and the reader
 *   who copies it gets a syntax error. z2ui5_cl_ui5_view_builder is the case
 *   that happened: on main from 2026-08-12, not in a release until 1.143.0
 *   three weeks later.
 *
 *   the framework changes something on main, and nine workflows across three
 *   repositories go red overnight without a single commit in any of them.
 *
 * A release tag fixes both: the gate answers the question a reader actually
 * has. abaplint's `"branch"` is the only key it offers for this, and it feeds
 * `git clone --branch`, which takes a tag just as happily as a branch name.
 * (A `"tag"` key would be silently ignored — abaplint does not have one.)
 *
 * Policy:
 *   1. Every abaplint config's abap2UI5 dependency carries a `"branch"` key.
 *      No key means the default branch, which is the drift this exists for.
 *   2. Never two `"branch"` keys in one dependency entry. JSON parsing takes
 *      the LAST of duplicate keys, so a stale pin left NEXT to the intended
 *      one is invisible to every consumer that just parses the file.
 *   3. All configs name the SAME release, so a bump moves them together and
 *      one forgotten file cannot lint against a different framework than its
 *      neighbours. ALLOWED_BRANCHES carries the exceptions.
 *
 * The 702 exception: the downported build must resolve the framework against
 * its downported branch. abap2UI5 force-pushes `702` from main on every push
 * (auto_downport), so it is not a release pin — it is the only branch whose
 * content is v702-parseable at all, and main is not.
 *
 * Run:  node scripts/check-framework-pin.mjs              (offline, exit 1)
 *       node scripts/check-framework-pin.mjs --set 1.144.0 (move the pin)
 *
 * `--set` is here rather than in the bump workflow so the policy has ONE
 * implementation: which configs carry the release, which carry an allowlisted
 * branch, and what a release tag looks like are the same three answers whether
 * they are being checked or written. A workflow doing it with sed would be a
 * second, silent copy of that policy.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

// config path (repo-relative) -> the branch value its abap2UI5 dependency must
// carry INSTEAD of the release tag. Absent = must carry the release tag.
const ALLOWED_BRANCHES = new Map([
  ['.github/abaplint/abap_702.jsonc', '702'],
]);

const A2UI5_URL_RE = /github\.com\/abap2UI5\/abap2UI5/i;
const RELEASE_RE = /^\d+\.\d+\.\d+$/;

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

const SET = (() => {
  const i = process.argv.indexOf('--set');
  return i !== -1 ? process.argv[i + 1] : null;
})();

if (SET !== null) {
  if (!RELEASE_RE.test(SET || '')) {
    console.log(`ERROR --set wants a release tag (x.y.z), got ${JSON.stringify(SET)}`);
    process.exit(1);
  }
  let written = 0;
  for (const rel of configFiles()) {
    if (ALLOWED_BRANCHES.has(rel)) continue;
    const full = path.join(ROOT, rel);
    const raw = fs.readFileSync(full, 'utf8');
    /* Rewrite in the RAW text, not a parsed tree: these are .jsonc files whose
     * comments carry the reasoning, and a parse/serialise round trip would
     * drop every one of them. Anchored on the abap2UI5 url line so a `branch`
     * belonging to another dependency is left alone. */
    const next = raw.replace(
      /("url"\s*:\s*"https:\/\/github\.com\/abap2UI5\/abap2UI5"\s*,\s*\n\s*"branch"\s*:\s*")[^"]*(")/,
      `$1${SET}$2`,
    );
    if (next !== raw) { fs.writeFileSync(full, next); written++; }
  }
  console.log(`check-framework-pin: set ${written} config(s) to ${SET}`);
}

const releases = new Map();   // config -> release tag it names
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
      err(`${rel}: abap2UI5 dependency carries no "branch" key — abaplint then clones the DEFAULT branch, so this config lints against the framework's development tip instead of a release${expected ? `; this config wants "branch": ${JSON.stringify(expected)}` : ''}`);
      continue;
    }

    const [branch] = branches;
    if (expected !== undefined) {
      if (branch !== expected) {
        err(`${rel}: abap2UI5 dependency carries "branch": ${JSON.stringify(branch)}, but this config is allowlisted for ${JSON.stringify(expected)} — change ALLOWED_BRANCHES in the same commit if that is deliberate`);
      }
      continue;
    }
    if (!RELEASE_RE.test(branch)) {
      err(`${rel}: abap2UI5 dependency is pinned to ${JSON.stringify(branch)}, which is not a release tag (x.y.z) — only the allowlisted configs may name a branch`);
      continue;
    }
    releases.set(rel, branch);
  }
}

if (!checked) {
  err('no abap2UI5 dependency entry found in any abaplint config — did the dependency URL change? (this check would go blind)');
}

// --- 3. one release across the repository -----------------------------------
const distinct = [...new Set(releases.values())];
if (distinct.length > 1) {
  err(`the configs name ${distinct.length} different releases (${distinct.join(', ')}) — a bump has to move all of them:\n`
    + [...releases].map(([f, v]) => `        ${v}  ${f}`).join('\n'));
}

if (errors) {
  console.log(`check-framework-pin: ${errors} error(s).`);
  process.exit(1);
}
console.log(`check-framework-pin: ok (${checked} abap2UI5 dependency entr${checked === 1 ? 'y' : 'ies'}, release ${distinct[0] ?? 'none'}${ALLOWED_BRANCHES.size ? `, ${ALLOWED_BRANCHES.size} allowlisted branch pin(s)` : ''})`);
