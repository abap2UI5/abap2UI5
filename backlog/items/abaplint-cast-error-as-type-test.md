---
target: abaplint
title: 'try_cast_empty_catch: also report a CATCH cx_sy_move_cast_error that only records the outcome'
summary: 'a TRY around a down cast whose CATCH cx_sy_move_cast_error only sets a flag, RETURNs or CONTINUEs is an IS INSTANCE OF written as exception handling; try_cast_empty_catch reports only an empty CATCH with the cast as the sole TRY statement'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11 - 74 sites use CATCH cx_sy_move_cast_error to find out which class an object is'
  - 'abaplint 2.120.118, rules/try_cast_empty_catch.ts: reports TRY. a ?= b. CATCH cx_sy_move_cast_error. ENDTRY. only when the cast is the only statement of the TRY, there is exactly one CATCH, without INTO, and its block is EMPTY - with a quick fix to IS INSTANCE OF'
  - 'searched abaplint/abaplint issues 2026-11-24 (move_cast_error, instance of cast): nothing beyond the rule above'
---

# try_cast_empty_catch: also report a CATCH cx_sy_move_cast_error that only records the outcome

```abap
TRY.
    DATA(lo_popup) = CAST zcl_popup( lo_app ).
    lv_is_popup = abap_true.
  CATCH cx_sy_move_cast_error.
    lv_is_popup = abap_false.
ENDTRY.

LOOP AT lt_apps INTO DATA(lo_any).
  TRY.
      DATA(lo_list) = CAST zcl_list( lo_any ).
    CATCH cx_sy_move_cast_error.
      CONTINUE.
  ENDTRY.
  lo_list->refresh( ).
ENDLOOP.
```

**Current behaviour.** `try_cast_empty_catch` covers the plain shape - one
cast, one empty CATCH - and offers the `IS INSTANCE OF` rewrite. Real code
mostly writes one of the shapes above: the CATCH records the answer, or
leaves the loop iteration or the method. Each is a type test written as
exception handling, raising and catching an exception per object that is
not of the type.

**Proposal.** Widen `try_cast_empty_catch` (or an option of it) to a CATCH
block for `cx_sy_move_cast_error` alone, without `INTO`, whose statements
are only:

- assignments of a constant to one variable (`flag = abap_false`), or
- one `RETURN`, `CONTINUE` or `EXIT`,

and a TRY block that starts with the cast (`?=` or `CAST #( )` /
`CAST type( )` into a variable) followed by statements that do not raise
`cx_sy_move_cast_error` themselves (no further cast). The quick fix is the
same rewrite, with the TRY statements moved into the `IF`, and the CATCH
statements into its `ELSE`.

**Not reported.** A CATCH that logs, raises, or uses `INTO`; a TRY block
with a second cast or a call (it could raise the same exception from
elsewhere); the generic `REF TO object` target the rule already skips.

**Where.** `try_cast_empty_catch`. **Effort:** S-M.

**Source.** a consumer system (74 sites).
