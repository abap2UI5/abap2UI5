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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_11 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.

        check_editable_active = abap_false.

        t_tab = VALUE #(
            ( title = 'entry 01'  value = 'red' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
            ( title = 'entry 02'  value = 'blue' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
            ( title = 'entry 03'  value = 'green' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
            ( title = 'entry 04'  value = 'orange' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
            ( title = 'entry 05'  value = 'grey' info = 'completed'  descr = 'this is a description' checkbox = abap_true )
        ).


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_EDIT'.
            check_editable_active = xsdbool( check_editable_active = abap_false ).

          WHEN 'BUTTON_DELETE'.
            delete t_tab where selkz = abap_true.

          WHEN 'BUTTON_ADD'.
            insert value #( ) into table t_tab.

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'abap2UI5 - Tables and editable' navbuttontap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).



        DATA(tab) = page->table(
                        items = view->_bind( t_tab )
                        mode  = 'MultiSelect'
                         ).

        "set toolbar
        tab->header_toolbar( )->overflow_toolbar(
            )->title( 'title of the table'
             )->toolbar_spacer(
             )->button(
                    icon = 'sap-icon://delete'
                    text = 'delete selected row'
                    press = view->_event( 'BUTTON_DELETE' )
            )->button(
                    icon = 'sap-icon://add'
                    text = 'add'
                    press = view->_event( 'BUTTON_ADD' )
             )->button(
                    icon = 'sap-icon://edit'
                    text = SWITCH #( check_editable_active WHEN abap_true THEN 'display' ELSE 'edit' )
                    press = view->_event( 'BUTTON_EDIT' )

                    ).

        "set header
        tab->columns(
            )->column( )->text( 'Title' )->get_parent(
            )->column( )->text( 'Color' )->get_parent(
            )->column( )->text( 'Info' )->get_parent(
            )->column( )->text( 'Description' )->get_parent(
            )->column( )->text( 'Checkbox' ).


        "set toolbar
        IF check_editable_active = abap_true.

          tab->items( )->column_list_item( selected = '{SELKZ}'  )->cells(
              )->input( '{TITLE}'
              )->input( '{VALUE}'
              )->input( '{INFO}'
              )->input( '{DESCR}'
              )->checkbox( selected = '{CHECKBOX}' enabled = abap_true ).

        ELSE.

          tab->items( )->column_list_item( selected = '{SELKZ}'  )->cells(
             )->text( '{TITLE}'
             )->text( '{VALUE}'
             )->text( '{INFO}'
             )->text( '{DESCR}'
             )->checkbox( '{CHECKBOX}' ).

        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
