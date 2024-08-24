CLASS z2ui5_cl_pop_to_sel_w_l DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_s_result,
        row             TYPE REF TO data,
        check_confirmed TYPE abap_bool,
      END OF ty_s_result.

    DATA ms_result       TYPE ty_s_result.
    DATA mr_tab          TYPE REF TO data.
    DATA mr_out          TYPE REF TO data.
    DATA mr_out_tmp      TYPE REF TO data.

    DATA ms_layout       TYPE z2ui5_cl_pop_layout_v2=>ty_s_layout.
    DATA mv_search_value TYPE string.

    CLASS-METHODS factory
      IMPORTING
        i_tab              TYPE STANDARD TABLE
        i_title            TYPE clike                          OPTIONAL
        i_sort_field       TYPE clike                          OPTIONAL
        i_descending       TYPE abap_bool                      OPTIONAL
        i_contentwidth     TYPE clike                          OPTIONAL
        i_contentheight    TYPE clike                          OPTIONAL
        i_growingthreshold TYPE clike                          OPTIONAL
        i_handle01         TYPE z2ui5_cl_pop_layout_v2=>handle OPTIONAL
        i_handle02         TYPE z2ui5_cl_pop_layout_v2=>handle OPTIONAL
        i_handle03         TYPE z2ui5_cl_pop_layout_v2=>handle OPTIONAL
        i_handle04         TYPE z2ui5_cl_pop_layout_v2=>handle OPTIONAL
      RETURNING
        VALUE(r_result)    TYPE REF TO z2ui5_cl_pop_to_sel_w_layout.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA title             TYPE string.
    DATA sort_field        TYPE string.
    DATA content_width     TYPE string.
    DATA content_height    TYPE string.
    DATA growing_threshold TYPE string.
    DATA descending        TYPE abap_bool.

    METHODS on_event.
    METHODS display.
    METHODS set_output_table.

    METHODS on_event_search.

    METHODS get_comp
      RETURNING
        VALUE(result) TYPE abap_component_tab.

  PRIVATE SECTION.
    METHODS set_row_id.
    METHODS confirm.
    METHODS on_after_layout.

ENDCLASS.


CLASS z2ui5_cl_pop_to_sel_w_l IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    r_result->title             = i_title.
    r_result->sort_field        = i_sort_field.
    r_result->descending        = i_descending.
    r_result->content_height    = i_contentheight.
    r_result->content_width     = i_contentwidth.
    r_result->growing_threshold = i_growingthreshold.

    r_result->mr_tab            = z2ui5_cl_util=>conv_copy_ref_data( i_tab ).

    CREATE DATA r_result->ms_result-row LIKE LINE OF i_tab.

    r_result->ms_layout = z2ui5_cl_pop_layout_v2=>init_layout( data     = r_result->mr_tab
                                                               control  = z2ui5_cl_pop_layout_v2=>m_table
                                                               handle01 = i_handle01
                                                               handle02 = i_handle02
                                                               handle03 = i_handle03
                                                               handle04 = i_handle04 ).

  ENDMETHOD.

  METHOD display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( )->dialog( title      = title
                                                               afterclose = client->_event( 'CANCEL' )  ).

    DATA(table) = popup->table( growing          = 'true'
                                growingthreshold = '100'
                                width            = 'auto'
                                autopopinmode    = abap_true
                                items            = client->_bind_edit( val = mr_out->* )
                                headertext       = title  ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(headder) = table->header_toolbar(
               )->overflow_toolbar(
                 )->title(  title
                 )->search_field( value  = client->_bind_edit( mv_search_value )
                                  search = client->_event( 'SEARCH' )
                                  change = client->_event( 'SEARCH' )
                                  id     = `SEARCH`
                                  width  = '17.5rem' ).

    headder = z2ui5_cl_pop_layout_v2=>render_layout_function( xml    = headder
                                                              client = client ).

    DATA(columns) = table->columns( ).

    LOOP AT ms_layout-t_layout REFERENCE INTO DATA(layout).
      DATA(lv_index) = sy-tabix.

      columns->column( visible         = client->_bind( val       = layout->visible
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       halign          = client->_bind( val       = layout->halign
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       importance      = client->_bind( val       = layout->importance
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       mergeduplicates = client->_bind( val       = layout->merge
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
                       width           = client->_bind( val       = layout->width
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
       )->text( layout->tlabel ).

    ENDLOOP.

    DATA(cells) = columns->get_parent( )->items(
                                       )->column_list_item(
                                           valign = 'Middle'
                                           type   = 'Navigation'
                                           press  = client->_event( val   = 'CONFIRM'
                                                                    t_arg = VALUE #( ( `${ZZROW_ID}`  ) ) )
                                       )->cells( ).

    LOOP AT ms_layout-t_layout REFERENCE INTO layout.

      IF layout->t_sub_col IS NOT INITIAL.

        DATA(sub_col) = ``.
        DATA(index) = 0.

        LOOP AT layout->t_sub_col INTO DATA(subcol).

          index = index + 1.

          READ TABLE ms_layout-t_layout INTO DATA(line) WITH KEY fname = subcol-fname.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          IF line-reference_field IS INITIAL.
            DATA(column) = |{ line-tlabel }: \{{ subcol-fname }\}|.
          ELSE.
            column = |{ line-tlabel }: \{{ subcol-fname }\} \{{ line-reference_field }\}|.
          ENDIF.

          IF index = 1.
            sub_col = column.
          ELSE.
            sub_col = |{ sub_col }{ cl_abap_char_utilities=>cr_lf }{ column }|.
          ENDIF.
        ENDLOOP.

        IF layout->reference_field IS NOT INITIAL.
          cells->object_identifier( title = |\{{ layout->fname }\} \{{ layout->reference_field }\}|
                                    text  = sub_col ).
        ELSE.
          cells->object_identifier( title = |\{{ layout->fname }\}|
                                    text  = sub_col ).
        ENDIF.

      ELSE.
     "   IF layout->reference_field IS NOT INITIAL.
          cells->object_identifier( text = |\{{ layout->fname }\} \{{ layout->reference_field }\}| ).
    "    ELSE.
          cells->object_identifier( text = |\{{ layout->fname }\}| ).
     "   ENDIF.
      ENDIF.
    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      set_output_table( ).

      display( ).

      RETURN.

    ENDIF.

    on_event( ).

    on_after_layout( ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'CONFIRM'.

        confirm( ).

        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'CANCEL'.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'SEARCH'.
        on_event_search( ).
        client->popup_model_update( ).

      WHEN OTHERS.

        client = z2ui5_cl_pop_layout_v2=>on_event_layout( client = client
                                                          layout = ms_layout ).

    ENDCASE.

  ENDMETHOD.

  METHOD on_after_layout.

    IF client->get( )-check_on_navigated = abap_false.
      RETURN.
    ENDIF.

    TRY.

        DATA(app) = CAST z2ui5_cl_pop_layout_v2( client->get_app( client->get( )-s_draft-id_prev_app ) ).

        ms_layout = app->ms_layout.

        display( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD confirm.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    ASSIGN mr_out->* TO <tab>.
    DATA(t_arg) = client->get( )-t_event_arg.
    DATA(row_clicked) = t_arg[ 1 ].

    LOOP AT <tab> ASSIGNING FIELD-SYMBOL(<line>).

      ASSIGN COMPONENT 'ZZROW_ID' OF STRUCTURE <line> TO FIELD-SYMBOL(<row_id>).

      IF <row_id> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF <row_id> = row_clicked.
        ms_result-row->* = CORRESPONDING #( <line> ).
        EXIT.
      ENDIF.

    ENDLOOP.

    ms_result-check_confirmed = abap_true.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.

  METHOD set_output_table.

    DATA(t_comp) = get_comp( ).
    TRY.

        DATA(new_struct_desc) = cl_abap_structdescr=>create( t_comp ).

        DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA mr_out     TYPE HANDLE new_table_desc.
        CREATE DATA mr_out_tmp TYPE HANDLE new_table_desc.

      CATCH cx_root.

    ENDTRY.

    mr_out->* = CORRESPONDING #( mr_tab->* ).

    set_row_id( ).

    mr_out_tmp->* = mr_out->*.

  ENDMETHOD.

  METHOD set_row_id.
    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.

    ASSIGN mr_out->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT 'ZZROW_ID' OF STRUCTURE <line> TO FIELD-SYMBOL(<row>).
      IF <row> IS ASSIGNED.
        <row> = sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_comp.
    DATA index TYPE int4.

*    DATA selkz TYPE abap_bool.

    TRY.

        DATA(comp) = z2ui5_cl_util_api=>rtti_get_t_attri_by_any( mr_tab ).

        IF xsdbool( line_exists( comp[ name = 'ZZROW_ID' ] ) ) = abap_false.
          APPEND LINES OF VALUE cl_abap_structdescr=>component_table(
                                    ( name = 'ZZROW_ID'
                                      type = CAST #( cl_abap_datadescr=>describe_by_data( index ) ) ) ) TO result.
        ENDIF.
*        IF xsdbool( line_exists( comp[ name = 'SELKZ' ] ) ) = abap_false.
*          APPEND LINES OF VALUE cl_abap_structdescr=>component_table(
*                                    ( name = 'SELKZ'
*                                      type = CAST #( cl_abap_datadescr=>describe_by_data( selkz ) ) ) ) TO result.
*
*        ENDIF.

        APPEND LINES OF comp TO result.

      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD on_event_search.

    FIELD-SYMBOLS <tab>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_tmp> TYPE STANDARD TABLE.

    ASSIGN mr_out->* TO <tab>.
    ASSIGN mr_out_tmp->* TO <tab_tmp>.

    IF <tab_tmp> IS NOT INITIAL.
      <tab> = <tab_tmp>.
    ENDIF.

    IF mv_search_value IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT <tab> ASSIGNING FIELD-SYMBOL(<f_row>).
      DATA(lv_row) = ``.
      DATA(lv_index) = 1.
      DO.
        ASSIGN COMPONENT lv_index OF STRUCTURE <f_row> TO FIELD-SYMBOL(<field>).
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        lv_row = lv_row && <field>.
        lv_index = lv_index + 1.
      ENDDO.

      IF lv_row NS mv_search_value.
        DELETE <tab>.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
