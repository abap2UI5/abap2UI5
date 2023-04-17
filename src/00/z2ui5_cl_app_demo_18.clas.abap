CLASS z2ui5_cl_app_demo_18 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA quantity TYPE string.
    DATA mv_textarea TYPE string.

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

    METHODS z2ui5_render_view_main
      RETURNING
        VALUE(result) TYPE string.

    METHODS z2ui5_render_view_second
      RETURNING
        VALUE(result) TYPE string.

    METHODS z2ui5_render_popup_input
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_18 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    " there are no restrictions how you structure your app
    " you can use this class as a template or find a better way

    me->client     = client.
    "we collect all app infos in the structure app
    app-get        = client->get( ).
    "we display popups only once so clear it after every roundtrip
    app-view_popup = ``.

    "do this only at the first start of the app, set init values
    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    "user commands are handler here
    IF app-get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    "view rendering
    CASE app-view_main.
      WHEN 'VIEW_MAIN'.
        app-next-xml_main = z2ui5_render_view_main( ).
      WHEN 'VIEW_SECOND'.
        app-next-xml_main = z2ui5_render_view_second( ).
    ENDCASE.

    "popup rendering
    CASE app-view_popup.
      WHEN 'POPUP_INPUT'.
        app-next-xml_popup = z2ui5_render_popup_input( ).
    ENDCASE.

    "set the data for the frontend
    client->set_next( app-next ).

    "the app will be serialized and persisted, we delete all data which is not needed in the future before
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'SHOW_POPUP'.
        app-view_popup = 'POPUP_INPUT'.

      WHEN 'POPUP_CONFIRM'.
        client->popup_message_toast( |confirm| ).

      WHEN 'POPUP_CANCEL'.
        CLEAR mv_textarea.
        client->popup_message_toast( |cancel| ).

      WHEN 'SHOW_VIEW_MAIN'.
        app-view_main = 'VIEW_MAIN'.
      WHEN 'SHOW_VIEW_SECOND'.
        app-view_main = 'VIEW_SECOND'.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.

  ENDMETHOD.


  METHOD z2ui5_render_popup_input.

    result = z2ui5_cl_xml_view=>factory_popup( )->dialog(
                      title = 'Title'
                      icon = 'sap-icon://edit'
                  )->content(
                      )->text_area(
                          height = '100%'
                          width  = '100%'
                          value  = client->_bind( mv_textarea )
                  )->get_parent(
                  )->footer( )->overflow_toolbar(
                      )->toolbar_spacer(
                      )->button(
                          text  = 'Cancel'
                          press = client->_event( 'POPUP_CANCEL' )
                      )->button(
                          text  = 'Confirm'
                          press = client->_event( 'POPUP_CONFIRM' )
                          type  = 'Emphasized' )->get_root( )->xml_get( ).


  ENDMETHOD.


  METHOD z2ui5_render_view_main.

    result = z2ui5_cl_xml_view=>factory( )->shell(
        )->page(
                title          = 'abap2UI5 - Template'
                navbuttonpress = client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code' target = '_blank'
                    href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
            )->get_parent(
            )->simple_form( title = 'VIEW_MAIN' editable = abap_true
                )->content( 'form'
                    )->title( 'Input'
                    )->label( 'quantity'
                    )->input( client->_bind( quantity )
                    )->label( 'text'
                    )->input(
                        value   = client->_bind( mv_textarea )
                        enabled = abap_false
                    )->button(
                        text  = 'show popup input'
                        press = client->_event( 'SHOW_POPUP' )
                        )->get_parent( )->get_parent( )->footer(
                      )->overflow_toolbar(
              )->toolbar_spacer(
              )->overflow_toolbar_button(
                  text  = 'Clear'
                  press = client->_event( 'BUTTON_CLEAR' )
                  type  = 'Reject'
                  icon  = 'sap-icon://delete'
              )->button(
                  text  = 'Go to View Second'
                  press = client->_event( 'SHOW_VIEW_SECOND' )
         )->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_render_view_second.

    result = z2ui5_cl_xml_view=>factory( )->shell(
         )->page(
                 title          = 'abap2UI5 - Template'
                 navbuttonpress = client->_event( 'BACK' )
                 shownavbutton  = abap_true
             )->header_content(
                 )->link(
                     text = 'Source_Code'
                     href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
             )->get_parent(
             )->simple_form( 'VIEW_SECOND'
                 )->content( 'form'

           )->get_parent( )->get_parent( )->footer(
           )->overflow_toolbar(
               )->toolbar_spacer(
               )->overflow_toolbar_button(
                   text  = 'Clear'
                   press = client->_event( 'BUTTON_CLEAR' )
                   type  = 'Reject'
                   icon  = 'sap-icon://delete'
               )->button(
                   text  = 'Go to View Main'
                   press = client->_event( 'SHOW_VIEW_MAIN' )
          )->get_root( )->xml_get( ).

  ENDMETHOD.
ENDCLASS.
