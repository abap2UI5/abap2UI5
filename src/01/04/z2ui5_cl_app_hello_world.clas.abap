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
      DATA(view) = z2ui5_cl_ui5_view_builder=>new( ).

      view->ele( n = `View` ns = `mvc`
          )->att( n = `xmlns` v = `sap.m`
          )->att( n = `xmlns:mvc` v = `sap.ui.core.mvc`
          )->att( n = `xmlns:core` v = `sap.ui.core`
          )->att( n = `xmlns:form` v = `sap.ui.layout.form`
          )->att( n = `displayBlock` v = `true`
          )->att( n = `height` v = `100%`
          )->ele( `Shell`
              )->ele( `Page`
                  )->att( n = `title` v = `abap2UI5 - Hello World`
                  )->ele( n = `SimpleForm` ns = `form`
                      )->att( n = `editable` v = `true`
                      )->ele( n = `content` ns = `form`
                          )->ele( n = `Title` ns = `core`
                              )->att( n = `text` v = `Enter a value and send it to the server...`
                          )->end(
                          )->ele( `Label`
                              )->att( n = `text` v = `Name`
                          )->end(
                          )->ele( `Input`
                              )->att( n = `value` v = client->_bind( name )
                          )->end(
                          )->ele( `Button`
                              )->att( n = `text` v = `Post`
                              )->att( n = `press` v = client->_event( `BUTTON_POST` ) ).

      client->view_display( view->stringify( ) ).

    ELSEIF client->check_on_event( `BUTTON_POST` ).
      client->message_box_display( |Your name is { name }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
