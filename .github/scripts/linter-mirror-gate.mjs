#!/usr/bin/env node
/*
 * linter-mirror-gate — the linter mirrors three things this repository owns,
 * and this is the side of that contract that lives here.
 *
 * @abap2ui5/linter carries hand-maintained copies of closed sets defined in
 * this repository:
 *
 *   lib/formatters.mjs        <- app/webapp/model/formatter.js
 *   lib/frontend-actions.mjs  <- src/01/03/z2ui5_cl_ui5f_*_js.clas.abap
 *   lib/released-api.mjs      <- the abapGit object layout of src/
 *
 * The linter checks them weekly (upstream-sync.yml) and opens an issue. That
 * catches the drift, but always AFTER it happened and never where it was
 * caused: the pull request that renames a formatter or splits an action module
 * is green here, and up to a week later a repository nobody in this change was
 * thinking about starts reporting correct code as invalid. It has happened in
 * both directions — a new CONTROL_GLOBAL target is how POPUP.setWithinArea
 * arrived, and the action JS being split from one class into one per action
 * group left the linter's own checker reading a file that no longer existed.
 *
 * So the same comparison runs here too, against the WORKING TREE, on the
 * change that moves the source. A rename then fails the pull request that does
 * the renaming, which is the only place it is cheap to fix.
 *
 * The comparison is the linter's own script — `--local` mode, which it already
 * has — never a second implementation of it here. Two consequences, both
 * deliberate:
 *
 *   it is only available once the installed linter publishes that script. An
 *   older one means this gate SAYS SO and passes, the same rule every other
 *   cross-repository gate here follows: never go red for a missing sibling,
 *   never claim to have verified what was not verified.
 *
 *   exit 2 from it means the sources could not be read, not that they drifted.
 *   That is a skip, not a failure.
 *
 *   node .github/scripts/linter-mirror-gate.mjs     (npm run check:mirrors)
 */
import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const PKG = path.join(ROOT, 'node_modules', '@abap2ui5', 'linter');
const SCRIPT = path.join(PKG, 'scripts', 'check-upstream.mjs');

/* Both halves have to be there, and the second is not pedantry: the script
 * imports the three mirrors out of the package's own lib/, so a checkout with
 * the script but no package fails with ERR_MODULE_NOT_FOUND and exit 1 — the
 * same exit code drift uses. Without this the gate would report a missing
 * install as a mirror that moved, which is a false alarm pointing at the wrong
 * repository entirely. */
if (!fs.existsSync(path.join(PKG, 'lib', 'formatters.mjs'))) {
  console.log('linter-mirror: @abap2ui5/linter is not installed here — SKIPPED, not verified.');
  process.exit(0);
}
if (!fs.existsSync(SCRIPT)) {
  console.log('linter-mirror: the installed @abap2ui5/linter does not ship scripts/check-upstream.mjs');
  console.log('               (published from linter 0.2.3 on) — SKIPPED, not verified.');
  process.exit(0);
}

const run = spawnSync(process.execPath, [SCRIPT, '--local', ROOT], { encoding: 'utf8' });
if (run.stdout) process.stdout.write(run.stdout);
if (run.stderr) process.stderr.write(run.stderr);

if (run.status === 2) {
  console.log('linter-mirror: the sources could not be read — SKIPPED, not verified.');
  process.exit(0);
}
if (run.status !== 0) {
  console.error(`\nlinter-mirror: @abap2ui5/linter mirrors something this change moved (exit ${run.status}).`);
  console.error('The linter is not a dependency of this repository, so nothing else notices:');
  console.error('its weekly upstream-sync would file an issue days from now, against a');
  console.error('repository whose users hit it first. Fix it in the linter alongside this');
  console.error('change, or say in the pull request why the mirror should stay as it is.');
  process.exit(1);
}
console.log('linter-mirror: the linter\'s copies still match this tree - OK');
