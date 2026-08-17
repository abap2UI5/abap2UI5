#!/usr/bin/env node
/*
 * frontend-module-gate — a `sap.ui.define` dependency must exist on the floor.
 *
 * A UI5 module the target release does not have 404s, and the ui5loader then
 * fails the WHOLE component rather than the one module. The app is blank.
 * There is no "unsupported feature" message, no degraded mode, nothing naming
 * the module — so the first guess is always wrong, and the release it breaks
 * on is the one nobody develops against.
 *
 * `sap/ui/core/Theming` and `sap/ui/core/Messaging` are both @since 1.118 and
 * both are needed here; `Component.js` therefore reaches for them with
 * `sap.ui.require("…")` at the point of use and branches on `undefined`. That
 * is the pattern, and it is easy to write and easy to forget — one `define`
 * entry is all it takes.
 *
 * SO THIS IS A RATCHET, NOT A REPAIR: 213 dependencies in 52 files, 31 UI5
 * modules, and every one of them long predates the floor. The exposure today
 * is zero; what this protects is that number staying zero, which nothing else
 * does.
 *
 * (The first draft of this file claimed "seven modules, three of them UI5" and
 * built an allow-list around it. That came from a grep that only matched
 * single-line `sap.ui.define([...])` and silently skipped every multi-line
 * array — which is most of them. Worth leaving here: a gate whose allow-list
 * is derived from a bad measurement passes, and reads as proof.)
 *
 * It is deliberately NOT an abap2ui5lint rule. That would want a per-release
 * module inventory nothing else needs, and a JavaScript input the linter does
 * not have. The list below is the whole data model, and a new entry costs one
 * line and a look.
 *
 *   node .github/scripts/frontend-module-gate.mjs   (npm run check:modules)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const SCAN = path.join(ROOT, 'app', 'webapp');
const FLOOR = '1.71';

/* Every UI5 module this repository names in a `sap.ui.define` array. All of
 * them are long-standing UI5 API, reviewed as present on the floor when this
 * list was written (2026-08-17) — deliberately a flat list rather than a
 * table of @since numbers, because inventing precise versions nobody
 * verified would be worse than none.
 *
 * The list is not the point; the DIFF is. A module that appears here has
 * been looked at once. A new one has not, and that is what the gate is for.
 *
 * A module NEWER than the floor does not belong here. It belongs behind
 * `sap.ui.require("…")` at the point of use with an `undefined` branch —
 * see `Component.js` and `sap/ui/core/Theming` (@since 1.118). */
const ALLOWED = new Set([
  'sap/m/Button',
  'sap/m/ComboBox',
  'sap/m/ComboBoxRenderer',
  'sap/m/Dialog',
  'sap/m/HBox',
  'sap/m/MessageBox',
  'sap/m/Text',
  'sap/m/Token',
  'sap/m/library',
  'sap/ui/Device',
  'sap/ui/VersionInfo',
  'sap/ui/core/BusyIndicator',
  'sap/ui/core/Control',
  'sap/ui/core/Element',
  'sap/ui/core/Fragment',
  'sap/ui/core/HTML',
  'sap/ui/core/IconPool',
  'sap/ui/core/Item',
  'sap/ui/core/Popup',
  'sap/ui/core/UIComponent',
  'sap/ui/core/message/Message',
  'sap/ui/core/mvc/Controller',
  'sap/ui/core/mvc/XMLView',
  'sap/ui/core/routing/HashChanger',
  'sap/ui/model/Filter',
  'sap/ui/model/FilterOperator',
  'sap/ui/model/Sorter',
  'sap/ui/model/json/JSONModel',
  'sap/ui/model/odata/v2/ODataModel',
  'sap/ui/unified/FileUploader',
  'sap/ui/util/Storage',
]);

function jsFiles(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const name of fs.readdirSync(dir).sort()) {
    const full = path.join(dir, name);
    if (fs.statSync(full).isDirectory()) jsFiles(full, out);
    else if (full.endsWith('.js')) out.push(full);
  }
  return out;
}

/* The dependency ARRAY only — `sap.ui.define([...])`. A `sap.ui.require("x")`
 * elsewhere in the file is the documented escape hatch and is not judged; that
 * asymmetry is the whole rule. */
const DEFINE = /sap\.ui\.define\s*\(\s*\[([^\]]*)\]/g;

const findings = [];
let files = 0;
let declared = 0;
const seen = new Set();

for (const file of jsFiles(SCAN)) {
  const rel = path.relative(ROOT, file).split(path.sep).join('/');
  const text = fs.readFileSync(file, 'utf8');
  let hit = false;
  for (const m of text.matchAll(DEFINE)) {
    for (const dep of m[1].matchAll(/["']([^"']+)["']/g)) {
      const mod = dep[1];
      hit = true;
      declared += 1;
      // z2ui5's own modules ship with the app; there is no UI5 release question
      if (mod.startsWith('z2ui5/') || mod.startsWith('./') || mod.startsWith('../')) continue;
      seen.add(mod);
      if (!ALLOWED.has(mod)) findings.push({ rel, mod });
    }
  }
  if (hit) files += 1;
}

console.log(
  `frontend-module: ${declared} dependency/dependencies in ${files} file(s), `
  + `${seen.size} UI5 module(s), floor ${FLOOR}`,
);

if (findings.length) {
  console.error(`\n${findings.length} UI5 module(s) declared in a sap.ui.define array and not on the ${FLOOR} list:`);
  for (const f of findings) console.error(`  ${f.rel}  ${f.mod}`);
  console.error(
    `\n  A module the ${FLOOR} runtime lacks 404s, and the ui5loader drops the WHOLE`
    + '\n  component - a blank app with nothing in the console naming it.'
    + '\n'
    + '\n  If the module exists on the floor: add it to ALLOWED in this script.'
    + '\n  If it does not: do not declare it. Require it lazily at the'
    + '\n  point of use and branch on undefined, the way Component.js reaches for'
    + '\n  sap/ui/core/Theming (@since 1.118).',
  );
  process.exit(1);
}

/* An allow-list entry nobody declares any more is a claim about this code base
 * that has stopped being true, and the next reader takes it for evidence. */
const stale = [...ALLOWED].filter((m) => !seen.has(m));
if (stale.length) console.log(`  allowed but not declared anywhere: ${stale.join(', ')}`);
console.log(`every declared UI5 module exists on ${FLOOR} - OK`);
