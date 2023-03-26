CLASS z2ui5_cl_app_demo_22 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        title TYPE string,
        value TYPE string,
        descr TYPE string,
        info  TYPE string,
      END OF ty_row.
    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA mv_value1 TYPE string.
    DATA mv_value2 TYPE string.
    DATA mv_value3 TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_22 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          mv_value1 = 'value1'.
          mv_value2 = 'this is a long text this is a long text this is a long text tis is a long text.'.
          DO 4 TIMES.
            mv_value2 = mv_value2 && mv_value2.
          ENDDO.
          mv_value3 = mv_value2.

          DATA(ls_row) = VALUE ty_row( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' ).
          DO 100 TIMES.
            INSERT ls_row INTO TABLE t_tab.
          ENDDO.

          RETURN.
        ENDIF.

        CASE client->get( )-event.

          WHEN 'BUTTON_SCROLL_TOP'.
            "nothing to do, default mode

          WHEN 'BUTTON_SCROLL_BOTTOM'.
            client->set( t_scroll_pos = VALUE #( ( n = 'id_page' v = '99999' ) ) ).

            " WHEN 'BUTTON_SCROLL_UP'.
            "    DATA(lv_pos) = client->get( )-page_scroll_pos - 500.
            "   client->set( page_scroll_pos = COND #( WHEN lv_pos < 0 THEN 0 ELSE lv_pos ) ).

            "  WHEN 'BUTTON_SCROLL_DOWN'.
            "    client->set( page_scroll_pos = client->get( )-page_scroll_pos + 500 ).

            "  WHEN 'BUTTON_SCROLL_HOLD'.
            "  client->set( page_scroll_pos = client->get( )-page_scroll_pos ).

          WHEN 'BUTTON_FOCUS_FIRST'.
            client->set( s_cursor_pos = VALUE #( id = 'id_text1'  cursorpos = '3' selectionstart = '3' selectionend = '3' ) ).

          WHEN 'BUTTON_FOCUS_SECOND'.
            client->set( s_cursor_pos = VALUE #( id = 'id_text2'  cursorpos = '5' selectionstart = '5' selectionend = '10' ) ).

          WHEN 'BUTTON_FOCUS_END'.
            client->set( s_cursor_pos = VALUE #( id = 'id_text3'  cursorpos = '99999' selectionstart = '99999' selectionend = '999999' ) ).
            client->set( t_scroll_pos = VALUE #(
              ( n = 'id_page' v = '99999' )
              ( n = 'id_text3' v = '99999' )
             ) ).


          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( id = 'id_page' title = 'abap2ui5 - Scrolling and Cursor' navbuttonpress = client->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Source_Code' href = client->get( )-s_request-url_source_code ).


        page->input(
            id = 'id_text1'
            value = client->_bind( mv_value1 )
            ).
        page->text_area(
            width = '100%'
            height = '10%'
            id = 'id_text2'
             value = client->_bind( mv_value2 ) ).

        page->button( text = 'cursor input pos 3'  press = client->_event( 'BUTTON_FOCUS_FIRST' ) ).
        page->button( text = 'cursor text area pos 5 to 10'  press = client->_event( 'BUTTON_FOCUS_SECOND' ) ).
        page->button( text = 'scroll end + focus end'  press = client->_event( 'BUTTON_FOCUS_END' ) ).

        DATA(tab) = page->table( sticky = 'ColumnHeaders,HeaderToolbar' headertext = 'Table with some entries' items = client->_bind_one_way( t_tab ) ).

        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Color' )->get_parent(
            )->column( )->text( 'Info' )->get_parent(
            )->column( )->text( 'Description' ).

        tab->items( )->column_list_item( )->cells(
           )->text( '{TITLE}'
           )->text( '{VALUE}'
           )->text( '{INFO}'
          )->text( '{DESCR}' ).

        page->text_area(
             id = 'id_text3'
             width = '100%'
             height = '10%'
             value = client->_bind( mv_value3 ) ).

        page->footer( )->overflow_toolbar(
              )->button( text = 'Scroll Top'     press = client->_event( 'BUTTON_SCROLL_TOP' )
         "    )->button( text = 'Scroll 500 up'   press = view->_event( 'BUTTON_SCROLL_UP' )
         "    )->button( text = 'Scroll 500 down' press = view->_event( 'BUTTON_SCROLL_DOWN' )
             )->button( text = 'Scroll Bottom'   press = client->_event( 'BUTTON_SCROLL_BOTTOM' )
           "  )->toolbar_spacer(
           "  )->button( text = 'Server Event and hold position' press = view->_event( 'BUTTON_SCROLL_HOLD' )
           ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
