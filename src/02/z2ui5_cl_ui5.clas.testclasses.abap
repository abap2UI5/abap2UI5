*"* use this source file for your ABAP unit test classes
CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS:
      test_add FOR TESTING RAISING cx_static_check,
      test_add_p FOR TESTING RAISING cx_static_check,
      test_go FOR TESTING RAISING cx_static_check,
      test_NS FOR TESTING RAISING cx_static_check,
      test_add_add FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_add.

    DATA(lo_tree) = NEW z2ui5_cl_ui5( ).
    lo_tree->_add( n = 'XML' ns = `core` t_p = VALUE #( ( n = `xmlns` v = `sap.m` ) ) ).

    DATA(lv_result) = lo_tree->_stringify( ).

    cl_abap_unit_assert=>fail( 'Implement your first test here' ).

  ENDMETHOD.

  METHOD test_add_p.

    DATA(lo_tree) = NEW z2ui5_cl_ui5( ).
    lo_tree->_add( n = 'XML' ns = `core`
        )->_add_p( n = `xmlns` v = `sap.m` ).

    DATA(lv_result) = lo_tree->_stringify( ).

    cl_abap_unit_assert=>fail( 'Implement your first test here' ).

  ENDMETHOD.

    METHOD test_add_add.

    DATA(lo_tree) = NEW z2ui5_cl_ui5( ).
    lo_tree->_add( n = 'XML' ns = `core`
        )->_add( n = `XML_CHILD` ns = `core` ).

    DATA(lv_result) = lo_tree->_stringify( ).

    cl_abap_unit_assert=>fail( 'Implement your first test here' ).

  ENDMETHOD.

      METHOD test_go.

    DATA(lo_tree) = NEW z2ui5_cl_ui5( ).
    data(lo_parent) = lo_tree->_add( n = 'XML' ns = `core` ).
    data(lo_child) = lo_parent->_add( n = `XML_CHILD` ns = `core` ).

    if lo_parent->_go_new( ) <> lo_child.

    endif.

    if lo_child->_go_up( ) <> lo_parent.

    endif.

    if lo_child->_go_root( ) <> lo_tree.

    endif.

    cl_abap_unit_assert=>fail( 'Implement your first test here' ).

  ENDMETHOD.

      METHOD test_NS.

    DATA(lo_html) = NEW z2ui5_cl_ui5( )->_ns_html( ).
    DATA(lo_m) = NEW z2ui5_cl_ui5( )->_ns_m( ).
    DATA(lo_ndc) = NEW z2ui5_cl_ui5( )->_ns_ndc( ).
    DATA(lo_suite) = NEW z2ui5_cl_ui5( )->_ns_suite( ).
    DATA(lo_zcc) = NEW z2ui5_cl_ui5( )->_ns_zcc( ).

  ENDMETHOD.

ENDCLASS.
