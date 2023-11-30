class Z2UI5_CL_FW_APP_HELLO_WORLD definition
  public
  create public .

public section.

  interfaces IF_SERIALIZABLE_OBJECT .
  interfaces Z2UI5_IF_APP .

  data PRODUCT type STRING .
  data QUANTITY type STRING .
  data CHECK_INITIALIZED type ABAP_BOOL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_APP_HELLO_WORLD IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    IF check_initialized = abap_false.
      check_initialized = abap_true.
      product  = 'products'.
      quantity = '500'.
    ENDIF.

    CASE client->get( )-event.
      WHEN 'BUTTON_POST'.
        client->message_toast_display( |{ product } { quantity } - send to the server| ).
    ENDCASE.

    client->view_display( z2ui5_cl_xml_view=>factory(
        )->shell(
        )->page( title = 'abap2UI5 - z2ui5_cl_app_hello_world'
            )->simple_form( title    = 'Hello World' editable = abap_true
                )->content( ns = `form`
                    )->title( 'Make an input here and send it to the server...'
                    )->label( 'quantity'
                    )->input( client->_bind_edit( quantity )
                    )->label( 'product'
                    )->input( value   = product enabled = abap_false
                    )->button( text  = 'post' press = client->_event( 'BUTTON_POST' )
         )->stringify( ) ).

  ENDMETHOD.
ENDCLASS.
