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
    END OF cs_event.

  CONSTANTS:
    BEGIN OF cs_clear,
      view TYPE string VALUE `VIEW`,
    END OF cs_clear.

  CONSTANTS:
    BEGIN OF cs_view,
      main    TYPE string VALUE `MAIN`,
      nested  TYPE string VALUE `NEST`,
      nested2 TYPE string VALUE `NEST2`,
    END OF cs_view.

  METHODS view_destroy.

  METHODS view_display
    IMPORTING
      val TYPE clike.

  METHODS view_model_update.

  METHODS nest_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
      method_insert  TYPE clike
      method_destroy TYPE clike OPTIONAL.

  METHODS nest_view_destroy.
  METHODS nest_view_model_update.

  METHODS nest2_view_display
    IMPORTING
      val            TYPE clike
      id             TYPE clike
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
      xml   TYPE clike
      by_id TYPE clike.

  METHODS popover_destroy.

  METHODS get
    RETURNING
      VALUE(result) TYPE z2ui5_if_types=>ty_s_get.

  METHODS get_app
    IMPORTING
      id            TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

  METHODS nav_app_leave
    IMPORTING
      app           TYPE REF TO z2ui5_if_app
    RETURNING
      VALUE(result) TYPE string.

  METHODS nav_app_call
    IMPORTING
      app           TYPE REF TO z2ui5_if_app
    RETURNING
      VALUE(result) TYPE string.

  METHODS message_box_display
    IMPORTING
      text TYPE clike
      type TYPE clike DEFAULT 'information'.

  METHODS message_toast_display
    IMPORTING
      text TYPE string.

  METHODS _event
    IMPORTING
      val                TYPE clike        OPTIONAL
      t_arg              TYPE string_table OPTIONAL
      check_view_destroy TYPE abap_bool    DEFAULT abap_false
        PREFERRED PARAMETER val
    RETURNING
      VALUE(result)      TYPE string.

  METHODS _event_client
    IMPORTING
      val           TYPE clike
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind
    IMPORTING
      val           TYPE data
      path          TYPE abap_bool DEFAULT abap_false
      custom_mapper TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter TYPE REF TO z2ui5_if_ajson_filter OPTIONAL
      tab           TYPE data OPTIONAL
      tab_index     TYPE i OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_edit
    IMPORTING
      val                TYPE data
      path               TYPE abap_bool  DEFAULT abap_false
      view               TYPE string     DEFAULT z2ui5_if_client=>cs_view-main
      custom_mapper      TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_mapper_back TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter      TYPE REF TO z2ui5_if_ajson_filter OPTIONAL
      custom_filter_back TYPE REF TO z2ui5_if_ajson_filter OPTIONAL
      tab                TYPE data OPTIONAL
      tab_index          TYPE i    OPTIONAL
    RETURNING
      VALUE(result)      TYPE string.

  METHODS _bind_local
    IMPORTING
      val           TYPE data
      path          TYPE abap_bool DEFAULT abap_false
      custom_mapper TYPE REF TO z2ui5_if_ajson_mapping OPTIONAL
      custom_filter TYPE REF TO z2ui5_if_ajson_filter OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_clear
    IMPORTING
      val TYPE data.

  METHODS clear
    IMPORTING
      val TYPE data.

ENDINTERFACE.
