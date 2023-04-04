CLASS z2ui5_cl_app_demo_18 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA mv_textarea TYPE string.

    DATA:
      BEGIN OF app,
        client            TYPE REF TO z2ui5_if_client,
        check_initialized TYPE abap_bool,
        view_main         TYPE string,
        view_popup        TYPE string,
        s_get             TYPE z2ui5_if_client=>ty_s_get,
        s_set             TYPE z2ui5_if_client=>ty_s_set,
      END OF app.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS z2ui5_on_render_main.
    METHODS z2ui5_on_render_popup.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_18 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    app-client = client.
    app-s_get  = client->get( ).

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-s_get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render_main( ).
    z2ui5_on_render_popup( ).

    client->set( s_data = app-s_set ).
    CLEAR app-s_get.
    CLEAR app-s_set.

  ENDMETHOD.

  METHOD z2ui5_on_init.

    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'MANUAL'.

  ENDMETHOD.

  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BUTTON_POST'.
        app-client->popup_message_toast( |{ product } { quantity } - send to the server| ).
        app-s_set-xml_main = 'NORMAL'.

      WHEN 'BACK'.
        app-client->nav_app_leave( app-s_get-id_prev_app_stack ).

    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_on_render_popup.

    CASE app-s_set-xml_popup.

      WHEN 'POPUP_CONFIRM'.

        app-s_set-xml_popup = z2ui5_cl_xml_view_helper=>factory( check_popup = abap_true )->dialog(
                 "   stretch = mv_stretch_active
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
                        press = app-client->_event( 'BUTTON_TEXTAREA_CANCEL' )
                    )->button(
                        text  = 'Confirm'
                        press = app-client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                        type  = 'Emphasized' )->xml_get( ).

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    CASE app-s_set-xml_main.

      WHEN 'MANUAL'.

        app-s_set-xml_main =
`<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.` &&
`core.mvc" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n|
&&
                            `  title="abap2UI5 - MANUAL MANUAL MANUAL" ` && |\n|  &&
                            `  showNavButton="true" ` && |\n|  &&
                            `  navButtonPress="` && app-client->_event( 'BACK' ) && `" ` && |\n|  &&
                            ` > <headerContent ` && |\n|  &&
                            ` > <Link ` && |\n|  &&
                            `  text="Source_Code" ` && |\n|  &&
                            `  target="_blank" ` && |\n|  &&
                            `  href="https://6654aaf7-905f-48ea-b013-3811c03fcba8.abap-web.us10.hana.ondemand.com/sap/bc/adt/oo/classes/Z2UI5_CL_APP_DEMO_01/source/main" ` && |\n|  &&
                            ` /></headerContent> <f:SimpleForm ` && |\n|  &&
                            `  title="Form Title" ` && |\n|  &&
                            `  layout="ResponsiveGridLayout" ` && |\n|  &&
                            ` > <f:content ` && |\n|  &&
                            ` > <Title ` && |\n|  &&
                            `  text="Input" ` && |\n|  &&
                            ` /> <Label ` && |\n|  &&
                            `  text="quantity" ` && |\n|  &&
                            ` /> <Input ` && |\n|  &&
                            `  value="` &&   app-client->_bind( quantity )  && `" ` && |\n|  &&
                            ` /> <Label ` && |\n|  &&
                            `  text="product" ` && |\n|  &&
                            ` /> <Input ` && |\n|  &&
                            `  enabled="false" ` && |\n|  &&
                            `  value="tomato" ` && |\n|  &&
                            ` /> <Button ` && |\n|  &&
                            `  press="` && app-client->_event( 'BUTTON_POST' ) && `" ` && |\n|  &&
                            `  text="post" ` && |\n|  &&
                            ` /></f:content></f:SimpleForm></Page></Shell></mvc:View>`.

      WHEN 'NORMAL'.

        app-s_set-xml_main = z2ui5_cl_xml_view_helper=>factory(
          )->page(
                  title          = 'abap2UI5 - NORMAL NORMAL NORMAL'
                  navbuttonpress = app-client->_event( 'BACK' )
                  shownavbutton  = abap_true
              )->header_content(
                  )->link(
                      text = 'Source_Code'
                      href = app-client->get( )-s_request-url_source_code
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
                          press = app-client->_event( 'BUTTON_POST' )
           )->get_root( )->xml_get( ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.
