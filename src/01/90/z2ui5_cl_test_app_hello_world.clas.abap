CLASS z2ui5_cl_test_app_hello_world DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA product           TYPE string.
    DATA quantity          TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_test_app_hello_world IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      product  = 'products'.
      quantity = '500'.
    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->message_toast_display( |{ product } { quantity } - send to the server| ).
      WHEN OTHERS.
    ENDCASE.

    client->view_display( z2ui5_cl_ui5=>_factory( )->_ns_m(
        )->shell(
        )->page( title = 'abap2UI5 - z2ui5_cl_app_hello_world' )->_ns_ui(
            )->simpleform( title    = 'Hello World'
                           editable = abap_true
                )->content( )->_ns_m(
                    )->title( 'Make an input here and send it to the server...'
                    )->label( 'quantity'
                    )->input( client->_bind_edit( quantity )
                    )->label( 'product'
                    )->input( value   = product
                              enabled = abap_false
                    )->button( text  = 'post'
                               press = client->_event( 'BUTTON_POST' )
         )->_stringify( ) ).

  ENDMETHOD.
ENDCLASS.
