---
target: abaplint
title: 'Report unnecessary me-> self references'
summary: '`me->mv = 1` and `me->run( )` say nothing the plain name does not; code-pal and Clean ABAP omit the self-reference'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check self-reference (SAP/code-pal-for-abap docs/checks/self-reference.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report unnecessary me-> self references

```abap
me->mv_count = 1.
me->run( ).
```

Instead:

```abap
mv_count = 1.
run( ).
```

**Proposal.** Report me-> before an attribute or method when no local variable or parameter of the same name exists; quick fix removes it.

**Not reported.** me-> needed to address an attribute shadowed by a local (that is shadowed-variable's case).

**Where.** a new rule (or an option of the closest existing one). **Effort:** S.

**Source.** code-pal-for-abap check self-reference.
