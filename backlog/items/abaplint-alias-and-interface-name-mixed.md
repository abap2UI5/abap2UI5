---
target: abaplint
title: 'Report a component addressed under its alias and under intf~name in one procedure'
summary: 'mo_app->mv_shared and mo_app->lif~mv_shared in one method - SLIN "The component addressed here under the name ... is accessed in the current context under a different name"; the method half shipped with abaplint#4788, the attribute half is silent'
priority: low
state: open
first_seen: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5, 2026-11-25, a unit test of z2ui5_cl_ui5_srv_model: one method reads mo_app->mv_shared (ALIASES mv_shared FOR lif~mv_shared) and mo_app->lif~mv_shared - the extended check warns, abaplint reports nothing; written up in abap-check'
  - 'probed 2026-11-27 against abaplint main with every default rule on: nothing for the mixed access; no_aliases forbids ALIASES altogether, implement_methods covers the method (abaplint/abaplint#4788)'
---

# One component, two names in one procedure

```abap
" ALIASES mv_shared FOR lif~mv_shared.
lv_a = mo_app->mv_shared.
lv_b = mo_app->lif~mv_shared.
```

The extended check warns that the component is accessed under a different
name in the same context.

## Proposal

Report the second spelling when one method body reads or writes the same
component both through its alias and as `intf~name`.

## Must not report

A consistent use of either spelling; two different components; the two
spellings in different methods.
