CLASS z2ui5_cl_app_demo_12 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_12 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_POPUP_01'.
            client->popup_view( 'POPUP_DECIDE' ).

          WHEN 'POPUP_DECIDE_CONTINUE'.
            client->popup_message_toast( 'continue pressed' ).

          WHEN 'POPUP_DECIDE_CANCEL'.
            client->popup_message_toast( 'cancel pressed' ).

          WHEN 'BUTTON_POPUP_02'.
            client->show_view( 'MAIN' ).
            client->popup_view( 'POPUP_DECIDE' ).

          WHEN 'BUTTON_POPUP_03'.
            client->show_view( 'MAIN' ).
            client->popup_view( 'POPUP_DECIDE_FRONTEND_CLOSE' ).

          WHEN 'BUTTON_POPUP_04'.
            client->set( set_prev_view = abap_true ).
            client->popup_view( 'POPUP_DECIDE' ).

          WHEN 'BUTTON_POPUP_05'.
            client->nav_app_call( z2ui5_cl_app_demo_20=>factory(
              i_text          = '(new app )this is a popup to decide, the text is send from the previous app and the answer will be send back'
              i_cancel_text   = 'Cancel '
              i_cancel_event  = 'POPUP_DECIDE_CANCEL'
              i_confirm_text  = 'Continue'
              i_confirm_event = 'POPUP_DECIDE_CONTINUE'
              i_check_show_previous_view = abap_false ) ).

          WHEN 'BUTTON_POPUP_06'.
            client->nav_app_call( z2ui5_cl_app_demo_20=>factory(
              i_text          = '(new app )this is a popup to decide, the text is send from the previous app and the answer will be send back'
              i_cancel_text   = 'Cancel'
              i_cancel_event  = 'POPUP_DECIDE_CANCEL'
              i_confirm_text  = 'Continue'
              i_confirm_event = 'POPUP_DECIDE_CONTINUE' ) ).

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(page) = client->factory_view( 'MAIN'
            )->page(
                title           = 'abap2UI5 - Popups'
                navbuttonpress  = client->_event( 'BACK' )
                )->header_content(
                    )->link(
                        text = 'Source_Code'
                        href = client->get( )-s_request-url_source_code
                )->get_parent( ).

        DATA(grid) = page->grid( 'L7 M12 S12' )->content( 'l'
            )->simple_form( 'Popup in same App' )->content( 'f'
                )->label( 'Demo'
                )->button(
                    text  = 'popup rendering, no background rendering'
                    press = client->_event( 'BUTTON_POPUP_01' )
                )->label( 'Demo'
                )->button(
                    text  = 'popup rendering, background rendering'
                    press = client->_event( 'BUTTON_POPUP_02' )
                )->label( 'Demo'
                )->button(
                    text  = 'popup rendering, background rendering - close (no roundtrip)'
                    press = client->_event( 'BUTTON_POPUP_03' )
                )->label( 'Demo'
                )->button(
                    text  = 'popup rendering, background rendering (previous view)'
                    press = client->_event( 'BUTTON_POPUP_04' )
            )->get_parent( )->get_parent( ).

        grid->simple_form( 'Popup in new App' )->content( 'f'
            )->label( 'Demo'
            )->button(
                text  = 'popup rendering, no background'
                press = client->_event( 'BUTTON_POPUP_05' )
            )->label( 'Demo'
            )->button(
                text  = 'popup rendering, background rendering (previous view)'
                press = client->_event( 'BUTTON_POPUP_06' ) ).


        client->factory_view( 'POPUP_DECIDE'
            )->dialog( 'Popup - Decide'
                )->vbox(
                    )->text( 'this is a popup to decide, you have to make a decision now...'
                )->get_parent(
                )->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'Cancel'
                        press = client->_event( 'POPUP_DECIDE_CANCEL' )
                    )->button(
                        text  = 'Continue'
                        press = client->_event( 'POPUP_DECIDE_CONTINUE' )
                        type  = 'Emphasized' ).


        client->factory_view( 'POPUP_DECIDE_FRONTEND_CLOSE'
            )->dialog( 'Popup - Info'
                )->vbox(
                    )->text( 'this is an information, press close to go back to the main view without a server roundtrip'
                )->get_parent(
                )->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'close'
                        press = client->_event_close_popup( )
                        type  = 'Emphasized' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
