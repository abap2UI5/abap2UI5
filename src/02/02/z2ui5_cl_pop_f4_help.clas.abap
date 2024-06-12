CLASS z2ui5_cl_pop_f4_help DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_app.

    DATA mt_DATA         TYPE REF TO data.
    DATA ms_DATA_row     TYPE REF TO data.
    DATA ms_layout       TYPE z2ui5_cl_pop_layout_v2=>ty_s_layout.

    DATA mv_table        TYPE string.
    DATA mv_field        TYPE string.
    DATA mv_value        TYPE string.
    DATA mv_return_value TYPE string.
    DATA mv_rows         TYPE int1 VALUE '50'.
    DATA mt_dfies        TYPE z2ui5_cl_util_api=>ty_t_dfies.

    CLASS-METHODS factory
      IMPORTING
        i_table       TYPE string
        i_fname       TYPE string
        i_value       TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_pop_f4_help.

  PROTECTED SECTION.
    DATA client             TYPE REF TO z2ui5_if_client.
    DATA mv_init            TYPE abap_bool.
    DATA mv_check_tab_field TYPE string.
    DATA mv_check_tab       TYPE string.

    METHODS get_dfies.

    METHODS on_init.

    METHODS render_view.

    METHODS on_event.

    METHODS set_row_id.

    METHODS get_txt
      IMPORTING
        roll          TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_data
      IMPORTING
        !where TYPE string.

    METHODS get_where_tab
      RETURNING
        VALUE(result) TYPE string.

    METHODS prefill_inputs.

    METHODS on_after_layout.

    METHODS get_layout.

    METHODS create_objects.
ENDCLASS.


CLASS z2ui5_cl_pop_f4_help IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_init = abap_false.
      mv_init = abap_true.

      on_init( ).

      render_view( ).

    ENDIF.

    on_event( ).

    on_after_LAYOUT( ).

  ENDMETHOD.

  METHOD on_init.

    get_dfies( ).

    create_objects( ).

    prefill_inputs( ).

    get_data( get_where_tab( ) ).

    get_layout( ).

  ENDMETHOD.

  METHOD get_where_tab.

    LOOP AT mt_dfies REFERENCE INTO DATA(dfies).

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE ms_data_row->* TO FIELD-SYMBOL(<value>).
      IF <value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
      IF <value> IS INITIAL.
        CONTINUE.
      ENDIF.

      IF result IS NOT INITIAL.
        DATA(and) = ` AND `.
      ENDIF.

      IF <value> CA `_`.
        DATA(escape) = `ESCAPE '#'`.
      ELSE.
        CLEAR escape.
      ENDIF.

      result = |{ result }{ and } ( { dfies->fieldname } LIKE '%{ <value> }%' { escape } )|.

      IF result CA `_`.
        REPLACE ALL OCCURRENCES OF `_` IN result WITH `#_`.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD create_objects.

    DATA index TYPE int4.

    TRY.

        DATA(comp) = VALUE cl_abap_structdescr=>component_table(
                               ( name = 'ROW_ID'
                                 type = CAST #( cl_abap_datadescr=>describe_by_data( index ) ) ) ).

        APPEND LINES OF z2ui5_cl_util_api=>rtti_get_t_attri_by_table_name( mv_check_tab  ) TO comp.

        DATA(New_struct_desc) = cl_abap_structdescr=>create( comp ).

        DATA(new_table_desc) = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA mt_data     TYPE HANDLE new_table_desc.
        CREATE DATA ms_data_row TYPE HANDLE new_struct_desc.

      CATCH cx_root.

    ENDTRY.

  ENDMETHOD.

  METHOD get_data.

    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

    TRY.
        ASSIGN mt_data->* TO <table>.

        SELECT *
          FROM (mv_check_tab)
          WHERE (where)
          INTO CORRESPONDING FIELDS OF TABLE @<table>
          UP TO @mv_rows ROWS.

        IF sy-subrc <> 0.
          client->message_toast_display( 'No Entries found.' ).
        ENDIF.

        set_row_id( ).

      CATCH cx_root.
        client->message_toast_display( 'Table not released.' ).
    ENDTRY.

  ENDMETHOD.

  METHOD render_view.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( ).

    DATA(simple_form) = popup->dialog( title        = 'F4-Help'
                                       contentWidth = '90%'
                                       afterclose   = client->_event( 'F4_CLOSE' )
          )->simple_form( title    = 'F4-Help'
                          layout   = 'ResponsiveGridLayout'
                          editable = abap_true
          )->content( 'form' ).

    LOOP AT mt_dfies REFERENCE INTO DATA(dfies).

      IF dfies->fieldname = `MANDT`.
        CONTINUE.
      ENDIF.
      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE ms_data_row->* TO FIELD-SYMBOL(<val>).
      IF <val> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      simple_form->label( get_txt( CONV #( dfies->rollname ) ) ).

      simple_form->input( value         = client->_bind_edit( <val> )
                          showvaluehelp = abap_false
                          submit        = client->_event( 'F4_INPUT_DONE' ) ).

    ENDLOOP.

    simple_form->label( get_txt( 'SYST_TABIX' ) ).

    simple_form->input( value         = client->_bind_edit( mv_rows )
                        showvaluehelp = abap_false
                        submit        = client->_event( 'F4_INPUT_DONE' )
                        maxLength     = '3' ).

    DATA(table) = popup->get_child( )->table( growing    = 'true'
                                              width      = 'auto'
                                              items      = client->_bind( val = mt_DATA->* )
                                              headerText = mv_check_tab  ).

    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(headder) = table->header_toolbar(
                 )->overflow_toolbar(
                 )->Title( mv_check_tab
                 )->toolbar_spacer( ).

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
                       minscreenwidth  = client->_bind( val       = layout->width
                                                        tab       = ms_layout-t_layout
                                                        tab_index = lv_index )
       )->text( get_txt( CONV #( layout->rollname ) ) ).

    ENDLOOP.

    DATA(cells) = columns->get_parent( )->items(
                                       )->column_list_item(
                                           valign = 'Middle'
                                           type   = 'Navigation'
                                           press  = client->_event( val   = 'F4_ROW_SELECT'
                                                                    t_arg = VALUE #( ( `${ROW_ID}`  ) ) )
                                       )->cells( ).

    LOOP AT ms_layout-t_layout REFERENCE INTO layout.

      cells->object_identifier( text = |\{{ layout->fname }\}| ).

    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

  METHOD on_event.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.

    CASE client->get( )-event.

      WHEN `F4_CLOSE`.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN `F4_ROW_SELECT`.

        DATA(lt_arg) = client->get( )-t_event_arg.

        ASSIGN mt_DATA->* TO <tab>.

        ASSIGN <tab>[ lt_arg[ 1 ] ] TO FIELD-SYMBOL(<row>).

        ASSIGN COMPONENT mv_check_tab_field OF STRUCTURE <row> TO FIELD-SYMBOL(<value>).
        IF <value> IS NOT ASSIGNED.
          RETURN.
        ENDIF.

        mv_return_value = <value>.

        client->popup_destroy( ).

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'F4_INPUT_DONE'.

        get_data( get_where_tab( ) ).

        client->popup_model_update( ).

      WHEN OTHERS.

        client = z2ui5_cl_pop_layout_v2=>on_event_layout( client = client
                                                          layout = ms_layout ).

    ENDCASE.

  ENDMETHOD.

  METHOD set_row_id.

    FIELD-SYMBOLS <tab>  TYPE STANDARD TABLE.
    FIELD-SYMBOLS <line> TYPE any.

    ASSIGN mt_DATA->* TO <tab>.

    LOOP AT <tab> ASSIGNING <line>.

      ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <line> TO FIELD-SYMBOL(<row>).
      IF <row> IS ASSIGNED.
        <row> = sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    result->mv_table = i_table.
    result->mv_field = i_fname.
    result->mv_value = i_value.

  ENDMETHOD.

  METHOD get_txt.

    result = z2ui5_cl_stmpncfctn_api=>rtti_get_data_element_texts( roll )-long.

  ENDMETHOD.

  METHOD get_dfies.

    DATA(t_dfies) = z2ui5_cl_util_api=>rtti_get_t_dfies_by_table_name( mv_table ).

    READ TABLE t_dfies REFERENCE INTO DATA(dfies) WITH KEY fieldname = mv_field.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF dfies->checktable IS INITIAL.
      RETURN.
    ENDIF.

    mt_dfies = z2ui5_cl_util_api=>rtti_get_t_dfies_by_table_name( CONV #( dfies->checktable ) ).
    "
    " ASSIGNMENT --- this may not be 100% certain ... :(
    mv_check_tab_field = VALUE #( mt_dfies[ rollname = dfies->rollname ]-fieldname OPTIONAL ).
    "  we have to go via Domname ..

    IF mv_check_tab_field IS INITIAL.
      mv_check_tab_field = VALUE #( mt_dfies[ domname = dfies->domname ]-fieldname OPTIONAL ).
    ENDIF.
    mv_check_tab = dfies->checktable.

  ENDMETHOD.

  METHOD prefill_inputs.

    LOOP AT mt_dfies REFERENCE INTO DATA(dfies).

      IF NOT ( dfies->keyflag = abap_true OR dfies->fieldname = mv_check_tab_field ).
        CONTINUE.
      ENDIF.

      ASSIGN COMPONENT dfies->fieldname OF STRUCTURE ms_data_row->* TO FIELD-SYMBOL(<val>).
      IF <val> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      IF dfies->fieldname = mv_check_tab_field.

        <val> = mv_value.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD on_after_layout.

    " Kommen wir aus einer anderen APP
    IF client->get( )-check_on_navigated = abap_false.
      RETURN.
    ENDIF.

    TRY.
        " War es das Layout?
        DATA(app) = CAST z2ui5_cl_pop_layout_v2( client->get_app( client->get( )-s_draft-id_prev_app ) ).

        ms_layout = app->ms_layout.

        render_view( ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

  METHOD get_layout.

    DATA(class) = cl_abap_classdescr=>get_class_name( me ).
    SHIFT class LEFT DELETING LEADING '\CLASS='.

    ms_layout = z2ui5_cl_pop_layout_v2=>init_layout( control  = z2ui5_cl_pop_layout_v2=>m_table
                                                     data     = mt_data
                                                     handle01 = CONV #( class )
                                                     handle02 = CONV #( mv_table )
                                                     handle03 = CONV #( 'F4' ) ).

  ENDMETHOD.

ENDCLASS.
