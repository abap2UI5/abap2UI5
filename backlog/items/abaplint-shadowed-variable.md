---
target: abaplint
title: 'Report a local variable or field symbol that shadows an attribute or a global'
summary: '`DATA mv_x` in a method hides the attribute mv_x - writes go to the local, and `me->mv_x` and `mv_x` mean different things'
priority: medium
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 046 (larshp/abapOpenChecks docs/_checks/46.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report a local variable or field symbol that shadows an attribute or a global

Shadowing is legal ABAP but a classic source of wrong-variable bugs.

```abap
CLASS zcl_p ... PRIVATE SECTION. DATA mv_x TYPE i. ...
METHOD run.
  DATA mv_x TYPE i.
  mv_x = 1.
```

**Proposal.** Report a DATA/FIELD-SYMBOLS/inline declaration in a method or form whose name equals a class attribute, a global of the program, or a parameter of an enclosing scope.

**Not reported.** Inherited private attributes (not visible); test classes (option).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abapOpenChecks check 046.
