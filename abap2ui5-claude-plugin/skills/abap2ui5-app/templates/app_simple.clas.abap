"! Minimal abap2UI5 app — everything in main( ).
"! Rename ZCL_MY_APP to your own class, in your own namespace, and adjust the
"! style (FINAL, prefixes) to match your project's ABAP standards.
CLASS zcl_my_app DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_my_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF client->check_on_init( ).

      product  = `Product`.
      quantity = `500`.

      DATA(view) = z2ui5_cl_xml_view=>factory( ).
      view->shell(
          )->page(
              title          = `My abap2UI5 App`
              navbuttonpress = client->_event_nav_app_leave( )
              shownavbutton  = client->check_app_prev_stack( )
              )->simple_form(
                  title    = `Form`
                  editable = abap_true
                  )->content( `form`
                  )->label( `Quantity`
                  )->input( client->_bind_edit( quantity )
                  )->label( `Product`
                  )->input( value = product
                  )->button(
                      text  = `Post`
                      press = client->_event( `POST` ) ).
      client->view_display( view->stringify( ) ).

    ELSEIF client->check_on_event( `POST` ).
      client->message_toast_display( |{ product } { quantity } - sent to the server| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
