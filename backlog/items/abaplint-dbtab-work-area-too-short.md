---
target: abaplint
title: 'check_syntax: INSERT / MODIFY / UPDATE dbtab FROM a work area shorter than the table line'
summary: '`MODIFY ztab FROM @ls` with a structure that lacks MANDT is "The work area LS is not long enough" on a system - the class does not compile; abaplint reports nothing'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4388
first_seen: 2026-10-06
upstream: abaplint/abaplint
evidence:
  - abap2UI5-addons/admin-cockpit, 2026-10-06 - a user's pull, `z2ui5_cl_cockpit_setup->row_save` @5 and `->salt_of_day` @26 - "The work area "LS_ROW" is not long enough." for `MODIFY z2ui5_t_ck_set FROM @ls_row` and `INSERT z2ui5_t_ck_set FROM @ls_row`, `ls_row` of a local type with NAME (c 30) and VALUE (c 255) and the client-dependent table MANDT + NAME + VALUE; the class had a syntax error, and every abap2UI5 request dumped with "Syntax error in program Z2UI5_CL_COCKPIT_SETUP" because the roundtrip monitor used it; fixed in abap2UI5-addons/admin-cockpit#6
  - measured 2026-10-06 on abaplint 2.120.64 with `check_syntax` on - no finding on either statement
---

# check_syntax: a database work area shorter than the table line

## What happens

```abap
TYPES:
  BEGIN OF ty_s_row,
    name  TYPE c LENGTH 30,
    value TYPE c LENGTH 255,
  END OF ty_s_row.
DATA(ls_row) = VALUE ty_s_row( name = `A` value = `B` ).
MODIFY z2ui5_t_ck_set FROM @ls_row.   " table: MANDT, NAME, VALUE
```

On a system: *The work area "LS_ROW" is not long enough.*, a syntax error of
the class. `INSERT`, `UPDATE` and `MODIFY dbtab FROM wa` take the work area as
the table line: it must be at least as long as the line, client field included,
whether or not the client is handled automatically. A structure that names
only the non-client columns is shorter by the length of MANDT.

## Proposed check

In `check_syntax`, for `INSERT dbtab FROM wa`, `UPDATE dbtab FROM wa`,
`MODIFY dbtab FROM wa` (and the `@` forms) where the table is known from the
DDIC: report when the work area is a flat structure whose length is smaller
than the table's line length. The cheap and common case is a structure that
lacks the client field of a client-dependent table.

## What it must NOT report

- A work area typed as the table (`DATA ls TYPE ztab`, `VALUE ztab( … )`).
- A work area longer than the line.
- `INSERT dbtab FROM TABLE itab` with a row type of the table.
- A table the registry does not know (no DDIC object): nothing to compare.
