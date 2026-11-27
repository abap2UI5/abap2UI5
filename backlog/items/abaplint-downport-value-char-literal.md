---
target: abaplint
title: 'The 702 downport of VALUE #( ( ''lit'' ) ) writes INSERT ''lit'' INTO TABLE, which does not convert the literal'
summary: 'the 7.02 downport turns VALUE #( ( ''literal'' ) ) for a table of c LENGTH n (or of string) into INSERT ''literal'' INTO TABLE, and check_syntax reports that as "Types not compatible" - on purpose, an insert through the table key does not convert; abap-cloud-gui''s 7.02 gate exempts two generated samples until the downport writes something else'
priority: high
state: filed
filed: https://github.com/abaplint/abaplint/pull/4816
first_seen: 2026-11-26
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap-cloud-gui DEV 2bc0afe, npm run check:702 with @abaplint/cli 2.120.120 (downport + syfixes + .github/abaplint/abap_702.jsonc): src/03/z2ui5_cl_cgui_r2c_25.clas.abap:65-66 and z2ui5_cl_cgui_r2c_40.clas.abap:58-60 - check_syntax "Types not compatible"; the same sources were clean with 2.120.92'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint): no issue for it; #4720 "downport: keep line breaks when outlining VALUE rows and INSERT/APPEND sources" merged 2026-11-25 17:49 UTC, after 2.120.120 was published - touches the same outlining, not verified whether it fixes this'
  - 'the downported statement INSERT ''<h2>Menu</h2>'' INTO TABLE temp2 (temp2 LIKE a STANDARD TABLE OF c LENGTH 255) is valid ABAP - a character literal converts into the line type; the false positive is check_syntax, not the downport'
  - 'workaround 2026-11-26: abap-cloud-gui DEV fbed492 - noIssues for z2ui5_cl_cgui_r2c_25/_40 in .github/abaplint/abap_702.jsonc and the same exception in tools/report2ui5/test/abaplint.test.mjs; remove both when this is fixed'
  - 'probed 2026-11-27 against abaplint main after 2.120.122, syntax v702: INSERT abc INTO TABLE t2. with t2 a standard table of c LENGTH 5 still reports "Types not compatible" (check_syntax), and the downport of t2 = VALUE #( ( abc ) ( de ) ) still writes that statement'
  - 'upstream search 2026-11-27 (open issues and pull requests of abaplint/abaplint): nothing on it; filed the same day as abaplint/abaplint#4816 - while writing it the diagnosis turned: check_syntax refuses INSERT of a text literal of another length INTO TABLE on purpose (a test of its own, "INSERT character literal into table of c length 20, error"), and by the keyword documentation as remembered an insert through the table key does not convert the work area - not verified on a system. So the pull request changes the downport, not check_syntax: a text literal row of VALUE is assigned to the row work area and that is inserted'
---

# The 702 downport: a text literal row of `VALUE` becomes `INSERT '<literal>' INTO TABLE`

## What happens

The 7.02 downport rewrites a constructor expression of char literals

```abap
DATA lt_src TYPE STANDARD TABLE OF c255 WITH DEFAULT KEY.  " c LENGTH 255
lt_src = VALUE #( ( '<h2>Menu</h2>' ) ( 'Pasta' ) ).
```

into one `INSERT` per row:

```abap
INSERT '<h2>Menu</h2>' INTO TABLE temp2.
```

`VALUE` converts a row operand to the line type; `INSERT ... INTO TABLE`
(the insert through the table key) does not. abaplint's `check_syntax` (v702)
reports the statement as "Types not compatible" and does so on purpose - so
it is the downport that writes something a 7.02 gate cannot take.

This item first read the other way round ("valid ABAP, check_syntax is
wrong"). Whether a 7.02 system activates the statement was never tested; the
change below is right either way.

## Expected

The downport assigns a text literal row to the row work area, which converts
it, and inserts the work area:

```abap
DATA temp3 LIKE LINE OF temp2.
temp3 = '<h2>Menu</h2>'.
INSERT temp3 INTO TABLE temp2.
```

## Reproduce

    cd abap-cloud-gui && git checkout 1ce3d6f && npm ci && npm run check:702
    # 5 findings in src/03/z2ui5_cl_cgui_r2c_25/_40 - from fbed492 on they are noIssues
