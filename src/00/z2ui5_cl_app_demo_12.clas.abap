CLASS z2ui5_cl_app_demo_12 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_popup_view TYPE string.
    DATA mv_main_view  TYPE string.
    DATA mv_check_initialized TYPE abap_bool.
    DATA mv_set_prev_view TYPE abap_bool.

    DATA mv_check_popup TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_12 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      mv_main_view = 'MAIN'.
    ENDIF.

    mv_set_prev_view = ''.
    mv_popup_view = ''.

    IF mv_check_popup = abap_true.
      mv_check_popup = abap_false.
      DATA(app) = CAST z2ui5_cl_app_demo_20( client->get_app( client->get( )-id_prev_app )  ).
      client->popup_message_toast( app->mv_event && ` pressed` ).
    ENDIF.

    CASE client->get( )-event.

      WHEN 'BUTTON_POPUP_01'.
        mv_popup_view = 'POPUP_DECIDE'.
        mv_main_view = ''.

      WHEN 'POPUP_DECIDE_CONTINUE'.
        mv_main_view = 'MAIN'.
        client->popup_message_toast( 'continue pressed' ).

      WHEN 'POPUP_DECIDE_CANCEL'.
        mv_main_view = 'MAIN'.
        client->popup_message_toast( 'cancel pressed' ).

      WHEN 'BUTTON_POPUP_02'.
        mv_main_view = 'MAIN'.
        mv_popup_view = 'POPUP_DECIDE'.

      WHEN 'BUTTON_POPUP_03'.
        mv_main_view = 'MAIN'.
        mv_popup_view = 'POPUP_INFO_FRONTEND_CLOSE'.

      WHEN 'BUTTON_POPUP_04'.
        mv_main_view = ``.
        mv_popup_view = 'POPUP_DECIDE'.

      WHEN 'BUTTON_POPUP_05'.
        mv_check_popup = abap_true.
        client->nav_app_call( z2ui5_cl_app_demo_20=>factory(
          i_text          = '(new app )this is a popup to decide, the text is send from the previous app and the answer will be send back'
          i_cancel_text   = 'Cancel '
          i_cancel_event  = 'POPUP_DECIDE_CANCEL'
          i_confirm_text  = 'Continue'
          i_confirm_event = 'POPUP_DECIDE_CONTINUE'
          ) ).
        RETURN.

      WHEN 'BUTTON_POPUP_06'.
        mv_check_popup = abap_true.
        client->nav_app_call( z2ui5_cl_app_demo_20=>factory(
          i_text          = '(new app )this is a popup to decide, the text is send from the previous app and the answer will be send back'
          i_cancel_text   = 'Cancel'
          i_cancel_event  = 'POPUP_DECIDE_CANCEL'
          i_confirm_text  = 'Continue'
          i_confirm_event = 'POPUP_DECIDE_CONTINUE' ) ).
        RETURN.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( client->get( )-id_prev_app_stack ) ).

    ENDCASE.

    DATA(lo_main) = z2ui5_cl_xml_view=>factory( )->shell( ).

    CASE mv_main_view.

      WHEN 'MAIN'.

        DATA(page) = lo_main->page(
                title          = 'abap2UI5 - Popups'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
                )->header_content(
                    )->link(
                        text = 'Source_Code' target = '_blank'
                        href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
                )->get_parent( ).

        DATA(grid) = page->grid( 'L7 M12 S12' )->content( 'layout'
            )->simple_form( 'Popup in same App' )->content( 'form'
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
                    text  = 'popup rendering, hold background view'
                    press = client->_event( val = 'BUTTON_POPUP_04' hold_view = abap_true )
            )->get_parent( )->get_parent( ).

        grid->simple_form( 'Popup in new App' )->content( 'form'
            )->label( 'Demo'
            )->button(
                text  = 'popup rendering, no background'
                press = client->_event( 'BUTTON_POPUP_05' )
            )->label( 'Demo'
            )->button(
                text  = 'popup rendering, hold previous view'
                press = client->_event( val = 'BUTTON_POPUP_06' hold_view = abap_true ) ).

    ENDCASE.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).

    CASE mv_popup_view.

      WHEN 'POPUP_DECIDE'.

        lo_popup->dialog( 'Popup - Decide'
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

      WHEN 'POPUP_INFO_FRONTEND_CLOSE'.

        lo_popup->dialog( 'Popup - Info'
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

    DATA(ls_next) = VALUE z2ui5_if_client=>ty_s_next(
         xml_main  = lo_main->get_root( )->xml_get( )
         xml_popup = COND #( WHEN mv_popup_view IS NOT INITIAL THEN lo_popup->get_root( )->xml_get( ) )
        ).
    IF mv_main_view = ``.
      ls_next-xml_main = ``.
    ENDIF.
    client->set_next( ls_next ).

  ENDMETHOD.
ENDCLASS.
