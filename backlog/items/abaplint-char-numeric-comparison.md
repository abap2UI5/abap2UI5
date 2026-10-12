---
target: abaplint
title: 'Report comparisons of character fields with numbers and of d/t fields with formatted literals'
summary: '`IF lv_char = 0` converts the text to a number (CX_SY_CONVERSION_NO_NUMBER once it holds text); `IF lv_date > ''01.01.2020''` compares characters in the wrong format'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/661
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abaplint/abaplint#661 (comparing wrong types)'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report comparisons of character fields with numbers and of d/t fields with formatted literals

```abap
IF lv_char = 0.
IF lv_date > '01.01.2020'.
```

**Proposal.** Report comparisons between c/string operands and numeric literals or variables, and literals compared with or assigned to d/t that do not match YYYYMMDD/HHMMSS.

**Not reported.** n and d against numbers; ASSERT.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abaplint/abaplint#661; ESLint no-implicit-coercion.

An upstream request exists (https://github.com/abaplint/abaplint/issues/661); this item collects the case and the scope for a pull request.
