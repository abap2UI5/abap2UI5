INTERFACE z2ui5_if_client
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_event,
      popup_close               TYPE string VALUE `POPUP_CLOSE`,
      open_new_tab              TYPE string VALUE `OPEN_NEW_TAB`,
      popover_close             TYPE string VALUE `POPOVER_CLOSE`,
      location_reload           TYPE string VALUE `LOCATION_RELOAD`,
      nav_container_to          TYPE string VALUE `NAV_CONTAINER_TO`,
      nest_nav_container_to     TYPE string VALUE `NEST_NAV_CONTAINER_TO`,
      nest2_nav_container_to    TYPE string VALUE `NEST2_NAV_CONTAINER_TO`,
      cross_app_nav_to_ext      TYPE string VALUE `CROSS_APP_NAV_TO_EXT`,
      cross_app_nav_to_prev_app TYPE string VALUE `CROSS_APP_NAV_TO_PREV_APP`,
      popup_nav_container_to    TYPE string VALUE `POPUP_NAV_CONTAINER_TO`,
      popover_nav_container_to  TYPE string VALUE `POPOVER_NAV_CONTAINER_TO`,
      download_b64_file         TYPE string VALUE `DOWNLOAD_B64_FILE`,
      set_size_limit            TYPE string VALUE `SET_SIZE_LIMIT`,
      set_odata_model           TYPE string VALUE `SET_ODATA_MODEL`,
      urlhelper                 TYPE string VALUE `URLHELPER`,
      history_back              TYPE string VALUE `HISTORY_BACK`,
      CLIPBOARD_APP_STATE       TYPE string VALUE `CLIPBOARD_APP_STATE`,
    END OF cs_event.

  CONSTANTS:
    BEGIN OF cs_view,
      main    TYPE string VALUE `MAIN`,
      nested  TYPE string VALUE `NEST`,
      nested2 TYPE string VALUE `NEST2`,
      popup   TYPE string VALUE `POPUP`,
      popover TYPE string VALUE `POPOVER`,
    END OF cs_view.

  METHODS view_destroy.

  METHODS view_display
    IMPORTING
      val                           TYPE clike
      switch_default_model_anno_uri TYPE string OPTIONAL
      switch_default_model_path     TYPE string OPTIONAL.

  METHODS view_model_update.

  METHODS set_session_stateful
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  METHODS set_app_state_active
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  METHODS set_push_state
    IMPORTING
      val TYPE string optional.

  METHODS set_nav_back
    IMPORTING
      val TYPE abap_bool DEFAULT abap_true.

  METHODS nest_view_display
    IMPORTING
      val            TYPE clike
      !id            TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest_view_destroy.
  METHODS nest_view_model_update.

  METHODS nest2_view_display
    IMPORTING
      val            TYPE clike
      !id            TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest2_view_destroy.
  METHODS nest2_view_model_update.

  METHODS popup_display
    IMPORTING
      val TYPE clike.

  METHODS popup_model_update.

  METHODS popup_destroy.

  METHODS popover_model_update.

  METHODS popover_display
    IMPORTING
      !xml  TYPE clike
      by_id TYPE clike.

  METHODS popover_destroy.

  METHODS get
    RETURNING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_get.

  METHODS get_event_arg
    IMPORTING
      v             TYPE i DEFAULT 1
    RETURNING
      VALUE(result) TYPE string.

  METHODS get_app
    IMPORTING
      !id           TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

  METHODS nav_app_leave
    IMPORTING
      VALUE(app)    TYPE REF TO z2ui5_if_app OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS nav_app_call
    IMPORTING
      app           TYPE REF TO z2ui5_if_app
    RETURNING
      VALUE(result) TYPE string.

  METHODS message_box_display
    IMPORTING
      !text             TYPE any
      !type             TYPE clike        DEFAULT `information`
      !title            TYPE clike        OPTIONAL
      styleclass        TYPE clike        OPTIONAL
      onclose           TYPE clike        OPTIONAL
      actions           TYPE string_table OPTIONAL
      emphasizedaction  TYPE clike        OPTIONAL
      initialfocus      TYPE clike        OPTIONAL
      textdirection     TYPE clike        OPTIONAL
      !icon             TYPE clike        OPTIONAL
      details           TYPE clike        OPTIONAL
      closeonnavigation TYPE abap_bool    DEFAULT abap_true.

  METHODS message_toast_display
    IMPORTING
      !text                    TYPE clike
      !duration                TYPE clike     OPTIONAL
      !width                   TYPE clike     OPTIONAL
      my                       TYPE clike     OPTIONAL
      !at                      TYPE clike     OPTIONAL
      !of                      TYPE clike     OPTIONAL
      !offset                  TYPE clike     OPTIONAL
      collision                TYPE clike     OPTIONAL
      onclose                  TYPE clike     DEFAULT ``
      autoclose                TYPE abap_bool DEFAULT abap_true
      animationtimingfunction  TYPE clike     OPTIONAL
      animationduration        TYPE clike     OPTIONAL
      closeonbrowsernavigation TYPE abap_bool DEFAULT abap_true
      !class                   TYPE clike     OPTIONAL.

  METHODS _event
    IMPORTING
      val           TYPE clike                              OPTIONAL
      t_arg         TYPE string_table                       OPTIONAL
      s_ctrl        TYPE z2ui5_if_types=>ty_s_event_control OPTIONAL
      r_data        TYPE data                               OPTIONAL
        PREFERRED PARAMETER val
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event_client
    IMPORTING
      val           TYPE clike
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind
    IMPORTING
      val                  TYPE data
      !path                TYPE abap_bool                     DEFAULT abap_false
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      !tab                 TYPE data                          OPTIONAL
      tab_index            TYPE i                             OPTIONAL
      switch_Default_Model TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result)        TYPE string.

  METHODS _bind_edit
    IMPORTING
      val                  TYPE data
      !path                TYPE abap_bool                     DEFAULT abap_false
      view                 TYPE string                        DEFAULT z2ui5_if_client=>cs_view-main
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_mapper_back   TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      custom_filter_back   TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      !tab                 TYPE data                          OPTIONAL
      tab_index            TYPE i                             OPTIONAL
      switch_default_model TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result)        TYPE string.

  METHODS _bind_local
    IMPORTING
      val                  TYPE data
      !path                TYPE abap_bool                     DEFAULT abap_false
      custom_mapper        TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter        TYPE REF TO z2ui5_if_ajson_filter  OPTIONAL
      switch_default_Model TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result)        TYPE string.

  METHODS follow_up_action
    IMPORTING
      val TYPE string.

  METHODS check_on_init
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS check_app_prev_stack
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS check_on_navigated
    RETURNING
      VALUE(result) TYPE abap_bool.

  METHODS get_app_prev
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

ENDINTERFACE.
