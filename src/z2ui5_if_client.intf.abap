INTERFACE z2ui5_if_client
  PUBLIC .

  TYPES:
    BEGIN OF ty_s_name_value,
      name  TYPE string,
      value TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_get,
      event             TYPE string,
      event_data        TYPE string,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
      t_req_param       type ty_t_name_value,
      t_req_header      type ty_t_name_value,
    END OF ty_s_get.

  TYPES:
    BEGIN OF ty_S_next,
      xml_main            TYPE string,
      xml_popup           TYPE string,
      popup_open_by_id    type string,
      check_set_prev_view TYPE abap_bool,
      t_scroll_pos        TYPE ty_t_name_value,
      BEGIN OF s_cursor_pos,
        id             TYPE string,
        cursorpos      TYPE string,
        selectionstart TYPE string,
        selectionend   TYPE string,
      END OF s_cursor_pos,
      begin of s_timer,
        interval_ms    type string,
        event_finished type string,
      end of s_timer,
    END OF ty_s_next.

  METHODS set_next
    IMPORTING
      val TYPE ty_S_next.

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
      app type ref to z2ui5_if_app.

  METHODS nav_app_call
    IMPORTING
      app TYPE REF TO z2ui5_if_app.

  METHODS nav_app_home.

  METHODS popup_message_box
    IMPORTING
      text TYPE string
      type TYPE string DEFAULT 'information'.

  METHODS popup_message_toast
    IMPORTING
      text TYPE string.

  METHODS _bind
    IMPORTING
      val            TYPE data
      path           TYPE abap_bool DEFAULT abap_false
      check_gen_data type abap_bool OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_one
    IMPORTING
      val           TYPE data
      path          TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event
    IMPORTING
      val           TYPE clike
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event_close_popup
    RETURNING
      VALUE(result) TYPE string.

ENDINTERFACE.
