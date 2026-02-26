CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION MEDIUM.

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

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_create.

    DATA(lo_view) = z2ui5_cl_xml_view=>factory( ).
    DATA(lv_xml) = lo_view->page( `test` )->stringify( ).

    IF lv_xml IS INITIAL.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA(lo_popup) = z2ui5_cl_xml_view=>factory_popup( ).
    DATA(lv_xml) = lo_popup->dialog( `Test` )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Dialog` ) ).

  ENDMETHOD.

  METHOD test_shell_page.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->shell(
      )->page( `My Page`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Shell` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Page` ) ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->simple_form( editable = abap_true
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `SimpleForm` ) ).

  ENDMETHOD.

  METHOD test_button.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->button( text  = `Click Me`
                 press = `onPress`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Click Me` ) ).

  ENDMETHOD.

  METHOD test_input.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->input( value       = `{/NAME}`
                placeholder = `Enter name`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Input` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Enter name` ) ).

  ENDMETHOD.

  METHOD test_label.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->label( `My Label`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Label` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Label` ) ).

  ENDMETHOD.

  METHOD test_text.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->text( `Hello World`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Text` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Hello World` ) ).

  ENDMETHOD.

  METHOD test_vbox_hbox.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->vbox(
        )->hbox(
          )->text( `Nested`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `VBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `HBox` ) ).

  ENDMETHOD.

  METHOD test_table.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->table( headertext = `My Table`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Table` ) ).

  ENDMETHOD.

  METHOD test_dialog.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory_popup(
      )->dialog( title = `Confirm`
                 icon  = `sap-icon://hint`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Dialog` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Confirm` ) ).

  ENDMETHOD.

  METHOD test_get_parent.

    DATA(lo_view) = z2ui5_cl_xml_view=>factory( ).
    DATA(lo_page) = lo_view->page( `Test` ).
    DATA(lo_vbox) = lo_page->vbox( ).
    DATA(lo_parent) = lo_vbox->get_parent( ).

    cl_abap_unit_assert=>assert_bound( lo_parent ).

    DATA(lv_xml) = lo_parent->stringify( ).
    cl_abap_unit_assert=>assert_not_initial( lv_xml ).

  ENDMETHOD.

  METHOD test_content.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->simple_form(
      )->content( `form`
        )->label( `Name`
        )->input( `{/NAME}`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `content` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Label` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Input` ) ).

  ENDMETHOD.

  METHOD test_columns_cells.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
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

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `columns` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Column` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `ColumnListItem` ) ).

  ENDMETHOD.

  METHOD test_message_page.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->message_page( text        = `Page not found`
                       description = `Check the URL`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `MessagePage` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page not found` ) ).

  ENDMETHOD.

  METHOD test_icon_tab_bar.

    DATA(lv_xml) = z2ui5_cl_xml_view=>factory(
      )->page( `Test`
      )->icon_tab_bar(
        )->items(
          )->icon_tab_filter( text = `Tab1`
            )->content(
              )->text( `Content1`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `IconTabBar` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `IconTabFilter` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Tab1` ) ).

  ENDMETHOD.

ENDCLASS.
