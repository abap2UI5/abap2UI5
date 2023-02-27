INTERFACE z2ui5_if_ui5_library
  PUBLIC .

  CONSTANTS:
    BEGIN OF cs,
      BEGIN OF lifecycle_method,
        on_init          TYPE string VALUE 'INIT',
        on_event         TYPE string VALUE 'EVENT',
        on_rendering     TYPE string VALUE 'RENDERING',
       " on_serialization TYPE string VALUE 'SERIALIZATION',
      END OF lifecycle_method,
      BEGIN OF event_type,
        server_function TYPE string VALUE 'SERVER_FUNCTION',
        display_id      TYPE string VALUE 'CALL_PREVIOUS_APP',
      END OF event_type,
      BEGIN OF bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF bind_type,
    END OF cs.

  TYPES:
    BEGIN OF ty,
      BEGIN OF s_property,
        n TYPE string,
        v TYPE string,
      END OF s_property,
    END OF ty.

  METHODS _bind
    IMPORTING
      val           TYPE data
    RETURNING
      VALUE(result) TYPE string.

  METHODS _bind_ONE_way
    IMPORTING
      val           TYPE data
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event
    IMPORTING
      val           TYPE string
    RETURNING
      VALUE(result) TYPE string.

  METHODS _event_display_id
    IMPORTING
      val           TYPE string
    RETURNING
      VALUE(result) TYPE string.

  METHODS code_editor
    IMPORTING
      value         TYPE string OPTIONAL
      type          TYPE string optional
      height        type string optional
      width         type string optional
      editable      type abap_bool optional
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS suggestion_items
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS list_item
    IMPORTING
      text            TYPE string OPTIONAL
      additional_text TYPE string OPTIONAL
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_ui5_library.

  METHODS input
    IMPORTING
      value            TYPE clike OPTIONAL
      placeholder      TYPE clike OPTIONAL
      type             TYPE clike OPTIONAL
      show_clear_icon  TYPE abap_bool DEFAULT abap_false
      value_state      TYPE clike OPTIONAL
      value_state_text TYPE clike OPTIONAL
      description      TYPE clike OPTIONAL
      editable         TYPE abap_bool DEFAULT abap_true
      suggestion_items TYPE string OPTIONAL "ty-input-t_suggestions OPTIONAL
      showsuggestion   TYPE abap_bool DEFAULT abap_true
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result)    TYPE REF TO  z2ui5_if_ui5_library.

  METHODS message_strip
    IMPORTING
      text          TYPE string OPTIONAL
      type          TYPE string OPTIONAL
      show_icon     TYPE abap_bool OPTIONAL
      class         TYPE string OPTIONAL
        PREFERRED PARAMETER text
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS ui_table
    IMPORTING
      rows            TYPE string OPTIONAL
      selectionMode   TYPE string OPTIONAL
      visibleRowCount TYPE string OPTIONAL
      selectedIndex   TYPE string optional
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_ui5_library.

  METHODS ui_extension
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS ui_columns
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS ui_column
    IMPORTING
      width         TYPE string DEFAULT '11rem'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS ui_template
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.


  METHODS table
    IMPORTING
      items             TYPE data OPTIONAL
      growing           TYPE abap_bool DEFAULT abap_false
      growing_threshold TYPE string DEFAULT ''
      header_text       TYPE string OPTIONAL
      sticky            TYPE string OPTIONAL
        PREFERRED PARAMETER items
    RETURNING
      VALUE(result)     TYPE REF TO  z2ui5_if_ui5_library.

  METHODS footer
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS dialog
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS buttons
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS message_page
    IMPORTING
      show_header           TYPE abap_bool DEFAULT abap_false
      text                  TYPE string OPTIONAL
      enable_formatted_text TYPE abap_bool DEFAULT abap_true
      description           TYPE string OPTIONAL
      icon                  TYPE string OPTIONAL
    RETURNING
      VALUE(result)         TYPE REF TO  z2ui5_if_ui5_library.

  METHODS table_select_dialog
    IMPORTING
      title            TYPE string OPTIONAL
      event_id_confirm TYPE string OPTIONAL
      event_id_cancel  TYPE string OPTIONAL
      items            TYPE data OPTIONAL
    RETURNING
      VALUE(result)    TYPE REF TO  z2ui5_if_ui5_library.

  METHODS get_parent
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS get
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS get_child
    IMPORTING
      index         TYPE i DEFAULT 1
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS columns
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS column
    IMPORTING
      width         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS items
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS column_list_item
    IMPORTING
      valign        TYPE string DEFAULT 'Middle'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS cells
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS header_content
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS sub_header
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS button
    IMPORTING
      text          TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
      press         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS page
    IMPORTING
      title          TYPE string OPTIONAL
      nav_button_tap TYPE string OPTIONAL
        PREFERRED PARAMETER title
    RETURNING
      VALUE(result)  TYPE REF TO  z2ui5_if_ui5_library.

  METHODS vbox
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS scroll_container
    IMPORTING
      height        TYPE string DEFAULT '100%'
      width         TYPE string DEFAULT '100%'
        PREFERRED PARAMETER height
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS simple_form
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS zz_html
    IMPORTING
      val           TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS content
    IMPORTING
      ns            TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS title
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS overflow_toolbar
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS toolbar_spacer
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS label
    IMPORTING
      text          TYPE string DEFAULT 'line_label'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS date_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS time_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS date_time_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS link
    IMPORTING
      text          TYPE string    DEFAULT 'line_label'
      href          TYPE string    OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS list
    IMPORTING
      header_text   TYPE string OPTIONAL
      items         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS standard_list_item
    IMPORTING
      title         TYPE string OPTIONAL
      description   TYPE string OPTIONAL
      icon          TYPE string OPTIONAL
      info          TYPE string OPTIONAL
      press         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS item
    IMPORTING
      key           TYPE string OPTIONAL
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS segmented_button_item
    IMPORTING
      icon          TYPE string OPTIONAL
      key           TYPE string OPTIONAL
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS combobox
    IMPORTING
      selectedkey     TYPE data
      show_clear_icon TYPE abap_bool DEFAULT abap_false
      label           TYPE string DEFAULT 'line_label'
      items           TYPE string OPTIONAL
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_ui5_library.

  METHODS grid
    IMPORTING
      class         TYPE string DEFAULT 'sapUiSmallMarginTop'
      default_span  TYPE string DEFAULT 'L6 M6 S12'
        PREFERRED PARAMETER default_span
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS text_area
    IMPORTING
      value         TYPE string OPTIONAL
      rows          TYPE i DEFAULT 8
      height        TYPE string OPTIONAL
      width         TYPE string DEFAULT '100%'
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS switch
    IMPORTING
      state         TYPE abap_bool DEFAULT abap_true
      customtexton  TYPE string OPTIONAL
      customtextoff TYPE string OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
      type          TYPE string DEFAULT 'Default'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS step_input
    IMPORTING
      value         TYPE string
      min           TYPE string
      max           TYPE string
      step          TYPE string
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS progress_indicator
    IMPORTING
      percent_value TYPE string
      display_value TYPE string OPTIONAL
      show_value    TYPE abap_bool DEFAULT abap_false
      state         TYPE string DEFAULT 'None'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS segmented_button
    IMPORTING
      selected_key  TYPE string
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS checkbox
    IMPORTING
      text          TYPE clike OPTIONAL
      selected      TYPE clike OPTIONAL
      enabled       TYPE abap_bool OPTIONAL
        PREFERRED PARAMETER selected
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS header_toolbar
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS text
    IMPORTING
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

ENDINTERFACE.
