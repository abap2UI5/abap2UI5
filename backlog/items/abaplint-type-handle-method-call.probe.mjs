/*
 * Detector for `abaplint-type-handle-method-call`: a `TYPE HANDLE` operand
 * containing a `(` (a method call or constructor expression), with the plain
 * data-object operand as the negative. Same test as abap2UI5's check:atc
 * `handle_call`.
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'a CREATE DATA/OBJECT … TYPE HANDLE operand that is a call, with the plain variable operand as the negative';

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      lines(file).forEach((line, i) => {
        if (isComment(line)) return;
        const m = /\bTYPE\s+HANDLE\s+([^.]*)\./i.exec(line);
        if (!m) return;
        const hit = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
        (m[1].includes('(') ? sites : negatives).push(hit);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Line-based: a statement whose operand continues on the next line is not read. The one incident was on one line.',
      'The 2026-09-02 site was repaired the same day, so the current tree is expected to answer 0.',
    ],
  };
}
