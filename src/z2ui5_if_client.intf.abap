INTERFACE z2ui5_if_client
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_event,
      popup_close     TYPE string VALUE `POPUP_CLOSE`,
      open_new_tab    TYPE string VALUE `OPEN_NEW_TAB`,
      popover_close   TYPE string VALUE `POPOVER_CLOSE`,
      location_reload TYPE string VALUE `LOCATION_RELOAD`,
    END OF cs_event.

  TYPES:
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_config,
      view_model_edit_name TYPE string,
      version              TYPE string,
      origin               TYPE string,
      pathname             TYPE string,
      search               TYPE string,
      body                 TYPE string,
    END OF ty_s_config.

  TYPES:
    BEGIN OF ty_s_draft,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
      app               TYPE REF TO z2ui5_if_app,
    END OF ty_s_draft.

  TYPES:
    BEGIN OF ty_s_cursor,
      id             TYPE string,
      cursorpos      TYPE string,
      selectionstart TYPE string,
      selectionend   TYPE string,
    END OF ty_s_cursor.

  TYPES:
    BEGIN OF ty_s_get,
      event                  TYPE string,
      t_event_arg            TYPE string_table,
      t_scroll_pos           TYPE ty_t_name_value,
      check_launchpad_active TYPE abap_bool,
      check_on_navigated     TYPE abap_bool,
      s_draft                TYPE ty_s_draft,
      s_cursor               TYPE ty_s_cursor,
      s_config               TYPE ty_s_config,
    END OF ty_s_get.

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

  METHODS cursor_set
    IMPORTING
      id             TYPE clike
      cursorpos      TYPE clike
      selectionstart TYPE clike
      selectionend   TYPE clike.

  METHODS scroll_position_set
    IMPORTING
      val TYPE ty_t_name_value.

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
      VALUE(result) TYPE ty_s_get.

  METHODS get_app
    IMPORTING
      id            TYPE clike
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

  METHODS nav_app_leave
    IMPORTING
      app TYPE REF TO z2ui5_if_app.

  METHODS nav_app_call
    IMPORTING
      app TYPE REF TO z2ui5_if_app.

  METHODS message_box_display
    IMPORTING
      text TYPE clike
      type TYPE clike DEFAULT 'information'.

  METHODS url_param_set
    IMPORTING
      val TYPE clike.

  METHODS timer_set
    IMPORTING
      interval_ms     TYPE clike
      event_finished  TYPE clike.

  METHODS message_toast_display
    IMPORTING
      text TYPE string.

  METHODS _event
    IMPORTING
      val                TYPE clike
      check_view_destroy TYPE abap_bool    DEFAULT abap_false
      t_arg              TYPE string_table OPTIONAL
    RETURNING
      VALUE(result)      TYPE string.

  METHODS _bind
    IMPORTING
      val           TYPE data
      path          TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_edit
    IMPORTING
      val           TYPE data
      path          TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event_client
    IMPORTING
      action        TYPE clike
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

ENDINTERFACE.
