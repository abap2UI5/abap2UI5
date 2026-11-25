---
target: abaplint
title: 'db_operation_in_loop: report configured expensive function modules called in a loop'
summary: 'db_operation_in_loop sees only Open SQL statements; a function module that reads the database per call (/SCWM/TO_GET_WIP, HU_READ, BAPI_*_GETDETAIL) called in a LOOP is the same N round trips and is not reported - a configurable list of names would cover it'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11 - a stock list makes two reading function module calls per stock row: 1,000 calls for 500 rows, each with its own database reads, and no finding from db_operation_in_loop'
  - 'abaplint 2.120.118, rules/db_operation_in_loop.ts: the rule looks for Select, SelectLoop, InsertDatabase, DeleteDatabase, UpdateDatabase and ModifyDatabase inside LOOP/DO/WHILE - CALL FUNCTION is not among them; function_module_recommendations suggests replacements for fixed names, not their position'
  - 'searched abaplint/abaplint issues 2026-11-24 (function module loop, call function loop, db_operation_in_loop): abaplint/abaplint#1829 (closed 2021, "DB operation inside top LOOP") is where db_operation_in_loop came from and names only SQL statements; nothing on function modules'
---

# db_operation_in_loop: report configured expensive function modules called in a loop

```abap
LOOP AT lt_stock ASSIGNING FIELD-SYMBOL(<ls_stock>).
  CALL FUNCTION '/SCWM/TO_GET_WIP'       " reads the database on every call
    EXPORTING …
    IMPORTING ….
ENDLOOP.
```

**Current behaviour.** `db_operation_in_loop` reports an Open SQL statement
inside LOOP/DO/WHILE. A function module that does the same SELECT inside is
invisible to it, although its cost per row is the same - and for the
standard reading modules of an application area (EWM, HU management, the
`BAPI_*_GETDETAIL` family) that is the common way the N+1 pattern appears in
custom code, because the SQL is in somebody else's package.

**Proposal.** An option of `db_operation_in_loop`, `functionModules`: a list
of function module names (or patterns, `BAPI_*_GETDETAIL`) whose `CALL
FUNCTION` inside a loop is reported like a database operation. Empty by
default, so nothing changes for a project that does not configure it.

**Not reported.** A `CALL FUNCTION` of a name not on the list; a call with
`IN UPDATE TASK` or `IN BACKGROUND TASK` (queued, not executed per row); a
call whose name is dynamic (`CALL FUNCTION lv_name`) unless the option says
so.

**Where.** `db_operation_in_loop`, one option. **Effort:** S.

**Source.** a consumer system's stock list (2 calls per row).
