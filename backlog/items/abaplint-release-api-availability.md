---
target: abaplint
title: 'Report SAP APIs and additions not available in the configured release'
summary: 'a curated per-release list (generalising forbidden_void_type) would catch cl_abap_unit_assert=>skip on 7.50, cl_abap_tstmp=>move_to_short on 7.31, syst_langu, missing exceptions or parameters on 7.51/7.52'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'SAP/code-pal-for-abap 9a02ae8; sbcgua/ajson 075a09b; abapGit/abapGit c5a6aed, f6ad8c6, 497b432, 1eafca9'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report SAP APIs and additions not available in the configured release

```abap
cl_abap_unit_assert=>skip( 'not on this release' ).   " not on 7.50
```

**Proposal.** Ship a list of API introductions per release and report uses below the configured syntax.version.

**Not reported.** Repository-defined objects.

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** code-pal, ajson, abapGit fix history.
