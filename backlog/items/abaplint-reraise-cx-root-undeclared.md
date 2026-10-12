---
target: abaplint
title: 'Report RAISE EXCEPTION of a cx_root-typed variable in a method without RAISING'
summary: '`CATCH cx_root INTO DATA(lx). … RAISE EXCEPTION lx.` - the static type could be a CX_STATIC_CHECK, so a system reports it as not caught or declared; CLEANUP is the shape that lets the exception travel on'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'a user''s system reported z2ui5_cl_ui5_http_handler=>_http_post (2026-09-02); abap-check §3'
  - 'measured 2026-10-11: abaplint 2.120.74 with check_syntax and uncaught_exception on reports nothing'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report RAISE EXCEPTION of a cx_root-typed variable in a method without RAISING

```abap
TRY.
    run( ).
  CATCH cx_root INTO DATA(lx).
    RAISE EXCEPTION lx.
ENDTRY.
```

**Proposal.** Report RAISE EXCEPTION <variable> whose static type is cx_root or cx_static_check (or another static-check class) when neither an enclosing CATCH nor the RAISING clause covers it - likely an extension of uncaught_exception.

**Not reported.** The same statement inside an outer CATCH cx_root.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2UI5 abap-check §3.
