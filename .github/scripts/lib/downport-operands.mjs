/*
 * downport-operands — where a 7.02 built-in function may not stand.
 *
 * Two callers, one definition: `check:downport` fails this repository's own
 * source on it (.github/scripts/downport-operand-gate.mjs, #2664), and the
 * `abaplint-downport-builtin-operand` backlog probe measures the same shape
 * across the four sibling checkouts to say how much a rule would report. A
 * detector that disagreed with the gate would be arguing for a rule this
 * repository does not itself enforce, so there is one of it.
 *
 * The reasoning - why these built-ins and not the pre-7.02 ones, why a
 * functional method call in the same position is NOT a finding, why the
 * positions are line-scoped - lives in the gate's header, next to the rule
 * it decides.
 */
/* The built-in functions release 7.02 introduced - the ones whose name is only
 * read as a function where a string expression is allowed, and as a method
 * call everywhere else. The numeric built-ins that predate 7.02 (`abs`,
 * `sign`, `strlen`, `lines`, `numofchar`, `charlen`) are deliberately absent:
 * see the header. */
export const BUILTINS = [
  "boolc", "boolx", "xsdbool",
  "char_off", "cmax", "cmin", "concat_lines_of", "condense",
  "contains", "contains_any_of", "contains_any_not_of",
  "count", "count_any_of", "count_any_not_of",
  "distance", "escape",
  "find", "find_any_of", "find_any_not_of", "find_end",
  "from_mixed", "insert", "match", "matches",
  "repeat", "replace", "reverse", "segment",
  "shift_left", "shift_right",
  "substring", "substring_after", "substring_before", "substring_from", "substring_to",
  "to_lower", "to_mixed", "to_upper", "translate",
];

export const CALL = new RegExp(`\\b(${BUILTINS.join("|")})\\s*\\(`, "i");

/* Comments and string literals never hold an operand position, and both are
 * full of words that would otherwise match.
 *
 * Re-exported from the statement lexer rather than written here: this file
 * carried its own loop, and that loop knew `'` and backtick and not `|`, so a
 * `"` inside a string template ended the scan and everything after it on the
 * line - the table-expression key, the WITH KEY operand, the WHERE - went
 * unchecked. The lexer is the module that already gets `|...|` right, escapes
 * and embedded `{ }` included. */
export { stripNoise } from "./abap-statements.mjs";

/* The three positions, each as the slice of the line that IS the position.
 * Line-scoped on purpose: a key or a WHERE operand split across lines still
 * gets its `= builtin( ` on one of them, and a whole-statement parse would buy
 * nothing but a way to disagree with the reader about where the finding is. */
export function positions(code) {
  const found = [];

  // 1. a table expression: everything between `[` and its `]`. Nested
  //    brackets do not occur in this corpus; an unclosed one takes the rest
  //    of the line, which is the safe direction for a check.
  for (const m of code.matchAll(/\[([^\]]*)\]/g)) {
    if (m[1].includes("=")) found.push({ where: "table expression key", text: m[1] });
  }

  // 2. WITH KEY / WITH TABLE KEY, to the end of the statement fragment.
  const key = /\bWITH\s+(?:TABLE\s+)?KEY\b(.*)$/i.exec(code);
  if (key) found.push({ where: "WITH KEY operand", text: key[1] });

  // 3. the WHERE condition of an internal-table statement. LOOP AT / DELETE /
  //    MODIFY only - an ABAP SQL WHERE is a different position with different
  //    rules, and this gate has no evidence about it.
  //
  //    The ABAP SQL half is excluded by the ONE spelling that carries it into
  //    a WHERE: `DELETE FROM <dbtab> WHERE …`. This used to be a blanket
  //    "no FROM anywhere on the line", which excluded the two internal-table
  //    shapes that legitimately have one and left the position unchecked:
  //    `MODIFY <itab> FROM <wa> TRANSPORTING … WHERE …` - the ONLY itab MODIFY
  //    that takes a WHERE at all, so that alternative could never match - and
  //    `LOOP AT <itab> FROM <idx> WHERE …`. Open SQL MODIFY has no WHERE clause
  //    and Open SQL DELETE only reaches one through `DELETE FROM`, so the
  //    narrow exclusion loses nothing and buys back both shapes.
  const where = /^\s*(?:LOOP\s+AT|DELETE(?!\s+FROM\b)|MODIFY)\b[^"]*?\bWHERE\b(.*)$/i.exec(code);
  if (where) found.push({ where: "internal-table WHERE operand", text: where[1] });

  return found;
}

