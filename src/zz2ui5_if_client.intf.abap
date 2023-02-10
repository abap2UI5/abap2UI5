INTERFACE zz2ui5_if_client
  PUBLIC .

  CONSTANTS cs LIKE zz2ui5_if_ui5_library=>cs VALUE zz2ui5_if_ui5_library=>cs.

  TYPES:
    BEGIN OF ty_S_get,
      screen_active    TYPE string,
      check_call_satck TYPE abap_bool,
      event_id         TYPE string,
      lifecycle_method TYPE string,
      event_object     TYPE REF TO z2ui5_cl_hlp_tree_json,
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

  METHODS nav_to_home.

  METHODS get_app_called
    RETURNING
      VALUE(result) TYPE REF TO zz2ui5_if_app.


  METHODS display_message_box
    IMPORTING
      text TYPE string
      type TYPE string DEFAULT cs-message_box-type-info.

  METHODS display_message_toast
    IMPORTING
      text TYPE string.

  METHODS display_view
    IMPORTING
      val               TYPE clike OPTIONAL
      check_no_rerender TYPE abap_bool DEFAULT abap_false
        PREFERRED PARAMETER val.

  METHODS factory_view
    IMPORTING
      name          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO zz2ui5_if_ui5_library.

  METHODS display_popup
    IMPORTING
      name TYPE clike.

ENDINTERFACE.
