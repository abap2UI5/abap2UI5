---
target: abap2ui5-linter
title: 'relative-binding-without-context: no verdict below a control the snapshot does not know'
summary: 'below a control the snapshot does not know (here a table:Column whose xmlns:table a helper declares after stringify) the walk lost the row-template context and reported every relative cell as contextless'
priority: medium
state: filed
filed: https://github.com/abap2UI5/linter/pull/199
first_seen: 2026-11-25
checked_upstream: 2026-11-25
evidence:
  - '@abap2ui5/linter with the S5S branches (abap2UI5/linter builder-helpers-across-classes) on oblomov-dev/S5S_DEV (DEV): /kro/ui504_cl_app_001 render_main( ) - a sap.ui.table.Table with rows = {/MT_TABLE_DISPLAY}, columns built in a LOOP, each column''s template filled in IF layout->fname = … ELSEIF … arms (RadialMicroChart, Button, GenericTag). Six errors "binds {ANZSER} relatively, but the control has no binding context" on the 3rd and later controls of the template'
  - 'root cause (traced 2026-11-25): not the IF arms - the view writes table:Column without declaring xmlns:table (the views class completes the xmlns after stringify), so the Column is an unknown control and its owner opaque; inTemplate was never set below it'
  - 'abap2UI5/linter open issues and PRs checked 2026-11-25 (#195, #196, #197): nothing on this'
---

# relative-binding-without-context: no verdict below an unknown control

Fixed in abap2UI5/linter#199: below a control the metadata snapshot does
not know, the binding context is unknown, so the rule no longer reports
there. The first reading of the case (side-by-side IF arms in a 0..1
template) was wrong - the arms were never the cause.
