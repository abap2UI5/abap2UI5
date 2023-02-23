CLASS z2ui5_cl_app_demo_11 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_editable_active TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS Z2UI5_CL_APP_DEMO_11 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        check_editable_active = abap_false.

        t_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 11 NEXT ret =
            VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true )  ) ).


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_EDIT'.
            check_editable_active = xsdbool( check_editable_active = abap_false ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_11' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        DATA(tab) = page->table( view->_bind( t_tab ) ).

        "set toolbar
        tab->header_toolbar( )->overflow_toolbar(
            )->title( 'title of the table'
             )->toolbar_spacer(
             )->button(
                    text = SWITCH #( check_editable_active WHEN abap_true THEN 'display' ELSE 'edit' )
                    press = view->_event( 'BUTTON_EDIT' ) ).

        "set header
        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Color' )->get_parent(
            )->column( )->text( 'Info' )->get_parent(
            )->column( )->text( 'Description' )->get_parent(
            )->column( )->text( 'Checkbox' ).


        "set toolbar
        IF check_editable_active = abap_true.

          tab->items( )->column_list_item( )->cells(
              )->input( '{TITLE}'
              )->input( '{VALUE}'
              )->input( '{INFO}'
              )->input( '{DESCR}'
              )->checkbox( selected = '{CHECKBOX}' enabled = abap_true ).

        ELSE.

          tab->items( )->column_list_item( )->cells(
             )->text( '{TITLE}'
             )->text( '{VALUE}'
             )->text( '{INFO}'
             )->text( '{DESCR}'
             )->checkbox( '{CHECKBOX}' ).

        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
