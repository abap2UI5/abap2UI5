---
target: abaplint
title: 'Report numeric literals in comparisons and control flow (magic numbers)'
summary: 'abaplint/abaplint#3296 asks for it; code-pal reports numeric literals in IF/ELSEIF/WHEN/CHECK/WHILE except 0 and 1'
priority: low
state: filed
filed: https://github.com/abaplint/abaplint/issues/3296
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check magic-number (SAP/code-pal-for-abap docs/checks/magic-number.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report numeric literals in comparisons and control flow (magic numbers)

```abap
IF lv_status = 74.
```

**Proposal.** Report numeric literals other than 0 and 1 (configurable allow list) as comparison operands in IF/ELSEIF/WHEN/CHECK/WHILE.

**Not reported.** Method arguments, assignments, DO n TIMES, offsets, test classes (option). #3296 discussed that string literals are a different rule.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** code-pal-for-abap check magic-number.

An upstream request exists (https://github.com/abaplint/abaplint/issues/3296); this item collects the case and the scope for a pull request.
