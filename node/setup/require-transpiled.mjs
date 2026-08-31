#!/usr/bin/env node
/*
 * require-transpiled — the unit suite runs against TRANSPILED ABAP, and the
 * transpiled tree is not in the repository.
 *
 * `npm test` is, by CONVENTIONS section 3, one of the two commands an outside
 * developer types before reading anything. On a fresh clone it aliased
 * `npm run unit`, which is `node node/output/index.mjs`, and node answered:
 *
 *   Error: Cannot find module '/…/abap2UI5/node/output/index.mjs'
 *   code: 'MODULE_NOT_FOUND'
 *
 * That names the file nobody wrote by hand and not the two commands that write
 * it, so the honest reading is "the repository is broken" rather than "you
 * skipped a build step". `test.yaml` never hits it because the `transpile` job
 * produces `node/output` and every downstream job unpacks it.
 *
 * A guard rather than making `unit` run the transpile itself: the transpile is
 * minutes, `npm run unit` is seconds, and a developer iterating on the ABAP
 * runs it many times per transpile. Doing it implicitly would make the fast
 * command slow to save one error message.
 *
 *   node node/setup/require-transpiled.mjs      (first half of `npm run unit`)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const ENTRY = path.join(ROOT, 'node', 'output', 'index.mjs');

if (!fs.existsSync(ENTRY)) {
  console.error(
    'node/output is not there — the unit suite runs against transpiled ABAP,\n'
    + 'and the transpiled tree is generated, not committed. Build it first:\n'
    + '\n'
    + '    npm run downport         # copy src/, abaplint --fix the copy, strip whitespace\n'
    + '    npm run auto_transpile   # ABAP -> mjs into node/output\n'
    + '\n'
    + 'Both together take a few minutes; after that `npm run unit` is seconds,\n'
    + 'and only a change under src/ makes it stale (AGENTS.md, "Build & verify").',
  );
  process.exit(1);
}
