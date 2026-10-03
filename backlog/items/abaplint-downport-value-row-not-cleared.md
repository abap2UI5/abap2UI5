---
target: abaplint
title: 'downport: a VALUE table row inherits every component the previous row set and it leaves out - the row work area is never cleared'
summary: the `downport` rule builds all rows of `VALUE #( ( … ) ( … ) )` in one work area and never clears it between rows, so a component a later row leaves out keeps the earlier row's value instead of being initial - silently wrong data, no finding, on every downported 702 branch (abap2UI5, samples, samples-controls) and in the transpiled unit run; reproduced on 2.120.60 and 2.120.64
priority: high
state: open
first_seen: 2026-10-03
upstream: abaplint/abaplint
evidence:
  - 2026-10-03, abap2UI5/headless-frontend (its typed-edit example app) - a row of `mt_row = VALUE #( ( … t_sub = VALUE #( … ) ) ( … ) )` that left out the nested table `T_SUB` came back holding the previous row's `T_SUB` on the transpiled runtime. Its tests run the way abap2UI5's own suite does, `npm run downport` and then `npm run auto_transpile`, so the transpiler only ever sees the downported code
  - minimal repro 2026-10-03 (class below, @abaplint/cli 2.120.60 and 2.120.64 for the downport, @abaplint/transpiler-cli and runtime 2.13.96, open-abap-core b2d219d) - 17 tests; transpiling the 7.40 source directly, all 17 pass; transpiling the downport output, 16 fail - `exp=0 act=1` for an omitted nested table (first or last component), `exp=0 act=5` for an omitted integer, `exp= act=x` for an omitted sub-structure, `exp= act=A` for an empty row `( )`, the same under `BASE`, with an inline `DATA( )` target, with a shared prefix, in a `DO` loop (the FIRST row inherits the previous pass's last row) and through a following `CALL TRANSFORMATION id`; only the FOR variant passes
  - the transpiler, the open-abap runtime and abap2UI5's draft roundtrip were each ruled out in the same run - the undownported VALUE, an asXML roundtrip of the table and of an object holding it (`CALL TRANSFORMATION id`, the draft's mechanism) all keep row 2 initial
  - the cause is in `packages/core/src/rules/downport.ts`, `outlineValue` (abaplint main 91efb82, 2026-10-02) - for each `ValueBodyLine` it emits the row's `FieldAssignment`s into `${structureName}` and `INSERT ${structureName} INTO TABLE ${uniqueName}` at the closing `)`, and nothing at the opening `(`; the multi-row tests in `packages/core/test/rules/downport.ts` ("VALUE appending to table", "… voided type") assign the same components in every row, which is why it never showed
  - `backlog:probe` counts 159 such constructors in the four checkouts, 8 of them in samples' production code (its app overview `z2ui5_cl_smp_app_000` leaves out `intro` in most rows, so on 702 every tile carries the first tile's intro text), 149 in samples-controls; abap2UI5's framework code has none - its 2 sites are test classes whose assertions happen not to read the inherited component (`HIGH` on `EQ`/`CP` range rows, `T_RANGE` of a popup factory call that only asserts the instance)
  - a fix with tests, `backlog/patches/abaplint-downport-value-row-clear.patch` (one commit, `git am` onto abaplint/abaplint main 91efb82) - 11 new tests in `packages/core/test/rules/downport.ts`, none of the 298 existing ones changed; `npm test` in `packages/core` 11 209 passing (32 pending), eslint 0 errors, schema and api-extractor clean. the repro downported with it passes 17 of 17 transpiled (1 of 17 with 2.120.64)
  - samples spells its eight constructors out (branch `claude/abap2ui5-project-brainstorm-nt7ifs`; the overview generator now writes `intro` and `keywords` on every tile) - downported with 2.120.64 and with the patched rule, its tree is then byte-identical
checked_upstream: 2026-10-03
patch: backlog/patches/abaplint-downport-value-row-clear.patch
---

# downport: VALUE table rows inherit the components the previous row set

## What happens

On a release with constructor expressions, a component a `VALUE` row does
not name is **initial**. The downport turns the constructor into one work area
that is filled and inserted row by row, and never clears it in between, so the
component instead keeps whatever an earlier row put there:

```abap
TYPES: BEGIN OF ty_row,
         name  TYPE string,
         qty   TYPE i,
         t_sub TYPE string_table,
       END OF ty_row.
DATA lt TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

lt = VALUE #( ( name = `A` qty = 5 t_sub = VALUE #( ( `x` ) ) )
              ( name = `B` ) ).
" 7.40+: lt[ 2 ]-qty = 0, lines( lt[ 2 ]-t_sub ) = 0
```

`abaplint --fix` with `downport` at `syntax.version: v702` (2.120.64):

```abap
DATA temp1 LIKE lt.
DATA temp2 LIKE LINE OF temp1.
DATA temp3 TYPE string_table.
CLEAR temp1.
temp2-name = `A`.
temp2-qty = 5.
CLEAR temp3.
INSERT `x` INTO TABLE temp3.
temp2-t_sub = temp3.
INSERT temp2 INTO TABLE temp1.
temp2-name = `B`.
INSERT temp2 INTO TABLE temp1.     " still qty = 5, t_sub = ( `x` )
lt = temp1.
```

The code activates, abaplint reports nothing, and the second row is
`( name = B qty = 5 t_sub = ( x ) )`.

## Where it applies

Every component kind - scalar, structure, nested table - and every place the
rows are built the same way:

| Shape | After the downport |
|---|---|
| a later row leaves out a component an earlier row set | inherits it |
| an empty row `( )` after a filled one | is a copy of the previous row |
| `BASE lt ( … ) ( … )` | same, among the new rows |
| `DATA(lt) = VALUE ty_t( ( … ) ( … ) )` | same |
| the constructor inside a `LOOP`/`DO` | the FIRST row inherits from the previous pass's last row - `DATA` is not executable, the work area lives across passes |
| a shared prefix, `VALUE #( sign = 'I' ( option = 'BT' low = 1 high = 5 ) ( option = 'EQ' low = 9 ) )` | the prefix survives as it should; row 2 inherits `high = 5` |
| `FOR … IN … ( … )` | correct - every iteration assigns the same components |
| rows that all assign the same components | correct |

A downported codebase is also a 702 *system's* code: abap2UI5, samples and
samples-controls force-push the downport output to a `702` branch that
installations pull. On those systems this is not a test artefact but wrong
data at runtime.

## A fix

In `outlineValue`, at a row's opening `(`: clear the work area and re-apply
the shared prefix before the row's own assignments. Clearing alone would be
wrong for the prefix form, whose assignments apply to every following row and
are emitted once today:

```abap
CLEAR temp2.                 " new: at every row, the first included
temp2-sign = 'I'.            " the prefix, now per row instead of once
temp2-option = 'BT'.
temp2-low = 1.
temp2-high = 5.
INSERT temp2 INTO TABLE temp1.
CLEAR temp2.
temp2-sign = 'I'.
temp2-option = 'EQ'.
temp2-low = 9.
INSERT temp2 INTO TABLE temp1.
```

The first row needs it too: a constructor inside a loop reaches its first
row with the work area of the previous pass, because the generated `DATA` is
declarative and does not reinitialise anything. Rows that are a plain source,
`( lv_line )`, or `LINES OF` insert directly and need nothing.

**Only where a row can see an earlier one.** When every row assigns the same
set of components and the prefix does not change between rows, nothing can
leak - every component a row writes is written by every row, in every pass.
That covers every `FOR` and every existing multi-row test, so the patch
emits the `CLEAR` only when the rows differ in shape (an empty row `( )`
among filled ones included) or a prefix assignment follows a row. Output that
is correct today stays byte-identical.

## The patch

[`backlog/patches/abaplint-downport-value-row-clear.patch`](../patches/abaplint-downport-value-row-clear.patch)
is one commit, `git am` onto abaplint/abaplint main 91efb82 (checked in a
fresh clone: applies cleanly, the tree equals the tested one). 54 lines in
`packages/core/src/rules/downport.ts` (`valueRowsNeedClear`,
`isStructuredValueRow`, the `CLEAR` and the per-row prefix in
`outlineValue`), 318 lines of tests.

**Tests**, in the style of `packages/core/test/rules/downport.ts`
(`testFix`, input and expected output): a row that leaves out a scalar, a
nested table, a sub-structure; an empty row after a filled one; `BASE` with
a source row in between; an inline `DATA( )` target; a shared prefix with a
row that leaves out a component; a prefix changed between rows; the
constructor inside a `DO`; `FOR` with two rows of different shapes; and rows
that assign the same components in a different order, which must stay
without `CLEAR`. None of the existing expectations changed.

**Evidence**, all 2026-10-03:

| | |
|---|---|
| downport rule tests | 309 passing, 5 pending (298 before, plus the 11 new) |
| `npm test` in `packages/core` | 11 209 passing, 32 pending; eslint 0 errors (one pre-existing warning in `else_after_all_returns.ts`); `npm run schema` and api-extractor clean |
| the 17-test repro, downported by the CLI built against the patched core, then transpiled (transpiler 2.13.96) | **17 / 17 pass** - 2.120.64: 1 / 17; the 7.40 source transpiled directly: 17 / 17 |
| abap2UI5/samples at main 2e998ef, `abap_702.jsonc`, patched vs. released 2.120.64 | differs in exactly the 8 files the probe lists, by 162 added `CLEAR` lines and nothing else |
| abap2UI5/samples after its mitigation (all 8 constructors spelled out), patched vs. released 2.120.64 | byte-identical |

**One behavioural change.** A shared prefix with a side effect, such as a
method call, is now evaluated once per row instead of once per constructor -
the price of re-applying it after the `CLEAR`. That only happens for
constructors whose rows differ in shape, where the output was wrong before.
An alternative that evaluates the prefix once is a second work area holding
only the prefix and `temp2 = temp_prefix.` instead of `CLEAR` plus the
assignments; it costs one more declaration per constructor.

## Pull request

Ready to paste. Title:

```
downport: clear the VALUE row work area between rows of different shapes
```

Body:

```markdown
`outlineValue` builds every row of a table `VALUE` in one work area
(`DATA temp2 LIKE LINE OF temp1`) and never clears it, so a component a row
leaves out keeps what an earlier row put there instead of being initial:

    TYPES: BEGIN OF ty_row,
             name TYPE string,
             qty  TYPE i,
           END OF ty_row.
    DATA tab TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.
    tab = VALUE #( ( name = 'A' qty = 5 ) ( name = 'B' ) ).

downports to

    DATA temp1 LIKE tab.
    CLEAR temp1.
    DATA temp2 LIKE LINE OF temp1.
    temp2-name = 'A'.
    temp2-qty = 5.
    INSERT temp2 INTO TABLE temp1.
    temp2-name = 'B'.
    INSERT temp2 INTO TABLE temp1.     " qty is still 5
    tab = temp1.

The code activates and nothing reports it. The same happens for an empty
row `( )` after a filled one, under `BASE`, with an inline `DATA( )` target,
for nested tables and sub-structures, and inside a `LOOP`/`DO`, where the
*first* row inherits the previous pass's last row (the generated `DATA` does
not reinitialize).

**Change.** A row that is built in the work area now starts with
`CLEAR temp2.` followed by the shared prefix assignments
(`VALUE #( sign = 'I' ( ... ) ( ... ) )`), which are emitted at every row
instead of once before the first, so the prefix still applies to every row.
Source rows `( lv_line )` and `LINES OF` are unchanged.

The `CLEAR` is only emitted when a row can observe an earlier one: when the
rows assign different sets of components, or a prefix assignment follows a
row. If all rows assign the same components, nothing can leak, so every
`FOR` and all existing multi-row tests downport exactly as before - none of
the existing expectations changed.

One behavioural note: in the constructors that get the `CLEAR`, a shared
prefix is evaluated per row instead of once. Happy to switch to a second work
area holding the prefix (`temp2 = temp3.` instead of `CLEAR` + assignments)
if you prefer that.

**Tests.** 11 new `testFix` cases: omitted scalar, nested table,
sub-structure, empty row, `BASE`, inline target, shared prefix, prefix
changed between rows, inside `DO`, `FOR` with two row shapes, and same
components in a different order (no `CLEAR`). `npm test` in `packages/core`
is green.

**Verified end to end** on abap2UI5/samples, which publishes its downport as
a 702 branch: with this change the downport output differs from 2.120.64
only by the added `CLEAR`s (162 lines), in exactly the 8 constructors whose
rows differ in shape, and nowhere else. A 17-case repro that fails 16 times
after the 2.120.64 downport passes completely.
```

## How to file

It is a correctness bug with a minimal repro, against a rule we can test
ourselves - a PR with the fix and the test is the realistic way:

1. Search the abaplint/abaplint tracker first and record the date in
   `checked_upstream:` (2026-10-03: the issue lists for "downport VALUE" and
   "downport clear" were read through the web, not the API - nothing about
   row work areas; PR #2636 "downport add CLEAR" from 2022 is about clearing
   the target table, not the row).
2. Open the pull request from the patch (`git am` onto main, push to a
   fork) with the description under "Pull request" above; the repro and
   the table of this item are the runtime evidence if a maintainer asks.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump abaplint here and in the downported repositories -
   their `702` branches pick the fix up on the next rebuild - and delete
   this item.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-downport-value-row-not-cleared.probe.mjs` — a table VALUE constructor where a later row leaves out a component an earlier row assigned, with the constructors whose rows differ in shape but never leave one out as the negative.
Run **2026-10-03** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 159 site(s)** in 3 repositories:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/03/z2ui5_cl_ui5_util_context.clas.testclasses.abap`:1204 | 4 rows, 2 inherit: row 3 leaves out high (row 2) |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_get_range_m.clas.testclasses.abap`:17 | 2 rows, 1 inherit: row 2 leaves out t_range (row 1) |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:721 | 127 rows, 121 inherit: row 2 leaves out intro (row 1) |
| samples | `src/z2ui5_cl_smp_app_011.clas.abap`:139 | 6 rows, 1 inherit: row 6 leaves out title (row 5), value (row 5), info (row 5), descr (row 5), checkbox (row 5) |
| samples | `src/z2ui5_cl_smp_app_421.clas.abap`:67 | 6 rows, 1 inherit: row 6 leaves out title (row 5), value (row 5), info (row 5), description (row 5), checkbox (row 5) |
| samples | `src/z2ui5_cl_smp_app_452.clas.abap`:57 | 11 rows, 7 inherit: row 3 leaves out subtitle (row 2) |
| samples | `src/z2ui5_cl_smp_app_460.clas.abap`:40 | 3 rows, 1 inherit: row 3 leaves out nodes (row 2) |
| samples | `src/z2ui5_cl_smp_app_461.clas.abap`:37 | 3 rows, 1 inherit: row 3 leaves out nodes (row 2) |
| samples | `src/z2ui5_cl_smp_app_467.clas.abap`:44 | 2 rows, 1 inherit: row 2 leaves out target (row 1) |
| samples | `src/z2ui5_cl_smp_app_507.clas.abap`:56 | 4 rows, 1 inherit: row 3 leaves out maxvalue (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_015.clas.abap`:111 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_015.clas.abap`:112 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_049.clas.abap`:143 | 14 rows, 12 inherit: row 3 leaves out value (row 2), min (row 2), max (row 2), validationmode (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_054.clas.abap`:85 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_054.clas.abap`:88 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_093.clas.abap`:139 | 4 rows, 2 inherit: row 3 leaves out modified (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_253.clas.abap`:74 | 5 rows, 1 inherit: row 5 leaves out valuestatetext (row 4) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_254.clas.abap`:73 | 5 rows, 1 inherit: row 5 leaves out valuestatetext (row 4) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_255.clas.abap`:74 | 5 rows, 1 inherit: row 5 leaves out valuestatetext (row 4) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_284.clas.abap`:194 | 6 rows, 1 inherit: row 2 leaves out subtitle (row 1), counter (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_404.clas.abap`:73 | 5 rows, 1 inherit: row 5 leaves out valuestatetext (row 4) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_436.clas.abap`:127 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_436.clas.abap`:130 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_437.clas.abap`:125 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_437.clas.abap`:128 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_451.clas.abap`:181 | 4 rows, 2 inherit: row 3 leaves out modified (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_540.clas.abap`:174 | 22 rows, 15 inherit: row 2 leaves out pic (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_540.clas.abap`:200 | 15 rows, 10 inherit: row 2 leaves out info (row 1), pic (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:212 | 11 rows, 2 inherit: row 4 leaves out t_headers (row 3) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:214 | 22 rows, 15 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:246 | 11 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:265 | 9 rows, 6 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:281 | 7 rows, 4 inherit: row 3 leaves out info (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:292 | 8 rows, 5 inherit: row 3 leaves out info (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:307 | 6 rows, 3 inherit: row 4 leaves out info (row 3) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:320 | 13 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:340 | 13 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:360 | 6 rows, 3 inherit: row 4 leaves out info (row 3) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:373 | 6 rows, 3 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_542.clas.abap`:383 | 12 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_546.clas.abap`:359 | 11 rows, 7 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_546.clas.abap`:374 | 7 rows, 4 inherit: row 2 leaves out pic (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_552.clas.abap`:105 | 39 rows, 32 inherit: row 8 leaves out text (row 7), tentative (row 7) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_566.clas.abap`:312 | 27 rows, 11 inherit: row 4 leaves out category (row 3), productid (row 3), dimensions (row 3), weightmeasure (row 3), weightunit (row 3), weight_state (row 3) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:170 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:140 | 2 rows, 1 inherit: row 2 leaves out nodes (row 1) |
| samples-controls | `src/01/02/z2ui5_cl_smpc_app_226.clas.abap`:192 | 5 rows, 4 inherit: row 2 leaves out introtext1 (row 1), introtext2 (row 1), introtext3 (row 1), description1 (row 1), description2 (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_025.clas.abap`:124 | 4 rows, 2 inherit: row 2 leaves out actions (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_066.clas.abap`:113 | 5 rows, 4 inherit: row 2 leaves out active (row 1), counter (row 1), subtitle (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_067.clas.abap`:130 | 5 rows, 4 inherit: row 2 leaves out active (row 1), counter (row 1), subtitle (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_099.clas.abap`:170 | 2 rows, 1 inherit: row 2 leaves out titleurl (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_099.clas.abap`:184 | 5 rows, 4 inherit: row 2 leaves out pagelinkid (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_099.clas.abap`:198 | 3 rows, 2 inherit: row 2 leaves out url (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_099.clas.abap`:203 | 2 rows, 1 inherit: row 2 leaves out emailsubject (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_100.clas.abap`:205 | 2 rows, 1 inherit: row 2 leaves out titleurl (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_100.clas.abap`:219 | 4 rows, 3 inherit: row 2 leaves out pagelinkid (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_100.clas.abap`:232 | 3 rows, 2 inherit: row 2 leaves out url (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_100.clas.abap`:237 | 2 rows, 1 inherit: row 2 leaves out emailsubject (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_100.clas.abap`:255 | 2 rows, 1 inherit: row 2 leaves out url (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_121.clas.abap`:189 | 2 rows, 1 inherit: row 2 leaves out mediatype (row 1), markers (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_121.clas.abap`:196 | 4 rows, 1 inherit: row 4 leaves out active (row 3) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_291.clas.abap`:162 | 2 rows, 1 inherit: row 2 leaves out groupitems (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_291.clas.abap`:166 | 2 rows, 1 inherit: row 2 leaves out authorpicture (row 1), authoravatarcolor (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_294.clas.abap`:201 | 11 rows, 7 inherit: row 3 leaves out subtitle (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_421.clas.abap`:245 | 2 rows, 1 inherit: row 2 leaves out titleurl (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_421.clas.abap`:260 | 4 rows, 3 inherit: row 2 leaves out pagelinkid (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_421.clas.abap`:274 | 3 rows, 2 inherit: row 2 leaves out url (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_421.clas.abap`:279 | 2 rows, 1 inherit: row 2 leaves out emailsubject (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_531.clas.abap`:170 | 2 rows, 1 inherit: row 2 leaves out titleurl (row 1), icon (row 1), fallbackicon (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_531.clas.abap`:188 | 4 rows, 3 inherit: row 2 leaves out pagelinkid (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_531.clas.abap`:204 | 3 rows, 2 inherit: row 2 leaves out url (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_531.clas.abap`:209 | 2 rows, 1 inherit: row 2 leaves out emailsubject (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_532.clas.abap`:176 | 2 rows, 1 inherit: row 2 leaves out header (row 1), title (row 1), icon (row 1), description (row 1), groups (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_532.clas.abap`:208 | 3 rows, 1 inherit: row 3 leaves out emailsubject (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_532.clas.abap`:224 | 3 rows, 1 inherit: row 3 leaves out emailsubject (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_532.clas.abap`:240 | 3 rows, 1 inherit: row 3 leaves out emailsubject (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_532.clas.abap`:256 | 3 rows, 1 inherit: row 3 leaves out emailsubject (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_536.clas.abap`:287 | 22 rows, 15 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_536.clas.abap`:318 | 11 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_536.clas.abap`:336 | 13 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_537.clas.abap`:376 | 12 rows, 8 inherit: row 3 leaves out info (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_537.clas.abap`:396 | 13 rows, 10 inherit: row 3 leaves out info (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_538.clas.abap`:211 | 22 rows, 15 inherit: row 2 leaves out pic (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_538.clas.abap`:237 | 15 rows, 10 inherit: row 2 leaves out info (row 1), pic (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_539.clas.abap`:282 | 13 rows, 10 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_539.clas.abap`:297 | 3 rows, 1 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_539.clas.abap`:304 | 12 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_539.clas.abap`:318 | 2 rows, 1 inherit: row 2 leaves out pic (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_541.clas.abap`:285 | 22 rows, 15 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_541.clas.abap`:319 | 11 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_541.clas.abap`:340 | 12 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_541.clas.abap`:358 | 7 rows, 2 inherit: row 6 leaves out color (row 5) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_543.clas.abap`:236 | 14 rows, 12 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_543.clas.abap`:255 | 13 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_543.clas.abap`:270 | 2 rows, 1 inherit: row 2 leaves out pic (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_544.clas.abap`:244 | 22 rows, 15 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_544.clas.abap`:276 | 11 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_544.clas.abap`:295 | 13 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_545.clas.abap`:173 | 22 rows, 15 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_545.clas.abap`:205 | 11 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_545.clas.abap`:224 | 13 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_547.clas.abap`:544 | 22 rows, 15 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_547.clas.abap`:576 | 11 rows, 8 inherit: row 2 leaves out info (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_547.clas.abap`:595 | 13 rows, 9 inherit: row 3 leaves out pic (row 2) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_549.clas.abap`:727 | 40 rows, 33 inherit: row 8 leaves out text (row 7), tentative (row 7) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_550.clas.abap`:166 | 37 rows, 30 inherit: row 8 leaves out text (row 7), tentative (row 7) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_551.clas.abap`:180 | 37 rows, 30 inherit: row 8 leaves out text (row 7), tentative (row 7) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_553.clas.abap`:192 | 36 rows, 29 inherit: row 8 leaves out text (row 7), tentative (row 7) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_553.clas.abap`:235 | 7 rows, 3 inherit: row 5 leaves out color (row 4) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_554.clas.abap`:223 | 18 rows, 11 inherit: row 8 leaves out text (row 7), tentative (row 7) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_555.clas.abap`:677 | 9 rows, 4 inherit: row 6 leaves out t_recurrence_day (row 5) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_555.clas.abap`:698 | 11 rows, 6 inherit: row 6 leaves out t_recurrence_day (row 5) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_563.clas.abap`:191 | 5 rows, 1 inherit: row 2 leaves out subtitle (row 1), counter (row 1) |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_564.clas.abap`:189 | 5 rows, 1 inherit: row 2 leaves out subtitle (row 1), counter (row 1) |
| samples-controls | `src/02/02/z2ui5_cl_smpc_app_308.clas.abap`:238 | 4 rows, 2 inherit: row 3 leaves out color (row 2) |
| samples-controls | `src/02/02/z2ui5_cl_smpc_app_308.clas.abap`:244 | 5 rows, 3 inherit: row 3 leaves out color (row 2) |
| samples-controls | `src/02/02/z2ui5_cl_smpc_app_359.clas.abap`:329 | 123 rows, 121 inherit: row 3 leaves out navigatedstate (row 2) |
| samples-controls | `src/02/02/z2ui5_cl_smpc_app_611.clas.abap`:188 | 3 rows, 1 inherit: row 3 leaves out end_date (row 2) |
| samples-controls | `src/02/03/z2ui5_cl_smpc_app_412.clas.abap`:930 | 2 rows, 1 inherit: row 2 leaves out titleurl (row 1) |
| samples-controls | `src/02/03/z2ui5_cl_smpc_app_412.clas.abap`:944 | 4 rows, 3 inherit: row 2 leaves out pagelinkid (row 1) |
| samples-controls | `src/02/03/z2ui5_cl_smpc_app_412.clas.abap`:957 | 3 rows, 2 inherit: row 2 leaves out url (row 1) |
| samples-controls | `src/02/03/z2ui5_cl_smpc_app_412.clas.abap`:962 | 2 rows, 1 inherit: row 2 leaves out emailsubject (row 1) |
| samples-controls | `src/02/04/z2ui5_cl_smpc_app_585.clas.abap`:247 | 4 rows, 3 inherit: row 2 leaves out t_items (row 1) |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_241.clas.abap`:295 | 5 rows, 2 inherit: row 4 leaves out items (row 3) |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_302.clas.abap`:414 | 7 rows, 1 inherit: row 5 leaves out items (row 4) |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_303.clas.abap`:337 | 7 rows, 5 inherit: row 3 leaves out key (row 2) |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_407.clas.abap`:637 | 8 rows, 7 inherit: row 2 leaves out tagtext (row 1) |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_407.clas.abap`:693 | 7 rows, 6 inherit: row 2 leaves out tagtext (row 1) |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_006.clas.abap`:139 | 6 rows, 4 inherit: row 2 leaves out children (row 1) |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_008.clas.abap`:68 | 5 rows, 2 inherit: row 4 leaves out attributes (row 3), team (row 3) |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_014.clas.abap`:214 | 3 rows, 1 inherit: row 2 leaves out relationships (row 1) |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_014.clas.abap`:223 | 2 rows, 1 inherit: row 2 leaves out relationships (row 1) |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_014.clas.abap`:241 | 5 rows, 2 inherit: row 3 leaves out relationships (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:1789 | 3 rows, 1 inherit: row 3 leaves out checked (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:2045 | 2 rows, 1 inherit: row 2 leaves out is_post171 (row 1), notes (row 1), post171 (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:2162 | 4 rows, 1 inherit: row 4 leaves out is_post171 (row 3), notes (row 3), post171 (row 3) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:2183 | 3 rows, 1 inherit: row 3 leaves out notes (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:2966 | 4 rows, 1 inherit: row 3 leaves out notes (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:2987 | 3 rows, 1 inherit: row 3 leaves out notes (row 2), checked (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:3378 | 2 rows, 1 inherit: row 2 leaves out is_post171 (row 1), post171 (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:3649 | 2 rows, 1 inherit: row 2 leaves out is_post171 (row 1), post171 (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:3841 | 2 rows, 1 inherit: row 2 leaves out checked (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:3974 | 3 rows, 1 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:4547 | 3 rows, 1 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:4606 | 3 rows, 2 inherit: row 2 leaves out is_post171 (row 1), notes (row 1), post171 (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:4648 | 2 rows, 1 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:4927 | 3 rows, 1 inherit: row 3 leaves out notes (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:5269 | 3 rows, 1 inherit: row 3 leaves out notes (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:5372 | 2 rows, 1 inherit: row 2 leaves out is_post171 (row 1), post171 (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6109 | 2 rows, 1 inherit: row 2 leaves out is_post171 (row 1), post171 (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6196 | 2 rows, 1 inherit: row 2 leaves out checked (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6214 | 3 rows, 1 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6273 | 3 rows, 2 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6882 | 2 rows, 1 inherit: row 2 leaves out since (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:7486 | 2 rows, 1 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:7692 | 2 rows, 1 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:8132 | 4 rows, 2 inherit: row 3 leaves out notes (row 2) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:8152 | 5 rows, 4 inherit: row 2 leaves out notes (row 1) |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:9065 | 2 rows, 1 inherit: row 2 leaves out is_post171 (row 1), post171 (row 1) |

**Must NOT fire on 47 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_action.clas.testclasses.abap`:504 | 2 rows of 2 shapes, no row leaves out an earlier component |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.testclasses.abap`:1688 | 4 rows of 2 shapes, no row leaves out an earlier component |
| abap2UI5 | `src/99/02/z2ui5_cl_pop_get_range.clas.testclasses.abap`:49 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_015.clas.abap`:113 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_054.clas.abap`:91 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_436.clas.abap`:133 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_437.clas.abap`:131 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_496.clas.abap`:151 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_496.clas.abap`:162 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_496.clas.abap`:173 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_496.clas.abap`:184 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_496.clas.abap`:212 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:176 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:193 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:210 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:227 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:244 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_601.clas.abap`:261 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:146 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:163 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:180 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:197 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:214 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_602.clas.abap`:231 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/01/z2ui5_cl_smpc_app_603.clas.abap`:111 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/02/z2ui5_cl_smpc_app_364.clas.abap`:159 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/02/z2ui5_cl_smpc_app_366.clas.abap`:158 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/01/04/z2ui5_cl_smpc_app_133.clas.abap`:188 | 11 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_065.clas.abap`:310 | 4 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_100.clas.abap`:250 | 3 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_376.clas.abap`:110 | 5 rows of 3 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_541.clas.abap`:368 | 4 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_553.clas.abap`:245 | 5 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_554.clas.abap`:244 | 5 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/01/z2ui5_cl_smpc_app_562.clas.abap`:380 | 4 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_407.clas.abap`:641 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/02/05/z2ui5_cl_smpc_app_407.clas.abap`:726 | 3 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_007.clas.abap`:87 | 11 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:2205 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:3006 | 3 rows of 3 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:3424 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:4039 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6712 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:6799 | 3 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:7472 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:8171 | 2 rows of 2 shapes, no row leaves out an earlier component |
| samples-controls | `src/z2ui5_cl_smpc_app_000.clas.abap`:10317 | 3 rows of 2 shapes, no row leaves out an earlier component |

**Where the detector is an approximation of the rule:**

- One site per constructor, located at its VALUE; the text names the first row that inherits and from which earlier row. Every later row that inherits is counted, not listed.
- Constructors whose rows all assign the same components are correct after the downport too and are not listed as negatives (969 of them) - the negatives are the closer lookalike, rows of different shapes where no row leaves out what an earlier one set.
- Constructors with FOR are not counted (46 skipped): every iteration assigns the same component list, so they do not leak - unless one FOR carries several rows of different shapes, which this detector does not read.
- Inside a loop the first row also inherits, from the previous pass's last row; that needs the control flow and is not detected, so the count is a lower bound.
- A shared prefix (`VALUE #( sign = 'I' ( low = 1 ) ( low = 2 ) )`) is assigned once before the rows and does not leak; it is not reported. A row that overrides a prefix component and a later row that does not is reported against the overriding row, which is right: the later row inherits the override, not the prefix.
- A component path `s-a` counts as covered by a later `s =` or the same `s-a =`; a later `s-b =` alone does not cover `s-a`, which is right too.
- String templates are blanked up to the next unescaped `|`; a template nested inside `{ }` of another template would confuse the parenthesis matching. None is expected in this corpus.
- Every site is correct ABAP on a 7.40+ system. It is wrong only after the abaplint downport - the 702 branches abap2UI5, samples and samples-controls publish, and the tree `npm run unit` transpiles.

<!-- probe:end -->
