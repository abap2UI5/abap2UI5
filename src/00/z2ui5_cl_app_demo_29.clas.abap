CLASS z2ui5_cl_app_demo_29 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE i.
    DATA mv_textarea TYPE string.

    DATA input21 TYPE string.
    DATA input22 TYPE string.
    DATA input32 TYPE i.
    DATA input41 TYPE string.
    DATA input51 TYPE string.
    DATA input52 TYPE string.
  PROTECTED SECTION.

    DATA:
      BEGIN OF app,
        client            TYPE REF TO z2ui5_if_client,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        s_get             TYPE z2ui5_if_client=>ty_s_get,
        s_next            TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_29 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    app-client     = client.
    app-s_get      = client->get( ).
    app-view_popup = ``.

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-s_get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render( ).

    client->set_next( app-s_next ).
    CLEAR app-s_get.
    CLEAR app-s_next.

  ENDMETHOD.

  METHOD z2ui5_on_init.

    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.
    input41 = 'faasdfdfsaVIp'.

    input21 = '40'.
    input22 = '40'.

  ENDMETHOD.

  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BUTTON_POST'.
        app-client->popup_message_toast( |{ product } { quantity } - send to the server| ).
        app-view_popup = 'POPUP_CONFIRM'.


      WHEN 'BACK'.
        app-client->nav_app_leave( app-s_get-id_prev_app_stack ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render.


    app-s_next-xml_main = `<mvc:View controllerName="project1.controller.View1"` && |\n|  &&
                          `    xmlns:mvc="sap.ui.core.mvc" displayBlock="true"` && |\n|  &&
                          `    xmlns:m="sap.m" xmlns="http://www.w3.org/1999/xhtml"` && |\n|  &&
                          `    >` && |\n|  &&
                          `<html><head><style>` && |\n|  &&
                          `body {background-color: powderblue;}` && |\n|  &&
                          `h1   {color: blue;}` && |\n|  &&
                          `p    {color: red;}` && |\n|  &&
                          `</style>` && |\n|  &&
                          `</head>` && |\n|  &&
                          `<body>` && |\n|  &&
                          |\n|  &&
                          `<h1>This is a heading</h1>` && |\n|  &&
                          `<p>This is a paragraph.</p>` && |\n|  &&
                          `<h1>My First JavaScript</h1>` && |\n|  &&
                          `<button type="button" onclick="sap.z2ui5.oView.getController().onEvent( )">` && |\n|  &&
                          `Click me to display Date and Time.</button>` && |\n|  &&
                          `<p id="demo"></p>` && |\n|  &&
                          `<script>` && |\n|  &&
                      "    `function pressdebugger; alert( 'test' );` && |\n|  &&
                          `</script>` &&
                          `</body>` && |\n|  &&
                          `</html> ` && |\n|  &&
                          `</mvc:View>`.


  ENDMETHOD.

ENDCLASS.
