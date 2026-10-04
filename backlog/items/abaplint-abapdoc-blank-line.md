---
target: abaplint
title: 'wrong_abapdoc_position: a blank line inside or after the ABAP Doc block'
summary: 'a blank line between a "! block and its declaration, or inside the block, is "ABAP Doc comment is in the wrong position" on a system; wrong_abapdoc_position does not report it'
priority: medium
state: open
first_seen: 2026-10-04
upstream: abaplint/abaplint
evidence:
  - 2026-10-04, Code Inspector SYNTAX_CHECK on an S/4HANA 7.58 system - three warnings in abap2UI5-addons/abap-cloud-gui (z2ui5_cl_cgui_layout with a blank line in the middle of its block, z2ui5_cl_cgui_report and z2ui5_if_cgui_variant_store with one before the declaration); fixed in abap2UI5-addons/abap-cloud-gui#9
  - a scan of abap-cloud-gui, sapgui, abap2UI5 and samples-controls for a "! line followed by a blank line finds exactly those three
  - measured 2026-10-04 on abaplint main 506e7b9 - wrong_abapdoc_position gives no finding for either shape
  - gated in abap2UI5 since 2026-10-04 by `check:atc` (`abapdoc`), which until then asserted that a blank line detaches nothing
---

# wrong_abapdoc_position: a blank line detaches the block

```abap
"! what it answers

METHODS run.        " system: ABAP Doc comment is in the wrong position
```

The rule walks past blank lines to the declaration. The system does not. A
blank line ends the block, the same as a plain `"` comment does (the shape
abap2UI5's gate already reports for comments).
