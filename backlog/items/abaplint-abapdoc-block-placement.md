---
target: abaplint
title: 'Report an ABAP Doc block that documents nothing'
summary: a `"!` block before a chain keyword, or inside a parameter list, silently documents no declaration at all — SLIN accepts it and the text is simply never shown
priority: medium
state: open
first_seen: 2026-08-17
upstream: abaplint/abaplint
evidence:
  - abap2UI5 `z2ui5_if_client=>cs_nav_mode` — the block sat before `CONSTANTS:` and documented nothing
  - the identical mistake in `abap2UI5/samples-stack` on `cs_status` (`7459f39`), found only by reading the file
  - it recurs across repositories because nothing anywhere reports it — the text is present, so the author has no reason to look again
  - third recurrence, from a user's system (2026-08-17) — five SLIN findings on samples-stack's overview app, two blocks before `CONSTANTS:` and three comments inside one parameter list (the shape the probe counts as a negative); gated locally since, by abap2UI5's `check:atc` and samples-stack's `check:abapdoc`
---

# Report an ABAP Doc block that documents nothing

## What happens

An ABAP Doc block documents **the one declaration directly below it**. In a
chained statement that means inside the chain, not before the chain keyword:

```abap
"! Navigation modes.            <-- documents nothing
CONSTANTS:
  BEGIN OF cs_nav_mode,
    ...
```

```abap
CONSTANTS:
  "! Navigation modes.          <-- documents cs_nav_mode
  BEGIN OF cs_nav_mode,
    ...
```

The same applies inside a parameter list: a `"!` between two parameters
documents nothing, because a parameter is documented from the method's own
block with `"! @parameter <name> | <text>`.

Neither form is an error anywhere. The text is in the source, it reads like
documentation to a human scanning the file, and it is simply never attached to
anything — so the object ships undocumented while looking documented.

## Why no existing rule catches it

The `abapdoc` rule checks for the **existence** of ABAP Doc on public methods,
interface methods and class/interface definitions. A block that exists but
attaches to nothing is indistinguishable from a block that was never written,
from that rule's point of view — and if the object is one `abapdoc` does not
require documentation for, nothing looks at all.

## Proposed rule

Report a `"!` block whose following statement is not a declaration it can
document:

- immediately before a chain keyword (`CONSTANTS:`, `DATA:`, `TYPES:`,
  `METHODS:`) rather than before the first chain member;
- inside a parameter list;
- immediately before `ENDCLASS`, `ENDINTERFACE`, `PUBLIC SECTION.`,
  `PROTECTED SECTION.` or `PRIVATE SECTION.`.

Each is a purely structural test on the statement following the comment block,
which abaplint's statement model already gives it.

## Suggested severity

A warning. Nothing breaks — that is the point, and it is why it needs a rule
rather than a convention.

<!-- probe:start — written by `npm run backlog:probe`, do not edit by hand -->

## Measured

`abaplint-abapdoc-block-placement.probe.mjs` — an ABAP Doc block whose next statement is a chain keyword or a section end, with the correct in-chain placement as the negative.
Run **2026-08-17** against `abap2UI5`, `samples`, `samples-controls`, `samples-stack`.

**Would fire on 2 site(s)** in 1 repository:

| Repository | Where | |
|---|---|---|
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:82 | → CONSTANTS: |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:98 | → CONSTANTS: |

**Must NOT fire on 597 site(s)** that match the shape and are correct:

| Repository | Where | |
|---|---|---|
| abap2UI5 | `src/00/02/z2ui5_cl_srt_classdescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_classdescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_complexdescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_complexdescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_datadescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_datadescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_elemdescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_elemdescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_intfdescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_intfdescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_objectdescr.clas.abap`:1 | → class z2ui5_cl_srt_objectdescr definition |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_refdescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_refdescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_structdescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_structdescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_tabledescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_tabledescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_typedescr.clas.abap`:1 | → CLASS z2ui5_cl_srt_typedescr DEFINITION |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_typedescr.clas.abap`:15 | → DATA not_serializable TYPE abap_bool |
| abap2UI5 | `src/00/02/z2ui5_cl_srt_typedescr.clas.abap`:18 | → DATA technical_type   TYPE abap_bool |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_app_cont.clas.abap`:41 | → METHODS app_refresh_draft_id. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:23 | → METHODS queue_app_event |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:32 | → METHODS queue_app_js |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:38 | → METHODS slot_destroy |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:46 | → METHODS slot_display |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:61 | → METHODS slots_serialize. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:71 | → METHODS nav_serialize. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:78 | → METHODS msg_toast |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:98 | → METHODS msg_box |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:128 | → METHODS build_global_call |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:136 | → METHODS queue_app |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:142 | → METHODS queue_system |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:156 | → METHODS box_resolve |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:166 | → METHODS slot_reset |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:172 | → METHODS set_opt_string |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_frontend.clas.abap`:190 | → METHODS set_opt_bool |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:66 | → METHODS session_merge. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:71 | → METHODS launchpad_derive. |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_handler.clas.abap`:76 | → METHODS actions_serialize |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_event.clas.abap`:23 | → METHODS get_event_client_ajson |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_event.clas.abap`:33 | → METHODS get_event_client_json |
| abap2UI5 | `src/01/02/z2ui5_cl_ui5_srv_model.clas.abap`:113 | → METHODS delta_apply_field |
| abap2UI5 | `src/02/z2ui5_cl_ui5_view_builder.clas.abap`:32 | → CLASS z2ui5_cl_ui5_view_builder DEFINITION PUBLIC CREATE PRI |
| abap2UI5 | `src/02/z2ui5_cl_ui5_view_builder.clas.abap`:44 | → METHODS ele |
| abap2UI5 | `src/02/z2ui5_cl_ui5_view_builder.clas.abap`:55 | → METHODS tag |
| abap2UI5 | `src/02/z2ui5_cl_ui5_view_builder.clas.abap`:67 | → METHODS a |
| abap2UI5 | `src/02/z2ui5_cl_ui5_view_builder.clas.abap`:76 | → METHODS end |
| abap2UI5 | `src/02/z2ui5_cl_ui5_view_builder.clas.abap`:82 | → METHODS stringify |
| abap2UI5 | `src/02/z2ui5_if_app.intf.abap`:15 | → DATA id_draft TYPE string. |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:114 | → BEGIN OF cs_nav_mode, |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:125 | → METHODS view_display |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:138 | → METHODS view_model_update. |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:163 | → METHODS nest_view_model_update. |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:175 | → METHODS nest2_view_model_update. |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:183 | → METHODS popup_model_update. |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:189 | → METHODS popover_model_update. |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:205 | → METHODS get_event |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:287 | → METHODS _event |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:313 | → METHODS _event_client |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:349 | → METHODS _bind |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:377 | → METHODS _bind_edit |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:497 | → METHODS follow_up_action |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:522 | → METHODS check_on_init |
| abap2UI5 | `src/02/z2ui5_if_client.intf.abap`:548 | → METHODS check_on_navigated |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3 | → CLASS z2ui5_cl_xml_view DEFINITION PUBLIC. |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:38 | → METHODS constructor. |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:47 | → METHODS horizontal_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:78 | → METHODS icon |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:110 | → METHODS dynamic_page |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:124 | → METHODS dynamic_page_title |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:133 | → METHODS dynamic_page_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:148 | → METHODS html |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:173 | → METHODS illustrated_message |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:187 | → METHODS p_cell_selector |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:199 | → METHODS p_copy_provider |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:208 | → METHODS additional_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:230 | → METHODS flex_box |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:278 | → METHODS popover |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:315 | → METHODS list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:333 | → METHODS overflow_toolbar_layout_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:367 | → METHODS table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:409 | → METHODS analytical_table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:422 | → METHODS rowmode |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:438 | → METHODS breadcrumbs |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:454 | → METHODS current_location |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:467 | → METHODS color_palette |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:484 | → METHODS auto |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:504 | → METHODS fixed |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:525 | → METHODS interactive |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:543 | → METHODS product_switch |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:561 | → METHODS product_switch_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:587 | → METHODS grid_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:612 | → METHODS grid_container_settings |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:626 | → METHODS layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:650 | → METHODS dynamic_date_range |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:681 | → METHODS message_strip |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:698 | → METHODS footer |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:714 | → METHODS message_page |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:759 | → METHODS object_page_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:824 | → METHODS object_page_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:872 | → METHODS object_page_header_action_btn |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:896 | → METHODS object_page_dyn_header_title |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:934 | → METHODS generic_tile |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:993 | → METHODS numeric_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1023 | → METHODS link_tile_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1041 | → METHODS image_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1066 | → METHODS tile_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1083 | → METHODS expanded_heading |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1088 | → METHODS snapped_heading |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1095 | → METHODS expanded_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1104 | → METHODS snapped_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1113 | → METHODS heading |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1122 | → METHODS actions |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1129 | → METHODS snapped_title_on_mobile |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1136 | → METHODS header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1143 | → METHODS navigation_actions |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1173 | → METHODS avatar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1215 | → METHODS avatar_group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1247 | → METHODS avatar_group_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1263 | → METHODS header_title |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1268 | → METHODS sections |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1286 | → METHODS object_page_section |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1302 | → METHODS sub_sections |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1318 | → METHODS object_page_sub_section |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1338 | → METHODS shell |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1368 | → METHODS shell_bar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1393 | → METHODS blocks |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1398 | → METHODS more_blocks |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1407 | → METHODS layout_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1423 | → METHODS flex_item_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1443 | → METHODS code_editor |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1454 | → METHODS suggestion_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1467 | → METHODS suggestion_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1478 | → METHODS suggestion_columns |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1483 | → METHODS suggestion_rows |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1495 | → METHODS vertical_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1532 | → METHODS multi_input |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1561 | → METHODS tokens |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1576 | → METHODS token |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1629 | → METHODS input |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1699 | → METHODS dialog |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1740 | → METHODS carousel |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1759 | → METHODS buttons |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1764 | → METHODS get_root |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1769 | → METHODS get_parent |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1776 | → METHODS get |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1785 | → METHODS get_child |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1794 | → METHODS columns |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1805 | → METHODS analytical_column |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1830 | → METHODS column |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1855 | → METHODS items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1873 | → METHODS interact_donut_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1887 | → METHODS segments |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1898 | → METHODS interact_donut_chart_segment |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1923 | → METHODS interact_bar_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1940 | → METHODS bars |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1951 | → METHODS interact_bar_chart_bar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1975 | → METHODS interact_line_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:1991 | → METHODS points |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2002 | → METHODS interact_line_chart_point |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2023 | → METHODS radial_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2051 | → METHODS column_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2073 | → METHODS action_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2081 | → METHODS cells |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2086 | → METHODS bar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2091 | → METHODS content_left |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2096 | → METHODS content_middle |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2101 | → METHODS content_right |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2108 | → METHODS content_areas |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2122 | → METHODS field |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2133 | → METHODS custom_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2140 | → METHODS header_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2149 | → METHODS sub_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2158 | → METHODS custom_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2171 | → METHODS core_custom_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2186 | → METHODS badge_custom_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2207 | → METHODS toggle_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2244 | → METHODS button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2269 | → METHODS begin_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2274 | → METHODS end_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2296 | → METHODS search_field |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2322 | → METHODS message_view |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2345 | → METHODS barcode_scanner_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2375 | → METHODS message_popover |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2403 | → METHODS message_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2441 | → METHODS page |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2474 | → METHODS menu_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2500 | → METHODS panel |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2534 | → METHODS vbox |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2571 | → METHODS hbox |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2600 | → METHODS scroll_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2642 | → METHODS simple_form |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2677 | → METHODS _cc_plain_xml |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2686 | → METHODS content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2707 | → METHODS title |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2728 | → METHODS tab_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2736 | → METHODS tab |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2760 | → METHODS overflow_toolbar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2788 | → METHODS overflow_toolbar_toggle_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2809 | → METHODS overflow_toolbar_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2832 | → METHODS overflow_toolbar_menu_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2852 | → METHODS menu |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2868 | → METHODS menu_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2882 | → METHODS toolbar_spacer |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2907 | → METHODS label |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:2950 | → METHODS image |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3004 | → METHODS date_picker |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3072 | → METHODS time_picker |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3117 | → METHODS date_time_picker |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3151 | → METHODS link |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3208 | → METHODS list |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3245 | → METHODS custom_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3254 | → METHODS input_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3281 | → METHODS standard_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3309 | → METHODS item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3328 | → METHODS segmented_button_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3368 | → METHODS combobox |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3426 | → METHODS multi_combobox |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3468 | → METHODS grid |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3488 | → METHODS grid_box_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3504 | → METHODS grid_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3524 | → METHODS grid_drop_info |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3568 | → METHODS grid_list |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3623 | → METHODS grid_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3669 | → METHODS text_area |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3713 | → METHODS range_slider |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3742 | → METHODS generic_tag |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3766 | → METHODS object_attribute |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3794 | → METHODS object_number |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3822 | → METHODS switch |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3840 | → METHODS harveyballmicrochartitem |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3870 | → METHODS step_input |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3902 | → METHODS progress_indicator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3926 | → METHODS segmented_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3959 | → METHODS checkbox |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:3985 | → METHODS header_toolbar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4003 | → METHODS toolbar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4035 | → METHODS text |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4068 | → METHODS formatted_text |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4090 | → METHODS _generic |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4101 | → METHODS _generic_property |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4108 | → METHODS xml_get |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4113 | → METHODS stringify |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4153 | → METHODS tree_table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4192 | → METHODS tree_columns |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4204 | → METHODS tree_column |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4214 | → METHODS tree_template |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4219 | → METHODS tree_extension |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4262 | → METHODS filter_bar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4301 | → METHODS filter_group_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4322 | → METHODS filter_group_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4341 | → METHODS filter_control |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4367 | → METHODS flexible_column_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4390 | → METHODS begin_column_pages |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4395 | → METHODS mid_column_pages |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4402 | → METHODS end_column_pages |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4440 | → METHODS ui_table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4493 | → METHODS ui_column |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4513 | → METHODS ui_columns |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4518 | → METHODS ui_custom_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4523 | → METHODS ui_extension |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4528 | → METHODS ui_template |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4541 | → METHODS currency |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4552 | → METHODS ui_row_action |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4557 | → METHODS ui_row_action_template |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4570 | → METHODS ui_row_action_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4597 | → METHODS radio_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4629 | → METHODS radio_button_group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4652 | → METHODS dynamic_side_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4666 | → METHODS side_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4710 | → METHODS planning_calendar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4766 | → METHODS planning_calendar_view |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4805 | → METHODS planning_calendar_row |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4840 | → METHODS planning_calendar_legend |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4860 | → METHODS calendar_legend_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4871 | → METHODS appointment_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4888 | → METHODS info_label |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4905 | → METHODS rows |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4910 | → METHODS appointments |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4927 | → METHODS calendar_appointment |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4943 | → METHODS interval_headers |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4952 | → METHODS block_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4964 | → METHODS block_layout_row |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:4982 | → METHODS block_layout_cell |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5006 | → METHODS object_identifier |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5035 | → METHODS object_status |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5073 | → METHODS tree |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5107 | → METHODS standard_tree_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5142 | → METHODS icon_tab_bar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5182 | → METHODS icon_tab_filter |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5208 | → METHODS icon_tab_separator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5219 | → METHODS _z2ui5 |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5226 | → METHODS gantt_chart_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5247 | → METHODS container_toolbar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5271 | → METHODS gantt_chart_with_table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5280 | → METHODS axis_time_strategy |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5287 | → METHODS proportion_zoom_strategy |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5294 | → METHODS total_horizon |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5302 | → METHODS time_horizon |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5310 | → METHODS visible_horizon |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5315 | → METHODS row_settings_template |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5325 | → METHODS gantt_row_settings |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5335 | → METHODS shapes1 |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5340 | → METHODS shapes2 |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5353 | → METHODS task |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5367 | → METHODS gantt_table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5384 | → METHODS rating_indicator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5400 | → METHODS gantt_toolbar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5432 | → METHODS base_rectangle |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5464 | → METHODS tool_page |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5471 | → METHODS tool_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5490 | → METHODS icon_tab_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5517 | → METHODS nav_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5530 | → METHODS pages |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5535 | → METHODS main_contents |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5564 | → METHODS table_select_dialog |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5605 | → METHODS process_flow |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5625 | → METHODS nodes |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5665 | → METHODS node |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5707 | → METHODS node_image |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5718 | → METHODS lanes |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5737 | → METHODS process_flow_node |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5763 | → METHODS process_flow_lane_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5794 | → METHODS view_settings_dialog |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5816 | → METHODS filter_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5821 | → METHODS sort_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5826 | → METHODS group_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5838 | → METHODS view_settings_filter_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5857 | → METHODS view_settings_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5893 | → METHODS variant_management |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5919 | → METHODS variant_items |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:5948 | → METHODS variant_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6003 | → METHODS variant_management_sapm |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6048 | → METHODS variant_item_sapm |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6089 | → METHODS feed_input |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6135 | → METHODS feed_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6168 | → METHODS feed_list_item_action |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6186 | → METHODS feed_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6201 | → METHODS news_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6217 | → METHODS color_picker |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6247 | → METHODS mask_input |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6276 | → METHODS responsive_splitter |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6291 | → METHODS splitter |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6303 | → METHODS invisible_text |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6318 | → METHODS fix_flex |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6329 | → METHODS fix_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6338 | → METHODS flex_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6348 | → METHODS pane_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6358 | → METHODS split_pane |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6370 | → METHODS splitter_layout_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6383 | → METHODS toolbar_layout_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6427 | → METHODS object_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6465 | → METHODS additional_numbers |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6477 | → METHODS header_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6489 | → METHODS markers |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6498 | → METHODS statuses |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6525 | → METHODS status |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6550 | → METHODS first_status |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6555 | → METHODS second_status |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6568 | → METHODS object_marker |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6596 | → METHODS object_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6617 | → METHODS detail_box |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6626 | → METHODS light_box |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6640 | → METHODS light_box_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6675 | → METHODS line_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6706 | → METHODS line_micro_chart_line |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6718 | → METHODS line_micro_chart_point |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6731 | → METHODS line_micro_chart_empszd_point |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6751 | → METHODS stacked_bar_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6776 | → METHODS column_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6797 | → METHODS column_micro_chart_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6821 | → METHODS comparison_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6845 | → METHODS comparison_micro_chart_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6871 | → METHODS delta_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6914 | → METHODS bullet_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6956 | → METHODS harvey_ball_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:6989 | → METHODS area_micro_chart |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7008 | → METHODS data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7041 | → METHODS rich_text_editor |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7088 | → METHODS slider |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7149 | → METHODS upload_set |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7194 | → METHODS upload_set_toolbar_placeholder |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7215 | → METHODS upload_set_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7236 | → METHODS markers_as_status |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7241 | → METHODS rules |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7249 | → METHODS mask_input_rule |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7270 | → METHODS side_panel |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7293 | → METHODS side_panel_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7303 | → METHODS main_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7317 | → METHODS quick_view |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7335 | → METHODS quick_view_page |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7346 | → METHODS quick_view_page_avatar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7354 | → METHODS quick_view_group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7371 | → METHODS quick_view_group_element |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7416 | → METHODS date_range_selection |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7472 | → METHODS variant_management_fl |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7498 | → METHODS column_element_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7506 | → METHODS fb_control |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7518 | → METHODS smart_variant_management |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7537 | → METHODS smart_filter_bar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7554 | → METHODS control_configuration |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7564 | → METHODS _control_configuration |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7588 | → METHODS smart_table |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7609 | → METHODS form_toolbar |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7619 | → METHODS paging_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7659 | → METHODS timeline |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7716 | → METHODS timeline_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7768 | → METHODS split_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7795 | → METHODS detail_pages |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7800 | → METHODS master_pages |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7808 | → METHODS container_content |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7820 | → METHODS map_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7839 | → METHODS spot |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7862 | → METHODS analytic_map |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7877 | → METHODS spots |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7886 | → METHODS vos |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7905 | → METHODS action_sheet |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7936 | → METHODS expandable_text |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:7982 | → METHODS select |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8015 | → METHODS embedded_control |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8036 | → METHODS header_container_control |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8058 | → METHODS dependents |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8072 | → METHODS card |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8101 | → METHODS card_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8155 | → METHODS numeric_header |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8195 | → METHODS numeric_side_indicator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8218 | → METHODS slide_tile |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8233 | → METHODS tiles |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8250 | → METHODS busy_indicator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8269 | → METHODS custom_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8278 | → METHODS carousel_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8298 | → METHODS facet_filter |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8360 | → METHODS facet_filter_list |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8423 | → METHODS facet_filter_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8450 | → METHODS draft_indicator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8463 | → METHODS drag_info |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8475 | → METHODS drag_drop_info |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8487 | → METHODS drag_drop_config |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8496 | → METHODS html_map |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8512 | → METHODS html_area |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8529 | → METHODS html_canvas |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8576 | → METHODS notification_list |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8637 | → METHODS notification_list_group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8688 | → METHODS notification_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8738 | → METHODS wizard |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8778 | → METHODS wizard_step |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8801 | → METHODS template_repeat |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8813 | → METHODS template_with |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8824 | → METHODS template_if |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8831 | → METHODS template_then |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8836 | → METHODS template_else |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8843 | → METHODS template_elseif |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8855 | → METHODS relationship |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8865 | → METHODS relationships |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8872 | → METHODS no_data |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8881 | → METHODS lines |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8902 | → METHODS line |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8925 | → METHODS groups |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8946 | → METHODS group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:8993 | → METHODS network_graph |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9024 | → METHODS layout_algorithm |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9034 | → METHODS layered_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9051 | → METHODS force_based_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9070 | → METHODS force_directed_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9084 | → METHODS noop_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9089 | → METHODS swim_lane_chain_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9094 | → METHODS two_columns_layout |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9101 | → METHODS attributes |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9111 | → METHODS element_attribute |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9122 | → METHODS action_buttons |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9135 | → METHODS action_button |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9150 | → METHODS routes |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9159 | → METHODS legend_area |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9167 | → METHODS legenditem |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9180 | → METHODS legend |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9197 | → METHODS route |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9216 | → METHODS column_menu |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9240 | → METHODS column_menu_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9265 | → METHODS column_menu_action_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9283 | → METHODS column_menu_quick_action |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9300 | → METHODS column_menu_quick_action_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9316 | → METHODS column_menu_quick_group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9333 | → METHODS column_menu_quick_group_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9350 | → METHODS column_menu_quick_sort |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9367 | → METHODS column_menu_quick_sort_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9384 | → METHODS column_menu_quick_total |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9401 | → METHODS column_menu_quick_total_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9419 | → METHODS micro_process_flow |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9439 | → METHODS micro_process_flow_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9455 | → METHODS intermediary |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9460 | → METHODS custom_control |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9467 | → METHODS responsive_scale |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9488 | → METHODS status_indicator |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9505 | → METHODS property_thresholds |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9515 | → METHODS property_threshold |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9527 | → METHODS shape_group |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9550 | → METHODS library_shape |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9581 | → METHODS tile_info |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9594 | → METHODS badge |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9603 | → METHODS side_navigation |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9614 | → METHODS navigation_list |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9625 | → METHODS navigation_list_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9636 | → METHODS fixed_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9655 | → METHODS viz_frame |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9672 | → METHODS viz_dataset |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9679 | → METHODS viz_flattened_dataset |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9686 | → METHODS viz_dimensions |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9699 | → METHODS viz_dimension_definition |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9712 | → METHODS viz_measures |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9725 | → METHODS viz_measure_definition |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9738 | → METHODS viz_feeds |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9747 | → METHODS viz_feed_item |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9776 | → METHODS smart_multi_input |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9800 | → METHODS row_settings |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9818 | → METHODS image_editor |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9837 | → METHODS image_editor_container |
| abap2UI5 | `src/99/z2ui5_cl_xml_view.clas.abap`:9859 | → METHODS xml_get_parts |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:102 | → METHODS focus |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:129 | → METHODS info_frontend |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:191 | → METHODS title |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:204 | → METHODS lp_title |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:223 | → METHODS history |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:230 | → METHODS scrolling |
| abap2UI5 | `src/99/z2ui5_cl_xml_view_cc.clas.abap`:244 | → METHODS timer |
| samples | `src/00/97/z2ui5_cl_smp_app_468.clas.abap`:14 | → CLASS z2ui5_cl_smp_app_468 DEFINITION PUBLIC. |
| samples | `src/00/97/z2ui5_cl_smp_app_480.clas.abap`:13 | → CLASS z2ui5_cl_smp_app_480 DEFINITION PUBLIC. |
| samples | `src/00/98/z2ui5_cl_smp_app_126.clas.abap`:9 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_132.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_184.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_190.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_194.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_212.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_339.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/00/98/z2ui5_cl_smp_app_342.clas.abap`:8 | → DATA mo_parent_page  TYPE REF TO z2ui5_cl_ui5_view_builder. |
| samples | `src/01/z2ui5_cl_smp_app_445.clas.abap`:19 | → METHODS device_form |
| samples | `src/01/z2ui5_cl_smp_app_453.clas.abap`:12 | → weight         TYPE i, |
| samples | `src/01/z2ui5_cl_smp_app_453.clas.abap`:22 | → weight_state   TYPE string, |
| samples | `src/01/z2ui5_cl_smp_app_469.clas.abap`:11 | → CLASS z2ui5_cl_smp_app_469 DEFINITION PUBLIC. |
| samples | `src/01/z2ui5_cl_smp_app_470.clas.abap`:12 | → CLASS z2ui5_cl_smp_app_470 DEFINITION PUBLIC. |
| samples | `src/01/z2ui5_cl_smp_app_488.clas.abap`:9 | → CLASS z2ui5_cl_smp_app_488 DEFINITION PUBLIC. |
| samples | `src/01/z2ui5_cl_smp_app_489.clas.abap`:5 | → CLASS z2ui5_cl_smp_app_489 DEFINITION PUBLIC. |
| samples | `src/01/z2ui5_cl_smp_app_490.clas.abap`:9 | → CLASS z2ui5_cl_smp_app_490 DEFINITION PUBLIC. |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:92 | → METHODS focus_search. |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:102 | → METHODS render_header |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:106 | → METHODS render_sub_header |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:112 | → METHODS install_display |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:126 | → METHODS header_button |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:141 | → METHODS open_url |
| samples | `src/z2ui5_cl_smp_app_000.clas.abap`:148 | → METHODS source_url |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_001.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_001 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_002.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_002 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_003.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_003 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_004.clas.abap`:12 | → CLASS z2ui5_cl_smpc_sapui5_004 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_005.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_005 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_006.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_006 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_007.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_007 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_008.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_008 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_009.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_009 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_010.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_010 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_011.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_011 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_012.clas.abap`:9 | → CLASS z2ui5_cl_smpc_sapui5_012 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_013.clas.abap`:12 | → CLASS z2ui5_cl_smpc_sapui5_013 DEFINITION PUBLIC. |
| samples-controls | `src/03/z2ui5_cl_smpc_sapui5_014.clas.abap`:13 | → CLASS z2ui5_cl_smpc_sapui5_014 DEFINITION PUBLIC. |
| samples-controls | `src/z2ui5_cl_smpc_app_overview.clas.abap`:67 | → CLASS z2ui5_cl_smpc_app_overview DEFINITION PUBLIC. |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:18 | → CLASS z2ui5_cl_smps_context DEFINITION PUBLIC FINAL CREATE P |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:26 | → BEGIN OF cs_status, |
| samples-stack | `src/00/00/z2ui5_cl_smps_context.clas.abap`:35 | → BEGIN OF cs_ui5_msg_type, |
| samples-stack | `src/02/z2ui5_cl_smps_app_319.clas.abap`:16 | → CLASS z2ui5_cl_smps_app_319 DEFINITION PUBLIC. |
| samples-stack | `src/03/01/z2ui5_cl_smps_bp_trv.clas.abap`:8 | → CLASS z2ui5_cl_smps_bp_trv DEFINITION PUBLIC ABSTRACT FINAL |
| samples-stack | `src/03/01/z2ui5_cl_smps_data_trv.clas.abap`:10 | → CLASS z2ui5_cl_smps_data_trv DEFINITION PUBLIC FINAL CREATE |
| samples-stack | `src/03/z2ui5_cl_smps_app_01.clas.abap`:14 | → CLASS z2ui5_cl_smps_app_01 DEFINITION PUBLIC. |
| samples-stack | `src/03/z2ui5_cl_smps_app_02.clas.abap`:22 | → CLASS z2ui5_cl_smps_app_02 DEFINITION PUBLIC. |
| samples-stack | `src/03/z2ui5_cl_smps_app_03.clas.abap`:17 | → CLASS z2ui5_cl_smps_app_03 DEFINITION PUBLIC. |
| samples-stack | `src/03/z2ui5_cl_smps_app_04.clas.abap`:14 | → CLASS z2ui5_cl_smps_app_04 DEFINITION PUBLIC. |
| samples-stack | `src/03/z2ui5_cl_smps_app_05.clas.abap`:19 | → CLASS z2ui5_cl_smps_app_05 DEFINITION PUBLIC. |
| samples-stack | `src/04/01/z2ui5_cl_smps_bp_trd.clas.abap`:8 | → CLASS z2ui5_cl_smps_bp_trd DEFINITION PUBLIC ABSTRACT FINAL |
| samples-stack | `src/04/01/z2ui5_cl_smps_data_trd.clas.abap`:10 | → CLASS z2ui5_cl_smps_data_trd DEFINITION PUBLIC FINAL CREATE |
| samples-stack | `src/04/z2ui5_cl_smps_app_06.clas.abap`:18 | → CLASS z2ui5_cl_smps_app_06 DEFINITION PUBLIC. |
| samples-stack | `src/04/z2ui5_cl_smps_app_07.clas.abap`:23 | → CLASS z2ui5_cl_smps_app_07 DEFINITION PUBLIC. |
| samples-stack | `src/04/z2ui5_cl_smps_app_07.clas.abap`:33 | → description       TYPE string, |
| samples-stack | `src/04/z2ui5_cl_smps_app_07.clas.abap`:36 | → draft_description TYPE string, |
| samples-stack | `src/04/z2ui5_cl_smps_app_08.clas.abap`:19 | → CLASS z2ui5_cl_smps_app_08 DEFINITION PUBLIC. |
| samples-stack | `src/04/z2ui5_cl_smps_app_09.clas.abap`:15 | → CLASS z2ui5_cl_smps_app_09 DEFINITION PUBLIC. |
| samples-stack | `src/04/z2ui5_cl_smps_app_10.clas.abap`:9 | → CLASS z2ui5_cl_smps_app_10 DEFINITION PUBLIC. |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:39 | → CLASS z2ui5_cl_smps_app_00 DEFINITION PUBLIC. |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:51 | → url       TYPE string, |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:53 | → installed TYPE abap_bool, |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:55 | → status    TYPE string, |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:61 | → DATA t_odata     TYPE ty_t_sample. |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:76 | → DATA demo_data_installed TYPE abap_bool. |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:103 | → samples_old  TYPE string VALUE `z2ui5_cl_demo_app_g00` ##NO_ |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:107 | → controls_old TYPE string VALUE `z2ui5_cl_dmo_app_overview` # |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:122 | → BEGIN OF cs_class, |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:138 | → METHODS render_header |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:146 | → METHODS install_display |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:158 | → name        TYPE string |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:165 | → class_old   TYPE string OPTIONAL |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:169 | → group_start TYPE abap_bool DEFAULT abap_false. |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:175 | → METHODS open_url |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:182 | → METHODS render_package |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:190 | → METHODS sample |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:204 | → METHODS class_check_installed |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:213 | → METHODS class_check_exists |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:220 | → METHODS data_reset |
| samples-stack | `src/z2ui5_cl_smps_app_00.clas.abap`:246 | → METHODS app_get_url |

**Where the detector is an approximation of the rule:**

- Only `.clas.abap` and `.intf.abap` are read — ABAP Doc on a report or function group is not counted.
- The negative count is every correctly placed block, so it is large by design: the point it makes is that the two placements are distinguishable by the next statement alone, which is what the rule needs.
- A `"!` block before a parameter inside a METHODS chain is not separated out here; the rule should report it and this detector counts it as a negative.

<!-- probe:end -->
