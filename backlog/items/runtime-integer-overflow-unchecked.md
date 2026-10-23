---
target: open-abap
title: 'runtime: i overflows silently - 2147483647 + 1 answers 2147483648 and a 1e10 packed value fits into an i, where a system raises CX_SY_ARITHMETIC_OVERFLOW / CX_SY_CONVERSION_OVERFLOW'
summary: '`types/integer.ts` keeps the value in a JS number and the range check in `set( )` is commented out, so `i = i + 1` past 2^31-1 and `i = p` with an 11-digit p both succeed; code that relies on the exception (or on the dump) passes the transpiled suite and fails on a system'
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/pull/2014
first_seen: 2026-10-22
upstream: abaplint/transpiler
evidence:
  - 'measured 2026-10-22 on abaplint/transpiler main 53a708f (runtime 2.14.10) with `runFiles`: `DATA i TYPE i. i = 2147483647. i = i + 1. WRITE i.` writes `2147483648` with no exception; `DATA p TYPE p LENGTH 8 DECIMALS 0 VALUE ''10000000000''. i = p. WRITE i.` writes `10000000000`'
  - 'the cause, read in the same checkout - `packages/runtime/src/types/integer.ts` `set( )`: the block `if (this.value > 2147483647 || this.value < -2147483648) throwError("CX_SY_ARITHMETIC_OVERFLOW")` is inside a `/* */` comment'
  - 'samples-controls `src/02/02/z2ui5_cl_smpc_app_611.clas.abap:135-139` (2026-10): a port whose counter overflowed on a real system while CI stayed green, ''the transpiled backend represents i as a JS number, which is why CI never saw it''; sidecar `meta/z2ui5_cl_smpc_app_611.json`'
  - 'abap2UI5 `src/01/02/z2ui5_cl_ui5_handler.clas.testclasses.abap:680-684`: a conversion test asserts only the exception on a system and not the value, ''the transpiled runtime does not check the range of i'''
  - 'prepared 2026-10-22 as `oblomov-dev/fork-transpiler` branch `fix/integer-overflow-raises` (e883fe1) on abaplint/transpiler main 53a708f: the change plus tests, green in the package suites and the transpiler''s integration tests; the fourteen prepared branches merged together transpile open-abap-core main 239b817 and pass its whole unit suite (1172 tests); abap2UI5 itself, downported and transpiled with that stack (`node/setup/abap_transpile.json`, open-abap-core pinned at 9c1271b with the compare_tables correction), passes `npm run unit` in full (1558 tests). Design note from the implementation: the operators cannot know the target (`f = i * i` is computed in f on a system, and an existing test pins that), so the operator result stays unchecked and `Integer.set( )` raises CX_SY_ARITHMETIC_OVERFLOW for an out-of-range operator result and CX_SY_CONVERSION_OVERFLOW for a conversion; `WRITE i + 1` at the maximum therefore prints instead of raising'
  - 'filed 2026-10-22 as abaplint/transpiler#2014, open on 2026-10-23; the branch merges cleanly onto main after #2012, #2015, #2016 and #2018'
checked_upstream: 2026-10-23
---

# runtime: an `i` overflows silently

## What happens

```abap
DATA i TYPE i.
i = 2147483647.
i = i + 1.         " system: CX_SY_ARITHMETIC_OVERFLOW   runtime 2.14.10: 2147483648

DATA p TYPE p LENGTH 8 DECIMALS 0 VALUE '10000000000'.
i = p.             " system: CX_SY_CONVERSION_OVERFLOW   runtime: 10000000000
```

`packages/runtime/src/types/integer.ts` keeps the value as a JS number
and the range check in `set( )` is commented out. A counter that wraps on
a system, or code that catches the overflow, passes the transpiled unit
suite and fails on the system (samples-controls app 611 found it that way).

## Proposed change

Re-enable the check in `Integer.set( )`: a value outside
`[-2147483648, 2147483647]` raises `CX_SY_CONVERSION_OVERFLOW` when it
comes from a conversion (string, packed, float, int8) and
`CX_SY_ARITHMETIC_OVERFLOW` from the `+ - *` operators (the operator
result type is `i` when both operands are `i`). `Integer8` the same at
2^63. The intermediate of `i + i` is already a JS number, so the check is
one comparison.

Risk: code that relies on the silent wrap. open-abap-core's own suite
and abapGit's will show it; that is the point of the check.

## Test

`test/statements/*`: the two snippets above inside `TRY … CATCH`, expecting
the exception class; plus `-2147483648 - 1`.

## How to file

An issue against abaplint/transpiler with the two snippets; the PR is a
few lines in `integer.ts` plus the operator result check.

