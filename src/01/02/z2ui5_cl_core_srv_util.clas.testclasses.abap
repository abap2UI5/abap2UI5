
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_create.

    DATA(lo_util) = NEW z2ui5_cl_core_srv_util( ) ##NEEDED.
    cl_abap_unit_assert=>assert_bound( lo_util ).

  ENDMETHOD.

ENDCLASS.
