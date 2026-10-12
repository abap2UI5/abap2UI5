---
target: abaplint
title: 'Report CLEAR of a variable as its first use after the declaration'
summary: 'a variable just declared is initial; CLEAR as its first use is dead code (or hides a missing initialisation the author had in mind)'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 079 (larshp/abapOpenChecks docs/_checks/79.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report CLEAR of a variable as its first use after the declaration

```abap
DATA lv TYPE i.
CLEAR lv.
rv = lv.
```

**Proposal.** Report CLEAR/FREE of a local, non-static variable that is not read or written between its declaration and the CLEAR, outside loops.

**Not reported.** STATICS; variables in loops (the CLEAR runs every pass); CLEAR … WITH.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks check 079.
