---
target: abaplint
title: 'Report MODIFY/INSERT/READ … INDEX sy-tabix in a LOOP after sy-tabix was overwritten'
summary: 'generalises delete_index_in_loop: any … INDEX sy-tabix after an inner LOOP, READ TABLE, APPEND, INSERT, COLLECT or method call in the loop body uses someone else''s index; sy-tabix in a LOOP over a hashed table is always 0'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/3260
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'sbcgua/ajson fedc4e3: sy-tabix in a LOOP over a hashed table made every array index 0 (ITAB_DUPLICATE_KEY)'
  - 'abaplint/abaplint#3260 (sy-tabix in DO/WHILE) asks for part of it'
  - 'abaplint/abaplint#4418 (delete_index_in_loop, merged) covers DELETE only'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report MODIFY/INSERT/READ … INDEX sy-tabix in a LOOP after sy-tabix was overwritten

```abap
LOOP AT lt_a INTO ls.
  READ TABLE lt_b INTO DATA(lb) INDEX 1.
  MODIFY lt_a FROM ls INDEX sy-tabix.
ENDLOOP.
```

**Proposal.** Extend delete_index_in_loop to MODIFY/INSERT/READ … INDEX sy-tabix, and report sy-tabix reads in loops over hashed tables.

**Not reported.** Read-then-modify directly after READ TABLE of the same table.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** ajson fix history; abaplint/abaplint#3260.

An upstream request exists (https://github.com/abaplint/abaplint/issues/3260); this item collects the case and the scope for a pull request.
