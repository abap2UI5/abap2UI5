---
target: abaplint
title: 'The 702 downport drops OPTIONAL from REF #( itab[ ... ] OPTIONAL )'
summary: 'REF #( itab[ k = 1 ] OPTIONAL ) is lowered to READ TABLE ... ASSIGNING + RAISE EXCEPTION TYPE cx_sy_itab_line_not_found - a row that is not found aborts on 7.02 where the source returns an initial reference'
priority: high
state: open
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint
evidence:
  - 'reproduced 2026-11-25 with abaplint 2.120.120, rule downport, syntax v702: r = REF #( it[ k = 1 ] OPTIONAL ). becomes READ TABLE it WITH KEY k = 1 ASSIGNING <temp1>. IF sy-subrc <> 0. RAISE EXCEPTION TYPE cx_sy_itab_line_not_found. ENDIF. GET REFERENCE OF <temp1> INTO r. - after syfixes ASSERT 1 = 0'
  - 'found in the popups 702 output while READ TABLE was forbidden across the abap2UI5 repositories; six existing sites in samples, layout-management and table-maintenance were rewritten to ASSIGN itab[ ... ] TO <fs> (samples a038a2d, layout-management b7fba83, table-maintenance 8325956)'
  - 'VALUE #( itab[ ... ] OPTIONAL ) is lowered correctly (the not-found branch clears the target)'
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

## Workaround

`ASSIGN itab[ ... ] TO <fs>` with `IS ASSIGNED`, or `line_exists( )` before
`REF #( itab[ ... ] )` (abap-check, section 4).
