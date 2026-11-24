---
target: abaplint
title: 'Report a direct assignment of TIMESTAMPL to TIMESTAMP'
summary: 'the assignment rounds and can produce second 60; SLIN warns'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'sbcgua/ajson 5e8de3f, 33d6180 (#128), 075a09b'
  - 'abap2UI5/abap2UI5 7c8d64c (#2855: ''rounding it into second 60'')'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'oblomov-dev/s5s_dev 3173ec5: one activation of the S5S DEV state on an S/4HANA EWM system (2026-11-24) warned about TIMESTAMPL assigned to the short time stamp at 10 sites, among them targets typed with DDIC aliases of the short type (TZNTSTMPS, TSEGEVTFRS, TSEGEVTTOS) and a method-call source ts = get_timestampl( )'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: lv_ts = lv_tsl, lv_ts = get_l( ) (RETURNING TYPE timestampl) and the same into a type p LENGTH 8 DECIMALS 0 standing in for TZNTSTMPS - no finding'
---

# Report a direct assignment of TIMESTAMPL to TIMESTAMP

```abap
DATA lv_ts TYPE timestamp.
lv_ts = lv_tsl.
```

**Proposal.** Report an assignment whose source is typed timestampl and whose target timestamp.

The source is not always a variable, and the target not always called
`timestamp` (S5S, a consumer system, 2026-11-24, 10 sites):

```abap
DATA lv_ts TYPE tzntstmps.        " also TSEGEVTFRS, TSEGEVTTOS - P(15,0) like TIMESTAMP
lv_ts = get_timestampl( ).        " RETURNING VALUE(r) TYPE timestampl
```

So the rule decides on the types, not the names: a source of type P(21,7)
(TIMESTAMPL and its aliases - a variable, a component, a functional method
call) into a target of type P(15,0) (TIMESTAMP, TZNTSTMPS and every other data
element on that domain).

**Not reported.** cl_abap_tstmp=>move_to_short; explicit truncation.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** ajson, abap2UI5 fix history.
