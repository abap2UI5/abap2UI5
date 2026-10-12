---
target: abaplint
title: 'Report CONV whose target already has the type (redundant_conversion option)'
summary: '`lv_i = CONV i( x )` into lv_i TYPE i is "Redundant conversion for type I" in SLIN; redundant_conversion only reports a CONV whose OPERAND already has the type'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'a user''s system reported nine findings in abap2UI5/samples-controls (2026-08-23); abap2ui5lint''s redundant-conv-i reproduced them and found four more'
  - 'a user''s system reported CONV string( ) in z2ui5_cl_ui5_util_context (2026-09-03)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report CONV whose target already has the type (redundant_conversion option)

```abap
DATA lv_i TYPE i.
lv_i = CONV i( client->get_event_arg( ) ).
```

**Proposal.** Option of redundant_conversion: report a CONV that is the whole right-hand side of an assignment into a target of the same type.

**Not reported.** CONV in comparisons, arithmetic, string templates; generic operands (the CONV fixes the type).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2UI5 abap-check §3.
