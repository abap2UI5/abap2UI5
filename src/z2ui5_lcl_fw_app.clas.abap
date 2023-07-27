CLASS z2ui5_lcl_fw_app DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF ms_error,
        x_error TYPE REF TO cx_root,
      END OF ms_error.

    DATA:
      BEGIN OF ms_home,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.

    CLASS-METHODS factory_error
      IMPORTING
        error         TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_lcl_fw_app.

    DATA mv_is_initialized TYPE abap_bool.

    DATA client TYPE REF TO z2ui5_if_client.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_error.
    METHODS view_display_start.

  PRIVATE SECTION.
    DATA lv_check_demo TYPE abap_bool.

ENDCLASS.


CLASS z2ui5_lcl_fw_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_is_initialized = abap_false.
      mv_is_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    z2ui5_on_event( ).

    IF ms_error-x_error IS BOUND.
      view_display_error( ).
    ELSE.
      view_display_start( ).
    ENDIF.

  ENDMETHOD.

  METHOD factory_error.

    result = NEW #( ).
    result->ms_error-x_error = error.

  ENDMETHOD.

  METHOD z2ui5_on_init.

    IF ms_error-x_error IS NOT BOUND.
      ms_home-btn_text       = `check`.
      ms_home-btn_event_id   = `BUTTON_CHECK`.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon       = `sap-icon://validate`.
      ms_home-classname      = `z2ui5_cl_app_hello_world`.
    ENDIF.

    lv_check_demo = abap_true.

  ENDMETHOD.

  METHOD z2ui5_on_event.

    CASE client->get( )-event.

      WHEN `BUTTON_CHANGE`.
        ms_home-btn_text       = `check`.
        ms_home-btn_event_id   = `BUTTON_CHECK`.
        ms_home-btn_icon       = `sap-icon://validate`.
        ms_home-class_editable = abap_true.

      WHEN `BUTTON_CHECK`.
        TRY.
            DATA li_app_test TYPE REF TO z2ui5_if_app.
            ms_home-classname = z2ui5_cl_utility=>get_trim_upper( ms_home-classname ).
            CREATE OBJECT li_app_test TYPE (ms_home-classname).

            client->message_toast_display( `App is ready to start!` ).
            ms_home-btn_text          = `edit`.
            ms_home-btn_event_id      = `BUTTON_CHANGE`.
            ms_home-btn_icon          = `sap-icon://edit`.
            ms_home-class_value_state = `Success`.
            ms_home-class_editable    = abap_false.

          CATCH cx_root INTO DATA(lx) ##CATCH_ALL.
            ms_home-class_value_state_text = lx->get_text( ).
            ms_home-class_value_state      = `Warning`.
            client->message_box_display( text = ms_home-class_value_state_text type = `error` ).
        ENDTRY.

      WHEN `DEMOS`.

        DATA li_app TYPE REF TO z2ui5_if_app.
        TRY.
            CREATE OBJECT li_app TYPE (`Z2UI5_CL_APP_DEMO_00`).
            lv_check_demo = abap_true.
            client->nav_app_call( li_app ).
          CATCH cx_root.
            lv_check_demo = abap_false.
        ENDTRY.

    ENDCASE.

  ENDMETHOD.


  METHOD view_display_error.

    WHILE ms_error-x_error->previous IS BOUND.
      ms_error-x_error = ms_error-x_error->previous.
    ENDWHILE.

    DATA(lv_txt)       = ms_error-x_error->get_text( ).
    DATA(lv_descr)     = escape( val = lv_txt format = cl_abap_format=>e_xml_attr ).

    DATA(ls_get)     = client->get( ).
    DATA(lv_url) = ls_get-s_config-origin && ls_get-s_config-pathname.
    SHIFT lv_url LEFT DELETING LEADING ` `.
    DATA(lv_url_app)  = lv_url && ls_get-s_config-search.
    lv_url = escape( val = lv_url format = cl_abap_format=>e_xml_attr ).
    lv_url_app = escape( val = lv_url_app format = cl_abap_format=>e_xml_attr ).

    DATA(lv_xml) = `<mvc:View ` && |\n| &&
                   `  xmlns="sap.m" ` && |\n| &&
                   `  xmlns:z2ui5="z2ui5" ` && |\n| &&
                   `  xmlns:core="sap.ui.core" ` && |\n| &&
                   `  xmlns:mvc="sap.ui.core.mvc" ` && |\n| &&
                   `  xmlns:layout="sap.ui.layout" ` && |\n| &&
                   `  xmlns:f="sap.f" ` && |\n| &&
                   `  xmlns:form="sap.ui.layout.form" ` && |\n| &&
                   `  xmlns:editor="sap.ui.codeeditor" ` && |\n| &&
                   `  xmlns:mchart="sap.suite.ui.microchart" ` && |\n| &&
                   `  xmlns:webc="sap.ui.webc.main" ` && |\n| &&
                   `  xmlns:uxap="sap.uxap" ` && |\n| &&
                   `  xmlns:sap="sap" ` && |\n| &&
                   `  xmlns:text="sap.ui.richtextedito" ` && |\n| &&
                   `  xmlns:html="http://www.w3.org/1999/xhtml" ` && |\n| &&
                   `  displayBlock="true" ` && |\n| &&
                   `  height="100%" ` && |\n| &&
                   `  controllerName="z2ui5_controller" ` && |\n| &&
                   ` > <Shell>` && |\n| &&
                   `<IllustratedMessage ` && |\n| &&
                   `  illustrationType="sapIllus-ErrorScreen" ` && |\n| &&
                   `  enableFormattedText="true" ` && |\n| &&
                   `  illustrationSize="sapIllus-ErrorScreen" ` && |\n| &&
                   `  description="` && lv_descr && `"` && |\n| &&
                   `  title="500 Internal Server Error" ` && |\n| &&
                   ` > <additionalContent ` && |\n| &&
                   ` > ` &&
                   `<Button ` && |\n| &&
                   `  press="` && client->_event_client( action = client->cs_event-location_reload t_arg = VALUE #( ( lv_url ) ) )  && `" ` && |\n| &&
                   `  text="Home" ` && |\n| &&
                   `  type="Emphasized" ` && |\n| &&
                   ` />` &&
                   `<Button ` && |\n| &&
                   `  press="` && client->_event_client( action = client->cs_event-location_reload t_arg = VALUE #( ( lv_url_app ) ) ) && `" ` && |\n| &&
                   `  text="Restart" /></additionalContent></IllustratedMessage></Shell></mvc:View>`.

    client->view_display( lv_xml ).

  ENDMETHOD.


  METHOD view_display_start.

    TRY.

        DATA(lv_url) = to_lower( client->get( )-s_config-origin && client->get( )-s_config-pathname ).

        DATA(lv_search) = client->get( )-s_config-search.
        SPLIT lv_search AT `&` INTO TABLE DATA(lt_param).
        LOOP AT lt_param INTO DATA(ls_param).
          TRY.
              IF ls_param(9) = `app_start`.
                DELETE lt_param.
              ENDIF.
            CATCH cx_root.
          ENDTRY.
        ENDLOOP.
        IF lv_search IS INITIAL.
          lv_url = lv_url && `?`.
        ELSE.
          lv_url = lv_url && lv_search && `&`.
        ENDIF.

        DATA(lv_link) = lv_url && `app_start=` && to_lower( ms_home-classname ).

      CATCH cx_root.
    ENDTRY.

    DATA(lv_xml_main) = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:l="sap.ui.layout" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:f="sap.ui.layout.form" xmlns:mvc="sap.ui.core.mvc` &&
`" xmlns:editor="sap.ui.codeeditor" xmlns:ui="sap.ui.table" xmlns="sap.m" xmlns:uxap="sap.uxap" xmlns:mchart="sap.suite.ui.microchart" xmlns:z2ui5="z2ui5" xmlns:webc="sap.ui.webc.main" xmlns:text="sap.ui.richtexteditor" > <Shell> <Page ` && |\n| &&
                        `  showNavButton="false" ` && |\n| &&
                        `  class="sapUiContentPadding sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" ` && |\n| &&
                        ` > <headerContent ` && |\n| &&
                        ` > <Title ` && |\n| &&
                        ` /> <Title ` && |\n| &&
                        `  text="abap2UI5 - Developing UI5 Apps in pure ABAP" ` && |\n| &&
                        ` /> <ToolbarSpacer ` && |\n| &&
                        ` /> <Link ` && |\n| &&
                        `  text="SCN" ` && |\n| &&
                        `  target="_blank" ` && |\n| &&
                        `  href="https://blogs.sap.com/tag/abap2ui5/" ` && |\n| &&
                        ` /> <Link ` && |\n| &&
                        `  text="Twitter" ` && |\n| &&
                        `  target="_blank" ` && |\n| &&
                        `  href="https://twitter.com/abap2UI5" ` && |\n| &&
                        ` /> <Link ` && |\n| &&
                        `  text="GitHub" ` && |\n| &&
                        `  target="_blank" ` && |\n| &&
                        `  href="https://github.com/abap2ui5/abap2ui5" ` && |\n| &&
                        ` /></headerContent>`.

    lv_xml_main = lv_xml_main && ` <l:Grid ` && |\n| &&
    `  defaultSpan="XL7 L7 M12 S12" ` && |\n| &&
    ` > <l:content ` && |\n| &&
    ` > <f:SimpleForm ` && |\n| &&
    `  title="Quick Start" ` && |\n| &&
    `  layout="ResponsiveGridLayout" ` && |\n| &&
    `  editable="true" ` && |\n| &&
    ` > <f:content ` && |\n| &&
    ` > <Label ` && |\n| &&
    `  text="Step 1" ` && |\n| &&
    ` /> <Text ` && |\n| &&
    `  text="Create a global class in your abap system" ` && |\n| &&
    ` /> <Label ` && |\n| &&
    `  text="Step 2" ` && |\n| &&
    ` /> <Text ` && |\n| &&
    `  text="Add the interface: Z2UI5_IF_APP" ` && |\n| &&
    ` /> <Label ` && |\n| &&
    `  text="Step 3" ` && |\n| &&
    ` /> <Text ` && |\n| &&
    `  text="Define view, implement behaviour" ` && |\n| &&
    ` /> <Link ` && |\n| &&
    `  text="(Example)" ` && |\n| &&
    `  target="_blank" ` && |\n| &&
    `  href="https://github.com/oblomov-dev/ABAP2UI5/blob/main/src/z2ui5_cl_app_hello_world.clas.abap" ` && |\n| &&
    ` /> <Label ` && |\n| &&
    `  text="Step 4" ` && |\n| &&
    ` /> `.

    IF ms_home-class_editable = abap_true.
      lv_xml_main = lv_xml_main && `<Input ` && |\n| &&
     `  placeholder="` && `fill in the class name and press 'check' ` && `" ` && |\n| &&
     `  editable="` && z2ui5_cl_utility=>get_json_boolean( ms_home-class_editable ) && `" ` && |\n| &&
     `  value="` && client->_bind_edit( ms_home-classname ) && `" ` && |\n| &&
     ` /> `.
    ELSE.
      lv_xml_main = lv_xml_main && `<Text ` && |\n| &&
      `  text=" ` && ms_home-classname && `" /> `.

    ENDIF.

    lv_xml_main = lv_xml_main && `<Button ` && |\n| &&
       `  press="`  && client->_event( ms_home-btn_event_id ) && `" ` && |\n| &&
       `  text="` && ms_home-btn_text && `" ` && |\n| &&
       `  icon="` && ms_home-btn_icon && `" ` && |\n| &&
       ` /> <Label ` && |\n| &&
       `  text="Step 5" ` && |\n| &&
       ` /> <Link ` && |\n| &&
       `  text="Link to the Application" ` && |\n| &&
       `  target="_blank" ` && |\n| &&
       `  href="` && escape( val = lv_link format = cl_abap_format=>e_xml_attr ) && `" ` && |\n| &&
       `  enabled="` && z2ui5_cl_utility=>get_json_boolean( xsdbool( ms_home-class_editable = abap_false ) ) && `" ` && |\n| &&
       ` /></f:content></f:SimpleForm>`.

    lv_xml_main = lv_xml_main && `<f:SimpleForm  editable="true" ` && |\n| &&
   `  title="Samples" ` && |\n| &&
   `  layout="ResponsiveGridLayout" ` && |\n| &&
   ` >`.

    IF lv_check_demo = abap_false.
      lv_xml_main = lv_xml_main && `<MessageStrip text="Oops! You need to install abap2UI5 demos before continuing..." type="Warning" > <link> ` &&
         `   <Link text="(HERE)"  target="_blank" href="https://github.com/oblomov-dev/abap2UI5-demos" /> ` &&
      `  </link> </MessageStrip>`.
    ENDIF.

    lv_xml_main = lv_xml_main && ` <f:content ` && |\n| &&
    ` > <Label/><Button ` && |\n| &&
    `  press="` && client->_event( val = `DEMOS` check_view_destroy = abap_true ) && `" ` && |\n| &&
    `  text="Continue..." enabled="` && COND #( WHEN lv_check_demo = abap_true THEN `true` ELSE `false` ) && |" \n| &&
    ` /><Button visible="false"/><Link text="More on GitHub..."  target="_blank" href="https://github.com/abap2UI5/abap2UI5/blob/main/docs/links.md" /></f:content></f:SimpleForm>`.

    lv_xml_main = lv_xml_main && `</l:content></l:Grid></Page></Shell></mvc:View>`.

    client->view_display( lv_xml_main ).

  ENDMETHOD.

ENDCLASS.



