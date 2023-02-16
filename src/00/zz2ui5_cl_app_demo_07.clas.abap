CLASS zz2ui5_cl_app_demo_07 DEFINITION PUBLIC.

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

    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_07 IMPLEMENTATION.

  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        mt_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 101 NEXT ret =
            VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
            ) ).


      WHEN client->cs-lifecycle_method-on_event.
        "implement event handling here


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page(
            title = 'Example - ZZ2UI5_CL_APP_DEMO_07'
            nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        DATA(tab) = page->table(
            header_text = 'Table with 100 entries'
            items  = view->_bind_one_way( mt_tab ) )->get( ).

        tab->columns( )->get(
            )->column( text = 'Name'
            )->column( text = 'Color'
            )->column( text = 'Info'
            )->column( text = 'Description'
            )->column( text = 'Checkbox' ).

        tab->items( )->get( )->column_list_item( )->get( )->cells( )->get(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{INFO}'
           )->text( '{DESCR}'
           )->checkbox( selected = '{CHECKBOX}' enabled = abap_false ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
