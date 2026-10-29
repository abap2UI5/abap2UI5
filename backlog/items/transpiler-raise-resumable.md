---
target: open-abap
title: 'transpiler: `RAISE RESUMABLE EXCEPTION` stops the build - "RaiseTranspiler, RESUMABLE not implemented"'
summary: '`RaiseTranspiler` throws for any `RAISE` with `RESUMABLE`, so one resumable raise anywhere in a class keeps the whole input from transpiling, although a handler without `CATCH BEFORE UNWIND` cannot tell a resumable exception from a plain one - transpiling it as a plain `RAISE` would cover that case, and `RESUME` could stay the error it is'
priority: low
state: open
first_seen: 2026-10-24
upstream: abaplint/transpiler
evidence:
  - 'found 2026-10-24 by the start measurement of report2cloud (abap2UI5-addons/abap-cloud-gui, `report2cloud:web --start`) - a class of the open-source web corpus that converted reports depend on raises `RAISE RESUMABLE EXCEPTION TYPE ...`; the transpile of the whole set stopped without naming a file, and the measurement now leaves such objects out before the build (`UNSUPPORTED` in `tools/report2cloud/lib/start.mjs`)'
  - 'reduced 2026-10-24 with @abaplint/transpiler-cli 2.14.5 - a class with `METHODS run RAISING RESUMABLE(cx_static_check).` and `RAISE RESUMABLE EXCEPTION TYPE cx_static_check.` stops the build with "Error: RaiseTranspiler, RESUMABLE not implemented"; abaplint reports no syntax error'
  - 'read 2026-10-24 in @abaplint/transpiler 2.14.5 `build/src/statements/raise.js` - the first lines of `transpile( )`: `if (node.findDirectTokenByText("RESUMABLE")) { throw new Error("RaiseTranspiler, RESUMABLE not implemented"); }`. `CATCH BEFORE UNWIND` parses (`Statements.Catch`) and `RESUME` is a known statement'
---

# transpiler: `RAISE RESUMABLE EXCEPTION` stops the build

## What happens

```abap
METHOD check RAISING RESUMABLE(zcx_warning).
  RAISE RESUMABLE EXCEPTION TYPE zcx_warning.
ENDMETHOD.
" transpiled: the build stops - "RaiseTranspiler, RESUMABLE not implemented"
```

The error comes from the transpiler, not from the code that runs. One
resumable raise in one method of one class keeps the whole input from
transpiling, including every class that never reaches it.

## Why

`build/src/statements/raise.js` refuses the token up front:

```js
if (node.findDirectTokenByText("RESUMABLE")) {
  throw new Error("RaiseTranspiler, RESUMABLE not implemented");
}
```

## The change

Transpile `RAISE RESUMABLE EXCEPTION` like `RAISE EXCEPTION`, with the
resumability left out. A handler that does not use `CATCH BEFORE UNWIND`
followed by `RESUME` cannot tell the two apart. For the handler that does,
`RESUME` (or `CATCH BEFORE UNWIND`) is where the missing feature shows, as a
transpile error or a runtime error that names it. Resuming needs the stack
to be kept until the handler decides, which the `throw` of the generated JS
cannot do. That half can stay unimplemented.

## Example

```abap
TRY.
    NEW zcl_checker( )->check( ).
  CATCH zcx_warning INTO DATA(warning).
    " reached on a system and transpiled alike
ENDTRY.
```
