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
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    DATA t_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_03 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

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
      WHEN 'SELCHANGE'.
        DATA(lt_sel) = t_tab.
        DELETE lt_sel WHERE selected = abap_false.
        client->popup_message_box( `go to details for item ` && lt_sel[ 1 ]-title ).


      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).
    ENDCASE.

    DATA(page) = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - List'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).

    page->list(
        headertext      = 'List Ouput'
        items           = client->_bind( t_tab )
        mode            = `SingleSelectMaster`
        selectionchange = client->_event( 'SELCHANGE' )
        )->standard_list_item(
            title       = '{TITLE}'
            description = '{DESCR}'
            icon        = '{ICON}'
            info        = '{INFO}'
            press       = client->_event( 'TEST' )
            type        = `Navigation`
            selected    = `{SELECTED}`
            ).

    client->set_next( VALUE #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
