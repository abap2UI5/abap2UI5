CLASS z2ui5_cl_app_hello_world DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA product           TYPE string.
    DATA quantity          TYPE string.
    DATA check_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_hello_world IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      product  = 'tomatos'.
      quantity = '500'.
    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->message_toast_display( |{ product } { quantity } - send to the server| ).
    ENDCASE.

*    z2ui5_cl_view=>factory( client
*        )->c( `Shell`
*        )->c( `Page` )->p( n = `title` v = `abap2UI5 - z2ui5_cl_app_hello_world`
*        )->down->c( `SimpleForm`
*                        )->p( n = `title`    v = `Hello World`
*                        )->p( n = `editable` v = abap_true )->is_boolean(
*                        )->p( n = `editable` v = abap_true )->is_bind_edit(
*                        )->p( n = `editable` v = abap_true )->is_bind(
*                        )->p( n = `editable` v = abap_true )->is_bind_local(
*        )->up->c( ).

    client->view_display( z2ui5_cl_xml_view=>factory( client
        )->shell(
        )->page( title = 'abap2UI5 - z2ui5_cl_app_hello_world'
            )->simple_form( title    = 'Hello World'
                            editable = abap_true
                )->content( ns = `form`
                    )->title( 'Make an input here and send it to the server...'
                    )->label( 'quantity'
                    )->input( value = client->_bind_edit( quantity )
                    )->label( 'product'
                    )->input( value   = product
                              enabled = abap_false
                    )->button( text  = 'post'
                               press = client->_event( 'BUTTON_POST' )
         )->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
