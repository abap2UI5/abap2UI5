---
target: abaplint
title: 'The 702 downport drops the not-found case: REF #( itab[ ... ] OPTIONAL ) and a bare line_index( )'
summary: 'REF #( itab[ k = 1 ] OPTIONAL ) is lowered to READ TABLE ... ASSIGNING + RAISE EXCEPTION TYPE cx_sy_itab_line_not_found - a row that is not found aborts on 7.02 where the source returns an initial reference'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4820
first_seen: 2026-11-25
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'reproduced 2026-11-25 with abaplint 2.120.120, rule downport, syntax v702: r = REF #( it[ k = 1 ] OPTIONAL ). becomes READ TABLE it WITH KEY k = 1 ASSIGNING <temp1>. IF sy-subrc <> 0. RAISE EXCEPTION TYPE cx_sy_itab_line_not_found. ENDIF. GET REFERENCE OF <temp1> INTO r. - after syfixes ASSERT 1 = 0'
  - 'found in the popups 702 output while READ TABLE was forbidden across the abap2UI5 repositories; six existing sites in samples, layout-management and table-maintenance were rewritten to ASSIGN itab[ ... ] TO <fs> (samples a038a2d, layout-management b7fba83, table-maintenance 8325956)'
  - 'VALUE #( itab[ ... ] OPTIONAL ) is lowered correctly (the not-found branch clears the target)'
  - 'samples-controls 2026-11-25: x = line_index( itab[ ... ] ) is lowered to READ TABLE ... followed by temp = sy-tabix without a sy-subrc check - a row that is not found yields the sy-tabix of an earlier statement instead of 0; written as IF line_exists( ... ) first (samples-controls 3c7f86d); the bare form exists on samples-controls main (e.g. samples 645, 569)'
  - 'abaplint/abaplint#4797 (merged 2026-11-27, after 2.120.122) adds the downport option tableExpressionNotFound - the statement written into the not-found branch, so a 7.02 system gets something that compiles; it does not change which expressions get that branch. Probed 2026-11-27 against abaplint main: r = REF #( it[ k = 1 ] OPTIONAL ) still becomes READ TABLE ... ASSIGNING <temp1>. IF sy-subrc <> 0. RAISE EXCEPTION TYPE cx_sy_itab_line_not_found. ENDIF. GET REFERENCE OF <temp1> INTO r., and x = line_index( it[ k = 1 ] ) still becomes READ TABLE ... TRANSPORTING NO FIELDS. temp1 = sy-tabix. without a sy-subrc check - both halves of this item are open'
  - 'filed 2026-11-27 as abaplint/abaplint#4820, both halves: REF #( tab[ ... ] OPTIONAL ) clears the target in an ELSE in place of the RAISE, line_index( ) is 0 when sy-subrc is not 0'
---

# The 702 downport drops OPTIONAL from `REF #( itab[ ... ] OPTIONAL )`

```abap
r = REF #( it[ k = 1 ] OPTIONAL ).
```

is downported to

```abap
READ TABLE it WITH KEY k = 1 ASSIGNING <temp1>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
GET REFERENCE OF <temp1> INTO r.
```

## Proposal

Lower the OPTIONAL form like the `VALUE #( ... OPTIONAL )` one: on
`sy-subrc <> 0` clear the target reference instead of raising, and only take
the reference when the row was found. A `DEFAULT` variant needs the default's
reference.

## The same for line_index( )

`x = line_index( itab[ k = 1 ] )` becomes `READ TABLE itab WITH KEY k = 1
TRANSPORTING NO FIELDS. temp = sy-tabix.` - on 7.50 the function returns 0
for a row that is not found, on 7.02 the result is whatever `sy-tabix` held.
Lower it with `IF sy-subrc = 0` around the assignment, else 0.

## Workaround

`ASSIGN itab[ ... ] TO <fs>` with `IS ASSIGNED`, or `line_exists( )` before
`REF #( itab[ ... ] )` (abap-check, section 4); `line_index( )` only after
`line_exists( )`.
