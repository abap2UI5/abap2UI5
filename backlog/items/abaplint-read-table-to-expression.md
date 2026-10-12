---
target: abaplint
title: 'Replace READ TABLE with a table expression'
summary: 'READ TABLE … INTO plus sy-subrc check can be a table expression; abaplint has use_line_exists for the TRANSPORTING NO FIELDS form only'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on: no rule reports it'
---

# Replace READ TABLE with a table expression

```abap
READ TABLE lt_rows INTO DATA(ls_row) WITH KEY id = iv_id.
IF sy-subrc = 0.
  rv = ls_row-name.
ENDIF.
```

Instead:

```abap
rv = VALUE #( lt_rows[ id = iv_id ]-name OPTIONAL ).
```

**Proposal.** Report READ TABLE … INTO/ASSIGNING … WITH KEY/INDEX followed by a sy-subrc check that can be a table expression with VALUE #( … OPTIONAL ) or line_exists( ); quick fix only where the semantics are identical.

**Not reported.** READ TABLE … BINARY SEARCH, TRANSPORTING, COMPARING; reads whose not-found branch does more than skip (the exception differs: CX_SY_ITAB_LINE_NOT_FOUND instead of sy-subrc).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.
