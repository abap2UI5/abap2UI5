---
target: abaplint
title: 'check_syntax: INSERT ''<literal>'' INTO TABLE of a c LENGTH n table is reported as "Types not compatible" (the 7.02 downport of VALUE #( ( ''lit'' ) ) writes it)'
summary: The 7.02 downport turns VALUE #( ( 'literal' ) ) for a table of c LENGTH n into INSERT 'literal' INTO TABLE - valid ABAP, which a system activates - but abaplint's check_syntax reports it as "Types not compatible"; abap-cloud-gui's 7.02 gate exempts its two generated report2UI5 samples (noIssues) until abaplint accepts a char literal there
priority: high
state: open
first_seen: 2026-11-26
checked_upstream: 2026-11-26
upstream: abaplint/abaplint
evidence:
  - 'abap-cloud-gui DEV 2bc0afe, npm run check:702 with @abaplint/cli 2.120.120 (downport + syfixes + .github/abaplint/abap_702.jsonc): src/03/z2ui5_cl_cgui_r2c_25.clas.abap:65-66 and z2ui5_cl_cgui_r2c_40.clas.abap:58-60 - check_syntax "Types not compatible"; the same sources were clean with 2.120.92'
  - 'gh search 2026-11-26 (repo:abaplint/abaplint): no issue for it; #4720 "downport: keep line breaks when outlining VALUE rows and INSERT/APPEND sources" merged 2026-11-25 17:49 UTC, after 2.120.120 was published - touches the same outlining, not verified whether it fixes this'
  - 'the downported statement INSERT ''<h2>Menu</h2>'' INTO TABLE temp2 (temp2 LIKE a STANDARD TABLE OF c LENGTH 255) is valid ABAP - a character literal converts into the line type; the false positive is check_syntax, not the downport'
  - 'workaround 2026-11-26: abap-cloud-gui DEV fbed492 - noIssues for z2ui5_cl_cgui_r2c_25/_40 in .github/abaplint/abap_702.jsonc and the same exception in tools/report2ui5/test/abaplint.test.mjs; remove both when this is fixed'
---

# check_syntax: `INSERT '<literal>' INTO TABLE` of a character table

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

That is valid ABAP - the literal converts into the line type, and a 7.02 system
activates it. abaplint's own `check_syntax` (v702) reports it as
"Types not compatible", so a repository that lints its downported code goes red
on correct code.

## Expected

`check_syntax` accepts a character literal (or any source convertible to the
line type) as the work area of `INSERT ... INTO TABLE` / `APPEND` for a table
of `c LENGTH n`, as the ABAP compiler does. (Alternatively the downport could
outline the literal into a typed helper, but the statement is not wrong.)

## Reproduce

    cd abap-cloud-gui && git checkout 1ce3d6f && npm ci && npm run check:702
    # 5 findings in src/03/z2ui5_cl_cgui_r2c_25/_40 - from fbed492 on they are noIssues
