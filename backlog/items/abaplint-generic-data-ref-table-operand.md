---
target: abaplint
title: 'check_syntax: the dereference of a generic REF TO data is refused as a table operand'
summary: 'INSERT LINES OF lt INTO TABLE mr_tab->*. and APPEND LINES OF lo_ref->* TO lt. with REF TO data activate on the system; check_syntax reports "INSERT target must be a table" / "LINES OF must be a table type" - LOOP AT mr_tab->* passes'
priority: high
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 80891c9: /KRO/UI509_CL_APP_001 and /KRO/UI509_CL_APP_002 (INSERT LINES OF kopf->* INTO TABLE mo_kopf->*.), /KRO/UI502_CL_APP_001, /KRO/UI502_CL_APP_011, /KRO/UI502_CL_APP_012 and /KRO/UI502_CL_APP_013 (APPEND LINES OF lo_kopf->* TO stock.) - every one activates on an S/4HANA EWM system (2026-11-24); together with the dynamic attribute access they make up most of the 16 files abaplint.jsonc excludes from check_syntax'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated project with a control finding firing: DATA mr_tab TYPE REF TO data. - INSERT LINES OF lt INTO TABLE mr_tab->*. reports "INSERT target must be a table (check_syntax)", APPEND LINES OF mr_tab->* TO lt. reports "LINES OF must be a table type (check_syntax)"; LOOP AT mr_tab->* ASSIGNING FIELD-SYMBOL(<row>). is not reported'
---

# check_syntax: the dereference of a generic REF TO data is refused as a table operand

```abap
DATA mr_tab TYPE REF TO data.
DATA lt     TYPE string_table.

INSERT LINES OF lt INTO TABLE mr_tab->*.          " INSERT target must be a table
APPEND LINES OF mr_tab->* TO lt.                  " LINES OF must be a table type

LOOP AT mr_tab->* ASSIGNING FIELD-SYMBOL(<row>).  " not reported
ENDLOOP.
```

`mr_tab->*` of a generic `REF TO data` has the generic type `data`; whether it
is a table is decided at runtime, as for a field symbol `TYPE any`. The system
activates all three statements. `LOOP AT` accepts the operand; `INSERT` and
`APPEND ... LINES OF` do not.

**Current behaviour.** `5_syntax/statements/insert_internal.ts` accepts a
target of `TableType`, `VoidType`, `AnyType` or `UnknownType`;
`5_syntax/statements/append.ts` the same list for the `LINES OF` source. The
dereference of `REF TO data` yields `DataType` (the generic `data`), which is
in neither list.

**Proposal.** Treat `DataType` like `AnyType` in both checks (and in the other
statements that test for a table operand the same way - `MODIFY`, `DELETE`,
`READ TABLE`, `SORT`, `INSERT ... INTO TABLE`), so a generic operand is not
refused for being generic.

**Not reported.** A table operand of a generic type (`data`, `any`).
**Still reported:** a dereference of a reference typed with a non-table type
(`REF TO string`, `REF TO ty_struct`); a plain non-table variable.

**Where.** `check_syntax` - `insert_internal.ts`, `append.ts`. **Effort:** S.

**Cost of the false positive.** As with the dynamic attribute access, the only
suppression is to exclude the file from `check_syntax` - S5S excludes 16 files
and loses the syntax check on all of them.

**Source.** S5S (a consumer system), linted against the system's own
activation the same day.

A PR is being prepared from oblomov-dev/fork-abaplint.
