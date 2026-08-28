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

import { readFileSync } from "node:fs";
import { walk } from "./lib/walk.mjs";
// The detector itself is in lib/ because the backlog probe for the upstream
// rule proposal measures the SAME shape across the sibling checkouts - a
// probe that disagreed with this gate would be arguing for a rule this
// repository does not enforce.
import { BUILTINS, CALL, stripNoise, positions } from "./lib/downport-operands.mjs";

const ROOT = new URL("../../", import.meta.url).pathname;

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
  `downport-operand: ${files.length} file(s), ${BUILTINS.length} built-in(s) checked`,
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
