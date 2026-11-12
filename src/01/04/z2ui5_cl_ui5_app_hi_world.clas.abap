CLASS z2ui5_cl_ui5_app_hi_world DEFINITION PUBLIC FINAL.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.
    DATA name TYPE string.

  PROTECTED SECTION.
    DATA client TYPE REF TO z2ui5_if_client.
    METHODS view_display.

  PRIVATE SECTION.
ENDCLASS.


CLASS z2ui5_cl_ui5_app_hi_world IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    " the dispatcher of the app guide (docs/agents/building-apps.md, section
    " 2), without an init arm: this app has nothing to seed. Its one event is
    " asked for by name - an app with more of them dispatches in on_event( )
    " with CASE client->get_event( ), which abaplint's short_case refuses
    " here for a single WHEN
    me->client = client.
    IF client->check_on_navigated( ).
      view_display( ).
    ELSEIF client->check_on_event( `BUTTON_POST` ).
      client->message_box_display( |Your name is { name }| ).
    ENDIF.

  ENDMETHOD.

  METHOD view_display.

    DATA(view) = z2ui5_cl_ui5_view_builder=>factory(
        )->ele( n = `View` ns = `mvc`
            )->a( n = `xmlns`         v = `sap.m`
            )->a( n = `xmlns:mvc`     v = `sap.ui.core.mvc`
            )->a( n = `xmlns:core`    v = `sap.ui.core`
            )->a( n = `xmlns:form`    v = `sap.ui.layout.form`
            )->a( n = `displayBlock`  v = `true`
            )->a( n = `height`        v = `100%`

            )->ele( `Shell`
                )->ele( `Page`
                    )->a( n = `title`  v = `abap2UI5 - Hello World`

                    )->ele( n = `SimpleForm` ns = `form`
                        )->a( n = `editable`  v = `true`

                        )->ele( n = `content` ns = `form`

                            )->tag( n = `Title` ns = `core`
                                )->a( n = `text`  v = `Enter a value and send it to the server...`
                            )->tag( `Label`
                                )->a( n = `text`  v = `Name`
                            )->tag( `Input`
                                )->a( n = `value`  v = client->_bind( name )
                            )->tag( `Button`
                                )->a( n = `text`   v = `Post`
                                )->a( n = `press`  v = client->_event( `BUTTON_POST` ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
