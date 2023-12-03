CLASS z2ui5_cl_fw_app_hello_world DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product TYPE string.
    DATA quantity TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_fw_app_hello_world IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      product  = 'products'.
      quantity = '500'.

      client->view_display( z2ui5_cl_xml_view=>factory(
        )->shell(
        )->page( title = 'abap2UI5 - z2ui5_cl_app_hello_world'
        )->simple_form( title    = 'Hello World' editable = abap_true
            )->content( ns = `form`
                )->title( 'Make an input here and send it to the server...'
                )->label( 'quantity'
                )->input( client->_bind_edit( quantity )
                )->label( 'product'
                )->input( value = product enabled = abap_false
                )->button( text = 'post' press = client->_event( 'BUTTON_POST' )
        )->stringify( ) ).

    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->message_toast_display( |{ product } { quantity } - send to the server| ).
    ENDCASE.

  ENDMETHOD.
ENDCLASS.
