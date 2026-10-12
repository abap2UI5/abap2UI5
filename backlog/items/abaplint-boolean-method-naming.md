---
target: abaplint
title: 'Report methods returning abap_bool whose name does not say so (is_/has_/…)'
summary: 'a predicate method call `IF check( )` reads wrong; code-pal requires is_/has_/are_/try_/can_/have_/must_/should_ or similar'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check method-return-bool (SAP/code-pal-for-abap docs/checks/method-return-bool.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report methods returning abap_bool whose name does not say so (is_/has_/…)

```abap
METHODS valid RETURNING VALUE(rv) TYPE abap_bool.
```

Instead:

```abap
METHODS is_valid RETURNING VALUE(rv) TYPE abap_bool.
```

**Proposal.** Report a method whose RETURNING is abap_bool (or boolean/xfeld) and whose name does not start with a configurable prefix list.

**Not reported.** Interface methods implemented from SAP interfaces (void).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check method-return-bool.
