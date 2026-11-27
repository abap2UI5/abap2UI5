---
target: abaplint
title: 'A FOR variable and a later DATA( ) of the same name in one method are not reported'
summary: 'VALUE #( FOR total IN t ( ... ) ) followed by DATA(total) = ... in the same method - the system refuses "TOTAL was already declared"; abaplint 2.120.116 accepts it'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4790
first_seen: 2026-11-25
checked_upstream: 2026-11-25
upstream: abaplint/abaplint#4561
evidence:
  - 'a downstream app repository, review of 2026-11: a range built with VALUE ... ( FOR total IN t_totals ... ) and a DATA(total) = VALUE #( t_totals[ ... ] OPTIONAL ) further down in the same method; activation 2026-11-25: "TOTAL was already declared" (error) and "Field TOTAL obscures a global field with the same name" (warning); abaplint 2.120.116 with check_syntax on: no finding'
  - 'probed 2026-11-25 against abaplint 2.120.113: DATA(lt_m) = VALUE string_table( FOR row IN it_rows ( ... ) ). DATA(row) = VALUE #( it_rows[ 1 ] OPTIONAL ). - no finding'
  - 'upstream: abaplint/abaplint#4561 (closed) "check_syntax: FOR and LET local names, clash with data objects and reuse with a different type" - this shape (FOR first, inline DATA after) is still not reported in 2.120.116'
---

# A FOR variable and a later DATA( ) of the same name are not reported

```abap
DATA(r_matnr) = VALUE /scwm/tt_matnr_r( FOR total IN t_totals
                                        sign = `I` option = 'EQ' ( low = total-matnr ) ).
...
DATA(total) = VALUE #( t_totals[ matnr = r_out->matnr ] OPTIONAL ).  " system: already declared
```

## Proposal

`check_syntax`: a name declared by `FOR` (or `LET`) is declared for the rest
of the procedure; a later inline or `DATA` declaration of the same name is
an error, as on the system.
