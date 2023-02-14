INTERFACE z2ui5_if_ui5_library
  PUBLIC .

  CONSTANTS:
    BEGIN OF cs,
      BEGIN OF lifecycle_method,
        on_init      TYPE string VALUE 'INIT',
        on_event     TYPE string VALUE 'EVENT',
        on_rendering TYPE string VALUE 'RENDERING',
      END OF lifecycle_method,
      BEGIN OF event_type,
        server_function   TYPE string VALUE 'SERVER_FUNCTION',
        display_id        TYPE string VALUE 'CALL_PREVIOUS_APP',
      END OF event_type,
      BEGIN OF bind_type,
        one_way  TYPE string VALUE 'ONE_WAY',
        two_way  TYPE string VALUE 'TWO_WAY',
        one_time TYPE string VALUE 'ONE_TIME',
      END OF bind_type,
      BEGIN OF input,
        BEGIN OF type,
          password TYPE string VALUE 'Password',
          email    TYPE string VALUE 'Email',
          telefon  TYPE string VALUE 'Tel',
          number   TYPE string VALUE 'Number',
          url      TYPE string VALUE 'Url',
        END OF type,
        BEGIN OF value_state,
          warning     TYPE string VALUE 'Warning',
          success     TYPE string VALUE 'Success',
          error       TYPE string VALUE 'Error',
          information TYPE string VALUE 'Information',
        END OF value_state,
      END OF input,
      BEGIN OF button,
        BEGIN OF type,
          reject     TYPE string VALUE 'Reject',
          success    TYPE string VALUE 'Success',
          emphasized TYPE string VALUE 'Emphasized',
        END OF type,
      END OF button,
      BEGIN OF message_strip,
        BEGIN OF type,
          error       TYPE string VALUE 'Error',
          warning     TYPE string VALUE 'Warning',
          success     TYPE string VALUE 'Success',
          information TYPE string VALUE 'Information',
        END OF type,
      END OF message_strip,
      BEGIN OF message_box,
        BEGIN OF type,
          error   TYPE string VALUE 'error',
          alert   TYPE string VALUE 'alert',
          info    TYPE string VALUE 'information',
          warning TYPE string VALUE 'warning',
          success TYPE string VALUE 'success',
        END OF type,
      END OF message_box,
      BEGIN OF code_editor,
        BEGIN OF type,
          abap       TYPE string VALUE 'abap',
          json       TYPE string VALUE 'json',
          xml        TYPE string VALUE 'xml',
          yaml       TYPE string VALUE 'yaml',
          css        TYPE string VALUE 'css',
          javascript TYPE string VALUE 'javascript',
        END OF type,
      END OF code_editor,
      BEGIN OF switch,
        BEGIN OF type,
          accept_reject TYPE string VALUE 'AcceptReject',
          Default       TYPE string VALUE 'Default',
        END OF type,
      END OF switch,
      BEGIN OF progress_indicator,
        BEGIN OF state,
          error       TYPE string VALUE 'Error',
          warning     TYPE string VALUE 'Warning',
          success     TYPE string VALUE 'Success',
          information TYPE string VALUE 'Information',
          none        TYPE string VALUE 'None',
        END OF state,
      END OF progress_indicator,
    END OF cs.

  TYPES: BEGIN OF ty_s_tab,
           text     TYPE string,
           icon     TYPE string,
           selected TYPE abap_bool,
         END OF ty_s_tab.

  TYPES:
    BEGIN OF ty,
*      BEGIN OF _,
*        BEGIN OF s_combobox,
*          key  TYPE string,
*          text TYPE string,
*        END OF s_combobox,
*        BEGIN OF s_seg_btn,
*          key  TYPE string,
*          icon TYPE string,
*          text TYPE string,
*        END OF s_seg_btn,
*      END OF _,
    "  BEGIN OF input,
     "   t_suggestions TYPE STANDARD TABLE OF ty-_-s_suggestion_items WITH EMPTY KEY,
   "  " END OF input,
   "   BEGIN OF combobox,
   "     t_item TYPE STANDARD TABLE OF ty-_-s_combobox WITH EMPTY KEY,
   "   END OF combobox,
      BEGIN OF radiobutton_group,
        BEGIN OF s_prop,
          selected TYPE abap_bool,
          text     TYPE string,
        END OF s_prop,
        t_prop TYPE string_table,
      END OF radiobutton_group,
      BEGIN OF segemented_button,
*        t_button TYPE STANDARD TABLE OF ty-_-s_seg_btn WITH EMPTY KEY,
        s_tab    TYPE ty_s_tab,
        tr_btn   TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY,
      END OF segemented_button,
      t_radio TYPE STANDARD TABLE OF string WITH EMPTY KEY,
    END OF ty.

  METHODS _bind
    IMPORTING
      val           TYPE data
     " type          TYPE string DEFAULT cs-bind_type-two_way
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
     " type          TYPE string DEFAULT cs-event_type-server_function
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
      type          TYPE string
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

    methods suggestion_items
        RETURNING
      VALUE(result)    TYPE REF TO  z2ui5_if_ui5_library.

    methods list_item
        importing
            text type string optional
            additional_text type string optional
           RETURNING
      VALUE(result)    TYPE REF TO  z2ui5_if_ui5_library.



  METHODS  input
    IMPORTING
      value            TYPE clike OPTIONAL
      placeholder      TYPE clike OPTIONAL
      type             TYPE clike OPTIONAL
      show_clear_icon  TYPE abap_bool DEFAULT abap_false
      value_state      TYPE clike OPTIONAL
      value_state_text TYPE clike OPTIONAL
      description      TYPE clike OPTIONAL
      editable         TYPE abap_bool DEFAULT abap_true
      suggestion_items TYPE string optional "ty-input-t_suggestions OPTIONAL
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

  METHODS table
    IMPORTING
      items             TYPE data
      growing_threshold TYPE string DEFAULT ''
    RETURNING
      VALUE(result)     TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  footer
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  dialog
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  buttons
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  message_page
    IMPORTING
      show_header           TYPE abap_bool DEFAULT abap_false
      text                  TYPE string OPTIONAL
      enable_formatted_text TYPE abap_bool DEFAULT abap_true
      description           TYPE string OPTIONAL
      icon                  TYPE string OPTIONAL
    RETURNING
      VALUE(result)         TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  table_select_dialog
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

  METHODS  columns
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  column
    IMPORTING
      width         TYPE string OPTIONAL
      text          TYPE string DEFAULT 'title'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  items
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  column_list_item
    IMPORTING
      valign        TYPE string DEFAULT 'Middle'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  cells
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  header_content
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  sub_header
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  button
    IMPORTING
      text          TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
    "  on_press_id   TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
      press         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  page
    IMPORTING
      title             TYPE string OPTIONAL
     " event_nav_back_id TYPE string OPTIONAL
      nav_button_tap type string optional
        PREFERRED PARAMETER title
    RETURNING
      VALUE(result)     TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  vbox
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  scroll_container
    IMPORTING
      height        TYPE string DEFAULT '100%'
      width         TYPE string DEFAULT '100%'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  simple_form
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  zz_html
    IMPORTING
      val           TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  content
    IMPORTING
      ns            TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  title
    IMPORTING
      title         TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  overflow_toolbar
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  toolbar_spacer
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  label
    IMPORTING
      text          TYPE string DEFAULT 'line_label'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  date_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  time_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  date_time_picker
    IMPORTING
      value         TYPE string OPTIONAL
      placeholder   TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  link
    IMPORTING
      text          TYPE string    DEFAULT 'line_label'
      href          TYPE string    OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  list
    IMPORTING
      header_text   TYPE string OPTIONAL
      items         TYPE data
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  standard_list_item
    IMPORTING
      title         TYPE string OPTIONAL
      description   TYPE string OPTIONAL
      icon          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

      methods item
        importing
            key type string optional
            text type string optional
              RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_ui5_library.


  methods segmented_button_item
    importing
        icon type string optional
        key type string optional
        text type string optional
                    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_ui5_library.

  METHODS  combobox
    IMPORTING
      selectedkey     TYPE data
      show_clear_icon TYPE abap_bool DEFAULT abap_false
      label           TYPE string DEFAULT 'line_label'
      items           TYPE string optional
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  grid
    IMPORTING
      class         TYPE string DEFAULT 'sapUiSmallMarginTop'
      default_span  TYPE string DEFAULT 'L6 M6 S12'
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  text_area
    IMPORTING
      value         TYPE string OPTIONAL
      rows          TYPE i DEFAULT 8
      height        TYPE string OPTIONAL
      width         TYPE string DEFAULT '100%'
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  switch
    IMPORTING
      state         TYPE abap_bool DEFAULT abap_true
      customtexton  TYPE string OPTIONAL
      customtextoff TYPE string OPTIONAL
      enabled       TYPE abap_bool DEFAULT abap_true
      type          TYPE string DEFAULT cs-switch-type-default
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  step_input
    IMPORTING
      value         TYPE string
      min           TYPE string
      max           TYPE string
      step          TYPE string
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  progress_indicator
    IMPORTING
      percent_value TYPE string
      display_value TYPE string OPTIONAL
      show_value    TYPE abap_bool DEFAULT abap_false
      state         TYPE string DEFAULT cs-progress_indicator-state-none
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  segmented_button
    IMPORTING
      selected_key  TYPE string
  "    t_button      TYPE ty-segemented_button-t_button
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

  METHODS  checkbox
    IMPORTING
      text          TYPE clike OPTIONAL
      selected      TYPE clike OPTIONAL
      "   selected_json TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  header_toolbar
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  radiobutton_group
    IMPORTING
      "    description     TYPE string OPTIONAL
      selected_index TYPE clike OPTIONAL
      t_prop         TYPE ty-radiobutton_group-t_prop
    RETURNING
      VALUE(result)  TYPE REF TO  z2ui5_if_ui5_library.
  METHODS  text
    IMPORTING
      text          TYPE string OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_ui5_library.

ENDINTERFACE.
