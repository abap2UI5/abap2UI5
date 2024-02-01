CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_factory FOR TESTING RAISING cx_static_check,
      test_factory_popup FOR TESTING RAISING cx_static_check,
      test_add FOR TESTING RAISING cx_static_check,
      test_add_p FOR TESTING RAISING cx_static_check,
      test_ns FOR TESTING RAISING cx_static_check,
      test_add_add FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_factory.

    DATA(lo_tree) = z2ui5_cl_ui5=>_factory( ).

    DATA(lv_result) = lo_tree->_stringify( ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_result
        exp = `<mvc:View displayBlock="true" height="100%" xmlns:mvc="sap.ui.core.mvc"/>` ).

  ENDMETHOD.

  METHOD test_factory_popup.

    DATA(lo_tree) = z2ui5_cl_ui5=>_factory( abap_true ).

    DATA(lv_result) = lo_tree->_stringify( ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_result
        exp = `<core:FragmentDefinition xmlns:core="sap.ui.core"/>` ).

  ENDMETHOD.

  METHOD test_add.

    DATA(lo_tree) = z2ui5_cl_ui5=>_factory( ).
    lo_tree->_add( n   = 'XML'
                   ns  = `sap.ui.core`
                   t_p = VALUE #( ( n = `test` v = `test_value` ) ) ).

    DATA(lv_result) = lo_tree->_stringify( ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_result
        exp = `<mvc:View displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:mvc="sap.ui.core.mvc"><core:XML test="test_value"/></mvc:View>` ).

  ENDMETHOD.

  METHOD test_add_p.

    DATA(lo_tree) = z2ui5_cl_ui5=>_factory( ).
    lo_tree->_add( n  = 'Test'
                   ns = `sap.ui.core`
        )->_add_p( n = `test_p`
                   v = `test_p_v` ).

    DATA(lv_result) = lo_tree->_stringify( ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_result
        exp = `<mvc:View displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:mvc="sap.ui.core.mvc"><core:Test test_p="test_p_v"/></mvc:View>` ).

  ENDMETHOD.

  METHOD test_add_add.

    DATA(lo_tree) = z2ui5_cl_ui5=>_factory( ).
    lo_tree->_add( n  = 'Test'
                   ns = `sap.ui.core`
        )->_add( n  = `test_p`
                 ns = `sap.ui.core` ).

    DATA(lv_result) = lo_tree->_stringify( ).
    cl_abap_unit_assert=>assert_equals(
        act = lv_result
        exp = `<mvc:View displayBlock="true" height="100%" xmlns:core="sap.ui.core" xmlns:mvc="sap.ui.core.mvc"><core:Test><core:test_p/></core:Test></mvc:View>` ).

  ENDMETHOD.

  METHOD test_ns.

    DATA(lo_html) = NEW z2ui5_cl_ui5( )->_ns_html( ) ##NEEDED.
    DATA(lo_m) = NEW z2ui5_cl_ui5( )->_ns_m( ) ##NEEDED.
    DATA(lo_ndc) = NEW z2ui5_cl_ui5( )->_ns_ndc( ) ##NEEDED.
    DATA(lo_suite) = NEW z2ui5_cl_ui5( )->_ns_suite( ) ##NEEDED.
    DATA(lo_zcc) = NEW z2ui5_cl_ui5( )->_ns_z2ui5( ) ##NEEDED.

  ENDMETHOD.

ENDCLASS.
