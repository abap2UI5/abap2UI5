---
target: abaplint
title: 'Report SORT / DELETE ADJACENT DUPLICATES without BY / COMPARING on a table with an empty primary key'
summary: '`SORT itab.` on a `WITH EMPTY KEY` table is the syntax-check warning "… is a table with an empty primary key" and sorts nothing; abaplint reports nothing'
priority: medium
state: open
first_seen: 2026-10-06
upstream: abaplint/abaplint
evidence:
  - abap2UI5-addons/admin-cockpit, 2026-10-06 - a user's pull, `z2ui5_cl_cockpit_inst->get_implementers` lines 23 and 24 - ""RESULT" is a table with an empty primary key. Check the semantics of the statement." for `SORT result.` and `DELETE ADJACENT DUPLICATES FROM result.`, `result` typed `STANDARD TABLE OF string WITH EMPTY KEY`; fixed with `BY table_line` / `COMPARING table_line`
  - measured 2026-10-06 on abaplint 2.120.70, every default rule on - no finding on either statement
---

# Report SORT / DELETE ADJACENT DUPLICATES on a table with an empty primary key

## What happens

```abap
TYPES ty_t_names TYPE STANDARD TABLE OF string WITH EMPTY KEY.
DATA result TYPE ty_t_names.
SORT result.                              " warning: empty primary key
DELETE ADJACENT DUPLICATES FROM result.   " warning: empty primary key
```

Without `BY` or `COMPARING`, both statements use the primary key. An empty
key makes `SORT` a no-op and `DELETE ADJACENT DUPLICATES` compare nothing.
The syntax check warns: *""RESULT" is a table with an empty primary key.
Check the semantics of the statement."*

## Proposed rule

Report `SORT itab` without `BY` and `DELETE ADJACENT DUPLICATES FROM itab`
without `COMPARING` when the table's primary key is empty. Quick fix:
`BY table_line` / `COMPARING table_line` for a table of an elementary type.

## What it must NOT report

- `SORT result BY table_line.` and `DELETE ADJACENT DUPLICATES FROM result COMPARING table_line.`
- A table with a default or explicit key, including the implicit default key of `TYPE TABLE OF x`.
- A sorted or hashed table: their key is never empty.
