INTERFACE z2ui5_if_client
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_event,
      popup_close   TYPE string VALUE `POPUP_CLOSE`,
      popover_close TYPE string VALUE `POPOVER_CLOSE`,
      leave_home    TYPE string VALUE `LEAVE_HOME`,
      leave_restart TYPE string VALUE `LEAVE_RESTART`,
    END OF cs_event.

  TYPES:
    BEGIN OF ty_S_config,
      controller_name TYPE string,
      pathname        TYPE string,
      origin          TYPE string,
      search          TYPE string,
      path_info       TYPE string,
      body            TYPE string,
      app             TYPE REF TO z2ui5_if_app,
    END OF ty_S_config.

  TYPES:
    BEGIN OF ty_s_name_value,
      name  TYPE string,
      value TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_get,
      event                  TYPE string,
      t_event_arg            TYPE string_table,
      id                     TYPE string,
      id_prev                TYPE string,
      id_prev_app            TYPE string,
      id_prev_app_stack      TYPE string,
      check_launchpad_active TYPE abap_bool,
      t_scroll_pos           TYPE ty_t_name_value,
      BEGIN OF s_cursor,
        id             TYPE string,
        cursorpos      TYPE string,
        selectionstart TYPE string,
        selectionend   TYPE string,
      END OF s_cursor,
      s_config               TYPE ty_S_config,
    END OF ty_s_get.

  TYPES:
    BEGIN OF ty_S_next,
      xml_main           TYPE string,
      xml_popup          TYPE string,
      popover_open_by_id TYPE string,
      t_scroll           TYPE ty_t_name_value,
      title              TYPE string,
      path               TYPE string,
      url                TYPE string,
      BEGIN OF s_popup,
        xml         TYPE string,
        id          TYPE string,
        check_close TYPE abap_bool,
      END OF s_popup,
      BEGIN OF s_popover,
        xml         TYPE string,
        id          TYPE string,
        open_by_id  TYPE string,
        check_close TYPE abap_bool,
      END OF s_popover,
      BEGIN OF s_cursor,
        id             TYPE string,
        cursorpos      TYPE string,
        selectionstart TYPE string,
        selectionend   TYPE string,
      END OF s_cursor,
      BEGIN OF s_timer,
        interval_ms    TYPE string,
        event_finished TYPE string,
      END OF s_timer,
      _viewmodel         TYPE string,
    END OF ty_s_next.

  METHODS view_display
    IMPORTING
      val TYPE string.

  METHODS cursor_set
    IMPORTING
      val TYPE ty_s_get-s_cursor.

  METHODS scroll_position_set
    IMPORTING
      val TYPE ty_s_get-t_scroll_pos.

  METHODS popup_display
    IMPORTING
      val TYPE string.

  METHODS popup_close.

  METHODS popover_display
    IMPORTING
      xml   TYPE string
      by_id TYPE string.

  METHODS popover_close.

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
      text TYPE string
      type TYPE string DEFAULT 'information'.

  METHODS message_toast_display
    IMPORTING
      text TYPE string.

  METHODS _event
    IMPORTING
      val                TYPE clike
      check_view_transit TYPE abap_bool DEFAULT abap_false
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
      val           TYPE string
    RETURNING
      VALUE(result) TYPE string.

ENDINTERFACE.
