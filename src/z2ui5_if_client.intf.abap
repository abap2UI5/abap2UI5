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
      t_event_arg       TYPE string_table,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,
      t_scroll_pos      TYPE ty_t_name_value,
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
      app TYPE REF TO z2ui5_if_app.

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
      check_gen_data TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(result)  TYPE string.

  METHODS _bind_one
    IMPORTING
      val           TYPE data
      path          TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event
    IMPORTING
      val           TYPE clike
      hold_view     TYPE abap_bool DEFAULT abap_false
      t_arg         TYPE string_table OPTIONAL
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event_close_popup
    RETURNING
      VALUE(result) TYPE string.

ENDINTERFACE.
