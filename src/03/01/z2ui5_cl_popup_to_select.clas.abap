CLASS z2ui5_cl_popup_to_select DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_tab           TYPE data
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_popup_to_select.

    TYPES:
      BEGIN OF ty_s_result,
        row          TYPE REF TO data,
        check_cancel TYPE abap_bool,
      END OF ty_s_result.
    DATA ms_result TYPE ty_s_result.

    METHODS result
      RETURNING
        VALUE(result) TYPE ty_s_result.

    DATA mr_tab TYPE REF TO data.
    DATA mr_tab_popup TYPE REF TO data ##NEEDED.
    DATA mr_tab_popup_backup TYPE REF TO data ##NEEDED.

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA check_table_line TYPE abap_bool.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS on_event.
    METHODS display.
    METHODS set_output_table.
    METHODS on_event_confirm.
    METHODS on_event_search.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_to_select IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).
    CREATE DATA r_result->mr_tab LIKE i_tab.
    FIELD-SYMBOLS <tab> TYPE any.
    ASSIGN r_result->mr_tab->* TO <tab>.
    <tab> = i_tab.

  ENDMETHOD.

  METHOD display.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.
    ASSIGN mr_tab_popup->* TO <tab_out>.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( client ).
    DATA(tab) = popup->table_select_dialog(
              items              =  `{path:'` && client->_bind_edit( val = <tab_out> path = abap_true ) && `', sorter : { path : 'STORAGE_LOCATION', descending : false } }`
              cancel             = client->_event( 'CANCEL' )
              search             = client->_event( val = 'SEARCH'  t_arg = VALUE #( ( `${$parameters>/value}` ) ( `${$parameters>/clearButtonPressed}` ) ) )
              confirm            = client->_event( val = 'CONFIRM' t_arg = VALUE #( ( `${$parameters>/selectedContexts[0]/sPath}` ) ) )
              growing = abap_true
            ).

    DATA(lt_comp) = z2ui5_cl_util_func=>rtti_get_t_comp_by_data( <tab_out> ).
    DELETE lt_comp WHERE name =  'ZZSELKZ'.

    DATA(list) = tab->column_list_item( valign = `Top` selected = `{ZZSELKZ}` ).
    DATA(cells) = list->cells( ).

    LOOP AT lt_comp INTO DATA(ls_comp).
      cells->text( text = `{` && ls_comp-name && `}` ).
    ENDLOOP.

    DATA(columns) = tab->columns( ).
    LOOP AT lt_comp INTO ls_comp.
      columns->column( width = '8rem' )->header( ns = `` )->text( text = ls_comp-name ).
    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client     = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      set_output_table( ).
      display( ).
      RETURN.
    ENDIF.

    on_event( ).

  ENDMETHOD.

  METHOD on_event.

    CASE client->get( )-event.

      WHEN 'CONFIRM'.
        on_event_confirm( ).

      WHEN 'CANCEL'.
        ms_result-check_cancel = abap_true.
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'SEARCH'.
        on_event_search( ).

    ENDCASE.

  ENDMETHOD.

  METHOD result.

    result = ms_result.

  ENDMETHOD.


  METHOD set_output_table.

    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <row2> TYPE any.
    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    ASSIGN mr_tab->* TO <tab>.

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <tab> ).
    DATA(lo_table) = CAST cl_abap_tabledescr( lo_type ).
    TRY.
        DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
        DATA(lt_comp) = lo_struct->get_components( ).
      CATCH cx_root.
        check_table_line = abap_true.
        DATA(lo_elem) = CAST cl_abap_elemdescr( lo_table->get_table_line_type( ) ).
        INSERT VALUE #( name = 'TAB_LINE' type = CAST #( lo_elem ) ) INTO TABLE lt_comp.
    ENDTRY.
    DATA(lo_type_bool) = cl_abap_structdescr=>describe_by_name( 'ABAP_BOOL' ).
    INSERT VALUE #( name = `ZZSELKZ` type = CAST #( lo_type_bool ) ) INTO TABLE lt_comp.

    DATA(lo_line_type) = cl_abap_structdescr=>create( lt_comp ).
    DATA(lo_tab_type) = cl_abap_tabledescr=>create( lo_line_type ).

    CREATE DATA mr_tab_popup TYPE HANDLE lo_tab_type.
    CREATE DATA mr_tab_popup_backup TYPE HANDLE lo_tab_type.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out2> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <field> TYPE any.
    ASSIGN mr_tab_popup->* TO <tab_out>.
    ASSIGN mr_tab_popup_backup->* TO <tab_out2>.
    LOOP AT <tab> ASSIGNING <row>.
      DATA lr_row TYPE REF TO data.
      CREATE DATA lr_row LIKE LINE OF <tab_out>.
      ASSIGN lr_row->* TO <row2>.
      IF check_table_line = abap_true.
        ASSIGN lr_row->('TAB_LINE') TO <field>.
        <field> = <row>.
      ELSE.
        <row2> = CORRESPONDING #( <row> ).
      ENDIF.
      INSERT <row2> INTO TABLE <tab_out>.

    ENDLOOP.

    <tab_out2> = <tab_out>.

  ENDMETHOD.


  METHOD on_event_confirm.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    ASSIGN mr_tab_popup->* TO <tab>.
    LOOP AT <tab> ASSIGNING <row>.
      DATA(lv_tabix) = sy-tabix.
      ASSIGN ('<row>-ZZSELKZ') TO <field>.
      IF <field> = abap_false.
        CONTINUE.
      ENDIF.
      FIELD-SYMBOLS <tab3> TYPE STANDARD TABLE.
      ASSIGN mr_tab->* TO <tab3>.
      FIELD-SYMBOLS <row3> TYPE any.
      FIELD-SYMBOLS <field2> TYPE any.
      CREATE DATA ms_result-row LIKE LINE OF <tab3>.
      ASSIGN ms_result-row->* TO <row3>.
      IF check_table_line = abap_true.
        ASSIGN ('<ROW>-TAB_LINE') TO <field2>.
        <row3> = <field2>.
      ELSE.
        <row3> = CORRESPONDING #( <row> ).
      ENDIF.
      EXIT.
    ENDLOOP.
    client->popup_destroy( ).
    client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

  ENDMETHOD.


  METHOD on_event_search.

    DATA(lt_arg) = client->get( )-t_event_arg.
    READ TABLE lt_arg INTO DATA(ls_arg) INDEX 1.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out_backup> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row2> TYPE any.
    FIELD-SYMBOLS <field2> TYPE any.
    ASSIGN mr_tab_popup->* TO <tab_out>.
    ASSIGN mr_tab_popup_backup->* TO <tab_out_backup>.

    <tab_out> = <tab_out_backup>.

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <tab_out> ).
    DATA(lo_table) = CAST cl_abap_tabledescr( lo_type ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
    DATA(lt_comp) = lo_struct->get_components( ).
    LOOP AT <tab_out> ASSIGNING <row2>.
      DATA(lv_check_continue) = abap_false.
      LOOP AT lt_comp INTO DATA(ls_comp).
        DATA(lv_assign) = '<ROW2>-' && ls_comp-name.
        ASSIGN (lv_assign) TO <field2>.
        IF to_upper( <field2> ) CS to_upper( ls_arg ).
          lv_check_continue = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_check_continue = abap_true.
        CONTINUE.
      ENDIF.
      DELETE <tab_out>.
    ENDLOOP.
    client->popup_model_update( ).

  ENDMETHOD.

ENDCLASS.
