/*
 * Detector for `transpiler-value-let-without-for`: a constructor expression
 * with a LET that @abaplint/transpiler drops - a VALUE without FOR, or a
 * CONV. The negatives are the LETs it transpiles correctly: VALUE with FOR,
 * COND, SWITCH and REDUCE. Matters only where 7.40 source is transpiled
 * directly; abap2UI5's unit run transpiles the downport output, where the
 * abaplint downport has already outlined the LET.
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'a VALUE without FOR, or a CONV, that binds a LET - the transpiler never declares the binding; the LETs in VALUE with FOR, COND, SWITCH and REDUCE as the negative';

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

export function run(roots) {
  const sites = [];
  const negatives = [];
  let lets = 0;
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const code = codeOnly(file.text);
      const lineOf = (off) => code.slice(0, off).split('\n').length;
      const re = /\b(VALUE|CONV|COND|SWITCH|REDUCE|NEW|EXACT|CORRESPONDING)\s+(#|[A-Za-z_][\w/=>~-]*)\(/gi;
      let m;
      while ((m = re.exec(code))) {
        const open = m.index + m[0].length - 1;
        const close = closing(code, open);
        if (close < 0) continue;
        const kids = children(code, open + 1, close);
        if (!(kids[0] && kids[0].kind === 'word' && kids[0].text === 'LET')) continue;
        lets++;
        const op = m[1].toUpperCase();
        const hasFor = kids.some((k) => k.kind === 'word' && k.text === 'FOR');
        const at = { repo: file.repo, file: file.rel, line: lineOf(m.index) };
        if ((op === 'VALUE' && !hasFor) || op === 'CONV') {
          sites.push({ ...at, text: `${op} with LET${op === 'VALUE' ? ' and no FOR' : ''} - the binding is never declared` });
        } else {
          negatives.push({ ...at, text: `${op} with LET${hasFor ? ' and FOR' : ''} - transpiled correctly` });
        }
      }
    }
  }
  return {
    sites,
    negatives,
    notes: [
      `A LET is counted where it opens the constructor body (${lets} found); a LET inside a FOR (\`FOR … LET … IN\`) is a different code path and not counted.`,
      'NEW, EXACT and CORRESPONDING with LET were not measured against the transpiler; any found would be listed as negatives, and none is expected in this corpus.',
      'Every site is correct ABAP on a 7.40+ system and transpiles correctly after the abaplint downport - it fails only where 7.40 source is transpiled directly, at runtime, with `ReferenceError`.',
    ],
  };
}
