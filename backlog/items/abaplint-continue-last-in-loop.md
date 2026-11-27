---
target: abaplint
title: 'Report CONTINUE as the last statement of a loop body'
summary: 'a CONTINUE directly before ENDLOOP/ENDDO/ENDWHILE/ENDSELECT does nothing - abapOpenChecks 062 "LOOP simplification" reports it, abaplint does not'
priority: low
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'ATC export of a consumer system on S/4HANA (2026-11-24), abapOpenChecks 062: 6 findings "CONTINUE as last statement in loop" - four in consumer classes, Z2UI5_CL_TM_001 and Z2UI5_CL_UI5_CLIENT'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated project with a control finding firing: LOOP AT it INTO DATA(lv_line). ... rv = rv && lv_line. CONTINUE. ENDLOOP. - no finding'
---

# Report CONTINUE as the last statement of a loop body

```abap
LOOP AT it INTO DATA(lv_line).
  IF lv_line IS INITIAL.
    CONTINUE.                 " fine - skips the rest
  ENDIF.
  rv = rv && lv_line.
  CONTINUE.                   " does nothing - the next iteration starts anyway
ENDLOOP.
```

A `CONTINUE` that is the last statement of the loop body - or the last
statement of the last branch of an `IF`/`CASE` that is itself last - has
nothing left to skip. It is dead code, often the remainder of a deleted
statement after it.

**Proposal.** Report a `CONTINUE` whose next statement, walking out of
enclosing `IF`/`ELSEIF`/`ELSE`/`CASE`/`WHEN` blocks, is the end of the loop
(`ENDLOOP`, `ENDDO`, `ENDWHILE`, `ENDSELECT`, `ENDPROVIDE`). Quick fix: delete
it. It is the loop twin of "RETURN as last statement" (abaplint/abaplint#439,
open).

**Not reported.** A `CONTINUE` followed by any statement in the loop body; one
in a branch that is not the last statement of the body; a `CONTINUE` outside a
loop (a syntax error, #3660).

**Where.** a new rule, or an option of the rule for #439. **Effort:** S.

**Source.** ATC on a consumer system (its own classes and the abap2UI5 addons installed
there).

Related upstream: abaplint/abaplint#439 (open - RETURN as last statement), #3660 (open - CONTINUE outside of a loop, a syntax check).
