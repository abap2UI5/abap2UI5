---
target: abaplint
title: 'check_syntax: RAISE EXCEPTION … MESSAGE for a class without IF_T100_MESSAGE'
summary: 'RAISE EXCEPTION TYPE x MESSAGE … (and THROW … MESSAGE) requires x to implement IF_T100_MESSAGE or IF_T100_DYN_MSG, and does not allow textid at the same time - otherwise the class does not activate'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'ABAP keyword documentation, RAISE EXCEPTION - MESSAGE: the T100 interface is requested by the syntax check'
---

# check_syntax: RAISE EXCEPTION … MESSAGE for a class without IF_T100_MESSAGE

The MESSAGE addition maps the T100 message onto the exception's attributes, which only a T100-enabled exception class has.

```abap
RAISE EXCEPTION TYPE zcx_plain MESSAGE e001(zmsg).   " zcx_plain: no IF_T100_MESSAGE
```

**Proposal.** Report RAISE EXCEPTION … MESSAGE where the class (known in the repository) implements neither interface, or where textid is passed as well.

**Not reported.** Void classes.

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** M.

**Source.** ABAP keyword documentation (RAISE EXCEPTION, MESSAGE).
