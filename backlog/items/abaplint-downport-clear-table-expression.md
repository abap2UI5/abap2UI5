---
target: abaplint
title: 'downport: CLEAR itab[ ... ]-component is not downported'
summary: 'a table expression as the target of CLEAR (`CLEAR lt[ name = x ]-t_range.`) stays as it is and does not parse at v702; READ TABLE ... ASSIGNING with the CX_SY_ITAB_LINE_NOT_FOUND raise the downport writes elsewhere is the 7.02 form'
priority: low
state: open
first_seen: 2026-11-02
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/range-filter, 2026-11-02 - `z2ui5_cl_sel_multisel`, `CLEAR ms_result-t_filter[ name = mv_popup_name ]-t_range.` and `-t_token`; rewritten as READ TABLE ... ASSIGNING (branch claude/addon-repo-namespaces-dnjqev)'
  - 'probed 2026-11-02 with @abaplint/cli 2.120.92 - a single class, syntax v702, rules downport, parser_error, check_syntax, unknown_types; `abaplint --fix` then a lint run: `CLEAR lt_f[ name = iv_text ]-t_range.` -> unchanged, parser_error'
checked_upstream: 2026-11-02
---
# downport: CLEAR itab[ ... ]-component is not downported

```abap
CLEAR lt_f[ name = iv_text ]-t_range.
```

stays as it is: `parser_error` at v702. A table expression on the right-hand
side, and as the target of an assignment, are downported; as the operand of
CLEAR it is not.

**Expected.** The same lowering the downport uses for a write through a table
expression:

```abap
FIELD-SYMBOLS <temp1> LIKE LINE OF lt_f.
READ TABLE lt_f WITH KEY name = iv_text ASSIGNING <temp1>.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE cx_sy_itab_line_not_found.
ENDIF.
CLEAR <temp1>-t_range.
```

FREE and the other statements that take a writable operand (`APPEND ... TO
lt[ 1 ]-sub`, `INSERT ... INTO TABLE lt[ 1 ]-sub`) are worth checking with
the same fix.
