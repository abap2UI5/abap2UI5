---
target: abaplint
title: 'Report empty ABAP Doc - a @parameter without text, a lone "! before the declaration'
summary: '"! @parameter client | with nothing after the bar, or a "! line that is the whole comment or ends it - SLIN "Empty documentation is not allowed", abaplint reports only MISSING ABAP Doc'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'oblomov-dev/s5s_dev 3173ec5: one activation of the S5S DEV state on an S/4HANA EWM system (2026-11-24) warned "Empty documentation is not allowed" about 20 times on /KRO/UI501_CL_APP_VIEW, and on /KRO/UI501_CL_APP_007 and /KRO/UI502_CL_APP_002 - "! @parameter <name> | with no text, a lone "! in front of CLASS, and a "! line ending a block'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: a lone "! in front of CLASS and "! @parameter client | - no finding (abapdoc, check_syntax, wrong_abapdoc_position all on)'
---

# Report empty ABAP Doc - a @parameter without text, a lone "! before the declaration

```abap
"!
CLASS zcl_doc DEFINITION PUBLIC FINAL CREATE PUBLIC.   " SLIN: Empty documentation is not allowed
  PUBLIC SECTION.
    "! Does something
    "!
    "! @parameter client |                              " SLIN: Empty documentation is not allowed
    "! @parameter result | the result
    METHODS run
      IMPORTING client TYPE i
      RETURNING VALUE(result) TYPE i.
```

The system reads an ABAP Doc comment that documents nothing as an error of the
documentation: a `@parameter` (`@raising`, `@exception`) whose text after
the bar is empty, a comment that consists of `"!` lines only, and a trailing
`"!` that closes the block. `abapdoc` reports a declaration that has NO ABAP
Doc; it is silent about one that has an empty one - which is what an editor
template or a generator leaves behind.

**Proposal.** An option of `abapdoc` (or a check in the ABAP Doc rule family
of #4385): report

1. `"! @parameter <name> |` (and `@raising`, `@exception`) with nothing but
   blanks after the bar;
2. an ABAP Doc block all of whose lines are empty;
3. an empty `"!` that is the last line of the block, directly in front of the
   declaration.

**Not reported.** An empty `"!` used as a separator inside a block, between
two lines with text (the summary line and the `@parameter` lines above - the
system accepts it).

**Where.** `abapdoc`, or a new `abapdoc_empty`. **Effort:** S.

**Source.** S5S (a consumer system), one activation on S/4HANA.

Related upstream: abaplint/abaplint#4385 (ABAP Doc checks a system warns about - position, `@` lines, tags; empty documentation is not among them), #4690 (rules that report syntax errors).
