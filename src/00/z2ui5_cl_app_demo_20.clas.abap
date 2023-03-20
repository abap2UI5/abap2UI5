CLASS z2ui5_cl_app_demo_20 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    CLASS-METHODS factory
      IMPORTING
        i_text                     TYPE string
        i_cancel_text              TYPE string
        i_cancel_event             TYPE string
        i_confirm_text             TYPE string
        i_confirm_event            TYPE string
        i_check_show_previous_view TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)              TYPE REF TO z2ui5_cl_app_demo_20.

    DATA check_initialized TYPE abap_bool.

    DATA mv_text TYPE string.
    DATA mv_cancel_text TYPE string.
    DATA mv_cancel_event TYPE string.
    DATA mv_confirm_text TYPE string.
    DATA mv_confirm_event TYPE string.
    DATA mv_check_show_previous_view TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_20 IMPLEMENTATION.

  METHOD factory.

    result = NEW #( ).

    result->mv_text = i_text.
    result->mv_cancel_text = i_cancel_text.
    result->mv_cancel_event = i_cancel_event.
    result->mv_confirm_text = i_confirm_text.
    result->mv_confirm_event = i_confirm_event.
    result->mv_check_show_previous_view = i_check_show_previous_view.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.

          check_initialized = abap_true.
          client->set( set_prev_view = mv_check_show_previous_view ).
          client->popup_view( 'POPUP_DECIDE' ).

        ENDIF.


        CASE client->get( )-event.

          WHEN mv_cancel_event OR mv_confirm_event.

            client->set( event = client->get( )-event ).
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        client->factory_view( 'POPUP_DECIDE'
            )->dialog( title = 'abap2UI5 - Popup to decide'
                )->vbox(
                    )->text( mv_text )->get_parent(
                )->footer(
                    )->overflow_toolbar(
                        )->toolbar_spacer(
                        )->button(
                            text  = mv_cancel_text
                            press = client->_event( mv_cancel_event )
                        )->button(
                            text  = mv_confirm_text
                            press = client->_event( mv_confirm_event )
                            type  = 'Emphasized' ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
