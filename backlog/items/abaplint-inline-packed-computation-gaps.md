---
target: abaplint
title: 'inline_packed_computation: a parenthesised right-hand side and a VALUE operand are not reported'
summary: 'DATA(x) = ( a + b ). and DATA(t) = a + VALUE #( lt[ 1 ]-quan OPTIONAL ). get type P(8,0) on the system and lose their decimals - the rule reports a - b, a * b, a + b and meth( ) + b, not these'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4792
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 3173ec5: one activation of the S5S DEV state on an S/4HANA EWM system (2026-11-24) warned "For the result of a computation with type P, the type P(8,0) is used here implicitly" on /KRO/UI502_CL_SHIPMENT_HANDLER->get_shipment_infos and /KRO/UI502_CL_APP_002->will_shipment_be_overloaded - weights and quantities with three decimals, so a difference below 0.5 counted as none'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: with ty_quan TYPE p LENGTH 7 DECIMALS 3 - reported: DATA(d) = a - b, a * b, a + b, get_weight( ) + b; NOT reported: DATA(s) = ( a + b )., DATA(t) = get_weight( ) + ( VALUE #( lt[ 1 ]-quan OPTIONAL ) )., DATA(t) = b + VALUE #( lt[ 1 ]-quan OPTIONAL ).'
---

# inline_packed_computation: a parenthesised right-hand side and a VALUE operand are not reported

```abap
TYPES ty_quan TYPE p LENGTH 7 DECIMALS 3.
DATA lv_menge TYPE ty_quan.

DATA(lv_diff)  = ls_row-quan - lv_menge.                                  " reported
DATA(lv_sum)   = ( ls_row-quan + lv_menge ).                              " NOT reported - P(8,0)
DATA(lv_total) = get_weight( ) + ( VALUE #( lt_row[ 1 ]-quan OPTIONAL ) ). " NOT reported - P(8,0)
DATA(lv_tot3)  = lv_menge + VALUE #( lt_row[ 1 ]-quan OPTIONAL ).          " NOT reported - P(8,0)
```

All four are the same thing to the kernel: an arithmetic expression with
packed operands, whose inline target falls back to P(8,0). The decimals are
cut off without notice - in the evidence a shipment weight difference below
0.5 kg counted as no difference. `inline_packed_computation` (from #4407 /
#4413) recognises the expression only when the right-hand side is a bare
arithmetic chain of plain operands and method calls: brackets around the
whole right-hand side, or a `VALUE #( ... )` (`CONV`, `COND` ...) operand
inside the chain, hide it.

**Proposal.** Unwrap redundant brackets around the right-hand side before the
check, and type a constructor operand by its inferred type (`VALUE #( itab[ ]-comp
OPTIONAL )` is the component's type) instead of giving up on it. The finding
and the quick fix stay as they are.

**Not reported.** `DATA(x) = CONV ty_quan( a + b ).`; `DATA(x) = ( a ).`
(no computation); an expression with an integer or decfloat operand that
decides the calculation type; `COND #( ... THEN packed ... )`.

**Where.** `inline_packed_computation`. **Effort:** S.

**Source.** S5S (a consumer system), one activation on S/4HANA.

Related upstream: abaplint/abaplint#4407 (closed - the collection the rule came from, item 6).
