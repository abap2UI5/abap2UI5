---
target: abaplint
title: 'Report transactions whose program, class or screen does not exist'
summary: 'a TRAN pointing at a missing report or class fails at start; abaplint has consistency checks for SMIM/SICF/MSAG/NROB but not TRAN'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report transactions whose program, class or screen does not exist

```abap
TRAN ZMYTX with PGMNA = ZMISSING
```

**Proposal.** In the TRAN XML, resolve the program (and dynpro), or the class/method of an OO transaction, and report one that is not in the registry; void when outside the errorNamespace.

**Not reported.** Parameter transactions pointing at SAP transactions (void).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.
