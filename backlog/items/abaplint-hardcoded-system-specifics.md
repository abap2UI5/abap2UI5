---
target: abaplint
title: 'Report comparisons of sy-uname/sy-sysid/sy-mandt/sy-host with literals and literal paths/URLs'
summary: 'a user or system name in code behaves differently per system and is a classic audit finding (backdoor)'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report comparisons of sy-uname/sy-sysid/sy-mandt/sy-host with literals and literal paths/URLs

```abap
IF sy-uname = 'JDOE'.
IF sy-sysid = 'PRD'.
OPEN DATASET '/usr/sap/tmp/x' FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
```

**Proposal.** Report the comparisons, literal absolute paths in DATASET statements and literal URLs/IPs in create_by_url.

**Not reported.** Test classes.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Sonar S5115/S1313; abapOpenChecks 102.
