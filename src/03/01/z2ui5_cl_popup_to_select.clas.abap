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

    METHODS get_selected_index
      RETURNING
        VALUE(result) TYPE i.

    DATA mr_tab TYPE REF TO data.
    DATA mr_tab_popup TYPE REF TO data ##NEEDED.
    DATA mr_tab_popup_backup TYPE REF TO data ##NEEDED.

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_selected_index TYPE i.
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
            ).

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <tab_out> ).
    DATA(lo_table) = CAST cl_abap_tabledescr( lo_type ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
    DATA(lt_comp) = lo_struct->get_components( ).
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
        client->popup_destroy( ).
        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

      WHEN 'SEARCH'.
        on_event_search( ).

    ENDCASE.

  ENDMETHOD.

  METHOD get_selected_index.

    result = mv_selected_index.

  ENDMETHOD.


  METHOD set_output_table.

    FIELD-SYMBOLS <tab> TYPE any.
    ASSIGN mr_tab->* TO <tab>.

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <tab> ).
    DATA(lo_table) = CAST cl_abap_tabledescr( lo_type ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
    DATA(lo_type_bool) = cl_abap_structdescr=>describe_by_name( 'ABAP_BOOL' ).
    DATA(lt_comp) = lo_struct->get_components( ).
    INSERT VALUE #( name = `ZZSELKZ` type = CAST #( lo_type_bool ) ) INTO TABLE lt_comp.

    DATA(lo_line_type) = cl_abap_structdescr=>create( lt_comp ).
    DATA(lo_tab_type) = cl_abap_tabledescr=>create( lo_line_type ).

    CREATE DATA mr_tab_popup TYPE HANDLE lo_tab_type.
    CREATE DATA mr_tab_popup_backup TYPE HANDLE lo_tab_type.

    FIELD-SYMBOLS <tab_out> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <tab_out2> TYPE STANDARD TABLE.
    ASSIGN mr_tab_popup->* TO <tab_out>.
    <tab_out> = CORRESPONDING #( <tab> ).
    ASSIGN mr_tab_popup_backup->* TO <tab_out2>.
    <tab_out2> = CORRESPONDING #( <tab> ).

  ENDMETHOD.


  METHOD on_event_confirm.

    FIELD-SYMBOLS <tab> TYPE STANDARD TABLE.
    FIELD-SYMBOLS <row> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    ASSIGN mr_tab_popup->* TO <tab>.
    LOOP AT <tab> ASSIGNING <row>.
      DATA(lv_tabix) = sy-tabix.
      ASSIGN ('<row>-ZZSELKZ') TO <field>.
      IF <field> = abap_true.
        mv_selected_index = lv_tabix.
        EXIT.
      ENDIF.
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
    <tab_out> = CORRESPONDING #( <tab_out_backup> ).

    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <tab_out> ).
    DATA(lo_table) = CAST cl_abap_tabledescr( lo_type ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
    DATA(lt_comp) = lo_struct->get_components( ).
    LOOP AT <tab_out> ASSIGNING <row2>.
      DATA(lv_check_continue) = abap_false.
      LOOP AT lt_comp INTO DATA(ls_comp).
        DATA(lv_assign) = '<ROW2>-' && ls_comp-name.
        ASSIGN (lv_assign) TO <field2>.
        IF <field2> CS ls_arg.
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
