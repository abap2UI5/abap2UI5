#!/usr/bin/env node
/*
 * generate-client-api — docs/agents/client-api.md, the client API as an index.
 *
 * `src/02/z2ui5_if_client.intf.abap` is the contract, and it documents itself
 * thoroughly: 1600 lines for 42 methods. That is the right place for the
 * reasoning and the wrong thing to read to answer "what is the parameter
 * called" - an agent that opens it for one signature pays for all of it, and
 * finds the obsolete methods standing between the current ones.
 *
 * So this writes the index: every method with its signature and the first
 * sentence of its documentation, the obsolete ones in a list of their own with
 * what replaces them, and the names of the constant structures. Nothing in it
 * is written by hand, so it cannot disagree with the interface - `--check`
 * (npm run check:client-api, part of the gates) fails when the committed file
 * is not what the interface produces today.
 *
 * The plugin generator carries the file into every skill copy as
 * `references/client-api.md`, next to the guide.
 *
 *   node .github/scripts/generate-client-api.mjs           (npm run client-api)
 *   node .github/scripts/generate-client-api.mjs --check   (npm run check:client-api)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const SOURCE = 'src/02/z2ui5_if_client.intf.abap';
const TARGET = 'docs/agents/client-api.md';
const CHECK = process.argv.includes('--check');

/* The constant structures an app names. Every `BEGIN OF cs_*` of the
 * interface is either listed here or fails the run - a new one is a decision
 * about this page, not something to drop silently. */
const CONSTANTS = new Map([
  ['cs_event', 'frontend actions for `follow_up_action( val = client->cs_event-… )` - the per-action `t_arg` is documented on `follow_up_action` in the interface'],
  ['cs_view', 'the view slots, for actions scoped to one of them'],
  ['cs_nav_mode', 'the modes of `cs_event-hash_routing`'],
  ['cs_transition', 'the page transitions `view_display( transition = … )` takes'],
  ['cs_device', 'the values the device facts take (system, browser, operating system, orientation)'],
]);

const lines = fs.readFileSync(path.join(ROOT, SOURCE), 'utf8').split('\n');

/* The first paragraph of an abapdoc block, cut at the sentence that ends
 * nearest to the limit: enough to say what the method is for. */
function summary(doc) {
  const para = [];
  for (const l of doc) {
    if (l === '' || l.startsWith('@parameter')) break;
    para.push(l);
  }
  const text = para.join(' ').replace(/\s+/g, ' ').replace(/&lt;/g, '<').replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&').trim();
  if (text.length <= 320) return text;
  const cut = text.slice(0, 320);
  const end = Math.max(cut.lastIndexOf('. '), cut.lastIndexOf(': '));
  return end > 80 ? cut.slice(0, end + 1) : `${cut.replace(/\s+\S*$/, '')} …`;
}

function parseMethod(statement) {
  const name = /METHODS\s+(\w+)/i.exec(statement)[1];
  const params = [];
  let result = null;
  let mode = null;
  for (const raw of statement.split('\n').slice(1)) {
    const l = raw.replace(/"[^`]*$/, '').trim().replace(/\.$/, '');
    if (!l) continue;
    if (/^(IMPORTING|EXPORTING|CHANGING|RETURNING|RAISING)\b/i.test(l)) {
      mode = l.split(/\s+/)[0].toUpperCase();
      const rest = l.slice(mode.length).trim();
      if (!rest) continue;
      take(rest);
      continue;
    }
    take(l);
  }
  function take(l) {
    if (mode === 'RAISING' || /^PREFERRED PARAMETER\b/i.test(l)) return;
    const m = /^(VALUE\((\w+)\)|!?(\w+))\s+TYPE\s+(.+?)(?:\s+(OPTIONAL|DEFAULT\s+.+))?$/i.exec(l);
    if (!m) throw new Error(`${SOURCE}: cannot read the parameter line "${l}" of ${name}`);
    const p = { name: (m[2] || m[3]).toLowerCase(), type: m[4].trim(), extra: (m[5] || '').trim() };
    if (mode === 'RETURNING') result = p;
    else params.push({ ...p, mode });
  }
  return { name, params, result };
}

const methods = [];
const structures = [];
let doc = [];
for (let i = 0; i < lines.length; i++) {
  const t = lines[i].trim();
  if (t.startsWith('"!')) {
    doc.push(t.slice(2).trim());
    continue;
  }
  const begin = /^BEGIN OF (cs_\w+),/i.exec(t);
  if (begin) {
    const name = begin[1].toLowerCase();
    const fields = [];
    for (i += 1; !new RegExp(`END OF ${name}`, 'i').test(lines[i]); i++) {
      const f = /^\s*(\w+)\s+TYPE\s+\S+\s+VALUE\b/i.exec(lines[i]);
      if (f) fields.push(f[1].toLowerCase());
    }
    structures.push({ name, fields });
    doc = [];
    continue;
  }
  if (/^METHODS\s+\w+/i.test(t)) {
    let statement = lines[i];
    while (!/\.\s*("[^`]*)?$/.test(lines[i])) statement += `\n${lines[++i]}`;
    methods.push({ ...parseMethod(statement), doc });
    doc = [];
    continue;
  }
  if (t && !t.startsWith('"')) doc = [];
}

for (const s of structures) {
  if (!CONSTANTS.has(s.name)) {
    throw new Error(`${SOURCE} declares ${s.name}, which generate-client-api.mjs does not describe - add it to CONSTANTS`);
  }
}
for (const name of CONSTANTS.keys()) {
  if (!structures.some((s) => s.name === name)) {
    throw new Error(`generate-client-api.mjs describes ${name}, which ${SOURCE} no longer declares - drop the entry`);
  }
}

const isObsolete = (m) => /^obsolete\b/i.test(m.doc[0] || '');

function signature(m) {
  const ps = m.params.map((p) => {
    const tail = p.extra ? ` ${p.extra.replace(/\s+/g, ' ')}` : '';
    const lead = p.mode === 'IMPORTING' ? '' : `${p.mode} `;
    return `    ${lead}${p.name} TYPE ${p.type}${tail}`;
  });
  const head = ps.length ? `${m.name}(\n${ps.join('\n')} )` : `${m.name}( )`;
  return m.result ? `${head}\n    -> ${m.result.type}` : head;
}

const current = methods.filter((m) => !isObsolete(m));
const obsolete = methods.filter(isObsolete);

const out = [];
out.push('# The client API in brief — `z2ui5_if_client`');
out.push('');
out.push(`<!-- GENERATED by .github/scripts/generate-client-api.mjs from ${SOURCE}. Do not edit; run npm run client-api. -->`);
out.push('');
out.push(`Every method an app can call on the \`client\` it is handed in \`main( )\`: the
signature and what it is for. A parameter without \`OPTIONAL\` or \`DEFAULT\` is
mandatory; \`->\` is the returning type. The contract, with the reasoning and
the per-parameter documentation, is \`${SOURCE}\` in
[abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5/blob/main/${SOURCE}) —
read a method's block there when this page is not enough.`);
out.push('');
out.push(`## Methods (${current.length})`);
for (const m of current) {
  out.push('');
  out.push(`### \`${m.name}\``);
  out.push('');
  out.push('```abap');
  out.push(signature(m));
  out.push('```');
  const s = summary(m.doc);
  if (s) {
    out.push('');
    out.push(s);
  }
}
out.push('');
out.push(`## Obsolete (${obsolete.length}) — still compile, never write them in new code`);
out.push('');
for (const m of obsolete) out.push(`- \`${m.name}\` — ${summary(m.doc).replace(/^obsolete\s*-\s*/i, '')}`);
out.push('');
out.push('## Constants');
out.push('');
for (const s of structures) {
  out.push(`- **\`${s.name}\`** — ${CONSTANTS.get(s.name)}:`);
  out.push(`  ${s.fields.map((f) => `\`${f}\``).join(', ')}`);
}
out.push('');

const text = out.join('\n');
const file = path.join(ROOT, TARGET);
if (CHECK) {
  const have = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
  if (have !== text) {
    console.error(`${TARGET} is not what ${SOURCE} produces - run npm run client-api and commit the result`);
    process.exit(1);
  }
  console.log(`${TARGET} matches ${SOURCE} (${current.length} methods, ${obsolete.length} obsolete) - OK`);
} else {
  fs.writeFileSync(file, text);
  console.log(`${TARGET} written from ${SOURCE} (${current.length} methods, ${obsolete.length} obsolete)`);
}
