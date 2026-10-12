---
target: abaplint
title: 'Report PROG/FUGR/CLAS XML without fixed point arithmetic'
summary: 'without FIXPT = X, packed numbers are computed as if they had no decimals - silently wrong results, and the flag is easy to lose in a round trip'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - '''FIXPT'' appears nowhere in abaplint core src'
---

# Report PROG/FUGR/CLAS XML without fixed point arithmetic

```abap
<FIXPT></FIXPT>
```

**Proposal.** Report a program, function group or class whose XML does not set FIXPT to X.

**Not reported.** Objects without packed arithmetic (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.
