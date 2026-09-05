// Gate: a 7.02 built-in function may not stand in an operand position that
// only becomes a general expression position at 7.40.
//
// The case that produced this gate, #2664. The source said
//
//   IF NOT line_exists( mt_names[ table_line = to_upper( is_node-name ) ] ).
//
// which is valid ABAP on the v750 target, lints green here, transpiles green,
// and downports - abaplint rewrites `line_exists( tab[ k = x ] )` into
//
//   READ TABLE mt_names WITH KEY table_line = to_upper( is_node-name ) …
//
// carrying the call over verbatim. On a real 7.02/7.31 system that line does
// not compile. `to_upper( )` is one of the built-in functions release 7.02
// added, and a built-in function is only recognised where a string expression
// is allowed; the `WITH KEY comp = …` operand does not become a general
// expression position until 7.40. So the compiler falls back to the only other
// reading of `name( … )` it has - a functional METHOD call - and reports
// "method TO_UPPER is unknown", as a SYNTAX_ERROR of the whole class pool.
// Every app on the system was down, from one filter method nothing calls
// unless `_bind( omit_initial_paths )` is used.
//
// Why a gate and not prose, and not a lint rule:
//
//   - abaplint is right about `src/`. The construct IS valid at v750, so no
//     rule of the standard config has anything to say about it, and the
//     downport rule that rewrote it is the thing that introduced the defect.
//   - the 702 lint (`ABAP_702.yaml`) runs over the downported branch and
//     passed anyway - abaplint does not model which operand positions accept a
//     built-in function at which release.
//   - the transpiler and the unit suite run the v750 source, where it works.
//
// So all four checks this repository has were green on a class that could not
// be activated. The only thing that could have caught it before a user's
// system did is a rule about the SOURCE shape, which is what this is.
//
// What it reports: a built-in function call inside a table-expression key, a
// WITH [TABLE] KEY operand, or an internal-table WHERE operand. Hoist the call
// into a variable on the line above - a plain assignment IS an expression
// position at 7.02, so the variable is the entire fix.
//
// What it deliberately does NOT report:
//
//   - a functional METHOD call (`client->get_event_arg( 1 )`) in the same
//     positions. Those parse as method calls at 7.02 and are accepted; that
//     reading is exactly what makes the built-in fail, and `src/99` has such a
//     line that has shipped for years.
//   - `lines( )`, `strlen( )` and the other pre-7.02 built-ins. The class in
//     #2664 also downported to `READ TABLE … INDEX lines( lt_parts )`, ten
//     lines above the failure, and the compiler had no complaint about it -
//     the dump named the `to_upper( )` line and nothing else.
//
// Scope: this repository's own ABAP. `src/00/01` (AJSON) and `src/00/02`
// (S-RTTI) are upstream mirrors, `src/99` is the frozen legacy package - a
// finding in any of the three is not ours to repair, the same scoping
// `check:atc` and `check:asserts` use.
//
// Run: node .github/scripts/downport-operand-gate.mjs   (npm run check:downport)

import { fileURLToPath } from "url";
import { readFileSync } from "node:fs";
import { walk } from "./lib/walk.mjs";
// The detector itself is in lib/ because the backlog probe for the upstream
// rule proposal measures the SAME shape across the sibling checkouts - a
// probe that disagreed with this gate would be arguing for a rule this
// repository does not enforce.
import { BUILTINS, CALL, stripNoise, positions } from "./lib/downport-operands.mjs";

const ROOT = fileURLToPath(new URL("../../", import.meta.url));

/* Self-test: the three positions, on statements written for them, before the
 * tree is scanned. This gate is green over `src/` either way - the one site it
 * ever had was repaired in the change that added it - so a position that stops
 * matching costs nothing visible and is noticed by nobody. That is not
 * hypothetical: the internal-table WHERE excluded any line carrying a `FROM`,
 * which silently covered `MODIFY <itab> FROM <wa> … WHERE` (the only itab
 * MODIFY that HAS a WHERE, so the alternative could never fire) and
 * `LOOP AT <itab> FROM <idx> WHERE`. `null` means "no position on this line".
 */
const SELF_TEST = [
  // the #2664 line itself
  ["IF NOT line_exists( mt_names[ table_line = to_upper( is_node-name ) ] ).", "table expression key"],
  ["READ TABLE lt_parts WITH KEY name = to_upper( iv_name ) INTO DATA(ls_part).", "WITH KEY operand"],
  ["DELETE lt_param WHERE n = to_lower( iv_name ).", "internal-table WHERE operand"],
  // the two shapes the blanket FROM exclusion used to swallow
  ["MODIFY lt_rows FROM ls_row TRANSPORTING val WHERE name = to_upper( iv_name ).", "internal-table WHERE operand"],
  ["LOOP AT lt_rows FROM lv_idx INTO DATA(ls) WHERE name = to_upper( iv_name ).", "internal-table WHERE operand"],
  // ABAP SQL is a different position with different rules - not this gate's
  ["DELETE FROM z2ui5_t_01 WHERE id = @( to_upper( lv_id ) ).", null],
  // a functional METHOD call in the same position is correct at 7.02
  ["LOOP AT lt_rows INTO DATA(ls_row) WHERE name = lo_app->get_name( ).", null],
  // a built-in outside any of the three positions
  ["DATA(lv_name) = to_upper( is_node-name ).", null],
  /* A `"` inside a `|...|` string template is TEXT, not the start of a
   * comment. The line scan used to stop there, so the operand position after
   * it was never looked at and the finding was silently lost - the bug class
   * lib/abap-statements.mjs was written to end, in the one caller that still
   * had its own loop. */
  [`READ TABLE lt_x WITH KEY msg = |say "hi"| name = to_upper( iv_name ) INTO ls_x.`, "WITH KEY operand"],
  [`LOOP AT lt_rows INTO DATA(ls) WHERE text = |a "b" c| AND name = to_upper( iv_name ).`, "internal-table WHERE operand"],
  // the template's own text is a literal and holds no operand position
  ["DATA(lv) = |x[ name = to_upper( a ) ]|.", null],
  // an embedded expression inside a template IS code and is still scanned
  [`READ TABLE lt_x WITH KEY name = |{ to_upper( iv_name ) }| INTO ls_x.`, "WITH KEY operand"],
];

for (const [line, expected] of SELF_TEST) {
  const code = stripNoise(line);
  const hit = positions(code).find((pos) => CALL.test(pos.text));
  const got = hit ? hit.where : null;
  if (got !== expected) {
    console.error("downport-operand: the gate's own self-test failed");
    console.error(`  ${line}`);
    console.error(`  expected: ${expected ?? "no finding"}`);
    console.error(`  got:      ${got ?? "no finding"}`);
    console.error("");
    console.error("The position patterns changed. A green run over src/ proves nothing while");
    console.error("this case fails - src/ carries no such site, so nothing else would notice.");
    process.exit(1);
  }
}

const EXCLUDED = [/^src\/99\//, /^src\/00\/01\//, /^src\/00\/02\//];

const files = walk(ROOT, "src")
  .filter((f) => f.endsWith(".abap"))
  .filter((f) => !EXCLUDED.some((re) => re.test(f)))
  .sort();

const findings = [];

for (const file of files) {
  const lines = readFileSync(ROOT + file, "utf8").split("\n");
  lines.forEach((raw, i) => {
    const code = stripNoise(raw);
    if (!CALL.test(code)) return; // cheap reject: most lines never reach the split
    for (const pos of positions(code)) {
      const hit = CALL.exec(pos.text);
      if (hit) findings.push({ file, line: i + 1, where: pos.where, fn: hit[1], text: raw.trim() });
    }
  });
}

console.log(
  `downport-operand: ${files.length} file(s), ${BUILTINS.length} built-in(s) checked, `
  + `${SELF_TEST.length} self-test case(s) passed`,
);

if (findings.length) {
  console.error(`\n${findings.length} problem(s):`);
  for (const f of findings) {
    console.error(`  ${f.file}:${f.line}: \`${f.fn}( )\` in a ${f.where}`);
    console.error(`    ${f.text}`);
    console.error(
      "    a built-in function is not read as one here at 7.02/7.31 - the "
      + "downported\n    statement fails to compile with \"method "
      + `${f.fn.toUpperCase()} is unknown" (#2664).`,
    );
    console.error("    assign it to a variable on the line above and use the variable.");
  }
  process.exit(1);
}

console.log("no built-in function stands in a 7.02 non-expression operand position - OK");
