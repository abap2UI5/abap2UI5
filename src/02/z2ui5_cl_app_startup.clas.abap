CLASS z2ui5_cl_app_startup DEFINITION
  PUBLIC FINAL
  CREATE PROTECTED.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    DATA:
      BEGIN OF ms_home,
        url                    TYPE string,
        btn_text               TYPE string,
        btn_event_id           TYPE string,
        btn_icon               TYPE string,
        classname              TYPE string,
        class_value_state      TYPE string,
        class_value_state_text TYPE string,
        class_editable         TYPE abap_bool VALUE abap_true,
      END OF ms_home.

    DATA mv_ui5_version TYPE string.
    DATA client         TYPE REF TO z2ui5_if_client.
    DATA:
      BEGIN OF ms_config,
        theme      TYPE string,
        debug_mode TYPE abap_bool,
        ui5_src    TYPE string,
        app_title  TYPE string,
        styles_css TYPE string,
        csp_policy TYPE string,
      END OF ms_config.

    DATA mt_all_configs TYPE z2ui5_cl_config_service=>ty_t_config.

    CLASS-METHODS factory
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_app_startup.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_start.
    METHODS on_event_check.
    METHODS view_display_popup.
    METHODS view_display_config_popup.
    METHODS save_all_configs.

  PROTECTED SECTION.
    DATA mt_classes             TYPE z2ui5_cl_util=>ty_t_classes.
    DATA mv_config_popup_active TYPE abap_bool.

ENDCLASS.


CLASS z2ui5_cl_app_startup IMPLEMENTATION.
  METHOD factory.
    result = NEW #( ).
  ENDMETHOD.

  METHOD on_event_check.
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA li_app_test TYPE REF TO z2ui5_if_app.
    DATA lx          TYPE REF TO cx_root.

    TRY.

        ms_home-classname = z2ui5_cl_util=>c_trim_upper( ms_home-classname ).
        CREATE OBJECT li_app_test TYPE (ms_home-classname).

        client->message_toast_display( `App is ready to start!` ).
        ms_home-btn_text          = `edit`.
        ms_home-btn_event_id      = `BUTTON_CHANGE`.
        ms_home-btn_icon          = `sap-icon://edit`.
        ms_home-class_value_state = `Success`.
        ms_home-class_editable    = abap_false.

        ms_home-url               = z2ui5_cl_core_srv_util=>app_get_url( client    = client
                                                                         classname = ms_home-classname ).

      CATCH cx_root INTO lx.
        ms_home-class_value_state_text = lx->get_text( ).
        ms_home-class_value_state      = `Warning`.
        client->message_box_display( text = ms_home-class_value_state_text
                                     type = `error` ).
    ENDTRY.
  ENDMETHOD.

  METHOD save_all_configs.
    TRY.
        client->follow_up_action( |sap.ui.getCore().applyTheme("{ ms_config-theme }");| ).

        " Save debug mode from bound form field
        DATA lv_debug_string TYPE string.
        IF ms_config-debug_mode = abap_true.
          lv_debug_string = 'X'.
        ELSE.
          lv_debug_string = ''.
        ENDIF.
        z2ui5_cl_config_service=>set_config( iv_key   = 'DEBUG_MODE'
                                             iv_value = lv_debug_string ).

        " Save application title from bound form field
        IF ms_config-app_title IS NOT INITIAL.
          z2ui5_cl_config_service=>set_config( iv_key   = 'APP_TITLE'
                                               iv_value = ms_config-app_title ).
        ENDIF.

        " Save custom CSS from bound form field
        z2ui5_cl_config_service=>set_config( iv_key   = 'STYLES_CSS'
                                             iv_value = ms_config-styles_css ).

        " Save other configurations if user has authority
        DATA lv_is_master TYPE boolean.
        lv_is_master = z2ui5_cl_config_service=>is_master_user( ).

        " Save UI5 source (admin only)
        IF lv_is_master = abap_true.
          IF ms_config-ui5_src IS NOT INITIAL.
            z2ui5_cl_config_service=>set_config( iv_key   = 'UI5_SRC'
                                                 iv_value = ms_config-ui5_src ).
          ENDIF.

          " Save CSP policy (admin only)
          z2ui5_cl_config_service=>set_config( iv_key   = 'CSP_POLICY'
                                               iv_value = ms_config-csp_policy ).
        ENDIF.

        " Commit all changes to database
        COMMIT WORK AND WAIT.

        " Clear cache to force reload
        z2ui5_cl_config_service=>load_config_cache( ).

        client->message_toast_display( 'Configuration saved successfully' ).

      CATCH cx_root INTO DATA(lx_error).
        ROLLBACK WORK.
        client->message_box_display( text = |Error saving configuration: { lx_error->get_text( ) }|
                                     type = 'error' ).
    ENDTRY.
  ENDMETHOD.

  METHOD view_display_config_popup.
    DATA lv_is_master TYPE boolean.

    mv_config_popup_active = abap_true.

    " Check if user is master user
    lv_is_master = z2ui5_cl_config_service=>is_master_user( ).

    " Initialize default configs if needed
    z2ui5_cl_config_service=>initialize_default_configs( ).

    " Only refresh configurations if they haven't been loaded yet or if explicitly requested
    " This prevents overwriting values selected from value help popups
    IF ms_config-theme IS INITIAL.
      ms_config-theme = z2ui5_cl_config_service=>get_current_theme( ).
    ENDIF.

    IF ms_config-app_title IS INITIAL.
      ms_config-app_title = z2ui5_cl_config_service=>get_config( 'APP_TITLE' ).
    ENDIF.

    IF ms_config-ui5_src IS INITIAL.
      ms_config-ui5_src = z2ui5_cl_config_service=>get_config( 'UI5_SRC' ).
    ENDIF.

    IF ms_config-styles_css IS INITIAL.
      ms_config-styles_css = z2ui5_cl_config_service=>get_config( 'STYLES_CSS' ).
    ENDIF.

    IF ms_config-csp_policy IS INITIAL.
      ms_config-csp_policy = z2ui5_cl_config_service=>get_config( 'CSP_POLICY' ).
    ENDIF.

    " Debug mode handling
    DATA lv_debug_value TYPE string.
    lv_debug_value = z2ui5_cl_config_service=>get_config( 'DEBUG_MODE' ).
    IF lv_debug_value = 'X' OR lv_debug_value = 'true' OR lv_debug_value = '1'.
      ms_config-debug_mode = abap_true.
    ELSE.
      ms_config-debug_mode = abap_false.
    ENDIF.

    DATA page TYPE REF TO z2ui5_cl_xml_view.
    page = z2ui5_cl_xml_view=>factory_popup(
             )->dialog( title         = 'Configuration Settings'
                        afterclose    = client->_event( 'CLOSE_CONFIG' )
                        contentwidth  = '60%'
                        contentheight = '70%' ).

    DATA form TYPE REF TO z2ui5_cl_xml_view.
    form = page->simple_form( editable = abap_true
                              layout   = 'ResponsiveGridLayout' ).

    " Theme configuration section - Display field + Button approach
    form->toolbar( )->title( 'Theme Settings' ).
    form->label( 'Theme' ).

    " Use a horizontal layout for theme selection
    DATA theme_hbox TYPE REF TO z2ui5_cl_xml_view.
    theme_hbox = form->hbox( ).

    " Display-only text field showing current theme
    theme_hbox->text( text  = client->_bind( ms_config-theme )
                      class = 'sapUiMediumMarginEnd' ).

    " Button to open theme selection
    theme_hbox->button( text  = 'Select Theme'
                        icon  = 'sap-icon://palette'
                        press = client->_event( 'THEME_VALUE_HELP' )
                        type  = 'Transparent' ).

    " Debug mode section
    form->toolbar( )->title( 'Debug Settings' ).
    form->label( 'Debug Mode' ).
    form->checkbox( selected = client->_bind_edit( ms_config-debug_mode )
                    enabled  = abap_true ).

    " UI5 Source configuration (admin only)
    form->toolbar( )->title( 'UI5 Bootstrap Settings' ).
    form->label( 'UI5 Source URL' ).
    IF lv_is_master = abap_true.
      form->input( value   = client->_bind_edit( ms_config-ui5_src )
                   enabled = abap_true ).
    ELSE.
      form->text( ms_config-ui5_src ).
      form->text( '(Admin only)' ).
    ENDIF.

    " Application Title configuration
    form->toolbar( )->title( 'Application Settings' ).
    form->label( 'Application Title' ).
    form->input( value   = client->_bind_edit( ms_config-app_title )
                 enabled = abap_true ).

    " Custom CSS configuration
    form->toolbar( )->title( 'Style Settings' ).
    form->label( 'Custom CSS' ).
    form->text_area( value   = client->_bind_edit( ms_config-styles_css )
                     rows    = '5'
                     enabled = abap_true ).

    " Content Security Policy (admin only)
    form->toolbar( )->title( 'Security Settings' ).
    form->label( 'Content Security Policy' ).
    IF lv_is_master = abap_true.
      form->text_area( value   = client->_bind_edit( ms_config-csp_policy )
                       rows    = '3'
                       enabled = abap_true ).
    ELSE.
      form->text( ms_config-csp_policy ).
      form->text( '(Admin only)' ).
    ENDIF.

    " Buttons
    page->buttons( )->button( text  = 'Save'
                              press = client->_event( 'CONFIG_SAVE' )
                              type  = 'Emphasized' ).
    page->buttons( )->button( text  = 'Cancel'
                              press = client->_event( 'CLOSE_CONFIG' ) ).

    client->popup_display( page->stringify( ) ).
  ENDMETHOD.

  METHOD view_display_popup.
    DATA page2        TYPE REF TO z2ui5_cl_xml_view.
    DATA content      TYPE REF TO z2ui5_cl_xml_view.
    DATA simple_form2 TYPE REF TO z2ui5_cl_xml_view.
    DATA temp4        TYPE string.
    DATA temp1        TYPE REF TO z2ui5_cl_core_srv_draft.
    DATA lv_count     LIKE temp4.

    page2 = z2ui5_cl_xml_view=>factory_popup(
         )->dialog( title      = `abap2UI5 - System Information`
                    afterclose = client->_event( `CLOSE` ) ).

    content = page2->content( ).
    content->_z2ui5( )->info_frontend( ui5_version = client->_bind( mv_ui5_version ) ).

    simple_form2 = content->simple_form( editable                = abap_true
                                         layout                  = `ResponsiveGridLayout`
                                         labelspanxl             = `4`
                                         labelspanl              = `3`
                                         labelspanm              = `4`
                                         labelspans              = `12`
                                         adjustlabelspan         = abap_false
                                         emptyspanxl             = `0`
                                         emptyspanl              = `4`
                                         emptyspanm              = `0`
                                         emptyspans              = `0`
                                         columnsxl               = `1`
                                         columnsl                = `1`
                                         columnsm                = `1`
                                         singlecontainerfullsize = abap_false
      )->content( `form` ).

    simple_form2->toolbar( )->title( `Frontend` ).

    simple_form2->label( `UI5 Version` ).
    simple_form2->text( client->_bind( mv_ui5_version ) ).
    simple_form2->label( `Launchpad active` ).
    simple_form2->checkbox( enabled  = abap_false
                            selected = client->get( )-check_launchpad_active ).

    simple_form2->toolbar( )->title( `Backend` ).

    simple_form2->label( `ABAP for Cloud` ).
    simple_form2->checkbox( enabled  = abap_false
                            selected = z2ui5_cl_util=>context_check_abap_cloud( ) ).

    temp1 = NEW z2ui5_cl_core_srv_draft( ).
    temp4 = temp1->count_entries( ).

    lv_count = temp4.
    simple_form2->toolbar( )->title( `abap2UI5` ).
    simple_form2->label( `Version ` ).
    simple_form2->text( z2ui5_if_app=>version ).
    simple_form2->label( `Draft Entries ` ).
    simple_form2->text( lv_count ).

    page2->end_button( )->button( text  = 'close'
                                  press = client->_event( 'CLOSE' )
                                  type  = 'Emphasized' ).

    client->popup_display( page2->stringify( ) ).
  ENDMETHOD.

  METHOD view_display_start.
    DATA page            TYPE REF TO z2ui5_cl_xml_view.
    DATA simple_form     TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_url_samples2 TYPE string.
    DATA temp1           TYPE string_table.

    page = z2ui5_cl_xml_view=>factory( )->shell( )->page(
               title         = `abap2UI5 - Developing UI5 Apps Purely in ABAP`
               shownavbutton = abap_false ).

    page->header_content(
      )->toolbar_spacer(
      )->button( text  = `Debugging Tools`
                 icon  = `sap-icon://enablement`
                 press = client->_event( `OPEN_DEBUG` )
      )->button( text  = `System`
                 icon  = `sap-icon://information`
                 press = client->_event( `OPEN_INFO` )
      )->button( text  = 'Config'
                 icon  = 'sap-icon://settings'
                 press = client->_event( 'SET_CONFIG' ) ).

    simple_form = page->simple_form( editable                = abap_true
                                     layout                  = `ResponsiveGridLayout`
                                     labelspanxl             = `4`
                                     labelspanl              = `3`
                                     labelspanm              = `4`
                                     labelspans              = `12`
                                     adjustlabelspan         = abap_false
                                     emptyspanxl             = `0`
                                     emptyspanl              = `4`
                                     emptyspanm              = `0`
                                     emptyspans              = `0`
                                     columnsxl               = `1`
                                     columnsl                = `1`
                                     columnsm                = `1`
                                     singlecontainerfullsize = abap_false
      )->content( `form` ).

    simple_form->toolbar( )->title( `Quickstart` ).
    simple_form->label( `Step 1`
      )->text( `Create a new class in your ABAP system`
      )->label( `Step 2`
      )->text( `Add the interface: Z2UI5_IF_APP`
      )->label( `Step 3`
      )->text( `Define the view, implement behavior`
      )->label(
      )->link( text   = `(Example)`
               target = `_blank`
               href   = `https://github.com/abap2UI5/abap2UI5/blob/main/src/02/z2ui5_cl_app_hello_world.clas.abap`
      )->label( `Step 4` ).

    IF ms_home-class_editable = abap_true.

      simple_form->input( placeholder      = `fill in the class name and press 'check'`
                          enabled          = client->_bind( ms_home-class_editable )
                          value            = client->_bind_edit( ms_home-classname )
                          submit           = client->_event( ms_home-btn_event_id )
                          valuehelprequest = client->_event( 'VALUE_HELP' )
                          showvaluehelp    = abap_true
                          width            = `70%` ).

    ELSE.
      simple_form->text( ms_home-classname ).
    ENDIF.

    simple_form->label( ).
    simple_form->button( press = client->_event( ms_home-btn_event_id )
                         text  = client->_bind( ms_home-btn_text )
                         icon  = client->_bind( ms_home-btn_icon )
                         width = `70%` ).
    simple_form->label( `Step 5`
      )->link( text    = `Link to the Application`
               target  = `_blank`
               href    = client->_bind( ms_home-url )
               enabled = |\{= ${ client->_bind( val = ms_home-class_editable ) } === false \}| ).

    lv_url_samples2 = z2ui5_cl_core_srv_util=>app_get_url( client    = client
                                                           classname = 'z2ui5_cl_demo_app_000' ).

    simple_form->toolbar( )->title( `What's next?` ).

    IF z2ui5_cl_util=>rtti_check_class_exists( `z2ui5_cl_demo_app_000` ) IS NOT INITIAL.
      simple_form->label( `Start Developing` ).

      CLEAR temp1.
      INSERT lv_url_samples2 INTO TABLE temp1.
      simple_form->button( text  = `Explore Code Samples`
                           press = client->_event_client( val   = client->cs_event-open_new_tab
                                                          t_arg = temp1 )
                           width = `70%` ).

    ELSE.
      simple_form->label( `Install the sample repository` ).
      simple_form->link( text   = `And explore more than 200 sample apps...`
                         target = `_blank`
                         href   = `https://github.com/abap2UI5/abap2UI5-samples` ).
    ENDIF.

    simple_form->toolbar( )->title( `Contribution` ).

    simple_form->label( `Open an issue` ).
    simple_form->link( text   = `You have problems, comments or wishes?`
                       target = `_blank`
                       href   = `https://github.com/abap2UI5/abap2UI5/issues` ).

    simple_form->label( `Open a Pull Request` ).
    simple_form->link( text   = `You added a new feature or fixed a bug?`
                       target = `_blank`
                       href   = `https://github.com/abap2UI5/abap2UI5/pulls` ).

    simple_form->toolbar( )->title( `Documentation` ).
    simple_form->label( ).
    simple_form->link( text   = `www.abap2UI5.org`
                       target = `_blank`
                       href   = `http://www.abap2UI5.org` ).

    client->view_display( page->stringify( ) ).
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      z2ui5_on_init( ).
      view_display_start( ).
      RETURN.
    ENDIF.

    IF client->get( )-check_on_navigated = abap_true.
      TRY.
          DATA(lo_f4) = CAST z2ui5_cl_pop_to_select(
            client->get_app( client->get( )-s_draft-id_prev_app ) ).
          DATA(ls_result) = lo_f4->result( ).

          IF ls_result-check_confirmed = abap_true.
            " Check if this is a theme selection popup
            TRY.
                ASSIGN ls_result-row->* TO FIELD-SYMBOL(<selected_row>).
                ASSIGN COMPONENT 'THEME' OF STRUCTURE <selected_row> TO FIELD-SYMBOL(<theme_value>).
                IF sy-subrc = 0.
                  " This is theme selection - update config and apply preview
                  ms_config-theme = <theme_value>.

                  " Apply theme as preview
                  client->follow_up_action( |sap.ui.getCore().applyTheme("{ ms_config-theme }");| ).

                  " Redisplay the config popup
                  mv_config_popup_active = abap_true.
                  view_display_config_popup( ).
                  RETURN.
                ENDIF.
              CATCH cx_root.
            ENDTRY.

            " Check for class selection (original logic)
            TRY.
                " TODO: variable is assigned but never used (ABAP cleaner)
                ASSIGN COMPONENT 'CLASSNAME' OF STRUCTURE <selected_row> TO FIELD-SYMBOL(<class_name>).
                IF sy-subrc = 0.
                  MOVE-CORRESPONDING <selected_row> TO ms_home.
                  mv_config_popup_active = abap_false.
                  view_display_start( ).
                  RETURN.
                ENDIF.
              CATCH cx_root.
            ENDTRY.
          ENDIF.
        CATCH cx_root.
      ENDTRY.
    ENDIF.

    z2ui5_on_event( ).
  ENDMETHOD.

  METHOD z2ui5_on_event.
    DATA li_app TYPE REF TO z2ui5_if_app.

    CASE client->get( )-event.

      WHEN `CLOSE`.
        client->popup_destroy( ).

      WHEN `OPEN_DEBUG`.
        client->message_box_display( `Press CTRL+F12 to open the debugging tools` ).

      WHEN 'SET_CONFIG'.
        view_display_config_popup( ).

      WHEN 'CONFIG_SAVE'.
        save_all_configs( ).
        client->popup_destroy( ).

      WHEN 'CLOSE_CONFIG'.
        " Reset theme to saved value if user cancels without saving
        DATA(lv_saved_theme) = z2ui5_cl_config_service=>get_current_theme( ).

        IF ms_config-theme <> lv_saved_theme.
          " Revert to saved theme
          client->follow_up_action( |sap.ui.getCore().applyTheme("{ lv_saved_theme }");| ).
          ms_config-theme = lv_saved_theme.
        ENDIF.
        mv_config_popup_active = abap_false.
        client->popup_destroy( ).

      WHEN `OPEN_INFO`.
        view_display_popup( ).
        RETURN.

      WHEN `BUTTON_CHECK`.
        IF ms_home-class_editable = abap_false.
          ms_home-btn_text       = `check`.
          ms_home-btn_event_id   = `BUTTON_CHECK`.
          ms_home-btn_icon       = `sap-icon://validate`.
          ms_home-class_editable = abap_true.
        ELSE.
          on_event_check( ).
        ENDIF.
        client->view_model_update( ).

      WHEN 'THEME_VALUE_HELP'.
        " Ensure UI5 version is available
        IF mv_ui5_version IS INITIAL.
          mv_ui5_version = '1.120.32'. " Fallback
        ENDIF.

        " Get available themes for current UI5 version
        DATA(lt_themes_raw) = z2ui5_cl_config_service=>get_theme_list( mv_ui5_version ).

        " Convert to table structure for popup selection
        TYPES: BEGIN OF ty_theme_item,
                 theme TYPE string,
               END OF ty_theme_item.
        DATA lt_themes TYPE STANDARD TABLE OF ty_theme_item.

        lt_themes = VALUE #( FOR theme IN lt_themes_raw
                             ( theme = theme ) ).

        " Open selection popup using existing framework popup
        client->nav_app_call( z2ui5_cl_pop_to_select=>factory( i_tab        = lt_themes
                                                               i_title      = 'Select Theme'
                                                               i_sort_field = 'THEME' ) ).

      WHEN 'VALUE_HELP'.
        TRY.
            mt_classes = z2ui5_cl_util=>rtti_get_classes_impl_intf( z2ui5_cl_util=>rtti_get_intfname_by_ref( li_app ) ).
          CATCH cx_root.
            client->message_box_display( `Unfortunately the value help is not available on your ABAP release!` ).
            RETURN.
        ENDTRY.
        client->nav_app_call( z2ui5_cl_pop_to_select=>factory( mt_classes ) ).
    ENDCASE.
  ENDMETHOD.

  METHOD z2ui5_on_init.
    DATA temp5 TYPE REF TO z2ui5_cl_app_hello_world.

    ms_home-btn_text       = `check`.
    ms_home-btn_event_id   = `BUTTON_CHECK`.
    ms_home-class_editable = abap_true.
    ms_home-btn_icon       = `sap-icon://validate`.

    temp5 = NEW #( ).
    ms_home-classname = z2ui5_cl_util=>rtti_get_classname_by_ref( temp5 ).

    " Initialize UI5 version - fallback approach for ABAP 7.3
    mv_ui5_version = '1.120.32'. " Default fallback version

    " Initialize default configs early
    z2ui5_cl_config_service=>initialize_default_configs( ).

    " Load current configurations into ms_config structure
    ms_config-theme = z2ui5_cl_config_service=>get_current_theme( ).
    DATA lv_debug_value TYPE string.
    lv_debug_value = z2ui5_cl_config_service=>get_config( 'DEBUG_MODE' ).
    IF lv_debug_value = 'X' OR lv_debug_value = 'true' OR lv_debug_value = '1'.
      ms_config-debug_mode = abap_true.
    ELSE.
      ms_config-debug_mode = abap_false.
    ENDIF.

    " Load other configuration values
    ms_config-ui5_src    = z2ui5_cl_config_service=>get_config( 'UI5_SRC' ).
    ms_config-app_title  = z2ui5_cl_config_service=>get_config( 'APP_TITLE' ).
    ms_config-styles_css = z2ui5_cl_config_service=>get_config( 'STYLES_CSS' ).
    ms_config-csp_policy = z2ui5_cl_config_service=>get_config( 'CSP_POLICY' ).
  ENDMETHOD.
ENDCLASS.