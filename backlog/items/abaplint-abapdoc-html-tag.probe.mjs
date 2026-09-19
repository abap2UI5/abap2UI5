/*
 * Detector for `abaplint-abapdoc-html-tag`: a complete tag-like token in a
 * `"!` line whose name is not one of the ABAP Doc markup tags; those tags
 * are the negatives. Same test as abap2UI5's check:atc `abapdoc_html`.
 */
import { lines, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'an unsupported tag-like token in ABAP Doc, with the ABAP Doc markup tags as the negatives';

const MARKUP = /^(?:p|em|strong|ul|ol|li|br|h[1-3])$/i;

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      lines(file).forEach((line, i) => {
        if (!/^\s*"!/.test(line)) return;
        for (const m of line.matchAll(/<\/?([A-Za-z][\w-]*)(?:\s[^<>]*)?\/?>/g)) {
          const hit = { repo: file.repo, file: file.rel, line: i + 1, text: m[0] };
          (MARKUP.test(m[1]) ? negatives : sites).push(hit);
        }
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'The #2705 sites were repaired when the gate shipped, so abap2UI5 is expected to answer 0; the negatives count the markup the rule must leave alone.',
    ],
  };
}
