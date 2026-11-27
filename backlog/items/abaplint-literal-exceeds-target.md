---
target: abaplint
title: 'Report literals and constants that do not fit their target'
summary: 'a char literal longer than c LENGTH n, a number out of range for int1/int2/i, a constant VALUE longer than its type - silent truncation or CX_SY_CONVERSION_OVERFLOW'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/issues/1343
first_seen: 2026-10-11
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'extended check on an ABAP Cloud trial system, 2026-11-11: """" is not an admissible value for type "D". Admissible: 00010101 (yyyymmdd)" and the same for type "T" (message GTW) on a test of z2ui5_cl_ui5_srv_model, `VALUE #( … adate = `` atime = `` )`. Probed 2026-11-11 against abaplint 2.120.92, every default rule on: `lv_date = ```, `lv_date = ''2024''` and the VALUE form are not reported'
  - 'abap2xlsx/abap2xlsx 0744e0c: `CLASS-DATA eol TYPE char01 VALUE cl_abap_char_utilities=>cr_lf` lost its LF in every CSV'
  - 'abaplint/abaplint#1343 asks for it'
  - 'the 2026-10-11 harvest (other linters, 18 ABAP repositories'' fix history, the abaplint tracker): checked against abaplint 2.120.74 - most examples probed with every rule on, the rest against the rule sources; no rule covers the shape'
  - 'one activation of a consumer system on S/4HANA (2026-11-24) warned "*" is not an admissible value for type "N(10)". Admissible: 0, "Admissible: 9" for "98"/"99" into a C(1) button position (three sites) and The type of "''''" cannot be converted to the type of "DALEN" for WHERE dalen <> '''' on a DATS field'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated syntax-clean project with a control finding firing: lv_n10 = ''*'', lv_n12 = `*`, lv_c1 = `98`, lv_c1 = ''99'', VALUE #( pos = `98` ), lv_d = '''', IF lv_d <> '''' and SELECT ... WHERE dalen <> '''' (DATS field of a TABL in the project) - no finding on any of them'
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

Three more shapes, from one activation of a consumer system on S/4HANA
(2026-11-24), all silent in abaplint 2.120.116:

```abap
DATA lv_itemno TYPE n LENGTH 10.
lv_itemno = '*'.            " "*" is not an admissible value for type "N(10)". Admissible: 0
DATA lv_pos TYPE c LENGTH 1.
lv_pos = '99'.              " ... Admissible: 9  (a two-character literal into C(1))
add( VALUE #( pos = `98` ) ).
SELECT COUNT( * ) FROM zp_dats WHERE dalen <> ''.   " DALEN TYPE dats:
IF lv_date <> ''.                                   " The type of "''" cannot be converted to the type of "DALEN"
```

- a literal with a non-digit into a NUMC target - the system names the
  admissible value;
- a literal longer than a C(1) target - the length rule above, for a literal
  that is a number written as text;
- the empty literal `''` compared with (or assigned to) a d field, in ABAP
  code and in an SQL `WHERE`: the comparison means `'00000000'`, which is the
  literal to write, or `IS INITIAL`.

**Not reported.** Generic targets; strings.

**Where.** a new rule (or an option of the closest existing one). **Effort:** M.

**Source.** abap2xlsx fix history.

An upstream request exists (https://github.com/abaplint/abaplint/issues/1343); this item collects the case and the scope for a pull request.
