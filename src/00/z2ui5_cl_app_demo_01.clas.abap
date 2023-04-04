CLASS z2ui5_cl_app_demo_01 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.
    DATA check_initialized TYPE abap_bool.

    DATA mv_textarea TYPE string.
    DATA mv_show_popup_active TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_01 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    CASE client->get( )-lifecycle_method.

      WHEN client->cs-lifecycle_method-on_event.

        IF check_initialized = abap_false.
          check_initialized = abap_true.

          product  = 'tomato'.
          quantity = '500'.

          RETURN.
        ENDIF.


        CASE client->get( )-event.

          WHEN 'BUTTON_POST'.
            client->popup_message_toast( |{ product } { quantity } - send to the server| ).
            mv_show_popup_active = abap_true.

          WHEN 'BACK'.
            client->nav_app_leave( client->get( )-id_prev_app_stack ).

        ENDCASE.


      WHEN client->cs-lifecycle_method-on_rendering.

*        client->set_view( z2ui5_cl_xml_view_helper=>factory(
*            )->page(
*                    title          = 'abap2UI5 - First Example'
*                    navbuttonpress = client->_event( 'BACK' )
*                    shownavbutton  = abap_true
*                )->header_content(
*                    )->link(
*                        text = 'Source_Code'
*                        href = client->get( )-s_request-url_source_code
*                )->get_parent(
*                )->simple_form( 'Form Title'
*                    )->content( 'f'
*                        )->title( 'Input'
*                        )->label( 'quantity'
*                        )->input( client->_bind( quantity )
*                        )->label( 'product'
*                        )->input(
*                            value   = product
*                            enabled = abap_false
*                        )->button(
*                            text  = 'post'
*                            press = client->_event( 'BUTTON_POST' )
*             )->get_root( )->xml_get( ) ).
*
*        RETURN.
        client->set_view( xml = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.` &&
`core.mvc" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n|
&&
                                `  title="abap2UI5 - TEST TEST TEST" ` && |\n|  &&
                                `  showNavButton="true" ` && |\n|  &&
                                `  navButtonPress="` && client->_event( 'BACK' ) && `" ` && |\n|  &&
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
                                `  value="` &&   client->_bind( quantity )  && `" ` && |\n|  &&
                                ` /> <Label ` && |\n|  &&
                                `  text="product" ` && |\n|  &&
                                ` /> <Input ` && |\n|  &&
                                `  enabled="false" ` && |\n|  &&
                                `  value="tomato" ` && |\n|  &&
                                ` /> <Button ` && |\n|  &&
                                `  press="` && client->_event( 'BUTTON_POST' ) && `" ` && |\n|  &&
                                `  text="post" ` && |\n|  &&
                                ` /></f:content></f:SimpleForm></Page></Shell></mvc:View>`  ).


        IF mv_show_popup_active = abap_true.
          mv_show_popup_active = abap_false.

          DATA(li_popup) = z2ui5_cl_xml_view_helper=>factory( check_popup = abap_true ).

          li_popup->dialog(
                   "   stretch = mv_stretch_active
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
                          press = client->_event( 'BUTTON_TEXTAREA_CANCEL' )
                      )->button(
                          text  = 'Confirm'
                          press = client->_event( 'BUTTON_TEXTAREA_CONFIRM' )
                          type  = 'Emphasized' ).

          client->set_popup( li_popup->xml_get( ) ).
        ENDIF.
        RETURN.

        client->factory_view(
            )->page(
                    title          = 'abap2UI5 - First Example'
                    navbuttonpress = client->_event( 'BACK' )
                )->header_content(
                    )->link(
                        text = 'Source_Code'
                        href = client->get( )-s_request-url_source_code
                )->get_parent(
            )->simple_form( 'Form Title'
                )->content( 'f'
                    )->title( 'Input'
                    )->label( 'quantity'
                    )->input( client->_bind( quantity )
                    )->label( 'product'
                    )->input(
                        value   = product
                        enabled = abap_false
                    )->button(
                        text  = 'post'
                        press = client->_event( 'BUTTON_POST' ) ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
