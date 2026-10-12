---
target: abaplint
title: 'CATCH handling: cx_root, empty CATCHes that can merge, RAISE without previous'
summary: 'three class-based exception checks - CATCH cx_root swallows system errors, several empty CATCHes in one TRY can be one, and a RAISE in CATCH … INTO x that drops previous = x loses the cause'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# CATCH handling: cx_root, empty CATCHes that can merge, RAISE without previous

All three read the CATCH blocks of a TRY; one rule, one option per check.

Merged on 2026-10-12 from the items `abaplint-catch-cx-root`, `abaplint-combine-empty-catches`, `abaplint-raise-without-previous`.

## Report CATCH cx_root

```abap
TRY.
    run( ).
  CATCH cx_root.
ENDTRY.
```

**Proposal.** Report cx_root in a CATCH clause; option to allow it in the outermost handler of a request (e.g. methods named handle_request) or with INTO + RAISE ... previous.

**Not reported.** CATCH cx_static_check / cx_dynamic_check (option).

## Report two or more empty CATCH blocks in one TRY

Each empty block repeats the same decision.

```abap
TRY.
    run( ).
  CATCH cx_sy_zerodivide.
  CATCH cx_sy_conversion_no_number.
ENDTRY.
```

Instead:

```abap
TRY.
    run( ).
  CATCH cx_sy_zerodivide cx_sy_conversion_no_number.
ENDTRY.
```

**Proposal.** Report a TRY with two or more empty CATCH blocks; quick fix merges them into one CATCH a b.

**Not reported.** A single empty CATCH (empty_structure has a catch option for that, off by default).

## Report RAISE EXCEPTION inside CATCH … INTO x that does not pass previous = x

```abap
CATCH cx_sy_conversion_error INTO DATA(lx).
  RAISE EXCEPTION NEW zcx_error( ).
```

**Proposal.** Report RAISE EXCEPTION/NEW in a CATCH … INTO block that does not supply previous with the caught variable.

**Not reported.** Re-raising the caught object itself (catch_and_raise).

**Source.** Pylint raise-missing-from (W0707).

**Where.** a new rule, one option per check. **Effort:** S.
