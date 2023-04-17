CLASS z2ui5_cl_app_demo_34 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA t_bapiret TYPE bapirettab.
    DATA check_initialized TYPE abap_bool.
    DATA mv_popup_name TYPE string.
    DATA mv_main_xml TYPE string.
    DATA mv_popup_xml TYPE string.

    METHODS view_main
      IMPORTING
        client TYPE REF TO z2ui5_if_client.
    METHODS view_popup_bal
      IMPORTING
        client TYPE REF TO z2ui5_if_client.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_34 IMPLEMENTATION.


  METHOD view_main.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
                title          = 'abap2UI5 - Popups'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
             "   )->link(
             "       text = 'Demo' target = '_blank'
               "     href = 'https://twitter.com/OblomovDev/status/1637163852264624139'
                )->link(
                    text = 'Source_Code' target = '_blank' href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
           )->get_parent( ).

    DATA(grid) = page->grid( 'L8 M12 S12' )->content( 'layout' ).

    grid->simple_form( 'Tables' )->content( 'form'
        )->label( '01'
        )->button(
            text  = 'Show bapiret tab'
            press = client->_event( 'POPUP_BAL' )
        ).

    mv_main_xml = page->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD view_popup_bal.

    DATA(popup) = Z2UI5_CL_XML_VIEW=>factory_popup(
        )->dialog( 'abap2ui5 - Popup Message Log'
            )->table( client->_bind( t_bapiret )
                )->columns(
                    )->column( '5rem'
                        )->text( 'Type' )->get_parent(
                    )->column( '5rem'
                        )->text( 'Number' )->get_parent(
                    )->column( '5rem'
                        )->text( 'ID' )->get_parent(
                    )->column(
                        )->text( 'Message' )->get_parent(
                )->get_parent(
                )->items(
                    )->column_list_item(
                        )->cells(
                            )->text( '{TYPE}'
                            )->text( '{NUMBER}'
                            )->text( '{ID}'
                            )->text( '{MESSAGE}'
            )->get_parent( )->get_parent( )->get_parent( )->get_parent(
            )->footer( )->overflow_toolbar(
                )->toolbar_spacer(
                )->button(
                    text  = 'close'
                    press = client->_event( 'POPUP_BAL_CLOSE' )
                    type  = 'Emphasized' ).

    mv_popup_xml = popup->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      t_bapiret = VALUE #(
        ( message = 'An empty Report field causes an empty XML Message to be sent' type = 'E' id = 'MSG1' number = '001' )
        ( message = 'Check was executed for wrong Scenario' type = 'E' id = 'MSG1' number = '002' )
        ( message = 'Request was handled without errors' type = 'S' id = 'MSG1' number = '003' )
        ( message = 'product activated' type = 'S' id = 'MSG4' number = '375' )
        ( message = 'check the input values' type = 'W' id = 'MSG2' number = '375' )
        ( message = 'product already in use' type = 'I' id = 'MSG2' number = '375' )
         ).

    ENDIF.

    mv_popup_name = ''.

    CASE client->get( )-event.

      WHEN 'POPUP_BAL'.
        mv_popup_name =  'POPUP_BAL'.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

    view_main( client ).

    CASE mv_popup_name.
      WHEN 'POPUP_BAL'.
        view_popup_bal( client ).
    ENDCASE.

    client->set_next( VALUE #( xml_main = mv_main_xml xml_popup = mv_popup_xml ) ).
    CLEAR: mv_main_xml, mv_popup_xml.
  ENDMETHOD.
ENDCLASS.
