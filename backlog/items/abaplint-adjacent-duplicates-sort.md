---
target: abaplint
title: 'Report DELETE ADJACENT DUPLICATES … COMPARING without a matching SORT before it'
summary: 'duplicates are only removed when adjacent; without a SORT by the compared fields (or one that leads with other fields) the result silently keeps duplicates'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 6cbc78d (#6121, ITAB_DUPLICATE_KEY afterwards)'
  - 'abap2xlsx/abap2xlsx f44f7ba, 5d80ca2 (#461)'
  - 'latent today: abapGit src/objects/zcl_abapgit_object_shi3.clas.abap:484 sorts BY id and compares spras id'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report DELETE ADJACENT DUPLICATES … COMPARING without a matching SORT before it

```abap
SORT lt_titles BY id.
DELETE ADJACENT DUPLICATES FROM lt_titles COMPARING spras id.
```

**Proposal.** Report DELETE ADJACENT DUPLICATES on a standard table filled in the method when the nearest earlier SORT of it does not lead with the COMPARING fields, or there is none and no SELECT … ORDER BY.

**Not reported.** Tables sorted elsewhere (parameters, attributes); sorted tables.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapGit, abap2xlsx fix history; Sonar S1673.
