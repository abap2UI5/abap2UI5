---
target: abaplint
title: 'downport: CONV #( ) for a generic formal parameter (clike) is declared as `TYPE undefined`'
summary: '`take( CONV #( lt_name[ 1 ] ) )` with `IMPORTING val TYPE clike` is downported into `DATA temp1 TYPE undefined.` - ABAP takes string as the type of # for a clike or csequence parameter; the 7.02 lint stays silent because `undefined` is outside the errorNamespace, and a 7.02 system refuses the class'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4513
first_seen: 2026-11-03
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/table-maintenance, 2026-11-03 - `z2ui5_cl_tm_pop`: `z2ui5_cl_tm_context=>rtti_get_data_element_texts( CONV #( mo_layout->ms_layout-t_layout[ fname = dfies->fieldname ]-rollname ) )`, the parameter is `val TYPE clike`; the published 702 form holds `DATA temp3 TYPE undefined.` and lints with 0 issues, the transpiler turns the declaration into a "Void type: UNDEFINED" runtime error'
  - 'probed 2026-11-03 with @abaplint/cli 2.120.92 - a single class, syntax v702, errorNamespace ^Z, rules downport, parser_error, check_syntax, unknown_types; `CLASS-METHODS take IMPORTING val TYPE clike` and `rv_ok = boolc( take( CONV #( lt_name[ 1 ] ) ) IS NOT INITIAL ).`: `abaplint --fix` writes `DATA temp1 TYPE undefined.`, the lint run reports 0 issues'
checked_upstream: 2026-11-03
---
# downport: CONV #( ) for a generic formal parameter is declared as `TYPE undefined`

```abap
CLASS-METHODS take IMPORTING val TYPE clike RETURNING VALUE(rv) TYPE string.
...
rv_ok = boolc( take( CONV #( lt_name[ 1 ] ) ) IS NOT INITIAL ).
```

becomes

```abap
DATA temp1 TYPE undefined.
...
temp1 = <temp2>.
rv_ok = boolc( take( temp1 ) IS NOT INITIAL ).
```

`undefined` is the downport's placeholder for a type it could not infer. The
lint after the downport does not report it - outside the errorNamespace the
name is void - so the 702 form looks clean and is refused on import.

**Expected.** The type ABAP infers for `#` at a generic formal parameter: for
`clike` and `csequence` it is `string` (likewise `c` -> the argument's own
`c` length, `numeric` -> `decfloat34`, `xsequence` -> `xstring`). Where the
downport still cannot infer a type, an issue instead of a silent placeholder.

**Workaround.** No `CONV #( )` at a generic parameter: `CONV string( ... )`,
or a typed variable.

Related: abaplint/abaplint#2337 (open, an implicit conversion in COND gives
the same undefined type) and #2984 (closed, "UNDEFINED not found").
