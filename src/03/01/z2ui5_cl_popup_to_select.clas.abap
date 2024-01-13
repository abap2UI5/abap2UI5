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

  PROTECTED SECTION.
    DATA check_initialized TYPE abap_bool.
    DATA mr_tab TYPE REF TO data.
    DATA mr_tab_popup TYPE REF TO data.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS z2ui5_on_event.
    METHODS display.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_popup_to_select IMPLEMENTATION.

  METHOD factory.

    CREATE OBJECT r_result.
    CREATE DATA r_result->mr_tab LIKE i_tab.
    FIELD-SYMBOLS <tab> TYPE any.
    ASSIGN r_result->mr_tab->* TO <tab>.
    <tab> = i_tab.

  ENDMETHOD.

  METHOD display.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( client ).

    FIELD-SYMBOLS <tab> TYPE any.
    ASSIGN mr_tab->* TO <tab>.
    popup = popup->table_select_dialog(
              items              =  `{path:'` && client->_bind_edit( val = <tab> path = abap_true ) && `', sorter : { path : 'STORAGE_LOCATION', descending : false } }`
              cancel             = client->_event( 'CANCEL' )
              search             = client->_event( val = 'SEARCH'  t_arg = VALUE #( ( `${$parameters>/value}` ) ( `${$parameters>/clearButtonPressed}` ) ) )
              confirm            = client->_event( val = 'CONFIRM' t_arg = VALUE #( ( `${$parameters>/selectedContexts[0]/sPath}` ) ) )
            ).


    DATA(lo_type) = cl_abap_structdescr=>describe_by_data( <tab> ).
    DATA(lo_table) = CAST cl_abap_tabledescr( lo_type ).
    DATA(lo_struct) = CAST cl_abap_structdescr( lo_table->get_table_line_type( ) ).
    DATA(lt_comp) = lo_struct->get_components( ).

    DATA(list) = popup->column_list_item( valign = `Top` selected = `{SELKZ}` ).
    DATA(cells) = popup->cells( ).
    LOOP AT lt_comp INTO DATA(ls_comp).
      cells->text( text = `{` && ls_comp-name && `}` ).
    ENDLOOP.

    DATA(columns) = list->columns( ).
    LOOP AT lt_comp INTO ls_comp.
      columns->column( width = '8rem' )->header( ns = `` )->text( text = ls_comp-name ).
    ENDLOOP.

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client     = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
*      Z2UI5_f4_set_data( ).
*      Z2UI5_view_display( ).
      RETURN.
    ENDIF.

    z2ui5_on_event( ).

  ENDMETHOD.

  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN 'CONFIRM'.
*        DELETE mt_f4_table WHERE selkz <> abap_true.
*        mv_product = VALUE #( mt_f4_table[ 1 ]-product OPTIONAL ).
*        client->view_model_update( ).

      WHEN 'CANCEL'.
        client->popup_destroy( ).

      WHEN 'SEARCH'.
*        DATA(lt_arg) = client->get( )-t_event_arg.
*        READ TABLE lt_arg INTO DATA(ls_arg) INDEX 1.
*        Z2UI5_f4_set_data( ).
*        LOOP AT mt_f4_table INTO DATA(ls_tab).
*          IF ls_tab-product CS ls_arg.
*            CONTINUE.
*          ENDIF.
*          DELETE mt_f4_table.
*        ENDLOOP.
        client->popup_model_update( ).

    ENDCASE.

  ENDMETHOD.

  METHOD get_selected_index.

  ENDMETHOD.

ENDCLASS.
