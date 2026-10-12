---
target: abaplint
title: 'Report READ TABLE … BINARY SEARCH without a matching SORT'
summary: 'BINARY SEARCH on a table not sorted by the key does not find lines that exist'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 201560c (''bug fixing'', added the SORT)'
  - '16 sites unsorted within their method in current trees'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report READ TABLE … BINARY SEARCH without a matching SORT

```abap
SORT lt BY b.
READ TABLE lt WITH KEY a = 1 BINARY SEARCH TRANSPORTING NO FIELDS.
```

**Proposal.** Report BINARY SEARCH on a locally filled standard table whose last SORT in the method is missing or does not lead with the WITH KEY fields in order.

**Not reported.** Tables filled outside the method.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapGit fix history; Sonar.
