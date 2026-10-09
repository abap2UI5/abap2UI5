---
target: abaplint
title: 'downport: NEW into a data reference becomes CREATE DATA, not CREATE OBJECT'
summary: '`mr = NEW #( `x` )` with `mr TYPE REF TO string` is downported to `CREATE OBJECT mr ClassDefinitionNotFound ERROR.` - no statement at all, a parser error on every downported 702 branch; without a value it is a plain `CREATE OBJECT mr`, which check_syntax refuses there'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4404
first_seen: 2026-10-09
upstream: abaplint/abaplint
evidence:
  - abap2UI5, 2026-10-09 - a test class of `z2ui5_cl_ui5_serializer` created data with `NEW`; valid at v750, and `npm run downport` ended red on the parser error in the downported tree (abap-check section 4, "`NEW` builds objects, `CREATE DATA` builds data")
  - reproduced 2026-10-09 on abaplint main 8db4281 (2.120.71) in an isolated project, `downport`, `check_syntax` and `parser_error` on, v702 - `mr = NEW #( `x` )` and `md = NEW string( `y` )` (md TYPE REF TO data) both come out as `CREATE OBJECT … ClassDefinitionNotFound ERROR.`
  - filed 2026-10-09 as abaplint/abaplint#4404 - CREATE DATA plus the value through the reference (a field symbol for a generic one); the snippet then downports to code check_syntax at v702 accepts, and abap2UI5's whole downport is byte-identical to 2.120.71
---

# downport: NEW into a data reference becomes CREATE DATA

```abap
DATA mr TYPE REF TO string.
DATA md TYPE REF TO data.
mr = NEW #( `x` ).
md = NEW string( `y` ).
```

`downport` (v702) wrote `CREATE OBJECT mr ClassDefinitionNotFound ERROR.` and
`CREATE OBJECT md TYPE string ClassDefinitionNotFound ERROR.`. `newParameters`
assumes NEW builds an object. With the change in abaplint/abaplint#4404:

```abap
CREATE DATA mr.
mr->* = `x`.
FIELD-SYMBOLS <temp1> TYPE any.
CREATE DATA md TYPE string.
ASSIGN md->* TO <temp1>.
<temp1> = `y`.
```
