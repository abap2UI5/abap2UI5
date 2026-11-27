---
target: abaplint
title: 'Report CONV #( ) of a non-character operand into a generic formal - the fixed type STRING is used'
summary: 'add_msg( v1 = CONV #( lv_quan ) ) with v1 TYPE clike and lv_quan TYPE p - SLIN "The fixed type STRING is used for the generic type CLIKE"; inline_generic_source covers only DATA( )'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'one activation of a consumer system on S/4HANA (2026-11-24) warned "The fixed type STRING is used for the generic type CLIKE" on add_msg( v1 = CONV #( lv_quan ) ) with a packed quantity. Fixed with CONV string( )'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: add_msg IMPORTING v1 TYPE clike OPTIONAL, DATA lv_menge TYPE p LENGTH 7 DECIMALS 3, add_msg( v1 = CONV #( lv_menge ) ) - no finding (only omit_parameter_name)'
---

# Report CONV #( ) of a non-character operand into a generic formal - the fixed type STRING is used

```abap
METHODS add_msg IMPORTING v1 TYPE clike OPTIONAL.
...
DATA lv_menge TYPE p LENGTH 7 DECIMALS 3.
add_msg( v1 = CONV #( lv_menge ) ).    " SLIN: The fixed type STRING is used for the generic type CLIKE
add_msg( v1 = CONV string( lv_menge ) ).   " fine
```

`#` has to pick a type, and a generic formal does not give one. For a
character-like operand the result is the operand's type (and the CONV is
redundant - abaplint-redundant-conversion-gaps); for a packed, integer or
date operand the kernel picks a fixed type, STRING for `clike`/`csequence`,
and warns about the pick. `inline_generic_source` reports the same pick for
`DATA(x) = generic_param`; nothing reports it for `CONV #( )`.

**Proposal.** Report `CONV #( operand )` as the actual parameter of a formal
with a generic type (`clike`, `csequence`, `simple`, `numeric` ...) when the
operand's type is not itself of that generic kind. The quick fix writes the
type the kernel picks, `CONV string( )` for `clike`/`csequence`.
Natural home: `inline_generic_source` (the same kernel decision).

**Not reported.** `CONV #( )` into a complete formal type; `CONV <type>( )`;
a character-like operand into `clike` (that is a redundant CONV, a separate
rule).

**Where.** `inline_generic_source`. **Effort:** S.

**Source.** A consumer system, one activation on S/4HANA.
