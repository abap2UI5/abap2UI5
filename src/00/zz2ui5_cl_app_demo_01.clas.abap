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

        DATA(view) = client->factory_view( ).

        DATA(content) = view->page( title = 'Page title'  nav_button_tap = view->_event_display_id( client->get( )-id_prev_app )
           )->simple_form('Form Title'
                )->content( 'f' )->title( 'Input' ).

        "two way binding, data is written into a a view model and send back to the server
        content->label( 'quantity' ).
        content->input( view->_bind( quantity ) ).

        "value is written directly into the xml, no data transfer
        content->label( 'product' ).
        content->input( value = product editable = abap_False ).

        "event is mapped on the backend function on_event with event 'BUTTON_POST'
        content->button( text = 'post' press = view->_event( 'BUTTON_POST' ) ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
