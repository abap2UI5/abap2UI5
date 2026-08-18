#!/usr/bin/env node
/*
 * check-app-rules — this repository's abaplint rules match the shared set.
 *
 * The shared set is `abap2UI5/abap2UI5`'s `.github/abaplint/app-rules.json`:
 * 187 rules, everything except `object_naming`, which every repository sets
 * for its own object prefixes. abap2UI5 is the SOURCE — it is where the rest
 * of "how to write an abap2UI5 app" already lives (the build-an-app and
 * view-chain-layout skills, docs/agents/building-apps.md, abap-check,
 * ui5-check), and a shared thing needs one owner.
 *
 * This replaces a peer comparison against the other two sample repositories,
 * which had three problems. Two were structural: three peers have no answer to
 * which of them is right, and a repository without its own copy of the checker
 * made the OTHER repositories' CI go red when it drifted. The third was worse,
 * because it was the case the checker existed for: it compared rule NAMES with
 * a regex over `"name":` keys, so `"prefer_inline": true` and
 * `"prefer_inline": false` looked identical to it — and switching a rule off to
 * get a pull request through is precisely the drift it was written to catch.
 *
 * So this compares PARSED SETTINGS, and it runs here, in the repository whose
 * pull request would cause the drift.
 *
 * abap2UI5 checks the same thing from its side (`shared-file-gate.mjs`) — that
 * is the source noticing, this is the consumer noticing. Both are cheap.
 *
 * A missing source (offline, rate limit, a sandbox with no route out) SAYS SO
 * and passes: a repository's gates must not go red because github.com is
 * unreachable, and must not claim to have verified what they did not.
 *
 * The SCRIPT is shared the same way the rule set it reads is: ONE SOURCE, and
 * it is abap2UI5's `.github/shared/check-app-rules.mjs`. The three repositories
 * that run it carry it byte-equal as `scripts/check-app-rules.mjs`; change the
 * source first and copy it to all three, and abap2UI5's `npm run check:shared`
 * is what notices when that did not happen. Three unowned copies of the
 * checker would have been the same arrangement the checker was written to
 * replace, one directory up.
 *
 *   node scripts/check-app-rules.mjs      (npm run check:app-rules)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const HERE = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const SOURCE = '.github/abaplint/app-rules.json';
const RAW = `https://raw.githubusercontent.com/abap2UI5/abap2UI5/main/${SOURCE}`;
const SIBLING = path.join(HERE, '..', 'abap2UI5', SOURCE);

/* JSONC: strip comments, keeping anything inside a string. A naive strip eats
 * the `//` of the dependency URLs this config carries. */
function parseJsonc(text) {
  let out = '';
  let inString = false;
  let quote = '';
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    const next = text[i + 1];
    if (inString) {
      out += c;
      if (c === '\\') { out += next; i += 1; continue; }
      if (c === quote) inString = false;
      continue;
    }
    if (c === '"' || c === "'") { inString = true; quote = c; out += c; continue; }
    if (c === '/' && next === '/') { while (i < text.length && text[i] !== '\n') i += 1; out += '\n'; continue; }
    if (c === '/' && next === '*') { i += 2; while (i < text.length && !(text[i] === '*' && text[i + 1] === '/')) i += 1; i += 1; continue; }
    out += c;
  }
  return JSON.parse(out.replace(/,(\s*[}\]])/g, '$1'));
}

const shared = (rules) => {
  const out = {};
  for (const k of Object.keys(rules).sort()) if (k !== 'object_naming') out[k] = rules[k];
  return out;
};

let source = null;
let from = '';
if (fs.existsSync(SIBLING)) {
  source = JSON.parse(fs.readFileSync(SIBLING, 'utf8'));
  from = 'the abap2UI5 checkout next to this one';
} else {
  try {
    const res = await fetch(RAW, { signal: AbortSignal.timeout(15000) });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    source = await res.json();
    from = 'abap2UI5/main';
  } catch (err) {
    console.log(`check-app-rules: source not reachable (${err.message}) — nothing verified, not a failure`);
    process.exit(0);
  }
}

const mine = shared(parseJsonc(fs.readFileSync(path.join(HERE, 'abaplint.jsonc'), 'utf8')).rules);
const theirs = shared(source.rules);

const problems = [];
for (const key of new Set([...Object.keys(theirs), ...Object.keys(mine)])) {
  const a = JSON.stringify(theirs[key]);
  const b = JSON.stringify(mine[key]);
  if (a === b) continue;
  if (a === undefined) problems.push(`\`${key}\` is configured here and not in the shared set`);
  else if (b === undefined) problems.push(`\`${key}\` is in the shared set and not configured here`);
  else problems.push(`\`${key}\`: shared set has ${a}, this repository has ${b}`);
}

console.log(
  `check-app-rules: ${Object.keys(mine).length} rule(s) here, `
  + `${Object.keys(theirs).length} in the shared set (read from ${from})`,
);

if (problems.length) {
  console.error(`\n${problems.length} difference(s) from the shared set:`);
  for (const p of problems.sort()) console.error(`  ${p}`);
  console.error(
    '\n  abap2UI5 is the source. Change it there first and copy it here, or —'
    + '\n  if this repository genuinely needs its own value — say so in'
    + `\n  abap2UI5's ${SOURCE} rather than diverging silently.`,
  );
  process.exit(1);
}
console.log('this repository matches the shared rule set - OK');
