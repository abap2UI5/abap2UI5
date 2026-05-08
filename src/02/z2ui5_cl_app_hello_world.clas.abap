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
      DATA(view) = z2ui5_cl_util_xml=>factory(
        )->__( n  = `View`
               ns = `mvc`
               p  = VALUE #( ( n = `xmlns`        v = `sap.m` )
                             ( n = `xmlns:mvc`    v = `sap.ui.core.mvc` )
                             ( n = `xmlns:core`   v = `sap.ui.core` )
                             ( n = `xmlns:form`   v = `sap.ui.layout.form` )
                             ( n = `displayBlock` v = `true` )
                             ( n = `height`       v = `100%` ) )
          )->__( `Shell`
            )->__( n = `Page` a = `title` v = `abap2UI5 - Hello World`
              )->__( n = `SimpleForm` ns = `form` a = `editable` v = `true`
                )->__( n = `content` ns = `form`
                  )->_( n  = `Title`
                        ns = `core`
                        a  = `text`
                        v  = `Make an input here and send it to the server...`
                  )->_( n = `Label` a = `text`  v = `Name`
                  )->_( n = `Input` a = `value` v = client->_bind_edit( name )
                  )->_( n = `Button`
                        p = VALUE #( ( n = `text`  v = `Send` )
                                     ( n = `press` v = client->_event( `BUTTON_POST` ) ) ) ).
      client->view_display( view->stringify( ) ).

    ELSEIF client->check_on_event( `BUTTON_POST` ).
      client->message_box_display( |Your name is { name }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
