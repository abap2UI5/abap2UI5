---
target: abaplint
title: 'SELECT FROM @itab: report a standard-key host table and a statement that goes to the database'
summary: 'SLIN "The primary key of LT_X is ignored because it is generic or is the standard key" and "The SELECT command is executed on the database" (an aggregate over @itab) - abaplint only reports the declaration, not the use'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'one activation of a consumer system on S/4HANA (2026-11-24) warned "The primary key of LT_... is ignored because it is generic or is the standard key" and "The SELECT command is executed on the database" - SELECT over a host table with the standard key, and an aggregate such as SELECT SUM( quan ) FROM @mt_stock'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: SELECT SUM( quan ) FROM @mt_stock (TYPE STANDARD TABLE ... WITH DEFAULT KEY) INTO @DATA(lv_menge) and SELECT * FROM @lt_plain (no key clause) - findings only at the declarations (avoid_use DEFAULT KEY, fully_type_itabs), none at the SELECT'
---

# SELECT FROM @itab: report a standard-key host table and a statement that goes to the database

```abap
TYPES ty_t_stock TYPE STANDARD TABLE OF ty_s_stock WITH DEFAULT KEY.
DATA mt_stock TYPE ty_t_stock.
...
SELECT SUM( quan ) FROM @mt_stock AS stock   " SLIN: primary key ... is ignored (standard key)
  INTO @DATA(lv_menge).                      " SLIN: The SELECT command is executed on the database
```

An internal table as a data source is read by the ABAP SQL engine when the
statement is simple enough; an aggregate, a join or a subquery sends the
table's content to the database and runs the statement there - a round trip
nobody reading the code expects. And a host table with a generic or standard
key has no key the engine can use.

**Proposal.** One rule over `FROM @itab` / `JOIN @itab`:

(a) report the host table when its primary key is the standard key or generic
(`WITH DEFAULT KEY`, no key clause on a local declaration, a generic type);

(b) report a statement over `@itab` that the ABAP SQL engine cannot run in
the application server - aggregate functions, `GROUP BY`, joins of two
sources, subqueries, as listed in the keyword documentation for
"internal tables as data source".

**Not reported.** A host table with an explicit key or `WITH EMPTY KEY` for
(a); a plain projection with `WHERE` for (b).

**Where.** a new rule beside `select_performance`. **Effort:** M.

**Source.** A consumer system, one activation on S/4HANA.
