INTERFACE z2ui5_if_client
  PUBLIC .

  TYPES:
    BEGIN OF ty_s_name_value,
      name  TYPE string,
      value TYPE string,
    END OF ty_s_name_value.
  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_s_cursor,
      id             TYPE string,
      cursorpos      TYPE string,
      selectionstart TYPE string,
      selectionend   TYPE string,
    END OF ty_s_cursor.

  TYPES:
    BEGIN OF ty_s_get,
      event             TYPE string,
      event_data        type string,
      id                TYPE string,
      id_prev           TYPE string,
      id_prev_app       TYPE string,
      id_prev_app_stack TYPE string,

         url_app         TYPE string,
          url_source_code TYPE string,
     " BEGIN OF s_request,
 "       tenant          TYPE string,

    "    url_app_gen     TYPE string,
    "    origin          TYPE string,

     " END OF s_request,
    END OF ty_s_get.

  TYPES:
    BEGIN OF ty_S_next,
      xml_main            TYPE string,
      xml_popup           TYPE string,
      check_set_prev_view TYPE abap_bool,
      event               TYPE string,
      t_scroll_pos        TYPE z2ui5_if_client=>ty_t_name_value,
      s_cursor_pos        TYPE z2ui5_if_client=>ty_s_cursor,
    END OF ty_s_next.

  METHODS set_next
    IMPORTING
      val TYPE ty_S_next.

  METHODS get
    RETURNING
      VALUE(result) TYPE ty_s_get.

  METHODS get_app_by_id
    IMPORTING
      id            TYPE clike
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_app.

  METHODS nav_app_leave
    IMPORTING
      id TYPE clike.

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
      val           TYPE data
      path          TYPE abap_boolean DEFAULT abap_false
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_one
    IMPORTING
      val           TYPE data
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
