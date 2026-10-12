---
target: abaplint
title: 'Report SORT … BY without ASCENDING or DESCENDING (configurable)'
summary: 'an implicit sort order makes the reader guess whether the order matters; ask for it on every field'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report SORT … BY without ASCENDING or DESCENDING (configurable)

SORT defaults to ascending; stating it shows the order was chosen.

```abap
SORT lt_rows BY name.
```

Instead:

```abap
SORT lt_rows BY name ASCENDING.
```

**Proposal.** Report a SORT … BY field without ASCENDING/DESCENDING after it (or after the table, for the whole sort).

**Not reported.** SORT without BY (that is sort_empty_key's / the primary key's business); off by default.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.
