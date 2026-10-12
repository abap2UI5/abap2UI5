---
target: abaplint
title: 'Report global classes without a local test class (configurable)'
summary: 'a class with logic and no testclasses include is untested by construction'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report global classes without a local test class (configurable)

```abap
zcl_calc.clas.abap without zcl_calc.clas.testclasses.abap
```

**Proposal.** Report a global class with at least one non-trivial method and no FOR TESTING class; options for exception classes, interfaces, abstract classes.

**Not reported.** Exception classes, constant classes, classes with only getters (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.
