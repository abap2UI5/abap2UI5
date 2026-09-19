/*
 * Detector for `abaplint-empty-catch-block`: a CATCH/CLEANUP statement
 * followed (comments and blank lines aside) by CATCH, CLEANUP or ENDTRY,
 * without ##NO_HANDLER; the pragma-carrying empty handler is the negative.
 */
import { lines, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'an empty CATCH block without ##NO_HANDLER, with the pragma-carrying one as the negative';

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const ls = lines(file);
      ls.forEach((line, i) => {
        if (!/^\s*(?:CATCH|CLEANUP)\b/i.test(line)) return;
        let j = i + 1;
        while (j < ls.length && /^\s*(?:"|\*|$)/.test(ls[j])) j++;
        if (!/^\s*(?:CATCH|CLEANUP|ENDTRY)\b/i.test(ls[j] || '')) return;
        const hit = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
        (/##NO_HANDLER/i.test(line) ? negatives : sites).push(hit);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Line-based; a CATCH statement continued on the next line (a long exception list) is judged on its first line, which can miss a pragma written at the end.',
      'In abap2UI5 every site is in the vendored ajson test classes - the code the app-class linter does not read, which is the argument for the upstream rule.',
    ],
  };
}
