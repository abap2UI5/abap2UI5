---
target: abaplint
title: 'Report READ / DELETE / MODIFY TABLE itab FROM wa on a table WITH EMPTY KEY'
summary: 'DELETE TABLE lt FROM ls. on a table WITH EMPTY KEY removes the first row each time, since there is no key to compare - found at runtime, nothing reports it; sort_empty_key covers SORT and DELETE ADJACENT DUPLICATES only'
priority: medium
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/popups 7746a51, 2026-11, the data element search popup: "DELETE TABLE ... FROM on a table WITH EMPTY KEY, which removes the first line each time - only odd languages survived"; found at runtime with CI green (the commit is a squash, the shape below is rebuilt from its text and the comment in the source)'
  - 'probed 2026-11-27 against abaplint main after 2.120.122 with every default rule on: neither DELETE TABLE lt FROM ls nor READ TABLE lt FROM ls on a table WITH EMPTY KEY is reported'
---

# Key access with a work area on a table `WITH EMPTY KEY`

```abap
DATA lt TYPE STANDARD TABLE OF ty_s WITH EMPTY KEY.

LOOP AT it INTO DATA(ls).
  DELETE TABLE lt FROM ls.     " removes row 1 every time
ENDLOOP.
```

`... TABLE itab FROM wa` and `... WITH TABLE KEY` address a row through the
primary table key. With an empty key there is nothing to compare, so the
first row is the match.

## Proposal

Extend `sort_empty_key` (or add a rule next to it) to report
`READ TABLE itab FROM wa`, `DELETE TABLE itab FROM wa`,
`MODIFY TABLE itab FROM wa` and the `WITH TABLE KEY` forms when the primary
key of the table is statically empty.

## Must not report

A table with the default key or an explicit key; sorted and hashed tables;
generic or unknown types; `USING KEY <secondary key>`; a free key
(`WITH KEY comp = ...`); `DELETE itab WHERE ...`; `DELETE itab INDEX ...`.
