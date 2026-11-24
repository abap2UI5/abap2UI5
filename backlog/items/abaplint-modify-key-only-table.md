---
target: abaplint
title: 'Report MODIFY/UPDATE on a database table whose fields are all key fields'
summary: 'a table with key fields only can take INSERT and DELETE, an UPDATE has nothing to change - SLIN "Table ... contains only key fields. Entries can be inserted, but not modified"; abaplint has the TABL and is silent'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 3173ec5: one activation of the S5S DEV state on an S/4HANA EWM system (2026-11-24) warned "Table /KRO/UI502_T026 contains only key fields. Entries can be inserted, but not modified" on /KRO/UI502_CL_APP_009->set_active_user, a MODIFY of the table'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: zp_keyonly with MANDT, TKNUM, UNAME all KEYFLAG X in the repository''s own .tabl.xml, MODIFY zp_keyonly FROM ls_row - no finding of that kind (only ambiguous_statement and check_subrc)'
---

# Report MODIFY/UPDATE on a database table whose fields are all key fields

```abap
" ZP_KEYONLY: MANDT, TKNUM, UNAME - all key fields
DATA(ls_row) = VALUE zp_keyonly( tknum = '1' uname = sy-uname ).
MODIFY zp_keyonly FROM ls_row.   " SLIN: contains only key fields - inserted, not modified
```

A row of a table without non-key fields is all key: there is nothing an
`UPDATE` can change, and `MODIFY` only ever inserts. Code written as "update
the active user" therefore never replaces the existing row - it adds another
one next to it (or does nothing). The system says so at the statement; the
table definition is in the repository as `.tabl.xml`, so the case is
decidable without a system.

**Proposal.** A rule (or a check in `check_syntax`'s SQL part, as a warning):
`UPDATE dbtab` and `MODIFY dbtab` (`FROM wa`, `FROM TABLE itab`, `SET`) are
reported when the table is a TABL known to the project and every field of it,
include structures resolved, is a key field.

**Not reported.** `INSERT` and `DELETE`; a table with any non-key field; a
table that is void (not in the project or its dependencies); a view; a
dynamic table name.

**Where.** a new rule next to the database access rules. **Effort:** S.

**Source.** S5S (a consumer system), one activation on S/4HANA.
