---
target: abaplint
title: 'Report a direct assignment of TIMESTAMPL to TIMESTAMP'
summary: 'the assignment rounds and can produce second 60; SLIN warns'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'sbcgua/ajson 5e8de3f, 33d6180 (#128), 075a09b'
  - 'abap2UI5/abap2UI5 7c8d64c (#2855: ''rounding it into second 60'')'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a direct assignment of TIMESTAMPL to TIMESTAMP

```abap
DATA lv_ts TYPE timestamp.
lv_ts = lv_tsl.
```

**Proposal.** Report an assignment whose source is typed timestampl and whose target timestamp.

**Not reported.** cl_abap_tstmp=>move_to_short; explicit truncation.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** ajson, abap2UI5 fix history.
