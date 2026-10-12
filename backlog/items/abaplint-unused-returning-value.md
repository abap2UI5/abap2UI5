---
target: abaplint
title: 'Report functional calls whose RETURNING value is discarded'
summary: 'a standalone call of a method that only returns something (a status, a transformed value) does nothing useful'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report functional calls whose RETURNING value is discarded

```abap
zcl_str=>escape( lv ).
lo_validator->is_valid( ls ).
```

**Proposal.** Report a standalone call of a method with RETURNING and no EXPORTING/CHANGING whose result is unused.

**Not reported.** Fluent methods returning their own class; an allow-list option.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** SpotBugs RV_RETURN_VALUE_IGNORED; Rust #[must_use].
