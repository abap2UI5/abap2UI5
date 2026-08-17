/*
 * Detector for `abaplint-abapdoc-block-placement`.
 *
 * Reports a `"!` block whose next non-blank line is a chain KEYWORD
 * (`CONSTANTS:`, `DATA:`, `TYPES:`, `METHODS:`) or a section/class end — in
 * both cases the block documents nothing. The negative is the same block one
 * line further down, inside the chain, where it documents the member.
 */
import { lines, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe =
  'an ABAP Doc block whose next statement is a chain keyword or a section end, with the correct in-chain placement as the negative';

const DOC = /^\s*"!/;
const CHAIN_KEYWORD = /^\s*(constants|data|types|methods|class-methods|class-data|events)\s*:\s*$/i;
const NOTHING_TO_DOCUMENT =
  /^\s*(endclass|endinterface|public\s+section|protected\s+section|private\s+section)\b/i;
// inside a chain: a member line, i.e. not itself a chain opener
const IN_CHAIN = /^\s*(begin\s+of|[a-z_][a-z_0-9]*\s)/i;

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      if (!/\.(clas|intf)\.abap$/.test(file.rel)) continue;
      const src = lines(file);
      src.forEach((line, i) => {
        if (!DOC.test(line)) return;
        // the last line of this doc block only
        if (DOC.test(src[i + 1] || '')) return;
        let j = i + 1;
        while (j < src.length && !src[j].trim()) j += 1;
        const next = src[j] || '';
        const where = { repo: file.repo, file: file.rel, line: i + 1, text: `→ ${next.trim().slice(0, 60)}` };
        if (CHAIN_KEYWORD.test(next) || NOTHING_TO_DOCUMENT.test(next)) sites.push(where);
        else if (IN_CHAIN.test(next)) negatives.push(where);
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Only `.clas.abap` and `.intf.abap` are read — ABAP Doc on a report or '
      + 'function group is not counted.',
      'The negative count is every correctly placed block, so it is large by '
      + 'design: the point it makes is that the two placements are distinguishable '
      + 'by the next statement alone, which is what the rule needs.',
      'A `"!` block before a parameter inside a METHODS chain is not separated '
      + 'out here; the rule should report it and this detector counts it as a '
      + 'negative.',
    ],
  };
}
