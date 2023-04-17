CLASS z2ui5_cl_app_demo_26 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    data mv_placement type string.

  PROTECTED SECTION.

    data client            TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF app,
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



CLASS Z2UI5_CL_APP_DEMO_26 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client     = client.
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


  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'POPOVER'.
        app-view_popup = 'POPOVER'.
        app-s_next-popup_open_by_id = 'TEST'.

      WHEN 'BUTTON_CONFIRM'.
        client->popup_message_toast( |confirm| ).
        app-view_popup = ''.

      WHEN 'BUTTON_CANCEL'.
        client->popup_message_toast( |cancel| ).
        app-view_popup = ''.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-s_get-id_prev_app_stack ) ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    mv_placement = 'Left'.
    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'VIEW_MAIN'.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    CASE app-view_main.

      WHEN 'VIEW_MAIN'.

        app-s_next-xml_main = Z2UI5_CL_XML_VIEW=>factory( )->shell(
          )->page(
                  title          = 'abap2UI5 - Popover Examples'
                  navbuttonpress = client->_event( 'BACK' )
                  shownavbutton  = abap_true
              )->header_content(
                  )->link( text = 'Demo' target = '_blank' href = `https://twitter.com/OblomovDev/status/1643899059839672321`
                  )->link(
                      text = 'Source_Code' target = '_blank'
                      href = Z2UI5_CL_XML_VIEW=>hlp_get_source_code_url( app = me get = client->get( ) )
              )->get_parent(
              )->simple_form( 'Popover'
                  )->content( 'form'
                      )->title( 'Input'
                      )->label( 'Link'
                      )->link(  text = 'Documentation UI5 Popover Control' href = 'https://openui5.hana.ondemand.com/entity/sap.m.Popover'
                      )->label( 'placement'
                      )->segmented_button( client->_bind( mv_placement )
                            )->items(
                            )->segmented_button_item(
                                    key = 'Left'
                                    icon = 'sap-icon://add-favorite'
                                    text = 'Left'
                            )->segmented_button_item(
                                    key = 'Top'
                                    icon = 'sap-icon://accept'
                                    text = 'Top'
                            )->segmented_button_item(
                                    key = 'Bottom'
                                    icon = 'sap-icon://accept'
                                    text = 'Bottom'
                            )->segmented_button_item(
                                    key = 'Right'
                                    icon = 'sap-icon://attachment'
                                    text = 'Right'
                      )->get_parent( )->get_parent(
                      )->label( 'popover'
                      )->button(
                          text  = 'show'
                          press = client->_event( 'POPOVER' )
                          id = 'TEST'
                      )->button(
                          text  = 'cancel'
                          press = client->_event( 'POPOVER' )
                    )->button(
                          text  = 'post'
                          press = client->_event( 'POPOVER' )
           )->get_root( )->xml_get( ).


      WHEN 'VIEW_SECOND'.



    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_popup.

    CASE app-view_popup.

      WHEN 'POPOVER'.

        app-s_next-xml_popup = Z2UI5_CL_XML_VIEW=>factory_popup( )->popover(
                    title     = 'Popover Title'
                    placement = mv_placement
                )->footer( )->overflow_toolbar(
                    )->toolbar_spacer(
                    )->button(
                        text  = 'Cancel'
                        press = client->_event( 'BUTTON_CANCEL' )
                    )->button(
                        text  = 'Confirm'
                        press = client->_event( 'BUTTON_CONFIRM' )
                        type  = 'Emphasized'
                  )->get_parent( )->get_parent(
              )->text(  'make an input here:'
              )->input( value = 'abcd'
              )->get_root( )->xml_get( ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
