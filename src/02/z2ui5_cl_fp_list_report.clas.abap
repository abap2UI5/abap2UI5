"! List report floorplan - a complete standard list app generated from any
"! flat internal table via RTTI: a responsive table with growing, a search
"! field filtering across the visible columns, cycling column sort
"! (ascending / descending / off) and a detail dialog per row. Works with
"! every data source that fills an internal table - no CDS, annotations or
"! OData required - on every supported release.
"!
"! The escape hatch is plain inheritance: the class is deliberately not
"! FINAL and every rendering and event step is a protected method a
"! subclass can redefine with ordinary abap2UI5 view code
"! (z2ui5_cl_ai_xml). Breaking out of the floorplan is not a breakout, it
"! is just another view method. Events the floorplan does not know are
"! routed to on_event, so a subclass adds its own actions the same way any
"! abap2UI5 app handles them.
"!
"! Related: the annotation-driven CDS floorplans (list report, object page,
"! worklist) in https://github.com/abap2UI5-addons/cds-wrapper generate the
"! same UX from CDS metadata - use them when the data source is a CDS view
"! with UI annotations; use this class when it is any internal table.
CLASS z2ui5_cl_fp_list_report DEFINITION PUBLIC CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_column,
        name    TYPE string,
        label   TYPE string,
        visible TYPE abap_bool,
      END OF ty_s_column.
    TYPES ty_t_column TYPE STANDARD TABLE OF ty_s_column WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_detail,
        label TYPE string,
        value TYPE string,
      END OF ty_s_detail.
    TYPES ty_t_detail TYPE STANDARD TABLE OF ty_s_detail WITH EMPTY KEY.

    CONSTANTS:
      BEGIN OF cs_evt,
        search       TYPE string VALUE `Z2UI5_FP_SEARCH`,
        sort         TYPE string VALUE `Z2UI5_FP_SORT`,
        row_press    TYPE string VALUE `Z2UI5_FP_ROW`,
        detail_close TYPE string VALUE `Z2UI5_FP_DETAIL_CLOSE`,
      END OF cs_evt.

    "! t_data is copied into the floorplan; columns (optional) fixes the
    "! column set, order and labels - otherwise all renderable components
    "! of the row type become visible columns with beautified labels
    CLASS-METHODS factory
      IMPORTING
        t_data        TYPE STANDARD TABLE
        title         TYPE clike OPTIONAL
        columns       TYPE ty_t_column OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fp_list_report.

    DATA mv_title           TYPE string.
    DATA mt_column          TYPE ty_t_column.
    DATA mv_search          TYPE string.
    DATA mv_sort_by         TYPE string.
    DATA mv_sort_descending TYPE abap_bool.
    "! the full data set as passed to factory
    DATA mr_data            TYPE REF TO data.
    "! the searched/sorted subset bound to the table
    DATA mr_display         TYPE REF TO data.
    DATA mt_detail          TYPE ty_t_detail.
    DATA mv_detail_title    TYPE string.

  PROTECTED SECTION.

    "! client is part of the hook signature for subclasses - the default
    "! implementation does not need it
    METHODS on_init
      IMPORTING
        client TYPE REF TO z2ui5_if_client ##NEEDED.

    "! subclass hook - called for every event the floorplan itself does not
    "! handle, exactly like the event branch of a hand-written app
    METHODS on_event
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

    METHODS render_view
      IMPORTING
        client        TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    METHODS render_table
      IMPORTING
        io_parent TYPE REF TO z2ui5_cl_ai_xml
        client    TYPE REF TO z2ui5_if_client.

    METHODS render_detail
      IMPORTING
        client        TYPE REF TO z2ui5_if_client
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_ai_xml.

    "! rebuild the display table: filter the data set by mv_search across
    "! the visible columns, then sort by mv_sort_by
    METHODS apply_view.

    METHODS sort_display.

    METHODS columns_derive.

    METHODS sort_toggle
      IMPORTING
        iv_column TYPE clike.

    METHODS detail_build
      IMPORTING
        iv_index TYPE clike.

    METHODS row_matches
      IMPORTING
        is_row        TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

    "! FIELD_NAME -> `Field Name`
    METHODS label_beautify
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    "! only elementary components can be rendered as text - a string
    "! template on a table, structure or reference dumps with the
    "! uncatchable runtime error STRG_ILLEGAL_DATA_TYPE
    METHODS check_renderable
      IMPORTING
        val           TYPE any
      RETURNING
        VALUE(result) TYPE abap_bool.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_fp_list_report IMPLEMENTATION.

  METHOD factory.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    result = NEW #( ).
    result->mv_title = title.
    result->mt_column = columns.
    CREATE DATA result->mr_data LIKE t_data.
    CREATE DATA result->mr_display LIKE t_data.
    ASSIGN result->mr_data->* TO <tab>.
    <tab> = t_data.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    IF client->check_on_init( ) = abap_true.
      on_init( client ).
      apply_view( ).
      client->view_display( render_view( client )->stringify( ) ).
      RETURN.
    ENDIF.

    CASE abap_true.

      WHEN client->check_on_event( cs_evt-search ).
        apply_view( ).
        client->view_model_update( ).

      WHEN client->check_on_event( cs_evt-sort ).
        sort_toggle( client->get_event_arg( 1 ) ).
        apply_view( ).
        client->view_model_update( ).

      WHEN client->check_on_event( cs_evt-row_press ).
        detail_build( client->get_event_arg( 1 ) ).
        client->popup_display( render_detail( client )->stringify( ) ).

      WHEN client->check_on_event( cs_evt-detail_close ).
        client->popup_destroy( ).

      WHEN OTHERS.
        on_event( client ).

    ENDCASE.

  ENDMETHOD.


  METHOD on_init.

    IF mv_title IS INITIAL.
      mv_title = `List Report`.
    ENDIF.
    columns_derive( ).

  ENDMETHOD.


  METHOD on_event ##NEEDED.
    " subclass hook - the floorplan itself has nothing to do here
  ENDMETHOD.


  METHOD columns_derive.

    DATA lr_row TYPE REF TO data.
    DATA lt_valid TYPE ty_t_column.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <val> TYPE any.

    ASSIGN mr_data->* TO <tab>.
    CREATE DATA lr_row LIKE LINE OF <tab>.
    ASSIGN lr_row->* TO <row>.

    " user-supplied columns: keep set, order and labels - only fill in
    " missing labels and drop columns the row type cannot render
    IF mt_column IS NOT INITIAL.
      LOOP AT mt_column INTO DATA(ls_custom).
        ASSIGN COMPONENT ls_custom-name OF STRUCTURE <row> TO <val>.
        IF sy-subrc <> 0 OR check_renderable( <val> ) = abap_false.
          CONTINUE.
        ENDIF.
        IF ls_custom-label IS INITIAL.
          ls_custom-label = label_beautify( ls_custom-name ).
        ENDIF.
        APPEND ls_custom TO lt_valid.
      ENDLOOP.
      mt_column = lt_valid.
      RETURN.
    ENDIF.

    DATA(lt_comp) = z2ui5_cl_a2ui5_context=>rtti_get_t_attri_by_any( mr_data ).
    LOOP AT lt_comp INTO DATA(ls_comp).

      ASSIGN COMPONENT ls_comp-name OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0 OR check_renderable( <val> ) = abap_false.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( name    = ls_comp-name
                      label   = label_beautify( ls_comp-name )
                      visible = abap_true ) TO mt_column.

    ENDLOOP.

  ENDMETHOD.


  METHOD check_renderable.

    DATA(lv_kind) = z2ui5_cl_a2ui5_context=>rtti_get_type_kind( val ).
    CASE lv_kind.
      WHEN z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_table
          OR z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct1
          OR z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_struct2
          OR z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_dref
          OR z2ui5_cl_a2ui5_context=>cv_typedescr_typekind_oref.
        result = abap_false.
      WHEN OTHERS.
        result = abap_true.
    ENDCASE.

  ENDMETHOD.


  METHOD apply_view.

    FIELD-SYMBOLS <all>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <disp> TYPE STANDARD TABLE.

    ASSIGN mr_data->* TO <all>.
    ASSIGN mr_display->* TO <disp>.
    CLEAR <disp>.

    LOOP AT <all> ASSIGNING FIELD-SYMBOL(<row>).
      IF mv_search IS INITIAL OR row_matches( <row> ) = abap_true.
        APPEND <row> TO <disp>.
      ENDIF.
    ENDLOOP.

    IF mv_sort_by IS NOT INITIAL.
      sort_display( ).
    ENDIF.

  ENDMETHOD.


  METHOD sort_display.

    " a stable insertion sort in plain ABAP: every dynamic SORT BY form -
    " `SORT itab BY (name)` and `SORT itab BY (lt_sort)` - is silently
    " dropped by the transpiler, so the framework test pipeline would run
    " unsorted. O(n*n) is acceptable for a list a human scrolls through
    DATA lr_sorted TYPE REF TO data.
    DATA lv_insert TYPE i.

    FIELD-SYMBOLS <disp>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <sorted>   TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>      TYPE any.
    FIELD-SYMBOLS <cand>     TYPE any.
    FIELD-SYMBOLS <val>      TYPE any.
    FIELD-SYMBOLS <val_cand> TYPE any.

    ASSIGN mr_display->* TO <disp>.
    CREATE DATA lr_sorted LIKE <disp>.
    ASSIGN lr_sorted->* TO <sorted>.

    LOOP AT <disp> ASSIGNING <row>.

      ASSIGN COMPONENT mv_sort_by OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0.
        " unknown sort column: leave the display order untouched
        RETURN.
      ENDIF.

      " insert before the first row that has to come after the new one -
      " equal keys keep their original order (stable)
      lv_insert = lines( <sorted> ) + 1.
      LOOP AT <sorted> ASSIGNING <cand>.
        ASSIGN COMPONENT mv_sort_by OF STRUCTURE <cand> TO <val_cand>.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF ( mv_sort_descending = abap_false AND <val_cand> > <val> )
            OR ( mv_sort_descending = abap_true  AND <val_cand> < <val> ).
          lv_insert = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
      INSERT <row> INTO <sorted> INDEX lv_insert.

    ENDLOOP.

    <disp> = <sorted>.

  ENDMETHOD.


  METHOD row_matches.

    FIELD-SYMBOLS <val> TYPE any.

    DATA(lv_search) = to_upper( mv_search ).

    LOOP AT mt_column INTO DATA(ls_col) WHERE visible = abap_true.

      ASSIGN COMPONENT ls_col-name OF STRUCTURE is_row TO <val>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      " mt_column only holds elementary components (columns_derive), so
      " the string template cannot dump
      IF to_upper( |{ <val> }| ) CS lv_search.
        result = abap_true.
        RETURN.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD sort_toggle.

    " cycle per column: ascending -> descending -> off
    IF mv_sort_by = iv_column.
      IF mv_sort_descending = abap_true.
        CLEAR mv_sort_by.
        CLEAR mv_sort_descending.
      ELSE.
        mv_sort_descending = abap_true.
      ENDIF.
    ELSE.
      mv_sort_by = iv_column.
      CLEAR mv_sort_descending.
    ENDIF.

  ENDMETHOD.


  METHOD detail_build.

    DATA lv_index TYPE i.

    FIELD-SYMBOLS <disp> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row>  TYPE any.
    FIELD-SYMBOLS <val>  TYPE any.

    CLEAR mt_detail.
    mv_detail_title = `Details`.

    " the row press sends the 0-based index of the pressed row's binding
    " context path
    TRY.
        lv_index = iv_index + 1.
      CATCH cx_root.
        RETURN.
    ENDTRY.

    ASSIGN mr_display->* TO <disp>.
    ASSIGN <disp>[ lv_index ] TO <row>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " the detail dialog shows every column, including invisible ones -
    " that is its purpose
    LOOP AT mt_column INTO DATA(ls_col).

      ASSIGN COMPONENT ls_col-name OF STRUCTURE <row> TO <val>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( label = ls_col-label
                      value = |{ <val> }| ) TO mt_detail.

    ENDLOOP.

  ENDMETHOD.


  METHOD label_beautify.

    DATA lt_token TYPE string_table.

    SPLIT to_lower( val ) AT `_` INTO TABLE lt_token.
    LOOP AT lt_token INTO DATA(lv_token).
      IF lv_token IS INITIAL.
        CONTINUE.
      ENDIF.
      DATA(lv_word) = |{ to_upper( substring( val = lv_token
                                              len = 1 ) ) }{ substring( val = lv_token
                                                                        off = 1 ) }|.
      result = COND #( WHEN result IS INITIAL
                       THEN lv_word
                       ELSE |{ result } { lv_word }| ).
    ENDLOOP.

  ENDMETHOD.


  METHOD render_view.

    result = z2ui5_cl_ai_xml=>factory( ).

    DATA(lo_page) = result->open( n  = `View`
                                  ns = `mvc`
        )->a( n = `xmlns`
              v = `sap.m`
        )->a( n = `xmlns:mvc`
              v = `sap.ui.core.mvc`
        )->a( n = `displayBlock`
              v = `true`
        )->a( n = `height`
              v = `100%`
        )->open( `Shell`
        )->open( `Page`
        )->a( n = `title`
              v = mv_title ).

    render_table( io_parent = lo_page
                  client    = client ).

  ENDMETHOD.


  METHOD render_table.

    FIELD-SYMBOLS <disp> TYPE STANDARD TABLE.

    ASSIGN mr_display->* TO <disp>.

    DATA(lo_table) = io_parent->open( `Table`
        )->a( n = `growing`
              v = `true`
        )->a( n = `growingThreshold`
              v = `50`
        )->a( n = `items`
              v = client->_bind( <disp> ) ).

    lo_table->open( `headerToolbar`
        )->open( `OverflowToolbar`
            )->leaf( `Title`
                )->a( n = `text`
                      v = mv_title
            )->leaf( `ToolbarSpacer`
            )->leaf( `SearchField`
                )->a( n = `width`
                      v = `30%`
                )->a( n = `value`
                      v = client->_bind( mv_search )
                )->a( n = `search`
                      v = client->_event( cs_evt-search ) ).

    DATA(lo_cols) = lo_table->open( `columns` ).
    LOOP AT mt_column INTO DATA(ls_col) WHERE visible = abap_true.
      " the column header doubles as the sort trigger
      lo_cols->open( `Column`
          )->leaf( `Link`
          )->a( n = `text`
                v = ls_col-label
          )->a( n = `press`
                v = client->_event( val   = cs_evt-sort
                                    t_arg = VALUE #( ( |'{ ls_col-name }'| ) ) ) ).
    ENDLOOP.

    " the pressed row is identified by the 0-based index of its binding
    " context path - the established row-event pattern
    DATA(lo_cells) = lo_table->open( `items`
        )->open( `ColumnListItem`
        )->a( n = `type`
              v = `Navigation`
        )->a( n = `press`
              v = client->_event( val   = cs_evt-row_press
                                  t_arg = VALUE #( ( `$event.oSource.getBindingContext().getPath().split('/').pop()` ) ) )
        )->open( `cells` ).

    LOOP AT mt_column INTO ls_col WHERE visible = abap_true.
      lo_cells->leaf( `Text`
          )->a( n = `text`
                v = |\{{ ls_col-name }\}| ).
    ENDLOOP.

  ENDMETHOD.


  METHOD render_detail.

    result = z2ui5_cl_ai_xml=>factory( ).

    result->open( n  = `View`
                  ns = `mvc`
        )->a( n = `xmlns`
              v = `sap.m`
        )->a( n = `xmlns:mvc`
              v = `sap.ui.core.mvc`
        )->open( `Dialog`
            )->a( n = `title`
                  v = mv_detail_title
            )->a( n = `contentWidth`
                  v = `30rem`
            )->a( n = `draggable`
                  v = `true`
            )->open( `content`
                )->open( `List`
                    )->a( n = `items`
                          v = client->_bind( mt_detail )
                    )->leaf( `DisplayListItem`
                    )->a( n = `label`
                          v = `{LABEL}`
                    )->a( n = `value`
                          v = `{VALUE}`
                )->shut(
            )->shut(
            " Dialog footer via the buttons aggregation (since 1.21) - the
            " footer aggregation only exists since ~1.110 (see AGENTS.md)
            )->open( `buttons`
                )->leaf( `Button`
                )->a( n = `text`
                      v = `Close`
                )->a( n = `press`
                      v = client->_event( cs_evt-detail_close ) ).

  ENDMETHOD.

ENDCLASS.
