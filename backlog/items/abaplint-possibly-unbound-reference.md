---
target: abaplint
title: 'Report dereferencing a reference that can be initial'
summary: 'the most frequent dump fix in the 18-repository corpus: a reference from a getter or factory, or set in one branch only, dereferenced without IS BOUND - OBJECTS_OBJREF_NOT_ASSIGNED'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'at least 12 fix commits, e.g. abapGit 93597d2, c1e70ce, 8ff0445, df62cb6, 20785fe, b4b3414, 9261028; abap2xlsx 19b3dca; abap2UI5 d92f5ec, 9c28a3a; abaplint-sci-client f88e124'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report dereferencing a reference that can be initial

```abap
lo_node = lo_tree->find( lv_key ).
lo_node->expand( ).
```

**Proposal.** Report a dereference of a local reference whose assignment comes from a callee whose implementation has a path leaving the RETURNING reference initial, or that is assigned in one branch only.

**Not reported.** References created with NEW in the method; guarded by IS BOUND.

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** abapGit, abap2xlsx, abap2UI5 fix history; SpotBugs NP_*.
