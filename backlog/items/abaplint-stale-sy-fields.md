---
target: abaplint
title: 'A sy-subrc or sy-tabix that is stale where it is read'
summary: 'a sy-subrc test after a statement that does not set sy-subrc, and an INDEX sy-tabix in a LOOP after another statement overwrote sy-tabix, both read a system field that no longer means what the author assumes - one data-flow walk over the statements'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/3260
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 11a7e58 introduced `read_progdir( )` followed by `IF sy-subrc = 0`, e2c625f replaced it two PRs later'
  - 'current site: abapGit zcl_abapgit_sap_package.clas.abap:446'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'sbcgua/ajson fedc4e3: sy-tabix in a LOOP over a hashed table made every array index 0 (ITAB_DUPLICATE_KEY)'
  - 'abaplint/abaplint#3260 (sy-tabix in DO/WHILE) asks for part of it'
  - 'abaplint/abaplint#4418 (delete_index_in_loop, merged) covers DELETE only'
---

# A sy-subrc or sy-tabix that is stale where it is read

Both need the same thing: which statement last set the system field before the read. The ASSIGN case is subrc_after_assign and the DELETE … INDEX case delete_index_in_loop, both shipped.

Merged on 2026-10-12 from the items `abaplint-subrc-after-method-call`, `abaplint-sy-tabix-overwritten`.

## Report a sy-subrc test directly after a statement that does not set sy-subrc

```abap
lv = lo->get( ).
IF sy-subrc <> 0.
```

**Proposal.** Report IF/CHECK/CASE/ASSERT on sy-subrc whose nearest preceding statement in the same block is a method call without EXCEPTIONS, an assignment, CLEAR or MOVE.

**Not reported.** Methods with classic EXCEPTIONS; statements that set sy-subrc.

**Source.** abapGit fix history; generalises subrc_after_assign.

## Report MODIFY/INSERT/READ … INDEX sy-tabix in a LOOP after sy-tabix was overwritten

```abap
LOOP AT lt_a INTO ls.
  READ TABLE lt_b INTO DATA(lb) INDEX 1.
  MODIFY lt_a FROM ls INDEX sy-tabix.
ENDLOOP.
```

**Proposal.** Extend delete_index_in_loop to MODIFY/INSERT/READ … INDEX sy-tabix, and report sy-tabix reads in loops over hashed tables.

**Not reported.** Read-then-modify directly after READ TABLE of the same table.

**Source.** ajson fix history; abaplint/abaplint#3260.

**Where.** a new rule, one option per check. **Effort:** M.

An upstream request exists (https://github.com/abaplint/abaplint/issues/3260); this item collects the cases and the scope for a pull request.
