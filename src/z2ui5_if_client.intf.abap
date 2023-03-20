INTERFACE z2ui5_if_client
  PUBLIC .

  CONSTANTS cs LIKE z2ui5_if_view=>cs VALUE z2ui5_if_view=>cs.

types:
    begin of ty_S_cursor,
       id             type string,
       cursorPos      type string,
       selectionStart type string,
       selectionEnd   type string,
    end of ty_S_cursor.

  TYPES:
    BEGIN OF ty_S_get,
      view_active        TYPE string,
      popup_active       type string,
      check_previous_app TYPE abap_bool,
      event              TYPE string,
      page_scroll_pos    TYPE i,
      lifecycle_method   TYPE string,
      id                 TYPE string,
      id_prev            TYPE string,
      id_prev_app        type string,
      id_prev_app_stack  TYPE string,
      BEGIN OF s_request,
        tenant          TYPE string,
        url_app         TYPE string,
        url_app_gen     TYPE string,
        origin          TYPE string,
        url_source_code TYPE string,
      END OF s_request,
    END OF ty_s_get.


  METHODS set
    IMPORTING
      event           TYPE clike OPTIONAL
      t_scroll_pos    type z2ui5_if_view=>ty_t_name_value optional
      s_cursor_pos    type ty_s_cursor optional
      set_prev_view   type abap_bool optional.

  METHODS get
    RETURNING
      VALUE(result) TYPE ty_S_get.

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


  METHODS show_view
    IMPORTING
      val               TYPE clike OPTIONAL
      check_no_rerender TYPE abap_bool DEFAULT abap_false
        PREFERRED PARAMETER val.

  METHODS popup_view
    IMPORTING
      name TYPE clike.


  METHODS factory_view
    IMPORTING
      name          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS _bind
    IMPORTING
      val           TYPE data
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_one_way
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
