CLASS z2ui5_cl_app_demo_20 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    CLASS-METHODS factory
      IMPORTING
        i_text          TYPE string
        i_cancel_text   TYPE string
        i_cancel_event  TYPE string
        i_confirm_text  TYPE string
        i_confirm_event TYPE string
      RETURNING
        VALUE(r_result) TYPE REF TO z2ui5_cl_app_demo_20.

    DATA mv_text TYPE string.
    DATA mv_cancel_text TYPE string.
    DATA mv_cancel_event TYPE string.
    DATA mv_confirm_text TYPE string.
    DATA mv_confirm_event TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_20 IMPLEMENTATION.

  METHOD factory.

    r_result = NEW #( ).

    r_result->mv_text = i_text.
    r_result->mv_cancel_text = i_cancel_text.
    r_result->mv_cancel_event = i_cancel_event.
    r_result->mv_confirm_text = i_confirm_text.
    r_result->mv_confirm_event = i_confirm_event.

  ENDMETHOD.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        client->view_popup( 'POPUP_DECIDE' ).

      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN mv_cancel_event OR mv_confirm_event.
            client->set( event = client->get( )-event ).
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( 'POPUP_DECIDE' ).

        DATA(page) = view->dialog( title = 'Example - ZZ2UI5_CL_APP_DEMO_07' ).

        page->text( text = mv_text ).
        page->button( text = mv_cancel_text press = view->_event( mv_cancel_event ) ).
        page->button( text = mv_confirm_text press = view->_event( mv_confirm_event ) ).


        page->footer( )->overflow_toolbar(
              )->toolbar_spacer(
              )->button(
                  text  = 'Send to Server'
                  press = view->_event( 'BUTTON_SEND' )
                  type  = 'Success' ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
