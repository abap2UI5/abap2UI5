CLASS z2ui5_cl_app_demo_26 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA mv_textarea TYPE string.

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
    METHODS z2ui5_on_render_main.
    METHODS z2ui5_on_render_popup.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_26 IMPLEMENTATION.


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

    z2ui5_on_render_main( ).
    z2ui5_on_render_popup( ).

    client->set_next( app-s_next ).
    CLEAR app-s_get.
    CLEAR app-s_next.

  ENDMETHOD.

  METHOD z2ui5_on_init.

    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.

  ENDMETHOD.

  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'POPOVER'.
        app-view_popup = 'POPOVER'.
        app-s_next-popup_open_by_id = 'TEST'.

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


  METHOD z2ui5_on_render_main.

    CASE app-view_main.

      WHEN 'VIEW_MAIN'.

        app-s_next-xml_main = z2ui5_cl_xml_view_helper=>factory(
          )->page(
                  title          = 'abap2UI5 - NORMAL NORMAL NORMAL'
                  navbuttonpress = app-client->_event( 'BACK' )
                  shownavbutton  = abap_true
              )->header_content(
                  )->link(
                      text = 'Source_Code'
                      href = app-client->get( )-url_source_code
              )->get_parent(
              )->simple_form( 'Form Title'
                  )->content( 'f'
                      )->title( 'Input'
                      )->label( 'quantity'
                      )->input( app-client->_bind( quantity )
                      )->label( 'product'
                      )->input(
                          value   = product
                          enabled = abap_false
                      )->button(
                          text  = 'post'
                          press = app-client->_event( 'POPOVER' )
                          id = 'TEST'
           )->get_root( )->xml_get( ).


      WHEN 'VIEW_SECOND'.



    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_on_render_popup.

    CASE app-view_popup.

      WHEN 'POPOVER'.

        app-s_next-xml_popup = z2ui5_cl_xml_view_helper=>factory( )->popover(
                    title = 'Title'
                   " icon = 'sap-icon://edit'
                )->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'Cancel'
                        press = app-client->_event( 'BUTTON_CANCEL' )
                    )->button(
                        text  = 'Confirm'
                        press = app-client->_event( 'BUTTON_CONFIRM' )
                        type  = 'Emphasized'
                  )->get_parent( )->get_parent(
              )->input( value = 'abcd'
              )->get_root( )->xml_get( ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
