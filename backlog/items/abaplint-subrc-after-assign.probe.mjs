/*
 * Detector for `abaplint-subrc-after-assign`.
 *
 * Reports a `sy-subrc` test whose nearest preceding sy-subrc-setting statement
 * is a plain dynamic `ASSIGN`. The negatives are the same test after
 * `ASSIGN COMPONENT … OF STRUCTURE`, where `sy-subrc` distinguishes "component
 * not found" and IS the documented check — the scope the rule has to respect.
 *
 * Each site also carries WHICH FIX APPLIES, because they are not the same fix
 * and the difference decides whether the rule can be auto-fixed at all:
 *
 *   simple      the field symbol is freshly declared in this method and this
 *               is its only ASSIGN — `IS [NOT] ASSIGNED` is a drop-in
 *   in-loop     the ASSIGN sits inside LOOP / DO / WHILE, so a FAILED assign
 *               leaves the binding from the previous iteration in place and
 *               `IS ASSIGNED` reads TRUE for a failure. Needs `UNASSIGN`
 *               first — verified against `@abaplint/runtime`'s assign, which
 *               sets sy-subrc = 4 and returns WITHOUT clearing the target
 *   reassigned  the same field symbol was already assigned earlier in the
 *               method; same trap, same fix
 *
 * Getting this wrong is how a "cleanup" turns a wrong-branch bug into a
 * silently-taken one, so a rule that blanket-suggests `IS ASSIGNED` would be
 * worse than no rule.
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

const TARGET = /\bTO\s+(?:FIELD-SYMBOL\()?(<[a-z_0-9]+>)/i;
let lastKind = 'simple';

export function run(roots) {
  const sites = [];
  const negatives = [];
  const counts = { simple: 0, 'in-loop': 0, reassigned: 0 };
  for (const root of roots) {
    for (const file of abapFiles(root)) {
      const src = lines(file);
      let claim = null;
      let depth = 0;
      let assignedHere = new Set();
      let lastTarget = null;
      src.forEach((line, i) => {
        if (isComment(line) || !line.trim()) return;
        if (/^\s*METHOD\s/i.test(line)) { assignedHere = new Set(); depth = 0; }
        if (/^\s*(loop\s+at|do\b|while\b)/i.test(line)) depth += 1;
        else if (/^\s*(endloop|enddo|endwhile)\b/i.test(line)) depth = Math.max(0, depth - 1);

        if (ASSIGN.test(line)) {
          claim = ASSIGN_COMPONENT.test(line) ? 'component' : 'plain';
          const t = TARGET.exec(line);
          lastTarget = t ? t[1].toLowerCase() : null;
          if (claim === 'plain' && lastTarget) {
            const kind = depth > 0 ? 'in-loop' : (assignedHere.has(lastTarget) ? 'reassigned' : 'simple');
            assignedHere.add(lastTarget);
            lastKind = kind;
          }
          return;
        }
        if (SUBRC.test(line)) {
          if (claim) {
            const where = { repo: file.repo, file: file.rel, line: i + 1, text: line.trim() };
            if (claim === 'plain') {
              where.text = `[${lastKind}] ${where.text}`;
              counts[lastKind] += 1;
              sites.push(where);
            } else negatives.push(where);
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
      `Which fix applies: ${counts.simple} simple · ${counts['in-loop']} in a loop `
      + `· ${counts.reassigned} re-assigned. Only the first is a drop-in; the other `
      + 'two need `UNASSIGN` before the `ASSIGN`, because a failed assign leaves '
      + 'the previous binding in place and `IS ASSIGNED` then reads TRUE for a '
      + 'failure. Verified against `@abaplint/runtime`\'s assign, which sets '
      + 'sy-subrc = 4 and returns without clearing the target.',
      'The set of sy-subrc-writing statements is hand-written and short. A '
      + 'statement missing from it lets an ASSIGN keep its claim too long, so '
      + 'the count is an upper bound — abaplint knows the real set (it models it '
      + 'for `check_subrc`) and would report fewer.',
      'Field-symbol assignment inside a macro or a chained statement is not '
      + 'followed.',
    ],
  };
}
