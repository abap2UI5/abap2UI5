---
target: abaplint
title: 'Report two or more empty CATCH blocks in one TRY'
summary: 'consecutive empty CATCH blocks can be one CATCH with a class list'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 098 (larshp/abapOpenChecks docs/_checks/98.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report two or more empty CATCH blocks in one TRY

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

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks check 098.
