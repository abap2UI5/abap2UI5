---
target: abaplint
title: 'Report a sy-subrc test directly after a statement that does not set sy-subrc'
summary: '`lv = lo->get( ). IF sy-subrc <> 0.` - a method call without classic EXCEPTIONS, an assignment or CLEAR does not set sy-subrc, so the test reads a stale value'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 11a7e58 introduced `read_progdir( )` followed by `IF sy-subrc = 0`, e2c625f replaced it two PRs later'
  - 'current sites: abapGit zcl_abapgit_sap_package.clas.abap:446, abapOpenChecks zcl_aoc_parser.clas.abap:910'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a sy-subrc test directly after a statement that does not set sy-subrc

```abap
lv = lo->get( ).
IF sy-subrc <> 0.
```

**Proposal.** Report IF/CHECK/CASE/ASSERT on sy-subrc whose nearest preceding statement in the same block is a method call without EXCEPTIONS, an assignment, CLEAR or MOVE.

**Not reported.** Methods with classic EXCEPTIONS; statements that set sy-subrc.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapGit fix history; generalises subrc_after_assign.
