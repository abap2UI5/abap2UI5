---
target: abaplint
title: 'Report a test that expects an exception but never calls fail( )'
summary: '`TRY. call( ). CATCH zcx. ENDTRY.` in a FOR TESTING method passes when nothing is raised'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report a test that expects an exception but never calls fail( )

```abap
TRY.
    cut->run( ).
  CATCH zcx_error.
ENDTRY.
```

**Proposal.** In FOR TESTING methods report TRY blocks whose CATCH is empty or only asserts and whose TRY part has no cl_abap_unit_assert=>fail( ) after the call.

**Not reported.** Tests that assert in the TRY part.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** Clean ABAP 'Use FAIL to check for expected exceptions'.
