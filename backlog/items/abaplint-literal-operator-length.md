---
target: abaplint
title: 'Report a text literal joined with the literal operator & that is longer than 255 characters'
summary: 'literals joined with & form ONE literal at compile time, and a literal may hold 255 characters - the system refuses the joined form, abaplint checks each part only'
priority: medium
state: filed
filed: https://github.com/abaplint/abaplint/pull/4823
first_seen: 2026-11-24
checked_upstream: 2026-11-27
upstream: abaplint/abaplint
evidence:
  - 'abap2UI5-addons/layout-management 5b1c8b7: a user''s pull (2026-11-24) refused the test classes of z2ui5_cl_layo_xml_tree with "The text literal "`<mvc:View xmlns="sap.m" xm..." is longer than 255 characters", then "The statement ENDCLASS is missing" and "Compilation was canceled" - a CONSTANTS c_view TYPE string VALUE of eleven backquoted parts joined with &. The fix built the string in a method with &&'
  - 'probed 2026-11-24 against abaplint 2.120.113, every syntax rule and line_length on: a CONSTANTS VALUE of three backquoted parts of 100 + 100 + 80 characters joined with & - no finding'
  - 'filed 2026-11-27 as abaplint/abaplint#4823 (syntax 1/4): check_syntax adds up the parts of a & chain, backquoted and quoted, in CONSTANTS/DATA VALUE and in operand positions'
---

# Report a text literal joined with the literal operator & that is longer than 255 characters

```abap
CONSTANTS c_view TYPE string VALUE
  `<mvc:View xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc"><Page title="P">` &
  `<Panel id="pnl" headerText="Customer">` &
  ...
  `</Page></mvc:View>`.          " 300+ characters - a syntax error on the system
```

The literal operator `&` joins literals at compile time into **one** literal,
and a character or string literal holds at most 255 characters. Each part is
short, so every line passes; the system refuses the joined result, and because
the statement never compiles the class reports "ENDCLASS is missing" as well.
`&&` is the run-time concatenation and has no such limit - but it is not
allowed in a `CONSTANTS ... VALUE`.

**Proposal.** In `check_syntax` (or `parser_error`): add up the content of the
literals of one `&` chain - backquoted and quoted alike, after unescaping
doubled delimiters - and report the chain when the total exceeds 255.

**Not reported.** `&&`; string templates `|...|`; a chain whose total is 255 or
less.

**Where.** `check_syntax`, where the literal chain is resolved. **Effort:** S.

**Source.** abap2UI5-addons/layout-management, a user's activation on S/4HANA.
