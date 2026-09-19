/*
 * Detector for `abaplint-get-reference-obsolete`: every `GET REFERENCE OF`
 * statement, with `= REF #( )` / `REF data( )` as the negative (the released
 * spelling of the same thing).
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'GET REFERENCE OF, with the REF constructor as the negative';

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      lines(file).forEach((line, i) => {
        if (isComment(line)) return;
        const hit = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
        if (/\bGET\s+REFERENCE\s+OF\b/i.test(line)) sites.push(hit);
        else if (/=\s*REF\s+(?:#|\w+)\s*\(/i.test(line)) negatives.push(hit);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'The rule is only about the Cloud language version; the count says how much a repository would have to rewrite to pass it, not that anything is wrong on-premise.',
      'abap2UI5 keeps its remaining sites in vendored mirrors (src/00) and the frozen package (src/99) on purpose - those follow their upstreams.',
    ],
  };
}
