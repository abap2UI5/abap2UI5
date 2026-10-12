---
target: abaplint
title: 'check_syntax: a CATCH of a subclass after the CATCH of its superclass'
summary: 'special exception classes have to be caught before general ones - a CATCH whose class is a subclass of one caught earlier in the same TRY is a syntax error'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, CATCH: the order special-before-general must be kept, otherwise syntax error'
---

# check_syntax: a CATCH of a subclass after the CATCH of its superclass

The later CATCH can never be reached, and the system refuses the TRY.

```abap
TRY.
    lo->run( ).
  CATCH cx_static_check.
  CATCH zcx_not_found.        " subclass of cx_static_check
ENDTRY.
```

**Proposal.** Report a CATCH class (or an entry of a CATCH list) that inherits from a class named in an earlier CATCH of the same TRY.

**Not reported.** Void (unknown) classes; unrelated classes.

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** M.

**Source.** ABAP keyword documentation (CATCH); Pylint bad-except-order (E0701).
