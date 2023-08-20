CLASS z2ui5_cl_fw_app DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

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

    CLASS-METHODS factory_start
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    CLASS-METHODS factory_error
      IMPORTING
        error         TYPE REF TO cx_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_fw_app.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA mv_check_initialized TYPE abap_bool.
    DATA mv_check_demo TYPE abap_bool.
    DATA mx_error TYPE REF TO cx_root.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_error.
    METHODS view_display_start.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_FW_APP IMPLEMENTATION.


  METHOD factory_error.

    result = NEW #( ).
    result->mx_error = error.

  ENDMETHOD.


  METHOD factory_start.

    result = NEW #( ).

  ENDMETHOD.


  METHOD view_display_error.

    DATA(lv_url) = shift_left( val = client->get( )-s_config-origin && client->get( )-s_config-pathname
                               sub = ` ` ).
    DATA(lv_url_app) = lv_url && client->get( )-s_config-search.

    DATA(lv_text) = mx_error->get_text( ).

    DATA(view) = z2ui5_cl_xml_view=>factory( client )->shell( )->illustrated_message(
        enableformattedtext = abap_true
        illustrationtype    = 'sapIllus-ErrorScreen'
        title               = '500 Internal Server Error'
        description         = lv_text
      )->additional_content(
        )->button(
            text  = 'Home'
            type  = 'Emphasized'
            press = client->_event_client( val = client->cs_event-location_reload t_arg  = VALUE #( ( lv_url ) ) )
        )->button(
            text  = 'Restart'
            press = client->_event_client( val = client->cs_event-location_reload t_arg  = VALUE #( ( lv_url_app ) ) ) ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD view_display_start.

    DATA(lv_url) = z2ui5_cl_xml_view=>factory( client )->hlp_get_app_url( ms_home-classname ).

    DATA(page) = z2ui5_cl_xml_view=>factory( client )->shell(
      )->page( shownavbutton = abap_false ).

    page->header_content(
            )->title( `abap2UI5 - Developing UI5 Apps in pure ABAP`
            )->toolbar_spacer(
            )->link( text   = `SCN`
                     target = `_blank`
                     href   = `https://blogs.sap.com/tag/abap2ui5/`
            )->link( text   = `Twitter`
                     target = `_blank`
                     href   = `https://twitter.com/abap2UI5`
            )->link( text   = `GitHub`
                     target = `_blank`
                     href   = `https://github.com/abap2ui5/abap2ui5` ).

    DATA(grid) = page->grid( `XL7 L7 M12 S12`
         )->content( `layout` ).
    DATA(content) = grid->simple_form( title    = `Quickstart`
                                       layout   = `ResponsiveGridLayout`
                                       editable = `true`
           )->content( `form` ).

    content->label( `Step 1`
        )->text( `Create a global class in your abap system`
        )->label( `Step 2`
        )->text( `Add the interface: Z2UI5_IF_APP`
        )->label( `Step 3`
        )->text( `Define view, implement behaviour`
        )->link( text   = `(Example)`
                 target = `_blank`
                 href   = `https://github.com/abap2ui5/ABAP2UI5/blob/main/src/z2ui5_cl_app_hello_world.clas.abap`
        )->label( `Step 4` ).

    IF ms_home-class_editable = abap_true.

      content->input( placeholder = `fill in the class name and press 'check'`
                      editable    = z2ui5_cl_fw_utility=>get_json_boolean( ms_home-class_editable )
          value                   = client->_bind_edit( ms_home-classname ) ).

    ELSE.
      content->text( ms_home-classname ).
    ENDIF.

    content->button( press = client->_event( ms_home-btn_event_id )
                     text  = ms_home-btn_text
                     icon  = ms_home-btn_icon
        )->label( `Step 5`
        )->link( text    = `Link to the Application`
                 target  = `_blank`
                 href    = lv_url
                 enabled = z2ui5_cl_fw_utility=>get_json_boolean( xsdbool( ms_home-class_editable = abap_false ) ) ).

    DATA(form) = grid->simple_form( title    = `Samples`
                                    editable = abap_true
                                    layout   = 'ResponsiveGridLayout' ).

    IF mv_check_demo = abap_false.
      form->message_strip( text = 'Oops! You need to install abap2UI5 demos before continuing...'
                           type = 'Warning'
          )->get( )->_generic( 'link' )->link( text   = `(HERE)`
                                               target = '_blank'
                                               href   = `https://github.com/oblomov-dev/abap2UI5-demos` ).
    ENDIF.

    DATA(cont) = form->content( `form` ).
    cont->label( ).
    cont->button(
       text    = 'Continue...'
       press   = client->_event( val = `DEMOS` check_view_destroy = abap_true )
       enabled = xsdbool( mv_check_demo = abap_true ) )->get( ).
    cont->button( visible = abap_false )->link( text   = 'More on GitHub...'
                                               target = '_blank'
                                               href   = 'https://github.com/abap2UI5/abap2UI5-documentation/blob/main/docs/links.md' ).

    client->view_display( form->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF mv_check_initialized = abap_false.
      mv_check_initialized = abap_true.
      z2ui5_on_init( ).
    ENDIF.

    z2ui5_on_event( ).

    IF mx_error IS BOUND.
      view_display_error( ).
    ELSE.
      view_display_start( ).
    ENDIF.

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
            ms_home-classname = z2ui5_cl_fw_utility=>get_trim_upper( ms_home-classname ).
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
            client->message_box_display( text = ms_home-class_value_state_text
                                         type = `error` ).
        ENDTRY.

      WHEN `DEMOS`.

        DATA li_app TYPE REF TO z2ui5_if_app.
        TRY.
            CREATE OBJECT li_app TYPE (`Z2UI5_CL_APP_DEMO_00`).
            mv_check_demo = abap_true.
            client->nav_app_call( li_app ).
          CATCH cx_root.
            mv_check_demo = abap_false.
        ENDTRY.

    ENDCASE.

  ENDMETHOD.


  METHOD z2ui5_on_init.

    IF mx_error IS NOT BOUND.
      ms_home-btn_text       = `check`.
      ms_home-btn_event_id   = `BUTTON_CHECK`.
      ms_home-class_editable = abap_true.
      ms_home-btn_icon       = `sap-icon://validate`.
      ms_home-classname      = `z2ui5_cl_app_hello_world`.
    ENDIF.

    mv_check_demo = abap_true.

  ENDMETHOD.
ENDCLASS.
