---
target: abaplint
title: 'Report a named classic exception mapped to 0'
summary: '`EXCEPTIONS not_found = 0` makes the exception indistinguishable from success'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'Marc-Bernard-Tools/MBT-Base 3492028 (''Fix exception in tree class'')'
  - '24 such mappings in the current abapGit, MBT-Base, abapOpenChecks and abap-file-formats-tools trees'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a named classic exception mapped to 0

```abap
CALL METHOD lo->get_icon
  EXCEPTIONS
    icon_not_found = 0.
```

**Proposal.** Report a named exception (not OTHERS) mapped to 0.

**Not reported.** OTHERS = 0, which is often deliberate.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** MBT-Base fix history.
