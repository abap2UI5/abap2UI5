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
    DATA temp2 TYPE xsdboolean.
    lo_popup = z2ui5_cl_xml_view=>factory_popup( ).

    lv_xml = lo_popup->dialog( `Test` )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).

    
    temp2 = boolc( lv_xml CS `Dialog` ).
    temp1 = temp2.
    cl_abap_unit_assert=>assert_true( temp1 ).

  ENDMETHOD.

  METHOD test_shell_page.

    DATA lv_xml TYPE string.
    DATA temp2 TYPE xsdboolean.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `My Page`
      )->stringify( ).


    
    temp5 = boolc( lv_xml CS `Shell` ).
    temp2 = temp5.
    cl_abap_unit_assert=>assert_true( temp2 ).

    
    temp6 = boolc( lv_xml CS `Page` ).
    temp3 = temp6.
    cl_abap_unit_assert=>assert_true( temp3 ).

    
    temp7 = boolc( lv_xml CS `My Page` ).
    temp4 = temp7.
    cl_abap_unit_assert=>assert_true( temp4 ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA lv_xml TYPE string.
    DATA temp5 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->simple_form( editable = abap_true
      )->stringify( ).


    
    temp8 = boolc( lv_xml CS `SimpleForm` ).
    temp5 = temp8.
    cl_abap_unit_assert=>assert_true( temp5 ).

  ENDMETHOD.

  METHOD test_button.

    DATA lv_xml TYPE string.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->button( text  = `Click Me`
                 press = `onPress`
      )->stringify( ).


    
    temp9 = boolc( lv_xml CS `Button` ).
    temp6 = temp9.
    cl_abap_unit_assert=>assert_true( temp6 ).

    
    temp10 = boolc( lv_xml CS `Click Me` ).
    temp7 = temp10.
    cl_abap_unit_assert=>assert_true( temp7 ).

  ENDMETHOD.

  METHOD test_input.

    DATA lv_xml TYPE string.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp12 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->input( value       = `{/NAME}`
                placeholder = `Enter name`
      )->stringify( ).


    
    temp11 = boolc( lv_xml CS `Input` ).
    temp8 = temp11.
    cl_abap_unit_assert=>assert_true( temp8 ).

    
    temp12 = boolc( lv_xml CS `Enter name` ).
    temp9 = temp12.
    cl_abap_unit_assert=>assert_true( temp9 ).

  ENDMETHOD.

  METHOD test_label.

    DATA lv_xml TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    DATA temp14 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->label( `My Label`
      )->stringify( ).


    
    temp13 = boolc( lv_xml CS `Label` ).
    temp10 = temp13.
    cl_abap_unit_assert=>assert_true( temp10 ).

    
    temp14 = boolc( lv_xml CS `My Label` ).
    temp11 = temp14.
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD test_text.

    DATA lv_xml TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    DATA temp16 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->text( `Hello World`
      )->stringify( ).


    
    temp15 = boolc( lv_xml CS `Text` ).
    temp12 = temp15.
    cl_abap_unit_assert=>assert_true( temp12 ).

    
    temp16 = boolc( lv_xml CS `Hello World` ).
    temp13 = temp16.
    cl_abap_unit_assert=>assert_true( temp13 ).

  ENDMETHOD.

  METHOD test_vbox_hbox.

    DATA lv_xml TYPE string.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->vbox(
        )->hbox(
          )->text( `Nested`
      )->stringify( ).


    
    temp17 = boolc( lv_xml CS `VBox` ).
    temp14 = temp17.
    cl_abap_unit_assert=>assert_true( temp14 ).

    
    temp18 = boolc( lv_xml CS `HBox` ).
    temp15 = temp18.
    cl_abap_unit_assert=>assert_true( temp15 ).

  ENDMETHOD.

  METHOD test_table.

    DATA lv_xml TYPE string.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->table( headertext = `My Table`
      )->stringify( ).


    
    temp19 = boolc( lv_xml CS `Table` ).
    temp16 = temp19.
    cl_abap_unit_assert=>assert_true( temp16 ).

    
    temp20 = boolc( lv_xml CS `My Table` ).
    temp17 = temp20.
    cl_abap_unit_assert=>assert_true( temp17 ).

  ENDMETHOD.

  METHOD test_dialog.

    DATA lv_xml TYPE string.
    DATA temp18 TYPE xsdboolean.
    DATA temp19 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    DATA temp22 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory_popup(
      )->dialog( title = `Confirm`
                 icon  = `sap-icon://hint`
      )->stringify( ).


    
    temp21 = boolc( lv_xml CS `Dialog` ).
    temp18 = temp21.
    cl_abap_unit_assert=>assert_true( temp18 ).

    
    temp22 = boolc( lv_xml CS `Confirm` ).
    temp19 = temp22.
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
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->simple_form(
      )->content( `form`
        )->label( `Name`
        )->input( `{/NAME}`
      )->stringify( ).


    
    temp23 = boolc( lv_xml CS `content` ).
    temp20 = temp23.
    cl_abap_unit_assert=>assert_true( temp20 ).

    
    temp24 = boolc( lv_xml CS `Label` ).
    temp21 = temp24.
    cl_abap_unit_assert=>assert_true( temp21 ).

    
    temp25 = boolc( lv_xml CS `Input` ).
    temp22 = temp25.
    cl_abap_unit_assert=>assert_true( temp22 ).

  ENDMETHOD.

  METHOD test_columns_cells.

    DATA lv_xml TYPE string.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE xsdboolean.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.
    DATA temp28 TYPE xsdboolean.
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


    
    temp26 = boolc( lv_xml CS `columns` ).
    temp23 = temp26.
    cl_abap_unit_assert=>assert_true( temp23 ).

    
    temp27 = boolc( lv_xml CS `Column` ).
    temp24 = temp27.
    cl_abap_unit_assert=>assert_true( temp24 ).

    
    temp28 = boolc( lv_xml CS `ColumnListItem` ).
    temp25 = temp28.
    cl_abap_unit_assert=>assert_true( temp25 ).

  ENDMETHOD.

  METHOD test_message_page.

    DATA lv_xml TYPE string.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.
    DATA temp29 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->message_page( text        = `Page not found`
                       description = `Check the URL`
      )->stringify( ).


    
    temp29 = boolc( lv_xml CS `MessagePage` ).
    temp26 = temp29.
    cl_abap_unit_assert=>assert_true( temp26 ).

    
    temp30 = boolc( lv_xml CS `Page not found` ).
    temp27 = temp30.
    cl_abap_unit_assert=>assert_true( temp27 ).

  ENDMETHOD.

  METHOD test_icon_tab_bar.

    DATA lv_xml TYPE string.
    DATA temp28 TYPE xsdboolean.
    DATA temp29 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    DATA temp31 TYPE xsdboolean.
    DATA temp32 TYPE xsdboolean.
    DATA temp33 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->icon_tab_bar(
        )->items(
          )->icon_tab_filter( text = `Tab1`
            )->content(
              )->text( `Content1`
      )->stringify( ).


    
    temp31 = boolc( lv_xml CS `IconTabBar` ).
    temp28 = temp31.
    cl_abap_unit_assert=>assert_true( temp28 ).

    
    temp32 = boolc( lv_xml CS `IconTabFilter` ).
    temp29 = temp32.
    cl_abap_unit_assert=>assert_true( temp29 ).

    
    temp33 = boolc( lv_xml CS `Tab1` ).
    temp30 = temp33.
    cl_abap_unit_assert=>assert_true( temp30 ).

  ENDMETHOD.

  METHOD test_select.

    DATA lv_xml TYPE string.
    DATA temp31 TYPE xsdboolean.
    DATA temp32 TYPE xsdboolean.
    DATA temp34 TYPE xsdboolean.
    DATA temp35 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->select( selectedkey = `{/SELECTED}`
                 change      = `onSelect`
      )->stringify( ).


    
    temp34 = boolc( lv_xml CS `Select` ).
    temp31 = temp34.
    cl_abap_unit_assert=>assert_true( temp31 ).

    
    temp35 = boolc( lv_xml CS `{/SELECTED}` ).
    temp32 = temp35.
    cl_abap_unit_assert=>assert_true( temp32 ).

  ENDMETHOD.

  METHOD test_combobox.

    DATA lv_xml TYPE string.
    DATA temp33 TYPE xsdboolean.
    DATA temp34 TYPE xsdboolean.
    DATA temp36 TYPE xsdboolean.
    DATA temp37 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->combobox( selectedkey = `{/KEY}`
                   placeholder = `Choose`
      )->stringify( ).


    
    temp36 = boolc( lv_xml CS `ComboBox` ).
    temp33 = temp36.
    cl_abap_unit_assert=>assert_true( temp33 ).

    
    temp37 = boolc( lv_xml CS `Choose` ).
    temp34 = temp37.
    cl_abap_unit_assert=>assert_true( temp34 ).

  ENDMETHOD.

  METHOD test_checkbox.

    DATA lv_xml TYPE string.
    DATA temp35 TYPE xsdboolean.
    DATA temp36 TYPE xsdboolean.
    DATA temp38 TYPE xsdboolean.
    DATA temp39 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->checkbox( text     = `Accept`
                   selected = `{/ACCEPTED}`
      )->stringify( ).


    
    temp38 = boolc( lv_xml CS `CheckBox` ).
    temp35 = temp38.
    cl_abap_unit_assert=>assert_true( temp35 ).

    
    temp39 = boolc( lv_xml CS `Accept` ).
    temp36 = temp39.
    cl_abap_unit_assert=>assert_true( temp36 ).

  ENDMETHOD.

  METHOD test_date_picker.

    DATA lv_xml TYPE string.
    DATA temp37 TYPE xsdboolean.
    DATA temp38 TYPE xsdboolean.
    DATA temp40 TYPE xsdboolean.
    DATA temp41 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->date_picker( value       = `{/DATE}`
                      placeholder = `Pick date`
      )->stringify( ).


    
    temp40 = boolc( lv_xml CS `DatePicker` ).
    temp37 = temp40.
    cl_abap_unit_assert=>assert_true( temp37 ).

    
    temp41 = boolc( lv_xml CS `Pick date` ).
    temp38 = temp41.
    cl_abap_unit_assert=>assert_true( temp38 ).

  ENDMETHOD.

  METHOD test_text_area.

    DATA lv_xml TYPE string.
    DATA temp39 TYPE xsdboolean.
    DATA temp40 TYPE xsdboolean.
    DATA temp42 TYPE xsdboolean.
    DATA temp43 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->text_area( value = `{/NOTES}`
                    rows  = `5`
      )->stringify( ).


    
    temp42 = boolc( lv_xml CS `TextArea` ).
    temp39 = temp42.
    cl_abap_unit_assert=>assert_true( temp39 ).

    
    temp43 = boolc( lv_xml CS `{/NOTES}` ).
    temp40 = temp43.
    cl_abap_unit_assert=>assert_true( temp40 ).

  ENDMETHOD.

  METHOD test_link.

    DATA lv_xml TYPE string.
    DATA temp41 TYPE xsdboolean.
    DATA temp42 TYPE xsdboolean.
    DATA temp44 TYPE xsdboolean.
    DATA temp45 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->link( text = `Click here`
               href = `https://example.com`
      )->stringify( ).


    
    temp44 = boolc( lv_xml CS `Link` ).
    temp41 = temp44.
    cl_abap_unit_assert=>assert_true( temp41 ).

    
    temp45 = boolc( lv_xml CS `Click here` ).
    temp42 = temp45.
    cl_abap_unit_assert=>assert_true( temp42 ).

  ENDMETHOD.

  METHOD test_title.

    DATA lv_xml TYPE string.
    DATA temp43 TYPE xsdboolean.
    DATA temp44 TYPE xsdboolean.
    DATA temp46 TYPE xsdboolean.
    DATA temp47 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->title( `My Title`
      )->stringify( ).


    
    temp46 = boolc( lv_xml CS `Title` ).
    temp43 = temp46.
    cl_abap_unit_assert=>assert_true( temp43 ).

    
    temp47 = boolc( lv_xml CS `My Title` ).
    temp44 = temp47.
    cl_abap_unit_assert=>assert_true( temp44 ).

  ENDMETHOD.

  METHOD test_toolbar.

    DATA lv_xml TYPE string.
    DATA temp45 TYPE xsdboolean.
    DATA temp46 TYPE xsdboolean.
    DATA temp48 TYPE xsdboolean.
    DATA temp49 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->overflow_toolbar(
        )->button( text  = `Action`
                   press = `onPress`
      )->stringify( ).


    
    temp48 = boolc( lv_xml CS `OverflowToolbar` ).
    temp45 = temp48.
    cl_abap_unit_assert=>assert_true( temp45 ).

    
    temp49 = boolc( lv_xml CS `Button` ).
    temp46 = temp49.
    cl_abap_unit_assert=>assert_true( temp46 ).

  ENDMETHOD.

  METHOD test_toolbar_spacer.

    DATA lv_xml TYPE string.
    DATA temp47 TYPE xsdboolean.
    DATA temp50 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->toolbar_spacer(
      )->stringify( ).


    
    temp50 = boolc( lv_xml CS `ToolbarSpacer` ).
    temp47 = temp50.
    cl_abap_unit_assert=>assert_true( temp47 ).

  ENDMETHOD.

  METHOD test_scroll_container.

    DATA lv_xml TYPE string.
    DATA temp48 TYPE xsdboolean.
    DATA temp51 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->scroll_container( height   = `100%`
                           vertical = abap_true
      )->stringify( ).


    
    temp51 = boolc( lv_xml CS `ScrollContainer` ).
    temp48 = temp51.
    cl_abap_unit_assert=>assert_true( temp48 ).

  ENDMETHOD.

  METHOD test_list.

    DATA lv_xml TYPE string.
    DATA temp49 TYPE xsdboolean.
    DATA temp50 TYPE xsdboolean.
    DATA temp52 TYPE xsdboolean.
    DATA temp53 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->list( headertext = `Items`
               items      = `{/ITEMS}`
        )->standard_list_item( title       = `{TITLE}`
                               description = `{DESC}`
      )->stringify( ).


    
    temp52 = boolc( lv_xml CS `List` ).
    temp49 = temp52.
    cl_abap_unit_assert=>assert_true( temp49 ).

    
    temp53 = boolc( lv_xml CS `StandardListItem` ).
    temp50 = temp53.
    cl_abap_unit_assert=>assert_true( temp50 ).

  ENDMETHOD.

  METHOD test_switch.

    DATA lv_xml TYPE string.
    DATA temp51 TYPE xsdboolean.
    DATA temp54 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->switch( state = `{/ACTIVE}`
                 type  = `AcceptReject`
      )->stringify( ).


    
    temp54 = boolc( lv_xml CS `Switch` ).
    temp51 = temp54.
    cl_abap_unit_assert=>assert_true( temp51 ).

  ENDMETHOD.

  METHOD test_radio_button.

    DATA lv_xml TYPE string.
    DATA temp52 TYPE xsdboolean.
    DATA temp53 TYPE xsdboolean.
    DATA temp55 TYPE xsdboolean.
    DATA temp56 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->radio_button( text     = `Option A`
                       selected = `{/OPTION_A}`
      )->stringify( ).


    
    temp55 = boolc( lv_xml CS `RadioButton` ).
    temp52 = temp55.
    cl_abap_unit_assert=>assert_true( temp52 ).

    
    temp56 = boolc( lv_xml CS `Option A` ).
    temp53 = temp56.
    cl_abap_unit_assert=>assert_true( temp53 ).

  ENDMETHOD.

  METHOD test_progress_ind.

    DATA lv_xml TYPE string.
    DATA temp54 TYPE xsdboolean.
    DATA temp57 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->progress_indicator( percentvalue = `75`
                             displayvalue = `75%`
                             state        = `Success`
      )->stringify( ).


    
    temp57 = boolc( lv_xml CS `ProgressIndicator` ).
    temp54 = temp57.
    cl_abap_unit_assert=>assert_true( temp54 ).

  ENDMETHOD.

  METHOD test_slider.

    DATA lv_xml TYPE string.
    DATA temp55 TYPE xsdboolean.
    DATA temp58 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->slider( value = `{/SLIDER_VAL}`
                 min   = `0`
                 max   = `100`
      )->stringify( ).


    
    temp58 = boolc( lv_xml CS `Slider` ).
    temp55 = temp58.
    cl_abap_unit_assert=>assert_true( temp55 ).

  ENDMETHOD.

  METHOD test_deep_nesting.

    DATA lv_xml TYPE string.
    DATA temp56 TYPE xsdboolean.
    DATA temp57 TYPE xsdboolean.
    DATA temp58 TYPE xsdboolean.
    DATA temp59 TYPE xsdboolean.
    DATA temp60 TYPE xsdboolean.
    DATA temp61 TYPE xsdboolean.
    DATA temp62 TYPE xsdboolean.
    DATA temp63 TYPE xsdboolean.
    DATA temp64 TYPE xsdboolean.
    DATA temp65 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `Deep`
        )->vbox(
          )->hbox(
            )->vbox(
              )->text( `Level4`
      )->stringify( ).


    
    temp61 = boolc( lv_xml CS `Shell` ).
    temp56 = temp61.
    cl_abap_unit_assert=>assert_true( temp56 ).

    
    temp62 = boolc( lv_xml CS `Page` ).
    temp57 = temp62.
    cl_abap_unit_assert=>assert_true( temp57 ).

    
    temp63 = boolc( lv_xml CS `VBox` ).
    temp58 = temp63.
    cl_abap_unit_assert=>assert_true( temp58 ).

    
    temp64 = boolc( lv_xml CS `HBox` ).
    temp59 = temp64.
    cl_abap_unit_assert=>assert_true( temp59 ).

    
    temp65 = boolc( lv_xml CS `Level4` ).
    temp60 = temp65.
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
    DATA temp66 TYPE xsdboolean.
    DATA temp67 TYPE xsdboolean.
    DATA temp68 TYPE xsdboolean.
    lo_view = z2ui5_cl_xml_view=>factory( ).

    lo_page = lo_view->page( `Test` ).

    lo_vbox = lo_page->vbox( ).

    lo_hbox = lo_vbox->hbox( ).

    lo_text = lo_hbox->text( `inner` ).


    lo_back = lo_text->get_parent( )->get_parent( )->get_parent( ).


    lv_xml = lo_back->button( text = `Added to page` )->stringify( ).


    
    temp66 = boolc( lv_xml CS `VBox` ).
    temp61 = temp66.
    cl_abap_unit_assert=>assert_true( temp61 ).

    
    temp67 = boolc( lv_xml CS `HBox` ).
    temp62 = temp67.
    cl_abap_unit_assert=>assert_true( temp62 ).

    
    temp68 = boolc( lv_xml CS `Added to page` ).
    temp63 = temp68.
    cl_abap_unit_assert=>assert_true( temp63 ).

  ENDMETHOD.

  METHOD test_xml_ns_decl.

    DATA lv_xml TYPE string.
    DATA temp64 TYPE xsdboolean.
    DATA temp69 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `NS Test`
      )->stringify( ).


    
    temp69 = boolc( lv_xml CS `xmlns` ).
    temp64 = temp69.
    cl_abap_unit_assert=>assert_true( temp64 ).

  ENDMETHOD.

  METHOD test_button_props.

    DATA lv_xml TYPE string.
    DATA temp65 TYPE xsdboolean.
    DATA temp66 TYPE xsdboolean.
    DATA temp67 TYPE xsdboolean.
    DATA temp70 TYPE xsdboolean.
    DATA temp71 TYPE xsdboolean.
    DATA temp72 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->button( text    = `Save`
                 press   = `onSave`
                 icon    = `sap-icon://save`
                 type    = `Emphasized`
                 enabled = abap_true
      )->stringify( ).


    
    temp70 = boolc( lv_xml CS `Save` ).
    temp65 = temp70.
    cl_abap_unit_assert=>assert_true( temp65 ).

    
    temp71 = boolc( lv_xml CS `sap-icon://save` ).
    temp66 = temp71.
    cl_abap_unit_assert=>assert_true( temp66 ).

    
    temp72 = boolc( lv_xml CS `Emphasized` ).
    temp67 = temp72.
    cl_abap_unit_assert=>assert_true( temp67 ).

  ENDMETHOD.

  METHOD test_generic_method.

    DATA temp1 TYPE z2ui5_if_types=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    DATA lv_xml TYPE string.
    DATA temp68 TYPE xsdboolean.
    DATA temp69 TYPE xsdboolean.
    DATA temp70 TYPE xsdboolean.
    DATA temp73 TYPE xsdboolean.
    DATA temp74 TYPE xsdboolean.
    DATA temp75 TYPE xsdboolean.
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


    
    temp73 = boolc( lv_xml CS `MyCustomControl` ).
    temp68 = temp73.
    cl_abap_unit_assert=>assert_true( temp68 ).

    
    temp74 = boolc( lv_xml CS `myProp` ).
    temp69 = temp74.
    cl_abap_unit_assert=>assert_true( temp69 ).

    
    temp75 = boolc( lv_xml CS `myValue` ).
    temp70 = temp75.
    cl_abap_unit_assert=>assert_true( temp70 ).

  ENDMETHOD.

  METHOD test_segmented_button.

    DATA lv_xml TYPE string.
    DATA temp71 TYPE xsdboolean.
    DATA temp72 TYPE xsdboolean.
    DATA temp76 TYPE xsdboolean.
    DATA temp77 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->segmented_button( `{/SEG_KEY}`
        )->items(
          )->segmented_button_item( key  = `key1`
                                    text = `Seg1`
      )->stringify( ).


    
    temp76 = boolc( lv_xml CS `SegmentedButton` ).
    temp71 = temp76.
    cl_abap_unit_assert=>assert_true( temp71 ).

    
    temp77 = boolc( lv_xml CS `SegmentedButtonItem` ).
    temp72 = temp77.
    cl_abap_unit_assert=>assert_true( temp72 ).

  ENDMETHOD.

  METHOD test_object_header.

    DATA lv_xml TYPE string.
    DATA temp73 TYPE xsdboolean.
    DATA temp74 TYPE xsdboolean.
    DATA temp78 TYPE xsdboolean.
    DATA temp79 TYPE xsdboolean.
    lv_xml = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->object_header( title      = `Order 123`
                        number     = `1000`
                        numberunit = `EUR`
      )->stringify( ).


    
    temp78 = boolc( lv_xml CS `ObjectHeader` ).
    temp73 = temp78.
    cl_abap_unit_assert=>assert_true( temp73 ).

    
    temp79 = boolc( lv_xml CS `Order 123` ).
    temp74 = temp79.
    cl_abap_unit_assert=>assert_true( temp74 ).

  ENDMETHOD.

ENDCLASS.
