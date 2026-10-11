---
target: abaplint
title: 'Report SELECT … FOR ALL ENTRIES whose field list lacks the full primary key'
summary: 'FOR ALL ENTRIES removes duplicate result rows, so sums and counts are silently wrong when the key is not selected'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report SELECT … FOR ALL ENTRIES whose field list lacks the full primary key

```abap
SELECT amount FROM zitem FOR ALL ENTRIES IN @lt_head WHERE head_id = @lt_head-id INTO TABLE @DATA(lt).
```

**Proposal.** With the table's DDIC key, report FAE selects whose field list does not contain every key field.

**Not reported.** SELECT * (contains the key).

**Where.** a new rule (or an option of the closest existing one). **Effort:** L.

**Source.** SAP FAE documentation.
