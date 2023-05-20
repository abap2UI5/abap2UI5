CLASS z2ui5_cl_app_demo_52 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        count    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.
    METHODS refresh_data.

    data next type z2ui5_if_client=>ty_s_next.

    DATA mv_check_popover TYPE abap_bool.
ENDCLASS.



CLASS z2ui5_cl_app_demo_52 IMPLEMENTATION.


  METHOD refresh_data.

    DO 100 TIMES.
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

    clear next.

    CASE client->get( )-event.

      WHEN `POPOVER_DETAIL`.
        DATA(lv_id) = client->get( )-event_data.
        mv_check_popover = abap_true.
        next-popover_open_by_id = lv_id.

      WHEN 'BUTTON_POST'.
        client->popup_message_box( 'button post was pressed' ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

  IF mv_check_popover = abap_false.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Demo displaying popver without rerendering the main view'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
        )->get_parent( ).

    DATA(tab) = page->scroll_container( height = '70%' vertical = abap_true
        )->table(
            growing             = abap_true
            growingthreshold    = '20'
            growingscrolltoload = abap_true
            items               = client->_bind_one( t_tab )
            sticky              = 'ColumnHeaders,HeaderToolbar' ).

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
       )->link( text = '{COUNT}' press = client->_event( val = `POPOVER_DETAIL` data = `${$source>/id}` hold_view = abap_true )
       )->text( '{INFO}'
       )->text( '{DESCR}'
       )->checkbox( selected = '{CHECKBOX}' enabled = abap_false
       )->text( '{COUNT}' ).

    next-xml_main = page->get_root( )->xml_get( ).

    else.

      mv_check_popover = abap_false.

      DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

      lo_popup->popover( placement = `Bottom` title = 'abap2UI5 - this is a popover'  contentwidth = `50%`
        )->simple_form( editable = abap_true
        )->content( 'form'
            )->label( 'info1'
            )->text(  `this is a text`
            )->label( 'info2'
            )->text(  `this is a text`
            )->label( 'info3'
            )->text(  `this is a text`
            )->text(  `this is a text`
          )->get_parent( )->get_parent(
          )->footer(
           )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'details'
                  press = client->_event( 'BUTTON_DETAILS' )
                  type  = 'Emphasized'

                  ).

      next-xml_popup = lo_popup->get_root( )->xml_get( ).
    ENDIF.


    client->set_next( next ).

  ENDMETHOD.
ENDCLASS.
