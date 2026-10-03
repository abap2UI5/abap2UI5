---
target: open-abap
title: 'transpiler: a LET in a VALUE without FOR is dropped - the binding is never declared, `ReferenceError: s is not defined` at runtime'
summary: `ValueBodyTranspiler` transpiles the LET of a VALUE body only for its FOR chain; without FOR it skips the Let child, so `VALUE #( LET s = … IN ( … s … ) )` and the structure form `VALUE #( LET s = … IN name = s )` reference a JS variable that was never declared - CONV with LET fails too (`SourceUnknown$InlineFieldDefinition`). Only hit when 7.40 source is transpiled directly - the abaplint downport outlines LET first, so the downported tree works
priority: low
state: open
first_seen: 2026-10-03
upstream: abaplint/transpiler
evidence:
  - found 2026-10-03 while separating the abaplint downport VALUE-row bug (abaplint-downport-value-row-not-cleared) from the transpiler - a repro row with `VALUE #( LET s = … IN ( … s … ) ( … ) )`, transpiled from the 7.40 source, died with `ReferenceError: s is not defined`
  - minimal repro 2026-10-03 (class below; @abaplint/transpiler-cli and runtime 2.13.96 - the version abap2UI5's devDependencies pin and the latest on npm that day - against open-abap-core b2d219d) - 9 tests transpiled from the 7.40 source; 6 fail - LET + one row, LET + two rows, LET used only by the second row, LET in a structure VALUE, LET + shared prefix (all `ReferenceError: s is not defined`) and `CONV string( LET s = … IN s )` (`ReferenceError: SourceUnknown$InlineFieldDefinition is not defined`); LET + FOR, COND with LET and REDUCE with LET pass
  - the same five VALUE cases downported with @abaplint/cli 2.120.64 first and then transpiled all pass - the downport outlines LET into `DATA s TYPE string. s = …`, which is why abap2UI5's own unit run (`npm run downport` before `npm run auto_transpile`) never meets it
  - the cause, read in the 2.13.96 bundle and unchanged in `packages/transpiler/src/expressions/value_body.ts` at abaplint/transpiler main a9c6b9f (2026-10-02) - `ValueBodyTranspiler.transpile` computes `outerLetCode` from the body's `Let` child but passes it only to `buildForChain`; in the children loop the `Let` branch is `continue`, so a body without FOR never emits the `LetTranspiler` output. The transpiler's own VALUE tests (`test/expressions/value.ts`) cover LET only together with FOR ("VALUE LET FOR UNTIL with table expressions", "VALUE FOR LET IN")
checked_upstream: 2026-10-03
---

# transpiler: a LET in a VALUE without FOR is dropped

## What happens

A `LET` in a `VALUE` constructor that has no `FOR` is not transpiled. The
binding is never declared, and the generated code references a variable that
does not exist:

```abap
TYPES: BEGIN OF ty_row,
         name TYPE string,
         qty  TYPE i,
       END OF ty_row.
TYPES ty_t_row TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
DATA lt TYPE ty_t_row.

lt = VALUE #( LET s = `x` IN ( name = s qty = 1 ) ( name = `y` qty = 2 ) ).
```

@abaplint/transpiler-cli 2.13.96 emits (types shortened):

```js
lt.set(abap.types.TableFactory.construct(…)
  .appendThis(new abap.types.Structure({…}).setField("name", s).setField("qty", abap.IntegerFactory.get(1)))
  .appendThis(new abap.types.Structure({…}).setField("name", new abap.types.String().set(`y`)).setField("qty", abap.IntegerFactory.get(2))));
```

No `let s = …` anywhere: `ReferenceError: s is not defined` when the statement
runs. The transpile itself succeeds, with the syntax check on.

## Where it applies

| Constructor | 2.13.96 |
|---|---|
| `VALUE #( LET s = … IN ( … s … ) )` - one row, several rows, the binding used by a later row only | `ReferenceError: s is not defined` |
| `VALUE #( LET s = … IN name = s qty = 1 )` - structure | same |
| `VALUE #( LET s = … IN name = s ( qty = 1 ) ( qty = 2 ) )` - shared prefix | same |
| `CONV string( LET s = … IN s )` | `ReferenceError: SourceUnknown$InlineFieldDefinition is not defined` |
| `VALUE #( LET s = … IN FOR i IN tab ( name = s ) )` | correct |
| `COND #( LET s = … IN WHEN … THEN s ELSE … )` | correct |
| `REDUCE i( LET k = 2 IN INIT x = 0 FOR … NEXT x = x + k )` | correct |

## Cause

`ValueBodyTranspiler.transpile` (`packages/transpiler/src/expressions/value_body.ts`):

```js
const outerLet = body.findDirectExpression(Expressions.Let);
const outerLetCode = outerLet === undefined
  ? undefined
  : new LetTranspiler().transpile(outerLet, traversal).getCode();
…
} else if (child.get() instanceof Expressions.For …) {
  … this.buildForChain(forNodes, typ, traversal, body, baseCode, outerLetCode);
} else if (child.get() instanceof Expressions.Let) {
  continue;
}
```

`outerLetCode` reaches the FOR chain and nothing else. Without a `FOR` the
`Let` child is skipped and its code is dropped.

## A fix

When the body has a `Let` and no `For`, wrap the constructor the way the
`DEFAULT` and `OPTIONAL` branches already do: an async IIFE that runs the
`LetTranspiler` output first and then returns the value:

```js
(await (async () => { <outerLetCode> return <the VALUE chain>; })())
```

The binding is then scoped to the expression the way ABAP scopes it. The
`CONV` case needs the same treatment in the CONV transpiler, which does not
read the `Let` at all today.

## Why it is low priority here

abap2UI5's tree never meets it. Its unit run downports first
(`npm run downport`, then `npm run auto_transpile`), and the abaplint downport
outlines a `LET` into a `DATA` and an assignment before the transpiler sees it.
The same five `VALUE` cases pass when they are transpiled from the downport
output. The corpus has no `VALUE`/`CONV` with `LET` today (see the
measurement below; the detector, run over the repro, lists exactly its six
failing constructors and its three passing ones as the negatives). It bites a consumer that transpiles 7.40 source directly,
such as a host's own classes transpiled against `@abap2ui5/node-runtime`, and
it fails at runtime, not at transpile time.

## The repro

`zcl_letrepro`, public section only:

```abap
TYPES: BEGIN OF ty_row,
         name TYPE string,
         qty  TYPE i,
       END OF ty_row.
TYPES ty_t_row TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
```

Its test class, one method per row of the table above:

```abap
METHOD let_two_rows.
  DATA lt TYPE zcl_letrepro=>ty_t_row.
  lt = VALUE #( LET s = `x` IN ( name = s qty = 1 ) ( name = `y` qty = 2 ) ).
  cl_abap_unit_assert=>assert_equals( act = lt[ 1 ]-name exp = `x` ).
  cl_abap_unit_assert=>assert_equals( act = lt[ 2 ]-name exp = `y` ).
ENDMETHOD.

METHOD let_structure.
  DATA ls TYPE zcl_letrepro=>ty_row.
  ls = VALUE #( LET s = `x` IN name = s qty = 1 ).
  cl_abap_unit_assert=>assert_equals( act = ls-name exp = `x` ).
ENDMETHOD.

METHOD let_conv.
  DATA lv TYPE string.
  lv = CONV string( LET s = `x` IN s ).
  cl_abap_unit_assert=>assert_equals( act = lv exp = `x` ).
ENDMETHOD.

METHOD let_for.        " passes
  DATA lt TYPE zcl_letrepro=>ty_t_row.
  DATA lt_i TYPE STANDARD TABLE OF i WITH EMPTY KEY.
  lt_i = VALUE #( ( 1 ) ( 2 ) ).
  lt = VALUE #( LET s = `x` IN FOR i IN lt_i ( name = s qty = i ) ).
  cl_abap_unit_assert=>assert_equals( act = lt[ 2 ]-name exp = `x` ).
ENDMETHOD.
```

`abap_transpile` with `write_unit_tests: true`, `unknownTypes: runtimeError`,
syntax check on, open-abap-core as the lib.

## How to file

An issue with this body against abaplint/transpiler. A PR is possible as
well: the change is local to `value_body.ts` (and the CONV transpiler), and
`test/expressions/value.ts` runs ABAP snippets end to end (`runFiles`, then
`ASSERT`/`WRITE` against the console), so the five failing cases above drop
in as tests as they are.

1. Search the abaplint/transpiler tracker first and record the date in
   `checked_upstream:` (2026-10-03: the GitHub issue search for `LET` and
   for `VALUE LET` in abaplint/transpiler, read through the web page because
   this session has no API access to the repository - 20 and 13 results,
   none about LET in a VALUE or CONV, nor an undeclared LET binding).
2. Open the issue.
3. Set `state: filed` and `filed: <url>` here, run `npm run backlog`, commit.
4. When it ships, bump the transpiler in abap2UI5 and delete this item.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`transpiler-value-let-without-for.probe.mjs` — a VALUE without FOR, or a CONV, that binds a LET - the transpiler never declares the binding; the LETs in VALUE with FOR, COND, SWITCH and REDUCE as the negative.
Run **2026-10-03** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 0 site(s)** in 0 repositories:

_none_

**Must NOT fire on 1 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/99/02/z2ui5_cl_pop_to_select.clas.abap`:132 | COND with LET - transpiled correctly |

**Where the detector is an approximation of the rule:**

- A LET is counted where it opens the constructor body (1 found); a LET inside a FOR (`FOR … LET … IN`) is a different code path and not counted.
- NEW, EXACT and CORRESPONDING with LET were not measured against the transpiler; any found would be listed as negatives, and none is expected in this corpus.
- Every site is correct ABAP on a 7.40+ system and transpiles correctly after the abaplint downport - it fails only where 7.40 source is transpiled directly, at runtime, with `ReferenceError`.

<!-- probe:end -->
