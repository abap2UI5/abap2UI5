---
target: abaplint
title: 'Report comparisons that are constant: a = a, x <> A OR x <> B, x = A AND x = B'
summary: 'a comparison of an operand with itself, or a pair of comparisons on one field that is always true (x <> A OR x <> B) or always false (x = A AND x = B), is a copy-paste bug'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/3567
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5/abap2UI5 7647c26 (#1814): `kind <> c_num OR kind <> c_numeric` made the numeric serialisation wrong'
  - 'abaplint/abaplint#3567 (no_self_compare) and #2040 (always true condition) ask for parts of it'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report comparisons that are constant: a = a, x <> A OR x <> B, x = A AND x = B

The condition does not depend on the data.

```abap
IF kind <> c_num OR kind <> c_numeric.
IF ls_new-id = ls_new-id.
```

**Proposal.** Report a comparison with identical operands, and OR of two <> / AND of two = on the same field with different literals or constants (also in SQL WHERE).

**Not reported.** ASSERT (deliberate); comparisons of method calls (may have side effects).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** Sonar S1764, ESLint no-self-compare, Clippy eq_op.

An upstream request exists (https://github.com/abaplint/abaplint/issues/3567); this item collects the case and the scope for a pull request.
