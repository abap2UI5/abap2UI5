INTERFACE z2ui5_if_client
  PUBLIC.

  CONSTANTS:
    BEGIN OF cs_event,
      event_popup_close   TYPE string VALUE `POPUP_CLOSE`,
      event_popover_close TYPE string VALUE `POPOVER_CLOSE`,
      go_back             TYPE string VALUE `GO_BACK`,
      go_forward          TYPE string VALUE `GO_FORWARD`,
    END OF cs_event.

  TYPES:
    BEGIN OF ty_S_config,
      controller_name TYPE string, " VALUE `z2ui5_controller`,
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

  METHODS set_view
    IMPORTING
      val TYPE string.

  METHODS set_popup
    IMPORTING
      val TYPE string.

  METHODS set_popover
    IMPORTING
      val TYPE string.

  METHODS get
    RETURNING VALUE(result) TYPE ty_s_get.

  METHODS get_app
    IMPORTING id            TYPE clike
    RETURNING VALUE(result) TYPE REF TO z2ui5_if_app.

  METHODS nav_app_leave
    IMPORTING app TYPE REF TO z2ui5_if_app.

  METHODS nav_app_call
    IMPORTING app TYPE REF TO z2ui5_if_app.

  METHODS nav_app_home.

  METHODS popup_message_box
    IMPORTING text TYPE string
              type TYPE string DEFAULT 'information'.

  METHODS popup_message_toast
    IMPORTING text TYPE string.

  METHODS _event_close_popup
    RETURNING VALUE(result) TYPE string.

  METHODS __event
    IMPORTING
      val               TYPE clike
      check_view_transit TYPE abap_bool DEFAULT abap_false
      t_arg             TYPE string_table OPTIONAL
    RETURNING
      VALUE(result)     TYPE string.

  METHODS __bind
    IMPORTING val           TYPE data
              path          TYPE abap_bool DEFAULT abap_false
    RETURNING VALUE(result) TYPE string.


  METHODS __bind_edit
    IMPORTING val           TYPE data
              path          TYPE abap_bool DEFAULT abap_false
    RETURNING VALUE(result) TYPE string.


  METHODS __event_frontend
    IMPORTING val           TYPE string
    RETURNING VALUE(result) TYPE string.

ENDINTERFACE.
