---
target: abaplint
title: 'Report an actual parameter that is not compatible with a by-reference IMPORTING parameter'
summary: 'a P(15,2) for a by-reference parameter TYPE decfloat34, an N(6) for the view builder''s v TYPE string - green in abaplint, "The type ... is not compatible with the type ... of ..." on the system'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4793
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/popups b2c33c3: a user''s pull (2026-11-24) refused z2ui5_cl_popup_sample_22->on_event with "The type "P(15.2)" of "ME->AMOUNT" is not compatible with the type "DECFLOAT34" of "I_VALUE"" - z2ui5_cl_popup_calculator=>factory( i_value TYPE decfloat34 OPTIONAL ) called with a packed amount. The fix typed the formal `numeric`'
  - 'abap2UI5-addons/table-maintenance 3751aca: the same day''s pull refused z2ui5_cl_tm_pop->render_popup three times with "The type "N(6)" of "DFIES->LENG" is not compatible with the type "STRING" of "V"" - `->a( n = `maxLength` v = dfies->leng )`, the view builder''s `a( v TYPE string )`. Fixed with `v = |{ CONV i( dfies->leng ) }|`'
  - 'probed 2026-11-24 against abaplint 2.120.113, check_syntax on, an isolated syntax-clean class: `take_str( df->leng )` with leng TYPE n LENGTH 6 and take_str IMPORTING v TYPE string - no finding; `take_dec( amount )` with `amount TYPE p LENGTH 15 DECIMALS 2` and `take_dec IMPORTING i_value TYPE decfloat34` - no finding'
---

# Report an actual parameter that is not compatible with a by-reference IMPORTING parameter

```abap
CLASS-METHODS take_dec IMPORTING i_value TYPE decfloat34 OPTIONAL.
...
DATA amount TYPE p LENGTH 15 DECIMALS 2.
take_dec( amount ).      " system: not compatible with the type DECFLOAT34 of I_VALUE

" the view builder: METHODS a IMPORTING n TYPE string v TYPE string OPTIONAL ...
view->a( n = `maxLength` v = dfies->leng ).   " leng TYPE n LENGTH 6 - not compatible
```

An IMPORTING parameter passed **by reference** (no `VALUE( )`) and typed
completely takes only a compatible actual parameter: same built-in type, same
length and decimals. The kernel refuses anything else at activation; there is
no conversion as for an assignment. abaplint's `check_syntax` accepts the call.

**Proposal.** In `check_syntax`: for a method call, an actual parameter that is
a data object (a variable, an attribute, a component - not an expression or a
literal) passed to a by-reference IMPORTING parameter with a complete
elementary type is reported when its type is not compatible - a different
built-in type (`p` to `decfloat34`, `i` to `p`, `c` to `string`) or the same
type with another length or number of decimals.

**Not reported.**

- a formal passed by value, `VALUE(i_value)` - the actual is converted;
- a generic formal (`numeric`, `clike`, `csequence`, `any`, `data`, `c` without
  length, `p` without decimals, ...);
- an expression, a functional call or a literal as the actual - the kernel
  creates a temporary of the formal's type for those;
- a typed data reference or an object reference (separate rules);
- CHANGING and EXPORTING (they have their own, stricter rules - a separate
  check, not this one).

**Where.** `check_syntax`, the method call parameter check. **Effort:** M.

**Source.** abap2UI5-addons/popups and table-maintenance, a user's activation on S/4HANA.

Related upstream: abaplint/abaplint#4675 (a functional method result passed to a structure, table or reference parameter) - another shape of the same parameter check; this one is an elementary data object for a by-reference parameter.
