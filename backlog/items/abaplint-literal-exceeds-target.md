---
target: abaplint
title: 'Report literals and constants that do not fit their target'
summary: 'a char literal longer than c LENGTH n, a number out of range for int1/int2/i, a constant VALUE longer than its type - silent truncation or CX_SY_CONVERSION_OVERFLOW'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/1343
first_seen: 2026-10-11
checked_upstream: 2026-10-11
upstream: abaplint/abaplint
evidence:
  - 'extended check on an ABAP Cloud trial system, 2026-11-11: """" is not an admissible value for type "D". Admissible: 00010101 (yyyymmdd)" and the same for type "T" (message GTW) on a test of z2ui5_cl_ui5_srv_model, `VALUE #( … adate = `` atime = `` )`. Probed 2026-11-11 against abaplint 2.120.92, every default rule on: `lv_date = ```, `lv_date = ''2024''` and the VALUE form are not reported'
  - 'abap2xlsx/abap2xlsx 0744e0c: `CLASS-DATA eol TYPE char01 VALUE cl_abap_char_utilities=>cr_lf` lost its LF in every CSV'
  - 'abaplint/abaplint#1343 asks for it'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
---

# Report literals and constants that do not fit their target

```abap
DATA lv_c3 TYPE c LENGTH 3.
lv_c3 = 'ABCDE'.
CONSTANTS c_eol TYPE c LENGTH 1 VALUE cl_abap_char_utilities=>cr_lf.
```

**Proposal.** Report literal/constant sources longer than a fixed-length c/n target and numeric literals outside the target's range.

The same check, for a target of type d or t: a literal that is not eight (six) digits is not a value of the type, and the extended check says so.

```abap
DATA lv_date TYPE d.
lv_date = ``.          " "" is not an admissible value for type "D"
lv_date = '2024'.
ls_row = VALUE #( adate = `` atime = `` ).
```

Report a literal assigned to, or passed for, a d or t target whose content is not exactly the type's digits. Not reported: a variable or an expression as the source; the initial values `'00000000'` and `'000000'`.

**Not reported.** Generic targets; strings.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2xlsx fix history.

An upstream request exists (https://github.com/abaplint/abaplint/issues/1343); this item collects the case and the scope for a pull request.
