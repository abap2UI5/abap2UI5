CLASS z2ui5_cl_app_demo_18 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA quantity TYPE string.
    DATA mv_textarea TYPE string.

  PROTECTED SECTION.

    DATA:
      BEGIN OF app,
        client            TYPE REF TO z2ui5_if_client,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        get               TYPE z2ui5_if_client=>ty_s_get,
        next              TYPE z2ui5_if_client=>ty_s_next,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_view_main
      RETURNING
        VALUE(result) TYPE string.
    METHODS z2ui5_on_view_second
      RETURNING
        VALUE(result) TYPE string.
    METHODS z2ui5_on_popup_input
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_18 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    " there are no restrictions how you structure your app
    " you can use this class as a template or find a better way

    app-client     = client. "we collect all app infos in the structure app
    app-get        = client->get( ). "read the frontend infos
    app-view_popup = ``. "we display popups only once so clear it after every roundtrip

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
        app-next-xml_main = z2ui5_on_view_main( ).
      WHEN 'VIEW_SECOND'.
        app-next-xml_main = z2ui5_on_view_second( ).
    ENDCASE.

    "popup rendering
    CASE app-view_popup.
      WHEN 'POPUP_INPUT'.
        app-next-xml_popup = z2ui5_on_popup_input( ).
    ENDCASE.

    "set the data for the frontend
    client->set_next( app-next ).

    "the app is serialized and persisted, we delete all data which is not needed in the future before
    CLEAR app-get.
    CLEAR app-next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-get-event.

      WHEN 'SHOW_POPUP'.
        app-view_popup = 'POPUP_INPUT'.

      WHEN 'POPUP_CONFIRM'.
        app-client->popup_message_toast( |confirm| ).

      WHEN 'POPUP_CANCEL'.
        CLEAR mv_textarea.
        app-client->popup_message_toast( |cancel| ).

      WHEN 'SHOW_VIEW_MAIN'.
        app-view_main = 'VIEW_MAIN'.
      WHEN 'SHOW_VIEW_SECOND'.
        app-view_main = 'VIEW_SECOND'.

      WHEN 'BACK'.
        app-client->nav_app_leave( app-get-id_prev_app_stack ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.

  ENDMETHOD.


  METHOD z2ui5_on_view_main.

    result = app-next-xml_main = z2ui5_cl_xml_view_helper=>factory(
        )->page(
                title          = 'abap2UI5 - Template'
                navbuttonpress = app-client->_event( 'BACK' )
                shownavbutton  = abap_true
            )->header_content(
                )->link(
                    text = 'Source_Code'
                    href = app-client->get( )-url_source_code
            )->get_parent(
            )->simple_form( title = 'VIEW_MAIN' editable = abap_true
                )->content( 'f'
                    )->title( 'Input'
                    )->label( 'quantity'
                    )->input( app-client->_bind( quantity )
                    )->label( 'text'
                    )->input(
                        value   = app-client->_bind( mv_textarea )
                        enabled = abap_false
                    )->button(
                        text  = 'show popup input'
                        press = app-client->_event( 'SHOW_POPUP' )
                        )->get_parent( )->get_parent( )->footer(
                      )->overflow_toolbar(
              )->toolbar_spacer(
              )->overflow_toolbar_button(
                  text  = 'Clear'
                  press = app-client->_event( 'BUTTON_CLEAR' )
                  type  = 'Reject'
                  icon  = 'sap-icon://delete'
              )->button(
                  text  = 'Go to View Second'
                  press = app-client->_event( 'SHOW_VIEW_SECOND' )
         )->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_view_second.
    result = app-next-xml_main = z2ui5_cl_xml_view_helper=>factory(
         )->page(
                 title          = 'abap2UI5 - Template'
                 navbuttonpress = app-client->_event( 'BACK' )
                 shownavbutton  = abap_true
             )->header_content(
                 )->link(
                     text = 'Source_Code'
                     href = app-client->get( )-url_source_code
             )->get_parent(
             )->simple_form( 'VIEW_SECOND'
                 )->content( 'f'

           )->get_parent( )->get_parent( )->footer(
           )->overflow_toolbar(
               )->toolbar_spacer(
               )->overflow_toolbar_button(
                   text  = 'Clear'
                   press = app-client->_event( 'BUTTON_CLEAR' )
                   type  = 'Reject'
                   icon  = 'sap-icon://delete'
               )->button(
                   text  = 'Go to View Main'
                   press = app-client->_event( 'SHOW_VIEW_MAIN' )
          )->get_root( )->xml_get( ).

  ENDMETHOD.


  METHOD z2ui5_on_popup_input.

    result = app-next-xml_popup = z2ui5_cl_xml_view_helper=>factory( )->dialog(
                      title = 'Title'
                      icon = 'sap-icon://edit'
                  )->content(
                      )->text_area(
                          height = '100%'
                          width  = '100%'
                          value  = app-client->_bind( mv_textarea )
                  )->get_parent(
                  )->footer( )->overflow_toolbar(
                      )->toolbar_spacer(
                      )->button(
                          text  = 'Cancel'
                          press = app-client->_event( 'POPUP_CANCEL' )
                      )->button(
                          text  = 'Confirm'
                          press = app-client->_event( 'POPUP_CONFIRM' )
                          type  = 'Emphasized' )->get_root( )->xml_get( ).


  ENDMETHOD.
ENDCLASS.
