CLASS zz2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_01 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-_lifecycle_method-on_init.

        product = 'tomato'.
        quantity = '500'.


      WHEN client->cs-_lifecycle_method-on_event.

        "user event handling
        CASE client->get( )-event_id.

          WHEN 'BUTTON_BACK'.
            client->nav_to_app( client->get_app_called( ) ).

          WHEN 'BUTTON_POST'.
            client->display_message_toast( |{ product } { quantity } ST - GR successful| ).

        ENDCASE.


      WHEN client->cs-_lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).

        view->page( event_nav_back_id = COND #( WHEN client->get( )-check_call_stack IS NOT INITIAL THEN 'BUTTON_BACK' ) title = 'Page title'
           )->simple_form('Form Title'
                )->content( 'f'
                    )->title( 'Input'
                    )->label( 'product'
                    )->input( view->_bind( product )
                    )->label( 'quantity'
                    )->input( view->_bind( quantity )
                    )->button( text = 'post' on_press_id = 'BUTTON_POST' ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
