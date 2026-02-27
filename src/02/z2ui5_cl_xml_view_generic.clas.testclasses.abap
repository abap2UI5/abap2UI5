CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_factory           FOR TESTING RAISING cx_static_check.
    METHODS test_factory_popup     FOR TESTING RAISING cx_static_check.
    METHODS test_factory_plain     FOR TESTING RAISING cx_static_check.
    METHODS test_shell_page        FOR TESTING RAISING cx_static_check.
    METHODS test_button            FOR TESTING RAISING cx_static_check.
    METHODS test_leaf              FOR TESTING RAISING cx_static_check.
    METHODS test_nested            FOR TESTING RAISING cx_static_check.
    METHODS test_nav_up            FOR TESTING RAISING cx_static_check.
    METHODS test_nav_named         FOR TESTING RAISING cx_static_check.
    METHODS test_nav_not_found     FOR TESTING RAISING cx_static_check.
    METHODS test_namespace         FOR TESTING RAISING cx_static_check.
    METHODS test_table             FOR TESTING RAISING cx_static_check.
    METHODS test_simple_form       FOR TESTING RAISING cx_static_check.
    METHODS test_preferred_param   FOR TESTING RAISING cx_static_check.
    METHODS test_shortcut_av       FOR TESTING RAISING cx_static_check.
    METHODS test_stringify_subnode FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lv_xml) = lo_view->_( n = `Page`
                                p = VALUE #( ( n = `title` v = `test` ) )
                              )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA(lo_popup) = z2ui5_cl_xml_view_generic=>factory_popup( ).
    DATA(lv_xml) = lo_popup->_( n = `Dialog`
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
      )->_( `Shell`
      )->_( n = `Page`
            p = VALUE #( ( n = `title` v = `My Page` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Shell` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Page` ) ).

  ENDMETHOD.

  METHOD test_button.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->_( n = `Page` a = `title` v = `Test`
      )->__( n = `Button`
             p = VALUE #( ( n = `text`  v = `Click Me` )
                           ( n = `press` v = `onPress` ) )
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Click Me` ) ).

  ENDMETHOD.

  METHOD test_leaf.

    DATA(lo_page) = z2ui5_cl_xml_view_generic=>factory(
      )->_( n = `Page` a = `title` v = `Test` ).

    lo_page->__( n = `Button` a = `text` v = `Btn1` ).
    lo_page->__( n = `Button` a = `text` v = `Btn2` ).

    DATA(lv_xml) = lo_page->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Btn1` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Btn2` ) ).

  ENDMETHOD.

  METHOD test_nested.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->_( `Shell`
      )->_( n = `Page` a = `title` v = `Test`
      )->_( `VBox`
      )->_( `HBox`
      )->__( n = `Text` a = `text` v = `Nested`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `VBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `HBox` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Nested` ) ).

  ENDMETHOD.

  METHOD test_nav_up.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    DATA(lo_vbox) = lo_page->_( `VBox` ).
    DATA(lo_parent) = lo_vbox->i( ).

    cl_abap_unit_assert=>assert_equals( exp = lo_page act = lo_parent ).

  ENDMETHOD.

  METHOD test_nav_named.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->_( `VBox`
      )->_( `HBox` ).

    DATA(lo_result) = lo_page->_( `VBox`
      )->_( `HBox`
      )->i( `Page` ).

    cl_abap_unit_assert=>assert_equals( exp = lo_page act = lo_result ).

  ENDMETHOD.

  METHOD test_nav_not_found.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->_( `VBox`
      )->_( `HBox` ).

    DATA(lo_result) = lo_page->_( `VBox`
      )->_( `HBox`
      )->i( `NotExisting` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

  ENDMETHOD.

  METHOD test_namespace.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
        t_ns = VALUE #( ( n = `xmlns:f` v = `sap.f` ) )
      )->_( n  = `DynamicPage`
            ns = `f`
      )->_( n  = `DynamicPageTitle`
            ns = `f`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `f:DynamicPage` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `f:DynamicPageTitle` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `xmlns:f` ) ).

  ENDMETHOD.

  METHOD test_table.

    DATA(lo_page) = z2ui5_cl_xml_view_generic=>factory(
      )->_( n = `Page` a = `title` v = `Test` ).

    DATA(lo_table) = lo_page->_( n = `Table`
                                  p = VALUE #( ( n = `items`      v = `{/ITEMS}` )
                                               ( n = `headerText` v = `My Table` ) ) ).

    lo_table->_( `columns`
      )->_( `Column`
      )->_( `header`
      )->__( n = `Text` a = `text` v = `Col1` ).

    lo_table->_( `items`
      )->_( `ColumnListItem`
      )->_( `cells`
      )->__( n = `Text` a = `text` v = `{COL1}` ).

    DATA(lv_xml) = lo_page->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `My Table` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `columns` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `ColumnListItem` ) ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA(lo_form) = z2ui5_cl_xml_view_generic=>factory(
        t_ns = VALUE #( ( n = `xmlns:form` v = `sap.ui.layout.form` ) )
      )->_( n = `Page` a = `title` v = `Test`
      )->_( n  = `SimpleForm`
            ns = `form`
            a  = `editable`
            v  = `true` ).

    lo_form->_( n  = `content`
                ns = `form`
      )->__( n = `Label` a = `text` v = `Name`
      )->__( n = `Input` a = `value` v = `{/NAME}` ).

    DATA(lv_xml) = lo_form->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `SimpleForm` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Label` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Input` ) ).

  ENDMETHOD.

  METHOD test_preferred_param.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->_( `Shell`
      )->_( `Page`
      )->__( `Button`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Shell` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).

  ENDMETHOD.

  METHOD test_shortcut_av.

    DATA(lv_xml) = z2ui5_cl_xml_view_generic=>factory(
      )->_( `Shell`
      )->__( n = `Button` a = `text` v = `OK`
      )->stringify( ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `Button` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_xml CS `text="OK"` ) ).

  ENDMETHOD.

  METHOD test_stringify_subnode.

    DATA(lo_view) = z2ui5_cl_xml_view_generic=>factory( ).
    DATA(lo_page) = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->__( n = `Button` a = `text` v = `Click` ).

    DATA(lv_full) = lo_page->stringify( ).
    DATA(lv_sub)  = lo_page->stringify( from_root = abap_false ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_full CS `mvc:View` ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( lv_sub CS `mvc:View` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_sub CS `Page` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_sub CS `Button` ) ).

  ENDMETHOD.

ENDCLASS.
