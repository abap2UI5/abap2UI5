---
target: abaplint
title: 'Report a dynamic WHERE (lv_where) whose string can be empty'
summary: 'SELECT … WHERE (lv_where) with an empty lv_where reads the whole table, and DELETE/UPDATE … WHERE (lv_where) changes every row - a WHERE string assembled from optional filters is empty exactly when the user set none'
priority: high
state: filed
filed: https://github.com/oblomov-dev/fork-abaplint/pull/8
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11 - a SELECT … WHERE (lv_where) whose lv_where can reach the statement empty, which then reads the whole table'
  - 'abaplint 2.120.118: no rule looks at the content of a dynamic WHERE; sql_escape_host_variables and the backlog item abaplint-sql-injection-dynamic are about what goes INTO the string, abaplint-sql-without-where about a statement with no WHERE written at all'
  - 'searched abaplint/abaplint issues 2026-11-24 (dynamic where, where clause empty): abaplint/abaplint#167 (SQL injection) is the closest and asks for a different check'
---

# Report a dynamic WHERE (lv_where) whose string can be empty

```abap
IF iv_matnr IS NOT INITIAL.
  lv_where = |MATNR = @IV_MATNR|.
ENDIF.
IF iv_werks IS NOT INITIAL.
  lv_where = |{ lv_where }{ COND #( WHEN lv_where IS NOT INITIAL THEN ` AND ` ) }WERKS = @IV_WERKS|.
ENDIF.
SELECT * FROM marc WHERE (lv_where) INTO TABLE @rt_marc.    " every row when no filter is set
```

**Current behaviour.** An empty dynamic WHERE is no condition: the
statement runs as if it had no WHERE. For a SELECT that is a full table
read - on a large table a timeout or a memory dump, on a small one a result
nobody asked for. For `DELETE FROM dbtab WHERE (lv_where)` and
`UPDATE dbtab SET … WHERE (lv_where)` it is every row. The static case
(no WHERE written) is `abaplint-sql-without-where`; this one is invisible
in the source, because a WHERE is right there.

**Proposal.** Report `SELECT`, `OPEN CURSOR`, `DELETE FROM`, `UPDATE`
and `MODIFY … WHERE` whose WHERE is a single dynamic token `(lv)` when,
within the procedure, `lv` can reach the statement empty:

- `lv` is a local variable, declared without `VALUE`, and every assignment
  to it before the statement sits inside a conditional branch (`IF`,
  `CASE`, a `LOOP` body - the loop may run zero times); or
- `lv` is assigned from a call or a parameter and no `IF lv IS INITIAL`
  / `CHECK lv IS NOT INITIAL` / `ASSERT` dominates the statement.

Option per statement kind: on by default for DELETE/UPDATE/MODIFY, on for
SELECT (it is the common case), with a list of tables to ignore (customizing
tables a full read of which is fine).

**Not reported.** A WHERE token with a static part (`WHERE mandt = @sy-mandt
AND (lv)` - still a condition); an `lv` with an unconditional assignment of
a non-empty literal or template before the statement; a statement under a
guard on `lv`; `UP TO n ROWS` (option - the read is bounded).

**Where.** a new rule, `dynamic_where_empty`. **Effort:** M (the branch
walk exists for `stale_subrc`-style data flow).

**Source.** a consumer system.
