CLASS z2ui5_cl_app_demo_23 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.

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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_app_demo_23 IMPLEMENTATION.


  METHOD z2ui5_if_app~controller.

    app-client = client.
    app-s_get  = client->get( ).
    "  app-view_popup = ``.

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
    app-view_main = 'NORMAL'.

  ENDMETHOD.

  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BACK'.
        app-client->nav_app_leave( app-s_get-id_prev_app_stack ).

      WHEN OTHERS.
        app-view_main = app-s_get-event.

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    CASE app-view_main.

      WHEN 'XML'.

        app-s_next-xml_main = `<mvc:View controllerName="zzdummy" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.co` &&
`re.mvc" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n|
&&
                              `  title="abap2UI5 - XML XML XML" ` && |\n|  &&
                              `  showNavButton="true" ` && |\n|  &&
                              `  navButtonPress="onEvent( { &apos;EVENT&apos; : &apos;BACK&apos;, &apos;METHOD&apos; : &apos;UPDATE&apos; } )" ` && |\n|  &&
                              ` > <headerContent ` && |\n|  &&
                              ` > <Link ` && |\n|  &&
                              `  text="Source_Code" ` && |\n|  &&
                              `  target="_blank" ` && |\n|  &&
                              `  href="https://6654aaf7-905f-48ea-b013-3811c03fcba8.abap-web.us10.hana.ondemand.com/sap/bc/adt/oo/classes/Z2UI5_CL_APP_DEMO_23/source/main" ` && |\n|  &&
                              ` /></headerContent> <f:SimpleForm ` && |\n|  &&
                              `  title="Form Title" ` && |\n|  &&
                              ` > <f:content ` && |\n|  &&
                              ` > <Title ` && |\n|  &&
                              `  text="Input" ` && |\n|  &&
                              ` /> <Label ` && |\n|  &&
                              `  text="quantity" ` && |\n|  &&
                              ` /> <Input ` && |\n|  &&
                              `  value="` &&  app-client->_bind( quantity ) && `" ` && |\n|  &&
                              ` /> <Button ` && |\n|  &&
                              `  press="` &&  app-client->_event( 'NORMAL' ) && `"`  && |\n|  &&
                              `  text="NORMAL" ` && |\n|  &&
                              ` /> <Button ` && |\n|  &&
                                  `  press="` &&  app-client->_event( 'GENERIC' ) && `"`  && |\n|  &&
                              `  text="GENERIC" ` && |\n|  &&
                              ` /> <Button ` && |\n|  &&
                                 `  press="` &&  app-client->_event( 'XML' ) && `"`  && |\n|  &&
                              `  text="XML" ` && |\n|  &&
                              ` /></f:content></f:SimpleForm></Page></Shell></mvc:View>`.


      WHEN 'NORMAL'.

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
                      )->button(
                          text  = 'NORMAL'
                          press = app-client->_event( 'NORMAL' )
                      )->button(
                          text  = 'GENERIC'
                          press = app-client->_event( 'GENERIC' )
                         )->button(
                          text  = 'XML'
                          press = app-client->_event( 'XML' )
           )->get_root( )->xml_get( ).


      WHEN 'GENERIC'.

        DATA(li_view) = z2ui5_cl_xml_view_helper=>factory( ).

        li_view->_generic(
           name   = `Page`
           t_prop = VALUE #(
               ( name = `title`          value = 'abap2UI5 - GENERIC GENERIC GENERIC' )
               ( name = `showNavButton`  value = `true` )
               ( name = `navButtonPress` value = app-client->_event( 'BACK' ) )
           ) )->_generic(
                name = `SimpleForm`
                ns   = `f`
                t_prop = VALUE #(
                    ( name = `title` value = 'title' )
           ) )->_generic(
                name = `content`
                ns   = `f`
           )->_generic(
                name = `Label`
                t_prop = VALUE #(
                    ( name = `text` value = 'quantity' )
           ) )->get_parent( )->_generic(
                name = `Input`
                t_prop = VALUE #(
                    ( name = `value` value = app-client->_bind( quantity ) )
           ) )->get_parent( )->_generic(
                name = `Button`
                t_prop = VALUE #(
                    ( name = `text`  value = `NORMAL` )
                    ( name = `press` value = app-client->_event( 'NORMAL' ) ) ) ).

        app-s_next-xml_main = li_view->get_root( )->xml_get( ).


    ENDCASE.

  ENDMETHOD.

  METHOD z2ui5_on_render_popup.


  ENDMETHOD.

ENDCLASS.
