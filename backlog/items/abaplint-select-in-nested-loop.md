---
target: abaplint
title: 'db_operation_in_loop: say when the loop is a nest over the same table (N x N)'
summary: 'a SELECT SINGLE inside a LOOP nested in a LOOP over the same internal table runs N x N times; db_operation_in_loop reports it with the same message as a single loop, and a project that switched the rule off for its many single-loop findings never sees the quadratic one'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11 - a shipment handler reads MARM with SELECT SINGLE inside a LOOP over its warehouse tasks nested in a LOOP over the same warehouse task table: N x N reads for N tasks'
  - 'abaplint 2.120.118, rules/db_operation_in_loop.ts: one issue per LOOP/DO/WHILE structure, at its first database statement, message "Database operation in loop" - the nesting and the loop tables are not looked at'
  - 'searched abaplint/abaplint issues 2026-11-24 (select single nested loop, db_operation_in_loop): nothing on nesting'
---

# db_operation_in_loop: say when the loop is a nest over the same table (N x N)

```abap
LOOP AT lt_wt INTO DATA(ls_wt).
  LOOP AT lt_wt INTO DATA(ls_other) WHERE huident = ls_wt-huident.
    SELECT SINGLE umrez FROM marm
      WHERE matnr = @ls_other-matnr AND meinh = @ls_other-altme
      INTO @DATA(lv_umrez).
  ENDLOOP.
ENDLOOP.
```

**Current behaviour.** `db_operation_in_loop` reports the SELECT once per
enclosing loop structure, with the message it gives a SELECT in a single
loop. The rule is noisy enough in older code that projects switch it off or
exclude files; the nested case, which is quadratic and usually the one
that actually hurts, disappears with the rest.

**Proposal.** In `db_operation_in_loop`:

1. when the database statement sits in a LOOP that is nested in a LOOP over
   the **same** internal table (the same variable after `LOOP AT`), report
   it with its own message ("database operation in a nested loop over the
   same table, N x N") - and
2. an option `onlyNested` (default false) that reports only that case, so a
   project that cannot afford every single-loop finding can still have the
   quadratic ones.

**Not reported as nested.** A nest over two different tables (that is N x M
and stays a plain finding); a `LOOP … WHERE` over a sorted or hashed table read with
its key (option - the inner loop is then cheap, the SELECT still runs per
inner row and stays reported as a plain finding).

**Where.** `db_operation_in_loop`, a second message and one option.
**Effort:** S.

**Source.** a consumer system's shipment handler.
