---
target: abaplint
title: 'Size metrics: methods, attributes, events, interfaces, output parameters per class, statements per WHEN'
summary: 'counts code-pal and abapOpenChecks report - members per class and statements per WHEN block - with a threshold each, next to the existing method_length and cyclomatic_complexity'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap checks number-methods, number-attributes, number-events, number-interfaces, number-output-parameter (SAP/code-pal-for-abap docs/checks/number-*.md)'
  - 'checked 2026-10-12 against the rule sources of abaplint main after v2.120.75 (an XML or cross-object check, not probed with a snippet): no rule decides it'
  - 'abapOpenChecks check 034 (larshp/abapOpenChecks docs/_checks/34.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Size metrics: methods, attributes, events, interfaces, output parameters per class, statements per WHEN

One rule with one threshold per count (0 = off); could also be options of method_length.

Merged on 2026-10-12 from the items `abaplint-class-size-metrics`, `abaplint-when-block-length`.

## Report classes over configured counts of methods, attributes, events, interfaces or output parameters

```abap
a class with 60 methods
```

**Proposal.** One rule with thresholds per count (methods, attributes, events, interfaces, EXPORTING+CHANGING parameters per method); each 0 = off.

**Not reported.** Exception classes, test classes (option).

**Source.** code-pal-for-abap checks number-methods, number-attributes, number-events, number-interfaces, number-output-parameter.

## Report a WHEN block longer than a configured number of statements

```abap
CASE lv_kind.
  WHEN 'A'.
    " 60 statements
  WHEN OTHERS.
ENDCASE.
```

**Proposal.** Report a WHEN block with more than N statements (default e.g. 20). Could also be an option of method_length.

**Not reported.** WHEN OTHERS (option).

**Source.** abapOpenChecks check 034.

**Where.** a new rule, one option per check. **Effort:** S.
