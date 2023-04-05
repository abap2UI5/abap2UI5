CLASS z2ui5_cl_app_demo_03 DEFINITION PUBLIC.

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
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_03 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          t_tab = VALUE #(
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'incompleted' descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'working'     descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
            ( title = 'Peter'  info = 'completed'   descr = 'this is a description' icon = 'sap-icon://account' )
          ).

        ENDIF.

        CASE client->get( )-event.
          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).
        ENDCASE.

        DATA(page) = z2ui5_cl_xml_view_helper=>factory(
            )->page(
                title          = 'abap2UI5 - List'
                navbuttonpress = client->_event( 'BACK' )
                  shownavbutton = abap_true
                )->header_content(
                    )->link(
                        text = 'Source_Code'
                        href = client->get( )-url_source_code
                )->get_parent( ).

        page->list(
            headertext = 'List Ouput'
            items      = client->_bind_one( t_tab )
            )->standard_list_item(
                title       = '{TITLE}'
                description = '{DESCR}'
                icon        = '{ICON}'
                info        = '{INFO}' ).

      client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
