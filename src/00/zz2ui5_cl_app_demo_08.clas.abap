CLASS zz2ui5_cl_app_demo_08 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA check_strip_active TYPE abap_bool.
    DATA strip_type TYPE string.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_08 IMPLEMENTATION.

  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_previous( ) ).

          WHEN 'BUTTON_MESSAGE_BOX'.
            client->display_message_box( 'this is a message box' ).

          WHEN 'BUTTON_MESSAGE_BOX_ERROR'.
            client->display_message_box( text = 'this is a message box' type = client->cs-message_box-type-error ).

          WHEN 'BUTTON_MESSAGE_BOX_SUCCESS'.
            client->display_message_box( text = 'this is a message box' type = client->cs-message_box-type-success ).

          WHEN 'BUTTON_MESSAGE_BOX_WARNING'.
            client->display_message_box( text = 'this is a message box' type = client->cs-message_box-type-warning ).

          WHEN 'BUTTON_MESSAGE_TOAST'.
            client->display_message_toast( 'this is a message toast' ).

          WHEN 'BUTTON_MESSAGE_STRIP_INFO'.
            check_strip_active = xsdbool(  check_strip_active = abap_false ).
            strip_type = client->cs-message_strip-type-information.

          WHEN 'BUTTON_MESSAGE_STRIP_ERROR'.
            check_strip_active = xsdbool(  check_strip_active = abap_false ).
            strip_type = client->cs-message_strip-type-error.

          WHEN 'BUTTON_MESSAGE_STRIP_SUCCESS'.
            check_strip_active = xsdbool(  check_strip_active = abap_false ).
            strip_type = client->cs-message_strip-type-success.

          WHEN 'BUTTON_ERROR'.
            DATA(dummy) = 1 / 0.

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        "Definition of View Main
        DATA(view) = client->factory_view( 'MAIN' ).
        DATA(page) = view->page( title = 'ABAP2UI5 - Messages' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app ) ).

        IF  check_strip_active = abap_true.
          page->message_strip( text = 'This is a Message Strip' type = strip_type ).
        ENDIF.

        page->grid( default_span  = 'L6 M12 S12' )->get( )->content( 'l' )->get(
         )->simple_form('Message Box' )->get( )->content( 'f' )->get(
           )->button( text = 'information'  press = view->_event(  'BUTTON_MESSAGE_BOX'  )
           )->button( text = 'success'      press = view->_event( 'BUTTON_MESSAGE_BOX_SUCCESS'  )
           )->button( text = 'error'        press = view->_event( 'BUTTON_MESSAGE_BOX_ERROR' )
           )->button( text = 'warning'      press = view->_event('BUTTON_MESSAGE_BOX_WARNING' ) ).

        page->grid( default_span  = 'L6 M12 S12' )->get( )->content( 'l' )->get(
          )->simple_form('Message Strip' )->get( )->content( 'f' )->get(
            )->button( text = 'success'       press = view->_event( 'BUTTON_MESSAGE_STRIP_SUCCESS' )
            )->button( text = 'error'         press = view->_event( 'BUTTON_MESSAGE_STRIP_ERROR' )
            )->button( text = 'information'   press = view->_event( 'BUTTON_MESSAGE_STRIP_INFO' ) ).

        page->grid( default_span  = 'L6 M12 S12' )->get( )->content( 'l' )->get(
              )->simple_form('Display' )->get( )->content( 'f' )->get(
                )->button( text = 'Message Toast'   press = view->_event( 'BUTTON_MESSAGE_TOAST' )
                )->button( text = 'Error'           press = view->_event( 'BUTTON_ERROR' ) ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
