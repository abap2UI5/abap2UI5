CLASS z2ui5_cl_app_demo_33 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_33 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-event.
      WHEN 'BUTTON_MESSAGE_BOX'.
        client->popup_message_box( 'this is a message box' ).
      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).
    ENDCASE.

    DATA(page) = Z2UI5_CL_XML_VIEW=>factory( )->shell(
        )->page(
            title          = 'abap2UI5 - Messages'
            navbuttonpress = client->_event( 'BACK' )
              shownavbutton = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'  target = '_blank'
                    href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent( ).

    page->illustrated_message(
        illustrationtype             = 'sapIllus-NoActivities'
    )->additional_content(  )->button(
                text  = 'information'
                press = client->_event( 'BUTTON_MESSAGE_BOX' ) ).

    client->set_next( VALUE #( xml_main = page->get_root(  )->xml_get( ) ) ).

  ENDMETHOD.
ENDCLASS.
