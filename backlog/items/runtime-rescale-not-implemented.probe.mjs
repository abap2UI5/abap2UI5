/*
 * Detector for `runtime-rescale-not-implemented`: a call of the built-in
 * function `rescale( )`, which @abaplint/runtime does not have - the
 * transpiled call is `abap.builtin.rescale(...)`, `TypeError: ... is not a
 * function` when it runs. The negatives are the `round( )` calls next to it,
 * which the runtime implements with every argument since 2.13.94.
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'a call of `rescale( )` - no builtin in @abaplint/runtime; the `round( val = … )` calls as the negative, implemented with dec, prec and mode since 2.13.94';

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
  return code.length - 1;
}

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const code = codeOnly(file.text);
      const lineOf = (off) => code.slice(0, off).split('\n').length;
      const re = /(^|[^\w>~-])(rescale|round)\(\s*val\b/gi;
      let m;
      while ((m = re.exec(code))) {
        const at = { repo: file.repo, file: file.rel, line: lineOf(m.index + m[1].length) };
        if (m[2].toLowerCase() === 'rescale') {
          sites.push({ ...at, text: 'rescale( ) - abap.builtin.rescale is not a function' });
        } else {
          const open = code.indexOf('(', m.index + m[1].length);
          /* the direct arguments only - a nested call's own `dec =` is not this one's */
          let depth = 0;
          const args = code.slice(open + 1, closing(code, open)).split('').filter((c) => {
            if (c === '(') depth++;
            else if (c === ')') { depth--; return false; }
            return depth === 0;
          }).join('');
          const named = ['dec', 'prec', 'mode'].filter((a) => new RegExp(`\\b${a}\\s*=`, 'i').test(args));
          negatives.push({ ...at, text: `round( ${named.length ? named.join(', ') : 'val only'} ) - implemented` });
        }
      }
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'A call is recognised by its `val =` argument, which both functions require; a method of the same name (`lo->round( … )`) is not counted.',
      'The round( ) negatives work on @abaplint/runtime 2.13.94 and later only; up to 2.13.93 any `dec` other than 0 threw `round(), todo, handle decimals`, which is what the MCP server\'s backend (transpiler-cli 2.13.93) still ships.',
    ],
  };
}
