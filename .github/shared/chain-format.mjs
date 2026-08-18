/**
 * chain-format — the layout of a z2ui5_cl_ui5_view_builder chain.
 *
 * The chain is the only picture of the view's tree there is, so its layout is
 * load-bearing: one call per line, four spaces per level of nesting, an `end( )`
 * back in the column of the `ele( )` it closes.
 *
 * Why this is a gate and not prose: nothing else formats a builder chain.
 * abaplint's `indentation` does not reach into a method-call chain, and the
 * abap2UI5-linter's two layout rules judge a chain's OWN rhythm
 * (`chain-indentation`) and one call per line (`chain-element-per-line`) —
 * neither judges the STEP, so a chain uniformly indented by 8 passes both while
 * saying the wrong thing about depth. Every corpus had shipped that way: 77
 * drifted ports in samples-controls, 168 stray indent steps in samples, and in
 * the framework the start app carrying `)->ele( `Shell` )->ele( `Page` ).` on
 * one line, hiding a level — all of it green.
 *
 * ONE SOURCE, AND IT IS abap2UI5's `.github/shared/chain-format.mjs`. The two
 * repositories that run it — abap2UI5/samples and abap2UI5/samples-controls —
 * carry it byte-equal as `scripts/chain-format.mjs`. Change the source first
 * and copy it to both; abap2UI5's `npm run check:shared` is what notices when
 * that did not happen. The paragraph this replaces named a third copy at
 * `.github/scripts/chain-format-gate.mjs`, which has not existed since the
 * framework moved its own chains onto the linter's `chain-house-layout` rule,
 * and nothing was checking either claim.
 *
 * The framework therefore does not RUN this script, and holds it for the same
 * reason it holds `.github/abaplint/app-rules.json`: a file two repositories
 * share needs one owner, and peer-to-peer copies have no answer to which of
 * them is right. It is meant to go away — `view-chain-layout` says when: both
 * consumers pin the linter at a version that predates `chain-house-layout`,
 * and the day that pin can move, the script is deleted and the rule replaces
 * it in all three places at once.
 *
 * The rules it enforces are the `view-chain-layout`
 * skill; `formatSource` is exported so a generator that emits builder chains
 * can run its output through it rather than hand-indenting template strings —
 * that is how the layout drifted back in on samples-controls.
 *
 * The transform only ever rewrites whitespace BETWEEN chain segments (the `)->`
 * boundaries at paren depth 0). Literals, comments, blank lines and the internal
 * layout of a call's arguments are copied through. That is checked, not assumed:
 * collapsing every run of code-whitespace must yield the identical file before
 * and after, or the file is left alone and the run fails.
 *
 *   node scripts/chain-format.mjs           check, non-zero exit on deviation
 *   node scripts/chain-format.mjs --write   rewrite the deviating files
 */
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const CODE = 0, LIT = 1, COMMENT = 2;

/** mask[i] = CODE / LIT / COMMENT for every character of an ABAP source. */
export function classify(text) {
  const mask = new Uint8Array(text.length);
  let i = 0, lineStart = true;
  const n = text.length;
  while (i < n) {
    const c = text[i];
    if (c === '\n') { mask[i++] = CODE; lineStart = true; continue; }
    if (lineStart && (c === ' ' || c === '\t')) { mask[i++] = CODE; continue; }
    if (lineStart && c === '*') { while (i < n && text[i] !== '\n') mask[i++] = COMMENT; continue; }
    lineStart = false;
    if (c === '"') { while (i < n && text[i] !== '\n') mask[i++] = COMMENT; continue; }
    if (c === "'" || c === '`') {
      mask[i++] = LIT;
      while (i < n) {
        if (text[i] === c) {
          mask[i++] = LIT;
          if (i < n && text[i] === c) { mask[i++] = LIT; continue; }  // doubled = escaped
          break;
        }
        if (text[i] === '\n') break;                                  // unterminated: bail
        mask[i++] = LIT;
      }
      continue;
    }
    if (c === '|') {
      mask[i++] = LIT;
      while (i < n) {
        if (text[i] === '\\') { mask[i] = LIT; if (i + 1 < n) mask[i + 1] = LIT; i += 2; continue; }
        if (text[i] === '|') { mask[i++] = LIT; break; }
        mask[i++] = LIT;
      }
      continue;
    }
    mask[i++] = CODE;
  }
  return mask;
}

/** The formatting-neutral fingerprint: runs of code whitespace collapse to one space. */
export function normalise(text) {
  const mask = classify(text);
  let out = '', prevWs = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i];
    if (mask[i] === CODE && (ch === ' ' || ch === '\t' || ch === '\n' || ch === '\r')) {
      if (!prevWs) out += ' ';
      prevWs = true;
    } else {
      out += ch;
      prevWs = false;
    }
  }
  return out;
}

const BUILDER = /->(?:ele|tag|end|a)\(|=>factory\(/;

/** Statement spans, split at code dots outside parens. */
function* statements(text, mask) {
  let depth = 0, start = 0;
  for (let i = 0; i < text.length; i++) {
    if (mask[i] !== CODE) continue;
    const ch = text[i];
    if (ch === '(') depth++;
    else if (ch === ')') depth = Math.max(0, depth - 1);
    else if (ch === '.' && depth === 0) { yield [start, i + 1]; start = i + 1; }
  }
  if (start < text.length) yield [start, text.length];
}

/** Indices of a `)` that closes back to depth 0 and is followed by `->`. */
function splitPoints(text, mask, lo, hi) {
  let depth = 0;
  const pts = [];
  for (let i = lo; i < hi; i++) {
    if (mask[i] !== CODE) continue;
    if (text[i] === '(') depth++;
    else if (text[i] === ')') {
      depth--;
      if (depth === 0 && text.slice(i + 1, i + 3) === '->') pts.push(i);
    }
  }
  return pts;
}

const callKind = (seg) => (seg.match(/^\)->(\w+)\(/) || [, 'other'])[1];

function headKind(head) {
  const ms = [...head.matchAll(/->(\w+)\(|=>(\w+)\(/g)];
  if (!ms.length) return 'other';
  const m = ms[ms.length - 1];
  return m[1] || m[2];
}

export function formatSource(text) {
  const mask = classify(text);
  const edits = [];   // [paren index, target column, statement end]

  for (let [lo, hi] of statements(text, mask)) {
    while (lo < hi && ' \t\r\n'.includes(text[lo])) lo++;   // span starts after the previous dot
    if (!BUILDER.test(text.slice(lo, hi))) continue;
    const pts = splitPoints(text, mask, lo, hi);
    if (!pts.length) continue;

    const ls = text.lastIndexOf('\n', lo - 1) + 1;
    if (text.slice(ls, lo).trim()) continue;               // statement must start its own line
    const base = (text.slice(ls).match(/^ */) || [''])[0].length;

    /* The tree walk. `openCols` holds the column of every `ele( )` still open,
     * so a child sits one level in from its container and an `end( )` lands
     * back on the column of the element it closes. */
    const openCols = headKind(text.slice(lo, pts[0])) === 'ele' ? [base] : [];
    let attrCol = base + 4;
    for (let k = 0; k < pts.length; k++) {
      const p = pts[k];
      const kind = callKind(text.slice(p, k + 1 < pts.length ? pts[k + 1] : hi));
      const childCol = openCols.length ? openCols[openCols.length - 1] + 4 : base + 4;
      let col;
      if (kind === 'a') col = attrCol;
      else if (kind === 'ele') { col = childCol; openCols.push(col); attrCol = col + 4; }
      else if (kind === 'tag') { col = childCol; attrCol = col + 4; }
      else if (kind === 'end') {
        col = openCols.length ? openCols.pop() : Math.max(base, childCol - 4);
        attrCol = openCols.length ? openCols[openCols.length - 1] + 4 : base + 4;
      } else col = childCol;
      edits.push([p, col, hi]);
    }
  }
  if (!edits.length) return text;

  /** Re-indent a segment's continuation lines. A line whose indent is content —
   *  the middle of a string template — stays exactly where it is. */
  const shiftBlock = (block, blockStart, delta) => {
    if (delta === 0) return block;
    const lines = block.split('\n');
    let pos = blockStart;
    const out = lines.map((line, k) => {
      if (k === 0 || !line.trim()) { pos += line.length + 1; return line; }
      const lead = (line.match(/^[ \t]*/) || [''])[0].length;
      let movable = mask[pos + lead] !== LIT;
      for (let j = 0; j < lead && movable; j++) if (mask[pos + j] !== CODE) movable = false;
      const res = movable ? ' '.repeat(Math.max(0, lead + delta)) + line.slice(lead) : line;
      pos += line.length + 1;
      return res;
    });
    return out.join('\n');
  };

  const gapStart = (p) => {
    let q = p;
    while (q > 0 && ' \t\r\n'.includes(text[q - 1]) && mask[q - 1] === CODE) q--;
    return q;
  };

  const out = [];
  let prev = 0;
  for (let idx = 0; idx < edits.length; idx++) {
    const [p, col, stmtHi] = edits[idx];
    const end = Math.min(idx + 1 < edits.length ? edits[idx + 1][0] : text.length, stmtHi);
    const gs = gapStart(p);
    out.push(text.slice(prev, gs));                                    // content, verbatim
    out.push('\n'.repeat(Math.max(1, (text.slice(gs, p).match(/\n/g) || []).length)));
    out.push(' '.repeat(col));
    const segEnd = end < stmtHi ? gapStart(end) : end;
    out.push(shiftBlock(text.slice(p, segEnd), p, col - (p - (text.lastIndexOf('\n', p - 1) + 1))));
    prev = segEnd;
  }
  out.push(text.slice(prev));
  return out.join('');
}

function walk(dir, acc = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const f = path.join(dir, e.name);
    if (e.isDirectory()) walk(f, acc);
    else if (e.name.endsWith('.abap')) acc.push(f);
  }
  return acc;
}

/* Nothing below runs on import. */
if (import.meta.url !== pathToFileURL(process.argv[1] || '').href) {
  // imported as a library
} else main();

function main() {
const WRITE = process.argv.includes('--write');
const roots = process.argv.slice(2).filter((a) => !a.startsWith('-'));
const deviating = [];
const broken = [];

for (const root of roots.length ? roots : ['src']) {
  for (const file of walk(root).sort()) {
    const src = fs.readFileSync(file, 'utf8');
    if (!src.includes('_view_builder')) continue;
    const dst = formatSource(src);
    if (dst === src) continue;
    if (normalise(src) !== normalise(dst)) { broken.push(file); continue; }
    deviating.push(file);
    if (WRITE) fs.writeFileSync(file, dst);
  }
}

for (const f of broken) console.error(`chain-format: ${f} — transform is not whitespace-only, left untouched`);
for (const f of deviating) console.log(`${WRITE ? 'formatted' : 'deviates '}  ${f}`);

if (broken.length) {
  console.error(`\nchain-format: ${broken.length} file(s) could not be formatted safely`);
  process.exit(2);
}
if (!WRITE && deviating.length) {
  console.error(`\nchain-format: ${deviating.length} file(s) deviate — run \`npm run fmt:chains\``);
  process.exit(1);
}
console.log(`chain-format: ${WRITE ? `${deviating.length} file(s) formatted` : 'all chains formatted'}`);
}
