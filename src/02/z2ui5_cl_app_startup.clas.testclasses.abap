CLASS ltcl_app_startup_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_first FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_app_startup_test IMPLEMENTATION.
  METHOD test_first.

    DATA(lo_app) = z2ui5_cl_app_startup=>factory( ) ##NEEDED.

  ENDMETHOD.
ENDCLASS.
