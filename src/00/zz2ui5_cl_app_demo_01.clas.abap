CLASS zz2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.
    DATA unit TYPE string.

ENDCLASS.

CLASS zz2ui5_cl_app_demo_01 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        product = 'tomato'.
        quantity = '500'.


      WHEN client->cs-lifecycle_method-on_event.

        "user event handling
        CASE client->get( )-event.

          WHEN 'BUTTON_POST'.
            client->display_message_toast( |{ product } { quantity } ST - GR successful| ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(context) = client->get( ).
        DATA(view) = client->factory_view( ).

        view->page(
           title = 'Page title'
           nav_button_tap = COND #( WHEN context-id_prev_app IS NOT INITIAL THEN view->_event_display_id( context-id_prev_app ) )
           )->simple_form('Form Title'
                )->content( 'f'
                    )->title( 'Input'
                    )->label( 'quantity'
                    "two way binding, data is written into a a view model and send back to the server
                    )->input( view->_bind( quantity )
                    "one way binding, data is written into a view model but not send back to the server
                    )->input( view->_bind_one_way( unit ) "
                    )->label( 'product'
                     "value is written directly into the xml, no data transfer
                    )->input( value = product editable = abap_False
                    )->button( text = 'post' press = view->_event( 'BUTTON_POST' ) ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
