CLASS z2ui5_cl_app_demo_12 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_12 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_POPUP_01'.
            client->view_popup( 'POPUP_DECIDE' ).

          WHEN 'POPUP_DECIDE_CONTINUE'.
            client->popup_message_toast( 'continue pressed' ).

          WHEN 'POPUP_DECIDE_CANCEL'.
            client->popup_message_toast( 'cancel pressed' ).

          WHEN 'BUTTON_POPUP_02'.
            client->view_show( 'MAIN' ).
            client->view_popup( 'POPUP_DECIDE' ).

          WHEN 'BUTTON_POPUP_03'.
            client->view_show( 'MAIN' ).
            client->view_popup( 'POPUP_DECIDE_FRONTEND_CLOSE' ).

          WHEN 'BUTTON_POPUP_04'.
            client->set( set_prev_view = abap_true ).
            client->view_popup( 'POPUP_DECIDE' ).

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

        DATA(view) = client->factory_view( name = 'MAIN' ).
        DATA(page) = view->page( title = 'abap2UI5 - Popups' navbuttontap = view->_event( 'BACK' ) ).
        page->header_content( )->link( text = 'Go to Source_Code' href = client->get( )-s_request-url_source_code ).

        DATA(grid) = page->grid( 'L7 M12 S12' )->content( 'l' ).
        grid->simple_form( 'Popup in same App' )->content( 'f'
         )->label( 'Demo'
         )->button(
             text    = 'popup rendering, no background rendering'
             press   = view->_event( 'BUTTON_POPUP_01' )
        )->label( 'Demo'
        )->button(
             text    = 'popup rendering, background rendering'
             press   = view->_event( 'BUTTON_POPUP_02' )
              )->label( 'Demo'
        )->button(
             text    = 'popup rendering, background rendering - close (no roundtrip)'
             press   = view->_event( 'BUTTON_POPUP_03' )
         )->label( 'Demo'
        )->button(
             text    = 'popup rendering, background rendering (previous view)'
             press   = view->_event( 'BUTTON_POPUP_04' )  ).
        grid->simple_form( 'Popup in new App' )->content( 'f'
          )->label( 'Demo'
          )->button( text  = 'popup rendering, no background'
              press   = view->_event( 'BUTTON_POPUP_05' )
          )->label( 'Demo'
          )->button(
              text    = 'popup rendering, background rendering (previous view)'
              press   = view->_event( 'BUTTON_POPUP_06' ) ).


        view = client->factory_view( 'POPUP_DECIDE' ).

        DATA(popup) = view->dialog( title = 'Popup - Decide'
        )->vbox( )->text( text = 'this is a popup to decide, you have to make a decision now...'
        )->get_parent(
         )->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Cancel'
                  press = view->_event( 'POPUP_DECIDE_CANCEL' )
              )->button(
                  text  = 'Continue'
                  press = view->_event( 'POPUP_DECIDE_CONTINUE' )
                  type  = 'Emphasized' ).


        view = client->factory_view( 'POPUP_DECIDE_FRONTEND_CLOSE' ).

        popup = view->dialog( title = 'Popup - Info'
        )->vbox( )->text( text = 'this is an information, press close to go back to the main view without a server roundtrip'
        )->get_parent(
         )->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'close'
                  press = view->_event_close_popup( )
                  type  = 'Emphasized' ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
