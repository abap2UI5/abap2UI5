INTERFACE z2ui5_if_client
  PUBLIC .

  CONSTANTS:
    BEGIN OF cs,
      BEGIN OF lifecycle_method,
        on_event     TYPE string VALUE 'EVENT',
        on_rendering TYPE string VALUE 'RENDERING',
      END OF lifecycle_method,
    END OF cs.

  TYPES:
    BEGIN OF ty_s_cursor,
      id             TYPE string,
      cursorpos      TYPE string,
      selectionstart TYPE string,
      selectionend   TYPE string,
    END OF ty_s_cursor.

  TYPES:
    BEGIN OF ty_s_get,
      view_active        TYPE string,
      popup_active       TYPE string,
      check_previous_app TYPE abap_bool,
      event              TYPE string,
      page_scroll_pos    TYPE i,
      lifecycle_method   TYPE string,
      id                 TYPE string,
      id_prev            TYPE string,
      id_prev_app        TYPE string,
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
      event         TYPE clike OPTIONAL
      t_scroll_pos  TYPE z2ui5_cl_http_handler=>ty_t_name_value OPTIONAL
      s_cursor_pos  TYPE ty_s_cursor OPTIONAL
      set_prev_view TYPE abap_bool OPTIONAL.

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
