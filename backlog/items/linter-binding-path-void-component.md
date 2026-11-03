---
target: abap2ui5-linter
title: 'unknown-binding-path: a row component with a void type is reported as missing'
summary: 'a table row declared `gname TYPE seqg3-gname` - an explicit component whose type the linter cannot resolve (an on-premise DDIC structure outside the dependencies) - is dropped from the row, so every binding to it ({GNAME}) is reported as "the rows have no such field (silently empty)"; the field is there, only its type is unknown'
priority: medium
state: open
first_seen: 2026-11-03
upstream: abap2UI5/linter
evidence:
  - 'abap2UI5-addons/lock-manager, 2026-11-03 - moving @abap2ui5/linter 0.8.5 -> 0.9.0: nine unknown-binding-path warnings in z2ui5_cl_lock_app_sm12 on {GNAME}, {GARG}, {GUNAME}, {GMODE}, {GCLIENT}, ... of {/MT_LOCKS}, whose row type ty_lock_row declares each of them as `<name> TYPE seqg3-<name>`; SEQG3 is not in the dependency the repository lints with. Frozen in abap2ui5lint-baseline.json as the workaround'
  - 'checked 2026-11-03 on a copy: changing only `gname TYPE seqg3-gname` to `gname TYPE string` makes the {GNAME} warning go away and leaves the other eight'
checked_upstream: 2026-11-03
---
# unknown-binding-path: a row component with a void type is reported as missing

```abap
TYPES:
  BEGIN OF ty_lock_row,
    gname TYPE seqg3-gname,
    garg  TYPE seqg3-garg,
  END OF ty_lock_row,
  ty_lock_rows TYPE STANDARD TABLE OF ty_lock_row WITH EMPTY KEY.
DATA mt_locks TYPE ty_lock_rows.
...
)->text( text = `{GNAME}` )
```

With SEQG3 unknown to the linter (an on-premise structure, outside the
dependency the repository lints with), `unknown-binding-path` reports
`sap.m.Text text="{GNAME}" — the rows of {/MT_LOCKS} have no such field
(silently empty)`. The component exists - it is declared by name in the
source; only its type is void.

**Expected.** A component whose name is known and whose type is not stays in
the row with an unknown type: a binding to it is not reported (a binding into
it - `{GNAME/SUB}` - cannot be decided either). Only a name that is not
declared at all is a missing field.

**Scope.** The same for a whole row type that is void (`TYPE STANDARD TABLE
OF seqg3`): nothing can be said about its fields, so nothing should be
reported - the rule should treat it like a binding into a generic reference.
