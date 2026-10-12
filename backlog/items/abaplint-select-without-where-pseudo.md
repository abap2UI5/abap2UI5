---
target: abaplint
title: 'Report SELECT without WHERE and without "#EC CI_NOWHERE'
summary: 'SLIN/ATC reports a SELECT without WHERE; the pseudo comment records that the full read is deliberate'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5 43515c97 (z2ui5_cl_ui5_srv_draft=>count_entries_total) needed the pseudo comment after an ATC run'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report SELECT without WHERE and without "#EC CI_NOWHERE

```abap
SELECT COUNT(*) FROM z2ui5_t_01 INTO @DATA(lv_count).
```

**Proposal.** Report SELECT/OPEN CURSOR without WHERE that carries neither "#EC CI_NOWHERE nor ##NO_WHERE (configurable).

**Not reported.** SELECT … FOR ALL ENTRIES; UP TO 1 ROWS existence checks (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abap2UI5 abap-check §3.
