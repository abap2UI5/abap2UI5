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



CLASS z2ui5_cl_app_demo_06 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        DO 1000 TIMES.
          DATA(ls_row) = VALUE ty_Row(  title = 'row_' && sy-index  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true ).
          INSERT ls_row INTO TABLE t_tab.
        ENDDO.


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_SORT'.
            SORT t_tab BY value.

          WHEN 'BUTTON_POST'.
            client->popup_message_box( 'button post was pressed' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'abap2UI5 - Scroll Container with Table and Toolbar' navbuttontap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).

        "set table and container
        DATA(tab) = page->scroll_container( '70%' )->table(
            growing = abap_true
            growingThreshold = '20'
            growingScrollToLoad = abap_true
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
