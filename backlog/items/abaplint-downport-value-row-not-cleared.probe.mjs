/*
 * Detector for `abaplint-downport-value-row-not-cleared`: a table VALUE
 * constructor whose later row leaves out a component an earlier row
 * assigned. The downport builds every row in ONE work area and never clears
 * it between rows, so on the downported code (the 702 branch, and the tree
 * `npm run unit` transpiles) that row inherits the earlier value. The
 * negatives are the multi-row constructors whose rows differ in shape but
 * never leave out what an earlier row set - they downport correctly.
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'a table VALUE constructor where a later row leaves out a component an earlier row assigned, with the constructors whose rows differ in shape but never leave one out as the negative';

/* Blank comments and string contents (keeping offsets and newlines), so the
 * parenthesis matching below only sees code. */
function codeOnly(text) {
  const out = text.split('');
  let i = 0;
  let lineStart = true;
  const blank = (from, to) => {
    for (let k = from; k < to; k++) if (out[k] !== '\n') out[k] = ' ';
  };
  while (i < text.length) {
    const c = text[i];
    if (c === '\n') { lineStart = true; i++; continue; }
    if (lineStart && c === '*') {
      const end = text.indexOf('\n', i);
      blank(i, end < 0 ? text.length : end);
      i = end < 0 ? text.length : end;
      continue;
    }
    lineStart = false;
    if (c === '"') {
      const end = text.indexOf('\n', i);
      blank(i, end < 0 ? text.length : end);
      i = end < 0 ? text.length : end;
      continue;
    }
    if (c === "'" || c === '`' || c === '|') {
      let j = i + 1;
      while (j < text.length) {
        if (c === '|' && text[j] === '\\') { j += 2; continue; }
        if (text[j] === c) {
          if (c !== '|' && text[j + 1] === c) { j += 2; continue; }
          break;
        }
        if (c !== '|' && text[j] === '\n') break;
        j++;
      }
      blank(i + 1, j);
      i = j + 1;
      continue;
    }
    i++;
  }
  return out.join('');
}

/* The index of the parenthesis closing the one at `open`. */
function closing(code, open) {
  let depth = 0;
  for (let k = open; k < code.length; k++) {
    if (code[k] === '(') depth++;
    else if (code[k] === ')') { depth--; if (depth === 0) return k; }
  }
  return -1;
}

/* The direct children of a parenthesised span: words and nested spans. */
function children(code, from, to) {
  const kids = [];
  let k = from;
  while (k < to) {
    if (/\s/.test(code[k])) { k++; continue; }
    if (code[k] === '(') {
      const end = closing(code, k);
      kids.push({ kind: 'span', start: k, end, glued: k > 0 && !/\s/.test(code[k - 1]) });
      k = end + 1;
      continue;
    }
    let e = k;
    while (e < to && !/\s/.test(code[e]) && code[e] !== '(' && code[e] !== ')') e++;
    if (code[e] === '(') {
      /* `name(` - a call or `#(`: the word and its argument span are one operand */
      const end = closing(code, e);
      kids.push({ kind: 'word', text: code.slice(k, e).toUpperCase(), start: k, end, call: true });
      k = end + 1;
      continue;
    }
    kids.push({ kind: 'word', text: code.slice(k, e).toUpperCase(), start: k, end: e - 1 });
    k = e;
  }
  return kids;
}

/* The components a row (or the shared prefix) assigns: `name =` at depth 0. */
function assigned(kids) {
  const names = [];
  kids.forEach((kid, n) => {
    const next = kids[n + 1];
    if (kid.kind === 'word' && !kid.call && next && next.kind === 'word' && next.text === '='
      && /^[A-Z_][\w/-]*$/.test(kid.text)) names.push(kid.text.toLowerCase());
  });
  return names;
}

const OPERATORS = new Set(['=', '+', '-', '*', '/', '**', '&&', '&', 'AND', 'OR', 'NOT', 'EQ', 'NE',
  '<', '>', '<=', '>=', '<>', 'THEN', 'ELSE', 'IN', 'MOD', 'DIV', 'BIT-AND', 'BIT-OR']);

export function run(roots) {
  const sites = [];
  const negatives = [];
  let withFor = 0;
  let uniform = 0;
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const code = codeOnly(file.text);
      const lineOf = (off) => code.slice(0, off).split('\n').length;
      const re = /\bVALUE\s+(#|[A-Za-z_][\w/=>~-]*)\(/gi;
      let m;
      while ((m = re.exec(code))) {
        const open = m.index + m[0].length - 1;
        const close = closing(code, open);
        if (close < 0) continue;
        const kids = children(code, open + 1, close);
        if (kids.some((k) => k.kind === 'word' && k.text === 'FOR')) { withFor++; continue; }
        /* a row is a free-standing span that does not continue an operand */
        const rows = [];
        kids.forEach((kid, n) => {
          const prev = kids[n - 1];
          const isRow = kid.kind === 'span' && !kid.glued
            && (!prev || !(prev.kind === 'word' && OPERATORS.has(prev.text)));
          if (isRow) rows.push(kid);
        });
        const structured = rows
          .map((r) => ({ row: r, kids: children(code, r.start + 1, r.end) }))
          .filter((r) => r.kids.length === 0 || assigned(r.kids).length > 0);
        if (structured.length < 2) continue;
        const seen = new Map(); /* component -> row number that set it */
        const leaks = [];
        const shapes = new Set();
        structured.forEach((r, n) => {
          const own = assigned(r.kids);
          shapes.add([...own].sort().join(' '));
          const covered = (c) => own.some((o) => o === c || c.startsWith(`${o}-`));
          const missing = [...seen.keys()].filter((c) => !covered(c));
          if (missing.length) leaks.push({ n: n + 1, missing: missing.map((c) => `${c} (row ${seen.get(c)})`) });
          own.forEach((c) => seen.set(c, n + 1));
        });
        const line = lineOf(m.index);
        if (leaks.length) {
          const first = leaks[0];
          sites.push({
            repo: file.repo,
            file: file.rel,
            line,
            text: `${structured.length} rows, ${leaks.length} inherit: row ${first.n} leaves out ${first.missing.join(', ')}`,
          });
        } else if (shapes.size > 1) {
          negatives.push({ repo: file.repo, file: file.rel, line, text: `${structured.length} rows of ${shapes.size} shapes, no row leaves out an earlier component` });
        } else {
          uniform++;
        }
      }
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'One site per constructor, located at its VALUE; the text names the first row that inherits and from which earlier row. Every later row that inherits is counted, not listed.',
      `Constructors whose rows all assign the same components are correct after the downport too and are not listed as negatives (${uniform} of them) - the negatives are the closer lookalike, rows of different shapes where no row leaves out what an earlier one set.`,
      `Constructors with FOR are not counted (${withFor} skipped): every iteration assigns the same component list, so they do not leak - unless one FOR carries several rows of different shapes, which this detector does not read.`,
      'Inside a loop the first row also inherits, from the previous pass\'s last row; that needs the control flow and is not detected, so the count is a lower bound.',
      "A shared prefix (`VALUE #( sign = 'I' ( low = 1 ) ( low = 2 ) )`) is assigned once before the rows and does not leak; it is not reported. A row that overrides a prefix component and a later row that does not is reported against the overriding row, which is right: the later row inherits the override, not the prefix.",
      'A component path `s-a` counts as covered by a later `s =` or the same `s-a =`; a later `s-b =` alone does not cover `s-a`, which is right too.',
      'String templates are blanked up to the next unescaped `|`; a template nested inside `{ }` of another template would confuse the parenthesis matching. None is expected in this corpus.',
      'Every site is correct ABAP on a 7.40+ system. It is wrong only after the abaplint downport - the 702 branches abap2UI5, samples and samples-controls publish, and the tree `npm run unit` transpiles.',
    ],
  };
}
