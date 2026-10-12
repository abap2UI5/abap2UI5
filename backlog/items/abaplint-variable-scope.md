---
target: abaplint
title: 'Variable scope: shadowed names, a block-local declaration used after the block'
summary: 'a local that shadows an attribute or global, and a DATA inside IF/LOOP/CASE used after the block, are the two scoping traps of ABAP''s procedure-wide scope'
priority: medium
state: open
first_seen: 2026-10-12
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapOpenChecks check 046 (larshp/abapOpenChecks docs/_checks/46.md)'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
  - 'code-pal-for-abap check scope-of-variable (SAP/code-pal-for-abap docs/checks/scope-of-variable.md)'
---

# Variable scope: shadowed names, a block-local declaration used after the block

Both need the declaration site and the reference sites of a name; one rule, one option per check.

Merged on 2026-10-12 from the items `abaplint-shadowed-variable`, `abaplint-variable-scope`.

## Report a local variable or field symbol that shadows an attribute or a global

Shadowing is legal ABAP but a classic source of wrong-variable bugs.

```abap
CLASS zcl_p ... PRIVATE SECTION. DATA mv_x TYPE i. ...
METHOD run.
  DATA mv_x TYPE i.
  mv_x = 1.
```

**Proposal.** Report a DATA/FIELD-SYMBOLS/inline declaration in a method or form whose name equals a class attribute, a global of the program, or a parameter of an enclosing scope.

**Not reported.** Inherited private attributes (not visible); test classes (option).

**Source.** abapOpenChecks check 046.

## Report a variable declared inside an IF/CASE/LOOP block and used after it

```abap
IF iv = 1.
  DATA lv TYPE i.
  lv = 1.
ENDIF.
lv = 2.
```

**Proposal.** Report a DATA/FIELD-SYMBOLS declaration inside IF/ELSEIF/ELSE/CASE/WHEN/LOOP/DO/WHILE that is referenced outside that block.

**Not reported.** Declarations at the top of the procedure (definitions_top); inline declarations in optional branches (no_inline_in_optional_branches covers those).

**Source.** code-pal-for-abap check scope-of-variable.

**Where.** a new rule, one option per check. **Effort:** M.
