CLASS z2ui5_cl_app_demo_11 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_row,
        selkz    TYPE abap_bool,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_editable_active TYPE abap_bool.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_11 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          check_editable_active = abap_false.
          t_tab = VALUE #(
              ( title = 'entry 01'  value = 'red'    info = 'completed'  descr = 'this is a description' checkbox = abap_true )
              ( title = 'entry 02'  value = 'blue'   info = 'completed'  descr = 'this is a description' checkbox = abap_true )
              ( title = 'entry 03'  value = 'green'  info = 'completed'  descr = 'this is a description' checkbox = abap_true )
              ( title = 'entry 04'  value = 'orange' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
              ( title = 'entry 05'  value = 'grey'   info = 'completed'  descr = 'this is a description' checkbox = abap_true ) ).

        ENDIF.


        CASE client->get( )-event.

          WHEN 'BUTTON_EDIT'.
            check_editable_active = xsdbool( check_editable_active = abap_false ).

          WHEN 'BUTTON_DELETE'.
            DELETE t_tab WHERE selkz = abap_true.

          WHEN 'BUTTON_ADD'.
            INSERT VALUE #( ) INTO TABLE t_tab.

          WHEN 'BACK'.
            client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

        ENDCASE.

        DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
            )->page(
                    title          = 'abap2UI5 - Tables and editable'
                    navbuttonpress = client->_event( 'BACK' )
                      shownavbutton = abap_true
                )->header_content(
                    )->link(
                        text = 'Demo' target = '_blank'
                        href = 'https://twitter.com/OblomovDev/status/1630240894581608448'
                    )->link(
                        text = 'Source_Code' target = '_blank'
                        href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).

        DATA(tab) = page->table(
                items = client->_bind( t_tab )
                mode  = 'MultiSelect'
            )->header_toolbar(
                )->overflow_toolbar(
                    )->title( 'title of the table'
                    )->toolbar_spacer(
                    )->button(
                        icon  = 'sap-icon://delete'
                        text  = 'delete selected row'
                        press = client->_event( 'BUTTON_DELETE' )
                    )->button(
                        icon  = 'sap-icon://add'
                        text  = 'add'
                        press = client->_event( 'BUTTON_ADD' )
                    )->button(
                        icon  = 'sap-icon://edit'
                        text  = SWITCH #( check_editable_active WHEN abap_true THEN |display| ELSE |edit| )
                        press = client->_event( 'BUTTON_EDIT' )
            )->get_parent( )->get_parent( ).

        tab->columns(
            )->column(
                )->text( 'Title' )->get_parent(
            )->column(
                )->text( 'Color' )->get_parent(
            )->column(
                )->text( 'Info' )->get_parent(
            )->column(
                )->text( 'Description' )->get_parent(
            )->column(
                )->text( 'Checkbox' ).

        IF check_editable_active = abap_true.

          tab->items( )->column_list_item( selected = '{SELKZ}'
            )->cells(
                )->input( '{TITLE}'
                )->input( '{VALUE}'
                )->input( '{INFO}'
                )->input( '{DESCR}'
                )->checkbox( '{CHECKBOX}' ).

        ELSE.

          tab->items( )->column_list_item( selected = '{SELKZ}'
            )->cells(
                )->text( '{TITLE}'
                )->text( '{VALUE}'
                )->text( '{INFO}'
                )->text( '{DESCR}'
                )->checkbox(
                    selected = '{CHECKBOX}'
                    enabled = abap_false ).

        ENDIF.

  client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
