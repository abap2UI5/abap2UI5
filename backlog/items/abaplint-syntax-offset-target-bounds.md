---
target: abaplint
title: 'check_syntax: a static offset/length on an assignment TARGET outside the field'
summary: '`lv_c5+3(4) = …` and `lv_c5+6 = …` are refused on a system; check_syntax reports the same shape on the source side ("Bad LENGTH") but not on the target'
priority: low
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit 10663aa (#7669): `rv_time+11 = ''+000000''` was a system syntax finding'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# check_syntax: a static offset/length on an assignment TARGET outside the field

A static offset and length on a fixed-length target have to lie inside the field.

```abap
DATA lv_c5 TYPE c LENGTH 5.
lv_c5+3(4) = 'ABCD'.
```

**Proposal.** Apply the existing source-side offset/length bounds check to write positions.

**Not reported.** Strings and generic fields (runtime).

**Where.** an extension of `check_syntax` - the system refuses the code at activation, so it belongs with the syntax check, not in a separate rule. **Effort:** S.

**Source.** abapGit fix history.
