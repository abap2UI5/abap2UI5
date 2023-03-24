INTERFACE z2ui5_if_view
  PUBLIC .

  CONSTANTS:
    BEGIN OF cs,
      BEGIN OF lifecycle_method,
*        on_init      TYPE string VALUE 'INIT',
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

  TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

  METHODS layout_data
    IMPORTING
      ns            TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS flex_item_data
    IMPORTING
      growfactor       TYPE clike OPTIONAL
      basesize         TYPE clike OPTIONAL
      backgrounddesign TYPE clike OPTIONAL
      styleclass       TYPE clike OPTIONAL
    RETURNING
      VALUE(result)    TYPE REF TO z2ui5_if_view.

  METHODS code_editor
    IMPORTING
      value         TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      height        TYPE clike OPTIONAL
      width         TYPE clike OPTIONAL
      editable      TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS suggestion_items
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS vertical_layout
    IMPORTING
      class         TYPE clike OPTIONAL
      width         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS horizontal_layout
    IMPORTING
      class         TYPE clike OPTIONAL
      width         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS flex_box
    IMPORTING
      class          TYPE clike OPTIONAL
      rendertype     TYPE clike OPTIONAL
      width          TYPE clike OPTIONAL
      height         TYPE clike OPTIONAL
      alignitems     TYPE clike OPTIONAL
      justifycontent TYPE clike OPTIONAL
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS list_item
    IMPORTING
      text           TYPE clike OPTIONAL
      additionaltext TYPE clike OPTIONAL
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS input
    IMPORTING
      id               TYPE clike OPTIONAL
      value            TYPE clike OPTIONAL
      placeholder      TYPE clike OPTIONAL
      type             TYPE clike OPTIONAL
      showclearicon    TYPE clike OPTIONAL
      valuestate       TYPE clike OPTIONAL
      valuestatetext   TYPE clike OPTIONAL
      description      TYPE clike OPTIONAL
      editable         TYPE clike OPTIONAL
      enabled          TYPE clike OPTIONAL
      suggestionitems  TYPE clike OPTIONAL
      showsuggestion   TYPE clike OPTIONAL
      showvaluehelp    TYPE clike OPTIONAL
      valuehelprequest TYPE clike OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result)    TYPE REF TO z2ui5_if_view.

  METHODS message_strip
    IMPORTING
      text          TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      showicon      TYPE clike OPTIONAL
      class         TYPE clike OPTIONAL
        PREFERRED PARAMETER text
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS table
    IMPORTING
      items               TYPE clike OPTIONAL
      growing             TYPE clike OPTIONAL
      growingthreshold    TYPE clike OPTIONAL
      growingscrolltoload TYPE clike OPTIONAL
      headertext          TYPE clike OPTIONAL
      sticky              TYPE clike OPTIONAL
      mode                TYPE clike OPTIONAL
      width               TYPE clike OPTIONAL
        PREFERRED PARAMETER items
    RETURNING
      VALUE(result)       TYPE REF TO z2ui5_if_view.

  METHODS footer
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS dialog
    IMPORTING
      title         TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      showheader    TYPE clike OPTIONAL
      stretch       TYPE clike OPTIONAL
      contentheight TYPE clike OPTIONAL
      contentwidth  TYPE clike OPTIONAL
      PREFERRED PARAMETER title
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS buttons
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS message_page
    IMPORTING
      show_header         TYPE clike OPTIONAL
      text                TYPE clike OPTIONAL
      enableformattedtext TYPE clike OPTIONAL
      description         TYPE clike OPTIONAL
      icon                TYPE clike OPTIONAL
    RETURNING
      VALUE(result)       TYPE REF TO z2ui5_if_view.

  METHODS get_parent
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS get
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS get_child
    IMPORTING
      index         TYPE i DEFAULT 1
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS columns
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS column
    IMPORTING
      width         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS items
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS interact_donut_chart
    IMPORTING
      selectionchanged  TYPE clike OPTIONAL
      errormessage      TYPE clike OPTIONAL
      errormessagetitle TYPE clike OPTIONAL
      showerror         TYPE clike OPTIONAL
      displayedsegments TYPE clike OPTIONAL
      press             TYPE clike OPTIONAL
    RETURNING
      VALUE(result)     TYPE REF TO z2ui5_if_view.

  METHODS segments
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS interact_donut_chart_segment
    IMPORTING
      label          TYPE clike OPTIONAL
      value          TYPE clike OPTIONAL
      displayedvalue TYPE clike OPTIONAL
      selected       TYPE clike OPTIONAL
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS interact_bar_chart
    IMPORTING
      selectionchanged  TYPE clike OPTIONAL
      press             TYPE clike OPTIONAL
      labelwidth        TYPE clike OPTIONAL
      errormessage      TYPE clike OPTIONAL
      errormessagetitle TYPE clike OPTIONAL
      showerror         TYPE clike OPTIONAL
    RETURNING
      VALUE(result)     TYPE REF TO z2ui5_if_view.

  METHODS bars
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS interact_bar_chart_bar
    IMPORTING
      label          TYPE clike OPTIONAL
      value          TYPE clike OPTIONAL
      displayedvalue TYPE clike OPTIONAL
      selected       TYPE clike OPTIONAL
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS interact_line_chart
    IMPORTING
      selectionchanged  TYPE clike OPTIONAL
      press             TYPE clike OPTIONAL
      precedingpoint    TYPE clike OPTIONAL
      succeddingpoint   TYPE clike OPTIONAL
      errormessage      TYPE clike OPTIONAL
      errormessagetitle TYPE clike OPTIONAL
      showerror         TYPE clike OPTIONAL
    RETURNING
      VALUE(result)     TYPE REF TO z2ui5_if_view.

  METHODS points
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS interact_line_chart_point
    IMPORTING
      label          TYPE clike OPTIONAL
      value          TYPE clike OPTIONAL
      secondarylabel TYPE clike OPTIONAL
      displayedvalue TYPE clike OPTIONAL
      selected       TYPE clike OPTIONAL
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS radial_micro_chart
    IMPORTING
      sice          TYPE clike OPTIONAL
      percentage    TYPE clike OPTIONAL
      press         TYPE clike OPTIONAL
      valuecolor    TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS column_list_item
    IMPORTING
      valign        TYPE clike optional " 'Middle'
      selected      TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS cells
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS header_content
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS sub_header
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS custom_data
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS badge_custom_data
    IMPORTING
      key           TYPE clike OPTIONAL
      value         TYPE clike OPTIONAL
      visible       TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS toggle_button
    IMPORTING
      text          TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      enabled       TYPE clike OPTIONAL
      press         TYPE clike OPTIONAL
      class         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS button
    IMPORTING
      text          TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      enabled       TYPE clike OPTIONAL
      press         TYPE clike OPTIONAL
      class         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS page
    IMPORTING
      title          TYPE clike OPTIONAL
      navbuttonpress TYPE clike OPTIONAL
      id             TYPE clike OPTIONAL
      class          TYPE clike OPTIONAL
        PREFERRED PARAMETER title
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS vbox
    IMPORTING
      height        TYPE clike OPTIONAL
      class         TYPE clike OPTIONAL
        PREFERRED PARAMETER class
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS hbox
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS scroll_container
    IMPORTING
      height        TYPE clike OPTIONAL
      width         TYPE clike OPTIONAL
      vertical      TYPE clike OPTIONAL
      horizontal    TYPE clike OPTIONAL
      focusable     TYPE clike OPTIONAL
        PREFERRED PARAMETER height
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS simple_form
    IMPORTING
      title         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS zz_html
    IMPORTING
      val           TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS content
    IMPORTING
      ns            TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS title
    IMPORTING
      title         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS tab_container
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS tab
    IMPORTING
      text          TYPE clike OPTIONAL
      selected      TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS overflow_toolbar
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS overflow_toolbar_button
    IMPORTING
      text          TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
      enabled       TYPE clike OPTIONAL
      press         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS toolbar_spacer
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS label
    IMPORTING
      text          TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS date_picker
    IMPORTING
      value         TYPE clike OPTIONAL
      placeholder   TYPE clike OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS time_picker
    IMPORTING
      value         TYPE clike OPTIONAL
      placeholder   TYPE clike OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS date_time_picker
    IMPORTING
      value         TYPE clike OPTIONAL
      placeholder   TYPE clike OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS link
    IMPORTING
      text          TYPE clike OPTIONAL
      href          TYPE clike OPTIONAL
      enabled       TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS list
    IMPORTING
      headertext    TYPE clike OPTIONAL
      items         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS standard_list_item
    IMPORTING
      title         TYPE clike OPTIONAL
      description   TYPE clike OPTIONAL
      icon          TYPE clike OPTIONAL
      info          TYPE clike OPTIONAL
      press         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS item
    IMPORTING
      key           TYPE clike OPTIONAL
      text          TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS segmented_button_item
    IMPORTING
      icon          TYPE clike OPTIONAL
      key           TYPE clike OPTIONAL
      text          TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS combobox
    IMPORTING
      selectedkey   TYPE clike OPTIONAL
      showclearicon TYPE clike OPTIONAL
      label         TYPE clike OPTIONAL
      items         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS grid
    IMPORTING
      class         TYPE clike OPTIONAL
      default_span  TYPE clike OPTIONAL
        PREFERRED PARAMETER default_span
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS grid_data
    IMPORTING
      span          TYPE clike OPTIONAL
        PREFERRED PARAMETER span
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS text_area
    IMPORTING
      value           TYPE clike OPTIONAL
      rows            TYPE clike OPTIONAL
      height          TYPE clike OPTIONAL
      width           TYPE clike OPTIONAL
      editable        TYPE clike OPTIONAL
      enabled         TYPE clike OPTIONAL
      growing         TYPE clike OPTIONAL
      growingmaxlines TYPE clike OPTIONAL
      id              TYPE clike OPTIONAL
        PREFERRED PARAMETER value
    RETURNING
      VALUE(result)   TYPE REF TO  z2ui5_if_view.

  METHODS range_slider
    IMPORTING
      max           TYPE clike OPTIONAL
      min           TYPE clike OPTIONAL
      step          TYPE clike OPTIONAL
      startvalue    TYPE clike OPTIONAL
      endvalue      TYPE clike OPTIONAL
      showtickmarks TYPE clike OPTIONAL
      labelinterval TYPE clike OPTIONAL
      width         TYPE clike OPTIONAL
      class         TYPE clike OPTIONAL
      id            TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS generic_tag
    IMPORTING
      arialabelledby TYPE clike OPTIONAL
      text           TYPE clike OPTIONAL
      design         TYPE clike OPTIONAL
      status         TYPE clike OPTIONAL
      class          TYPE clike OPTIONAL
    RETURNING
      VALUE(result)  TYPE REF TO z2ui5_if_view.

  METHODS object_number
    IMPORTING
      state         TYPE clike OPTIONAL
      emphasized    TYPE clike OPTIONAL
      number        TYPE clike OPTIONAL
      unit          TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS switch
    IMPORTING
      state         TYPE clike OPTIONAL
      customtexton  TYPE clike OPTIONAL
      customtextoff TYPE clike OPTIONAL
      enabled       TYPE clike OPTIONAL
      type          TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS step_input
    IMPORTING
      value         TYPE clike
      min           TYPE clike
      max           TYPE clike
      step          TYPE clike
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS progress_indicator
    IMPORTING
      percentvalue  TYPE clike OPTIONAL
      displayvalue  TYPE clike OPTIONAL
      showvalue     TYPE clike OPTIONAL
      state         TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS segmented_button
    IMPORTING
      selected_key     TYPE clike
      selection_change TYPE clike OPTIONAL
    RETURNING
      VALUE(result)    TYPE REF TO z2ui5_if_view.

  METHODS checkbox
    IMPORTING
      text          TYPE clike OPTIONAL
      selected      TYPE clike OPTIONAL
      enabled       TYPE clike OPTIONAL
        PREFERRED PARAMETER selected
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS header_toolbar
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS text
    IMPORTING
      text          TYPE clike OPTIONAL
      class         TYPE clike OPTIONAL
        PREFERRED PARAMETER text
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

  METHODS formatted_text
    IMPORTING
      htmltext      TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS _generic
    IMPORTING
      name          TYPE clike
      ns            TYPE clike OPTIONAL
      t_prop        TYPE ty_t_name_value OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO z2ui5_if_view.

  METHODS zz_file_uploader
    IMPORTING
      value         TYPE clike OPTIONAL
      path          TYPE clike OPTIONAL
      placeholder   TYPE clike OPTIONAL
      upload        TYPE clike OPTIONAL
    RETURNING
      VALUE(result) TYPE REF TO  z2ui5_if_view.

ENDINTERFACE.
