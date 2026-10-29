#!/usr/bin/env node
/*
 * conventions-gate — the parts of CONVENTIONS.md a script can decide.
 *
 * CONVENTIONS.md is this repository's declaration of how the organisation's
 * repositories are laid out, and this repository broke most of it. Not one
 * rule at a time either: the workflow naming rule names `UI5.yaml -> UI5_2X`
 * as the bad example, and `UI5_2X.yaml` is a file here. §6 asks for a
 * CLAUDE.md next to every AGENTS.md, and there was none, in six repositories,
 * one of which said so in its AGENTS.md.
 *
 * That is the failure mode the document itself names — "prose is not a thing
 * that fails a pull request" — and the answer is not to delete the rules but
 * to make the ones that CAN fail a pull request do so. Two do:
 *
 *   1. workflow file names are lower kebab case (§2)
 *   2. a repository with an AGENTS.md has a CLAUDE.md (§6)
 *   3. a repository carrying ABAP or generated trees has a .gitattributes (§6)
 *   4. every `actions/setup-node@<sha>` under .github/ is the SAME sha -
 *      `.github/actions/setup/action.yml` is the one place for that pin and
 *      says that `trigger_local.yaml` (which cannot load the action) has to
 *      be kept equal to it, and the pins had drifted a minor version apart
 *      with nothing to say so (2026-10-22)
 *
 * The workflow names that predate this are GRANDFATHERED by name (the gate
 * prints the current count). Renaming a workflow renames its status check and
 * its badge URL, so doing it to the whole list at once is a change to make
 * deliberately rather than as a side effect of writing this gate. What the
 * list buys immediately is that the NEXT one cannot happen: a NEW workflow
 * has to be named properly.
 *
 * The list only shrinks. An entry naming a file that no longer exists fails —
 * so a rename removes its exception in the same change, and the list cannot
 * quietly outlive the problem it records (the same rule the linter baseline
 * and the corpus render skips follow).
 *
 *   node .github/scripts/conventions-gate.mjs     (npm run check:conventions)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const WORKFLOWS = path.join(ROOT, '.github', 'workflows');
const KEBAB = /^[a-z0-9]+(-[a-z0-9]+)*\.(yml|yaml)$/;

/* Workflow names that predate the rule. Each one is a status check and a badge
 * URL somebody may have linked, which is why they are exceptions rather than a
 * rename in this change. Remove an entry by renaming its file.
 *
 * They are being retired in stages rather than in one sweep, because renaming
 * a workflow retitles what branch protection requires and a repository that
 * renames the whole list at once is a repository with as many unrequirable
 * checks until somebody re-points every rule. The order follows the blast radius:
 *
 *   1. DONE - the two that produce no pull-request check at all.
 *      `build_rename` (workflow_dispatch only) and `check_v2_sdk` (schedule +
 *      dispatch) never report on a pull request, so no branch-protection rule
 *      can name them and the rename cost nothing but their references.
 *   2. NEXT - `UI5_2X.yaml`, which CONVENTIONS §2 names as its own bad example
 *      (`UI5.yaml -> UI5_2X`) and which this file's header therefore has to
 *      keep explaining. It IS a pull-request check, so it goes with the branch
 *      protection change in the same pull request.
 *   3. `ABAP_702`, `auto_downport`, `auto_abaplint_fix`, `trigger_local` -
 *      single-purpose workflows with few references each.
 *   4. LAST - `check_gates`, `check_app2abap`, `frontend_check`,
 *      `frontend_deploy`. These are the required checks and the ones the
 *      documentation names most (`check_gates` alone is referenced ~50 times),
 *      so each is its own change.
 *
 * The list only shrinks: an entry for a file that no longer exists fails
 * below, so a rename drops its exception in the same change. */
const GRANDFATHERED = new Set([
  'ABAP_702.yaml',
  'UI5_2X.yaml',
  'auto_abaplint_fix.yaml',
  'auto_downport.yaml',
  'check_app2abap.yaml',
  'check_gates.yaml',
  'frontend_check.yaml',
  'frontend_deploy.yaml',
  'trigger_local.yaml',
]);

let errors = 0;
const err = (m) => { console.log(`ERROR ${m}`); errors++; };

// --- §2 workflow file names -------------------------------------------------
const files = fs.existsSync(WORKFLOWS)
  ? fs.readdirSync(WORKFLOWS).filter((f) => /\.ya?ml$/.test(f)).sort()
  : [];
if (!files.length) err('.github/workflows has no workflow files — this gate would go blind');

let grandfathered = 0;
for (const f of files) {
  if (KEBAB.test(f)) continue;
  if (GRANDFATHERED.has(f)) { grandfathered++; continue; }
  err(`.github/workflows/${f}: CONVENTIONS §2 wants a lower-kebab-case file name`
    + ' — a new workflow is named by the rule, not by the exceptions around it');
}
for (const stale of [...GRANDFATHERED].filter((f) => !files.includes(f))) {
  err(`conventions-gate: ${stale} is grandfathered but no longer exists`
    + ' — drop it from GRANDFATHERED in .github/scripts/conventions-gate.mjs;'
    + ' the list has to shrink as the names are fixed, or it outlives the problem');
}

// --- §6 an AGENTS.md comes with a CLAUDE.md ---------------------------------
const has = (f) => fs.existsSync(path.join(ROOT, f));
if (has('AGENTS.md') && !has('CLAUDE.md')) {
  err('AGENTS.md without CLAUDE.md — CONVENTIONS §6. Claude Code reads CLAUDE.md and'
    + ' nothing else by that name, so the guidance is invisible to it without one;'
    + ' a pointer at AGENTS.md is the whole file.');
}

// --- §6 LF-only, enforced by .gitattributes ---------------------------------
/* src/ is pulled into SAP systems by abapGit, which expects LF. Measured
 * when the root file went in: `git add --renormalize .` changed nothing, so
 * the tree was already LF throughout and the file records that rather than
 * converting anything. (The delivery trees are no longer committed here -
 * they are built into the git-ignored tools/out/ and shipped byte for byte
 * by frontend_deploy, out of reach of any attribute of this repository.) */
if (!has('.gitattributes')) {
  err('no .gitattributes — CONVENTIONS §6 asks for one in every repository that'
    + ' carries ABAP or generated trees, and this one carries both. Without it a'
    + ' checkout with core.autocrlf=true rewrites src/ to CRLF and abapGit'
    + ' imports the difference.');
}

// --- one actions/setup-node pin ---------------------------------------------
/* Every yaml under .github/ - the workflows, the composite action, and the
 * shared workflows that are mirrored into the sibling repositories. Dependabot
 * bumps one file per pull request, so a half-done bump is the normal shape of
 * this drift, and the gate names every file so the bump is finished in the
 * same change. */
function yamlFiles(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...yamlFiles(p));
    else if (/\.ya?ml$/.test(entry.name)) out.push(p);
  }
  return out;
}
const SETUP_NODE = /uses:\s*actions\/setup-node@([0-9a-f]{40}|[^\s#]+)/g;
const pins = new Map();
for (const file of yamlFiles(path.join(ROOT, '.github'))) {
  const text = fs.readFileSync(file, 'utf8');
  for (const m of text.matchAll(SETUP_NODE)) {
    const rel = path.relative(ROOT, file).split(path.sep).join('/');
    if (!pins.has(m[1])) pins.set(m[1], []);
    pins.get(m[1]).push(rel);
  }
}
if (pins.size > 1) {
  err('actions/setup-node is pinned to more than one revision under .github/ -'
    + ' .github/actions/setup/action.yml is the one place for that pin and every'
    + ' other occurrence has to equal it (finish the bump in every file):');
  for (const [sha, files] of pins) console.log(`    ${sha}\n      ${files.join('\n      ')}`);
}

if (errors) {
  console.log(`conventions-gate: ${errors} error(s).`);
  process.exit(1);
}
console.log(`conventions-gate: ok (${files.length} workflow(s), ${grandfathered} grandfathered name(s),`
  + ` AGENTS.md${has('CLAUDE.md') ? ' + CLAUDE.md' : ''}, .gitattributes,`
  + ` setup-node pinned once in ${[...pins.values()].flat().length} file(s))`);
