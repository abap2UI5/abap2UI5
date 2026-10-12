---
target: abaplint
title: 'Report a variable declared inside an IF/CASE/LOOP block and used after it'
summary: 'ABAP has no block scope, so a variable declared in a branch is visible after it - code-pal reports the use outside, where it may be uninitialised'
priority: low
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'code-pal-for-abap check scope-of-variable (SAP/code-pal-for-abap docs/checks/scope-of-variable.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# Report a variable declared inside an IF/CASE/LOOP block and used after it

```abap
IF iv = 1.
  DATA lv TYPE i.
  lv = 1.
ENDIF.
lv = 2.
```

**Proposal.** Report a DATA/FIELD-SYMBOLS declaration inside IF/ELSEIF/ELSE/CASE/WHEN/LOOP/DO/WHILE that is referenced outside that block.

**Not reported.** Declarations at the top of the procedure (definitions_top); inline declarations in optional branches (no_inline_in_optional_branches covers those).

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** code-pal-for-abap check scope-of-variable.
