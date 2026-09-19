/*
 * Detector for `abaplint-ref-into-generic-target`.
 *
 * A `<fs> = REF #( … )` / `x = REF #( … )` whose target is declared with a
 * generic type in the same file (FIELD-SYMBOLS … TYPE any/data/…, a generic
 * parameter, or a field symbol declared inline by an ASSIGN of a `->*`), with
 * the typed target as the negative.
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'REF #( ) assigned to a generically typed target, with the typed target as the negative';

const GENERIC = /\bTYPE\s+(?:any|data|simple|clike|csequence|numeric|xsequence|c|n|x|p|decfloat|any\s+table|index\s+table|standard\s+table|sorted\s+table|hashed\s+table|table)\s*[,.]/i;

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const generic = new Set();
      const ls = lines(file);
      ls.forEach((line) => {
        if (isComment(line)) return;
        const fs = /\bFIELD-SYMBOLS?\s*:?\s*(<\w+>)\s+(.*)$/i.exec(line);
        if (fs && GENERIC.test(fs[2] + '.')) generic.add(fs[1].toLowerCase());
        const par = /\b(?:IMPORTING|EXPORTING|CHANGING)?\s*(\w+)\s+TYPE\s+(?:any|data|simple|clike|csequence)\b/i.exec(line);
        if (par && /\bMETHODS?\b|^\s+\w+\s+TYPE\s+(?:any|data)\b/i.test(line)) generic.add(par[1].toLowerCase());
        const inl = /\bASSIGN\b[^.]*->\*\s+TO\s+FIELD-SYMBOL\((<\w+>)\)/i.exec(line);
        if (inl) generic.add(inl[1].toLowerCase());
      });
      ls.forEach((line, i) => {
        if (isComment(line)) return;
        const m = /^\s*(<\w+>|\w+(?:->\w+)?)\s*=\s*REF\s+#\s*\(/i.exec(line);
        if (!m) return;
        const hit = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
        (generic.has(m[1].toLowerCase()) ? sites : negatives).push(hit);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Generic parameters are read only where the declaration keeps name and TYPE on one line; a multi-line METHODS signature is missed, so the count is a floor.',
      'A field symbol assigned by a dynamic ASSIGN of a typed reference is treated as typed - the rule would ask the reference type, this cannot.',
      'The two sites of 2026-09 were repaired as REF data( ) the same day, so the current tree is expected to answer 0 - the negatives show the rule can tell a typed target apart.',
    ],
  };
}
