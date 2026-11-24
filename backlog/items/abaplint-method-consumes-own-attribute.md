---
target: abaplint
title: 'Report a method that deletes from or clears the instance attribute it reads as its input'
summary: 'a getter like get_data( ) that DELETEs rows from the attribute holding its filters works once; the second call on the same instance runs with fewer filters and returns more data - nothing in the signature says the call consumes state'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11 - two selection classes (011, 014): get_data( ) reads its filter values from the attribute t_var_val and DELETEs from it, so a second get_data( ) on the same instance (a refresh) selects with fewer filters'
  - 'the same review: a literal ''VBLEN'' (for VBELN) in that code went unnoticed - a field name in a literal that a rule cannot judge without knowing what it names; context, not part of this rule'
  - 'abaplint 2.120.118: no rule tracks writes to an attribute a method also reads as input; searched abaplint/abaplint issues 2026-11-24 (importing parameter modified): abaplint/abaplint#2742 is about modifying IMPORTING parameters, a syntax error, not attributes'
---

# Report a method that deletes from or clears the instance attribute it reads as its input

```abap
METHOD get_data.                       " RETURNING VALUE(rt_data)
  LOOP AT t_var_val INTO DATA(ls_var) WHERE name = 'MATNR'.
    INSERT VALUE #( sign = 'I' option = 'EQ' low = ls_var-value ) INTO TABLE lr_matnr.
  ENDLOOP.
  DELETE t_var_val WHERE name = 'MATNR'.          " consumed - gone for the next call
  …
  SELECT … WHERE matnr IN @lr_matnr INTO TABLE @rt_data.
ENDMETHOD.
```

**Current behaviour.** Nothing reports it. The first call is right; a
refresh that calls the same method on the same instance selects without
the consumed filters - with an empty range, every row.

**Proposal.** Report a `DELETE itab`, `CLEAR`, `FREE` or `REFRESH` of an
instance attribute in a method that

- has a RETURNING parameter or a name starting with `get_` / `read_` /
  `select_` (configurable prefixes), and
- READS the same attribute earlier in the method (a `LOOP AT`, `READ
  TABLE`, a table expression, an `IN` operand).

Message: the method consumes its own input; a second call sees less. Work
on a local copy.

**Not reported.** A method whose name says it changes state (`reset_`,
`clear_`, `consume_`, `pop_` - configurable); a `DELETE` on a local copy
(`DATA(lt) = t_var_val.`); a static attribute used as a cache
(`CLASS-DATA`), where emptying is the point; an attribute written but not
read before.

**Where.** a new rule. **Effort:** M.

**Source.** a consumer system's selection classes.
