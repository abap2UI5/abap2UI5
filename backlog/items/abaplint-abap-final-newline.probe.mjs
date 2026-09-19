/*
 * Detector for `abaplint-abap-final-newline`: a source file whose content
 * does not end with exactly one `\n`; a file ending correctly is the
 * negative (counted once per repository, not per file).
 */
import { abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe = 'a file not ending with exactly one newline, with the correctly terminated files counted per repository';

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    let ok = 0;
    for (const file of abapFiles(root)) {
      const t = file.text;
      if (!t.length) continue;
      if (t.endsWith('\n') && !t.endsWith('\n\n')) { ok++; continue; }
      sites.push({ repo: file.repo, file: file.rel, line: t.split('\n').length, text: t.endsWith('\n') ? 'blank line after the last statement' : 'no newline at end of file' });
    }
    negatives.push({ repo: root.repo, file: '(all .abap files)', line: 0, text: `${ok} files end with exactly one newline` });
  }
  return {
    sites,
    negatives,
    notes: [
      'Only .abap files are read; the XML sidecars the rule would cover too are out of this scan\'s reach.',
      'Repositories gated by abapgit-format-gate.mjs answer 0 by construction - the number says the gate works, not that the rule is unneeded elsewhere.',
    ],
  };
}
