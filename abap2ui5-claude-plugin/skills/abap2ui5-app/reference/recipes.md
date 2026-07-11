# Recipes — copy-pasteable patterns

Distilled from the sample apps. Each recipe names the canonical sample — **read
it in full** before adapting. Snippets are trimmed to the essentials.

## 1. Editable / responsive table bound to an internal table

`sap.m.Table` bound two-way on the table path; columns are headers, cells bind
per field with `{FIELDNAME}`. Row selection via `selected="{SELKZ}"` +
`mode="MultiSelect"`. Event handlers operate directly on the ABAP table, then
`view_model_update( )`. **Canonical: `z2ui5_cl_demo_app_011`** (simpler table:
`app_056`, cell-level binding: `app_144`).

```abap
DATA(tab) = page->table(
        items = |\{path: '{ client->_bind_edit( val = t_tab path = abap_true ) }', templateShareable: false\}|
        mode  = `MultiSelect` ).

tab->columns(
    )->column( )->text( `Title` )->get_parent(
    )->column( )->text( `Checkbox` ).

tab->items( )->column_list_item( selected = `{SELKZ}`
    )->cells(
        )->input(    value    = `{TITLE}`    enabled = `{EDITABLE}`
        )->checkbox( selected = `{CHECKBOX}` enabled = `{EDITABLE}` ).
```
```abap
ELSEIF client->check_on_event( `BUTTON_DELETE` ).
  DELETE t_tab WHERE selkz = abap_true.
  client->view_model_update( ).
ELSEIF client->check_on_event( `BUTTON_ADD` ).
  INSERT VALUE #( ) INTO TABLE t_tab.
  client->view_model_update( ).
```

## 2. sap.ui.table grid table and tree table

**Grid table** (`ui_table`) — bind `rows`, define `ui_columns`/`ui_column`, each
column carries a `ui_template` leaf control. Supports `sortproperty`/
`filterproperty`, `selectionmode`, `rowactioncount` + `ui_row_action_template`,
and a `ui_extension` toolbar. **Canonical: `z2ui5_cl_demo_app_070`** (editable
cells: `app_160`, variant mgmt: `app_100`).

```abap
DATA(tab) = page->ui_table( rows           = client->_bind( val = mt_table )
                            selectionmode  = `None`
                            rowactioncount = `2` ).
DATA(cols) = tab->ui_columns( ).
cols->ui_column( width = `11rem` sortproperty = `PRICE` filterproperty = `PRICE`
    )->text( `Price` )->ui_template( )->currency( value = `{PRICE}` currency = `{WAERS}` ).
```

**Tree table** (`tree_table`) — `rows` is a JSON binding string declaring
`arrayNames` (the nested child table) and `numberOfExpandedLevels`. The ABAP type
nests a child `nodes` table. **Canonical: `z2ui5_cl_demo_app_364`** (tree in a
popup: `app_068`).

```abap
TYPES: BEGIN OF ty_s_tree,
         user  TYPE string,
         nodes TYPE STANDARD TABLE OF ty_s_node WITH DEFAULT KEY,
       END OF ty_s_tree.

DATA(columns) = page->tree_table(
        rows = `{path:'` && client->_bind_edit( val = t_tree path = abap_true )
            && `', parameters: {arrayNames:['NODES'], numberOfExpandedLevels: 1}}`
    )->tree_columns( ).
columns->tree_column( `User` )->tree_template( )->text( `{USER}` ).
```

## 3. Built-in popups (`z2ui5_cl_pop_*`)

Every built-in popup is itself an app: build via `...=>factory( )`, push with
`client->nav_app_call( )`. Read the result in the navigated-back branch.

| pop class | Purpose | Sample |
|---|---|---|
| `z2ui5_cl_pop_to_inform` | info message | app_151 |
| `z2ui5_cl_pop_to_confirm` | yes/no, fires confirm/cancel events | app_150 |
| `z2ui5_cl_pop_to_select` | pick row(s) from a table | app_174 |
| `z2ui5_cl_pop_messages` / `_bal` / `_error` | bapiret / BAL / exception | app_154 |
| `z2ui5_cl_pop_file_ul` / `_file_dl` | file upload / download | app_157 / app_168 |
| `z2ui5_cl_pop_get_range` / `_get_range_m` | build select-options | app_056 / app_162 |
| `z2ui5_cl_pop_input_val` / `_textedit` / `_pdf` / `_html` | value/text/PDF/HTML | app_156/155/158/149 |

```abap
" Confirm — fires named events back into THIS app (app_150)
client->nav_app_call( z2ui5_cl_pop_to_confirm=>factory(
    i_question_text = `this is a question`
    i_event_confirm = `POPUP_TRUE`
    i_event_cancel  = `POPUP_FALSE` ) ).
" ... later:  ELSEIF client->check_on_event( `POPUP_TRUE` ). ...

" Select — pass a table, read result on navigated-back (app_174)
client->nav_app_call( z2ui5_cl_pop_to_select=>factory(
    i_tab = mt_tab  i_multiselect = abap_true  i_title = `Multi select` ) ).
" in on_navigation:
DATA(ls_result) = CAST z2ui5_cl_pop_to_select(
    client->get_app( client->get( )-s_draft-id_prev_app ) )->result( ).
```

## 4. Custom popup / popover built with a view

`factory_popup( )` builds `dialog`/`popover`/`message_view` XML; show with
`client->popup_display( xml )` (modal) or
`client->popover_display( xml = ... by_id = <control id> )` (anchored). Close with
`popup_destroy( )` / `popover_destroy( )`, or
`_event_client( client->cs_event-popup_close )` (no roundtrip). **Canonical:
`z2ui5_cl_demo_app_038`** (popover with placement: `app_026`).

```abap
DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).
popup = popup->dialog( title      = `Messages`
                       afterclose = client->_event_client( client->cs_event-popup_close ) ).
popup->buttons( )->button( text  = `Continue`
                           press = client->_event_client( client->cs_event-popup_close )
                           type  = `Emphasized` ).
client->popup_display( popup->stringify( ) ).
```

## 5. App-to-app navigation with parameters and result

Push a sub-app with `nav_app_call( NEW sub( ) )`; pass parameters by setting
**public attributes on the instance before the call**. On return,
`check_on_navigated` is true; read results via `CAST sub( client->get_app_prev( ) )`.
**Canonical: `z2ui5_cl_demo_app_024`** (caller) + `z2ui5_cl_demo_app_025` (sub-app).

```abap
" Caller: set instance attributes, then push
WHEN `CALL_NEW_APP_READ`.
  DATA(app_next) = NEW z2ui5_cl_demo_app_025( ).
  app_next->input_previous_set = input.
  client->nav_app_call( app_next ).

" Caller's navigated-back branch: read the sub-app's result
ELSEIF client->check_on_navigated( ).
  DATA(app_025) = CAST z2ui5_cl_demo_app_025( client->get_app_prev( ) ).
  client->message_box_display( |Input from sub app: { app_025->input }| ).
```

Dynamic launch by class name: `CREATE OBJECT li_app TYPE (lv_classname).
client->nav_app_call( li_app ).` (see `z2ui5_cl_demo_app_000`).

## 6. File upload and download (base64)

Files cross the wire as base64 data URIs. Decode with
`z2ui5_cl_abap2ui5_context=>conv_decode_x_base64( )` ->
`conv_get_string_by_xstring( )`. (Older samples call the same methods on
`z2ui5_cl_util`, which is obsolete — moved to package `src/99`.)
**Upload canonical: `z2ui5_cl_demo_app_075`**, **download: `z2ui5_cl_demo_app_186`**.

```abap
" Upload: strip the "data:mime;base64," prefix, then decode
SPLIT mv_value AT `;` INTO DATA(lv_dummy) DATA(lv_data).
SPLIT lv_data  AT `,` INTO lv_dummy lv_data.
DATA(lv_x)  = z2ui5_cl_abap2ui5_context=>conv_decode_x_base64( lv_data ).
mv_file     = z2ui5_cl_abap2ui5_context=>conv_get_string_by_xstring( lv_x ).

" Download via client action
client->action->gen(
    val   = client->cs_event-download_b64_file
    t_arg = VALUE #( ( file_content_64 ) ( file_name ) ) ).
```

Simpler: `z2ui5_cl_pop_file_ul=>factory( )` / `z2ui5_cl_pop_file_dl=>factory( file )`.

## 7. Two-way binding patterns

`_bind_edit( var )` = two-way (`{/XX/...}`), read back next roundtrip.
`_bind( var )` = read-only (display, list/combo items). Works on scalars,
structure components, and tables. Use `path = abap_true` when only the path is
needed inside a JSON literal (`items`/`rows`). **Canonical: `z2ui5_cl_demo_app_002`**.

```abap
)->date_picker( client->_bind_edit( s_screen-date )
)->combobox( selectedkey = client->_bind_edit( s_screen-combo_key )
             items       = client->_bind( t_combo )
    )->item( key = `{KEY}` text = `{TEXT}` ).

" valueState / valueStateText for validation feedback (app_298)
)->select( selectedkey    = client->_bind( key )
           valuestate     = `Error`
           valuestatetext = `error value state text`
           items          = client->_bind( lt_products ) ).
```

## 8. Events with arguments

`client->_event( val = 'NAME' t_arg = VALUE #( ( ... ) ) )` attaches args
collected on the client at fire time; read them via `client->get( )-t_event_arg`
(1-based). Arg expressions: literals, model values, source-control properties
(`${$source>/text}`), event params (`${$parameters>/value}`). **Canonical:
`z2ui5_cl_demo_app_167`** (per-cell args: `app_160`).

```abap
page->input( submit = client->_event( val   = `EVENT_PROPERTY_VALUE`
                                      t_arg = VALUE #( ( `${$parameters>/value}` ) ) ) ).
" read back
CASE client->get( )-event.
  WHEN `EVENT_PROPERTY_VALUE`.
    client->message_box_display( `arg: ` && client->get( )-t_event_arg[ 1 ] ).
ENDCASE.
```

## 9. Custom controls / HTML / CSS / JS

```abap
" Raw HTML (app_242)
page->vertical_layout( )->content( `layout`
    )->html( `<div class="content"><h4>Lorem ipsum</h4></div>` ).

" Code editor (app_035)
page->code_editor( type = client->_bind_edit( mv_type ) value = client->_bind( mv_editor ) ).

" Custom-namespace control: _z2ui5( ) switches into the z2ui5.cc namespace (app_075)
footer->_z2ui5( )->file_uploader( value  = client->_bind_edit( mv_value )
                                  upload = client->_event( `UPLOAD` ) ).

" Own CSS to the frontend (app_050) / JS loader popup (app_090)
client->nav_app_call( z2ui5_cl_pop_js_loader=>factory( get_custom_js( ) ) ).
```
CSS classes apply via `class = 'sapUi...'` on any control (e.g.
`sapUiContentPadding`, `sapUiTinyMargin`).

## Cross-cutting notes
- `factory( )` -> normal view (`view_display`); `factory_popup( )` -> popup/popover XML.
- Hand a result back from a pushed app/popup with
  `client->get_app( client->get( )-s_draft-id_prev_app )` (or `get_app_prev( )`) + `CAST`.
- `path = abap_true` returns just the binding path (for JSON literals);
  without it you get the full `{...}` expression.
- The `)->x( ... )->get_parent(` idiom adds a child then walks back up so the
  next sibling attaches at the right level — this is why `get_parent` is the most
  frequent call in the whole sample set.
