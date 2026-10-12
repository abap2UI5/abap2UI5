---
target: abaplint
title: 'SQL without WHERE: DELETE/UPDATE on a whole table, SELECT without WHERE or pseudo comment'
summary: 'DELETE FROM dbtab / UPDATE dbtab SET without WHERE change every row; a SELECT without WHERE reads every row - the same missing-WHERE test on three statements'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'abap2UI5 43515c97 (z2ui5_cl_ui5_srv_draft=>count_entries_total) needed the pseudo comment after an ATC run'
---

# SQL without WHERE: DELETE/UPDATE on a whole table, SELECT without WHERE or pseudo comment

One rule, options per statement kind (modify statements on by default, SELECT off).

Merged on 2026-10-12 from the items `abaplint-db-change-without-where`, `abaplint-select-without-where-pseudo`.

## Report DELETE FROM dbtab and UPDATE dbtab SET without WHERE

```abap
DELETE FROM ztab.
UPDATE ztab SET status = 'X'.
```

**Proposal.** Report DELETE FROM / UPDATE … SET on a database table without WHERE.

**Not reported.** DELETE ztab FROM TABLE / FROM wa (key-based); a pseudo comment for deliberate wipes.

**Source.** Sonar S1139/S1496.

## Report SELECT without WHERE and without "#EC CI_NOWHERE

```abap
SELECT COUNT(*) FROM z2ui5_t_01 INTO @DATA(lv_count).
```

**Proposal.** Report SELECT/OPEN CURSOR without WHERE that carries neither "#EC CI_NOWHERE nor ##NO_WHERE (configurable).

**Not reported.** SELECT … FOR ALL ENTRIES; UP TO 1 ROWS existence checks (option).

**Source.** abap2UI5 abap-check §3.

**Where.** a new rule, one option per check. **Effort:** S.
