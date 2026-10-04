---
target: open-abap
title: 'transpiler: SORT ... BY (name) drops the dynamic component'
summary: '`SORT lt BY (lv_name)` transpiles to `abap.statements.sort(lt,{})` - the dynamic component is dropped, a table with an empty key stays unsorted and nothing reports it'
priority: medium
state: filed
filed: https://github.com/abaplint/transpiler/pull/1960
first_seen: 2026-10-03
upstream: abaplint/transpiler
evidence:
  - abap2UI5#2403 - `SORT itab BY (dynamic)` "not supported" in the transpiled unit run; `z2ui5_cl_util=>itab_sort_by` rewritten as a static sort over a helper table
  - abap2UI5/samples-controls#143 - apps 298, 362 and 571 showed unsorted tables in the transpiled build
  - measured 2026-10-03 on transpiler main 6de459a - `SORT lt BY (lv_name) DESCENDING` gives the rows in insertion order, the generated call is `abap.statements.sort(lt,{})`; the static `SORT lt BY a DESCENDING` is correct
  - filed 2026-10-03 as abaplint/transpiler#1960 - the BY list takes Dynamic nodes, the name from a literal or a character-like field at runtime; three runtime tests, all failing on main; a sort order table (abap_sortorder_tab) is left as it is
---

# transpiler: SORT ... BY (name) drops the dynamic component

## What happens

```abap
DATA(lv_name) = `A`.
SORT lt BY (lv_name) DESCENDING.
```

The transpiler reads only static `ComponentChain` nodes in the BY list. The
`Dynamic` node is skipped, so the call carries no `by` and sorts by the primary
key, or not at all with an empty key.

## How it is filed

abaplint/transpiler#1960. `z2ui5_cl_util=>itab_sort_by` can go back to a plain
`SORT … BY (name)` once a transpiler release carries it.
