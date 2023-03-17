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

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_22 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        mv_value1 = 'value1'.
        mv_value2 = 'this is a long text this is a long text this is a long text this is a long text this is a long text this is a long text this is a long text this is a long text this is a long text this is a long text ' &&
                     ' long text this is a long text this is a long text this is a long text this is a long text this is a long text.'.
        do 5 times.
        mv_value2 = mv_value2 && mv_value2.
        enddo.

        mv_value3 = mv_value2.

        t_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 100 NEXT
             ret = VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' ) ) ).


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_SCROLL_TOP'.
            "nothing to do, default mode

          WHEN 'BUTTON_SCROLL_BOTTOM'.
            client->set( page_scroll_pos = '99999999' ).

          WHEN 'BUTTON_SCROLL_UP'.
            DATA(lv_pos) = client->get( )-page_scroll_pos - 500.
            client->set( page_scroll_pos = COND #( WHEN lv_pos < 0 THEN 0 ELSE lv_pos ) ).

          WHEN 'BUTTON_SCROLL_DOWN'.
            client->set( page_scroll_pos = client->get( )-page_scroll_pos + 500 ).

          WHEN 'BUTTON_SCROLL_HOLD'.
            client->set( page_scroll_pos = client->get( )-page_scroll_pos ).

          WHEN 'BUTTON_FOCUS_FIRST'.
            client->set( focus = mv_value1 focus_pos = '3' ).

          WHEN 'BUTTON_FOCUS_SECOND'.
            client->set( focus = mv_value2 focus_pos = '20' ).

          WHEN 'BUTTON_FOCUS_END'.
            client->set( focus = mv_value3 focus_pos = '9999999' ).
            client->set( page_scroll_pos = '99999999' ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( id = 'test2' title = 'abap2ui5 - Scrolling and Focus' nav_button_tap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).


        page->input( value = view->_bind( mv_value1 ) ).
        page->text_area(
            width = '100%'
            height = '20%'
            id = 'test'
             value = view->_bind( mv_value2 ) ).

        page->button( text = 'focus input pos 3'  press = view->_event( 'BUTTON_FOCUS_FIRST' ) ).
        page->button( text = 'focus text area pos 20'  press = view->_event( 'BUTTON_FOCUS_SECOND' ) ).
        page->button( text = 'scroll end + focus end'  press = view->_event( 'BUTTON_FOCUS_END' ) ).

*        DATA(tab) = page->table( sticky = 'ColumnHeaders,HeaderToolbar' header_text = 'Table with some entries' items = view->_bind_one_way( t_tab ) ).
*
*        tab->columns(
*            )->column( )->text( 'Title' )->get_parent(
*            )->column( )->text( 'Color' )->get_parent(
*            )->column( )->text( 'Info' )->get_parent(
*            )->column( )->text( 'Description' ).
*
*        tab->items( )->column_list_item( )->cells(
*           )->text( '{TITLE}'
*           )->text( '{VALUE}'
*           )->text( '{INFO}'
*          )->text( '{DESCR}' ).

*       page->text_area(
*            width = '100%'
*          "  rows = '1'
*            growing = abap_true
*            value = view->_bind( mv_value3 ) ).

        page->footer( )->overflow_toolbar(
              )->button( text = 'Scroll Top'     press = view->_event( 'BUTTON_SCROLL_TOP' )
             )->button( text = 'Scroll 500 up'   press = view->_event( 'BUTTON_SCROLL_UP' )
             )->button( text = 'Scroll 500 down' press = view->_event( 'BUTTON_SCROLL_DOWN' )
             )->button( text = 'Scroll Bottom'   press = view->_event( 'BUTTON_SCROLL_BOTTOM' )
             )->toolbar_spacer(
             )->button( text = 'Server Event and hold position' press = view->_event( 'BUTTON_SCROLL_HOLD' ) ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
