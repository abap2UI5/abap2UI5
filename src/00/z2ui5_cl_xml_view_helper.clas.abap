CLASS z2ui5_cl_xml_view_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.
    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

    DATA m_name  TYPE string.
    DATA m_ns    TYPE string.
    DATA mt_prop TYPE ty_t_name_value.

    DATA m_root    TYPE REF TO z2ui5_cl_xml_view_helper.
    DATA m_last    TYPE REF TO z2ui5_cl_xml_view_helper.
    DATA m_parent  TYPE REF TO z2ui5_cl_xml_view_helper.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view_helper WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        ns            TYPE string_table OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    CLASS-METHODS hlp_get_source_code_url
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
        get           TYPE z2ui5_if_client=>ty_s_get
      RETURNING
        VALUE(result) TYPE string.

    METHODS constructor
      IMPORTING
        ns TYPE string_table OPTIONAL.

    METHODS horizontal_layout
      IMPORTING
        class         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS Dynamic_Page
      IMPORTING
        headerExpanded           TYPE clike OPTIONAL
        toggleHeaderOnTitleClick TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS Dynamic_Page_Title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.


    METHODS Dynamic_Page_Header
      IMPORTING
        pinnable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS Illustrated_Message
      IMPORTING
        enableVerticalResponsiveness TYPE clike OPTIONAL
        illustrationType             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS additional_Content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS flex_box
      IMPORTING
        class          TYPE clike OPTIONAL
        rendertype     TYPE clike OPTIONAL
        width          TYPE clike OPTIONAL
        fitContainer   TYPE clike OPTIONAL
        height         TYPE clike OPTIONAL
        alignitems     TYPE clike OPTIONAL
        justifycontent TYPE clike OPTIONAL
        wrap           TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS popover
      IMPORTING
        title         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        placement     TYPE clike OPTIONAL
        initialFocus  TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS list_item
      IMPORTING
        text           TYPE clike OPTIONAL
        additionaltext TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

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
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS message_strip
      IMPORTING
        text          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        showicon      TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS footer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS message_page
      IMPORTING
        show_header         TYPE clike OPTIONAL
        text                TYPE clike OPTIONAL
        enableformattedtext TYPE clike OPTIONAL
        description         TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS object_page_layout
      IMPORTING
        showTitleInHeaderContent TYPE clike OPTIONAL
        showEditHeaderButton     TYPE clike OPTIONAL
        editHeaderButtonPress    TYPE clike OPTIONAL
        upperCaseAnchorBar       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS Object_Page_Dyn_Header_Title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS expanded_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS snapped_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS expanded_content
      IMPORTING
        ns            TYPE clike DEFAULT `uxap`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS snapped_content
      IMPORTING
        ns            TYPE clike DEFAULT `uxap`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS snapped_Title_On_Mobile
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS navigation_actions
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS actions
      IMPORTING
        ns            TYPE clike DEFAULT `uxap`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS avatar
      IMPORTING
        src           TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        displaysize   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS Object_Page_Section
      IMPORTING
        titleUppercase TYPE clike OPTIONAL
        title          TYPE clike OPTIONAL
        importance     TYPE clike OPTIONAL
        id             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS heading
      IMPORTING
        ns            TYPE clike DEFAULT `uxap`
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS sub_sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS Object_page_Sub_Section
      IMPORTING
        id            TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS shell
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.
    METHODS blocks
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS layout_data
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS flex_item_data
      IMPORTING
        growfactor       TYPE clike OPTIONAL
        basesize         TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        styleclass       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS code_editor
      IMPORTING
        value         TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS suggestion_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS vertical_layout
      IMPORTING
        class         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS multi_input
      IMPORTING
        showclearicon   TYPE clike OPTIONAL
        showValueHelp   TYPE clike OPTIONAL
        suggestionitems TYPE clike OPTIONAL
        width           TYPE clike OPTIONAL
        tokens          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS tokens
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS token
      IMPORTING
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

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
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view_helper.

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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS buttons
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS get_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS get_parent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS get
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS get_child
      IMPORTING
        index         TYPE i DEFAULT 1
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS column
      IMPORTING
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS interact_donut_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
        displayedsegments TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS segments
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS interact_donut_chart_segment
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS interact_bar_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        labelwidth        TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS bars
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS interact_bar_chart_bar
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

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
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS points
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS interact_line_chart_point
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        secondarylabel TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS radial_micro_chart
      IMPORTING
        sice          TYPE clike OPTIONAL
        percentage    TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        valuecolor    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS column_list_item
      IMPORTING
        valign        TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS cells
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS header_content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS sub_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS custom_data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS badge_custom_data
      IMPORTING
        key           TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS toggle_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        id            TYPE clike OPTIONAL
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS page
      IMPORTING
        title          TYPE clike OPTIONAL
        navbuttonpress TYPE clike OPTIONAL
        shownavbutton  TYPE clike OPTIONAL
        id             TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
        ns             TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS vbox
      IMPORTING
        height        TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
          PREFERRED PARAMETER class
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS hbox
      IMPORTING
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS scroll_container
      IMPORTING
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        vertical      TYPE clike OPTIONAL
        horizontal    TYPE clike OPTIONAL
        focusable     TYPE clike OPTIONAL
          PREFERRED PARAMETER height
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS simple_form
      IMPORTING
        title         TYPE clike OPTIONAL
        layout        TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS zz_plain
      IMPORTING
        val           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS title
      IMPORTING
        ns            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        wrapping      TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS tab_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS tab
      IMPORTING
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS overflow_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS overflow_toolbar_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS toolbar_spacer
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS label
      IMPORTING
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS image
      IMPORTING
        src           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS date_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS time_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS date_time_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS link
      IMPORTING
        text          TYPE clike OPTIONAL
        href          TYPE clike OPTIONAL
        target        TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS list
      IMPORTING
        headertext    TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS standard_list_item
      IMPORTING
        title         TYPE clike OPTIONAL
        description   TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        info          TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS item
      IMPORTING
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS segmented_button_item
      IMPORTING
        icon          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS combobox
      IMPORTING
        selectedkey   TYPE clike OPTIONAL
        showclearicon TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS grid
      IMPORTING
        class         TYPE clike OPTIONAL
        default_span  TYPE clike OPTIONAL
          PREFERRED PARAMETER default_span
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS grid_data
      IMPORTING
        span          TYPE clike OPTIONAL
          PREFERRED PARAMETER span
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

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
        VALUE(result)   TYPE REF TO  z2ui5_cl_xml_view_helper.

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
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS generic_tag
      IMPORTING
        arialabelledby TYPE clike OPTIONAL
        text           TYPE clike OPTIONAL
        design         TYPE clike OPTIONAL
        status         TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS object_attribute
      IMPORTING
        title         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS object_number
      IMPORTING
        state         TYPE clike OPTIONAL
        emphasized    TYPE clike OPTIONAL
        number        TYPE clike OPTIONAL
        unit          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS switch
      IMPORTING
        state         TYPE clike OPTIONAL
        customtexton  TYPE clike OPTIONAL
        customtextoff TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS step_input
      IMPORTING
        value         TYPE clike
        min           TYPE clike
        max           TYPE clike
        step          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS progress_indicator
      IMPORTING
        percentvalue  TYPE clike OPTIONAL
        displayvalue  TYPE clike OPTIONAL
        showvalue     TYPE clike OPTIONAL
        state         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS segmented_button
      IMPORTING
        selected_key     TYPE clike
        selection_change TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS checkbox
      IMPORTING
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
          PREFERRED PARAMETER selected
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS header_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS text
      IMPORTING
        text          TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        ns            TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS formatted_text
      IMPORTING
        htmltext      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS _generic
      IMPORTING
        name          TYPE clike
        ns            TYPE clike OPTIONAL
        t_prop        TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view_helper.

    METHODS zz_file_uploader
      IMPORTING
        value         TYPE clike OPTIONAL
        path          TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
        upload        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view_helper.

    METHODS xml_get
      RETURNING
        VALUE(result) TYPE string.


  PROTECTED SECTION.

    METHODS xml_get_begin
      RETURNING
        VALUE(result) TYPE string.

    DATA mt_ns TYPE string_table.

  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_xml_view_helper IMPLEMENTATION.


  METHOD constructor.

    IF ns IS INITIAL.

      mt_ns = VALUE string_table(
      ( `xmlns="sap.m"` )
      ( `xmlns:z2ui5="z2ui5"` )
      ( `xmlns:core="sap.ui.core"` )
      ( `xmlns:mvc="sap.ui.core.mvc"` )
      ( `xmlns:l="sap.ui.layout"` )
      ( `xmlns:f="sap.f"` )
      ( `xmlns:form="sap.ui.layout.form"` )
      ( `xmlns:editor="sap.ui.codeeditor"` )
      ( `xmlns:mchart="sap.suite.ui.microchart"` )
      ( `xmlns:webc="sap.ui.webc.main"` )
      ( `xmlns:uxap="sap.uxap"` )
      ( `xmlns:sap="sap"` )
      ( `xmlns:text="sap.ui.richtexteditor"` )
      ( `xmlns:html="http://www.w3.org/1999/xhtml"` )
       ).

    ELSE.
      mt_ns = ns.
    ENDIF.

  ENDMETHOD.


  METHOD factory.

    DATA(lo_tree) = NEW z2ui5_cl_xml_view_helper( ns = ns ).
    lo_tree->m_root = lo_tree.
    lo_tree->m_parent = lo_tree.
    result = lo_tree.

  ENDMETHOD.


  METHOD xml_get_begin.

    result = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" `.
    LOOP AT mt_ns REFERENCE INTO DATA(lr_ns).
      result = result && ` ` && lr_ns->* && ` `.
    ENDLOOP.
    result = result && `>`.

  ENDMETHOD.


  METHOD header.

    result = _generic(
        name   = `header`
        ns     = `f`
      ).

  ENDMETHOD.

  METHOD navigation_actions.

    result = _generic(
        name   = `navigationActions`
        ns     = `f`
      ).

  ENDMETHOD.


  METHOD actions.

    result = _generic(
        name   = `actions`
        ns     = ns
      ).

  ENDMETHOD.


  METHOD avatar.

    result = me.
    _generic(
        name   = `Avatar`
        t_prop = VALUE #(
            ( n = `src`         v = src )
            ( n = `class`       v = class )
            ( n = `displaysize` v = displaysize )
    ) ).

  ENDMETHOD.


  METHOD badge_custom_data.

    result = me.
    _generic(
       name   = `BadgeCustomData`
       t_prop = VALUE #(
          ( n = `key`      v = key )
          ( n = `value`    v = value )
          ( n = `visible`  v = _=>get_json_boolean( visible ) )
       ) ).

  ENDMETHOD.


  METHOD bars.

    result = _generic(
        name = `bars`
        ns   = `mchart` ).

  ENDMETHOD.


  METHOD blocks.

    result = _generic(
        name   = `blocks`
        ns     = `uxap`
     ).

  ENDMETHOD.


  METHOD button.

    result = me.
    _generic(
       name   = `Button`
       ns     = ns
       t_prop = VALUE #(
          ( n = `press`   v = press )
          ( n = `text`    v = text )
          ( n = `enabled` v = _=>get_json_boolean( enabled ) )
          ( n = `icon`    v = icon )
          ( n = `type`    v = type )
          ( n = `id`   v = id )
          ( n = `class`   v = class )
       ) ).

  ENDMETHOD.


  METHOD buttons.

    result = _generic( `buttons` ).

  ENDMETHOD.


  METHOD cells.

    result = _generic( `cells` ).

  ENDMETHOD.


  METHOD checkbox.

    result = me.
    _generic(
       name  = `CheckBox`
       t_prop = VALUE #(
          ( n = `text`     v = text )
          ( n = `selected` v = selected )
          ( n = `enabled`  v = _=>get_json_boolean( enabled ) )
      ) ).

  ENDMETHOD.


  METHOD code_editor.

    result = me.
    _generic(
        name  = `CodeEditor`
        ns = `editor`
        t_prop = VALUE #(
            ( n = `value`   v = value )
            ( n = `type`    v = type )
            ( n = `editable`   v = _=>get_json_boolean( editable ) )
            ( n = `height` v = height )
            ( n = `width`  v = width )
       ) ).

  ENDMETHOD.


  METHOD column.

    result = _generic(
        name  = `Column`
          t_prop = VALUE #( ( n = `width` v = width ) )
     ).

  ENDMETHOD.


  METHOD columns.

    result = _generic( `columns` ).

  ENDMETHOD.


  METHOD column_list_item.

    result = _generic(
        name = `ColumnListItem`
        t_prop = VALUE #( ( n = `vAlign`   v = valign )
                          ( n = `selected` v = selected )
       ) ).

  ENDMETHOD.


  METHOD combobox.

    result = _generic(
       name  = `ComboBox`
       t_prop = VALUE #(
          (  n = `showClearIcon` v = _=>get_json_boolean( showclearicon ) )
          (  n = `selectedKey`   v = selectedkey )
          (  n = `items`         v = items )
          (  n = `label`         v = label )
      ) ).

  ENDMETHOD.


  METHOD content.

    result = _generic( ns = ns name = `content` ).

  ENDMETHOD.


  METHOD custom_data.

    result = _generic(
       `customData`
        ).

  ENDMETHOD.


  METHOD date_picker.

    result = me.
    _generic(
      name       = `DatePicker`
      t_prop = VALUE #(
          ( n = `value` v = value )
          ( n = `placeholder` v = placeholder )
       ) ).

  ENDMETHOD.


  METHOD date_time_picker.

    result = me.
    _generic(
        name  = `DateTimePicker`
        t_prop = VALUE #(
            ( n = `value` v = value )
            ( n = `placeholder`  v = placeholder )
         ) ).

  ENDMETHOD.


  METHOD dialog.

    result = _generic(
         name = `Dialog`
        t_prop = VALUE #(
          ( n = `title`  v = title )
          ( n = `icon`  v = icon )
          ( n = `stretch`  v = stretch )
          ( n = `showHeader`  v = showheader )
          ( n = `contentWidth`  v = contentwidth )
          ( n = `contentHeight`  v = contentheight )
          ) ).

  ENDMETHOD.


  METHOD expanded_content.

    result = _generic(
         name   = `expandedContent`
         ns     = ns
      ).

  ENDMETHOD.


  METHOD expanded_heading.

    result = _generic(
        name   = `expandedHeading`
        ns     = `uxap`
    ).

  ENDMETHOD.


  METHOD flex_box.

    result = _generic(
          name   = `FlexBox`
          t_prop = VALUE #(
                      ( n = `class`  v = class )
                      ( n = `renderType`  v = rendertype )
                      ( n = `width`  v = width )
                      ( n = `height`  v = height )
                      ( n = `alignItems`  v = alignitems )
                      ( n = `fitContainer`  v = _=>get_json_boolean( fitContainer ) )
                      ( n = `justifyContent`  v = justifycontent )
                      ( n = `wrap`  v = wrap )
        ) ).


  ENDMETHOD.


  METHOD flex_item_data.

    result = me.

    _generic(
          name = `FlexItemData`
        t_prop = VALUE #(
            ( n = `growFactor`  v = growfactor )
            ( n = `baseSize`   v = basesize )
            ( n = `backgroundDesign`   v = backgrounddesign )
            ( n = `styleClass`   v = styleclass )
        ) ).

  ENDMETHOD.


  METHOD footer.

    result = _generic( `footer` ).

  ENDMETHOD.


  METHOD formatted_text.

    result = me.
    _generic(
       name   = `FormattedText`
       t_prop = VALUE #(
          ( n = `htmlText`   v = htmltext )
       ) ).

  ENDMETHOD.


  METHOD generic_tag.

    result = _generic(
           name  = `GenericTag`
           t_prop = VALUE #(
              ( n = `ariaLabelledBy`           v = arialabelledby )
              ( n = `class`        v = class )
              ( n = `design`          v = design )
              ( n = `status`  v = status )
              ( n = `text`   v = text )
       ) ).

  ENDMETHOD.


  METHOD get.

    result = m_root->m_last.

  ENDMETHOD.


  METHOD get_child.

    result = t_child[ index ].

  ENDMETHOD.


  METHOD get_parent.
    result = m_parent.
  ENDMETHOD.


  METHOD get_root.

    result = m_root.

  ENDMETHOD.


  METHOD grid.

    result = _generic(
        name = `Grid`
        ns   = `l`
        t_prop = VALUE #(
            ( n = `defaultSpan` v = default_span )
            ( n = `class`       v = class )
            ) ).

  ENDMETHOD.


  METHOD grid_data.

    result = me.
    _generic(
           name = `GridData`
           ns = `l`
        t_prop = VALUE #(
            ( n = `span`  v = span )
        ) ).

  ENDMETHOD.


  METHOD hbox.

    result = _generic(
          name   = `HBox`
          t_prop = VALUE #(
            ( n = `class` v = class )
        ) ).

  ENDMETHOD.


  METHOD header_content.

    result = _generic(
        name = `headerContent`
        ns   = ns
         ).

  ENDMETHOD.


  METHOD header_title.

    result = _generic(
        name   = `headerTitle`
        ns     = `uxap`
     ).

  ENDMETHOD.


  METHOD header_toolbar.

    result = _generic( `headerToolbar` ).

  ENDMETHOD.


  METHOD heading.

    result = me.
    result = _generic(
        name   = `heading`
        ns     = ns
    ).

  ENDMETHOD.


  METHOD horizontal_layout.

    result = _generic(
        name   = `HorizontalLayout`
        ns     = `l`
        t_prop = VALUE #(
                     ( n = `class`  v = class )
                     ( n = `width`  v = width )
        ) ).

  ENDMETHOD.


  METHOD image.

    result = me.
    _generic(
       name  = `Image`
       t_prop = VALUE #(
           ( n = `src` v = src )
        ) ).

  ENDMETHOD.


  METHOD input.

    result = me.
    _generic(
       name   = `Input`
       t_prop = VALUE #(
           ( n = `id`               v = id )
           ( n = `placeholder`      v = placeholder )
           ( n = `type`             v = type )
           ( n = `showClearIcon`    v = _=>get_json_boolean( showclearicon ) )
           ( n = `description`      v = description )
           ( n = `editable`         v = _=>get_json_boolean( editable ) )
           ( n = `enabled`         v = _=>get_json_boolean( enabled ) )
           ( n = `valueState`       v = valuestate )
           ( n = `valueStateText`   v = valuestatetext )
           ( n = `value`            v = value )
           ( n = `suggestionItems`  v = suggestionitems )
           ( n = `showSuggestion`   v = _=>get_json_boolean( showsuggestion ) )
           ( n = `valueHelpRequest` v = valuehelprequest )
           ( n = `showValueHelp`    v = _=>get_json_boolean( showvaluehelp ) )
        ) ).

  ENDMETHOD.


  METHOD interact_bar_chart.

    result = _generic(
        name = `InteractiveBarChart`
        ns   = `mchart`
        t_prop = VALUE #(
             ( n = `selectionChanged`  v = selectionchanged )
             ( n = `showError`         v = showerror )
             ( n = `press`             v = press )
             ( n = `labelWidth`        v = labelwidth )
             ( n = `errorMessageTitle` v = errormessagetitle )
             ( n = `errorMessage`      v = errormessage )
    ) ).

  ENDMETHOD.


  METHOD interact_bar_chart_bar.

    result = _generic(
         name = `InteractiveBarChartBar`
         ns = `mchart`
         t_prop = VALUE #(
             ( n = `label`          v = label )
             ( n = `displayedValue` v = displayedvalue )
             ( n = `value`          v = value )
             ( n = `selected`       v = selected )
    ) ).

  ENDMETHOD.


  METHOD interact_donut_chart.

    result = _generic(
         name = `InteractiveDonutChart`
         ns   = `mchart`
         t_prop = VALUE #(
             ( n = `selectionChanged`  v = selectionchanged )
             ( n = `showError`         v = _=>get_json_boolean( showerror ) )
             ( n = `errorMessageTitle` v = errormessagetitle )
             ( n = `errorMessage`      v = errormessage )
             ( n = `displayedSegments` v = displayedsegments )
             ( n = `press`             v = press )
    ) ).

  ENDMETHOD.


  METHOD interact_donut_chart_segment.

    result = _generic(
         name = `InteractiveDonutChartSegment`
         ns   = `mchart`
         t_prop = VALUE #(
             ( n = `label`          v = label )
             ( n = `displayedValue` v = displayedvalue )
             ( n = `value`          v = value )
             ( n = `selected`       v = selected )
    ) ).

  ENDMETHOD.


  METHOD interact_line_chart.

    result = _generic(
         name = `InteractiveLineChart`
         ns = `mchart`
         t_prop = VALUE #(
             ( n = `selectionChanged`  v = selectionchanged )
             ( n = `showError`         v = _=>get_json_boolean( showerror ) )
             ( n = `press`             v = press )
             ( n = `errorMessageTitle` v = errormessagetitle )
             ( n = `errorMessage`      v = errormessage )
             ( n = `precedingPoint`    v = precedingpoint )
             ( n = `succeedingPoint`   v = succeddingpoint )
    ) ).

  ENDMETHOD.


  METHOD interact_line_chart_point.

    result = _generic(
         name   = `InteractiveLineChartPoint`
         ns     = `mchart`
         t_prop = VALUE #(
             ( n = `label`          v = label )
             ( n = `secondaryLabel` v = secondarylabel )
             ( n = `value`          v = value )
             ( n = `displayedValue` v = displayedvalue )
             ( n = `selected`       v = _=>get_json_boolean( selected ) )
    ) ).

  ENDMETHOD.


  METHOD item.

    result = me.
    _generic(
       name = `Item`
       ns = `core`
       t_prop = VALUE #(
           ( n = `key`  v = key )
           ( n = `text` v = text )
      ) ).

  ENDMETHOD.


  METHOD items.

    result = _generic( `items` ).

  ENDMETHOD.


  METHOD label.

    result = me.
    _generic(
       name  = `Label`
       t_prop = VALUE #(
           ( n = `text` v = text )
        ) ).

  ENDMETHOD.


  METHOD layout_data.

    result = _generic(
            ns = ns
           name = `layoutData`
       ).

  ENDMETHOD.


  METHOD link.

    result = me.
    _generic(
     name  = `Link`
     ns    = ns
       t_prop = VALUE #(
         ( n = `text`    v = text )
         ( n = `target`  v = target )
         ( n = `href`    v = href )
         ( n = `enabled` v = _=>get_json_boolean( enabled ) )
       ) ).

  ENDMETHOD.


  METHOD list.

    result = _generic(
        name = `List`
        t_prop = VALUE #(
          ( n = `headerText` v = headertext )
          ( n = `items` v = items )
      ) ).

  ENDMETHOD.


  METHOD list_item.

    result = me.
    _generic(
        name   = `ListItem`
        ns     = `core`
        t_prop = VALUE #(
            ( n = `text` v = text )
            ( n = `additionalText` v = additionaltext ) ) ).

  ENDMETHOD.


  METHOD message_page.

    result = _generic(
        name   = `MessagePage`
        t_prop = VALUE #(
           ( n = `showHeader` v = _=>get_json_boolean( show_header ) )
           ( n = `description` v = description )
           ( n = `icon` v = icon )
           ( n = `text` v = text )
           ( n = `enableFormattedText` v = _=>get_json_boolean( enableformattedtext ) )
      ) ).

  ENDMETHOD.


  METHOD message_strip.

    result = me.
    _generic(
        name   = `MessageStrip`
        t_prop = VALUE #(
           ( n = `text` v = text )
           ( n = `type` v = type )
           ( n = `showIcon` v = _=>get_json_boolean( showicon ) )
           ( n = `class` v = class )
      ) ).

  ENDMETHOD.


  METHOD multi_input.

    result = _generic(
        name   = `MultiInput`
        t_prop = VALUE #(
            ( n = `tokens` v = tokens )
            ( n = `showClearIcon` v = _=>get_json_boolean( showclearicon ) )
            ( n = `showValueHelp` v = _=>get_json_boolean( showvaluehelp ) )
            ( n = `suggestionItems` v = suggestionitems )
            ( n = `width` v = width )
    ) ).

  ENDMETHOD.


  METHOD object_number.

    result = me.
    _generic(
        name  = `ObjectNumber`
        t_prop = VALUE #(
           ( n = `emphasized`           v = _=>get_json_boolean( emphasized ) )
           ( n = `number`        v = number )
           ( n = `state`          v = state )
           ( n = `unit`  v = unit )
    ) ).

  ENDMETHOD.


  METHOD object_page_dyn_header_title.

    result = _generic(
        name   = `ObjectPageDynamicHeaderTitle`
        ns     = `uxap`
    ).

  ENDMETHOD.


  METHOD object_page_layout.

    result = _generic(
        name   = `ObjectPageLayout`
        ns     = `uxap`
        t_prop = VALUE #(
            ( n = `showTitleInHeaderContent`  v = _=>get_json_boolean( showTitleInHeaderContent ) )
            ( n = `showEditHeaderButton`      v = _=>get_json_boolean( showEditHeaderButton ) )
            ( n = `editHeaderButtonPress`     v = editHeaderButtonPress )
            ( n = `upperCaseAnchorBar`        v = upperCaseAnchorBar )
    ) ).

  ENDMETHOD.


  METHOD object_page_section.

    result = _generic(
        name   = `ObjectPageSection`
        ns     = `uxap`
        t_prop = VALUE #(
            ( n = `titleUppercase`  v = _=>get_json_boolean( titleUppercase ) )
            ( n = `title`           v = title )
            ( n = `id`              v = id )
            ( n = `importance`      v = importance )
    ) ).

  ENDMETHOD.


  METHOD object_page_sub_section.

    result = _generic(
        name   = `ObjectPageSubSection`
        ns     = `uxap`
      t_prop = VALUE #(
            ( n = `id`    v = id )
            ( n = `title` v = title )
    ) ).

  ENDMETHOD.


  METHOD overflow_toolbar.

    result = _generic( `OverflowToolbar` ).

  ENDMETHOD.


  METHOD overflow_toolbar_button.

    result = me.
    _generic(
       name   = `OverflowToolbarButton`
       t_prop = VALUE #(
          ( n = `press`   v = press )
          ( n = `text`    v = text )
          ( n = `enabled` v = _=>get_json_boolean( enabled ) )
          ( n = `icon`    v = icon )
          ( n = `type`    v = type )
          ( n = `tooltip` v = tooltip )
       ) ).

  ENDMETHOD.


  METHOD page.

    result = _generic(
        name   = `Page`
        ns     = ns
         t_prop = VALUE #(
             ( n = `title` v = title )
             ( n = `showNavButton`  v = _=>get_json_boolean( shownavbutton ) )
             ( n = `navButtonPress` v = navbuttonpress )
             ( n = `class` v = class )
             ( n = `id` v = id )
         ) ).

  ENDMETHOD.


  METHOD points.

    result = _generic(
         name = `points`
         ns   = `mchart` ).

  ENDMETHOD.


  METHOD popover.

    result = _generic(
          name   = `Popover`
          t_prop = VALUE #(
                      ( n = `title`  v = title )
                      ( n = `class`  v = class )
                      ( n = `placement`  v = placement )
                      ( n = `initialFocus`  v = initialFocus )
        ) ).

  ENDMETHOD.


  METHOD progress_indicator.

    result = me.
    _generic(
         name  = `ProgressIndicator`
         t_prop = VALUE #(
            ( n = `percentValue` v = percentvalue )
            ( n = `displayValue` v = displayvalue )
            ( n = `showValue`    v = _=>get_json_boolean( showvalue ) )
            ( n = `state`        v = state )
     ) ).

  ENDMETHOD.


  METHOD radial_micro_chart.

    result = me.
    _generic(
        name   = `RadialMicroChart`
        ns     = `mchart`
        t_prop = VALUE #(
            ( n = `percentage`  v = percentage )
            ( n = `press`       v = press )
            ( n = `sice`        v = sice )
            ( n = `valueColor`  v = valuecolor )
    ) ).

  ENDMETHOD.


  METHOD range_slider.

    result = me.
    _generic(
          name  = `RangeSlider`
          ns    = `webc`
          t_prop = VALUE #(
             ( n = `class`           v = class )
             ( n = `endValue`        v = endvalue )
             ( n = `id`          v = id )
             ( n = `labelInterval`  v = labelinterval )
             ( n = `max`   v = max )
             ( n = `min`   v = min )
             ( n = `showTickmarks`   v = _=>get_json_boolean( showtickmarks ) )
             ( n = `startValue`   v = startvalue )
             ( n = `step`   v = step )
             ( n = `width`   v = width )
      ) ).

  ENDMETHOD.


  METHOD scroll_container.

    result = _generic(
        name = `ScrollContainer`
        t_prop = VALUE #(
          ( n = `height`      v = height )
          ( n = `width`       v = width )
          ( n = `vertical`    v = _=>get_json_boolean( vertical ) )
          ( n = `horizontal`  v = _=>get_json_boolean( horizontal ) )
          ( n = `focusable`   v = _=>get_json_boolean( focusable  ) )
       ) ).

  ENDMETHOD.


  METHOD sections.

    result = _generic(
        name   = `sections`
        ns     = `uxap`
     ).

  ENDMETHOD.


  METHOD segmented_button.

    result = _generic(
       name  = `SegmentedButton`
       t_prop = VALUE #(
        ( n = `selectedKey` v = selected_key )
        ( n = `selectionChange` v = selection_change )
      ) ).

  ENDMETHOD.


  METHOD segmented_button_item.

    result = me.
    _generic(
        name = `SegmentedButtonItem`
        t_prop = VALUE #(
            ( n = `icon`  v = icon )
            ( n = `key`   v = key )
            ( n = `text`  v = text )
      ) ).

  ENDMETHOD.


  METHOD segments.

    result = _generic(
        name = `segments`
        ns   = `mchart` ).

  ENDMETHOD.


  METHOD simple_form.

    result = _generic(
      name   = `SimpleForm`
      ns     = `form`
      t_prop = VALUE #(
        ( n = `title`    v = title )
        ( n = `layout`   v = layout )
        ( n = `editable` v = _=>get_json_boolean( editable ) )
      ) ).

  ENDMETHOD.


  METHOD snapped_content.

    result = _generic(
         name   = `snappedContent`
         ns     = ns
      ).

  ENDMETHOD.


  METHOD snapped_heading.

    result = me.
    result = _generic(
        name   = `snappedHeading`
        ns     = `uxap`
     ).

  ENDMETHOD.


  METHOD snapped_title_on_mobile.

    result = _generic(
         name   = `snappedTitleOnMobile`
         ns     = `uxap`
      ).

  ENDMETHOD.


  METHOD standard_list_item.

    result = me.
    _generic(
        name = `StandardListItem`
        t_prop = VALUE #(
            ( n = `title`       v = title )
            ( n = `description` v = description )
            ( n = `icon`        v = icon )
            ( n = `info`        v = info )
            ( n = `press`       v = press )
       ) ).

  ENDMETHOD.


  METHOD step_input.

    result = me.
    _generic(
         name  = `StepInput`
         t_prop = VALUE #(
            ( n = `max`  v = max )
            ( n = `min`  v = min )
            ( n = `step` v = step )
            ( n = `value` v = value )
     ) ).

  ENDMETHOD.


  METHOD sub_header.

    result = _generic( `subHeader` ).

  ENDMETHOD.


  METHOD sub_sections.

    result = me.
    result = _generic(
        name   = `subSections`
        ns     = `uxap`
     ).

  ENDMETHOD.


  METHOD suggestion_items.

    result = _generic( `suggestionItems` ).

  ENDMETHOD.


  METHOD switch.

    result = me.
    _generic(
          name  = `Switch`
          t_prop = VALUE #(
             ( n = `type`           v = type )
             ( n = `enabled`        v = _=>get_json_boolean( enabled ) )
             ( n = `state`          v = state )
             ( n = `customTextOff`  v = customtextoff )
             ( n = `customTextOn`   v = customtexton )
      ) ).

  ENDMETHOD.


  METHOD tab.

    result = _generic(
         name = `Tab`
         ns = `webc`
         t_prop = VALUE #(
             ( n = `text`     v = text )
             ( n = `selected` v = selected )
         ) ).

  ENDMETHOD.


  METHOD table.

    result = _generic(
        name  = `Table`
        t_prop = VALUE #(
           ( n = `items`            v = items )
           ( n = `headerText`       v = headertext )
           ( n = `growing`          v = growing )
           ( n = `growingThreshold` v = growingthreshold )
           ( n = `growingScrollToLoad` v = growingscrolltoload )
           ( n = `sticky`           v = sticky )
           ( n = `mode`             v = mode )
           ( n = `width`            v = width )
     ) ).

  ENDMETHOD.


  METHOD tab_container.

    result = _generic(
        name = `TabContainer`
        ns   = `webc` ).

  ENDMETHOD.

  METHOD text.

    result = me.
    _generic(
      name  = `Text`
      ns    = ns
      t_prop = VALUE #(
        ( n = `text`  v = text )
        ( n = `class` v = class )
        ) ).

  ENDMETHOD.


  METHOD text_area.

    result = me.
    _generic(
          name  = `TextArea`
            t_prop = VALUE #(
              ( n = `value` v = value )
              ( n = `rows` v = rows )
              ( n = `height` v = height )
              ( n = `width` v = width )
              ( n = `editable` v = _=>get_json_boolean( editable ) )
              ( n = `enabled` v = _=>get_json_boolean( enabled ) )
              ( n = `id` v = id )
              ( n = `growing` v = _=>get_json_boolean( growing ) )
              ( n = `growingMaxLines` v = growingmaxlines )
       ) ).

  ENDMETHOD.


  METHOD time_picker.

    result = me.
    _generic(
     name   = `TimePicker`
     t_prop = VALUE #(
          ( n = `value` v = value )
          ( n = `placeholder`  v = placeholder )
      ) ).

  ENDMETHOD.


  METHOD title.

    DATA(lv_name) = COND #( WHEN ns = 'f' THEN 'title' ELSE `Title` ).

    result = me.
    _generic(
         ns = ns
         name  = lv_name
         t_prop = VALUE #(
             ( n = `text`     v = text )
             ( n = `wrapping` v = _=>get_json_boolean( wrapping ) )
      ) ).

  ENDMETHOD.


  METHOD toggle_button.

    result = me.
    _generic(
       name   = `ToggleButton`
       t_prop = VALUE #(
          ( n = `press`   v = press )
          ( n = `text`    v = text )
          ( n = `enabled` v = _=>get_json_boolean( enabled ) )
          ( n = `icon`    v = icon )
          ( n = `type`    v = type )
          ( n = `class`   v = class )
       ) ).

  ENDMETHOD.


  METHOD token.

    result = me.
    _generic(
        name   = `Token`
        t_prop = VALUE #(
            ( n = `key`      v = key )
            ( n = `text`     v = text )
            ( n = `selected` v = selected )
            ( n = `visible`  v = visible )
    ) ).

  ENDMETHOD.


  METHOD tokens.

    result = _generic( `tokens` ).

  ENDMETHOD.


  METHOD toolbar_spacer.

    result = me.
    _generic(
        name = `ToolbarSpacer`
        ns   = ns
        ).

  ENDMETHOD.


  METHOD vbox.

    result = _generic(
         name   = `VBox`
         t_prop = VALUE #(
            ( n = `height` v = height )
            ( n = `class`  v = class )
         ) ).

  ENDMETHOD.


  METHOD vertical_layout.

    result = _generic(
        name   = `VerticalLayout`
        ns     = `l`
        t_prop = VALUE #(
                     ( n = `class`  v = class )
                     ( n = `width`  v = width )
        ) ).

  ENDMETHOD.


  METHOD xml_get.

    "case - root
    IF me = m_root.

      IF t_child IS INITIAL.
        RETURN.
      ENDIF.

      result = xml_get_begin(  ).

      LOOP AT t_child INTO DATA(lr_child).
        result = result && CAST z2ui5_cl_xml_view_helper( lr_child )->xml_get( ).
      ENDLOOP.

      result = result &&  `</mvc:View>`.
      RETURN.
    ENDIF.

    "case - normal
    CASE m_name.
      WHEN `ZZHTML`.
        result = mt_prop[ n = `VALUE` ]-v.
        RETURN.
      WHEN `ZZPLAIN`.
        result = mt_prop[ n = `VALUE` ]-v.
        RETURN.
    ENDCASE.

    DATA(lv_tmp2) = COND #( WHEN m_ns <> `` THEN |{ m_ns }:| ).
    DATA(lv_tmp3) = REDUCE #( INIT val = `` FOR row IN mt_prop WHERE ( v <> `` )
                          NEXT val = |{ val } { row-n }="{ escape( val = COND string( WHEN row-v = abap_true THEN `true` ELSE row-v ) format = cl_abap_format=>e_xml_attr ) }" \n | ).

    result = |{ result } <{ lv_tmp2 }{ m_name } \n { lv_tmp3 }|.

    IF t_child IS INITIAL.
      result = |{ result }/>|.
      RETURN.
    ENDIF.

    result = |{ result }>|.

    LOOP AT t_child INTO lr_child.
      result = result && CAST z2ui5_cl_xml_view_helper( lr_child )->xml_get( ).
    ENDLOOP.

    DATA(lv_ns) = COND #( WHEN m_ns <> || THEN |{ m_ns }:| ).
    result = |{ result }</{ lv_ns }{ m_name }>|.

  ENDMETHOD.


  METHOD zz_file_uploader.

    result = me.
    _generic(
      name   = `FileUploader`
      ns     = `z2ui5`
      t_prop = VALUE #(
         (  n = `placeholder` v = placeholder )
         (  n = `upload`      v = upload )
         (  n = `path`        v = path )
         (  n = `value`       v = value )
      ) ).

  ENDMETHOD.

  METHOD _generic.

    DATA(result2) = NEW z2ui5_cl_xml_view_helper( ).
    result2->m_name = name.
    result2->m_ns = ns.
    result2->mt_prop = t_prop.
    result2->m_parent = me.
    result2->m_root   = m_root.
    INSERT result2 INTO TABLE t_child.

    m_root->m_last = result2.
    result = result2.

  ENDMETHOD.

  METHOD dynamic_page.

    result = _generic(
      name   = `DynamicPage`
      ns     = `f`
      t_prop = VALUE #(
         (  n = `headerExpanded`           v = _=>get_json_boolean( headerexpanded ) )
         (  n = `toggleHeaderOnTitleClick` v = toggleHeaderOnTitleClick )
      ) ).

  ENDMETHOD.

  METHOD dynamic_page_header.

    result = _generic(
      name   = `DynamicPageHeader`
      ns     = `f`
      t_prop = VALUE #(
         (  n = `pinnable`           v = _=>get_json_boolean( pinnable ) )
      ) ).

  ENDMETHOD.

  METHOD dynamic_page_title.

    result = _generic(
       name   = `DynamicPageTitle`
       ns     = `f`
       t_prop = VALUE #(
       "   (  n = `pinnable`           v = pinnable )
       ) ).

  ENDMETHOD.

  METHOD object_attribute.

    result = me.

    _generic(
       name   = `ObjectAttribute`
     "  ns     = `form`
       t_prop = VALUE #(
         (  n = `title`       v = title )
         (  n = `text`           v = text )
       ) ).

  ENDMETHOD.

  METHOD zz_plain.

    result = me.
    _generic(
         name  = `ZZPLAIN`
         t_prop = VALUE #( ( n = `VALUE` v = val ) )
    ).

  ENDMETHOD.

  METHOD shell.

    result = _generic(
        name   = `Shell`
        ns     = ns
      ).

  ENDMETHOD.

  METHOD hlp_get_source_code_url.

    DATA(lv_url) = get-t_req_header[ name = `referer` ]-value.
    SPLIT lv_url AT '?' INTO lv_url DATA(lv_dummy).

    " result-url_app           = lv_url && `?sap-client=` && sy-mandt && `&app=` && _=>get_classname_by_ref( mo_runtime->ms_db-o_app ).
    result  = z2ui5_cl_http_handler=>client-t_header[ name = `origin` ]-value  && `/sap/bc/adt/oo/classes/` && _=>get_classname_by_ref( app ) && `/source/main`.


  ENDMETHOD.

  METHOD additional_content.

    result = _generic(
         name  = `additionalContent`

    ).

  ENDMETHOD.

  METHOD illustrated_message.

    result = _generic(
         name  = `IllustratedMessage`
         t_prop = VALUE #(
            ( n = `enableVerticalResponsiveness` v = enableVerticalResponsiveness )
            ( n = `illustrationType`             v = illustrationType )
    ) ).

  ENDMETHOD.

ENDCLASS.
