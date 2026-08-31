#!/usr/bin/env node
/*
 * check-catalogue-contract — the root `catalogue.json` is a PUBLISHED
 * interface, and this pins its shape.
 *
 * Three repositories publish one: abap2UI5/samples, abap2UI5/samples-controls
 * and abap2UI5/samples-stack. At least three programs outside them parse all
 * three shapes independently — abap2UI5/mcp-server's `lib/examples.mjs`, the
 * vscode-extension's `src/catalogue.ts` and the playground's examples browser
 * fetch these files raw from GitHub main — so a generator "tidying" a key
 * breaks consumers whose tests stay green, in repositories that only find out
 * from users. Each repository's own `generate-catalogue.mjs --check` proves
 * the file matches the TREE it was generated from; nothing proved it still
 * matches what the CONSUMERS parse. This does.
 *
 * The shapes deliberately differ per repository and this file pins them AS
 * THEY ARE, divergences included:
 *
 *   - samples names itself under `repository`, the other two under `repo`
 *   - samples and samples-controls put the source path in `file`,
 *     samples-stack in `path`
 *   - `keywords` is an ARRAY of words in samples and samples-stack, and one
 *     space-joined STRING in samples-controls
 *
 * Do not "fix" any of these here or in a generator: every consumer above
 * handles all three spellings today, and unifying them is a coordinated
 * cross-repository decision (producers, their committed catalogues, three
 * consumers), not a cleanup. Until that decision is made, changing a spelling
 * is drift, and this gate is what makes it a failing check instead of a
 * support issue.
 *
 * One copy per publishing repository, byte-identical; the source is
 * abap2UI5/.github/shared/check-catalogue-contract.mjs (`check:shared` gates
 * the copies, `sync-shared.yaml` pulls them). The file identifies which
 * repository it is running in from the catalogue itself, so the copies carry
 * nothing repository-specific.
 *
 *   node scripts/check-catalogue-contract.mjs        (from the repository root)
 */
import fs from 'node:fs';

const problems = [];
const fail = (msg) => problems.push(msg);

const text = fs.readFileSync('catalogue.json', 'utf8');
let cat;
try {
  cat = JSON.parse(text);
} catch (err) {
  console.error(`catalogue.json is not JSON: ${err.message}`);
  process.exit(1);
}

/* ------------------------------------------------------------- primitives */

const isStr = (v) => typeof v === 'string' && v.length > 0;
const isStrArray = (v) => Array.isArray(v) && v.every((x) => typeof x === 'string');

/** Every entry carries EXACTLY the declared keys. Exact, not "at least":
 *  all three catalogues have had no optional entry keys since they exist,
 *  a consumer may rely on that, and a new key appearing on some entries only
 *  is the start of the optionality no parser over there handles. */
function checkEntries(list, listName, fields) {
  const names = Object.keys(fields);
  list.forEach((e, i) => {
    const id = e?.class ?? `#${i}`;
    const keys = Object.keys(e ?? {});
    for (const k of keys) if (!names.includes(k)) fail(`${listName}[${id}]: unexpected key "${k}"`);
    for (const [k, ok] of Object.entries(fields)) {
      if (!(k in e)) { fail(`${listName}[${id}]: key "${k}" is missing`); continue; }
      if (!ok(e[k])) fail(`${listName}[${id}]: "${k}" has the wrong shape (${JSON.stringify(e[k]).slice(0, 60)})`);
    }
  });
}

function checkTop(required, listKey) {
  const keys = Object.keys(cat);
  for (const k of required) if (!keys.includes(k)) fail(`top level: key "${k}" is missing`);
  for (const k of keys) if (!required.includes(k)) fail(`top level: unexpected key "${k}"`);
  if (!Array.isArray(cat[listKey])) fail(`top level: "${listKey}" is not an array`);
  return Array.isArray(cat[listKey]) ? cat[listKey] : [];
}

function checkCommon(list, listName, prefix, pathKey) {
  const seen = new Set();
  for (const e of list) {
    const cls = String(e?.class ?? '');
    if (!cls.toUpperCase().startsWith(prefix)) fail(`${listName}[${cls}]: class does not carry the ${prefix}* prefix`);
    if (seen.has(cls.toUpperCase())) fail(`${listName}[${cls}]: class listed twice`);
    seen.add(cls.toUpperCase());
    /* the path must point INTO this checkout — a catalogue naming a file the
     * tree no longer has is stale, whatever generated it */
    const p = e?.[pathKey];
    if (isStr(p) && !fs.existsSync(p)) fail(`${listName}[${cls}]: ${pathKey} "${p}" does not exist in this repository`);
  }
}

/* ------------------------------------------------- one spec per publisher */

const who = cat.repository ?? cat.repo;

if (who === 'abap2UI5/samples') {
  const list = checkTop(
    ['purpose', 'repository', 'role', 'family', 'naming', 'scope', 'learningPath', 'counts', 'samples'],
    'samples',
  );
  const stages = new Set((cat.learningPath ?? []).map((s) => s.id));
  checkEntries(list, 'samples', {
    class: isStr,
    file: isStr,
    category: isStr,
    stage: (v) => isStr(v) && stages.has(v),
    title: isStr,
    description: isStr,
    summary: isStr,
    keywords: isStrArray,
    docs: isStrArray,
  });
  checkCommon(list, 'samples', 'Z2UI5_CL_SMP_', 'file');
  if (cat.counts?.samples !== list.length) fail(`counts.samples says ${cat.counts?.samples}, the array has ${list.length}`);
} else if (who === 'abap2UI5/samples-controls') {
  const list = checkTop(
    ['note', 'repo', 'role', 'caveat', 'categories', 'statuses', 'deviationTypes', 'ui5Snapshot', 'counts', 'ports'],
    'ports',
  );
  const statuses = new Set(Object.keys(cat.statuses ?? {}));
  const categories = new Set(Object.keys(cat.categories ?? {}));
  const deviationTypes = Object.keys(cat.deviationTypes ?? {});
  checkEntries(list, 'ports', {
    class: isStr,
    file: isStr,
    category: (v) => isStr(v) && categories.has(v),
    library: isStr,
    // empty on the src/03 SAPUI5 collection - those are free rebuilds with no
    // single demo kit original, so the KEY is the contract, not its content
    sample: (v) => typeof v === 'string',
    entity: (v) => typeof v === 'string',
    title: isStr,
    summary: isStr,
    // one space-joined string here, an array in the sibling repositories —
    // pinned as-is, see the header
    keywords: (v) => typeof v === 'string',
    status: (v) => isStr(v) && statuses.has(v),
    deviations: (v) => isStrArray(v)
      && v.every((d) => deviationTypes.some((t) => d.startsWith(t))),
  });
  checkCommon(list, 'ports', 'Z2UI5_CL_SMPC_', 'file');
  if (cat.counts?.entries !== list.length) fail(`counts.entries says ${cat.counts?.entries}, the array has ${list.length}`);
} else if (who === 'abap2UI5/samples-stack') {
  const list = checkTop(
    ['comment', 'repo', 'role', 'start', 'overviewApp', 'packages', 'samples'],
    'samples',
  );
  const packages = new Set((cat.packages ?? []).map((p) => p.package));
  const branches = new Set((cat.packages ?? []).map((p) => p.branch));
  checkEntries(list, 'samples', {
    class: isStr,
    path: isStr,
    package: (v) => isStr(v) && packages.has(v),
    technology: isStr,
    title: isStr,
    summary: isStr,
    keywords: isStrArray,
    runsOn: isStr,
    cloud: (v) => typeof v === 'boolean',
    needs: isStr,
    branch: (v) => isStr(v) && branches.has(v),
    setup: isStr,
  });
  checkCommon(list, 'samples', 'Z2UI5_CL_SMPS_', 'path');
} else {
  fail(`cannot tell which repository this catalogue belongs to — neither "repository" nor "repo" names one this contract knows (got ${JSON.stringify(who)})`);
}

/* ------------------------------------------------------------------ report */

if (problems.length) {
  console.error(`catalogue.json breaks the published contract - ${problems.length} problem(s):`);
  for (const p of problems.slice(0, 25)) console.error(`  ${p}`);
  if (problems.length > 25) console.error(`  ... and ${problems.length - 25} more`);
  console.error('\nthe shape is pinned by scripts/check-catalogue-contract.mjs (source: abap2UI5/.github/shared/) -');
  console.error('mcp-server, the vscode-extension and the playground parse this file from GitHub main.');
  process.exit(1);
}
const n = (cat.samples ?? cat.ports).length;
console.log(`catalogue.json keeps the published contract - ${n} entries in the ${who} shape`);
