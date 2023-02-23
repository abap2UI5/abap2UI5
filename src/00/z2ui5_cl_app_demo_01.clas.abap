CLASS z2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.

PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.

CLASS Z2UI5_CL_APP_DEMO_01 IMPLEMENTATION.

  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        product = 'tomato'.
        quantity = '500'.


      WHEN client->cs-lifecycle_method-on_event.

        CASE client->get( )-event.

          WHEN 'BUTTON_POST'.
            client->display_message_toast( |{ product } { quantity } ST - GR successful| ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).

        view->page( title = 'Page title' nav_button_tap = view->_event_display_id( client->get( )-id_prev_app )
           )->simple_form('Form Title'
             )->content( 'f'
                )->title( 'Input'
                )->label( 'quantity'
                )->input( view->_bind( quantity )
                )->label( 'product'
                )->input( value = product editable = abap_False
                )->button( text = 'post' press = view->_event( 'BUTTON_POST' ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
