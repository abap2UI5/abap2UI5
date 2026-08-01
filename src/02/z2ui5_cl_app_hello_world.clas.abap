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
      DATA(view) = z2ui5_cl_ai_xml=>factory( ).

      view->open( n  = `View`
                  ns = `mvc`
          )->a( n = `xmlns`
                v = `sap.m`
          )->a( n = `xmlns:mvc`
                v = `sap.ui.core.mvc`
          )->a( n = `xmlns:core`
                v = `sap.ui.core`
          )->a( n = `xmlns:form`
                v = `sap.ui.layout.form`
          )->a( n = `displayBlock`
                v = `true`
          )->a( n = `height`
                v = `100%`

          )->open( `Shell`
              )->open( `Page`
                  )->a( n = `title`
                        v = `abap2UI5 - Hello World`

                  )->open( n  = `SimpleForm`
                           ns = `form`
                      )->a( n = `editable`
                            v = `true`
                      )->open( n  = `content`
                               ns = `form`

                          )->leaf( n  = `Title`
                                   ns = `core`
                              )->a( n = `text`
                                    v = `Enter a value and send it to the server...`

                          )->leaf( `Label`
                              )->a( n = `text`
                                    v = `Name`

                          )->leaf( `Input`
                              )->a( n = `value`
                                    v = client->_bind_edit( name )

                          )->leaf( `Button`
                              )->a( n = `text`
                                    v = `Post`
                              )->a( n = `press`
                                    v = client->_event( `BUTTON_POST` ) ).

      client->view_display( view->stringify( ) ).

    ELSEIF client->check_on_event( `BUTTON_POST` ).
      client->message_box_display( |Your name is { name }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
