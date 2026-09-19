/*
 * Detector for `abaplint-into-corresponding-inline-decl`:
 * `INTO|APPENDING CORRESPONDING FIELDS OF [TABLE] @DATA( )`, with the
 * plain `INTO TABLE @DATA( )` and the declared-target CORRESPONDING form as
 * the negatives.
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'CORRESPONDING FIELDS OF … @DATA( ) in a SELECT, with INTO TABLE @DATA( ) and a declared target as the negatives';

const stripComments = (text) => text.split(/\r?\n/).map((l) => (/^\s*[*"]/.test(l) ? '' : l.replace(/"[^`']*$/, ''))).join('\n');

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const text = stripComments(file.text);
      for (const m of text.matchAll(/\b(?:INTO|APPENDING)\s+(?:CORRESPONDING\s+FIELDS\s+OF\s+)?(?:TABLE\s+)?@(DATA\s*\(|\w+)/gi)) {
        const line = text.slice(0, m.index).split('\n').length;
        const hit = { repo: file.repo, file: file.rel, line, text: text.split('\n')[line - 1].trim() };
        const corresponding = /CORRESPONDING/i.test(m[0]);
        const inline = /^DATA/i.test(m[1]);
        if (corresponding && inline) sites.push(hit);
        else if (corresponding || inline) negatives.push(hit);
      }
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'Statement-level, so a SELECT spread over lines is read. Open SQL only by construction of the `@` host prefix; the samples-348 shape was exactly this.',
      'The negatives are the two neighbouring legal spellings: an inline declaration without CORRESPONDING, and CORRESPONDING into a declared table.',
    ],
  };
}
