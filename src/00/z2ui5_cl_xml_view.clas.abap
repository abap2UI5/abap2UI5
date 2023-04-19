CLASS z2ui5_cl_xml_view DEFINITION
  PUBLIC
  FINAL
  CREATE PROTECTED.

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

    DATA m_root    TYPE REF TO z2ui5_cl_xml_view.
    DATA m_last    TYPE REF TO z2ui5_cl_xml_view.
    DATA m_parent  TYPE REF TO z2ui5_cl_xml_view.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view WITH EMPTY KEY.

    CLASS-METHODS factory
      IMPORTING
        t_ns          TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS factory_popup
      IMPORTING
        t_ns          TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    CLASS-METHODS hlp_get_source_code_url
      IMPORTING
        app           TYPE REF TO z2ui5_if_app
        get           TYPE z2ui5_if_client=>ty_s_get
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS hlp_replace_controller_name
      IMPORTING
        xml           TYPE string
      RETURNING
        VALUE(result) TYPE string.

    METHODS constructor.

    METHODS horizontal_layout
      IMPORTING
        class         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS Dynamic_Page
      IMPORTING
        headerExpanded           TYPE clike OPTIONAL
        toggleHeaderOnTitleClick TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view.

    METHODS Dynamic_Page_Title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS Dynamic_Page_Header
      IMPORTING
        pinnable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS Illustrated_Message
      IMPORTING
        enableVerticalResponsiveness TYPE clike OPTIONAL
        illustrationType             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)                TYPE REF TO z2ui5_cl_xml_view.

    METHODS additional_Content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS popover
      IMPORTING
        title         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        placement     TYPE clike OPTIONAL
        initialFocus  TYPE clike OPTIONAL
        contentwidth  TYPE clike OPTIONAL
        contentheight TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS list_item
      IMPORTING
        text           TYPE clike OPTIONAL
        additionaltext TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

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
        selectionchange     TYPE clike OPTIONAL
          PREFERRED PARAMETER items
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_strip
      IMPORTING
        text          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        showicon      TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS footer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_page
      IMPORTING
        show_header         TYPE clike OPTIONAL
        text                TYPE clike OPTIONAL
        enableformattedtext TYPE clike OPTIONAL
        description         TYPE clike OPTIONAL
        icon                TYPE clike OPTIONAL
      RETURNING
        VALUE(result)       TYPE REF TO z2ui5_cl_xml_view.

    METHODS object_page_layout
      IMPORTING
        showTitleInHeaderContent TYPE clike OPTIONAL
        showEditHeaderButton     TYPE clike OPTIONAL
        editHeaderButtonPress    TYPE clike OPTIONAL
        upperCaseAnchorBar       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)            TYPE REF TO z2ui5_cl_xml_view.

    METHODS Object_Page_Dyn_Header_Title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS expanded_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS snapped_heading
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS expanded_content
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS snapped_content
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS heading
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS actions
      IMPORTING
        ns            TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS snapped_Title_On_Mobile
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS navigation_actions
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS avatar
      IMPORTING
        src           TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        displaysize   TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS header_title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS Object_Page_Section
      IMPORTING
        titleUppercase TYPE clike OPTIONAL
        title          TYPE clike OPTIONAL
        importance     TYPE clike OPTIONAL
        id             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS sub_sections
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS Object_page_Sub_Section
      IMPORTING
        id            TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS shell
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.
    METHODS blocks
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS layout_data
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS flex_item_data
      IMPORTING
        growfactor       TYPE clike OPTIONAL
        basesize         TYPE clike OPTIONAL
        backgrounddesign TYPE clike OPTIONAL
        styleclass       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    METHODS code_editor
      IMPORTING
        value         TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS suggestion_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS vertical_layout
      IMPORTING
        class         TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS multi_input
      IMPORTING
        showclearicon   TYPE clike OPTIONAL
        showValueHelp   TYPE clike OPTIONAL
        suggestionitems TYPE clike OPTIONAL
        width           TYPE clike OPTIONAL
        tokens          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_xml_view.

    METHODS tokens
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS token
      IMPORTING
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS buttons
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS get_root
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS get_parent
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS get
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS get_child
      IMPORTING
        index         TYPE i DEFAULT 1
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS column
      IMPORTING
        width         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS interact_donut_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
        displayedsegments TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    METHODS segments
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS interact_donut_chart_segment
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS interact_bar_chart
      IMPORTING
        selectionchanged  TYPE clike OPTIONAL
        press             TYPE clike OPTIONAL
        labelwidth        TYPE clike OPTIONAL
        errormessage      TYPE clike OPTIONAL
        errormessagetitle TYPE clike OPTIONAL
        showerror         TYPE clike OPTIONAL
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    METHODS bars
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS interact_bar_chart_bar
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)     TYPE REF TO z2ui5_cl_xml_view.

    METHODS points
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS interact_line_chart_point
      IMPORTING
        label          TYPE clike OPTIONAL
        value          TYPE clike OPTIONAL
        secondarylabel TYPE clike OPTIONAL
        displayedvalue TYPE clike OPTIONAL
        selected       TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS radial_micro_chart
      IMPORTING
        sice          TYPE clike OPTIONAL
        percentage    TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        valuecolor    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS column_list_item
      IMPORTING
        valign        TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS cells
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS header_content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS sub_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS custom_data
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS badge_custom_data
      IMPORTING
        key           TYPE clike OPTIONAL
        value         TYPE clike OPTIONAL
        visible       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS toggle_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_view
      IMPORTING
        items         TYPE clike OPTIONAL
        groupItems    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_popover
      IMPORTING
        items         TYPE clike OPTIONAL
        groupItems    TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS message_item
      IMPORTING
        type          TYPE clike OPTIONAL
        title         TYPE clike OPTIONAL
        subtitle      TYPE clike OPTIONAL
        description   TYPE clike OPTIONAL
        groupName     TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

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
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS vbox
      IMPORTING
        height        TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
          PREFERRED PARAMETER class
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS hbox
      IMPORTING
        class         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS scroll_container
      IMPORTING
        height        TYPE clike OPTIONAL
        width         TYPE clike OPTIONAL
        vertical      TYPE clike OPTIONAL
        horizontal    TYPE clike OPTIONAL
        focusable     TYPE clike OPTIONAL
          PREFERRED PARAMETER height
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS simple_form
      IMPORTING
        title         TYPE clike OPTIONAL
        layout        TYPE clike OPTIONAL
        editable      TYPE clike OPTIONAL
          PREFERRED PARAMETER title
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS zz_plain
      IMPORTING
        val           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS content
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS title
      IMPORTING
        ns            TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
        wrapping      TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS tab_container
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS tab
      IMPORTING
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS overflow_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS overflow_toolbar_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        tooltip       TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS toolbar_spacer
      IMPORTING
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS label
      IMPORTING
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS image
      IMPORTING
        src           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS date_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS time_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS date_time_picker
      IMPORTING
        value         TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS link
      IMPORTING
        text          TYPE clike OPTIONAL
        href          TYPE clike OPTIONAL
        target        TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        ns            TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS list
      IMPORTING
        headertext      TYPE clike OPTIONAL
        items           TYPE clike OPTIONAL
        mode            TYPE clike OPTIONAL
        selectionChange type clike optional
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS standard_list_item
      IMPORTING
        title         TYPE clike OPTIONAL
        description   TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        info          TYPE clike OPTIONAL
        press         TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS item
      IMPORTING
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS segmented_button_item
      IMPORTING
        icon          TYPE clike OPTIONAL
        key           TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS combobox
      IMPORTING
        selectedkey   TYPE clike OPTIONAL
        showclearicon TYPE clike OPTIONAL
        label         TYPE clike OPTIONAL
        items         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS grid
      IMPORTING
        class         TYPE clike OPTIONAL
        default_span  TYPE clike OPTIONAL
          PREFERRED PARAMETER default_span
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS grid_data
      IMPORTING
        span          TYPE clike OPTIONAL
          PREFERRED PARAMETER span
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

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
        VALUE(result)   TYPE REF TO  z2ui5_cl_xml_view.

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
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS generic_tag
      IMPORTING
        arialabelledby TYPE clike OPTIONAL
        text           TYPE clike OPTIONAL
        design         TYPE clike OPTIONAL
        status         TYPE clike OPTIONAL
        class          TYPE clike OPTIONAL
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_xml_view.

    METHODS object_attribute
      IMPORTING
        title         TYPE clike OPTIONAL
        text          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS object_number
      IMPORTING
        state         TYPE clike OPTIONAL
        emphasized    TYPE clike OPTIONAL
        number        TYPE clike OPTIONAL
        unit          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS switch
      IMPORTING
        state         TYPE clike OPTIONAL
        customtexton  TYPE clike OPTIONAL
        customtextoff TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
        type          TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS step_input
      IMPORTING
        value         TYPE clike
        min           TYPE clike
        max           TYPE clike
        step          TYPE clike
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS progress_indicator
      IMPORTING
        percentvalue  TYPE clike OPTIONAL
        displayvalue  TYPE clike OPTIONAL
        showvalue     TYPE clike OPTIONAL
        state         TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS segmented_button
      IMPORTING
        selected_key     TYPE clike
        selection_change TYPE clike OPTIONAL
      RETURNING
        VALUE(result)    TYPE REF TO z2ui5_cl_xml_view.

    METHODS checkbox
      IMPORTING
        text          TYPE clike OPTIONAL
        selected      TYPE clike OPTIONAL
        enabled       TYPE clike OPTIONAL
          PREFERRED PARAMETER selected
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS header_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS text
      IMPORTING
        text          TYPE clike OPTIONAL
        class         TYPE clike OPTIONAL
        ns            TYPE clike OPTIONAL
          PREFERRED PARAMETER text
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS formatted_text
      IMPORTING
        htmltext      TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS _generic
      IMPORTING
        name          TYPE clike
        ns            TYPE clike OPTIONAL
        t_prop        TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_xml_view.

    METHODS zz_file_uploader
      IMPORTING
        value         TYPE clike OPTIONAL
        path          TYPE clike OPTIONAL
        placeholder   TYPE clike OPTIONAL
        upload        TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO  z2ui5_cl_xml_view.

    METHODS xml_get
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS z2ui5_cl_xml_view IMPLEMENTATION.

  METHOD constructor.

    mt_prop = VALUE #(
    ( n = `xmlns`        v = `sap.m` )
    ( n = `xmlns:z2ui5`  v = `z2ui5` )
    ( n = `xmlns:core`   v = `sap.ui.core` )
    ( n = `xmlns:mvc`    v = `sap.ui.core.mvc` )
    ( n = `xmlns:layout` v = `sap.ui.layout` )
    ( n = `xmlns:f`      v = `sap.f` )
    ( n = `xmlns:form`   v = `sap.ui.layout.form` )
    ( n = `xmlns:editor` v = `sap.ui.codeeditor` )
    ( n = `xmlns:mchart` v = `sap.suite.ui.microchart` )
    ( n = `xmlns:webc`   v = `sap.ui.webc.main` )
    ( n = `xmlns:uxap`   v = `sap.uxap` )
    ( n = `xmlns:sap`    v = `sap` )
    ( n = `xmlns:text`   v = `sap.ui.richtextedito` )
    ( n = `xmlns:html`   v = `http://www.w3.org/1999/xhtml` )
     ).

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->mt_prop = VALUE #( BASE result->mt_prop
        (  n = 'displayBlock'   v = 'true' )
        (  n = 'height'         v = '100%' )
        (  n = 'controllerName' v = z2ui5_cl_http_handler=>config-controller_name )
    ).

    result->m_name   = `View`.
    result->m_ns     = `mvc`.
    result->m_root   = result.
    result->m_parent = result.

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
          ( n = `visible`  v = lcl_utility=>get_json_boolean( visible ) )
       ) ).

  ENDMETHOD.


  METHOD bars.

    result = _generic(
        name = `bars`
        ns   = `mchart` ).

  ENDMETHOD.


  METHOD blocks.

    result = _generic(
        name = `blocks`
        ns   = `uxap`
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
          ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
          ( n = `icon`    v = icon )
          ( n = `type`    v = type )
          ( n = `id`      v = id )
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
          ( n = `enabled`  v = lcl_utility=>get_json_boolean( enabled ) )
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
            ( n = `editable`   v = lcl_utility=>get_json_boolean( editable ) )
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
          (  n = `showClearIcon` v = lcl_utility=>get_json_boolean( showclearicon ) )
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
                      ( n = `fitContainer`  v = lcl_utility=>get_json_boolean( fitContainer ) )
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
        ns   = `layout`
        t_prop = VALUE #(
            ( n = `defaultSpan` v = default_span )
            ( n = `class`       v = class )
            ) ).

  ENDMETHOD.


  METHOD grid_data.

    result = me.
    _generic(
           name = `GridData`
           ns = `layout`
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
        ns     = `layout`
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
           ( n = `showClearIcon`    v = lcl_utility=>get_json_boolean( showclearicon ) )
           ( n = `description`      v = description )
           ( n = `editable`         v = lcl_utility=>get_json_boolean( editable ) )
           ( n = `enabled`          v = lcl_utility=>get_json_boolean( enabled ) )
           ( n = `valueState`       v = valuestate )
           ( n = `valueStateText`   v = valuestatetext )
           ( n = `value`            v = value )
           ( n = `suggestionItems`  v = suggestionitems )
           ( n = `showSuggestion`   v = lcl_utility=>get_json_boolean( showsuggestion ) )
           ( n = `valueHelpRequest` v = valuehelprequest )
           ( n = `showValueHelp`    v = lcl_utility=>get_json_boolean( showvaluehelp ) )
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
             ( n = `showError`         v = lcl_utility=>get_json_boolean( showerror ) )
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
             ( n = `showError`         v = lcl_utility=>get_json_boolean( showerror ) )
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
             ( n = `selected`       v = lcl_utility=>get_json_boolean( selected ) )
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
         ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
       ) ).

  ENDMETHOD.


  METHOD list.

    result = _generic(
        name = `List`
        t_prop = VALUE #(
          ( n = `headerText`      v = headertext )
          ( n = `items`           v = items )
          ( n = `mode`            v = mode )
          ( n = `selectionChange` v = selectionchange )
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
           ( n = `showHeader`          v = lcl_utility=>get_json_boolean( show_header ) )
           ( n = `description`         v = description )
           ( n = `icon`                v = icon )
           ( n = `text`                v = text )
           ( n = `enableFormattedText` v = lcl_utility=>get_json_boolean( enableformattedtext ) )
      ) ).

  ENDMETHOD.


  METHOD message_strip.

    result = me.
    _generic(
        name   = `MessageStrip`
        t_prop = VALUE #(
           ( n = `text`     v = text )
           ( n = `type`     v = type )
           ( n = `showIcon` v = lcl_utility=>get_json_boolean( showicon ) )
           ( n = `class`    v = class )
      ) ).

  ENDMETHOD.


  METHOD multi_input.

    result = _generic(
        name   = `MultiInput`
        t_prop = VALUE #(
            ( n = `tokens` v = tokens )
            ( n = `showClearIcon` v = lcl_utility=>get_json_boolean( showclearicon ) )
            ( n = `showValueHelp` v = lcl_utility=>get_json_boolean( showvaluehelp ) )
            ( n = `suggestionItems` v = suggestionitems )
            ( n = `width` v = width )
    ) ).

  ENDMETHOD.


  METHOD object_number.

    result = me.
    _generic(
        name  = `ObjectNumber`
        t_prop = VALUE #(
           ( n = `emphasized`  v = lcl_utility=>get_json_boolean( emphasized ) )
           ( n = `number`      v = number )
           ( n = `state`       v = state )
           ( n = `unit`        v = unit )
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
            ( n = `showTitleInHeaderContent` v = lcl_utility=>get_json_boolean( showTitleInHeaderContent ) )
            ( n = `showEditHeaderButton`     v = lcl_utility=>get_json_boolean( showEditHeaderButton ) )
            ( n = `editHeaderButtonPress`    v = editHeaderButtonPress )
            ( n = `upperCaseAnchorBar`       v = upperCaseAnchorBar )
    ) ).

  ENDMETHOD.


  METHOD object_page_section.

    result = _generic(
        name   = `ObjectPageSection`
        ns     = `uxap`
        t_prop = VALUE #(
            ( n = `titleUppercase`  v = lcl_utility=>get_json_boolean( titleUppercase ) )
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
          ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
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
             ( n = `showNavButton`  v = lcl_utility=>get_json_boolean( shownavbutton ) )
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
                      ( n = `title`         v = title )
                      ( n = `class`         v = class )
                      ( n = `placement`     v = placement )
                      ( n = `initialFocus`  v = initialFocus )
                      ( n = `contentHeight` v = contentheight )
                      ( n = `contentWidth`  v = contentwidth )
        ) ).

  ENDMETHOD.


  METHOD progress_indicator.

    result = me.
    _generic(
         name  = `ProgressIndicator`
         t_prop = VALUE #(
            ( n = `percentValue` v = percentvalue )
            ( n = `displayValue` v = displayvalue )
            ( n = `showValue`    v = lcl_utility=>get_json_boolean( showvalue ) )
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
             ( n = `showTickmarks`   v = lcl_utility=>get_json_boolean( showtickmarks ) )
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
          ( n = `vertical`    v = lcl_utility=>get_json_boolean( vertical ) )
          ( n = `horizontal`  v = lcl_utility=>get_json_boolean( horizontal ) )
          ( n = `focusable`   v = lcl_utility=>get_json_boolean( focusable  ) )
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
        ( n = `editable` v = lcl_utility=>get_json_boolean( editable ) )
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
            ( n = `type`        v = type )
            ( n = `selected`    v = selected )
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
             ( n = `enabled`        v = lcl_utility=>get_json_boolean( enabled ) )
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
           ( n = `selectionChange`  v = selectionchange )
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
              ( n = `editable` v = lcl_utility=>get_json_boolean( editable ) )
              ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
              ( n = `id` v = id )
              ( n = `growing` v = lcl_utility=>get_json_boolean( growing ) )
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
             ( n = `wrapping` v = lcl_utility=>get_json_boolean( wrapping ) )
      ) ).

  ENDMETHOD.


  METHOD toggle_button.

    result = me.
    _generic(
       name   = `ToggleButton`
       t_prop = VALUE #(
          ( n = `press`   v = press )
          ( n = `text`    v = text )
          ( n = `enabled` v = lcl_utility=>get_json_boolean( enabled ) )
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
        ns     = `layout`
        t_prop = VALUE #(
                     ( n = `class`  v = class )
                     ( n = `width`  v = width )
        ) ).

  ENDMETHOD.


  METHOD xml_get.

    CASE m_name.
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

    LOOP AT t_child INTO DATA(lr_child).
      result = result && CAST z2ui5_cl_xml_view( lr_child )->xml_get( ).
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

    DATA(result2) = NEW z2ui5_cl_xml_view( ).
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
         (  n = `headerExpanded`           v = lcl_utility=>get_json_boolean( headerexpanded ) )
         (  n = `toggleHeaderOnTitleClick` v = toggleHeaderOnTitleClick )
      ) ).

  ENDMETHOD.

  METHOD dynamic_page_header.

    result = _generic(
      name   = `DynamicPageHeader`
      ns     = `f`
      t_prop = VALUE #(
         (  n = `pinnable`           v = lcl_utility=>get_json_boolean( pinnable ) )
      ) ).

  ENDMETHOD.

  METHOD dynamic_page_title.

    result = _generic(
       name   = `DynamicPageTitle`
       ns     = `f`
       ).

  ENDMETHOD.

  METHOD object_attribute.

    result = me.

    _generic(
       name   = `ObjectAttribute`
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

    result  = z2ui5_cl_http_handler=>client-t_header[ name = `origin` ]-value  && `/sap/bc/adt/oo/classes/` && lcl_utility=>get_classname_by_ref( app ) && `/source/main`.

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

  METHOD factory_popup.

    result = NEW #( ).

    IF t_ns IS NOT INITIAL.
      result->mt_prop = t_ns.
    ENDIF.

    result->m_name = `FragmentDefinition`.
    result->m_ns = `core`.
    result->m_root = result.
    result->m_parent = result.

  ENDMETHOD.

  METHOD message_item.

    result = _generic(
         name  = `MessageItem`
         t_prop = VALUE #(
            ( n = `type`        v = type )
            ( n = `title`       v = title )
            ( n = `subtitle`    v = subtitle )
            ( n = `description` v = description )
            ( n = `groupName`   v = groupName )
    ) ).

  ENDMETHOD.

  METHOD message_popover.

    result = _generic(
         name  = `MessagePopover`
         t_prop = VALUE #(
            ( n = `items`      v = items )
            ( n = `groupItems` v = lcl_utility=>get_json_boolean( groupItems ) )
    ) ).

  ENDMETHOD.

  METHOD message_view.

    result = _generic(
         name  = `MessageView`
         t_prop = VALUE #(
            ( n = `items`      v = items )
            ( n = `groupItems` v = lcl_utility=>get_json_boolean( groupItems ) )
    ) ).

  ENDMETHOD.

  METHOD hlp_replace_controller_name.

    result  = lcl_utility=>get_replace( iv_val = xml
    iv_begin = 'controllerName="' iv_end = '"' iv_replace = `controllerName="` && z2ui5_cl_http_handler=>config-controller_name && `"` ).

  ENDMETHOD.

ENDCLASS.
