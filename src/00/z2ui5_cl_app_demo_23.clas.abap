CLASS z2ui5_cl_app_demo_23 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA product  TYPE string.
    DATA quantity TYPE string.

    DATA client TYPE REF TO z2ui5_if_client.
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

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_APP_DEMO_23 IMPLEMENTATION.


  METHOD z2ui5_if_app~main.

    me->client = client.
    app-s_get  = client->get( ).

    IF app-check_initialized = abap_false.
      app-check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    IF app-s_get-event IS NOT INITIAL.
      z2ui5_on_event( ).
    ENDIF.

    z2ui5_on_render_main( ).

    client->set_next( app-s_next ).
    CLEAR app-s_get.
    CLEAR app-s_next.

  ENDMETHOD.


  METHOD z2ui5_on_event.

    CASE app-s_get-event.

      WHEN 'BACK'.
        client->nav_app_leave( client->get_app( app-s_get-id_prev_app_stack ) ).

      WHEN OTHERS.
        app-view_main = app-s_get-event.

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    product  = 'tomato'.
    quantity = '500'.
    app-view_main = 'NORMAL'.

  ENDMETHOD.


  METHOD z2ui5_on_render_main.

    DATA(lo_view) = z2ui5_cl_xml_view=>factory( ).

    CASE app-view_main.

      WHEN 'XML'.

        DATA(lv_xml) = `<mvc:View controllerName="zzdummy" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.co` &&
    `re.mvc" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n|
    &&
                              `  title="abap2UI5 - XML XML XML" ` && |\n|  &&
                              `  showNavButton="true" ` && |\n|  &&
                              `  navButtonPress="` &&  client->_event( 'BACK' ) && `" ` && |\n|  &&
                              ` > <headerContent ` && |\n|  &&
                              ` > <Link ` && |\n|  &&
                              `  text="Source_Code" ` && |\n|  &&
                              `  target="_blank" ` && |\n|  &&
                              `  href="&lt;system&gt;sap/bc/adt/oo/classes/Z2UI5_CL_APP_DEMO_23/source/main" ` && |\n|  &&
                              ` /></headerContent> <f:SimpleForm ` && |\n|  &&
                              `  title="Form Title" ` && |\n|  &&
                              ` > <f:content ` && |\n|  &&
                              ` > <Title ` && |\n|  &&
                              `  text="Input" ` && |\n|  &&
                              ` /> <Label ` && |\n|  &&
                              `  text="quantity" ` && |\n|  &&
                              ` /> <Input ` && |\n|  &&
                              `  value="` &&  client->_bind( quantity ) && `" ` && |\n|  &&
                              ` /> <Button ` && |\n|  &&
                              `  press="` &&  client->_event( 'NORMAL' ) && `"`  && |\n|  &&
                              `  text="NORMAL" ` && |\n|  &&
                              ` /> <Button ` && |\n|  &&
                                  `  press="` &&  client->_event( 'GENERIC' ) && `"`  && |\n|  &&
                              `  text="GENERIC" ` && |\n|  &&
                              ` /> <Button ` && |\n|  &&
                                 `  press="` &&  client->_event( 'XML' ) && `"`  && |\n|  &&
                              `  text="XML" ` && |\n|  &&
                              ` /></f:content></f:SimpleForm></Page></Shell></mvc:View>`.

        app-s_next-xml_main = z2ui5_cl_xml_view=>hlp_replace_controller_name( lv_xml ).

      WHEN 'NORMAL'.

        lo_view->shell(
          )->page(
                  title          = 'abap2UI5 - NORMAL NORMAL NORMAL'
                  navbuttonpress = client->_event( 'BACK' )
                  shownavbutton  = abap_true
              )->header_content(
                  )->link(
                      text = 'Source_Code'
                      href = z2ui5_cl_xml_view=>hlp_get_source_code_url( app = me get = client->get( ) )
                      target = '_blank'
              )->get_parent(
              )->simple_form( 'Form Title'
                  )->content( 'form'
                      )->title( 'Input'
                      )->label( 'quantity'
                      )->input( client->_bind( quantity )
                      )->button(
                          text  = 'NORMAL'
                          press = client->_event( 'NORMAL' )
                      )->button(
                          text  = 'GENERIC'
                          press = client->_event( 'GENERIC' )
                         )->button(
                          text  = 'XML'
                          press = client->_event( 'XML' ) ).

        app-s_next-xml_main = lo_view->get_root( )->xml_get( ).

      WHEN 'GENERIC'.

        lo_view->_generic( 'Shell' )->_generic(
           name      = `Page`
           t_prop = VALUE #(
               ( n = `title`          v = 'abap2UI5 - GENERIC GENERIC GENERIC' )
               ( n = `showNavButton`  v = `true` )
               ( n = `navButtonPress` v = client->_event( 'BACK' ) ) )
           )->_generic(
                name = `SimpleForm`
                ns   = `form`
                t_prop = VALUE #(
                    ( n = `title` v = 'title' )
           ) )->_generic(
                name = `content`
                ns   = `form`
           )->_generic(
                name = `Label`
                t_prop = VALUE #(
                    ( n = `text` v = 'quantity' )
           ) )->get_parent( )->_generic(
                name = `Input`
                t_prop = VALUE #(
                    ( n = `value` v = client->_bind( quantity ) )
           ) )->get_parent(
            )->_generic(
                name = `Button`
                t_prop = VALUE #(
                    ( n = `text`  v = `NORMAL` )
                    ( n = `press` v = client->_event( 'NORMAL' ) ) )
               )->get_parent(
               )->_generic(
                name = `Button`
                t_prop = VALUE #(
                    ( n = `text`  v = `GENERIC` )
                    ( n = `press` v = client->_event( 'GENERIC' ) ) )
                )->get_parent(
                     )->_generic(
                name = `Button`
                t_prop = VALUE #(
                    ( n = `text`  v = `XML` )
                    ( n = `press` v = client->_event( 'XML' ) ) ) ).

        app-s_next-xml_main = lo_view->get_root( )->xml_get( ).

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
