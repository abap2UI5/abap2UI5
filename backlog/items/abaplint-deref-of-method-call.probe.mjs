/*
 * Detector for `abaplint-deref-of-method-call`: a `)` directly in front of
 * `->*` (a functional call or constructor expression dereferenced inline),
 * with the reference-variable dereference as the negative. Same test as
 * abap2UI5's check:atc `deref_call`.
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = '`)->*` — a call or constructor expression dereferenced inline, with `var->*` as the negative';

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      lines(file).forEach((line, i) => {
        if (isComment(line)) return;
        const code = line.replace(/`[^`]*`|'[^']*'|\|[^|]*\|/g, '``');
        if (!/->\*/.test(code)) return;
        const hit = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
        (/\)\s*->\*/.test(code) ? sites : negatives).push(hit);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Every ordinary `ref->*` on a line counts as one negative; the negatives show how common the legal form is next to the reported one.',
      'The #2722 site was repaired, so the current tree is expected to answer 0.',
    ],
  };
}
