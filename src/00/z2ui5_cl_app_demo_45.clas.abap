CLASS z2ui5_cl_app_demo_45 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        count    TYPE i,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.
    DATA mv_info_filter TYPE string.
    METHODS refresh_data.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_45 IMPLEMENTATION.


  METHOD refresh_data.

    DO 1000 TIMES.
      DATA(ls_row) = VALUE ty_row( count = sy-index  value = 'red'
        info = COND #( WHEN sy-index < 50 THEN 'completed' ELSE 'uncompleted' )
        descr = 'this is a description' checkbox = abap_true ).
      INSERT ls_row INTO TABLE t_tab.
    ENDDO.

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      refresh_data( ).
    ENDIF.

    CASE client->get( )-event.

      WHEN 'FLTER_INFO'.
        refresh_data( ).
        IF mv_info_filter <> ''.
          DELETE t_tab WHERE info <> mv_info_filter.
        ENDIF.

      WHEN 'BUTTON_POST'.
        client->popup_message_box( 'button post was pressed' ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.


    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Scroll Container with Table and Toolbar'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
        )->get_parent( ).

    page->simple_form( title = 'Form Title' editable = abap_true
                )->content( 'form'
                    )->title( 'Filter'
                    )->label( 'info'
                    )->input(  client->_bind( mv_info_filter )
                    )->button(
                        text  = 'filter'
                        press = client->_event( 'FLTER_INFO' ) ).

    DATA(tab) = page->scroll_container( height = '70%' vertical = abap_true
        )->table(
            growing             = abap_true
            growingthreshold    = '20'
            growingscrolltoload = abap_true
            items               = client->_bind_one( t_tab )
            sticky              = 'ColumnHeaders,HeaderToolbar' ).

    tab->header_toolbar(
        )->overflow_toolbar(
            )->toolbar_spacer( ).

    tab->columns(
        )->column(
            )->text( 'Color' )->get_parent(
        )->column(
            )->text( 'Info' )->get_parent(
        )->column(
            )->text( 'Description' )->get_parent(
        )->column(
            )->text( 'Checkbox' )->get_parent(
         )->column(
            )->text( 'Counter' ).

    tab->items( )->column_list_item( )->cells(
       )->text( '{VALUE}'
       )->text( '{INFO}'
       )->text( '{DESCR}'
       )->checkbox( selected = '{CHECKBOX}' enabled = abap_false
       )->text( '{COUNT}' ).

    client->set_next( VALUE #( xml_main = page->get_root( )->xml_get( ) )  ).

  ENDMETHOD.
ENDCLASS.
