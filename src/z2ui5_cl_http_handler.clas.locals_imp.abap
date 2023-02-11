    CLASS z2ui5_lcl_runtime DEFINITION DEFERRED.
    CLASS _ DEFINITION INHERITING FROM z2ui5_cl_hlp_utility.
    ENDCLASS.

    CLASS z2ui5_lcl_ui5_library DEFINITION
      CREATE PUBLIC .

      PUBLIC SECTION.

        INTERFACES: z2ui5_if_ui5_library.

        CONSTANTS cs LIKE z2ui5_if_ui5_library=>cs VALUE z2ui5_if_ui5_library=>cs.
        DATA m_name TYPE string.
        DATA m_ns   TYPE string.
        DATA mt_prop TYPE STANDARD TABLE OF z2ui5_cl_hlp_utility=>ty_property WITH EMPTY KEY.

        DATA mt_attri  TYPE _=>ty-t-attri.
        DATA mo_app TYPE REF TO object.

        DATA m_root    TYPE REF TO z2ui5_lcl_ui5_library.
        DATA m_parent  TYPE REF TO z2ui5_lcl_ui5_library.
        DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_lcl_ui5_library WITH EMPTY KEY.

        CLASS-METHODS factory
          IMPORTING
            t_attri       TYPE _=>ty-t-attri
            o_app         TYPE REF TO z2ui5_if_app
          RETURNING
            VALUE(result) TYPE REF TO z2ui5_lcl_ui5_library.

        METHODS _get_event_method
          IMPORTING
            event_object  TYPE string
          RETURNING
            VALUE(result) TYPE string.

        METHODS _generic
          IMPORTING
            name          TYPE string
            ns            TYPE string OPTIONAL
            t_prop        LIKE mt_prop OPTIONAL
          RETURNING
            VALUE(result) TYPE REF TO z2ui5_lcl_ui5_library.

        TYPES:
          BEGIN OF ty_S_view,
            xml     TYPE string,
            o_model TYPE REF TO z2ui5_cl_hlp_tree_json,
            t_attri TYPE _=>ty-t-attri,
          END OF ty_S_view.

        METHODS get_view
          IMPORTING
            check_popup_active TYPE abap_bool DEFAULT abap_false
          RETURNING
            VALUE(result)      TYPE ty_S_view.

        METHODS _get_name_by_ref
          IMPORTING
            value           TYPE data
            type            TYPE string DEFAULT cs-_bind_type-two_way
          RETURNING
            VALUE(r_result) TYPE string.

      PROTECTED SECTION.

        METHODS xml_get
          IMPORTING
            check_popup_active TYPE abap_bool DEFAULT abap_false
          RETURNING
            VALUE(result)      TYPE string.

        METHODS xml_get_begin
          IMPORTING
            check_popup_active TYPE abap_bool DEFAULT abap_false
          RETURNING
            VALUE(result)      TYPE string.

        METHODS xml_get_end
          IMPORTING
            check_popup_active TYPE abap_bool DEFAULT abap_false
          RETURNING
            VALUE(result)      TYPE string.

      PRIVATE SECTION.

    ENDCLASS.



    CLASS z2ui5_lcl_ui5_library IMPLEMENTATION.

      METHOD _get_name_by_ref.

        IF type = cs-_bind_type-one_time.
          DATA(lv_id) = _=>get_uuid_session( ).
          INSERT VALUE #(
            name = lv_id
            data_stringify = _=>trans_any_2_json( value )
            bind_type = type
           ) INTO TABLE m_root->mt_attri.
          r_result = '{/' && lv_id && '}'.
          RETURN.
        ENDIF.

        DATA(lr_in) = REF #( value ).

        LOOP AT m_root->mt_attri REFERENCE INTO DATA(lr_attri).

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = |M_ROOT->MO_APP->{ to_upper( lr_attri->name ) }|.
          ASSIGN (lv_name) TO <attribute>.
          DATA(lr_ref) = REF #( <attribute> ).

          IF lr_in = lr_ref.
            lr_attri->bind_type = type.
            r_result = COND #( WHEN type = cs-_bind_type-two_way THEN '/oUpdate/' ELSE '/' ) && lr_attri->name.
            RETURN.
          ENDIF.

        ENDLOOP.

      ENDMETHOD.

      METHOD xml_get_begin.

        result = COND #(  WHEN check_popup_active = abap_false
                  THEN      `<mvc:View controllerName='MyController'     xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
                         `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                                   ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` &&
                             COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `<Shell>` )
                  ELSE   `<core:FragmentDefinition   xmlns:core="sap.ui.core"    xmlns:l="sap.ui.layout"` && |\n|  &&
                         `    xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:f="sap.ui.layout.form" xmlns:mvc='sap.ui.core.mvc' displayBlock="true"` && |\n|  &&
                                   ` xmlns:editor="sap.ui.codeeditor"   xmlns="sap.m" xmlns:text="sap.ui.richtexteditor" > ` ).

      ENDMETHOD.

      METHOD xml_get_end.

        result &&= COND #( WHEN check_popup_active = abap_false
                  THEN COND #( WHEN z2ui5_cl_http_handler=>cs_config-letterboxing = abap_true THEN  `</Shell>` ) && `</mvc:View>`
                  ELSE `</core:FragmentDefinition>` ).

      ENDMETHOD.

      METHOD xml_get.

        "case - root
        IF me = m_root.
          result = xml_get_begin( check_popup_active ).

          LOOP AT t_child INTO DATA(lr_child).
            result &&= lr_child->xml_get(  ).
          ENDLOOP.

          result &&= xml_get_end( check_popup_active ).
          RETURN.
        ENDIF.

        "case - normal
        CASE m_name.

          WHEN 'ZZHTML'.
            result = mt_prop[ n = 'VALUE' ]-v.
            RETURN.
        ENDCASE.

        result = |{ result } <{ COND #( WHEN m_ns <> '' THEN |{ m_ns }:| ) }{ m_name } \n {
                             REDUCE #( INIT val = `` FOR row IN  mt_prop WHERE ( v <> '' )
                              NEXT val = |{ val } { row-n }="{ escape( val = row-v  format = cl_abap_format=>e_xml_attr ) }" \n | ) }|.

        IF t_child IS INITIAL.
          result &&= '/>'.
          RETURN.
        ENDIF.

        result &&= '>'.

        LOOP AT t_child INTO lr_child.
          result &&= lr_child->xml_get(  ).
        ENDLOOP.

        result &&= |</{ COND #( WHEN m_ns <> '' THEN |{ m_ns }:| ) }{ m_name }>|.

      ENDMETHOD.

      METHOD _generic.

        result = NEW z2ui5_lcl_ui5_library( ).
        result->m_name = name.
        result->m_ns = ns.
        result->mt_prop = t_prop.
        result->m_parent = me.
        result->m_root   = m_root.
        INSERT result INTO TABLE t_child.

      ENDMETHOD.

      METHOD factory.

        result = NEW z2ui5_lcl_ui5_library( ).
        result->m_root = result.
        result->m_parent = result.
        result->mt_attri = t_attri.
        result->mo_app = o_app.

      ENDMETHOD.

      METHOD _get_event_method.

        result = |onEventBackend({ event_object })|.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~button.

        result = me.

        _generic(
           name   = 'Button'
           t_prop = VALUE #(
              ( n = 'press'   v = _get_event_method( `{ 'ID' : '` && on_press_id && `' }` ) )
              "( n = 'press'   v = context->get_event_method( ` $event , { 'ID' : '` && on_press_id && `' } )` ) )
              ( n = 'text'    v = text )
              ( n = 'enabled' v = _=>get_abap_2_json( enabled ) )
              ( n = 'icon'    v = icon )
              ( COND #( WHEN type IS NOT INITIAL THEN VALUE #( n = 'type'  v = type ) ) )
           ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~input.

        result = me.

        DATA(lr_input) = _generic(
            name   = 'Input'
            t_prop = VALUE #(
                ( n = 'placeholder'    v = placeholder )
                ( n = 'type'           v = type )
                ( n = 'showClearIcon'  v = _=>get_abap_2_json( show_clear_icon ) )
                ( n = 'description'    v = description )
                ( n = 'editable'       v = _=>get_abap_2_json( editable ) )
                ( n = 'valueState'     v = value_state )
                ( n = 'valueStateText' v = value_state_text )
                ( n = 'value'          v = value )
                              ) ).

        IF suggestion_items IS NOT INITIAL.

          lr_input->mt_prop = VALUE #( BASE lr_input->mt_prop
            ( n = 'suggestionItems' v = _get_name_by_ref( value = suggestion_items type = cs-_bind_type-one_time )  ) "'{/' && lv_id && '}' )
            ( n = 'showSuggestion'  v = _=>get_abap_2_json( showsuggestion ) )
            ).

          lr_input->_generic( |suggestionItems|
                 )->_generic(
                     name   = 'ListItem'
                     ns     = 'core'
                     t_prop = VALUE #(
                            ( n = 'text' v = '{VALUE}' )
                            ( n = 'additionalText' v = '{DESCR}' ) ) ).

        ENDIF.

      ENDMETHOD.

      METHOD get_view.

        result-xml = m_root->xml_get( check_popup_active ).

        data(m_view_model) = z2ui5_cl_hlp_tree_json=>factory( ).
        DATA(lo_update) = m_view_model->add_attribute_object( 'oUpdate' ).

        LOOP AT mt_attri REFERENCE INTO DATA(lr_attri) WHERE bind_type <> ''.

          IF lr_attri->bind_type = cs-_bind_type-one_time.
            m_view_model->add_attribute(
                  n = lr_attri->name
                  v = lr_attri->data_stringify
                  apos_active = abap_false
               ).
            CONTINUE.
          ENDIF.

          DATA(lo_actual) = COND #( WHEN lr_attri->bind_type = cs-_bind_type-one_way THEN m_view_model
                                     ELSE lo_update ).

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = |M_PARENT->MO_APP->{ to_upper( lr_attri->name ) }|.
          ASSIGN (lv_name) TO <attribute>.

          CASE lr_attri->kind.

            WHEN 'g' OR 'D' OR 'P' OR 'T' OR 'C'.

              lo_actual->add_attribute( n = lr_attri->name
                                        v = _=>get_abap_2_json( <attribute> )
                                        apos_active = abap_false ).

            WHEN 'I'.
              lo_actual->add_attribute( n = lr_attri->name
                                          v = CONV string( <attribute> )
                                          apos_active = abap_false ).

            WHEN 'h'.
              lo_actual->add_attribute( n = lr_attri->name
                                         v = _=>trans_any_2_json( <attribute> )
                                         apos_active = abap_false ).

          ENDCASE.
        ENDLOOP.

        IF lo_update->mt_values IS INITIAL.
          lo_update->mv_value = '{}'.
          lo_update->mv_apost_active = abap_false.
        ENDIF.

        result-o_model = m_view_model.
        DELETE m_root->mt_attri WHERE bind_type = cs-_bind_type-one_time.
        result-t_attri = m_root->mt_attri.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~page.

        result = _generic(
            name   = 'Page'
             t_prop = VALUE #(
                 ( n = 'title' v = title )
                 ( n = 'showNavButton' v = COND #( WHEN event_nav_back_id = '' THEN 'false' ELSE 'true' ) )
                 ( n = 'navButtonTap' v = _get_event_method( `{ 'ID' : '` && event_nav_back_id && `' } )` ) )
             ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~vbox.

        result = _generic(
             name   = 'VBox'
             t_prop = VALUE #(
                ( n = 'class' v = 'sapUiSmallMargin' )
               "( n = 'height' v = '10%' )
                 ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~simple_form.

        result = _generic(
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


      METHOD z2ui5_if_ui5_library~content.

        result = _generic(
            ns    = ns
           name   = 'content'
          ).

      ENDMETHOD.


      METHOD z2ui5_if_ui5_library~title.

        result = me.

        _generic(
             name  = 'Title'
             t_prop = VALUE #(
                 ( n = 'text' v = title ) )
            ) .

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~code_editor.

        result = me.

        _generic(
            name  = 'CodeEditor'
            ns = 'editor'
            t_prop = VALUE #(
                ( n = 'value'   v = _get_name_by_ref( value ) )
                ( n = 'type'    v = type )
                ( n = 'height'  v = '600px' )
             ) ) .

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~zz_html.

        "todo
        DATA(lv_html) = replace( val = val sub = '</' with = '#+´"?' occ   =   0 ).
        lv_html = replace( val = lv_html sub = '<' with = '<html:' occ   =   0 ).
        lv_html = replace( val = lv_html sub = '#+´"?' with = '</html:' occ   =   0 ).

        result = me.

        _generic(
          name  = 'ZZHTML'
          t_prop = VALUE #( ( n = 'VALUE' v = lv_html ) )
        ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~overflow_toolbar.

        result = _generic( 'OverflowToolbar' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~toolbar_spacer.

        result = me.
        _generic( 'ToolbarSpacer' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~combobox.

        result = me.

        DATA(lo_box) = _generic(
          name  = 'ComboBox'
          t_prop = VALUE #(
           (  n = 'showClearIcon' v = _=>get_abap_2_json( show_clear_icon ) )
           (  n = 'selectedKey'   v = selectedkey )
           (  n = 'items'         v = _get_name_by_ref( value = t_item type = cs-_bind_type-one_time ) )
          ) ).

        lo_box->_generic(
           name = 'Item'
           ns = 'core'
           t_prop = VALUE #(
              ( n = 'key'  v ='{KEY}'  )
              ( n = 'text' v = '{TEXT}' )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~date_picker.

        result = me.

        _generic(
          name       = 'DatePicker'
          t_prop = VALUE #(
              ( n = 'value' v = value  )
              ( n = 'placeholder' v = placeholder )
           ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~date_time_picker.

        result = me.

        _generic(
            name  = 'DateTimePicker'
            t_prop = VALUE #(
                ( n = 'value' v =  value )
                ( n = 'placeholder'  v = placeholder  )
             ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~label.

        result = me.

        _generic(
           name  = 'Label'
           t_prop = VALUE #(
               ( n = 'text' v = text )
            ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~link.

        result = me.

        _generic(
         name  = 'Link'
           t_prop = VALUE #(
             ( n = 'text'   v = text )
             ( n = 'target' v = '_blank' )
             ( n = 'href'   v = href )
             ( n = 'enabled'   v = _=>get_abap_2_json( enabled ) )
           ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~segmented_button.

        result = me.

        DATA(lo_button) = _generic(
          name  = 'SegmentedButton'
          t_prop = VALUE #(
           ( n = 'selectedKey' v = selected_key )
         ) ).

        DATA(lo_item) = lo_button->_generic( 'items' ).

        LOOP AT t_button REFERENCE INTO DATA(lr_btn).

          lo_item->_generic(
              name   = 'SegmentedButtonItem'
              t_prop = VALUE #(
                ( n = 'icon'  v = lr_btn->icon  )
                ( n = 'key'   v = lr_btn->key )
                ( n = 'text'  v = lr_btn->text )
                      ) ).

        ENDLOOP.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~step_input.

        result = me.

        _generic(
             name  = 'StepInput'
             t_prop = VALUE #(
                ( n = 'max'  v = max  )
                ( n = 'min'  v = min  )
                ( n = 'step' v = step )
                ( n = 'value' v = _get_name_by_ref( value )  )
         ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~switch.

        result = me.

        _generic(
              name  = 'Switch'
              t_prop = VALUE #(
                 ( n = 'type'           v = type           )
                 ( n = 'enabled'        v = _=>get_abap_2_json( enabled  )      )
                 ( n = 'state'          v = _get_name_by_ref( state ) )
                 ( n = 'customTextOff'  v = customtextoff  )
                 ( n = 'customTextOn'   v = customtexton   )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~text_area.

        result = me.

        _generic(
              name  = 'TextArea'
                t_prop = VALUE #(
                  ( n = 'value' v = _get_name_by_ref( value ) )
                  ( n = 'rows' v = rows )
                  ( n = 'height' v = height )
                  ( n = 'width' v = width )
              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~time_picker.

        result = me.

        _generic(
         name   = 'TimePicker'
         t_prop = VALUE #(
              ( n = 'value' v =  value  )
              ( n = 'placeholder'  v = placeholder  )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~checkbox.

        result = me.

        _generic(
           name  = 'CheckBox'
           t_prop = VALUE #(
              ( n = 'text'  v = text )
              ( n = 'selected' v = selected )
          ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~progress_indicator.

        result = me.

        _generic(
             name  = 'ProgressIndicator'
             t_prop = VALUE #(
                ( n = 'percentValue' v = _get_name_by_ref( percent_value ) )
                ( n = 'displayValue' v = display_Value )
                ( n = 'showValue'    v = _=>get_abap_2_json( show_value  )      )
                ( n = 'state'        v = state  )
         ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~radiobutton_group.

        result = me.

        _generic(
         name   = 'RadioButtonGroup'
         t_prop = VALUE #(
                 ( n = 'columns' v = lines( t_prop ) )
                 ( n = 'selectedIndex' v = selected_index )
         ) ).

        LOOP AT t_prop REFERENCE INTO DATA(lr_prop).
          DATA(lv_tabix) = sy-tabix - 1.

          _generic(
            name   = 'RadioButton'
            t_prop = VALUE #(
               ( n = 'text' v = lr_prop->* )
             ) ).

        ENDLOOP.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~text.

        result = me.

        _generic(
          name  = 'Text'
          t_prop = VALUE #( ( n = 'text' v = text ) )
         ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~table.

        result = _generic(
            name  = 'Table'
            t_prop = VALUE #(
               ( n = 'items' v = items )
               ( n = 'growing' v = 'true' )
               ( n = 'growingThreshold' v = growing_threshold )
            ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~cells.

        result = _generic(  'cells' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~column.

        result = me.
        DATA(lo_col) = _generic(
            name  = 'Column'
              t_prop = VALUE #( ( n = 'width' v = width ) )
         ).

        lo_col->z2ui5_if_ui5_library~text( text ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~columns.

        result = _generic(  'columns' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~column_list_item.

        result = _generic(
            name = 'ColumnListItem'
            t_prop = VALUE #( ( n = 'vAlign' v = valign ) )
             ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~items.

        result = _generic(  'items' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~grid.

        result = _generic(
            name = 'Grid'
            ns   = 'l'
            t_prop = VALUE #(
                ( n = 'defaultSpan' v = default_span )
                ( n = 'class'       v = class )
                ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~header_toolbar.

        result = _generic( 'headerToolbar' ).

      ENDMETHOD.



      METHOD z2ui5_if_ui5_library~scroll_container.

        result = _generic(
             name = 'ScrollContainer'
             "  ns   = 'l'
            t_prop = VALUE #(
              ( n = 'height' v = height )
              ( n = 'width'       v = width )
              ( n = 'vertical'       v = 'true' )
              ( n = 'focusable'       v = 'true' )
              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~header_content.

        result = _generic( 'headerContent' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~sub_header.

        result = _generic( 'subHeader' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~footer.

        result = _generic( 'footer' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~dialog.

        result = _generic(
             name = 'Dialog'
             "  ns   = 'l'
            t_prop = VALUE #(
              ( n = 'title'  v = title )
              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~table_select_dialog.

        result = _generic(
             name = 'TableSelectDialog'
            t_prop = VALUE #(
              ( n = 'title' v = title )
              ( n = 'confirm'      v = _get_event_method( ` $event , { 'ID' : '` && event_id_confirm && `' } )` ) )
              ( n = 'cancel'       v = _get_event_method( `{ 'ID' : '` && event_id_cancel && `' }` ) )
              ( n = 'items' v = '{' && _get_name_by_ref( value = items ) && '}' )
              ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~list.

        result = _generic(
              name = 'List'
             t_prop = VALUE #(
               ( n = 'headerText' v = header_text )
               ( n = 'items' v = '{' && _get_name_by_ref( items ) && '}' )
               ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~standard_list_item.

        result = _generic(
          name = 'StandardListItem'
         t_prop = VALUE #(
           ( n = 'title' v = title )
           ( n = 'description' v = description )
           ( n = 'icon' v = icon )
               ) ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~message_page.

        result = _generic(
          name = 'MessagePage'
         t_prop = VALUE #(
           ( n = 'showHeader' v = _=>get_abap_2_json( show_header ) )
           ( n = 'description' v = description )
           ( n = 'icon' v = icon )
           ( n = 'text' v = text )
           ( n = 'enableFormattedText' v =  _=>get_abap_2_json( enable_formatted_text ) )
          ) ).


      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~buttons.

        result = _generic( 'buttons' ).

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~_bind.

        result = '{' && _get_name_by_ref( value = val  type = type ) && '}'.

      ENDMETHOD.

      METHOD z2ui5_if_ui5_library~get_parent.
        result = m_parent.
      ENDMETHOD.

    ENDCLASS.

    CLASS z2ui5_lcl_app_system DEFINITION.

      PUBLIC SECTION.

        INTERFACES  z2ui5_if_app.

        DATA:
          BEGIN OF ms_error,
            x_error   TYPE REF TO cx_root,
            app       TYPE REF TO z2ui5_if_app,
            classname TYPE string,
            kind      TYPE string,
          END OF ms_error.

        DATA:
          BEGIN OF ms_home,
            is_initialized         TYPE abap_bool,
            btn_text               TYPE string,
            btn_event_id           TYPE string,
            btn_icon               TYPE string,
            classname              TYPE string,
            class_value_state      TYPE string,
            class_value_state_text TYPE string,
            class_editable         TYPE abap_bool VALUE abap_true,
          END OF ms_home.

        CLASS-METHODS factory_error
          IMPORTING
            error           TYPE REF TO cx_root
            app             TYPE REF TO z2ui5_if_app OPTIONAL
            kind            TYPE string OPTIONAL
            "  server          TYPE REF TO z2ui5_lcl_runtime
          RETURNING
            VALUE(r_result) TYPE REF TO  z2ui5_lcl_app_system.

        TYPES: BEGIN OF ty_row,
                 id          TYPE string,
                 name        TYPE string,
                 value       TYPE string,
                 test1       TYPE string,
                 test2       TYPE string,
                 check_valid TYPE abap_bool,
               END OF ty_row.

        DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

      PROTECTED SECTION.
        METHODS a2ui5_on_init
          IMPORTING
            client TYPE REF TO z2ui5_if_client.
        METHODS a2ui5_on_event
          IMPORTING
            client TYPE REF TO z2ui5_if_client.
        METHODS a2ui5_on_rendering
          IMPORTING
            client TYPE REF TO z2ui5_if_client.

    ENDCLASS.

    CLASS z2ui5_lcl_app_system IMPLEMENTATION.

      METHOD z2ui5_if_app~controller.

        CASE client->get( )-lifecycle_method.

          WHEN client->cs-_lifecycle_method-on_init.
            a2ui5_on_init( client ).
          WHEN client->cs-_lifecycle_method-on_event.
            a2ui5_on_event( client ).
          WHEN client->cs-_lifecycle_method-on_rendering.
            a2ui5_on_rendering( client ).
        ENDCASE.
      ENDMETHOD.

      METHOD factory_error.

        r_result = NEW #( ).

        r_result->ms_error-x_error = error.
        r_result->ms_error-app     = app.
        r_result->ms_error-kind    = kind.

      ENDMETHOD.


      METHOD a2ui5_on_init.
        IF ms_error-x_error IS NOT BOUND.
          client->display_view( 'HOME' ).
        ELSE.
          client->display_view( 'ERROR' ).
        ENDIF.



        mt_tab = VALUE #( id = '010'
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ( name = 'Hans' value = 'red' test1 = 'das ist ein langer text' test2 = 'das ist noch ein langer text' check_valid = abap_true )
            ).

        " ms_home-classname = 'test'.
      ENDMETHOD.


      METHOD a2ui5_on_event.

        CASE client->get( )-screen_active.

          WHEN 'HOME'.
            CASE client->get( )-event_id.

              WHEN 'BUTTON_CHANGE'.
                ms_home-btn_text = 'check'.
                ms_home-btn_event_id = 'BUTTON_CHECK'.
                ms_home-btn_icon = 'sap-icon://validate'.
                ms_home-class_editable = abap_true.

              WHEN 'POPUP_SELECT_TABLE'.
                client->display_popup( 'POPUP_TABLE' ).

              WHEN 'BUTTON_CHECK'.

                " data(test) = 1 / 0.

                TRY.
                    DATA li_app_test TYPE REF TO z2ui5_if_app.
                    ms_home-classname = to_upper( ms_home-classname ).
                    CREATE OBJECT li_app_test TYPE (ms_home-classname).

                    client->display_message_toast( 'App is ready to start!' ).
                    ms_home-btn_text = 'edit'.
                    ms_home-btn_event_id = 'BUTTON_CHANGE'.
                    ms_home-btn_icon = 'sap-icon://edit'.
                    ms_home-class_value_state = z2ui5_if_client=>cs-input-value_state-success.
                    ms_home-class_editable = abap_false.

                  CATCH cx_root INTO DATA(lx).
                    ms_home-class_value_state_text = lx->get_text( ).
                    ms_home-class_value_state = z2ui5_if_client=>cs-input-value_state-warning.
                    client->display_message_box(
                        text = ms_home-class_value_state_text
                        type = z2ui5_if_client=>cs-message_box-type-error
                         ).
                ENDTRY.
            ENDCASE.

          WHEN 'ERROR'.
            CASE client->get( )-event_id.

              WHEN 'BUTTON_HOME'.
                client->nav_to_app( NEW z2ui5_lcl_app_system( ) ).
            ENDCASE.
        ENDCASE.

        "client->display_view( client->get( )-screen_active ).
      ENDMETHOD.


      METHOD a2ui5_on_rendering.

        DATA(lo_view) = client->factory_view( 'HOME' ).

        DATA(lo_page) = lo_view->page( 'ABAP2UI5 - Home' ).
        lo_page->header_content(
            )->link( text = 'Twitter' href = 'https://twitter.com/OblomovDev'
            )->link( text = 'abapGit' href = 'https://github.com/oblomov-dev/abap2ui5'
          "  )->add_button( text = 'Demos'
        ).



        DATA(lo_grid) = lo_page->grid( default_span  = 'L12 M12 S12' )->content( 'l' ).
        DATA(lo_form) = lo_grid->simple_form( 'Quick Start' )->content( 'f' ).

*        lo_form = lo_form->add_vbox( ).
*        lo_form->add_input( product ).
*        lo_form->add_button( text = 'POPUP_SELECT_TABLE' on_press_id = 'POPUP_SELECT_TABLE' ).
*        lo_form->add_input( product ).
*        lo_form->add_button( text = 'BAL Anzeige' on_press_id = 'BUTTON_BAL' ).
*
*        lo_form = lo_grid->add_simple_form( title = 'test' )->add_content( 'f' ).
*        lo_form->add_title( 'new title' ).
*        lo_form = lo_form->add_vbox( ).




*    data(lo_content) = lo_page->add_content( ).
*    DATA(lo_form) = lo_content->add_simple_form( 'Quick Start'
        " lo_form->add_title( ':'
        lo_form->label( 'Step 1'
          )->text( 'Create a new global class in the abap system'
          )->label( 'Step 2'
          )->text( 'Implement the interface Z2UI5_IF_APP'
          )->label( 'Step 3'
          )->text( 'Define the views in the method set_view and the behaviour in the method on_event '
          )->label( 'Step 4'
        ).

        IF ms_home-class_editable = abap_true.
          lo_form->input(
                         value          = lo_form->_bind( ms_home-classname )
                         placeholder    = 'fill in the classname and press check'
                         value_state      = ms_home-class_value_state
                         value_state_text = ms_home-class_value_state_text
                         editable         = ms_home-class_editable
                    ).
        ELSE.
          lo_form->text( ms_home-classname ).
        ENDIF.

        lo_form->button( text = ms_home-btn_text on_press_id = 'BUTTON_CHECK'  icon = ms_home-btn_icon ).  "type = view->cs-button-type-
        lo_form->button( text = ms_home-btn_text on_press_id = 'POPUP_SELECT_TABLE'  icon = ms_home-btn_icon   "type = view->cs-button-type-
                 )->label( 'Step 5' ).

        IF ms_home-class_editable = abap_false.
          lo_form->link( text = 'Link to the Application'
                  href = _=>get_server_info(  app = ms_home-classname )-url_app " 'https://' && lv_url && '' && '?sap-client=' && lv_tenant && '&amp;app=' && ms_home-classname
               ).
        ENDIF.


        lo_grid = lo_page->grid( default_span  = 'L4 M6 S12' )->content( 'l' ).

        lo_form = lo_grid->simple_form(  'Demo - Selection-Screen' )->content( 'f' ).

        " lo_form->add_title( ':'
        lo_form->label( 'Selection-Screen'
           )->text( 'Z2UI5_CL_APP_01'
           )->label( 'Write Output'
           )->text( 'Z2UI5_CL_APP_01'
           )->label( 'Table (ALV)'
           )->text( 'Z2UI5_CL_APP_01'
         ).

        lo_form = lo_grid->simple_form(  'Demo - Write Output' )->content( 'f' ).

        " lo_form->add_title( ':'
        lo_form->label( 'Write Output'
           )->text( 'Z2UI5_CL_APP_01'
           )->label( 'Write Output'
           )->text( 'Z2UI5_CL_APP_01'
           )->label( 'Table (ALV)'
           )->text( 'Z2UI5_CL_APP_01'
         ).

        lo_form = lo_grid->simple_form(  'Demo - Table Output (ALV)' )->content( 'f' ).

        " lo_form->add_title( ':'
        lo_form->label( 'Selection-Screen'
           )->text( 'Z2UI5_CL_APP_01'
           )->label( 'Write Output'
           )->text( 'Z2UI5_CL_APP_01'
           )->label( 'Table (ALV)'
           )->text( 'Z2UI5_CL_APP_01'
         ).




        lo_page->footer( )->overflow_toolbar(  )->toolbar_spacer(
*         )->add_link( text = 'Link to the Application'
*              href = _=>get_server_info(  app = ms_home-classname )-url_app " 'https://' && lv_url && '' && '?sap-client=' && lv_tenant && '&amp;app=' && ms_home-classname
*        )->add_button( text = 'Start' type = client->cs-button-type-success
            ).




        IF ms_error-x_error IS BOUND.
          client->factory_view( 'ERROR' )->message_page(
              text = ms_error-classname
              description = ms_error-x_error->get_text( )
              )->buttons(
            )->button(
                  text = 'HOME'
                  on_press_id = 'BUTTON_HOME'
          "  )->add_button(
          "        text = 'Neustart'
          "           on_press_id = 'RESTART'
            ).
        ENDIF.


        lo_view = client->factory_view( 'POPUP_TABLE' ).

        DATA(lo_tab) = lo_view->table_select_dialog(
                    title            = 'title'
                    event_id_confirm = 'TAB_CONFIRM'
                    event_id_cancel  = 'TAB_CANCEL'
                    items            = mt_tab
                 ).

        lo_tab->column_list_item( )->cells(
        )->text( '{NAME}'
        )->text( '{VALUE}'
        )->button( text = '{TEST1}' on_press_id = '{NAME}'
        )->input( value = '{TEST2}'
        )->checkbox( selected = '{CHECK_VALID}'
).
        lo_tab->columns( )->column( text = 'Name'
        )->column( text = 'Value'
        )->column( text = 'Test1'
        )->column( text = 'Test2'
        )->column( text = 'Checkbox'
        ).

      ENDMETHOD.

    ENDCLASS.

    CLASS z2ui5_lcl_client DEFINITION.

      PUBLIC SECTION.

        INTERFACES z2ui5_if_client.

        DATA mo_server TYPE REF TO z2ui5_lcl_runtime.

        METHODS constructor
          IMPORTING
            i_server TYPE REF TO z2ui5_lcl_runtime.

    ENDCLASS.


    CLASS z2ui5_lcl_runtime DEFINITION.

      PUBLIC SECTION.

        TYPES:
          BEGIN OF s_screen,
            name          TYPE string,
            check_binding TYPE abap_bool,
            o_parser      TYPE REF TO z2ui5_lcl_ui5_library,
            t_controls    TYPE STANDARD TABLE OF _=>ty-s-control WITH EMPTY KEY,
          END OF s_screen.

        DATA:
          BEGIN OF ms_control,
            event_type TYPE string,
          END OF ms_control.

        DATA:
          BEGIN OF ms_db,
            id                TYPE string,
            id_prev           TYPE string,
            id_prev_app       TYPE string,
            app               TYPE string,
            screen            TYPE string,
            check_no_rerender TYPE abap_bool,
            screen_popup      TYPE string,
            t_attri           TYPE _=>ty-t-attri,
            o_app             TYPE REF TO object,
          END OF ms_db.

        DATA mt_after TYPE STANDARD TABLE OF string_table WITH EMPTY KEY.
        DATA mt_screen TYPE STANDARD TABLE OF s_screen.
        DATA ms_leave_to_app LIKE ms_db.

        METHODS constructor RAISING cx_uuid_error.

        METHODS db_save.

        METHODS db_load
          IMPORTING
            id              TYPE string
          RETURNING
            VALUE(r_result) LIKE ms_db.

        METHODS execute_init
          RETURNING
            VALUE(ro_model) TYPE REF TO z2ui5_lcl_runtime.

        METHODS execute_finish
          RETURNING
            VALUE(r_result) TYPE string.

        METHODS init_app_prev.

        METHODS init_app_new.

        METHODS factory_new_error
          IMPORTING
            kind            TYPE string
            ix              TYPE REF TO cx_root
          RETURNING
            VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime.

        METHODS factory_new
          IMPORTING
            i_app           TYPE REF TO z2ui5_if_app
          RETURNING
            VALUE(r_result) TYPE REF TO z2ui5_lcl_runtime.

        DATA x TYPE REF TO cx_root.

      PRIVATE SECTION.

    ENDCLASS.

    CLASS z2ui5_lcl_runtime IMPLEMENTATION.

      METHOD constructor.

        ms_db-id = _=>get_uuid( ).

      ENDMETHOD.

      METHOD db_load.

        SELECT SINGLE FROM z2ui5_t_draft
            FIELDS
                data
           WHERE uuid = @id
          INTO @DATA(lv_data).

        _=>trans_xml_2_object(
          EXPORTING
            xml    = lv_data
           IMPORTING
            data   = r_result
        ).

      ENDMETHOD.

      METHOD db_save.

        MODIFY z2ui5_t_draft FROM @( VALUE #(
          uuid  = ms_db-id
          uname = _=>get_user_tech( )
          timestampl = _=>get_timestampl( )
          data  = _=>trans_object_2_xml( REF #( ms_db ) )
          ) ).
        COMMIT WORK.

      ENDMETHOD.


      METHOD execute_init.

        TRY.
            ms_db-id_prev = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OSYSTEM' )->get_attribute( 'ID')->get_val( ).
          CATCH cx_root.
        ENDTRY.

        IF ms_db-id_prev IS INITIAL.
          init_app_new( ).
        ELSE.
          init_app_prev( ).
        ENDIF.

      ENDMETHOD.


      METHOD execute_finish.

        x = COND #( WHEN lines( mt_screen ) = 0 THEN THROW _( 'no view defined in method set_view' ) ).

        IF ms_db-screen IS INITIAL.
          DATA(lr_screen) = REF #( mt_screen[ 1 ] ).
          ms_db-screen = lr_screen->name.
        ELSE.
          lr_screen = REF #( mt_screen[ name = ms_db-screen ] ).
        ENDIF.


        DATA(lo_ui5_model) = z2ui5_cl_hlp_tree_json=>factory( ).

        DATA(ls_view) = lr_screen->o_parser->get_view(  ).
        ms_db-t_attri = ls_view-t_attri.
        lo_ui5_model->add_attribute( n = `vView` v = ls_view-xml ).
        ls_view-o_model->mv_name = 'oViewModel'.
        lo_ui5_model->add_attribute_instance( ls_view-o_model ).


        DATA(lo_system) = lo_ui5_model->add_attribute_object( 'oSystem' ).
        lo_system->add_attribute( n = 'ID' v = ms_db-id ).
        lo_system->add_attribute( n = 'ID_PREV' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-debug_mode_on ) ).
        "    lo_ui5_model->add_attribute( n = 'CHECK_POPUP_ACTIVE' v = ''  apos_active = abap_false ).
        lo_system->add_attribute( n = 'CHECK_DEBUG_ACTIVE' v = _=>get_abap_2_json( z2ui5_cl_http_handler=>cs_config-debug_mode_on )  apos_active = abap_false ).


        IF mt_after IS NOT INITIAL.
          DATA(lo_list) = lo_ui5_model->add_attribute_list( 'oAfter' ).
          LOOP AT mt_after REFERENCE INTO DATA(lr_after).
            DATA(lo_list2) = lo_list->add_list_list(  ).
            LOOP AT lr_after->* REFERENCE INTO DATA(lr_con).
              lo_list2->add_list_val( lr_con->* ).
            ENDLOOP.
          ENDLOOP.
        ENDIF.

        r_result = lo_ui5_model->get_root( )->write_result( ).
        db_save( ).

      ENDMETHOD.


      METHOD init_app_prev.

        ms_db = CORRESPONDING #( BASE ( ms_db ) db_load( ms_db-id_prev ) EXCEPT id id_prev ).

        LOOP AT ms_db-t_attri REFERENCE INTO DATA(lr_attri)
            WHERE bind_type = z2ui5_if_ui5_library=>cs-_bind_type-two_way. " check_used = abap_true AND check_update = abap_true.

          lr_attri->bind_type = ''.

          FIELD-SYMBOLS <attribute> TYPE any.
          DATA(lv_name) = |MS_DB-O_APP->{ to_upper( lr_attri->name ) }|.
          ASSIGN (lv_name) TO <attribute>.

          CASE lr_attri->kind.

            WHEN 'g' OR 'I' OR 'C'.
              DATA(lv_value) = z2ui5_cl_http_handler=>client-o_body->get_attribute( lr_attri->name )->get_val( ).
              <attribute> = lv_value.

            WHEN 'h'.
              _=>trans_ref_tab_2_tab(
                         ir_tab_from = z2ui5_cl_http_handler=>client-o_body->get_attribute( lr_attri->name )->mr_actual
                         ir_tab_to   = REF #( <attribute> )          ).

          ENDCASE.

        ENDLOOP.

        ms_control-event_type = z2ui5_if_client=>cs-_lifecycle_method-on_event.
      ENDMETHOD.


      METHOD init_app_new.
        DO.
          TRY.

              z2ui5_cl_http_handler=>client-t_param = VALUE #( LET tab = z2ui5_cl_http_handler=>client-t_param IN FOR row IN tab
                ( name = to_upper( row-name ) value = to_upper( row-value ) ) ).

              TRY.
                  ms_db-app = z2ui5_cl_http_handler=>client-t_param[ name = 'APP' ]-value.
                CATCH cx_root.
                  ms_db-o_app = NEW z2ui5_lcl_app_system( ).
                  EXIT.
              ENDTRY.

              CREATE OBJECT ms_db-o_app TYPE (ms_db-app).
              EXIT.

            CATCH cx_root.
              DATA(lo_error) = NEW z2ui5_lcl_app_system( ).
              lo_error->ms_error-x_error = NEW _( val = `Class with name ` && ms_db-app && ` not found. Please check your repository.` ).
              ms_db-o_app = CAST #( lo_error ).
              EXIT.
          ENDTRY.
        ENDDO.

        ms_db-app     = _=>get_classname_by_ref( ms_db-o_app ).
        ms_db-t_attri = _=>hlp_get_t_attri( ms_db-o_app ).

        ms_control-event_type = z2ui5_if_client=>cs-_lifecycle_method-on_init.

      ENDMETHOD.

      METHOD factory_new.

        r_result = NEW z2ui5_lcl_runtime( ).
        r_result->ms_db-o_app = i_app.
        r_result->ms_db-app = _=>get_classname_by_ref( i_app ).
        CLEAR z2ui5_cl_http_handler=>client-o_body.
        r_result->mt_after = mt_after.
        r_result->ms_db-t_attri = _=>hlp_get_t_attri( r_result->ms_db-o_app ).

      ENDMETHOD.

      METHOD factory_new_error.

        r_result = factory_new(
                 z2ui5_lcl_app_system=>factory_error( error = ix app = CAST #( me->ms_db-o_app ) kind = kind ) ).

        r_result->ms_control-event_type = z2ui5_if_client=>cs-_lifecycle_method-on_init.
      ENDMETHOD.

    ENDCLASS.

    CLASS z2ui5_lcl_client IMPLEMENTATION.

      METHOD constructor.

        me->mo_server = i_server.

      ENDMETHOD.


      METHOD z2ui5_if_client~display_message_toast.

        INSERT VALUE #( ( `MessageToast` ) ( `show` ) ( text ) )
             INTO TABLE mo_server->mt_after.

      ENDMETHOD.

      METHOD z2ui5_if_client~display_message_box.

        INSERT VALUE #( ( `MessageBox` ) ( type ) ( text ) )
          INTO TABLE mo_server->mt_after.

      ENDMETHOD.

      METHOD z2ui5_if_client~display_view.

        mo_server->ms_db-screen = val.
        mo_server->ms_db-check_no_rerender = check_no_rerender.

      ENDMETHOD.

      METHOD z2ui5_if_client~factory_view.

        result = z2ui5_lcl_ui5_library=>factory(
            t_attri = mo_server->ms_db-t_attri
            o_app   = CAST #( mo_server->ms_db-o_app )
             ).
        INSERT VALUE #( name = name o_parser = CAST #(  result  ) ) INTO TABLE mo_server->mt_screen.

      ENDMETHOD.

      METHOD z2ui5_if_client~nav_to_home.

        z2ui5_if_client~nav_to_app( NEW z2ui5_lcl_app_system( ) ).

      ENDMETHOD.

      METHOD z2ui5_if_client~get.

        result = VALUE #(
            lifecycle_method = mo_server->ms_control-event_type
            check_call_satck = xsdbool( mo_server->ms_db-id_prev_app IS NOT INITIAL )
            screen_active = mo_server->ms_db-screen
        ).

        TRY.
            result-event_id = z2ui5_cl_http_handler=>client-o_body->get_attribute( 'OEVENT' )->get_attribute( 'ID' )->get_val( ).
          CATCH cx_root.
        ENDTRY.

      ENDMETHOD.

      METHOD z2ui5_if_client~get_app_called.

        DATA(x) = COND i( WHEN mo_server->ms_db-id_prev_app IS INITIAL THEN THROW _('CX_STACK_EMPTY - NO CALLING APP FOUND') ).
        result = CAST #( mo_server->db_load( mo_server->ms_db-id_prev_app )-o_app ).

      ENDMETHOD.

      METHOD z2ui5_if_client~nav_to_app.

        mo_server->ms_leave_to_app = VALUE #( o_app = app ).

      ENDMETHOD.

      METHOD z2ui5_if_client~display_popup.

        mo_server->ms_db-screen_popup = name.

      ENDMETHOD.

    ENDCLASS.
