INTERFACE zz2ui5_if_app_client
  PUBLIC .

  TYPES:
    BEGIN OF ty_S_get,
      screen_active    TYPE string,
      check_call_satck TYPE abap_bool,
      event_id         TYPE string,
      lifecycle_method TYPE string,
      event_object     type ref to z2ui5_cl_hlp_tree_json,
    END OF ty_s_get.

  CONSTANTS:
    BEGIN OF lifecycle_method,
      on_init      TYPE string VALUE 'INIT',
      on_event     TYPE string VALUE 'EVENT',
      on_rendering TYPE string VALUE 'RENDERING',
    END OF lifecycle_method.

  METHODS get
    RETURNING
      VALUE(result) TYPE ty_S_get.

  METHODS nav_to_app
    IMPORTING
      app TYPE REF TO zz2ui5_if_app.

    methods nav_to_home.

  METHODS get_app_called
    RETURNING
      VALUE(result) TYPE REF TO zz2ui5_if_app.


  METHODS display_popup_inform
       IMPORTING
      text TYPE string
      type TYPE string DEFAULT z2ui5_if_view=>cs-message_box-type-info.

  METHODS display_message_toast
     IMPORTING
      text TYPE string.

  METHODS display_view
    IMPORTING
      val TYPE clike optional
    check_no_rerender type abap_bool default abap_false
    PREFERRED PARAMETER val.

  methods factory_view
    importing
        name type string optional
    RETURNING
       value(result) type ref to z2ui5_cl_control_library.

  methods display_popup
    importing
      name type clike.

  "  methods display_popup_inform.

ENDINTERFACE.
