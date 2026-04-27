CLASS z2ui5_cl_app_hello_world DEFINITION PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_app_hello_world IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    IF client->check_on_init( ).
      DATA(view) = z2ui5_cl_xml_view=>factory(
        )->shell(
        )->page( `abap2UI5 - Hello World`
          )->simple_form( editable = abap_true
            )->content( `form`
              )->title( `Make an input here and send it to the server...`
              )->label( `Name`
              )->input( client->_bind_edit( name )
              )->button( text  = `Send`
                         press = client->_event( `BUTTON_POST` ) ).
        client->view_display( view->stringify( ) ).

    ELSEIF client->check_on_event( `BUTTON_POST` ).
      client->message_box_display( |Your name is { name }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
