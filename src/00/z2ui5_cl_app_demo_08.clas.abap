CLASS z2ui5_cl_app_demo_08 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_strip_active TYPE abap_bool.
    DATA strip_type TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_08 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

        CASE client->get( )-event.

          WHEN 'BUTTON_MESSAGE_BOX'.
            client->popup_message_box( 'this is a message box' ).

          WHEN 'BUTTON_MESSAGE_BOX_ERROR'.
            client->popup_message_box( text = 'this is a message box' type = 'error' ).

          WHEN 'BUTTON_MESSAGE_BOX_SUCCESS'.
            client->popup_message_box( text = 'this is a message box' type = 'success' ).

          WHEN 'BUTTON_MESSAGE_BOX_WARNING'.
            client->popup_message_box( text = 'this is a message box' type = 'warning' ).

          WHEN 'BUTTON_MESSAGE_TOAST'.
            client->popup_message_toast( 'this is a message toast' ).

          WHEN 'BUTTON_MESSAGE_STRIP_INFO'.
            check_strip_active = abap_true.
            strip_type = 'Information'.

          WHEN 'BUTTON_MESSAGE_STRIP_ERROR'.
            check_strip_active = abap_true.
            strip_type = 'Error'.

          WHEN 'BUTTON_MESSAGE_STRIP_SUCCESS'.
            check_strip_active = abap_true.
            strip_type = 'Success'.

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

        IF check_strip_active = abap_true.
          page->message_strip( text = 'This is a Message Strip' type = strip_type ).
        ENDIF.

        page->grid( 'L6 M12 S12'
            )->content( 'layout'
                )->simple_form( 'Message Box' )->content( 'form'
                    )->button(
                        text  = 'information'
                        press = client->_event( 'BUTTON_MESSAGE_BOX' )
                    )->button(
                        text  = 'success'
                        press = client->_event( 'BUTTON_MESSAGE_BOX_SUCCESS' )
                    )->button(
                        text  = 'error'
                        press = client->_event( 'BUTTON_MESSAGE_BOX_ERROR' )
                    )->button(
                        text  = 'warning'
                        press = client->_event( 'BUTTON_MESSAGE_BOX_WARNING' ) ).

        page->grid( 'L6 M12 S12'
            )->content( 'layout'
                )->simple_form( 'Message Strip' )->content( 'form'
                    )->button(
                        text = 'success'
                        press = client->_event( 'BUTTON_MESSAGE_STRIP_SUCCESS' )
                    )->button(
                        text = 'error'
                        press = client->_event( 'BUTTON_MESSAGE_STRIP_ERROR' )
                    )->button(
                        text = 'information'
                        press = client->_event( 'BUTTON_MESSAGE_STRIP_INFO' ) ).

        page->grid( 'L6 M12 S12'
            )->content( 'layout'
                )->simple_form( 'Display' )->content( 'form'
                    )->button(
                        text = 'Message Toast'
                        press = client->_event( 'BUTTON_MESSAGE_TOAST' ) ).

        client->set_next( value #( xml_main = page->get_root(  )->xml_get( ) ) ).
  ENDMETHOD.
ENDCLASS.
