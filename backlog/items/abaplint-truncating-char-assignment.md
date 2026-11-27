---
target: abaplint
title: 'Report a character variable assigned to a shorter character target (silent truncation)'
summary: 'lv_c3 = lv_c10. cuts the value without a message - the code inspector reports "Truncate in Conversion to ABAP Type C", abaplint covers the literal source only (abaplint-literal-exceeds-target)'
priority: medium
state: open
first_seen: 2026-11-24
checked_upstream: 2026-11-24
upstream: abaplint/abaplint
evidence:
  - 'ATC export of a consumer system on S/4HANA (2026-11-24), check "Suspect Conversions": 121 findings in consumer classes and the abap2UI5 classes installed there - 74 "Suspect Conversion from Literal to ABAP Type", 36 "Truncate in Conversion to ABAP Type C", 11 "Suspect Conversion (a Structure) to ABAP Type CHAR"; 58 of the 121 in Z2UI5_ classes (Z2UI5_CL_UI5_SRV_MODEL 24, Z2UI5_CL_UI5_UTIL_CONTEXT 11), the truncations in Z2UI5_CL_POPUP_CONTEXT, Z2UI5_CL_UI5_UTIL_CONTEXT and 20 consumer classes'
  - 'probed 2026-11-24 against abaplint 2.120.116, every rule on from `abaplint --default`, open-abap-core as dependency, an isolated project with a control finding firing: DATA lv_c10 TYPE c LENGTH 10. DATA lv_c3 TYPE c LENGTH 3. lv_c3 = lv_c10. - no finding'
---

# Report a character variable assigned to a shorter character target (silent truncation)

```abap
DATA lv_c10 TYPE c LENGTH 10.
DATA lv_c3  TYPE c LENGTH 3.

lv_c3 = lv_c10.                    " CI: Truncate in Conversion to ABAP Type C
ls_row-short = ls_src-long_text.   " the same between structure components
```

A `c` (or `n`) source longer than its `c` target is cut at the target length,
without an exception and without a message. Usually that is the bug: a field
copied into a too-short buffer, a domain lengthened on one side only. When it
is intended, the code can say so (`lv_c3 = lv_c10(3).`).

`abaplint-literal-exceeds-target` (abaplint/abaplint#1343) covers a **literal**
or constant that does not fit. This is the same check for a **variable**
source.

**Proposal.** Report a `MOVE` (`=`), a `VALUE #( comp = x )` component, and an
actual parameter passed by value, when source and target both have a known
fixed length, the target is `c` (or `n`), the source is `c`, `n` or a
character-like DDIC type, and the source is longer than the target.

**Not reported.**

- a generic or variable-length target (`clike`, `csequence`, `string`,
  `any`) - nothing is cut;
- a source with explicit offset/length (`lv_c10(3)`, `lv_c10+2(3)`) - the
  length is stated;
- `CONV c3( lv_c10 )` / a CONV with an explicitly shorter type - the
  conversion is stated;
- a `string` source - its length is not known statically (an option could
  report it);
- a source whose type is unknown (void, unresolved DDIC).

**Where.** a new rule, or an option of the rule that lands for
abaplint/abaplint#1343. **Effort:** M.

**Source.** ATC on a consumer system (its own classes and the abap2UI5 classes installed
there).
