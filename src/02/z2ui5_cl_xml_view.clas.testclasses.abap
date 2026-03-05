CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_create           FOR TESTING RAISING cx_static_check.
    METHODS test_factory_popup    FOR TESTING RAISING cx_static_check.
    METHODS test_shell_page       FOR TESTING RAISING cx_static_check.
    METHODS test_simple_form      FOR TESTING RAISING cx_static_check.
    METHODS test_button           FOR TESTING RAISING cx_static_check.
    METHODS test_input            FOR TESTING RAISING cx_static_check.
    METHODS test_label            FOR TESTING RAISING cx_static_check.
    METHODS test_text             FOR TESTING RAISING cx_static_check.
    METHODS test_vbox_hbox        FOR TESTING RAISING cx_static_check.
    METHODS test_table            FOR TESTING RAISING cx_static_check.
    METHODS test_dialog           FOR TESTING RAISING cx_static_check.
    METHODS test_get_parent       FOR TESTING RAISING cx_static_check.
    METHODS test_content          FOR TESTING RAISING cx_static_check.
    METHODS test_columns_cells    FOR TESTING RAISING cx_static_check.
    METHODS test_message_page     FOR TESTING RAISING cx_static_check.
    METHODS test_icon_tab_bar     FOR TESTING RAISING cx_static_check.

    METHODS test_select           FOR TESTING RAISING cx_static_check.
    METHODS test_combobox         FOR TESTING RAISING cx_static_check.
    METHODS test_checkbox         FOR TESTING RAISING cx_static_check.
    METHODS test_date_picker      FOR TESTING RAISING cx_static_check.
    METHODS test_text_area        FOR TESTING RAISING cx_static_check.
    METHODS test_link             FOR TESTING RAISING cx_static_check.
    METHODS test_title            FOR TESTING RAISING cx_static_check.
    METHODS test_toolbar          FOR TESTING RAISING cx_static_check.
    METHODS test_toolbar_spacer   FOR TESTING RAISING cx_static_check.
    METHODS test_scroll_container FOR TESTING RAISING cx_static_check.
    METHODS test_list             FOR TESTING RAISING cx_static_check.
    METHODS test_switch           FOR TESTING RAISING cx_static_check.
    METHODS test_radio_button     FOR TESTING RAISING cx_static_check.
    METHODS test_progress_ind     FOR TESTING RAISING cx_static_check.
    METHODS test_slider           FOR TESTING RAISING cx_static_check.
    METHODS test_deep_nesting     FOR TESTING RAISING cx_static_check.
    METHODS test_multi_get_parent FOR TESTING RAISING cx_static_check.
    METHODS test_xml_ns_decl      FOR TESTING RAISING cx_static_check.
    METHODS test_button_props     FOR TESTING RAISING cx_static_check.
    METHODS test_generic_method   FOR TESTING RAISING cx_static_check.
    METHODS test_segmented_button FOR TESTING RAISING cx_static_check.
    METHODS test_object_header    FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_create.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    lo_view = z2ui5_cl_xml_view=>factory( ).

    lv_xml = lo_view->page( `test` )->stringify( ).

    IF lv_xml IS INITIAL.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA lo_popup TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp1 TYPE xsdboolean.
    lo_popup = z2ui5_cl_xml_view=>factory_popup( ).

    lv_xml = lo_popup->dialog( `Test` )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).

    temp1 = xsdbool( lv_xml CS `Dialog` ).
    cl_abap_unit_assert=>assert_true( temp1 ).

  ENDMETHOD.

  METHOD test_shell_page.

    DATA lv_xml TYPE string.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `My Page`
      )->stringify( ).


    temp2 = xsdbool( lv_xml CS `Shell` ).
    cl_abap_unit_assert=>assert_true( temp2 ).

    temp3 = xsdbool( lv_xml CS `Page` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

    temp4 = xsdbool( lv_xml CS `My Page` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA lv_xml TYPE string.
    DATA temp5 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->simple_form( editable = abap_true
      )->stringify( ).


    temp5 = xsdbool( lv_xml CS `SimpleForm` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_button.

    DATA lv_xml TYPE string.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->button( text  = `Click Me`
                 press = `onPress`
      )->stringify( ).


    temp6 = xsdbool( lv_xml CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

    temp7 = xsdbool( lv_xml CS `Click Me` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD test_input.

    DATA lv_xml TYPE string.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->input( value       = `{/NAME}`
                placeholder = `Enter name`
      )->stringify( ).


    temp8 = xsdbool( lv_xml CS `Input` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

    temp9 = xsdbool( lv_xml CS `Enter name` ).
    cl_abap_unit_assert=>assert_true( temp9 ).

  ENDMETHOD.

  METHOD test_label.

    DATA lv_xml TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->label( `My Label`
      )->stringify( ).


    temp10 = xsdbool( lv_xml CS `Label` ).
    cl_abap_unit_assert=>assert_true( temp10 ).

    temp11 = xsdbool( lv_xml CS `My Label` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD test_text.

    DATA lv_xml TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->text( `Hello World`
      )->stringify( ).


    temp12 = xsdbool( lv_xml CS `Text` ).
    cl_abap_unit_assert=>assert_true( temp12 ).

    temp13 = xsdbool( lv_xml CS `Hello World` ).
    cl_abap_unit_assert=>assert_true( temp13 ).

  ENDMETHOD.

  METHOD test_vbox_hbox.

    DATA lv_xml TYPE string.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->vbox(
        )->hbox(
          )->text( `Nested`
      )->stringify( ).


    temp14 = xsdbool( lv_xml CS `VBox` ).
    cl_abap_unit_assert=>assert_true( temp14 ).

    temp15 = xsdbool( lv_xml CS `HBox` ).
    cl_abap_unit_assert=>assert_true( temp15 ).

  ENDMETHOD.

  METHOD test_table.

    DATA lv_xml TYPE string.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->table( headertext = `My Table`
      )->stringify( ).


    temp16 = xsdbool( lv_xml CS `Table` ).
    cl_abap_unit_assert=>assert_true( temp16 ).

    temp17 = xsdbool( lv_xml CS `My Table` ).
    cl_abap_unit_assert=>assert_true( temp17 ).

  ENDMETHOD.

  METHOD test_dialog.

    DATA lv_xml TYPE string.
    DATA temp18 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory_popup(
      )->dialog( title = `Confirm`
                 icon  = `sap-icon://hint`
      )->stringify( ).


    temp18 = xsdbool( lv_xml CS `Dialog` ).
    cl_abap_unit_assert=>assert_true( temp18 ).

    temp19 = xsdbool( lv_xml CS `Confirm` ).
    cl_abap_unit_assert=>assert_true( temp19 ).

  ENDMETHOD.

  METHOD test_get_parent.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_page TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_vbox TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_parent TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    lo_view = z2ui5_cl_xml_view=>factory( ).

    lo_page = lo_view->page( `Test` ).

    lo_vbox = lo_page->vbox( ).

    lo_parent = lo_vbox->get_parent( ).

    cl_abap_unit_assert=>assert_bound( lo_parent ).


    lv_xml = lo_parent->stringify( ).
    cl_abap_unit_assert=>assert_not_initial( lv_xml ).

  ENDMETHOD.

  METHOD test_content.

    DATA lv_xml TYPE string.
    DATA temp20 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->simple_form(
      )->content( `form`
        )->label( `Name`
        )->input( `{/NAME}`
      )->stringify( ).


    temp20 = xsdbool( lv_xml CS `content` ).
    cl_abap_unit_assert=>assert_true( temp20 ).

    temp21 = xsdbool( lv_xml CS `Label` ).
    cl_abap_unit_assert=>assert_true( temp21 ).

    temp22 = xsdbool( lv_xml CS `Input` ).
    cl_abap_unit_assert=>assert_true( temp22 ).

  ENDMETHOD.

  METHOD test_columns_cells.

    DATA lv_xml TYPE string.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->table(
        )->columns(
          )->column( )->header( `` )->text( `Col1`
        )->get_parent( )->get_parent( )->get_parent(
        )->items(
          )->column_list_item(
            )->cells(
              )->text( `{COL1}`
      )->stringify( ).


    temp23 = xsdbool( lv_xml CS `columns` ).
    cl_abap_unit_assert=>assert_true( temp23 ).

    temp24 = xsdbool( lv_xml CS `Column` ).
    cl_abap_unit_assert=>assert_true( temp24 ).

    temp25 = xsdbool( lv_xml CS `ColumnListItem` ).
    cl_abap_unit_assert=>assert_true( temp25 ).

  ENDMETHOD.

  METHOD test_message_page.

    DATA lv_xml TYPE string.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->message_page( text        = `Page not found`
                       description = `Check the URL`
      )->stringify( ).


    temp26 = xsdbool( lv_xml CS `MessagePage` ).
    cl_abap_unit_assert=>assert_true( temp26 ).

    temp27 = xsdbool( lv_xml CS `Page not found` ).
    cl_abap_unit_assert=>assert_true( temp27 ).

  ENDMETHOD.

  METHOD test_icon_tab_bar.

    DATA lv_xml TYPE string.
    DATA temp28 TYPE xsdboolean.
    DATA temp29 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->icon_tab_bar(
        )->items(
          )->icon_tab_filter( text = `Tab1`
            )->content(
              )->text( `Content1`
      )->stringify( ).


    temp28 = xsdbool( lv_xml CS `IconTabBar` ).
    cl_abap_unit_assert=>assert_true( temp28 ).

    temp29 = xsdbool( lv_xml CS `IconTabFilter` ).
    cl_abap_unit_assert=>assert_true( temp29 ).

    temp30 = xsdbool( lv_xml CS `Tab1` ).
    cl_abap_unit_assert=>assert_true( temp30 ).

  ENDMETHOD.

  METHOD test_select.

    DATA lv_xml TYPE string.
    DATA temp31 TYPE xsdboolean.
    DATA temp32 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->select( selectedkey = `{/SELECTED}`
                 change      = `onSelect`
      )->stringify( ).


    temp31 = xsdbool( lv_xml CS `Select` ).
    cl_abap_unit_assert=>assert_true( temp31 ).

    temp32 = xsdbool( lv_xml CS `{/SELECTED}` ).
    cl_abap_unit_assert=>assert_true( temp32 ).

  ENDMETHOD.

  METHOD test_combobox.

    DATA lv_xml TYPE string.
    DATA temp33 TYPE xsdboolean.
    DATA temp34 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->combobox( selectedkey = `{/KEY}`
                   placeholder = `Choose`
      )->stringify( ).


    temp33 = xsdbool( lv_xml CS `ComboBox` ).
    cl_abap_unit_assert=>assert_true( temp33 ).

    temp34 = xsdbool( lv_xml CS `Choose` ).
    cl_abap_unit_assert=>assert_true( temp34 ).

  ENDMETHOD.

  METHOD test_checkbox.

    DATA lv_xml TYPE string.
    DATA temp35 TYPE xsdboolean.
    DATA temp36 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->checkbox( text     = `Accept`
                   selected = `{/ACCEPTED}`
      )->stringify( ).


    temp35 = xsdbool( lv_xml CS `CheckBox` ).
    cl_abap_unit_assert=>assert_true( temp35 ).

    temp36 = xsdbool( lv_xml CS `Accept` ).
    cl_abap_unit_assert=>assert_true( temp36 ).

  ENDMETHOD.

  METHOD test_date_picker.

    DATA lv_xml TYPE string.
    DATA temp37 TYPE xsdboolean.
    DATA temp38 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->date_picker( value       = `{/DATE}`
                      placeholder = `Pick date`
      )->stringify( ).


    temp37 = xsdbool( lv_xml CS `DatePicker` ).
    cl_abap_unit_assert=>assert_true( temp37 ).

    temp38 = xsdbool( lv_xml CS `Pick date` ).
    cl_abap_unit_assert=>assert_true( temp38 ).

  ENDMETHOD.

  METHOD test_text_area.

    DATA lv_xml TYPE string.
    DATA temp39 TYPE xsdboolean.
    DATA temp40 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->text_area( value = `{/NOTES}`
                    rows  = `5`
      )->stringify( ).


    temp39 = xsdbool( lv_xml CS `TextArea` ).
    cl_abap_unit_assert=>assert_true( temp39 ).

    temp40 = xsdbool( lv_xml CS `{/NOTES}` ).
    cl_abap_unit_assert=>assert_true( temp40 ).

  ENDMETHOD.

  METHOD test_link.

    DATA lv_xml TYPE string.
    DATA temp41 TYPE xsdboolean.
    DATA temp42 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->link( text = `Click here`
               href = `https://example.com`
      )->stringify( ).


    temp41 = xsdbool( lv_xml CS `Link` ).
    cl_abap_unit_assert=>assert_true( temp41 ).

    temp42 = xsdbool( lv_xml CS `Click here` ).
    cl_abap_unit_assert=>assert_true( temp42 ).

  ENDMETHOD.

  METHOD test_title.

    DATA lv_xml TYPE string.
    DATA temp43 TYPE xsdboolean.
    DATA temp44 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->title( `My Title`
      )->stringify( ).


    temp43 = xsdbool( lv_xml CS `Title` ).
    cl_abap_unit_assert=>assert_true( temp43 ).

    temp44 = xsdbool( lv_xml CS `My Title` ).
    cl_abap_unit_assert=>assert_true( temp44 ).

  ENDMETHOD.

  METHOD test_toolbar.

    DATA lv_xml TYPE string.
    DATA temp45 TYPE xsdboolean.
    DATA temp46 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->overflow_toolbar(
        )->button( text  = `Action`
                   press = `onPress`
      )->stringify( ).


    temp45 = xsdbool( lv_xml CS `OverflowToolbar` ).
    cl_abap_unit_assert=>assert_true( temp45 ).

    temp46 = xsdbool( lv_xml CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp46 ).

  ENDMETHOD.

  METHOD test_toolbar_spacer.

    DATA lv_xml TYPE string.
    DATA temp47 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->toolbar_spacer(
      )->stringify( ).


    temp47 = xsdbool( lv_xml CS `ToolbarSpacer` ).
    cl_abap_unit_assert=>assert_true( temp47 ).

  ENDMETHOD.

  METHOD test_scroll_container.

    DATA lv_xml TYPE string.
    DATA temp48 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->scroll_container( height   = `100%`
                           vertical = abap_true
      )->stringify( ).


    temp48 = xsdbool( lv_xml CS `ScrollContainer` ).
    cl_abap_unit_assert=>assert_true( temp48 ).

  ENDMETHOD.

  METHOD test_list.

    DATA lv_xml TYPE string.
    DATA temp49 TYPE xsdboolean.
    DATA temp50 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->list( headertext = `Items`
               items      = `{/ITEMS}`
        )->standard_list_item( title       = `{TITLE}`
                               description = `{DESC}`
      )->stringify( ).


    temp49 = xsdbool( lv_xml CS `List` ).
    cl_abap_unit_assert=>assert_true( temp49 ).

    temp50 = xsdbool( lv_xml CS `StandardListItem` ).
    cl_abap_unit_assert=>assert_true( temp50 ).

  ENDMETHOD.

  METHOD test_switch.

    DATA lv_xml TYPE string.
    DATA temp51 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->switch( state = `{/ACTIVE}`
                 type  = `AcceptReject`
      )->stringify( ).


    temp51 = xsdbool( lv_xml CS `Switch` ).
    cl_abap_unit_assert=>assert_true( temp51 ).

  ENDMETHOD.

  METHOD test_radio_button.

    DATA lv_xml TYPE string.
    DATA temp52 TYPE xsdboolean.
    DATA temp53 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->radio_button( text     = `Option A`
                       selected = `{/OPTION_A}`
      )->stringify( ).


    temp52 = xsdbool( lv_xml CS `RadioButton` ).
    cl_abap_unit_assert=>assert_true( temp52 ).

    temp53 = xsdbool( lv_xml CS `Option A` ).
    cl_abap_unit_assert=>assert_true( temp53 ).

  ENDMETHOD.

  METHOD test_progress_ind.

    DATA lv_xml TYPE string.
    DATA temp54 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->progress_indicator( percentvalue = `75`
                             displayvalue = `75%`
                             state        = `Success`
      )->stringify( ).


    temp54 = xsdbool( lv_xml CS `ProgressIndicator` ).
    cl_abap_unit_assert=>assert_true( temp54 ).

  ENDMETHOD.

  METHOD test_slider.

    DATA lv_xml TYPE string.
    DATA temp55 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->slider( value = `{/SLIDER_VAL}`
                 min   = `0`
                 max   = `100`
      )->stringify( ).


    temp55 = xsdbool( lv_xml CS `Slider` ).
    cl_abap_unit_assert=>assert_true( temp55 ).

  ENDMETHOD.

  METHOD test_deep_nesting.

    DATA lv_xml TYPE string.
    DATA temp56 TYPE xsdboolean.
    DATA temp57 TYPE xsdboolean.
    DATA temp58 TYPE xsdboolean.
    DATA temp59 TYPE xsdboolean.
    DATA temp60 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `Deep`
        )->vbox(
          )->hbox(
            )->vbox(
              )->text( `Level4`
      )->stringify( ).


    temp56 = xsdbool( lv_xml CS `Shell` ).
    cl_abap_unit_assert=>assert_true( temp56 ).

    temp57 = xsdbool( lv_xml CS `Page` ).
    cl_abap_unit_assert=>assert_true( temp57 ).

    temp58 = xsdbool( lv_xml CS `VBox` ).
    cl_abap_unit_assert=>assert_true( temp58 ).

    temp59 = xsdbool( lv_xml CS `HBox` ).
    cl_abap_unit_assert=>assert_true( temp59 ).

    temp60 = xsdbool( lv_xml CS `Level4` ).
    cl_abap_unit_assert=>assert_true( temp60 ).

  ENDMETHOD.

  METHOD test_multi_get_parent.

    DATA lo_view TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_page TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_vbox TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_hbox TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_text TYPE REF TO z2ui5_cl_xml_view.
    DATA lo_back TYPE REF TO z2ui5_cl_xml_view.
    DATA lv_xml TYPE string.
    DATA temp61 TYPE xsdboolean.
    DATA temp62 TYPE xsdboolean.
    DATA temp63 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( ).

    lo_page = lo_view->page( `Test` ).

    lo_vbox = lo_page->vbox( ).

    lo_hbox = lo_vbox->hbox( ).

    lo_text = lo_hbox->text( `inner` ).


    lo_back = lo_text->get_parent( )->get_parent( )->get_parent( ).


    lv_xml = lo_back->button( text = `Added to page` )->stringify( ).


    temp61 = xsdbool( lv_xml CS `VBox` ).
    cl_abap_unit_assert=>assert_true( temp61 ).

    temp62 = xsdbool( lv_xml CS `HBox` ).
    cl_abap_unit_assert=>assert_true( temp62 ).

    temp63 = xsdbool( lv_xml CS `Added to page` ).
    cl_abap_unit_assert=>assert_true( temp63 ).

  ENDMETHOD.

  METHOD test_xml_ns_decl.

    DATA lv_xml TYPE string.
    DATA temp64 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `NS Test`
      )->stringify( ).


    temp64 = xsdbool( lv_xml CS `xmlns` ).
    cl_abap_unit_assert=>assert_true( temp64 ).

  ENDMETHOD.

  METHOD test_button_props.

    DATA lv_xml TYPE string.
    DATA temp65 TYPE xsdboolean.
    DATA temp66 TYPE xsdboolean.
    DATA temp67 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->button( text    = `Save`
                 press   = `onSave`
                 icon    = `sap-icon://save`
                 type    = `Emphasized`
                 enabled = abap_true
      )->stringify( ).


    temp65 = xsdbool( lv_xml CS `Save` ).
    cl_abap_unit_assert=>assert_true( temp65 ).

    temp66 = xsdbool( lv_xml CS `sap-icon://save` ).
    cl_abap_unit_assert=>assert_true( temp66 ).

    temp67 = xsdbool( lv_xml CS `Emphasized` ).
    cl_abap_unit_assert=>assert_true( temp67 ).

  ENDMETHOD.

  METHOD test_generic_method.

    DATA temp1 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    DATA lv_xml TYPE string.
    DATA temp68 TYPE xsdboolean.
    DATA temp69 TYPE xsdboolean.
    DATA temp70 TYPE xsdboolean.
    CLEAR temp1.

    temp2-n = `myProp`.
    temp2-v = `myValue`.
    INSERT temp2 INTO TABLE temp1.

    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->_generic( name   = `MyCustomControl`
                   ns     = ``
                   t_prop = temp1
      )->stringify( ).


    temp68 = xsdbool( lv_xml CS `MyCustomControl` ).
    cl_abap_unit_assert=>assert_true( temp68 ).

    temp69 = xsdbool( lv_xml CS `myProp` ).
    cl_abap_unit_assert=>assert_true( temp69 ).

    temp70 = xsdbool( lv_xml CS `myValue` ).
    cl_abap_unit_assert=>assert_true( temp70 ).

  ENDMETHOD.

  METHOD test_segmented_button.

    DATA lv_xml TYPE string.
    DATA temp71 TYPE xsdboolean.
    DATA temp72 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->segmented_button( `{/SEG_KEY}`
        )->items(
          )->segmented_button_item( key  = `key1`
                                    text = `Seg1`
      )->stringify( ).


    temp71 = xsdbool( lv_xml CS `SegmentedButton` ).
    cl_abap_unit_assert=>assert_true( temp71 ).

    temp72 = xsdbool( lv_xml CS `SegmentedButtonItem` ).
    cl_abap_unit_assert=>assert_true( temp72 ).

  ENDMETHOD.

  METHOD test_object_header.

    DATA lv_xml TYPE string.
    DATA temp73 TYPE xsdboolean.
    DATA temp74 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->object_header( title      = `Order 123`
                        number     = `1000`
                        numberunit = `EUR`
      )->stringify( ).


    temp73 = xsdbool( lv_xml CS `ObjectHeader` ).
    cl_abap_unit_assert=>assert_true( temp73 ).

    temp74 = xsdbool( lv_xml CS `Order 123` ).
    cl_abap_unit_assert=>assert_true( temp74 ).

  ENDMETHOD.

ENDCLASS.
