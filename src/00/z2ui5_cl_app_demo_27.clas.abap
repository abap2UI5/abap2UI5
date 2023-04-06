CLASS z2ui5_cl_app_demo_27 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE i.

    DATA input2 TYPE string.
    DATA input31 TYPE i.
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



CLASS Z2UI5_CL_APP_DEMO_27 IMPLEMENTATION.


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


  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BUTTON_POST'.
        app-client->popup_message_toast( |{ product } { quantity } - send to the server| ).
        app-view_popup = 'POPUP_CONFIRM'.

      WHEN 'BUTTON_CONFIRM'.
        app-client->popup_message_toast( |confirm| ).
        app-view_popup = ''.

      WHEN 'BUTTON_CANCEL'.
        app-client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        app-client->nav_app_leave( app-s_get-id_prev_app_stack ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.
    input41 = 'faasdfdfsaVIp'.

  ENDMETHOD.


  METHOD z2ui5_on_render.


    app-s_next-xml_main = z2ui5_cl_xml_view_helper=>factory(
      )->page(
              title          = 'abap2UI5 - Binding Syntax'
              navbuttonpress = app-client->_event( 'BACK' )
              shownavbutton  = abap_true
          )->header_content(
              )->link(
                  text = 'Source_Code'
                  href = app-client->get( )-url_source_code
          )->get_parent(
          )->simple_form( title = 'Binding Syntax' editable = abap_true
              )->content( 'f'
                )->title( 'Expression Binding'

                )->label( 'Documentation'
                )->link(
                  text = 'Expression Binding'
                  href = 'https://sapui5.hana.ondemand.com/sdk/#/topic/daf6852a04b44d118963968a1239d2c0'
                )->label( 'input in uppercase'
                )->input( app-client->_bind( input2 )
                )->input(
                    value   = '{= $' &&  app-client->_bind( input2 ) && '.toUpperCase() }'
                    enabled = abap_false


                )->label( 'max value of the first two inputs'
                )->input( '{ type : "sap.ui.model.type.Integer",' &&
                          '  path:"' &&  app-client->_bind( val = input31 path = abap_true ) && '" }'
                )->input( '{ type : "sap.ui.model.type.Integer",' && |\n|  &&
                          '  path:"' &&  app-client->_bind( val = input32 path = abap_true ) && '" }'
                )->input(
                    value   = '{= Math.max($' &&  app-client->_bind( input31 ) &&', $' &&  app-client->_bind( input32 ) &&  ') }'
                    enabled = abap_false


                )->label( 'only enabled when the quantity equals 500'
                )->input( '{ type : "sap.ui.model.type.Integer",' &&
                          '  path:"' &&  app-client->_bind( val = quantity path = abap_true ) && `"  }`
                )->input(
                    value   = product
                    enabled = '{= 500===$' && app-client->_bind( quantity ) && ' }'

                )->label( 'RegExp Set to enabled if the input contains VIP, ignoring the case.'
                )->input( app-client->_bind( val = input41 )
                )->button(
                    text   = 'VIP'
                    enabled = '{= RegExp(''vip'', ''i'').test($' && app-client->_bind( input41 ) && ') }'


                )->label( 'concatenate both inputs'
                )->input( app-client->_bind( val = input51 )
                )->input( app-client->_bind( val = input52 )
                )->input(
                    value   = '{ parts: [' && |\n|  &&
                              '                "' &&  app-client->_bind( val = input51 path = abap_true ) && '",' && |\n|  &&
                              '                "' &&   app-client->_bind( val = input52 path = abap_true ) && '"' && |\n|  &&
                              '               ]  }'
                    enabled = abap_false

       )->get_root( )->xml_get( ).


  ENDMETHOD.
ENDCLASS.
