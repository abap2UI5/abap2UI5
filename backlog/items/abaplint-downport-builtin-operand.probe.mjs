/*
 * Detector for `abaplint-downport-builtin-operand`.
 *
 * It is the shipped gate, not a re-implementation: `check:downport` fails this
 * repository's own source on exactly this shape (#2664), and the detector both
 * of them use lives in `.github/scripts/lib/downport-operands.mjs`. A probe
 * that reported a different set would be arguing for a rule abap2UI5 does not
 * itself enforce.
 *
 * `sites` are the source lines a rule would have to report: a 7.02 built-in
 * function standing in a table-expression key, a `WITH [TABLE] KEY` operand or
 * an internal-table `WHERE` operand. All three are positions the downport
 * carries the call into verbatim, and none of them is a general expression
 * position before 7.40.
 *
 * `negatives` are the half that decides whether the rule can be written: a
 * functional METHOD call in the very same positions. Those parse as method
 * calls at 7.02 and are correct there - that reading is precisely what makes
 * the built-in fail - so a rule that reported them would be wrong on code that
 * has shipped for years. The counts say how far apart the two sets are.
 */
import { abapFiles, lines } from '../../.github/scripts/lib/abap-scan.mjs';
import { BUILTINS, CALL, stripNoise, positions } from '../../.github/scripts/lib/downport-operands.mjs';

export const describe =
  'a 7.02 built-in function in a table-expression key, a WITH KEY operand or an internal-table WHERE, with the functional method call in the same positions as the negative';

/* `name( ` that is not one of the built-ins: the method-call reading the rule
 * must leave alone. Excludes the control-flow keywords that are followed by a
 * parenthesis for a different reason. */
const NOT_A_BUILTIN = new Set([...BUILTINS, 'if', 'and', 'or', 'not', 'value', 'conv', 'cond', 'switch', 'ref', 'corresponding', 'reduce', 'filter', 'exact', 'cast', 'new']);
const ANY_CALL = /\b([a-z_][a-z_0-9]*(?:->|=>)?[a-z_0-9~]*)\s*\(/gi;

export function run(roots) {
  const sites = [];
  const negatives = [];
  const perRepo = {};

  for (const root of roots) {
    for (const file of abapFiles(root)) {
      // src/99 is frozen legacy in abap2UI5 and has no counterpart elsewhere;
      // the mirrors under src/00/01 and src/00/02 are upstream code. Same
      // scoping the gate uses - a finding there is nobody's to repair.
      if (/^src\/(99|00\/0[12])\//.test(file.rel)) continue;

      lines(file).forEach((raw, i) => {
        const code = stripNoise(raw);
        for (const pos of positions(code)) {
          const hit = CALL.exec(pos.text);
          if (hit) {
            perRepo[file.repo] = (perRepo[file.repo] || 0) + 1;
            sites.push({
              repo: file.repo,
              file: file.rel,
              line: i + 1,
              text: `[${pos.where}] ${raw.trim()}`,
            });
            continue;
          }
          for (const m of pos.text.matchAll(ANY_CALL)) {
            const name = m[1].toLowerCase();
            if (NOT_A_BUILTIN.has(name)) continue;
            negatives.push({
              repo: file.repo,
              file: file.rel,
              line: i + 1,
              text: `[${pos.where}, method call] ${raw.trim()}`,
            });
            break;
          }
        }
      });
    }
  }

  return {
    sites,
    negatives,
    notes: [
      'The detector IS the gate: both import '
      + '`.github/scripts/lib/downport-operands.mjs`, so a site here is a line '
      + '`npm run check:downport` would fail on, and the two cannot drift apart.',
      `Sites by repository: ${
        Object.keys(perRepo).length
          ? Object.entries(perRepo).map(([r, n]) => `${r} ${n}`).join(' · ')
          : 'none'
      }. abap2UI5 itself is expected to be at zero - the one site it had is the `
      + 'defect this item was written from, and it was repaired in the same change '
      + 'that added the gate.',
      'The positions are recognised line by line rather than statement by '
      + 'statement. A key or a WHERE operand split across lines still carries its '
      + '`= builtin( ` on one of them, so the count holds; a construct built by a '
      + 'macro is not followed.',
      'The negatives are approximated by "a call that is not one of the 39 '
      + 'built-ins": a constructor expression or a control-flow keyword in the '
      + 'same position is filtered out by name, but the set is hand-written, so '
      + 'read the count as an order of magnitude rather than an exact figure.',
      'abaplint knows all of this properly - it models the release levels and it '
      + 'owns the downport rewrite that introduces the construct. The right fix is '
      + 'in the downport itself (hoist the call into a variable, which IS an '
      + 'expression position at 7.02), not in a source-shape rule; this probe '
      + 'measures how often the rewrite would have to do it.',
    ],
  };
}
