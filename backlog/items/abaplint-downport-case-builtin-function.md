---
target: abaplint
title: 'The 702 downport does not outline a built-in function used as CASE operand'
summary: 'CASE to_upper( val ). is reported at v702 ("Built-in function to_upper not allowed as CASE/WHEN operand before v740sp02") and left as it is by --fix'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4818
first_seen: 2026-11-27
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/table-maintenance 09a06ce, 2026-11: get_config_by_url of z2ui5_cl_tm_001 was rewritten by hand to value = to_upper( condense( value ) ). IF value = ... - "The 7.02 downport cannot take a built-in function as a CASE operand"'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, syntax v702, --fix: CASE to_upper( val ). WHEN `X` OR `TRUE`. - check_syntax reports the built-in function as CASE operand, the statement is unchanged after the fix and the finding stays'
  - 'upstream search 2026-11-27 (open issues and pull requests of abaplint/abaplint): nothing on it; filed the same day as abaplint/abaplint#4818 - the operand is outlined for a built-in function of release 7.02; a function in a WHEN operand, nmax/nmin/round/rescale and functions newer than 7.02 stay as they are'
---

# The 702 downport: a built-in function as `CASE` operand

```abap
CASE to_upper( val ).
  WHEN `X` OR `TRUE`.
    ...
ENDCASE.
```

`check_syntax` at v702 says the built-in function is not allowed as CASE/WHEN
operand before 7.40 SP02 - the downport has no fix for it, so the finding
stays after `--fix`.

## Proposal

Outline the operand into a typed helper variable in front of the `CASE`:

```abap
DATA temp1 TYPE string.
temp1 = to_upper( val ).
CASE temp1.
```

## Must not change

A functional method call as CASE operand (7.02 takes it) and a function in
the body of a WHEN branch. A built-in function in a `WHEN` operand is its own
decision - it cannot be moved in front of the CASE without evaluating it
earlier than the source does.
