---
target: abaplint
title: 'check_syntax: a built-in function as the operand of IS [NOT] INITIAL'
summary: '`IF condense( lv ) IS INITIAL.` is "Unexpected operator IS" on a system - also on 7.58, not only on 7.02/7.31; abaplint accepts it at every syntax version'
priority: high
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - abap2UI5#2767 - `IF condense( val ) IS INITIAL.` refused as "Unexpected operator IS" on 7.02/7.31 (through the 702 downport)
  - measured 2026-10-03 on a real system (S/4HANA, release 758, ADT) - `IF condense( lv ) IS INITIAL.` is "Unexpected operator "IS"."; `READ TABLE … WITH KEY table_line = to_upper( lv )` in the same class is fine
  - 2026-10-04, Code Inspector SYNTAX_CHECK on the same 7.58 system - `zcl_sapgui_se03->do_search` and `zcl_sapgui_se16n->variant_from_store`, line 4 each, "Unexpected operator "IS"." (a repository outside the abap2UI5 organisation)
  - measured 2026-10-03 on abaplint main 506e7b9 - no finding at v702, v750 or v758
---

# check_syntax: a built-in function as the operand of IS [NOT] INITIAL

## What happens

```abap
IF condense( lv ) IS INITIAL.   " 7.58: Unexpected operator "IS".
ENDIF.
IF condense( lv ) = ``.         " fine
ENDIF.
```

abaplint parses the predicate with any `Source` before `IS [NOT] INITIAL`; the
kernel refuses at least the built-in function there.

## Still to measure before it is filed

Which operands the kernel refuses in front of `IS [NOT] INITIAL`:

- a numeric built-in (`lines( lt )`)
- a functional method call (`get_text( )`)
- a constructor expression (`CONV string( lv )`)
- a table expression (`lt[ 1 ]`)

The fix is a grammar or `check_syntax` change, depending on that answer. A rule
that is too wide would refuse valid code.

## Remedy

Compare instead: `IF condense( lv ) = ``.` / `IF lines( lt ) = 0.`, or assign
to a variable first.
