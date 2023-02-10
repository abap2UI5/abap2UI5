INTERFACE z2ui5_if_selscreen_group PUBLIC.
  TYPES:
    BEGIN OF ty_,
      BEGIN OF s_suggestion_items,
        value TYPE string,
        descr TYPE string,
      END OF s_suggestion_items,
      BEGIN OF s_combobox,
        key  TYPE string,
        text TYPE string,
      END OF s_combobox,
      BEGIN OF s_seg_btn,
        key  TYPE string,
        icon TYPE string,
        text TYPE string,
      END OF s_seg_btn,
    END OF ty_.

  TYPES: BEGIN OF ty_s_tab,
           text     TYPE string,
           icon     TYPE string,
           selected TYPE abap_bool,
         END OF ty_s_tab.

  TYPES:
    BEGIN OF ty,
      BEGIN OF input,
        t_suggestions TYPE STANDARD TABLE OF ty_-s_suggestion_items WITH EMPTY KEY,
      END OF input,
      BEGIN OF combobox,
        t_item TYPE STANDARD TABLE OF ty_-s_combobox WITH EMPTY KEY,
      END OF combobox,
      BEGIN OF radiobutton_group,
        BEGIN OF s_prop,
          selected TYPE abap_bool,
          text     TYPE string,
        END OF s_prop,
        t_prop TYPE string_table,
      END OF radiobutton_group,
      BEGIN OF segemented_button,
        t_button TYPE STANDARD TABLE OF ty_-s_seg_btn WITH EMPTY KEY,
        s_tab    TYPE ty_s_tab,
        tr_btn   TYPE STANDARD TABLE OF ty_s_tab WITH EMPTY KEY,
      END OF segemented_button,
      test    TYPE string,
      t_radio TYPE STANDARD TABLE OF string WITH EMPTY KEY,
    END OF ty.

  METHODS custom_control
    IMPORTING
      VALUE(val) TYPE  z2ui5_cl_hlp_utility=>ty-s-control
   RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS label
    IMPORTING
      text            TYPE string DEFAULT 'line_label'
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS date_picker
    IMPORTING
      value           TYPE string OPTIONAL
      placeholder     TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS time_picker
    IMPORTING
      value           TYPE string OPTIONAL
      placeholder     TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS date_time_picker
    IMPORTING
      value           TYPE string OPTIONAL
      placeholder     TYPE string OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
  METHODS link
    IMPORTING
      text            TYPE string    DEFAULT 'line_label'
      href            TYPE string    OPTIONAL
      enabled         type abap_bool DEFAULT abap_true
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
  METHODS combobox
    IMPORTING
      selectedKey     TYPE data
      show_clear_icon TYPE abap_bool DEFAULT abap_false
      label           TYPE string DEFAULT 'line_label'
      t_item          TYPE ty-combobox-t_item
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS text_area
    importing
         value type string optional
         rows  type i default 8
         height type string optional
         width  type string default '100%'
          PREFERRED PARAMETER value
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS switch
    importing
         state type abap_bool default abap_true
         customTextOn type string optional
         customTextOff type string optional
         enabled type abap_bool default abap_true
         type type string DEFAULT z2ui5_if_view=>cs-switch-type-default
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS step_input
    importing
      value type string
      min type string
      max type string
      step type string
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

   methods progress_indicator
        importing
            percent_value type string
            display_value type string optional
            show_value type abap_bool
            state type string default z2ui5_if_view=>cs-progress_indicator-state-none
        RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.

  METHODS segmented_button
    IMPORTING
      selected_key    TYPE data OPTIONAL
      t_button        TYPE ty-segemented_button-t_button
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
  METHODS button
    IMPORTING
      text            TYPE clike OPTIONAL
      icon            TYPE clike OPTIONAL
      on_press_id     TYPE clike
      type            TYPE clike OPTIONAL
      enabled         TYPE abap_bool OPTIONAL
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
  METHODS checkbox
    IMPORTING
      text            TYPE string OPTIONAL
      selected        TYPE abap_bool
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
  METHODS radiobutton_group
    IMPORTING
      "    description     TYPE string OPTIONAL
      selected_index  TYPE i OPTIONAL
      t_prop          TYPE ty-radiobutton_group-t_prop
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
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
      suggestion_items TYPE ty-input-t_suggestions OPTIONAL
      showSuggestion   TYPE abap_bool DEFAULT abap_true
        PREFERRED PARAMETER value
    RETURNING
      VALUE(r_result)  TYPE REF TO z2ui5_if_selscreen_group.
  METHODS text
    IMPORTING
      text            TYPE string OPTIONAL
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_group.
  METHODS end_of_group
    RETURNING
      VALUE(r_result) TYPE REF TO z2ui5_if_selscreen_block.
ENDINTERFACE.
