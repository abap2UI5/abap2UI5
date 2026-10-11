---
target: abaplint
title: 'Report IS ASSIGNED after READ … ASSIGNING inside a loop without UNASSIGN first'
summary: 'a failed READ TABLE … ASSIGNING leaves the field symbol on the previous iteration''s row, so IS ASSIGNED reads TRUE for the failure - the complement of subrc_after_assign'
priority: high
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abap2xlsx/abap2xlsx 719fe85 (''Do not rely on IS ASSIGNED inside a LOOP'')'
  - 'abap2UI5/abap2UI5 932cf90, 75bf551, 1e4c2a4'
  - '28 sites in current trees, two latent bugs: abapGit src/ui/zcl_abapgit_popups.clas.locals_imp.abap:168-172 and abap2xlsx src/zcl_excel_writer_huge_file.clas.abap:807 (a cell gets the previous cell''s style)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report IS ASSIGNED after READ … ASSIGNING inside a loop without UNASSIGN first

```abap
LOOP AT lt_cells INTO ls_cell.
  READ TABLE lt_styles ASSIGNING <style> WITH KEY id = ls_cell-style.
  IF <style> IS ASSIGNED.
```

**Proposal.** Report IS [NOT] ASSIGNED on a field symbol whose last binding is a READ TABLE … ASSIGNING or ASSIGN inside the same loop, when no UNASSIGN precedes that statement in the loop body.

**Not reported.** sy-subrc checks (the right test after READ); field symbols declared inline in the READ (fresh each time? no - still stale; keep).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2xlsx and abap2UI5 fix history.
