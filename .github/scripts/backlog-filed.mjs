#!/usr/bin/env node
/*
 * backlog-filed — has anything with `state: filed` actually landed?
 *
 * A `filed` item is a claim about another repository, and the backlog cannot
 * see when that claim stops being true. `event-auto-model-update` said
 * "pending merge" for six days after abap2UI5#2545 merged, and nothing noticed
 * — at the FIRST filed item the stock ever had. The rule that a shipped
 * request is deleted rather than kept as a row only works if somebody is told
 * when it shipped.
 *
 * So this reads each `filed:` url and reports what GitHub says. It does not
 * delete anything: removing an item is the same human step as creating one,
 * and a merged pull request is not always the whole change.
 *
 * Not part of `check:backlog` — it needs the network, and a gate that goes red
 * because github.com is unreachable is a gate people switch off.
 *
 *   node .github/scripts/backlog-filed.mjs      (npm run backlog:filed)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const ITEMS = path.join(ROOT, 'backlog', 'items');

/* The api.github.com address for a `filed:` url, or null when the value is
 * not a github.com issue or pull request address.
 *
 * Anchored at the scheme and closed after the number: the unanchored form
 * accepted any string that merely CONTAINED such a path -
 * `https://example.com/?x=github.com/a/b/pull/1` - and built a request from
 * it, and its `[^/]+` owner and repository segments accepted `..`, which
 * fetch then resolved away into a different endpoint entirely. */
const API = (url) => {
  const m = /^https:\/\/github\.com\/([\w.-]+)\/([\w.-]+)\/(pull|issues)\/(\d+)(?:[/?#]|$)/.exec(url);
  if (!m || /^\.+$/.test(m[1]) || /^\.+$/.test(m[2])) return null;
  const kind = m[3] === 'pull' ? 'pulls' : 'issues';
  return `https://api.github.com/repos/${m[1]}/${m[2]}/${kind}/${m[4]}`;
};

const rows = [];
for (const name of fs.readdirSync(ITEMS).filter((n) => n.endsWith('.md')).sort()) {
  const text = fs.readFileSync(path.join(ITEMS, name), 'utf8');
  const state = (text.match(/^state:\s*(.+)$/m) || [])[1]?.trim();
  const filed = (text.match(/^filed:\s*(.+)$/m) || [])[1]?.trim();
  if (state !== 'filed') continue;
  const id = name.replace(/\.md$/, '');
  const api = filed && API(filed);
  if (!api) { rows.push([id, 'no url that resolves to a GitHub issue or pull request']); continue; }
  try {
    const res = await fetch(api, {
      headers: { Accept: 'application/vnd.github+json', 'User-Agent': 'abap2UI5-backlog' },
      signal: AbortSignal.timeout(20000),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const j = await res.json();
    if (j.merged) rows.push([id, `MERGED ${(j.merged_at || '').slice(0, 10)} — delete the item and run \`npm run backlog\``]);
    else if (j.state === 'closed') rows.push([id, `CLOSED without merging — decide: deferred, or back to open`]);
    else rows.push([id, `still open upstream`]);
  } catch (e) {
    rows.push([id, `not checked (${e.message})`]);
  }
}

if (!rows.length) { console.log('backlog-filed: nothing is in the `filed` state'); process.exit(0); }
console.log(`backlog-filed: ${rows.length} filed item(s)`);
for (const [id, what] of rows) console.log(`  ${id.padEnd(38)} ${what}`);
const landed = rows.filter(([, w]) => w.startsWith('MERGED') || w.startsWith('CLOSED'));
if (landed.length) console.log(`\n${landed.length} item(s) no longer describe open work.`);
