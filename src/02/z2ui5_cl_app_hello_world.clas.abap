CLASS z2ui5_cl_app_hello_world DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_hello_world IMPLEMENTATION.

  METHOD z2ui5_if_app~main.
        DATA view TYPE REF TO z2ui5_cl_xml_view.

    CASE abap_true.

      WHEN client->check_on_init( ).

        
        view = z2ui5_cl_xml_view=>factory(
          )->shell(
          )->page( `abap2UI5 - Hello World`
          )->simple_form( editable = abap_true
              )->content( `form`
                  )->title( `Make an input here and send it to the server...`
                  )->label( `Name`
                  )->input( client->_bind_edit( name )
                  )->button( text  = `SEND`
                             press = client->_event( `BUTTON_POST` ) ).
        client->view_display( view->stringify( ) ).

      WHEN client->check_on_event( `BUTTON_POST` ).
        client->message_box_display( |Your name is { name }| ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
