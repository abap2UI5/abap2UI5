CLASS z2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_01 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_init.
        product  = 'tomato'.
        quantity = '500'.

      WHEN client->cs-lifecycle_method-on_event.
        CASE client->get( )-event.
          WHEN 'BUTTON_POST'.
            client->popup_message_toast( |{ product } { quantity } ST - send to the server| ).
          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).
        ENDCASE.

      WHEN client->cs-lifecycle_method-on_rendering.

        DATA(view) = client->factory_view( ).
        DATA(page) = view->page( title = 'abap2UI5 - First Example' navbuttontap = view->_event( 'BACK' ) ).

        page->header_content( )->link( text = 'Go to Source Code' href = client->get( )-s_request-url_source_code ).

        page->simple_form( 'Form Title'
             )->content( 'f'
                )->title( 'Input'
                )->label( 'quantity'
                )->input( view->_bind( quantity )
                )->label( 'product'
                )->input( value = product enabled = abap_False
                )->button( text = 'post' press = view->_event( 'BUTTON_POST' ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
