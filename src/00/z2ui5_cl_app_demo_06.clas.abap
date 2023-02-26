CLASS z2ui5_cl_app_demo_06 DEFINITION PUBLIC.

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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_06 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        t_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 101 NEXT ret =
            VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true )  ) ).


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_SORT'.
            SORT t_tab BY value.

          WHEN 'BUTTON_POST'.
            client->display_message_box( 'button post was pressed' ).
        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_06' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        "set table and container
        DATA(tab) = page->scroll_container( '70%' )->table(
            items = view->_bind_one_way( t_tab )
             sticky = 'ColumnHeaders,HeaderToolbar'
             ).

        "set toolbar
        tab->header_toolbar( )->overflow_toolbar(
            )->title( 'title of the table'
             )->toolbar_spacer(
             )->button( text = 'Sort' press = view->_event( 'BUTTON_SORT' )
             )->button( text = 'Post' press = view->_event( 'BUTTON_POST' )
          ).

        "set header
        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Color' )->get_parent(
            )->column( )->text( 'Info' )->get_parent(
            )->column( )->text( 'Description' )->get_parent(
            )->column( )->text( 'Checkbox' ).

        "set content
        tab->items( )->column_list_item( )->cells(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{INFO}'
           )->text( '{DESCR}'
           )->checkbox( '{CHECKBOX}' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
