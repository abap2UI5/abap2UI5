CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_factory           FOR TESTING RAISING cx_static_check.
    METHODS test_factory_popup     FOR TESTING RAISING cx_static_check.
    METHODS test_factory_plain     FOR TESTING RAISING cx_static_check.
    METHODS test_shell_page        FOR TESTING RAISING cx_static_check.
    METHODS test_button            FOR TESTING RAISING cx_static_check.
    METHODS test_input             FOR TESTING RAISING cx_static_check.
    METHODS test_leaf              FOR TESTING RAISING cx_static_check.
    METHODS test_nested            FOR TESTING RAISING cx_static_check.
    METHODS test_up                FOR TESTING RAISING cx_static_check.
    METHODS test_namespace         FOR TESTING RAISING cx_static_check.
    METHODS test_table             FOR TESTING RAISING cx_static_check.
    METHODS test_simple_form       FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lv_xml) = lo_view->add( n = `Page`
                                 p = VALUE #( ( n = `title` v = `test` ) )
                               )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA(lo_popup) = z2ui5_cl_xml_view_generic=>factory_popup( ).
    DATA(lv_xml) = lo_popup->add( n = `Dialog`
                                  p = VALUE #( ( n = `title` v = `Test` ) )
                                )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Dialog` ) ).

  ENDMETHOD.

  METHOD test_factory_plain.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory_plain( ).

    cl_abap_unit_assert=>assert_bound( lo_view ).

  ENDMETHOD.

  METHOD test_shell_page.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `Shell`
      )->add( n = `Page`
              p = VALUE #( ( n = `title` v = `My Page` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Shell` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Page` ) ).

  ENDMETHOD.

  METHOD test_button.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `Page`
              p = VALUE #( ( n = `title` v = `Test` ) )
      )->leaf( n = `Button`
               p = VALUE #( ( n = `text`  v = `Click Me` )
                             ( n = `press` v = `onPress` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Click Me` ) ).

  ENDMETHOD.

  METHOD test_input.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `Page`
              p = VALUE #( ( n = `title` v = `Test` ) )
      )->leaf( n = `Input`
               p = VALUE #( ( n = `value`       v = `{/NAME}` )
                             ( n = `placeholder` v = `Enter name` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Input` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Enter name` ) ).

  ENDMETHOD.

  METHOD test_leaf.

    DATA(lo_page) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `Page`
              p = VALUE #( ( n = `title` v = `Test` ) ) ).

    lo_page->leaf( n = `Button`
                   p = VALUE #( ( n = `text` v = `Btn1` ) ) ).
    lo_page->leaf( n = `Button`
                   p = VALUE #( ( n = `text` v = `Btn2` ) ) ).

    DATA(lv_xml) = lo_page->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Btn1` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Btn2` ) ).

  ENDMETHOD.

  METHOD test_nested.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `Shell`
      )->add( n = `Page`
              p = VALUE #( ( n = `title` v = `Test` ) )
      )->add( n = `VBox`
      )->add( n = `HBox`
      )->leaf( n = `Text`
               p = VALUE #( ( n = `text` v = `Nested` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `VBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `HBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Nested` ) ).

  ENDMETHOD.

  METHOD test_up.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lo_page) = lo_view->add( n = `Page`
                                  p = VALUE #( ( n = `title` v = `Test` ) ) ).
    DATA(lo_vbox) = lo_page->add( n = `VBox` ).
    DATA(lo_parent) = lo_vbox->up( ).

    cl_abap_unit_assert=>assert_bound( lo_parent ).

    DATA(lv_xml) = lo_parent->stringify( ).
    cl_abap_unit_assert=>assert_not_initial( lv_xml ).

  ENDMETHOD.

  METHOD test_namespace.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `DynamicPage`
              ns = `f`
      )->add( n = `DynamicPageTitle`
              ns = `f`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `f:DynamicPage` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `f:DynamicPageTitle` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `xmlns:f` ) ).

  ENDMETHOD.

  METHOD test_table.

    DATA(lo_page) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n = `Page`
              p = VALUE #( ( n = `title` v = `Test` ) ) ).

    DATA(lo_table) = lo_page->add( n = `Table`
                                   p = VALUE #( ( n = `items`      v = `{/ITEMS}` )
                                                ( n = `headerText` v = `My Table` ) ) ).

    DATA(lo_columns) = lo_table->add( n = `columns` ).
    DATA(lo_col) = lo_columns->add( n = `Column` ).
    lo_col->add( n = `header` )->leaf( n = `Text`
                                       p = VALUE #( ( n = `text` v = `Col1` ) ) ).

    lo_table->add( n = `items`
      )->add( n = `ColumnListItem`
      )->add( n = `cells`
      )->leaf( n = `Text`
               p = VALUE #( ( n = `text` v = `{COL1}` ) ) ).

    DATA(lv_xml) = lo_page->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `columns` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Column` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `ColumnListItem` ) ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA(lo_form) = z2ui5_cl_xml_view_generic=>factory(
      )->add( n  = `Page`
              p  = VALUE #( ( n = `title` v = `Test` ) )
      )->add( n  = `SimpleForm`
              ns = `form`
              p  = VALUE #( ( n = `editable` v = `true` ) ) ).

    lo_form->add( n  = `content`
                  ns = `form`
      )->leaf( n = `Label`
               p = VALUE #( ( n = `text` v = `Name` ) )
      )->leaf( n = `Input`
               p = VALUE #( ( n = `value` v = `{/NAME}` ) ) ).

    DATA(lv_xml) = lo_form->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `SimpleForm` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Label` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Input` ) ).

  ENDMETHOD.

ENDCLASS.
