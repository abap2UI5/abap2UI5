---
target: abaplint
title: 'LOOP and READ targets used wrongly: after the loop, reused by an inner loop, INTO <fs>, not typed as the line'
summary: 'four checks on the work area or field symbol of a LOOP/READ - read after ENDLOOP, reused by a nested LOOP/READ, an INTO <fs> that overwrites the row (ASSIGNING was meant), and a target not typed as the line type'
priority: medium
state: open
first_seen: 2026-10-11
checked_upstream: 2026-10-12
upstream: abaplint/abaplint
evidence:
  - 'abapGit/abapGit d68e4e6 (#2157, dump)'
  - '15 sites in current trees, one a real risk: abap2xlsx src/not_cloud/zcl_excel_converter.clas.abap:1470 reads <fs_sfcat>-totals_function after its loop'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'probed 2026-10-12 against abaplint main after v2.120.75 with every default rule on (Config.getDefault, v750): no rule reports the bad example'
---

# LOOP and READ targets used wrongly: after the loop, reused by an inner loop, INTO <fs>, not typed as the line

All four look at the INTO/ASSIGNING target of LOOP AT and READ TABLE; one rule, one option per check. The stale IS ASSIGNED case stays its own item (abaplint-stale-fs-is-assigned), it has the strongest evidence.

Merged on 2026-10-12 from the items `abaplint-loop-target-used-after-loop`, `abaplint-nested-loop-same-target`, `abaplint-read-into-field-symbol`, `abaplint-loop-target-not-line-type`.

## Report the LOOP's field symbol or work area read after ENDLOOP

```abap
LOOP AT lt ASSIGNING FIELD-SYMBOL(<r>).
ENDLOOP.
<r>-flag = abap_true.
```

**Proposal.** Report a read of the LOOP's ASSIGNING field symbol (or INTO work area) after ENDLOOP before it is reassigned or guarded by IS ASSIGNED.

**Not reported.** Use guarded by a flag set inside the loop (option).

**Source.** abapGit fix history; Pylint W0631.

## Report an inner LOOP/READ that reuses the work area or field symbol of the enclosing LOOP

The outer loop body continues with a value the inner statement replaced.

```abap
LOOP AT lt_a INTO ls.
  LOOP AT lt_b INTO ls.
  ENDLOOP.
ENDLOOP.
```

**Proposal.** Report INTO/ASSIGNING targets of a LOOP or READ that equal the target of an enclosing LOOP.

**Not reported.** Targets of a loop that has already ended.

**Source.** Ruff/Pylint PLW2901.

## Report READ TABLE … INTO <fs> and LOOP AT … INTO <fs>

A field symbol as INTO target is a write through the field symbol.

```abap
READ TABLE lt INTO <ls> WITH KEY id = 2.
```

**Proposal.** Report a field symbol as the INTO target of READ TABLE / LOOP AT.

**Not reported.** Field symbols deliberately bound to a work area (pseudo comment).

## Report a LOOP/READ work area or field symbol not typed as the table's line type

A work area of another type is converted silently.

```abap
DATA lt TYPE STANDARD TABLE OF ty_a WITH DEFAULT KEY.
DATA ls TYPE ty_b.
LOOP AT lt INTO ls.
ENDLOOP.
```

Instead:

```abap
DATA ls TYPE LINE OF ty_t_a.
```

**Proposal.** Report INTO / ASSIGNING targets whose type is not the line type of the table (identical type or LINE OF), when both are known structures.

**Not reported.** Inline declarations; generic targets; identical types under another name (option).

**Where.** a new rule, one option per check. **Effort:** M.
