CLASS z2ui5_cl_xml_view_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES z2ui5_if_view.

    CONSTANTS:
      BEGIN OF cs_config,
        letterboxing TYPE abap_bool VALUE abap_true,
      END OF cs_config.

    TYPES:
      BEGIN OF ty_attri,
        name           TYPE string,
        type_kind      TYPE string,
        bind_type      TYPE string,
        data_stringify TYPE string,
      END OF ty_attri.

    TYPES ty_T_attri TYPE STANDARD TABLE OF ty_attri WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_s_name_value,
        n TYPE string,
        v TYPE string,
      END OF ty_s_name_value.

    TYPES ty_t_name_value TYPE STANDARD TABLE OF ty_s_name_value WITH EMPTY KEY.

    DATA m_name TYPE string.
    DATA m_ns   TYPE string.
    DATA mt_prop TYPE z2ui5_if_client=>ty_t_name_value.

    DATA m_root    TYPE REF TO z2ui5_cl_xml_view_helper.
    DATA m_last    TYPE REF TO z2ui5_cl_xml_view_helper.
    DATA m_parent  TYPE REF TO z2ui5_cl_xml_view_helper.
    DATA t_child TYPE STANDARD TABLE OF REF TO z2ui5_cl_xml_view_helper WITH EMPTY KEY.

    CLASS-METHODS factory
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_view.

    METHODS _generic
      IMPORTING
        name          TYPE clike
        ns            TYPE clike OPTIONAL
        t_prop        TYPE ty_t_name_value OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_view.

    METHODS xml_get_begin
      RETURNING
        VALUE(result) TYPE string.

    METHODS constructor
      IMPORTING
        ns TYPE string_table OPTIONAL.
    METHODS xml_get_end
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA: lt_ns TYPE string_table.

ENDCLASS.



CLASS z2ui5_cl_xml_view_helper IMPLEMENTATION.

  METHOD constructor.

    IF ns IS NOT SUPPLIED.

      lt_ns = VALUE string_table(
      ( `xmlns="sap.m"` )
      ( `xmlns:z2ui5="z2ui5"` )
      ( `xmlns:core="sap.ui.core"` )
      ( `xmlns:mvc="sap.ui.core.mvc"` )
      ( `xmlns:l="sap.ui.layout"` )
      ( `xmlns:f="sap.ui.layout.form"` )
      ( `xmlns:editor="sap.ui.codeeditor"` )
      ( `xmlns:ui="sap.ui.table"` )
      ( `xmlns:mchart="sap.suite.ui.microchart"` )
      ( `xmlns:webc="sap.ui.webc.main"` )
      ( `xmlns:uxap="sap.uxap"` )
      ( `xmlns:sap="sap"` )
      ( `xmlns:text="sap.ui.richtexteditor"` )
      ( `xmlns:html="http://www.w3.org/1999/xhtml"` )
       ).

    ENDIF.

  ENDMETHOD.


  METHOD xml_get_begin.

    result = `<mvc:View controllerName="z2ui5_controller" displayBlock="true" height="100%" `.
    LOOP AT lt_ns REFERENCE INTO DATA(lr_ns).
      result = result && ` ` && lr_ns->* && ` `.
    ENDLOOP.
    result = result && `>`.
    result = result && COND #( WHEN cs_config-letterboxing = abap_true THEN `<Shell>` ).

  ENDMETHOD.

  METHOD xml_get_end.

    result = COND #( WHEN cs_config-letterboxing = abap_true THEN `</Shell>` ) && `</mvc:View>` .

  ENDMETHOD.

  METHOD z2ui5_if_view~xml_get.

    "case - root
    IF me = m_root.

      IF t_child IS INITIAL.
        RETURN.
      ENDIF.

      result = xml_get_begin( ).

      LOOP AT t_child INTO DATA(lr_child).
        result = result && CAST z2ui5_if_view( lr_child )->xml_get( ).
      ENDLOOP.

      result = result && xml_get_end(  ).
      RETURN.
    ENDIF.

    "case - normal
    CASE m_name.
      WHEN `ZZHTML`.
        result = mt_prop[ name = `VALUE` ]-value.
        RETURN.
    ENDCASE.

    DATA(lv_tmp2) = COND #( WHEN m_ns <> `` THEN |{ m_ns }:| ).
    DATA(lv_tmp3) = REDUCE #( INIT val = `` FOR row IN mt_prop WHERE ( value <> `` )
                          NEXT val = |{ val } { row-name }="{ escape( val = COND string( WHEN row-value = abap_true THEN `true` ELSE row-value ) format = cl_abap_format=>e_xml_attr ) }" \n | ).

    result = |{ result } <{ lv_tmp2 }{ m_name } \n { lv_tmp3 }|.

    IF t_child IS INITIAL.
      result = |{ result }/>|.
      RETURN.
    ENDIF.

    result = |{ result }>|.

    LOOP AT t_child INTO lr_child.
      result = result && CAST z2ui5_if_view( lr_child )->xml_get( ).
    ENDLOOP.

    DATA(lv_ns) = COND #( WHEN m_ns <> || THEN |{ m_ns }:| ).
    result = |{ result }</{ lv_ns }{ m_name }>|.

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

  METHOD z2ui5_if_view~_generic.

    result = _generic(
       name   = name
       ns     = ns
       t_prop = t_prop ).

  ENDMETHOD.

  METHOD factory.

    " result = NEW #( ).
    DATA(lo_tree) = NEW z2ui5_cl_xml_view_helper( ).
    lo_tree->m_root = lo_tree.
    lo_tree->m_parent = lo_tree.
    result = lo_tree.
    "   result->mo_runtime = runtime.

  ENDMETHOD.

  METHOD z2ui5_if_view~overflow_toolbar_button.

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

  METHOD z2ui5_if_view~custom_data.

    result = _generic(
       `customData`
        ).

  ENDMETHOD.

  METHOD z2ui5_if_view~formatted_text.

    result = me.
    _generic(
       name   = `FormattedText`
       t_prop = VALUE #(
          ( n = `htmlText`   v = htmltext )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~badge_custom_data.

    result = me.
    _generic(
       name   = `BadgeCustomData`
       t_prop = VALUE #(
          ( n = `key`      v = key )
          ( n = `value`    v = value )
          ( n = `visible`  v = _=>get_json_boolean( visible ) )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~toggle_button.

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

  METHOD z2ui5_if_view~button.

    result = me.
    _generic(
       name   = `Button`
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

  METHOD z2ui5_if_view~input.

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

  METHOD z2ui5_if_view~page.

    result = _generic(
        name   = `Page`
         t_prop = VALUE #(
             ( n = `title` v = title )
             ( n = `showNavButton`  v = _=>get_json_boolean( shownavbutton ) )
             ( n = `navButtonPress` v = navbuttonpress )
             ( n = `class` v = class )
             ( n = `id` v = id )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~vbox.

    result = _generic(
         name   = `VBox`
         t_prop = VALUE #(
            ( n = `height` v = height )
            ( n = `class`  v = class )
         ) ).

  ENDMETHOD.


  METHOD z2ui5_if_view~hbox.

    result = _generic(
          name   = `HBox`
          t_prop = VALUE #(
            ( n = `class` v = class )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~simple_form.

    result = _generic(
      name   = `SimpleForm`
      ns     = `f`
      t_prop = VALUE #(
        ( n = `title`    v = title )
        ( n = `layout`   v = layout )
        ( n = `editable` v = _=>get_json_boolean( editable ) )
      ) ).

  ENDMETHOD.


  METHOD z2ui5_if_view~content.

    result = _generic( ns = ns name = `content` ).

  ENDMETHOD.


  METHOD z2ui5_if_view~title.

    result = me.
    _generic(
         name  = `Title`
         t_prop = VALUE #(
             ( n = `text`     v = text )
             ( n = `wrapping` v = _=>get_json_boolean( wrapping ) )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~code_editor.

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

  METHOD z2ui5_if_view~zz_file_uploader.

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

  METHOD z2ui5_if_view~zz_html.

    SPLIT val AT `<` INTO TABLE DATA(lt_table).

    DATA(lv_html) = ``.
    lv_html = VALUE #( lt_table[ 1 ] OPTIONAL ).

    LOOP AT lt_table REFERENCE INTO DATA(lr_line) FROM 2.
      IF lr_line->*(1) = `/`.
        lv_html = `</html:` && lr_line->*.
      ELSE.
        lv_html = `<html:` && lr_line->*.
      ENDIF.
    ENDLOOP.

    result = me.
    _generic(
         name  = `ZZHTML`
         t_prop = VALUE #( ( n = `VALUE` v = lv_html ) )
    ).

  ENDMETHOD.

  METHOD z2ui5_if_view~overflow_toolbar.

    result = _generic( `OverflowToolbar` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~toolbar_spacer.

    result = me.
    _generic( `ToolbarSpacer` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~combobox.

    result = _generic(
       name  = `ComboBox`
       t_prop = VALUE #(
          (  n = `showClearIcon` v = _=>get_json_boolean( showclearicon ) )
          (  n = `selectedKey`   v = selectedkey )
          (  n = `items`         v = items )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~date_picker.

    result = me.
    _generic(
      name       = `DatePicker`
      t_prop = VALUE #(
          ( n = `value` v = value )
          ( n = `placeholder` v = placeholder )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~date_time_picker.

    result = me.
    _generic(
        name  = `DateTimePicker`
        t_prop = VALUE #(
            ( n = `value` v = value )
            ( n = `placeholder`  v = placeholder )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~label.

    result = me.
    _generic(
       name  = `Label`
       t_prop = VALUE #(
           ( n = `text` v = text )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~image.

    result = me.
    _generic(
       name  = `Image`
       t_prop = VALUE #(
           ( n = `src` v = src )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~link.

    result = me.
    _generic(
     name  = `Link`
       t_prop = VALUE #(
         ( n = `text`   v = text )
         ( n = `target` v = `_blank` )
         ( n = `href`   v = href )
         ( n = `enabled`   v = _=>get_json_boolean( enabled ) )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segmented_button.

    result = _generic(
       name  = `SegmentedButton`
       t_prop = VALUE #(
        ( n = `selectedKey` v = selected_key )
        ( n = `selectionChange` v = selection_change )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~step_input.

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

  METHOD z2ui5_if_view~switch.

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

  METHOD z2ui5_if_view~range_slider.

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

  METHOD z2ui5_if_view~generic_tag.

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

  METHOD z2ui5_if_view~object_number.

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

  METHOD z2ui5_if_view~text_area.

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

  METHOD z2ui5_if_view~time_picker.

    result = me.
    _generic(
     name   = `TimePicker`
     t_prop = VALUE #(
          ( n = `value` v = value )
          ( n = `placeholder`  v = placeholder )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~checkbox.

    result = me.
    _generic(
       name  = `CheckBox`
       t_prop = VALUE #(
          ( n = `text`     v = text )
          ( n = `selected` v = selected )
          ( n = `enabled`  v = _=>get_json_boolean( enabled ) )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~progress_indicator.

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

  METHOD z2ui5_if_view~text.

    result = me.
    _generic(
      name  = `Text`
      t_prop = VALUE #(
        ( n = `text`  v = text )
        ( n = `class` v = class )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~table.

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

  METHOD z2ui5_if_view~cells.

    result = _generic( `cells` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~column.

    result = _generic(
        name  = `Column`
          t_prop = VALUE #( ( n = `width` v = width ) )
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~columns.

    result = _generic( `columns` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~column_list_item.

    result = _generic(
        name = `ColumnListItem`
        t_prop = VALUE #( ( n = `vAlign`   v = valign )
                          ( n = `selected` v = selected )
       ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~items.

    result = _generic( `items` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~grid.

    result = _generic(
        name = `Grid`
        ns   = `l`
        t_prop = VALUE #(
            ( n = `defaultSpan` v = default_span )
            ( n = `class`       v = class )
            ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~header_toolbar.

    result = _generic( `headerToolbar` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~scroll_container.

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

  METHOD z2ui5_if_view~header_content.

    result = _generic(
        name = `headerContent`
        ns   = ns
         ).

  ENDMETHOD.

  METHOD z2ui5_if_view~sub_header.

    result = _generic( `subHeader` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~footer.

    result = _generic( `footer` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~dialog.

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

  METHOD z2ui5_if_view~list.

    result = _generic(
        name = `List`
        t_prop = VALUE #(
          ( n = `headerText` v = headertext )
          ( n = `items` v = items )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~standard_list_item.

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

  METHOD z2ui5_if_view~message_page.

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

  METHOD z2ui5_if_view~buttons.

    result = _generic( `buttons` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~get_parent.
    result = m_parent.
  ENDMETHOD.

  METHOD z2ui5_if_view~message_strip.

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

  METHOD z2ui5_if_view~list_item.

    result = me.
    _generic(
        name   = `ListItem`
        ns     = `core`
        t_prop = VALUE #(
            ( n = `text` v = text )
            ( n = `additionalText` v = additionaltext ) ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~suggestion_items.

    result = _generic( `suggestionItems` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~item.

    result = me.
    _generic(
       name = `Item`
       ns = `core`
       t_prop = VALUE #(
           ( n = `key`  v = key )
           ( n = `text` v = text )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~segmented_button_item.

    result = me.
    _generic(
        name = `SegmentedButtonItem`
        t_prop = VALUE #(
            ( n = `icon`  v = icon )
            ( n = `key`   v = key )
            ( n = `text`  v = text )
      ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~get_child.

    result = t_child[ index ].

  ENDMETHOD.

  METHOD z2ui5_if_view~get.

    result = m_root->m_last.

  ENDMETHOD.

  METHOD z2ui5_if_view~flex_box.

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
        ) ).


  ENDMETHOD.

  METHOD z2ui5_if_view~popover.

    result = _generic(
          name   = `Popover`
          t_prop = VALUE #(
                      ( n = `title`  v = title )
                      ( n = `class`  v = class )
                      ( n = `placement`  v = placement )
                      ( n = `initialFocus`  v = initialFocus )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~horizontal_layout.

    result = _generic(
        name   = `HorizontalLayout`
        ns     = `l`
        t_prop = VALUE #(
                     ( n = `class`  v = class )
                     ( n = `width`  v = width )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~vertical_layout.

    result = _generic(
        name   = `VerticalLayout`
        ns     = `l`
        t_prop = VALUE #(
                     ( n = `class`  v = class )
                     ( n = `width`  v = width )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~flex_item_data.

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

  METHOD z2ui5_if_view~grid_data.

    result = me.
    _generic(
           name = `GridData`
           ns = `l`
        t_prop = VALUE #(
            ( n = `span`  v = span )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~layout_data.

    result = _generic(
            ns = ns
           name = `layoutData`
       ).

  ENDMETHOD.

  METHOD z2ui5_if_view~tab.

    result = _generic(
         name = `Tab`
         ns = `webc`
         t_prop = VALUE #(
             ( n = `text`     v = text )
             ( n = `selected` v = selected )
         ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~tab_container.

    result = _generic(
        name = `TabContainer`
        ns   = `webc` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~bars.

    result = _generic(
        name = `bars`
        ns   = `mchart` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~interact_bar_chart.

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

  METHOD z2ui5_if_view~interact_bar_chart_bar.

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

  METHOD z2ui5_if_view~interact_donut_chart.

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

  METHOD z2ui5_if_view~interact_donut_chart_segment.

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

  METHOD z2ui5_if_view~interact_line_chart.

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

  METHOD z2ui5_if_view~interact_line_chart_point.

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

  METHOD z2ui5_if_view~points.

    result = _generic(
         name = `points`
         ns   = `mchart` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~radial_micro_chart.

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

  METHOD z2ui5_if_view~segments.

    result = _generic(
        name = `segments`
        ns   = `mchart` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~multi_input.

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

  METHOD z2ui5_if_view~token.

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

  METHOD z2ui5_if_view~tokens.

    result = _generic( `tokens` ).

  ENDMETHOD.

  METHOD z2ui5_if_view~actions.

    result = _generic(
        name   = `actions`
        ns     = `uxap`
      ).

  ENDMETHOD.

  METHOD z2ui5_if_view~avatar.

    result = me.
    _generic(
        name   = `Avatar`
        t_prop = VALUE #(
            ( n = `src`      v = src )
            ( n = `class`    v = class )
    ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~blocks.

    result = _generic(
        name   = `blocks`
        ns     = `uxap`
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~expanded_heading.

    result = _generic(
        name   = `expandedHeading`
        ns     = `uxap`
    ).

  ENDMETHOD.

  METHOD z2ui5_if_view~heading.

    result = me.
    result = _generic(
        name   = `heading`
        ns     = `uxap`
    ).

  ENDMETHOD.

  METHOD z2ui5_if_view~object_page_dyn_header_title.

    result = _generic(
        name   = `ObjectPageDynamicHeaderTitle`
        ns     = `uxap`
    ).

  ENDMETHOD.

  METHOD z2ui5_if_view~object_page_layout.

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

  METHOD z2ui5_if_view~object_page_section.

    result = _generic(
        name   = `ObjectPageSection`
        ns     = `uxap`
        t_prop = VALUE #(
            ( n = `titleUppercase`  v = titleUppercase )
            ( n = `title`           v = title )
    ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~object_page_sub_section.

    result = _generic(
        name   = `ObjectPageSubSection`
        ns     = `uxap`
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~sections.

    result = _generic(
        name   = `sections`
        ns     = `uxap`
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~snapped_heading.

    result = me.
    result = _generic(
        name   = `snappedHeading`
        ns     = `uxap`
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~sub_sections.

    result = me.
    result = _generic(
        name   = `subSections`
        ns     = `uxap`
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~header_title.

    result = _generic(
        name   = `headerTitle`
        ns     = `uxap`
     ).

  ENDMETHOD.

  METHOD z2ui5_if_view~expanded_content.

    result = _generic(
         name   = `expandedContent`
         ns     = `uxap`
      ).

  ENDMETHOD.

  METHOD z2ui5_if_view~snapped_content.

    result = _generic(
         name   = `snappedContent`
         ns     = `uxap`
      ).

  ENDMETHOD.

  METHOD z2ui5_if_view~snapped_title_on_mobile.

    result = _generic(
         name   = `snappedTitleOnMobile`
         ns     = `uxap`
      ).

  ENDMETHOD.

  METHOD z2ui5_if_view~get_root.

    result = m_root.

  ENDMETHOD.

  METHOD z2ui5_if_view~template_if.

    result = _generic(
            name   = `if`
            ns     = `template`
            t_prop = VALUE #(
                ( n = `test`  v = test )
        ) ).

  ENDMETHOD.

  METHOD z2ui5_if_view~template_with.

    result = _generic(
            name   = `with`
            ns     = `template`
            t_prop = VALUE #(
                ( n = `path`  v = path )
                ( n = `var`   v = var )
        ) ).

  ENDMETHOD.

ENDCLASS.
