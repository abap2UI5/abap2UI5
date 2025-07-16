CLASS z2ui5_cl_config_service DEFINITION
PUBLIC FINAL
CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_config.
             INCLUDE TYPE z2ui5_config.
    TYPES: END OF ty_config.
    TYPES ty_t_config TYPE STANDARD TABLE OF ty_config WITH DEFAULT KEY.
    TYPES ty_t_themes TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    CLASS-DATA gt_config_cache TYPE ty_t_config.

    CLASS-METHODS get_config
      IMPORTING iv_key          TYPE clike
                iv_user_id      TYPE clike DEFAULT sy-uname
      RETURNING VALUE(rv_value) TYPE string.

    CLASS-METHODS set_config
      IMPORTING iv_key         TYPE clike
                iv_value       TYPE clike
                iv_user_id     TYPE clike DEFAULT sy-uname
                iv_description TYPE clike OPTIONAL
                iv_type        TYPE clike  DEFAULT 'STRING'
      RAISING   z2ui5_cx_config_error.

    CLASS-METHODS get_all_configs
      IMPORTING iv_user_id       TYPE syuname DEFAULT sy-uname
      RETURNING VALUE(rt_config) TYPE ty_t_config.

    CLASS-METHODS get_theme_list
      IMPORTING iv_ui5_version   TYPE clike " DEFAULT z2ui5_cl_app_startup=>mv_ui5_version
      RETURNING VALUE(rt_themes) TYPE ty_t_themes.

    CLASS-METHODS get_current_theme
      IMPORTING iv_user_id      TYPE clike DEFAULT sy-uname
      RETURNING VALUE(rv_theme) TYPE string.

    CLASS-METHODS is_master_user
      RETURNING VALUE(rv_is_master) TYPE boolean.

    CLASS-METHODS check_config_authority
      IMPORTING iv_config_key        TYPE clike
                iv_activity          TYPE clike DEFAULT '02'
      RETURNING VALUE(rv_authorized) TYPE abap_bool.

    CLASS-METHODS initialize_default_configs
      IMPORTING iv_force_refresh TYPE clike DEFAULT abap_false.

    CLASS-METHODS load_config_cache.

  PRIVATE SECTION.
    CLASS-METHODS save_config_to_db
      IMPORTING is_config TYPE ty_config
      RAISING   z2ui5_cx_config_error.
ENDCLASS.


CLASS z2ui5_cl_config_service IMPLEMENTATION.
  METHOD load_config_cache.
    CLEAR gt_config_cache.
    SELECT * FROM z2ui5_config
      WHERE is_active = 'X'
       INTO CORRESPONDING FIELDS OF TABLE @gt_config_cache.
  ENDMETHOD.

  METHOD get_config.
    DATA ls_config TYPE ty_config.

    IF gt_config_cache IS INITIAL.
      load_config_cache( ).
    ENDIF.

    " Try user-specific configuration first
    READ TABLE gt_config_cache INTO ls_config WITH KEY config_key = iv_key
                                                       user_id    = iv_user_id.
    IF sy-subrc = 0.
      rv_value = ls_config-config_value.
      RETURN.
    ENDIF.

    " Fallback to global configuration
    READ TABLE gt_config_cache INTO ls_config WITH KEY config_key = iv_key
                                                       user_id    = ''.
    IF sy-subrc = 0.
      rv_value = ls_config-config_value.
      RETURN.
    ENDIF.

    " Fallback to ABAP2UI5 defaults
    CASE iv_key.
      WHEN 'THEME'.
        rv_value = 'sap_horizon'.
      WHEN 'DEBUG_MODE'.
        rv_value = ''.
      WHEN OTHERS.
        rv_value = ''.
    ENDCASE.
  ENDMETHOD.

  METHOD set_config.
    DATA ls_config TYPE ty_config.

    IF gt_config_cache IS INITIAL.
      load_config_cache( ).
    ENDIF.

    " Check if configuration is locked and user is not a master-user
    READ TABLE gt_config_cache INTO DATA(ls_existing) WITH KEY config_key = iv_key
                                                               user_id    = ''.
    IF sy-subrc = 0 AND ls_existing-is_locked = 'X' AND is_master_user( ) = ''.
      z2ui5_cx_config_error=>raise_config_locked( ).
    ENDIF.

    ls_config-config_key   = iv_key.
    ls_config-user_id      = iv_user_id.
    ls_config-config_value = iv_value.
    ls_config-description  = iv_description.
    ls_config-config_type  = iv_type.
    ls_config-is_active    = 'X'.
    ls_config-is_locked    = ''.
    ls_config-changed_by   = sy-uname.
    GET TIME STAMP FIELD ls_config-changed_at.

    ASSIGN gt_config_cache[ config_key = iv_key
                            user_id    = iv_user_id ] TO FIELD-SYMBOL(<ls_config>).
    IF sy-subrc = 0.
      <ls_config>-config_value = iv_value.
      <ls_config>-description  = iv_description.
      <ls_config>-config_type  = iv_type.
      <ls_config>-changed_by   = sy-uname.
      GET TIME STAMP FIELD <ls_config>-changed_at.
    ELSE.
      ls_config-created_by = sy-uname.
      GET TIME STAMP FIELD ls_config-created_at.
      INSERT ls_config INTO TABLE gt_config_cache.
    ENDIF.

    save_config_to_db( ls_config ).
  ENDMETHOD.

  METHOD save_config_to_db.
    MODIFY z2ui5_config FROM @is_config.
    IF sy-subrc <> 0.
      z2ui5_cx_config_error=>raise_save_failed( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_all_configs.
    IF gt_config_cache IS INITIAL.
      load_config_cache( ).
    ENDIF.
    rt_config = gt_config_cache.
    DELETE rt_config WHERE user_id <> iv_user_id AND user_id <> ''.
  ENDMETHOD.

  METHOD get_theme_list.
    DATA lv_ui5_version TYPE string.
    DATA lv_result      TYPE string.
    DATA lt_parts       TYPE TABLE OF string.

    " Normalize UI5 version (e.g., '1.71.22' → '1.71', fallback to '1' for broad match)
    lv_ui5_version = iv_ui5_version.
    IF lv_ui5_version IS INITIAL.
      lv_ui5_version = '1'. " Broad match for all versions
    ELSE.
      lv_ui5_version = condense( val  = lv_ui5_version
                                 from = ` `
                                 to   = `` ). " Remove spaces
*          REPLACE ALL OCCURRENCES OF REGEX '\.\d+\b' IN lv_ui5_version WITH ''. " Remove patch version

      " Split the version string by dots
      SPLIT lv_ui5_version AT '.' INTO TABLE lt_parts.

      " If there are at least 3 parts (e.g., 1.120.32), take the first two
      IF lines( lt_parts ) >= 3.
        READ TABLE lt_parts INTO DATA(lv_part1) INDEX 1.
        READ TABLE lt_parts INTO DATA(lv_part2) INDEX 2.
        CONCATENATE lv_part1 lv_part2 INTO lv_result SEPARATED BY '.'.
      ELSE.
        lv_result = lv_ui5_version. " No patch version, keep as is
      ENDIF.

      lv_ui5_version = lv_result.
      " Input: '1.120.32' Result: lv_ui5_version = '1.120'
    ENDIF.

    " Try exact version match
    SELECT theme FROM z2ui5_themes
      WHERE ui5_version = @lv_ui5_version
        AND is_active   = 'X'
        INTO TABLE @rt_themes.

    " Fallback to broader version match (e.g., '1.71%' or '1%')
    IF rt_themes IS INITIAL.
      SELECT theme FROM z2ui5_themes
        WHERE ui5_version LIKE @lv_ui5_version
          AND is_active      = 'X'
           INTO TABLE @rt_themes.
    ENDIF.

    " Fallback to default themes if none found
    IF rt_themes IS INITIAL.
      rt_themes = VALUE #( ( `sap_horizon` ) ( `sap_fiori_3` ) ( `sap_horizon_dark` ) ).
    ENDIF.
  ENDMETHOD.

  METHOD get_current_theme.
    rv_theme = get_config( iv_key     = 'THEME'
                           iv_user_id = iv_user_id ).
  ENDMETHOD.

  METHOD is_master_user.
    " Check for master configuration authority
    AUTHORITY-CHECK OBJECT 'Z2UI5_CONF'
                    ID 'ACTVT' FIELD '02'  " Change authorization
                    ID 'CONFIG_TYPE' FIELD '*'.
    " sy-subrc = 0. " Set to 0 to Simulate authority check for master user
    IF sy-subrc = 0.
      rv_is_master = COND #( WHEN sy-subrc = 0 THEN 'X' ELSE '' ).
    ENDIF.
  ENDMETHOD.

  METHOD check_config_authority.
    AUTHORITY-CHECK OBJECT 'Z2UI5_CONF'
                    ID 'ACTVT' FIELD iv_activity
                    ID 'CONFIG_TYPE' FIELD iv_config_key.
    " sy-subrc = 0. " Set to 0 to Simulate authority check
    IF sy-subrc = 0.
      rv_authorized = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).
    ENDIF.
  ENDMETHOD.

  METHOD initialize_default_configs.
    DATA lv_timestamp       TYPE timestampl.
    DATA lt_default_configs TYPE ty_t_config.
    DATA ls_config          TYPE ty_config.
    DATA lv_count           TYPE i.

    " Check if already initialized (unless force refresh)
    IF iv_force_refresh = abap_false.
      SELECT COUNT(*) FROM z2ui5_config INTO @lv_count.
      IF lv_count > 0.
        RETURN. " Already initialized
      ENDIF.
    ENDIF.

    GET TIME STAMP FIELD lv_timestamp.

    " Initialize default configurations based on abap2UI5 documentation
    CLEAR lt_default_configs.

    " Core theme configuration - unlocked for user customization
    CLEAR ls_config.
    ls_config-config_key   = 'THEME'.
    ls_config-config_value = 'sap_horizon'.
    ls_config-config_type  = 'STRING'.
    ls_config-description  = 'Default UI5 Theme'.
    ls_config-is_active    = abap_true.
    ls_config-user_id      = ''.
    ls_config-is_locked    = abap_false.
    ls_config-created_by   = sy-uname.
    ls_config-changed_by   = sy-uname.
    ls_config-created_at   = lv_timestamp.
    ls_config-changed_at   = lv_timestamp.
    APPEND ls_config TO lt_default_configs.

    " Debug mode - unlocked for user customization
    CLEAR ls_config.
    ls_config-config_key   = 'DEBUG_MODE'.
    ls_config-config_value = ''.
    ls_config-config_type  = 'BOOLEAN'.
    ls_config-description  = 'Debug Mode Setting'.
    ls_config-is_active    = abap_true.
    ls_config-user_id      = ''.
    ls_config-is_locked    = abap_false.
    ls_config-created_by   = sy-uname.
    ls_config-changed_by   = sy-uname.
    ls_config-created_at   = lv_timestamp.
    ls_config-changed_at   = lv_timestamp.
    APPEND ls_config TO lt_default_configs.

    " UI5 Bootstrap source - locked for security (master user only)
    CLEAR ls_config.
    ls_config-config_key   = 'UI5_SRC'.
    ls_config-config_value = 'https://sdk.openui5.org/resources/sap-ui-cachebuster/sap-ui-core.js'.
    ls_config-config_type  = 'STRING'.
    ls_config-description  = 'UI5 Bootstrap Source'.
    ls_config-is_active    = abap_true.
    ls_config-user_id      = ''.
    ls_config-is_locked    = abap_true.
    ls_config-created_by   = sy-uname.
    ls_config-changed_by   = sy-uname.
    ls_config-created_at   = lv_timestamp.
    ls_config-changed_at   = lv_timestamp.
    APPEND ls_config TO lt_default_configs.

    " Application title - unlocked for customization
    CLEAR ls_config.
    ls_config-config_key   = 'APP_TITLE'.
    ls_config-config_value = 'abap2UI5'.
    ls_config-config_type  = 'STRING'.
    ls_config-description  = 'Application Title'.
    ls_config-is_active    = abap_true.
    ls_config-user_id      = ''.
    ls_config-is_locked    = abap_false.
    ls_config-created_by   = sy-uname.
    ls_config-changed_by   = sy-uname.
    ls_config-created_at   = lv_timestamp.
    ls_config-changed_at   = lv_timestamp.
    APPEND ls_config TO lt_default_configs.

    " Insert configurations
    LOOP AT lt_default_configs INTO ls_config.
      MODIFY z2ui5_config FROM @ls_config.
    ENDLOOP.

    " Initialize themes based on UI5 compatibility matrix
    " For themes, create a structure and populate it
    DATA ls_theme_entry TYPE z2ui5_themes.

    " sap_horizon themes (UI5 1.96+)
    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.96'.
    ls_theme_entry-theme       = 'sap_horizon'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.101'.
    ls_theme_entry-theme       = 'sap_horizon'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.120'.
    ls_theme_entry-theme       = 'sap_horizon'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.136'.
    ls_theme_entry-theme       = 'sap_horizon'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    " sap_horizon_dark themes (UI5 1.101+)
    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.101'.
    ls_theme_entry-theme       = 'sap_horizon_dark'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.120'.
    ls_theme_entry-theme       = 'sap_horizon_dark'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.136'.
    ls_theme_entry-theme       = 'sap_horizon_dark'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    " sap_horizon_hcb themes (UI5 1.101+)
    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.101'.
    ls_theme_entry-theme       = 'sap_horizon_hcb'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.120'.
    ls_theme_entry-theme       = 'sap_horizon_hcb'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.136'.
    ls_theme_entry-theme       = 'sap_horizon_hcb'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    " sap_horizon_hcw themes (UI5 1.101+)
    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.101'.
    ls_theme_entry-theme       = 'sap_horizon_hcw'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.120'.
    ls_theme_entry-theme       = 'sap_horizon_hcw'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.136'.
    ls_theme_entry-theme       = 'sap_horizon_hcw'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    " sap_fiori_3 themes (UI5 1.65+)
    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.65'.
    ls_theme_entry-theme       = 'sap_fiori_3'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    " sap_fiori_3 themes (UI5 1.69+)
    CLEAR ls_theme_entry.
    ls_theme_entry-ui5_version = '1.69'.
    ls_theme_entry-theme       = 'sap_fiori_3'.
    ls_theme_entry-is_active   = abap_true.
    ls_theme_entry-created_by  = sy-uname.
    ls_theme_entry-changed_by  = sy-uname.
    ls_theme_entry-created_at  = lv_timestamp.
    ls_theme_entry-changed_at  = lv_timestamp.
    MODIFY z2ui5_themes FROM @ls_theme_entry.

    " Continue with other themes following the same pattern...
    " (Expand this for all themes and versions as required)

    COMMIT WORK AND WAIT.
  ENDMETHOD.
ENDCLASS.
