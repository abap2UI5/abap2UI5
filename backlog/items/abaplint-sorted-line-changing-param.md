---
target: abaplint
title: 'Report a whole line of a sorted or hashed table, reached by a field symbol, passed to a CHANGING parameter'
summary: '`READ TABLE sorted_tab … ASSIGNING <row>.` then `meth( CHANGING cs = <row> )` activates, and on a system it is CX_SY_DYN_CALL_ILLEGAL_TYPE ("the actual parameter for CS is write-protected") - the line key is write-protected; abaplint reports nothing'
priority: high
state: open
first_seen: 2026-10-08
upstream: abaplint/abaplint
evidence:
  - abap2UI5-addons/admin-cockpit, 2026-10-08 - a user's first start of the cockpit, `z2ui5_cl_cockpit_stats` - "Call of the method ADD_SUM of the class Z2UI5_CL_COCKPIT_STATS has failed; the actual parameter for CS_SUM is write-protected" (CX_SY_DYN_CALL_ILLEGAL_TYPE, initial rendering); five sites in get_trend, get_apps, get_app_events, get_hints and get_window, each a `SORTED TABLE OF ty_s_sum WITH UNIQUE KEY …` read or inserted with `ASSIGNING <sum>` and passed as `CHANGING cs_sum = <sum>`; fixed in abap2UI5-addons/admin-cockpit#10 with a work area and `MODIFY TABLE`
  - measured 2026-10-08 on abaplint 2.120.64, every default rule on, `check_syntax` live - no finding on a minimal class with the same shape; the system's syntax check accepted the class too (it activated, the error came at run time)
  - measured 2026-10-08 on the transpiled runtime (admin-cockpit `npm run unit`) - the same shape as a test method passes, so the unit run cannot see it either
---

# Report a sorted- or hashed-table line passed by field symbol to a CHANGING parameter

## What happens

```abap
TYPES: BEGIN OF ty_s_sum,
         app TYPE c LENGTH 30,
         cnt TYPE i,
       END OF ty_s_sum.
TYPES ty_t_sum TYPE SORTED TABLE OF ty_s_sum WITH UNIQUE KEY app.

CLASS-METHODS add CHANGING cs_sum TYPE ty_s_sum.

DATA lt_sum TYPE ty_t_sum.
READ TABLE lt_sum WITH TABLE KEY app = lv_app ASSIGNING FIELD-SYMBOL(<sum>).
IF sy-subrc <> 0.
  INSERT VALUE #( app = lv_app ) INTO TABLE lt_sum ASSIGNING <sum>.
ENDIF.
add( CHANGING cs_sum = <sum> ).
```

The class activates. On a system, the call fails at run time:

```
An exception with the type CX_SY_DYN_CALL_ILLEGAL_TYPE was raised, but was not handled locally or declared in a RAISING clause.
Call of the method ADD of the class … has failed; the actual parameter for CS_SUM is write-protected
```

A field symbol on a line of a sorted or hashed table may change the
non-key components, but the key components are write-protected. The line as
a whole is therefore write-protected, and binding it to a `CHANGING`
parameter (which may write all of it) is refused when the call runs. The
callee does not have to touch the key: `add` above writes only `cnt`.

## Proposed rule

Report an actual parameter of a `CHANGING` parameter (and of an `EXPORTING`
parameter of the callee, written `IMPORTING` at the call) when it is a field
symbol that the same method assigned to a whole line of a table whose type is
statically known to be `SORTED` or `HASHED` - through `READ TABLE … ASSIGNING`,
`LOOP AT … ASSIGNING`, `INSERT … INTO TABLE … ASSIGNING` or
`ASSIGN itab[ … ] TO`. The message names the fix: read the line into a work
area, call with it, `MODIFY TABLE … FROM` the work area afterwards; or pass the
non-key components the callee needs.

## What it must NOT report

- A component of the line that is not part of the key: `CHANGING cv = <sum>-cnt`.
- The same pattern on a `STANDARD TABLE`, with or without a key: its key is not write-protected.
- A work area: `READ TABLE lt_sum … INTO ls_sum.` then `CHANGING cs_sum = ls_sum`.
- An `IMPORTING` parameter of the callee (`EXPORTING` at the call), which only reads.
- A field symbol typed generically or assigned from a table of unknown kind - nothing to decide statically.

To confirm on a system before it is filed: whether an `EXPORTING` parameter of
the callee fails the same way, and whether a table expression
(`CHANGING cs = lt_sum[ app = lv_app ]`) is refused at activation already.
Related, not the same: abaplint/abaplint#3041 (`APPEND` to a sorted or hashed
table).
