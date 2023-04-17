CLASS z2ui5_cl_app_demo_32 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_value TYPE string.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_32 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client = client.
    app-get      = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-next ).
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'POST'.
        client->popup_message_toast( app-get-event_data ).

      WHEN 'MYCC'.
        client->popup_message_toast( 'MYCC event ' && mv_value ).

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    app-view_main = 'VIEW_MAIN'.
    mv_value = 'test'.

  ENDMETHOD.


  METHOD z2ui5_on_render.

    app-next-xml_main = `<mvc:View controllerName="project1.controller.View1"` && |\n|  &&
                          `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` && |\n|  &&
                          `  xmlns:z2ui5="z2ui5"  xmlns:m="sap.m" xmlns="http://www.w3.org/1999/xhtml"` && |\n|  &&
                          `    ><m:Button ` && |\n|  &&
                          `  text="back" ` && |\n|  &&
                          `  press="` && client->_event( 'BACK' ) && `" ` && |\n|  &&
                          `  class="sapUiContentPadding sapUiResponsivePadding--content"/> ` && |\n|  &&
                   `       <m:Link target="_blank" text="Source_Code" href="` && z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) ) && `"/>` && |\n|  &&
                          `<html><head><style>` && |\n|  &&
                          `body {background-color: powderblue;}` && |\n|  &&
                          `h1   {color: blue;}` && |\n|  &&
                          `p    {color: red;}` && |\n|  &&
                          `</style>` &&
                          `</head>` && |\n|  &&
                          `<body>` && |\n|  &&
                          `<h1>This is a heading with css</h1>` && |\n|  &&
                          `<p>This is a paragraph with css.</p>` && |\n|  &&
                          `<h1>My First JavaScript</h1>` && |\n|  &&
                          `<button onclick="myFunction()" type="button">send</button>` && |\n|  &&
                          `<Input id='input' value='frontend data' /> ` &&
                          `<script> function myFunction( ) { sap.z2ui5.oView.getController().onEvent({ 'EVENT' : 'POST', 'METHOD' : 'UPDATE' }, document.getElementById(sap.z2ui5.oView.createId( "input" )).value ) } </script>` && |\n|  &&
                          `</body>` && |\n|  &&
                          `</html> ` && |\n|  &&
                            `</mvc:View>`.

    app-next-xml_main = z2ui5_cl_xml_view=>hlp_replace_controller_name( app-next-xml_main ).

  ENDMETHOD.
ENDCLASS.
