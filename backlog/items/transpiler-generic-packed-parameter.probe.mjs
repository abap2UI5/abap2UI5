/*
 * Detector for `transpiler-generic-packed-parameter`: a method parameter
 * typed with the generic `TYPE p` (no LENGTH, no DECIMALS). @abaplint/transpiler
 * has no branch for abaplint's PGenericType, so every place it declares the
 * parameter - a CHANGING or optional parameter's default, an EXPORTING
 * parameter nobody receives, the METHODS metadata RTTI reads - becomes
 * `new abap.types.typeTodoPGenericType()`, which is no constructor. The
 * negatives are the shapes that look the same and transpile: a FORM
 * parameter `TYPE p` (the FORM transpiler declares nothing) and a method
 * parameter `TYPE numeric` (mapped to a packed fallback).
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'a METHODS / CLASS-METHODS parameter typed `TYPE p` without LENGTH or DECIMALS - the transpiler emits `typeTodoPGenericType`; FORM parameters `TYPE p` and method parameters `TYPE numeric` as the negative';

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

/* The statements of a file, as `{text, start}` - split at the periods that
 * end a statement (code only, so a period in a literal does not count). */
function statements(code) {
  const out = [];
  let from = 0;
  for (let k = 0; k < code.length; k++) {
    if (code[k] === '.' && (k + 1 === code.length || /\s/.test(code[k + 1]))) {
      out.push({ text: code.slice(from, k), start: from });
      from = k + 1;
    }
  }
  return out;
}

export function run(roots) {
  const sites = [];
  const negatives = [];
  let numericParams = 0;
  let pForms = 0;
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const code = codeOnly(file.text);
      const lineOf = (off) => code.slice(0, off).split('\n').length;
      for (const st of statements(code)) {
        const head = /^\s*(CLASS-METHODS|METHODS|FORM)\b/i.exec(st.text);
        if (!head) continue;
        const kind = head[1].toUpperCase();
        /* `iv TYPE p DECIMALS 2` is concrete; `iv TYPE p` followed by a parameter
         * that happens to be called `decimals` (`decimals TYPE i`) is not */
        const re = /\bTYPE\s+(p|numeric)\b(?!\s+(LENGTH|DECIMALS)\s+(?!(TYPE|LIKE)\b)\S)/gi;
        let m;
        while ((m = re.exec(st.text))) {
          const at = { repo: file.repo, file: file.rel, line: lineOf(st.start + m.index) };
          const type = m[1].toLowerCase();
          if (type === 'p' && kind !== 'FORM') {
            sites.push({ ...at, text: `${kind} parameter TYPE p - declared as typeTodoPGenericType` });
          } else if (type === 'p') {
            pForms++;
            negatives.push({ ...at, text: 'FORM parameter TYPE p - the FORM transpiler declares nothing, transpiled correctly' });
          } else if (kind !== 'FORM') {
            numericParams++;
            negatives.push({ ...at, text: `${kind} parameter TYPE numeric - the transpiler falls back to Packed({length: 8, decimals: 2}), transpiled correctly` });
          }
        }
      }
    }
  }
  return {
    sites,
    negatives,
    notes: [
      `Only parameters are counted: \`DATA\`, \`FIELD-SYMBOLS\` and \`STATICS\` with \`TYPE p\` are not generic (abaplint gives them p LENGTH 8 DECIMALS 0) and transpile correctly. ${numericParams} method parameter(s) \`TYPE numeric\` and ${pForms} FORM parameter(s) \`TYPE p\` found.`,
      'An IMPORTING parameter without OPTIONAL and DEFAULT, by reference or VALUE( ), is the one shape that survives a call (the transpiler takes the actual as it is) - but the METHODS metadata still holds the typeTodo, so RTTI on the class fails. Every site counts.',
      'EVENTS parameters `TYPE p` would hit the same branch and are not counted; none is expected in this corpus.',
    ],
  };
}
