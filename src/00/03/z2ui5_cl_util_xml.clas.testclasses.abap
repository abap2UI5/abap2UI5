CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION MEDIUM.

  PRIVATE SECTION.
    METHODS test_factory           FOR TESTING RAISING cx_static_check.
    METHODS test_factory_popup     FOR TESTING RAISING cx_static_check.
    METHODS test_shell_page        FOR TESTING RAISING cx_static_check.
    METHODS test_button            FOR TESTING RAISING cx_static_check.
    METHODS test_leaf              FOR TESTING RAISING cx_static_check.
    METHODS test_nested            FOR TESTING RAISING cx_static_check.
    METHODS test_nav_up            FOR TESTING RAISING cx_static_check.
    METHODS test_nav_named         FOR TESTING RAISING cx_static_check.
    METHODS test_nav_not_found     FOR TESTING RAISING cx_static_check.
    METHODS test_nav_prev          FOR TESTING RAISING cx_static_check.
    METHODS test_nav_root          FOR TESTING RAISING cx_static_check.
    METHODS test_namespace         FOR TESTING RAISING cx_static_check.
    METHODS test_table             FOR TESTING RAISING cx_static_check.
    METHODS test_simple_form       FOR TESTING RAISING cx_static_check.
    METHODS test_preferred_param   FOR TESTING RAISING cx_static_check.
    METHODS test_shortcut_av       FOR TESTING RAISING cx_static_check.
    METHODS test_stringify_subnode FOR TESTING RAISING cx_static_check.
    METHODS test_p                 FOR TESTING RAISING cx_static_check.
    METHODS test_if_true           FOR TESTING RAISING cx_static_check.
    METHODS test_if_false          FOR TESTING RAISING cx_static_check.
    METHODS test_leaf_if_true      FOR TESTING RAISING cx_static_check.
    METHODS test_leaf_if_false     FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_page_sample   FOR TESTING RAISING cx_static_check.
    METHODS test_ui5_page_sample_indent FOR TESTING RAISING cx_static_check.

    METHODS build_page_view
      RETURNING VALUE(result) TYPE REF TO z2ui5_cl_util_xml.

ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_factory.

    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA temp1 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp2 LIKE LINE OF temp1.
    DATA lv_xml TYPE string.
    DATA temp3 TYPE xsdboolean.
    lo_view = z2ui5_cl_util_xml=>factory( )->_( `View` ).
    
    CLEAR temp1.
    
    temp2-n = `title`.
    temp2-v = `test`.
    INSERT temp2 INTO TABLE temp1.
    
    lv_xml = lo_view->_( n = `Page`
                                p = temp1
                              )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    
    temp3 = boolc( lv_xml CS `Page` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA temp3 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp4 LIKE LINE OF temp3.
    DATA lo_popup TYPE REF TO z2ui5_cl_util_xml.
    DATA temp5 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp6 LIKE LINE OF temp5.
    DATA lv_xml TYPE string.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    CLEAR temp3.
    
    temp4-n = `xmlns`.
    temp4-v = `sap.m`.
    INSERT temp4 INTO TABLE temp3.
    temp4-n = `xmlns:core`.
    temp4-v = `sap.ui.core`.
    INSERT temp4 INTO TABLE temp3.
    
    lo_popup = z2ui5_cl_util_xml=>factory( )->_( n = `FragmentDefinition` ns = `core`
                       p = temp3 ).
    
    CLEAR temp5.
    
    temp6-n = `title`.
    temp6-v = `Test`.
    INSERT temp6 INTO TABLE temp5.
    
    lv_xml = lo_popup->_( n = `Dialog`
                                 p = temp5
                               )->stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_xml ).
    
    temp7 = boolc( lv_xml CS `Dialog` ).
    cl_abap_unit_assert=>assert_true( temp7 ).
    
    temp8 = boolc( lv_xml CS `core:FragmentDefinition` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

  ENDMETHOD.

  METHOD test_shell_page.

    DATA temp7 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp8 LIKE LINE OF temp7.
    DATA lv_xml TYPE string.
    DATA temp9 TYPE xsdboolean.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.
    CLEAR temp7.
    
    temp8-n = `title`.
    temp8-v = `My Page`.
    INSERT temp8 INTO TABLE temp7.
    
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( n = `Page`
            p = temp7
      )->stringify( ).

    
    temp9 = boolc( lv_xml CS `Shell` ).
    cl_abap_unit_assert=>assert_true( temp9 ).
    
    temp10 = boolc( lv_xml CS `Page` ).
    cl_abap_unit_assert=>assert_true( temp10 ).
    
    temp11 = boolc( lv_xml CS `My Page` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD test_button.

    DATA temp9 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp10 LIKE LINE OF temp9.
    DATA lv_xml TYPE string.
    DATA temp12 TYPE xsdboolean.
    DATA temp13 TYPE xsdboolean.
    CLEAR temp9.
    
    temp10-n = `text`.
    temp10-v = `Click Me`.
    INSERT temp10 INTO TABLE temp9.
    temp10-n = `press`.
    temp10-v = `onPress`.
    INSERT temp10 INTO TABLE temp9.
    
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( n = `Page` a = `title` v = `Test`
      )->__( n = `Button`
             p = temp9
      )->stringify( ).

    
    temp12 = boolc( lv_xml CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp12 ).
    
    temp13 = boolc( lv_xml CS `Click Me` ).
    cl_abap_unit_assert=>assert_true( temp13 ).

  ENDMETHOD.

  METHOD test_leaf.

    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA lv_xml TYPE string.
    DATA temp14 TYPE xsdboolean.
    DATA temp15 TYPE xsdboolean.
    lo_page = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( n = `Page` a = `title` v = `Test` ).

    lo_page->__( n = `Button` a = `text` v = `Btn1` ).
    lo_page->__( n = `Button` a = `text` v = `Btn2` ).

    
    lv_xml = lo_page->stringify( ).

    
    temp14 = boolc( lv_xml CS `Btn1` ).
    cl_abap_unit_assert=>assert_true( temp14 ).
    
    temp15 = boolc( lv_xml CS `Btn2` ).
    cl_abap_unit_assert=>assert_true( temp15 ).

  ENDMETHOD.

  METHOD test_nested.

    DATA lv_xml TYPE string.
    DATA temp16 TYPE xsdboolean.
    DATA temp17 TYPE xsdboolean.
    DATA temp18 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( n = `Page` a = `title` v = `Test`
      )->_( `VBox`
      )->_( `HBox`
      )->__( n = `Text` a = `text` v = `Nested`
      )->stringify( ).

    
    temp16 = boolc( lv_xml CS `VBox` ).
    cl_abap_unit_assert=>assert_true( temp16 ).
    
    temp17 = boolc( lv_xml CS `HBox` ).
    cl_abap_unit_assert=>assert_true( temp17 ).
    
    temp18 = boolc( lv_xml CS `Nested` ).
    cl_abap_unit_assert=>assert_true( temp18 ).

  ENDMETHOD.

  METHOD test_nav_up.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_vbox TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_parent TYPE REF TO z2ui5_cl_util_xml.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_view = lo_root->_( n = `View` ns = `mvc` ).
    
    lo_page = lo_view->_( n = `Page` a = `title` v = `Test` ).
    
    lo_vbox = lo_page->_( `VBox` ).
    
    lo_parent = lo_vbox->n( ).

    cl_abap_unit_assert=>assert_equals( exp = lo_page act = lo_parent ).

  ENDMETHOD.

  METHOD test_nav_named.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_result TYPE REF TO z2ui5_cl_util_xml.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_view = lo_root->_( n = `View` ns = `mvc` ).
    
    lo_page = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->_( `VBox`
      )->_( `HBox` ).

    
    lo_result = lo_page->_( `VBox`
      )->_( `HBox`
      )->n( `Page` ).

    cl_abap_unit_assert=>assert_equals( exp = lo_page act = lo_result ).

  ENDMETHOD.

  METHOD test_nav_not_found.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_result TYPE REF TO z2ui5_cl_util_xml.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_view = lo_root->_( n = `View` ns = `mvc` ).
    
    lo_page = lo_view->_( n = `Page` a = `title` v = `Test` ).

    
    lo_result = lo_page->_( `VBox`
      )->_( `HBox`
      )->n( `NotExisting` ).

    cl_abap_unit_assert=>assert_bound( lo_result ).

  ENDMETHOD.

  METHOD test_nav_prev.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_prev TYPE REF TO z2ui5_cl_util_xml.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_view = lo_root->_( n = `View` ns = `mvc` ).
    
    lo_page = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->__( n = `Button` a = `text` v = `Btn` ).

    
    lo_prev = lo_root->n_prev( ).

    cl_abap_unit_assert=>assert_bound( lo_prev ).

  ENDMETHOD.

  METHOD test_nav_root.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_deep TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_result TYPE REF TO z2ui5_cl_util_xml.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_deep = lo_root->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( `Page`
      )->_( `VBox` ).

    
    lo_result = lo_deep->n_root( ).

    cl_abap_unit_assert=>assert_equals( exp = lo_root act = lo_result ).

  ENDMETHOD.

  METHOD test_namespace.

    DATA temp11 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp12 LIKE LINE OF temp11.
    DATA lv_xml TYPE string.
    DATA temp19 TYPE xsdboolean.
    DATA temp20 TYPE xsdboolean.
    DATA temp21 TYPE xsdboolean.
    CLEAR temp11.
    
    temp12-n = `xmlns:f`.
    temp12-v = `sap.f`.
    INSERT temp12 INTO TABLE temp11.
    
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
            p = temp11
      )->_( n  = `DynamicPage`
            ns = `f`
      )->_( n  = `DynamicPageTitle`
            ns = `f`
      )->stringify( ).

    
    temp19 = boolc( lv_xml CS `f:DynamicPage` ).
    cl_abap_unit_assert=>assert_true( temp19 ).
    
    temp20 = boolc( lv_xml CS `f:DynamicPageTitle` ).
    cl_abap_unit_assert=>assert_true( temp20 ).
    
    temp21 = boolc( lv_xml CS `xmlns:f` ).
    cl_abap_unit_assert=>assert_true( temp21 ).

  ENDMETHOD.

  METHOD test_table.

    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA temp13 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp14 LIKE LINE OF temp13.
    DATA lo_table TYPE REF TO z2ui5_cl_util_xml.
    DATA lv_xml TYPE string.
    DATA temp22 TYPE xsdboolean.
    DATA temp23 TYPE xsdboolean.
    DATA temp24 TYPE xsdboolean.
    DATA temp25 TYPE xsdboolean.
    lo_page = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( n = `Page` a = `title` v = `Test` ).

    
    CLEAR temp13.
    
    temp14-n = `items`.
    temp14-v = `{/ITEMS}`.
    INSERT temp14 INTO TABLE temp13.
    temp14-n = `headerText`.
    temp14-v = `My Table`.
    INSERT temp14 INTO TABLE temp13.
    
    lo_table = lo_page->_( n = `Table`
                                  p = temp13 ).

    lo_table->_( `columns`
      )->_( `Column`
      )->_( `header`
      )->__( n = `Text` a = `text` v = `Col1` ).

    lo_table->_( `items`
      )->_( `ColumnListItem`
      )->_( `cells`
      )->__( n = `Text` a = `text` v = `{COL1}` ).

    
    lv_xml = lo_page->stringify( ).

    
    temp22 = boolc( lv_xml CS `Table` ).
    cl_abap_unit_assert=>assert_true( temp22 ).
    
    temp23 = boolc( lv_xml CS `My Table` ).
    cl_abap_unit_assert=>assert_true( temp23 ).
    
    temp24 = boolc( lv_xml CS `columns` ).
    cl_abap_unit_assert=>assert_true( temp24 ).
    
    temp25 = boolc( lv_xml CS `ColumnListItem` ).
    cl_abap_unit_assert=>assert_true( temp25 ).

  ENDMETHOD.

  METHOD test_simple_form.

    DATA temp15 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp16 LIKE LINE OF temp15.
    DATA lo_form TYPE REF TO z2ui5_cl_util_xml.
    DATA lv_xml TYPE string.
    DATA temp26 TYPE xsdboolean.
    DATA temp27 TYPE xsdboolean.
    DATA temp28 TYPE xsdboolean.
    CLEAR temp15.
    
    temp16-n = `xmlns:form`.
    temp16-v = `sap.ui.layout.form`.
    INSERT temp16 INTO TABLE temp15.
    
    lo_form = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
            p = temp15
      )->_( n = `Page` a = `title` v = `Test`
      )->_( n  = `SimpleForm`
            ns = `form`
            a  = `editable`
            v  = `true` ).

    lo_form->_( n  = `content`
                ns = `form`
      )->__( n = `Label` a = `text` v = `Name`
      )->__( n = `Input` a = `value` v = `{/NAME}` ).

    
    lv_xml = lo_form->stringify( ).

    
    temp26 = boolc( lv_xml CS `SimpleForm` ).
    cl_abap_unit_assert=>assert_true( temp26 ).
    
    temp27 = boolc( lv_xml CS `Label` ).
    cl_abap_unit_assert=>assert_true( temp27 ).
    
    temp28 = boolc( lv_xml CS `Input` ).
    cl_abap_unit_assert=>assert_true( temp28 ).

  ENDMETHOD.

  METHOD test_preferred_param.

    DATA lv_xml TYPE string.
    DATA temp29 TYPE xsdboolean.
    DATA temp30 TYPE xsdboolean.
    DATA temp31 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->_( `Page`
      )->__( `Button`
      )->stringify( ).

    
    temp29 = boolc( lv_xml CS `Shell` ).
    cl_abap_unit_assert=>assert_true( temp29 ).
    
    temp30 = boolc( lv_xml CS `Page` ).
    cl_abap_unit_assert=>assert_true( temp30 ).
    
    temp31 = boolc( lv_xml CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp31 ).

  ENDMETHOD.

  METHOD test_shortcut_av.

    DATA lv_xml TYPE string.
    DATA temp32 TYPE xsdboolean.
    DATA temp33 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Shell`
      )->__( n = `Button` a = `text` v = `OK`
      )->stringify( ).

    
    temp32 = boolc( lv_xml CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp32 ).
    
    temp33 = boolc( lv_xml CS `text="OK"` ).
    cl_abap_unit_assert=>assert_true( temp33 ).

  ENDMETHOD.

  METHOD test_stringify_subnode.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA lv_full TYPE string.
    DATA lv_sub TYPE string.
    DATA temp34 TYPE xsdboolean.
    DATA temp35 TYPE xsdboolean.
    DATA temp36 TYPE xsdboolean.
    DATA temp37 TYPE xsdboolean.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_view = lo_root->_( n = `View` ns = `mvc` ).
    
    lo_page = lo_view->_( n = `Page` a = `title` v = `Test` ).
    lo_page->__( n = `Button` a = `text` v = `Click` ).

    
    lv_full = lo_page->stringify( ).
    
    lv_sub  = lo_page->stringify( from_root = abap_false ).

    
    temp34 = boolc( lv_full CS `mvc:View` ).
    cl_abap_unit_assert=>assert_true( temp34 ).
    
    temp35 = boolc( lv_sub CS `mvc:View` ).
    cl_abap_unit_assert=>assert_false( temp35 ).
    
    temp36 = boolc( lv_sub CS `Page` ).
    cl_abap_unit_assert=>assert_true( temp36 ).
    
    temp37 = boolc( lv_sub CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp37 ).

  ENDMETHOD.

  METHOD test_p.

    DATA lo_root TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_view TYPE REF TO z2ui5_cl_util_xml.
    DATA lo_btn TYPE REF TO z2ui5_cl_util_xml.
    DATA lv_xml TYPE string.
    DATA temp38 TYPE xsdboolean.
    DATA temp39 TYPE xsdboolean.
    DATA temp40 TYPE xsdboolean.
    lo_root = z2ui5_cl_util_xml=>factory( ).
    
    lo_view = lo_root->_( n = `View` ns = `mvc` ).
    
    lo_btn  = lo_view->_( `Page`
      )->_( n = `Button` a = `text` v = `OK` ).

    lo_btn->p( n = `type` v = `Emphasized` ).
    lo_btn->p( n = `icon` v = `sap-icon://accept` ).

    
    lv_xml = lo_root->stringify( ).

    
    temp38 = boolc( lv_xml CS `text="OK"` ).
    cl_abap_unit_assert=>assert_true( temp38 ).
    
    temp39 = boolc( lv_xml CS `type="Emphasized"` ).
    cl_abap_unit_assert=>assert_true( temp39 ).
    
    temp40 = boolc( lv_xml CS `sap-icon://accept` ).
    cl_abap_unit_assert=>assert_true( temp40 ).

  ENDMETHOD.

  METHOD test_if_true.

    DATA lv_xml TYPE string.
    DATA temp41 TYPE xsdboolean.
    DATA temp42 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->_if( when = abap_true
              n    = `Panel`
              a    = `headerText`
              v    = `Admin`
      )->__( n = `Text` a = `text` v = `Secret`
      )->n( `Page`
      )->stringify( ).

    
    temp41 = boolc( lv_xml CS `Panel` ).
    cl_abap_unit_assert=>assert_true( temp41 ).
    
    temp42 = boolc( lv_xml CS `Secret` ).
    cl_abap_unit_assert=>assert_true( temp42 ).

  ENDMETHOD.

  METHOD test_if_false.

    DATA lv_xml TYPE string.
    DATA temp43 TYPE xsdboolean.
    DATA temp44 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->_if( when = abap_false
              n    = `Panel`
              a    = `headerText`
              v    = `Admin`
      )->__( n = `Button` a = `text` v = `Visible`
      )->stringify( ).

    
    temp43 = boolc( lv_xml CS `Panel` ).
    cl_abap_unit_assert=>assert_false( temp43 ).
    
    temp44 = boolc( lv_xml CS `Button` ).
    cl_abap_unit_assert=>assert_true( temp44 ).

  ENDMETHOD.

  METHOD test_leaf_if_true.

    DATA lv_xml TYPE string.
    DATA temp45 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->__if( when = abap_true
               n    = `Button`
               a    = `text`
               v    = `Admin Only`
      )->stringify( ).

    
    temp45 = boolc( lv_xml CS `Admin Only` ).
    cl_abap_unit_assert=>assert_true( temp45 ).

  ENDMETHOD.

  METHOD test_leaf_if_false.

    DATA lv_xml TYPE string.
    DATA temp46 TYPE xsdboolean.
    DATA temp47 TYPE xsdboolean.
    lv_xml = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
      )->_( `Page`
      )->__if( when = abap_false
               n    = `Button`
               a    = `text`
               v    = `Hidden`
      )->__( n = `Text` a = `text` v = `Visible`
      )->stringify( ).

    
    temp46 = boolc( lv_xml CS `Hidden` ).
    cl_abap_unit_assert=>assert_false( temp46 ).
    
    temp47 = boolc( lv_xml CS `Visible` ).
    cl_abap_unit_assert=>assert_true( temp47 ).

  ENDMETHOD.

  METHOD build_page_view.

    DATA temp17 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp18 LIKE LINE OF temp17.
    DATA temp19 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp20 LIKE LINE OF temp19.
    DATA lo_page TYPE REF TO z2ui5_cl_util_xml.
    DATA temp21 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp22 LIKE LINE OF temp21.
    DATA lo_footer_toolbar TYPE REF TO z2ui5_cl_util_xml.
    DATA temp23 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp24 LIKE LINE OF temp23.
    DATA temp25 TYPE z2ui5_cl_util=>ty_t_name_value.
    DATA temp26 LIKE LINE OF temp25.
    CLEAR temp17.
    
    temp18-n = `height`.
    temp18-v = `100%`.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `xmlns:mvc`.
    temp18-v = `sap.ui.core.mvc`.
    INSERT temp18 INTO TABLE temp17.
    temp18-n = `xmlns`.
    temp18-v = `sap.m`.
    INSERT temp18 INTO TABLE temp17.
    result = z2ui5_cl_util_xml=>factory(
      )->_( n = `View` ns = `mvc`
            p = temp17 ).

    
    CLEAR temp19.
    
    temp20-n = `title`.
    temp20-v = `Title`.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `class`.
    temp20-v = `sapUiContentPadding sapUiResponsivePadding--header sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer`.
    INSERT temp20 INTO TABLE temp19.
    temp20-n = `showNavButton`.
    temp20-v = `true`.
    INSERT temp20 INTO TABLE temp19.
    
    lo_page = result->_( n = `Page`
      p = temp19 ).

    
    CLEAR temp21.
    
    temp22-n = `icon`.
    temp22-v = `sap-icon://action`.
    INSERT temp22 INTO TABLE temp21.
    temp22-n = `tooltip`.
    temp22-v = `Share`.
    INSERT temp22 INTO TABLE temp21.
    lo_page->_( `headerContent`
      )->__( n = `Button`
             p = temp21 ).

    lo_page->_( `subHeader`
      )->_( `OverflowToolbar`
      )->__( `SearchField` ).

    lo_page->_( `content`
      )->_( `VBox`
      )->__( n = `Text` a = `text`
             v = `Lorem ipsum dolor st amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
           && ` At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
           && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
           && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat` ).

    
    lo_footer_toolbar = lo_page->_( `footer`
      )->_( `OverflowToolbar` ).
    lo_footer_toolbar->__( `ToolbarSpacer` ).
    
    CLEAR temp23.
    
    temp24-n = `text`.
    temp24-v = `Accept`.
    INSERT temp24 INTO TABLE temp23.
    temp24-n = `type`.
    temp24-v = `Accept`.
    INSERT temp24 INTO TABLE temp23.
    lo_footer_toolbar->__( n = `Button` p = temp23 ).
    
    CLEAR temp25.
    
    temp26-n = `text`.
    temp26-v = `Reject`.
    INSERT temp26 INTO TABLE temp25.
    temp26-n = `type`.
    temp26-v = `Reject`.
    INSERT temp26 INTO TABLE temp25.
    lo_footer_toolbar->__( n = `Button` p = temp25 ).
    lo_footer_toolbar->__( n = `Button` a = `text` v = `Edit` ).
    lo_footer_toolbar->__( n = `Button` a = `text` v = `Delete` ).

  ENDMETHOD.

  METHOD test_ui5_page_sample.

    DATA lv_xml TYPE string.
    DATA lv_exp TYPE string.
    lv_xml = build_page_view( )->stringify( ).

    
    lv_exp = ` <mvc:View height="100%" xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc">`
                && ` <Page class="sapUiContentPadding sapUiResponsivePadding--header sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" showNavButton="true" title="Title">`
                && ` <headerContent>`
                && ` <Button icon="sap-icon://action" tooltip="Share"/>`
                && `</headerContent>`
                && ` <subHeader>`
                && ` <OverflowToolbar>`
                && ` <SearchField/>`
                && `</OverflowToolbar>`
                && `</subHeader>`
                && ` <content>`
                && ` <VBox>`
                && ` <Text text="Lorem ipsum dolor st amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat"/>`
                && `</VBox>`
                && `</content>`
                && ` <footer>`
                && ` <OverflowToolbar>`
                && ` <ToolbarSpacer/>`
                && ` <Button text="Accept" type="Accept"/>`
                && ` <Button text="Reject" type="Reject"/>`
                && ` <Button text="Edit"/>`
                && ` <Button text="Delete"/>`
                && `</OverflowToolbar>`
                && `</footer>`
                && `</Page>`
                && `</mvc:View>`.

    cl_abap_unit_assert=>assert_equals( exp = lv_exp act = lv_xml ).

  ENDMETHOD.

  METHOD test_ui5_page_sample_indent.

    DATA lv_xml TYPE string.
    DATA lv_exp TYPE string.
    lv_xml = build_page_view( )->stringify( indent = abap_true ).

    
    lv_exp = `<mvc:View height="100%" xmlns="sap.m" xmlns:mvc="sap.ui.core.mvc">` && |\n|
                && `  <Page class="sapUiContentPadding sapUiResponsivePadding--header sapUiResponsivePadding--subHeader sapUiResponsivePadding--content sapUiResponsivePadding--footer" showNavButton="true" title="Title">` && |\n|
                && `    <headerContent>` && |\n|
                && `      <Button icon="sap-icon://action" tooltip="Share"/>` && |\n|
                && `    </headerContent>` && |\n|
                && `    <subHeader>` && |\n|
                && `      <OverflowToolbar>` && |\n|
                && `        <SearchField/>` && |\n|
                && `      </OverflowToolbar>` && |\n|
                && `    </subHeader>` && |\n|
                && `    <content>` && |\n|
                && `      <VBox>` && |\n|
                && `        <Text text="Lorem ipsum dolor st amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.`
                && ` Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat"/>` && |\n|
                && `      </VBox>` && |\n|
                && `    </content>` && |\n|
                && `    <footer>` && |\n|
                && `      <OverflowToolbar>` && |\n|
                && `        <ToolbarSpacer/>` && |\n|
                && `        <Button text="Accept" type="Accept"/>` && |\n|
                && `        <Button text="Reject" type="Reject"/>` && |\n|
                && `        <Button text="Edit"/>` && |\n|
                && `        <Button text="Delete"/>` && |\n|
                && `      </OverflowToolbar>` && |\n|
                && `    </footer>` && |\n|
                && `  </Page>` && |\n|
                && `</mvc:View>`.

    cl_abap_unit_assert=>assert_equals( exp = lv_exp act = lv_xml ).

  ENDMETHOD.

ENDCLASS.
