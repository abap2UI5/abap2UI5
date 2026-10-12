---
target: abaplint
title: 'Report classes over configured counts of methods, attributes, events, interfaces or output parameters'
summary: 'code-pal counts methods, attributes, events, implemented interfaces and output parameters per class; abaplint has method_length and cyclomatic_complexity but no class-level counts'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap checks number-methods, number-attributes, number-events, number-interfaces, number-output-parameter (SAP/code-pal-for-abap docs/checks/number-*.md)'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
---

# Report classes over configured counts of methods, attributes, events, interfaces or output parameters

```abap
a class with 60 methods
```

**Proposal.** One rule with thresholds per count (methods, attributes, events, interfaces, EXPORTING+CHANGING parameters per method); each 0 = off.

**Not reported.** Exception classes, test classes (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap checks number-methods, number-attributes, number-events, number-interfaces, number-output-parameter.
