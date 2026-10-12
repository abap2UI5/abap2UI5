---
target: abaplint
title: 'check_syntax: a predicate function used as a comparison operand'
summary: 'contains( ), contains_any_of( ), matches( ), line_exists( ) are predicates, not values - `contains( … ) = abap_true` is a syntax error on a system; abaplint at v750 is silent'
priority: high
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abap2xlsx/abap2xlsx 868c90f introduced `contains( … ) = abap_true`, 03faa95 fixed it as an ''urgent fix … syntax error'''
  - 'the seven current sites in abap2xlsx all carry the boolc( ) workaround'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# check_syntax: a predicate function used as a comparison operand

A predicate function returns a truth value, not a data object; it can stand alone in a condition or inside boolc( )/xsdbool( ), never as an operand of =.

```abap
IF contains( val = lv start = ` ` ) = abap_true.
```

Instead:

```abap
IF contains( val = lv start = ` ` ).
```

**Proposal.** Report a predicate function (contains, contains_any_of, contains_any_not_of, matches, line_exists) as either operand of a comparison.

**Not reported.** The same functions inside boolc( )/xsdbool( ) or standing alone as the condition.

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** S.

**Source.** abap2xlsx fix history.
