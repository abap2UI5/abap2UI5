CLASS z2ui5_cl_app_demo_19 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        selkz    TYPE abap_bool,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_19 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        t_tab = REDUCE #( INIT ret = VALUE #( ) FOR n = 1 WHILE n < 10 NEXT
             ret = VALUE #( BASE ret ( title = 'Hans'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true ) ) ).


      WHEN client->cs-lifecycle_method-on_event.

        case client->get( )-event.

        when 'BUTTON_TAB'.

        data(lv_test) = `test`.
        "implement event handling here

        endcase.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        DATA(tab) = page->table(
            header_text = 'Table with 100 entries'
            mode =  'MultiSelect' " 'SingleSelectMaster' "'MultiSelect'
            items = view->_bind( t_tab ) ).

        "set header
        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Color' )->get_parent(
            )->column( )->text( 'Info' )->get_parent(
            )->column( )->text( 'Description' )->get_parent(
            )->column( )->text( 'Checkbox' ).

        "set content
        tab->items( )->column_list_item(
            selected = '{SELKZ}'
             )->cells(
           )->button( text = '{TITLE}' press = `onEvent( { 'EVENT' : '` && `BUTTON_TAB` && `', 'METHOD' : 'UPDATE' } )`
           )->text( '{VALUE}'
           )->text( '{INFO}'
           )->text( '{DESCR}'
           )->checkbox( selected = '{CHECKBOX}' enabled = abap_false ).


        page->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Send to Server'
                  press = view->_event( 'BUTTON_SEND' )
                  type  = 'Success' ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
