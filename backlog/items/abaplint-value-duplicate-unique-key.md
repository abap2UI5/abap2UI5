---
target: abaplint
title: 'Report literal rows with duplicate keys in VALUE for a unique-key table'
summary: 'VALUE tt_hashed( ( a = ''A'' ) ( a = ''A'' ) ) dumps with CX_SY_ITAB_DUPLICATE_KEY'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report literal rows with duplicate keys in VALUE for a unique-key table

```abap
lt_map = VALUE tt_hashed( ( id = 'A' ) ( id = 'A' ) ).
```

**Proposal.** Report VALUE constructors of a table with a unique primary key whose literal rows repeat the key values.

**Not reported.** Rows built from variables.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** ESLint no-dupe-keys.
