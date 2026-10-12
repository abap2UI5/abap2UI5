---
target: abaplint
title: 'check_syntax: RETURN, EXIT, CONTINUE or CHECK that leave a CLEANUP block'
summary: 'a CLEANUP block may not contain a statement that statically leaves it - RETURN, or EXIT/CONTINUE/CHECK that end an enclosing loop; the system refuses it, and leaving it at runtime is a runtime error'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, CLEANUP: statements that statically leave the block are a syntax error'
---

# check_syntax: RETURN, EXIT, CONTINUE or CHECK that leave a CLEANUP block

CLEANUP runs on the way to an outer handler and must hand control back. A statement that leaves it is refused by the syntax check.

```abap
DO 2 TIMES.
  TRY.
      lo->run( ).
    CLEANUP.
      EXIT.
  ENDTRY.
ENDDO.
```

**Proposal.** Report RETURN anywhere in a CLEANUP block, and EXIT/CONTINUE/CHECK there when they refer to a loop outside the TRY.

**Not reported.** EXIT/CONTINUE/CHECK of a loop that lies entirely inside the CLEANUP block.

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** S.

**Source.** ABAP keyword documentation (CLEANUP); ESLint no-unsafe-finally; Pylint lost-exception (W0150).
