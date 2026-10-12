---
target: abaplint
title: 'check_syntax: a built-in function as a READ TABLE … WITH KEY operand below 7.40'
summary: 'before 7.40 a built-in function in a READ TABLE … WITH [TABLE] KEY operand (`url = to_lower( iv )`) does not activate ("method TO_LOWER is unknown"); abaplint at v702 is silent, and the downport of line_exists( t[ k = to_upper( x ) ] ) produces exactly this shape'
priority: high
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit db22013 (#4038) and abap2UI5/abap2UI5 2674d0f (#2666) both fixed it after a 7.02/7.31 system refused the class'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# check_syntax: a built-in function as a READ TABLE … WITH KEY operand below 7.40

Below 7.40 the operand position of a READ key accepts functional method calls but not built-in functions.

```abap
READ TABLE lt_urls WITH KEY url = to_lower( iv_url ) TRANSPORTING NO FIELDS.
```

Instead:

```abap
DATA(lv_url) = to_lower( iv_url ).
READ TABLE lt_urls WITH KEY url = lv_url TRANSPORTING NO FIELDS.
```

**Proposal.** With syntax.version below v740, report a built-in function call in a WITH KEY / WITH TABLE KEY operand.

**Not reported.** Functional method calls (allowed); v740 and later.

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** S.

**Source.** abapGit and abap2UI5 fix history.
