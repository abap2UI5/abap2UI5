---
target: abaplint
title: 'Report MESSAGE TYPE E/A/X and WRITE in methods of global classes'
summary: 'in HTTP, RFC or background contexts (abap2UI5 requests) a MESSAGE TYPE E/A/X aborts the request or dumps (MESSAGE_TYPE_X); classes should raise exceptions'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report MESSAGE TYPE E/A/X and WRITE in methods of global classes

```abap
METHOD read.
  MESSAGE e001(zmsg).
ENDMETHOD.
```

**Proposal.** Report MESSAGE without RAISING of type E, A or X, and WRITE, in global class methods.

**Not reported.** MESSAGE … INTO; MESSAGE … RAISING; type S/I/W.

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** abapOpenChecks 57; Clean ABAP.
