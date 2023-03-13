INTERFACE z2ui5_if_view
  PUBLIC .

  CONSTANTS:
    BEGIN OF cs,
      BEGIN OF lifecycle_method,
        on_init      TYPE string VALUE 'INIT',
        on_event     TYPE string VALUE 'EVENT',
        on_rendering TYPE string VALUE 'RENDERING',
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
    BEGIN OF ty_s_name_value,
      n TYPE string,
      v TYPE string,
    END OF ty_s_name_value.

  TYPES ty_T_name_value TYPE STANDARD TABLE OF ty_S_name_value WITH EMPTY KEY.

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

  METHODS layout_data
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS flex_item_data
    IMPORTING
      grow_Factor       TYPE string OPTIONAL
      base_Size         TYPE string OPTIONAL
      background_Design TYPE string OPTIONAL
      style_Class       TYPE string OPTIONAL
    RETURNING
      VALUE(result)     TYPE REF TO  z2ui5_if_view.

  METHODS code_editor
    IMPORTING
      value         TYPE string OPTIONAL
      type          TYPE string OPTIONAL
      height        TYPE string OPTIONAL
      width         TYPE string OPTIONAL
      editable      TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS suggestion_items
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS vertical_layout
    IMPORTING
      class         TYPE string OPTIONAL
      width         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS flex_box
    IMPORTING
      class         TYPE string OPTIONAL
      render_Type   TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS list_item
    IMPORTING
      text            TYPE string OPTIONAL
      additional_text TYPE string OPTIONAL
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_view.

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
      suggestion_items TYPE string OPTIONAL
      showsuggestion   TYPE abap_bool DEFAULT abap_true
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result)    TYPE REF TO  z2ui5_if_view.

  METHODS message_strip
    IMPORTING
      text          TYPE string OPTIONAL
      type          TYPE string OPTIONAL
      show_icon     TYPE abap_bool OPTIONAL
      class         TYPE string OPTIONAL
        PREFERRED PARAMETER text
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS ui_table
    IMPORTING
      rows            TYPE string OPTIONAL
      selectionMode   TYPE string OPTIONAL
      visibleRowCount TYPE string OPTIONAL
      selectedIndex   TYPE string OPTIONAL
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_view.

  METHODS ui_extension
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS ui_columns
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS ui_column
    IMPORTING
      width         TYPE string DEFAULT '11rem'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS ui_template
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.


  METHODS table
    IMPORTING
      items             TYPE data OPTIONAL
      growing           TYPE abap_bool DEFAULT abap_false
      growing_threshold TYPE string DEFAULT ''
      header_text       TYPE string OPTIONAL
      sticky            TYPE string OPTIONAL
      mode              type string optional
        PREFERRED PARAMETER items
    RETURNING
      VALUE(result)     TYPE REF TO  z2ui5_if_view.

  METHODS footer
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS dialog
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS buttons
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS message_page
    IMPORTING
      show_header           TYPE abap_bool DEFAULT abap_false
      text                  TYPE string OPTIONAL
      enable_formatted_text TYPE abap_bool DEFAULT abap_true
      description           TYPE string OPTIONAL
      icon                  TYPE string OPTIONAL
    RETURNING
      VALUE(result)         TYPE REF TO  z2ui5_if_view.

  METHODS table_select_dialog
    IMPORTING
      title            TYPE string OPTIONAL
      event_id_confirm TYPE string OPTIONAL
      event_id_cancel  TYPE string OPTIONAL
      items            TYPE data OPTIONAL
    RETURNING
      VALUE(result)    TYPE REF TO  z2ui5_if_view.

  METHODS get_parent
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS get
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS get_child
    IMPORTING
      index         TYPE i DEFAULT 1
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS columns
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS column
    IMPORTING
      width         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS items
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS column_list_item
    IMPORTING
      valign        TYPE string DEFAULT 'Middle'
      selected      type string optional
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS cells
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS header_content
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS sub_header
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS button
    IMPORTING
      text          TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
      press         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS page
    IMPORTING
      title          TYPE string OPTIONAL
      nav_button_tap TYPE string OPTIONAL
        PREFERRED PARAMETER title
    RETURNING
      VALUE(result)  TYPE REF TO  z2ui5_if_view.

  METHODS vbox
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS hbox
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS scroll_container
    IMPORTING
      height        TYPE string DEFAULT '100%'
      width         TYPE string DEFAULT '100%'
        PREFERRED PARAMETER height
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS simple_form
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS zz_html
    IMPORTING
      val           TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS content
    IMPORTING
      ns            TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS title
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS overflow_toolbar
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS toolbar_spacer
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS label
    IMPORTING
      text          TYPE string DEFAULT 'line_label'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS date_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS time_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS date_time_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS link
    IMPORTING
      text          TYPE string    DEFAULT 'line_label'
      href          TYPE string    OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS list
    IMPORTING
      header_text   TYPE string OPTIONAL
      items         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS standard_list_item
    IMPORTING
      title         TYPE string OPTIONAL
      description   TYPE string OPTIONAL
      icon          TYPE string OPTIONAL
      info          TYPE string OPTIONAL
      press         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS item
    IMPORTING
      key           TYPE string OPTIONAL
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS segmented_button_item
    IMPORTING
      icon          TYPE string OPTIONAL
      key           TYPE string OPTIONAL
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS combobox
    IMPORTING
      selectedkey     TYPE data
      show_clear_icon TYPE abap_bool DEFAULT abap_false
      label           TYPE string DEFAULT 'line_label'
      items           TYPE string OPTIONAL
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_view.

  METHODS grid
    IMPORTING
      class         TYPE string DEFAULT 'sapUiSmallMarginTop'
      default_span  TYPE string DEFAULT 'L6 M6 S12'
        PREFERRED PARAMETER default_span
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS text_area
    IMPORTING
      value         TYPE string OPTIONAL
      rows          TYPE string DEFAULT '8'
      height        TYPE string OPTIONAL
      width         TYPE string DEFAULT '100%'
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS switch
    IMPORTING
      state         TYPE string OPTIONAL
      customtexton  TYPE string OPTIONAL
      customtextoff TYPE string OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
      type          TYPE string DEFAULT 'Default'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS step_input
    IMPORTING
      value         TYPE string
      min           TYPE string
      max           TYPE string
      step          TYPE string
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS progress_indicator
    IMPORTING
      percent_value TYPE string
      display_value TYPE string OPTIONAL
      show_value    TYPE abap_bool DEFAULT abap_false
      state         TYPE string DEFAULT 'None'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS segmented_button
    IMPORTING
      selected_key     TYPE string
      selection_Change  type string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS checkbox
    IMPORTING
      text          TYPE clike OPTIONAL
      selected      TYPE clike OPTIONAL
      enabled       TYPE abap_bool OPTIONAL
        PREFERRED PARAMETER selected
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS header_toolbar
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS text
    IMPORTING
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.
  METHODS _generic
    IMPORTING
      name          TYPE string
      ns            TYPE string OPTIONAL
      t_prop        TYPE ty_t_name_value OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS zz_file_uploader
    IMPORTING
      value         TYPE clike OPTIONAL
      path          TYPE clike OPTIONAL
      placeholder   TYPE clike OPTIONAL
      upload        type clike optional
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

ENDINTERFACE.
