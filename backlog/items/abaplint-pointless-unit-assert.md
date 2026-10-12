---
target: abaplint
title: 'Report unit-test assertions whose act and exp are identical or both literals'
summary: '`assert_equals( act = 1 exp = 1 )` always passes and tests nothing'
priority: medium
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check unit_test_assert (SAP/code-pal-for-abap docs/checks/unit_test_assert.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report unit-test assertions whose act and exp are identical or both literals

```abap
cl_abap_unit_assert=>assert_equals( act = 1 exp = 1 ).
```

**Proposal.** Report calls of cl_abap_unit_assert=>assert_* (and methods named *assert*) where act and exp are token-identical or both literals.

**Not reported.** Asserts with only act (assert_bound, assert_true).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check unit_test_assert.
