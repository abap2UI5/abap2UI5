---
target: abaplint
title: 'Report a field symbol that is read but never assigned in its method'
summary: 'a local field symbol that is never the target of ASSIGN, ASSIGNING or REFERENCE INTO but is read always dumps with GETWA_NOT_ASSIGNED - typically a copy-paste error'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4584
first_seen: 2026-10-11
checked_upstream: 2026-11-17
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit f603147 (#2577): `LOOP AT t ASSIGNING <type>. CLEAR <attr>-author.`'
  - 'sbcgua/ajson 06cfb34'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'filed 2026-11-17 as abaplint/abaplint#4584, the rule `field_symbol_never_assigned`. It has no finding in abap2UI5, open-abap-core or abapGit, and neither cited fix is this shape: in abapGit f603147 the field symbol WAS bound by an earlier LOOP ... ASSIGNING and read after ENDLOOP (the after-the-loop check of abaplint-loop-target-misuse), and in ajson 06cfb34 it was not declared at all, which check_syntax already reports'
---

# Report a field symbol that is read but never assigned in its method

```abap
LOOP AT lt ASSIGNING <type>.
  CLEAR <attr>-author.
ENDLOOP.
```

**Proposal.** Report reads of a method-local field symbol that no statement of the method assigns.

**Not reported.** Field symbols passed in (generic parameters), globally declared ones.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapGit, ajson fix history.
