#!/usr/bin/env node
/*
 * samples-md-gate — a catalogue row is a CONTRACT, and this is where it is
 * written down.
 *
 * `SAMPLES.md` is generated in three repositories — abap2UI5/samples,
 * /samples-controls and /samples-stack — by three independent programs, each
 * of them `scripts/generate-samples-md.mjs` and none of them the same code.
 * That is defensible: each generator knows its own repository's folder scheme,
 * its helper classes, its sections. Merging them is a large change with a small
 * payoff.
 *
 * What is NOT defensible is that the LINE FORMAT they all emit is read by two
 * programs in two further repositories:
 *
 *   abap2UI5/mcp-server   lib/examples.mjs  — the `examples` tool an agent
 *                                             searches all three catalogues with
 *   abap2UI5/docs         scripts/lib/catalogue.mjs
 *                                           — the "Working Samples" block on
 *                                             every cookbook page, and the app
 *                                             counts the site quotes
 *
 * Five programs, one row shape, and until now nothing anywhere stated it. Both
 * readers have the scar tissue to prove what that costs: each carries a comment
 * about the day its pattern silently stopped matching, and both describe the
 * same failure mode — a parser that matches nothing answers "there are no
 * samples for that" rather than "this file changed shape". A wrong answer, not
 * a red build. It has happened at least twice (the `@docs` block, then the
 * `@summary` sentence), each time because a generator grew a field and the
 * readers were in other repositories.
 *
 * So this gate reads the three published catalogues and checks every row
 * against BOTH readers' patterns — the patterns themselves, copied from the two
 * files above, not a third guess at what they accept. A generator change that
 * would blind either reader fails here, in the repository both readers already
 * depend on, before it is merged.
 *
 * It is deliberately NOT a check that the three catalogues look alike. They do
 * not: samples-controls writes its whole header in bold with nothing after it,
 * samples writes `**Header** — Title`, samples-stack has rows with no header at
 * all, and all three are fine because both readers accept all three. The rule
 * is "can be read", not "is written the way samples writes it".
 *
 * The one known asymmetry between the readers is left alone on purpose:
 * mcp-server's pattern makes the dash after a bold header optional and docs' does
 * not, so a bold-header-no-dash row loses its title over in docs and falls back
 * to `**Header**` inside the label. That renders as bold text in the generated
 * block — cosmetic, and it is docs' pattern to widen if anybody minds. What
 * matters, and what is checked, is that both readers get the same CLASS and the
 * same PATH out of every row, because those are the pointer.
 *
 * Reading, in order (shared-file-gate's, including the part that matters):
 *   a sibling CHECKOUT next to this one   (offline, and what a local run sees)
 *   raw.githubusercontent.com/<repo>/main (CI, and what is actually published)
 * When neither is reachable the run SAYS SO and passes. A repository's gates
 * must not go red because github.com is unreachable, and must not claim to have
 * verified something they did not.
 *
 *   node .github/scripts/samples-md-gate.mjs      (npm run check:samples-md)
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

const CATALOGUES = ['samples', 'samples-controls', 'samples-stack'];
const FILE = 'SAMPLES.md';
const raw = (repo) => `https://raw.githubusercontent.com/abap2UI5/${repo}/main/${FILE}`;

/* ------------------------------------------------------- the two readers */

/* Copied verbatim, so that "does this row parse" is answered by the program
 * that will actually parse it and not by an approximation of it. Both are one
 * line in their own repository; keeping them one line here makes a future diff
 * against the original a diff of one line.
 *
 * abap2UI5/mcp-server, lib/examples.mjs */
const MCP_ROW = /^\|\s*(?:\*\*(?<title>[^*]+)\*\*\s*(?:(?:—|--)\s*)?)?(?<sub>[^|<]*?)\s*(?<blocks>(?:<br>(?:<[a-z]+>[^<]*<\/[a-z]+>|[^<]*))*)\s*\|\s*\[`(?<cls>[A-Z0-9_]+)`\]\((?<path>[^)]+)\)\s*\|/;

/* abap2UI5/docs, scripts/lib/catalogue.mjs */
const DOCS_ROW = /^\|\s*(?:\*\*(?<title>[^*]+)\*\*\s*(?:—|--)\s*)?(?<sub>[^|<]*?)\s*(?<small>(?:<br>(?:<[a-z]+>[^<]*<\/[a-z]+>|[^<]*))*)\s*\|\s*\[`(?<cls>[A-Z0-9_]+)`\]\((?<path>[^)]+)\)\s*\|/;

/* Both readers walk the file the same way: a `##` or `###` line sets the
 * current section, and a row without a header of its own is titled by it. So a
 * row that sits under no heading has no name at all in either reader. */
const HEADING = /^#{2,3}\s+(.+?)\s*$/;

/* The `<br>`-separated blocks after the title, as mcp-server splits them. A block
 * this gate does not recognise costs nothing — that tolerance is the readers'
 * deliberate design and copying it is the point. */
const blocksOf = (blocks) =>
  [...(blocks || '').matchAll(/<br>(?:<([a-z]+)>([^<]*)<\/[a-z]+>|([^<]*))/g)]
    .map((m) => (m[1] !== undefined
      ? { tag: m[1], text: (m[2] || '').trim(), whole: m[0] }
      : { tag: '', text: (m[3] || '').trim(), whole: m[0] }));

const DOC_LINK = /\[([^\]]+)\]\(([^)]+)\)/g;

/* --------------------------------------------------------- the row shape */

/* Which table a row belongs to. A catalogue table is headed `| Sample | Class |`
 * and every reader's pattern is aimed at its rows. The sample repositories also
 * publish tables of SUPPORTING classes — `| Class | What it is |`, the class in
 * the first column — which are not apps, do not parse into a pointer, and are
 * not meant to: samples-stack has eight of them and docs' `countCatalogue`
 * comment names them as the reason its count is "what this repository can
 * resolve" rather than a row count. Telling the two apart by their header is
 * what lets this gate say "every row of a catalogue table must parse" instead
 * of the much weaker "some rows parse". */
const CATALOGUE_HEAD = /^\|\s*Sample\s*\|\s*Class\s*\|\s*$/;
const DELIMITER = /^\|[\s:|-]+\|\s*$/;

function checkCatalogue(repo, text) {
  const problems = [];
  const seen = new Map();
  let section = '';
  let inCatalogue = false;
  let rows = 0;

  const lines = text.split('\n');
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    const at = `${repo}/${FILE}:${i + 1}`;

    const head = HEADING.exec(line);
    if (head) { section = head[1].trim(); inCatalogue = false; continue; }

    /* A table ends at the first line that is not a row. The flag has to come
     * down there, or a pipe line further down the page would be judged as part
     * of a table it is not in. */
    if (!line.startsWith('|')) { inCatalogue = false; continue; }
    if (CATALOGUE_HEAD.test(line)) { inCatalogue = true; continue; }
    if (DELIMITER.test(line)) continue;
    if (!inCatalogue) {
      /* A row that parses as a catalogue row but is not IN a catalogue table.
       * Both readers scan the whole file line by line and know nothing about
       * tables, so they would take it — a supporting class or a stray example
       * would arrive at an agent as an app it can start. */
      if (MCP_ROW.test(line) || DOCS_ROW.test(line)) {
        problems.push(`${at}: parses as a catalogue row but is not under a \`| Sample | Class |\` header`);
      }
      continue;
    }

    rows += 1;
    const mcp = MCP_ROW.exec(line);
    const docs = DOCS_ROW.exec(line);
    if (!mcp || !docs) {
      const who = !mcp && !docs ? 'neither reader' : (!mcp ? "abap2UI5/mcp-server's reader" : "abap2UI5/docs' reader");
      problems.push(
        `${at}: ${who} can parse this row\n`
        + `      ${JSON.stringify(line.slice(0, 120))}\n`
        + '      a row is `| <title blocks> | [`CLASS`](path) |` — see this gate\'s header',
      );
      continue;
    }

    const g = mcp.groups;
    /* The pointer is the whole answer both readers exist to give. If they
     * disagree about it, one of them is sending a reader to the wrong file. */
    if (g.cls !== docs.groups.cls || g.path !== docs.groups.path) {
      problems.push(
        `${at}: the two readers disagree about the pointer\n`
        + `      mcp-server: ${g.cls} -> ${g.path}\n`
        + `      docs:       ${docs.groups.cls} -> ${docs.groups.path}`,
      );
    }

    if (!section) {
      problems.push(`${at}: sits under no \`##\` heading — a row without its own header is titled by its section`);
    }

    /* The link target is the class file. Both readers hand the path straight to
     * a reader or a URL builder without checking it, and mcp-server additionally
     * decides `src/01` vs experimental from its first segment. */
    if (!/^src\/[^)\s]*\.clas\.abap$/.test(g.path)) {
      problems.push(`${at}: \`${g.path}\` is not a \`src/…/<class>.clas.abap\` path`);
    } else {
      const base = path.posix.basename(g.path, '.clas.abap');
      if (base !== g.cls.toLowerCase()) {
        problems.push(`${at}: the link says \`${g.cls}\` and points at \`${base}.clas.abap\``);
      }
    }

    /* Both readers key a Map by class name, so a second row for the same class
     * does not duplicate — it silently replaces the first. */
    const prior = seen.get(g.cls);
    if (prior) problems.push(`${at}: \`${g.cls}\` is already a row at line ${prior} — the later row wins in both readers`);
    else seen.set(g.cls, i + 1);

    /* A `<br>` block opens and closes with the SAME tag. The readers' pattern
     * accepts any closing tag (`</[a-z]+>`), so `<sub>…</sup>` parses — into a
     * block tagged `sub`, which is the one both of them go looking for. */
    for (const b of blocksOf(g.blocks)) {
      const pair = /^<br><([a-z]+)>[^<]*<\/([a-z]+)>$/.exec(b.whole);
      if (pair && pair[1] !== pair[2]) {
        problems.push(`${at}: a block opens \`<${pair[1]}>\` and closes \`</${pair[2]}>\``);
      }
    }

    /* The `docs:` block: mcp-server returns its links as the answer to "which
     * chapter explains this", and finds the KEYWORDS by taking the first `<sub>`
     * that is not it. Two of them and the second is unreachable. */
    const docBlocks = blocksOf(g.blocks).filter((b) => b.tag === 'sub' && b.text.startsWith('docs:'));
    if (docBlocks.length > 1) {
      problems.push(`${at}: ${docBlocks.length} \`docs:\` blocks — only the first is ever read`);
    }
    for (const b of docBlocks) {
      const links = [...b.text.matchAll(DOC_LINK)];
      const left = b.text.replace(/^docs:\s*/, '').replace(DOC_LINK, '').replace(/[\s,]/g, '');
      if (!links.length) problems.push(`${at}: a \`docs:\` block with no \`[topic](url)\` link in it`);
      if (left) problems.push(`${at}: a \`docs:\` block carries text outside its links: ${JSON.stringify(left)}`);
    }
  }

  return { problems, rows, classes: seen.size };
}

/* ------------------------------------------------------------------- run */

const problems = [];
const notes = [];
const read = [];

for (const repo of CATALOGUES) {
  const local = path.join(ROOT, '..', repo, FILE);
  let text = null;
  let from = '';
  if (fs.existsSync(local)) {
    text = fs.readFileSync(local, 'utf8');
    from = 'checkout';
  } else {
    try {
      const res = await fetch(raw(repo), { signal: AbortSignal.timeout(15000) });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      text = await res.text();
      from = 'github';
    } catch (err) {
      notes.push(`${repo}: not read (${err.message})`);
      continue;
    }
  }

  const result = checkCatalogue(repo, text);
  read.push(`${repo}: ${result.rows} row(s) (from ${from})`);
  if (!result.rows) {
    problems.push(`${repo}/${FILE}: no catalogue rows at all — either the file or this gate has the shape wrong`);
  }
  problems.push(...result.problems);
}

console.log(`samples-md: ${read.length} of ${CATALOGUES.length} catalogue(s) read`);
for (const r of read) console.log(`  ${r}`);
for (const n of notes) console.log(`  ${n}`);

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`);
  for (const p of problems) console.error(`  ${p}`);
  console.error(
    '\n  The row format is read by abap2UI5/mcp-server (lib/examples.mjs) and'
    + '\n  abap2UI5/docs (scripts/lib/catalogue.mjs). A row neither can parse is'
    + '\n  a sample that answers "no such sample" instead of failing anything.'
    + '\n  Fix the generator in the repository the row came from.',
  );
  process.exit(1);
}
if (!read.length) {
  console.log('no catalogue reachable — not a failure, but nothing was verified');
} else {
  console.log('every catalogue row can be read by both readers - OK');
}
