CLASS z2ui5_cl_app_icf_config DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

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
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_app_icf_config.

    METHODS z2ui5_on_init.
    METHODS z2ui5_on_event.
    METHODS view_display_popup.
    METHODS view_display_config_popup.
    METHODS save_all_configs.

  PROTECTED SECTION.
    DATA mt_classes             TYPE z2ui5_cl_util=>ty_t_classes.
    DATA mv_config_popup_active TYPE abap_bool.

ENDCLASS.


CLASS z2ui5_cl_app_icf_config IMPLEMENTATION.
  METHOD factory.
    result = NEW #( ).
  ENDMETHOD.

  METHOD save_all_configs.
    TRY.
        " Save theme from bound form field
        IF ms_config-app_title IS NOT INITIAL.
          client->follow_up_action( |sap.ui.getCore().applyTheme("{ ms_config-theme }");| ).
          z2ui5_cl_config_service=>set_config( iv_key   = 'THEME'
                                               iv_value = ms_config-theme ).
        ENDIF.

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

 METHOD z2ui5_if_app~main.
    me->client = client.

    IF client->check_on_init( ) IS NOT INITIAL.
      z2ui5_on_init( ).
      view_display_config_popup( ).
*      view_display_start( ).
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
        client->nav_app_leave( ).

      WHEN `OPEN_INFO`.
        view_display_popup( ).
        RETURN.

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

    ENDCASE.
  ENDMETHOD.

  METHOD z2ui5_on_init.

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
