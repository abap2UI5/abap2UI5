CLASS z2ui5_cl_control_library DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

  interfaces: zz2ui5_if_ui5_library.

"  ALIASES: add_code_editor FOR zz2ui5_if_ui5_library~add_code_editor.

    CONSTANTS:
      BEGIN OF cs,
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

    TYPES:
      BEGIN OF ty,
        BEGIN OF _,
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
        END OF _,
        BEGIN OF input,
          t_suggestions TYPE STANDARD TABLE OF ty-_-s_suggestion_items WITH EMPTY KEY,
        END OF input,
        BEGIN OF combobox,
          t_item TYPE STANDARD TABLE OF ty-_-s_combobox WITH EMPTY KEY,
        END OF combobox,
        BEGIN OF radiobutton_group,
          BEGIN OF s_prop,
            selected TYPE abap_bool,
            text     TYPE string,
          END OF s_prop,
          t_prop TYPE string_table,
        END OF radiobutton_group,
        BEGIN OF segemented_button,
          t_button TYPE STANDARD TABLE OF ty-_-s_seg_btn WITH EMPTY KEY,
          BEGIN OF s_tab,
            text     TYPE string,
            icon     TYPE string,
            selected TYPE abap_bool,
          END OF s_tab,
          tr_btn   TYPE STANDARD TABLE OF ty-segemented_button-s_tab WITH EMPTY KEY,
        END OF segemented_button,
        test    TYPE string,
        t_radio TYPE STANDARD TABLE OF ty-test WITH EMPTY KEY,
      END OF ty.

    DATA name TYPE string.
    DATA ns   TYPE string.
    DATA t_prop TYPE STANDARD TABLE OF z2ui5_cl_hlp_utility=>ty_property WITH EMPTY KEY.


    DATA root    TYPE REF TO z2ui5_cl_control_library.
    DATA parent  TYPE REF TO z2ui5_cl_control_library.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_cl_control_library WITH EMPTY KEY.

    DATA context TYPE REF TO z2ui5_if_view_context.

    CLASS-METHODS factory
      IMPORTING
        context       TYPE REF TO z2ui5_if_view_context
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add
      IMPORTING
        name          TYPE string
        ns            TYPE string OPTIONAL
        t_prop        LIKE t_prop OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_input
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
        VALUE(result)    TYPE REF TO z2ui5_cl_control_library.

    METHODS add_table
      IMPORTING
        items                 TYPE data
        growing_threshold     TYPE string DEFAULT ''
        zz_check_update_model TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(result)         TYPE REF TO z2ui5_cl_control_library.

    METHODS add_footer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    methods add_dialog
        importing
            title type string optional
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    methods add_buttons
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    methods add_message_page
        importing
            show_header type abap_bool default abap_false
            text type string optional
            enable_formatted_text type abap_bool default abap_true
                description type string optional
                icon type string optional
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    methods add_Table_Select_Dialog
        importing
        title type string optional
        event_ID_confirm TYpe string optional
        event_id_cancel type string optional
        items type data optional
          RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_columns
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_column
      IMPORTING
        width         TYPE string OPTIONAL
        text          TYPE string DEFAULT 'title'
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_items
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_column_list_item
      IMPORTING
        vAlign        TYPE string DEFAULT 'Middle'
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_cells
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_header_content
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_sub_header
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_button
      IMPORTING
        text          TYPE clike OPTIONAL
        icon          TYPE clike OPTIONAL
        on_press_id   TYPE clike optional
        type          TYPE clike OPTIONAL
        enabled       TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_page
      IMPORTING
        title             TYPE string OPTIONAL
        event_nav_back_id TYPE string OPTIONAL
        PREFERRED PARAMETER title
      RETURNING
        VALUE(result)     TYPE REF TO z2ui5_cl_control_library.

    METHODS add_vbox
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_scroll_container
      IMPORTING
        height        TYPE string DEFAULT '100%'
        width         TYPE string DEFAULT '100%'
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_simple_form
      IMPORTING
        title         TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_zz_html
      IMPORTING
        val           TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.


    METHODS add_content
      IMPORTING
        ns            TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.



    METHODS add_title
      IMPORTING
        title         TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_overflow_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_toolbar_spacer
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_label
      IMPORTING
        text          TYPE string DEFAULT 'line_label'
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_date_picker
      IMPORTING
        value         TYPE string OPTIONAL
        placeholder   TYPE string OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_time_picker
      IMPORTING
        value         TYPE string OPTIONAL
        placeholder   TYPE string OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_date_time_picker
      IMPORTING
        value         TYPE string OPTIONAL
        placeholder   TYPE string OPTIONAL
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_link
      IMPORTING
        text          TYPE string    DEFAULT 'line_label'
        href          TYPE string    OPTIONAL
        enabled       TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    methods add_list
      IMPORTING
        header_text     TYPE string optional
        items           TYPE data
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_control_library.

   methods add_standard_list_item
      IMPORTING
        title        TYPE string optional
        description  TYPE string optional
        icon         TYPE string optional
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_control_library.

    METHODS add_combobox
      IMPORTING
        selectedKey     TYPE data
        show_clear_icon TYPE abap_bool DEFAULT abap_false
        label           TYPE string DEFAULT 'line_label'
        t_item          TYPE ty-combobox-t_item
      RETURNING
        VALUE(result)   TYPE REF TO z2ui5_cl_control_library.

    METHODS add_grid
      IMPORTING
        class         TYPE string DEFAULT 'sapUiSmallMarginTop'
        default_Span  TYPE string DEFAULT 'L6 M6 S12'
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_text_area
      IMPORTING
        value         TYPE string OPTIONAL
        rows          TYPE i DEFAULT 8
        height        TYPE string OPTIONAL
        width         TYPE string DEFAULT '100%'
          PREFERRED PARAMETER value
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_switch
      IMPORTING
        state         TYPE abap_bool DEFAULT abap_true
        customTextOn  TYPE string OPTIONAL
        customTextOff TYPE string OPTIONAL
        enabled       TYPE abap_bool DEFAULT abap_true
        type          TYPE string DEFAULT z2ui5_if_view=>cs-switch-type-default
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_step_input
      IMPORTING
        value         TYPE string
        min           TYPE string
        max           TYPE string
        step          TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_progress_indicator
      IMPORTING
        percent_value TYPE string
        display_value TYPE string OPTIONAL
        show_value    TYPE abap_bool DEFAULT abap_false
        state         TYPE string DEFAULT z2ui5_if_view=>cs-progress_indicator-state-none
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_segmented_button
      IMPORTING
        selected_key  TYPE data OPTIONAL
        t_button      TYPE ty-segemented_button-t_button
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_checkbox
      IMPORTING
        text          TYPE string OPTIONAL
        selected      TYPE abap_bool OPTIONAL
        selected_json TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS add_header_toolbar
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.


    METHODS add_radiobutton_group
      IMPORTING
        "    description     TYPE string OPTIONAL
        selected_index TYPE i OPTIONAL
        t_prop         TYPE ty-radiobutton_group-t_prop
      RETURNING
        VALUE(result)  TYPE REF TO z2ui5_cl_control_library.

    METHODS add_text
      IMPORTING
        text          TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_control_library.

    METHODS get_view
        importing
            check_popup_active type abap_bool default abap_false
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

    METHODS xml_get
        importing
             check_popup_active type abap_bool default abap_false
      RETURNING
        VALUE(result) TYPE string.

    METHODS xml_get_begin
        importing
             check_popup_active type abap_bool default abap_false
      RETURNING
        VALUE(result) TYPE string.

    METHODS xml_get_end
          importing
         check_popup_active type abap_bool default abap_false
      RETURNING
        VALUE(result) TYPE string.

  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_control_library IMPLEMENTATION.

  METHOD xml_get_begin.

    result = cond #(  when check_popup_active = abap_false
              then      `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
                     `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                               ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` &&
                         COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `<Shell>` )
              else   `<core:FragmentDefinition   xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
                     `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                               ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` ).

  ENDMETHOD.

  METHOD xml_get_end.

    result &&= cond #( when check_popup_active = abap_false
              then COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `</Shell>` ) && `</mvc:View>`
              else `</core:FragmentDefinition>` ).

  ENDMETHOD.

  METHOD xml_get.

    "case - root
    IF me = root.
      result = xml_get_begin( check_popup_active ).

      LOOP AT t_child INTO DATA(lr_child).
        result &&= lr_child->xml_get(  ).
      ENDLOOP.

      result &&= xml_get_end( check_popup_active ).
      RETURN.
    ENDIF.

    "case - normal
    CASE name.

      WHEN 'ZZHTML'.
        result = t_prop[ n = 'VALUE' ]-v.
        RETURN.
    ENDCASE.

    result = |{ result } <{ COND #( WHEN ns <> '' THEN |{ ns }:| ) }{ name } \n {
                         REDUCE #( INIT val = `` FOR row IN  t_prop WHERE ( v <> '' )
                          NEXT val = |{ val } { row-n }="{ escape( val = row-v  format = cl_abap_format=>e_xml_attr ) }" \n | ) }|.

    IF t_child IS INITIAL.
      result &&= '/>'.
      RETURN.
    ENDIF.

    result &&= '>'.

    LOOP AT t_child INTO lr_child.
      result &&= lr_child->xml_get(  ).
    ENDLOOP.

    result &&= |</{ COND #( WHEN ns <> '' THEN |{ ns }:| ) }{ name }>|.

  ENDMETHOD.

  METHOD add.

    result = NEW z2ui5_cl_control_library( ).
    result->name = name.
    result->ns = ns.
    result->t_prop = t_prop.
    result->parent = me.
    result->root   = root.
    result->context = context.

    INSERT result INTO TABLE t_child.

  ENDMETHOD.

  METHOD factory.

    result = NEW z2ui5_cl_control_library( ).
    result->root = result.
    result->parent = result.
    result->context = context.

  ENDMETHOD.

  METHOD add_button.

    result = me.

    add(
       name   = 'Button'
       t_prop = VALUE #(
          ( n = 'press'   v = context->get_event_method( `{ 'ID' : '` && on_press_id && `' }` ) )
          "( n = 'press'   v = context->get_event_method( ` $event , { 'ID' : '` && on_press_id && `' } )` ) )
          ( n = 'text'    v = text )
          ( n = 'enabled' v = _=>get_abap_2_json( enabled ) )
          ( n = 'icon'    v = icon )
          ( COND #( WHEN type IS NOT INITIAL THEN VALUE #( n = 'type'  v = type ) ) )
       ) ).

  ENDMETHOD.

  METHOD add_input.

    result = me.

    DATA(lr_input) = add(
        name   = 'Input'
        t_prop = VALUE #(
            ( n = 'placeholder'    v = placeholder )
            ( n = 'type'           v = type )
            ( n = 'showClearIcon'  v = _=>get_abap_2_json( show_clear_icon ) )
            ( n = 'description'    v = description )
            ( n = 'editable'       v = _=>get_abap_2_json( editable ) )
            ( n = 'valueState'     v = value_state )
            ( n = 'valueStateText' v = value_state_text )
            ( n = 'value'          v = COND #( WHEN value is not INITIAL and value(1) = `{` THEN value
                                               WHEN editable = abap_false THEN value
                                               ELSE   '{' && context->get_attr_name_by_ref( value ) && '}' ) )
                          ) ).

    IF suggestion_items IS NOT INITIAL.

      DATA(lv_id) = _=>get_uuid_session( ).
      lr_input->t_prop = VALUE #( BASE lr_input->t_prop
        ( n = 'suggestionItems' v = '{/' && lv_id && '}' )
        ( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )
        ).

      " ??????
      context->mo_view_model->add_attribute(
           n = lv_id
           v = _=>trans_any_2_json( suggestion_items  )
        apos_active = abap_false
      ).

      lr_input->add( |suggestionItems|
             )->add(
                 name   = 'ListItem'
                 ns     = 'core'
                 t_prop = VALUE #(
                        ( n = 'text' v = '{VALUE}' )
                        ( n = 'additionalText' v = '{DESCR}' ) ) ).

    ENDIF.

  ENDMETHOD.

  METHOD get_view.

*    if check_popup_active = abap_true.
*
*    result = `<core:FragmentDefinition` && |\n|  &&
*             `   xmlns="sap.m"` && |\n|  &&
*             `   xmlns:core="sap.ui.core" >` && |\n|  &&
*             `   <Dialog` && |\n|  &&
*             `      id="helloDialog"` && |\n|  &&
*             `      title="Hello {/recipient/name}">` && |\n|  &&
*             `   </Dialog>` && |\n|  &&
*             `</core:FragmentDefinition>`.
*    return.
*    endif.

    result = root->xml_get( check_popup_active ).

  ENDMETHOD.

  METHOD add_page.

    result = add(
        name   = 'Page'
         t_prop = VALUE #(
             ( n = 'title' v = title )
             ( n = 'showNavButton' v = COND #( WHEN event_nav_back_id = '' THEN 'false' ELSE 'true' ) )
             ( n = 'navButtonTap' v = context->get_event_method( `{ 'ID' : '` && event_nav_back_id && `' } )` ) )
          "   ( n = 'navButtonTap' v = context->get_event_method( `${$parameters}, ${$source} , $event , { 'ID' : '` && event_nav_back_id && `' } )` ) )
     ) ).

    " result = lo_page->add( 'content').

  ENDMETHOD.

  METHOD add_vbox.

    result = add(
         name   = 'VBox'
         t_prop = VALUE #(
            ( n = 'class' v = 'sapUiSmallMargin' )
           "( n = 'height' v = '10%' )
             ) ).

  ENDMETHOD.

  METHOD add_simple_form.

    result = add(
      name   = 'SimpleForm'
      ns     = 'f'
      t_prop = VALUE #(
        ( n = 'title' v = title )
        ( n = 'editable' v = 'true' )
        ( n = 'layout' v = 'ResponsiveGridLayout' )
        ( n = 'labelSpanXL' v = '4' )
        ( n = 'labelSpanL' v = '3' )
        ( n = 'labelSpanM' v = '4' )
        ( n = 'labelSpanS' v = '12' )
        ( n = 'emptySpanXL' v = '0' )
        ( n = 'emptySpanL' v = '4' )
        ( n = 'emptySpanM' v = '0' )
        ( n = 'emptySpanS' v = '0' )
        ( n = 'columnsL' v = '1' )
        ( n = 'columnsM' v = '1' )
        ( n = 'singleContainerFullSize' v = 'false' )
        ( n = 'adjustLabelSpan' v = 'false' )
      ) ).

  ENDMETHOD.


  METHOD add_content.

    result = add(
        ns    = ns
       name   = 'content'
      ).

  ENDMETHOD.


  METHOD add_title.

    result = me.

    add(
         name  = 'Title'
        " ns = 'core'
         t_prop = VALUE #(
             ( n = 'text' v = title ) )
        ) .

  ENDMETHOD.

  METHOD zz2ui5_if_ui5_library~code_editor.

    result = me.

    add(
        name  = 'CodeEditor'
        ns = 'editor'
        t_prop = VALUE #(
            ( n = 'value'   v = context->get_attr_name_by_ref( value ) )
            ( n = 'type'    v = type )
            ( n = 'height'  v = '600px' )
         ) ) .

  ENDMETHOD.

  METHOD add_zz_html.

    "todo
    DATA(lv_html) = replace( val = val sub = '</' with = '#+´"?' occ   =   0 ).
    lv_html = replace( val = lv_html sub = '<' with = '<html:' occ   =   0 ).
    lv_html = replace( val = lv_html sub = '#+´"?' with = '</html:' occ   =   0 ).

    result = me.

    add(
      name  = 'ZZHTML'
      t_prop = VALUE #( ( n = 'VALUE' v = lv_html ) )
    ).

  ENDMETHOD.

  METHOD add_overflow_toolbar.

    result = add( 'OverflowToolbar' ).

  ENDMETHOD.

  METHOD add_toolbar_spacer.

    result = me.
    add( 'ToolbarSpacer' ).

  ENDMETHOD.

  METHOD add_combobox.

    result = me.

    DATA(lv_id) = _=>get_uuid_session( ).

    DATA(lo_box) = add(
      name  = 'ComboBox'
      t_prop = VALUE #(
       (  n = 'showClearIcon' v = _=>get_abap_2_json( show_clear_icon ) )
       (  n = 'selectedKey'   v = context->get_attr_name_by_ref( selectedkey ) )
       (  n = 'items' v = '{/' && lv_id && '}' )
      ) ).

    lo_box->add(
       name = 'Item'
       ns = 'core'
       t_prop = VALUE #(
     ( n = 'key'  v ='{KEY}'  )
     ( n = 'text' v = '{TEXT}' )
    ) ).

    context->mo_view_model->add_attribute(
      n           = lv_id
      v           = _=>trans_any_2_json( t_item )
      apos_active = abap_false
     ).

  ENDMETHOD.

  METHOD add_date_picker.

    result = me.

    add(
      name       = 'DatePicker'
      t_prop = VALUE #(
          ( n = 'value' v = context->get_attr_name_by_ref( value )  )
          ( n = 'placeholder' v = placeholder )
       ) ).

  ENDMETHOD.

  METHOD add_date_time_picker.

    result = me.

    add(
        name  = 'DateTimePicker'
        t_prop = VALUE #(
            ( n = 'value' v = context->get_attr_name_by_ref( value ) )
            ( n = 'placeholder'  v = placeholder  )
         ) ).

  ENDMETHOD.

  METHOD add_label.

    result = me.

    add(
       name  = 'Label'
       t_prop = VALUE #(
           ( n = 'text' v = text )
        ) ).

  ENDMETHOD.

  METHOD add_link.

    result = me.

    add(
     name  = 'Link'
       t_prop = VALUE #(
         ( n = 'text'   v = text )
         ( n = 'target' v = '_blank' )
         ( n = 'href'   v = href )
         ( n = 'enabled'   v = _=>get_abap_2_json( enabled ) )
       ) ).

  ENDMETHOD.

  METHOD add_segmented_button.

    result = me.

    DATA(lo_button) = add(
      name  = 'SegmentedButton'
      t_prop = VALUE #(
       ( n = 'selectedKey' v = context->get_attr_name_by_ref( selected_key ) )
     ) ).

    DATA(lo_item) = lo_button->add( 'items' ).

    LOOP AT t_button REFERENCE INTO DATA(lr_btn).

      lo_item->add(
          name   = 'SegmentedButtonItem'
          t_prop = VALUE #(
            ( n = 'icon'  v = lr_btn->icon  )
            ( n = 'key'   v = lr_btn->key )
            ( n = 'text'  v = lr_btn->text )
                  ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD add_step_input.

    result = me.

    add(
         name  = 'StepInput'
         t_prop = VALUE #(
            ( n = 'max'  v = max  )
            ( n = 'min'  v = min  )
            ( n = 'step' v = step )
            ( n = 'value' v = context->get_attr_name_by_ref( value )  )
     ) ).

  ENDMETHOD.

  METHOD add_switch.

    result = me.

    add(
          name  = 'Switch'
          t_prop = VALUE #(
             ( n = 'type'           v = type           )
             ( n = 'enabled'        v = _=>get_abap_2_json( enabled  )      )
             ( n = 'state'          v = context->get_attr_name_by_ref( state ) )
             ( n = 'customTextOff'  v = customtextoff  )
             ( n = 'customTextOn'   v = customtexton   )
      ) ).

  ENDMETHOD.

  METHOD add_text_area.

    result = me.

    add(
          name  = 'TextArea'
            t_prop = VALUE #(
              ( n = 'value' v = context->get_attr_name_by_ref( value ) )
              ( n = 'rows' v = rows )
              ( n = 'height' v = height )
              ( n = 'width' v = width )
          ) ).

  ENDMETHOD.

  METHOD add_time_picker.

    result = me.

    add(
     name   = 'TimePicker'
     t_prop = VALUE #(
          ( n = 'value' v = context->get_attr_name_by_ref( value )  )
          ( n = 'placeholder'  v = placeholder  )
      ) ).

  ENDMETHOD.

  METHOD add_checkbox.

    result = me.

    add(
       name  = 'CheckBox'
       t_prop = VALUE #(
          ( n = 'text'  v = text )
          ( n = 'selected' v = COND #( WHEN selected_json IS SUPPLIED THEN selected_json ELSE context->get_attr_name_by_ref( selected ) ) )
      ) ).

  ENDMETHOD.

  METHOD add_progress_indicator.

    result = me.

    add(
         name  = 'ProgressIndicator'
         t_prop = VALUE #(
            ( n = 'percentValue' v = context->get_attr_name_by_ref( percent_value ) )
            ( n = 'displayValue' v = display_Value )
            ( n = 'showValue'    v = _=>get_abap_2_json( show_value  )      )
            ( n = 'state'        v = state  )
     ) ).

  ENDMETHOD.

  METHOD add_radiobutton_group.

    result = me.

    add(
     name   = 'RadioButtonGroup'
     t_prop = VALUE #(
             ( n = 'columns' v = lines( t_prop ) )
             ( n = 'selectedIndex' v = context->get_attr_name_by_ref( selected_index ) )
     ) ).

    LOOP AT t_prop REFERENCE INTO DATA(lr_prop).
      DATA(lv_tabix) = sy-tabix - 1.

      add(
        name   = 'RadioButton'
        t_prop = VALUE #(
           ( n = 'text' v = lr_prop->* )
         ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD add_text.

    result = me.

    add(
      name  = 'Text'
      t_prop = VALUE #( ( n = 'text' v = text ) )
     ).

  ENDMETHOD.

  METHOD add_table.

    result = add(
        name  = 'Table'
        t_prop = VALUE #(
             ( n = 'items' v = '{' && context->get_attr_name_by_ref( ref = items check_update = zz_check_update_model ) && '}' )
             ( n = 'growing' v = 'true' )
             ( n = 'growingThreshold' v = growing_threshold )
              )
       ).

  ENDMETHOD.

  METHOD add_cells.

    result = add(  'cells' ).

  ENDMETHOD.

  METHOD add_column.

    result = me.
    DATA(lo_col) = add(
        name  = 'Column'
          t_prop = VALUE #( ( n = 'width' v = width ) )
     ).

    lo_col->add_text( text ).

  ENDMETHOD.

  METHOD add_columns.

    result = add(  'columns' ).

  ENDMETHOD.

  METHOD add_column_list_item.

    result = add(
        name = 'ColumnListItem'
        t_prop = VALUE #( ( n = 'vAlign' v = valign ) )
         ).

  ENDMETHOD.

  METHOD add_items.

    result = add(  'items' ).

  ENDMETHOD.

  METHOD add_grid.

    result = add(
        name = 'Grid'
        ns   = 'l'
        t_prop = VALUE #(
            ( n = 'defaultSpan' v = default_span )
            ( n = 'class'       v = class )
            ) ).

  ENDMETHOD.

  METHOD add_header_toolbar.

    result = add( 'headerToolbar' ).

  ENDMETHOD.



  METHOD add_scroll_container.

    result = add(
         name = 'ScrollContainer'
         "  ns   = 'l'
        t_prop = VALUE #(
          ( n = 'height' v = height )
          ( n = 'width'       v = width )
          ( n = 'vertical'       v = 'true' )
          ( n = 'focusable'       v = 'true' )
          ) ).

  ENDMETHOD.

  METHOD add_header_content.

    result = add( 'headerContent' ).

  ENDMETHOD.

  METHOD add_sub_header.

    result = add( 'subHeader' ).

  ENDMETHOD.

  METHOD add_footer.

    result = add( 'footer' ).

  ENDMETHOD.

  METHOD add_dialog.

    result = add(
         name = 'Dialog'
         "  ns   = 'l'
        t_prop = VALUE #(
          ( n = 'title'  v = title )
          ) ).

  ENDMETHOD.

  METHOD add_table_select_dialog.

    result = add(
         name = 'TableSelectDialog'
         "  ns   = 'l'
        t_prop = VALUE #(
          ( n = 'title' v = title )
        "  ( n = 'confirm'       v = context->get_event_method( `{ 'ID' : '` && event_id_confirm && `' }` ) )
          ( n = 'confirm'      v = context->get_event_method( ` $event , { 'ID' : '` && event_id_confirm && `' } )` ) )
          ( n = 'cancel'       v = context->get_event_method( `{ 'ID' : '` && event_id_cancel && `' }` ) )
          ( n = 'items' v = '{' && context->get_attr_name_by_ref( ref = items check_update = abap_true ) && '}' )
          ) ).

  ENDMETHOD.

  METHOD add_list.

   result = add(
         name = 'List'
         "  ns   = 'l'
        t_prop = VALUE #(
          ( n = 'headerText' v = header_text )
          ( n = 'items' v = '{' && context->get_attr_name_by_ref( ref = items check_update = abap_true ) && '}' )
          ) ).

  ENDMETHOD.

  METHOD add_standard_list_item.

       result = add(
         name = 'StandardListItem'
         "  ns   = 'l'
        t_prop = VALUE #(
          ( n = 'title' v = title )
          ( n = 'description' v = description )
          ( n = 'icon' v = icon )
              ) ).

  ENDMETHOD.

  METHOD add_message_page.

       result = add(
         name = 'MessagePage'
         "  ns   = 'l'
        t_prop = VALUE #(
          ( n = 'showHeader' v = _=>get_abap_2_json( show_header ) )
          ( n = 'description' v = description )
          ( n = 'icon' v = icon )
          ( n = 'text' v = text )
          ( n = 'enableFormattedText' v =  _=>get_abap_2_json( enable_formatted_text ) )
         ) ).


  ENDMETHOD.

  METHOD add_buttons.

    result = add( 'buttons' ).

  ENDMETHOD.

ENDCLASS.
