/*
 * Detector for `abaplint-default-key-implicit`: `TYPE [STANDARD] TABLE OF x`
 * with no WITH … KEY clause in the same declaration element, with the
 * explicit `WITH DEFAULT KEY` (what obsolete_statement already reports) as
 * the negative.
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'an implicit default-key table declaration, with the explicit WITH DEFAULT KEY as the negative';

const stripComments = (text) => text.split(/\r?\n/).map((l) => (/^\s*[*"]/.test(l) ? '' : l.replace(/"[^`']*$/, ''))).join('\n');

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const text = stripComments(file.text);
      for (const m of text.matchAll(/\bTYPE\s+(?:STANDARD\s+)?TABLE\s+OF\s+([^,.]*)[,.]/gi)) {
        const line = text.slice(0, m.index).split('\n').length;
        const hit = { repo: file.repo, file: file.rel, line, text: text.split('\n')[line - 1].trim() };
        if (/\bWITH\s+DEFAULT\s+KEY\b/i.test(m[1])) negatives.push(hit);
        else if (!/\bWITH\b/i.test(m[1])) sites.push(hit);
      }
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Declaration-element level (a chained DATA: is split on its commas by the terminator match), so a multi-line element is read.',
      'RANGE OF and TABLE FOR are not matched by construction; a `LIKE` declaration is not either.',
    ],
  };
}
