/*
 * Detector for `abaplint-subrc-after-assign`.
 *
 * Reports a `sy-subrc` test whose nearest preceding sy-subrc-setting statement
 * is a plain dynamic `ASSIGN`. The negatives are the same test after
 * `ASSIGN COMPONENT … OF STRUCTURE`, where `sy-subrc` distinguishes "component
 * not found" and IS the documented check — the scope the rule has to respect.
 */
import { lines, isComment, abapFiles } from '../../.github/scripts/lib/abap-scan.mjs';

export const describe =
  'a sy-subrc test whose nearest sy-subrc-setting statement is a plain ASSIGN, with ASSIGN COMPONENT as the negative';

const ASSIGN = /^\s*assign\b/i;
const ASSIGN_COMPONENT = /^\s*assign\s+component\b/i;
const SUBRC = /\bsy-subrc\b/i;

/* Statements that write sy-subrc and therefore end an ASSIGN's claim on it.
 * Deliberately short and deliberately over-broad: a statement missing here
 * makes the detector report MORE than the rule would, which is the direction
 * that gets caught by reading the list rather than the direction that hides a
 * finding. */
const SETS_SUBRC =
  /^\s*(read\s+table|select|loop\s+at|find|replace|call\s+function|call\s+method|delete|insert|modify|append|split|open\s+dataset|authority-check|import|export|describe|search|at\s+selection|get\s+parameter|set\s+parameter)\b/i;

export function run(roots) {
  const sites = [];
  const negatives = [];
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const src = lines(file);
      // 'plain' | 'component' | null — what last laid claim to sy-subrc
      let claim = null;
      src.forEach((line, i) => {
        if (isComment(line) || !line.trim()) return;
        if (ASSIGN.test(line)) { claim = ASSIGN_COMPONENT.test(line) ? 'component' : 'plain'; return; }
        if (SUBRC.test(line)) {
          if (claim) {
            const where = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
            (claim === 'plain' ? sites : negatives).push(where);
          }
          claim = null;
          return;
        }
        if (SETS_SUBRC.test(line)) claim = null;
      });
    }
  }
  return {
    sites,
    negatives,
    notes: [
      'The set of sy-subrc-writing statements above is hand-written and short. '
      + 'A statement missing from it lets an ASSIGN keep its claim too long, so '
      + 'the count is an upper bound — abaplint knows the real set (it models it '
      + 'for `check_subrc`) and would report fewer.',
      'Field-symbol assignment inside a macro or a chained statement is not '
      + 'followed.',
    ],
  };
}
