---
target: abaplint
title: 'Report a RETURNING parameter that is not assigned on some path'
summary: 'a method that leaves through an early RETURN (or falls off the end of a branch) without setting its RETURNING value hands the caller an initial value - or for a reference, nothing - and the caller has no way to tell that from a real result'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'a downstream app repository, review of 2026-11 - a selection class leaves a method through an early RETURN without setting its result object, so the caller works on initial data'
  - 'the backlog item abaplint-possibly-unbound-reference reports the dereference at the CALLER and needs this analysis of the callee as its first half'
  - 'abaplint 2.120.118: unnecessary_return, else_after_all_returns, prefer_returning_to_exporting and mix_returning look at RETURN and RETURNING, none at whether the result is assigned on every path; searched abaplint/abaplint issues 2026-11-24 (returning not assigned, returning value initial): nothing'
---

# Report a RETURNING parameter that is not assigned on some path

```abap
METHOD create_selection.
  IF iv_type IS INITIAL.
    RETURN.                                   " result stays initial
  ENDIF.
  CASE iv_type.
    WHEN 'A'. result = NEW lcl_sel_a( ).
    WHEN 'B'. result = NEW lcl_sel_b( ).
  ENDCASE.                                    " no WHEN OTHERS: initial for every other type
ENDMETHOD.
```

**Current behaviour.** Nothing reports it. For a value the caller gets an
initial value it cannot tell from a real one; for a reference it gets an
unbound reference and the dump happens in the caller
(`OBJECTS_OBJREF_NOT_ASSIGNED`), far from the cause.

**Proposal.** For a method with `RETURNING VALUE(r)`, walk the paths from
the start of the implementation to every exit (`RETURN`, `CHECK`, the end
of the method, an `EXIT`/`CHECK` outside a loop) and report the exit when
`r` is not written on at least one path to it. A write is an assignment
to `r` or a component of it, `CLEAR r` (explicit), `r` as an `INTO` /
`APPENDING` / `ASSIGNING` target, as an actual `EXPORTING`/`CHANGING`
parameter, or `NEW`/`CREATE OBJECT r`.

Option `references only` (default true): report only RETURNING parameters
typed `REF TO`, where an unassigned result is almost always a defect; a
value result that is initial on purpose (`rv_found` = false) is common.

**Not reported.** A path that ends in `RAISE EXCEPTION` / `RAISE` /
`MESSAGE … TYPE 'X'`; a method whose RETURNING is a boolean (abap_bool,
xsdboolean) under the default option; an exit preceded by a write in every
path.

**Where.** a new rule, `returning_not_assigned`. **Effort:** M.

**Source.** a consumer system's selection classes; the caller side is
`abaplint-possibly-unbound-reference`.
