# Control & Client-API Vocabulary

Ranked by real usage across the 360+ sample apps. Use this to pick the right
fluent method. Names are the `z2ui5_cl_xml_view` builder methods (each wraps one
UI5 control) and the `client->` methods. **Do not invent method names** — if a
control is missing here, either find it in a sample or fall back to the raw-XML
escape hatch (`_generic`).

## Most-used view-builder methods

> Chain-navigation helpers (not controls): `get_parent` returns the parent node
> to continue the chain (by far the most frequent call — it is how you add a
> child and walk back up to attach the next sibling); `get` returns the current
> node; `stringify` emits the final XML. `_`, `__`, `_generic`, `_z2ui5`,
> `_cc_*` are escape hatches for raw XML / custom controls.

| Method | Purpose | Canonical sample |
|---|---|---|
| `text` | Text label / table cell | app_183 |
| `button` | Button | app_125 |
| `label` | Form field caption | app_125 |
| `page` | Scrollable page (title, nav-button) | app_125 |
| `input` | Single-line text entry | app_125 |
| `content` | Aggregation slot (`form` / `layout`) | app_125 |
| `column` | Responsive-table column header | app_183 |
| `shell` | Top-level app frame | app_125 |
| `link` | Hyperlink | app_181 |
| `title` | Section/heading title | app_300 |
| `layout_data` | Grid/flex layout data wrapper | app_277 |
| `toolbar_spacer` | Pushes toolbar items apart | app_183 |
| `items` | items aggregation (lists/tables) | app_183 |
| `overflow_toolbar` | Responsive toolbar | app_183 |
| `vbox` / `hbox` / `flex_box` | Flex containers | app_277 |
| `simple_form` | Responsive label/field form | app_125 |
| `column_list_item` | One responsive-table row | app_183 |
| `quick_view_page` | Quick-view card body | app_129 |
| `icon_tab_filter` | One tab of an IconTabBar | app_181 |
| `ui_template` | Template binding for repeated aggregation | app_183 |
| `object_status` | Colored status text/icon | app_300 |
| `item` | Generic item (select/segmented) | app_181 |
| `tile_content` / `generic_tile` / `numeric_content` | Dashboard tiles | app_277 |
| `cells` | cells aggregation of a row | app_183 |
| `checkbox` | Boolean toggle | app_300 |
| `segmented_button` / `segmented_button_item` | Segment control | app_181 |
| `radio_button` | Single radio option | app_181 |
| `object_page_sub_section` / `blocks` | Object-page blocks | app_300 |
| `vertical_layout` | Stacked layout | app_181 |
| `panel` | Titled collapsible container | app_181 |
| `toolbar` / `header_toolbar` / `footer` | Bars | app_183 |
| `switch` | On/off slider | app_181 |
| `object_attribute` / `object_number` | Object header attributes | app_300 |
| `message_strip` | Inline message banner | app_238 |
| `avatar` | Image/initials avatar | app_017 |
| `text_area` | Multi-line entry | app_021 |
| `table` | Responsive `sap.m.Table` | app_183 |
| `select` / `combobox` / `multi_input` | Dropdowns | app_288 |
| `slider` / `range_slider` / `step_input` | Numeric input | app_237 |
| `icon` | Icon | app_268 |
| `html` | Raw embedded HTML | app_242 |
| `code_editor` | Code editor | app_035 |
| `date_picker` / `date_time_picker` / `time_picker` | Date/time | app_002 |
| `progress_indicator` | Progress bar | app_022 |

**More (lower frequency):** `splitter_layout_data`, `grid` / `grid_data`,
`dynamic_page_title`, `dialog`, `mask_input`, `search_field`, `toggle_button`,
`timer`, `generic_tag`, `info_label`, `standard_list_item`, `action_list_item`,
`input_list_item`, `rating_indicator`, `feed_input`, `wizard`, `planning_calendar`,
`ui_table` / `ui_column` / `ui_template` (sap.ui.table), `tree_table` /
`tree_column` (tree). ~300 distinct methods exist — read a sample to confirm
exact names and aggregation slots.

## Client methods (`z2ui5_if_client`)

| Method | Purpose |
|---|---|
| `_event( val [, t_arg] )` | Register a backend event; returns binding for `press`/event attrs |
| `_event_client( val )` | Pure frontend event, no roundtrip (e.g. `cs_event-popup_close`) |
| `_event_nav_app_leave( )` | Bind back-navigation (pops app stack), no roundtrip |
| `_bind_edit( val [, path] )` | Two-way binding `{/XX/attr}` for editable controls |
| `_bind( val [, path] )` | One-way read-only binding `{/attr}` (display, list items) |
| `view_display( xml )` | Render the main view |
| `view_model_update( )` | Push updated bound data to the existing view |
| `view_destroy( )` | Destroy the main view |
| `check_on_init( )` | True on the first roundtrip |
| `check_on_event( [name] )` | True when a (named) event fired |
| `check_on_navigated( )` | True when returning from a sub-app/popup |
| `check_app_prev_stack( )` | True if a previous app exists (drives `shownavbutton`) |
| `get( )` | Read request context: `-event`, `-t_event_arg`, `-s_draft-*` |
| `get_event_arg( )` / `get( )-t_event_arg` | Read args passed with the event (1-based) |
| `message_toast_display( text )` | Transient toast |
| `message_box_display( text [, type] )` | Modal message box |
| `nav_app_call( app )` | Push/navigate to a sub-app |
| `nav_app_leave( [app] )` | Pop the app stack (manual back) |
| `get_app( id )` / `get_app_prev( )` | Get a referenced app instance |
| `popup_display( xml )` / `popup_model_update( )` / `popup_destroy( )` | Modal dialog lifecycle |
| `popover_display( xml, by_id )` / `popover_destroy( )` | Anchored popover lifecycle |
| `nest_view_display( xml )` / `nest_view_model_update( )` | Nested sub-view |
| `set_session_stateful( val )` | Keep session state across roundtrips |
| `follow_up_action( val )` | Queue a follow-up frontend action |
| `cs_event` / `cs_view` | Predefined event-id / view-name constants |
| `action->gen( val, t_arg )` | Generic client action (download, scroll, …) |
