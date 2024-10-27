CLASS ltcl_app_startup_test DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_app_startup_test IMPLEMENTATION.
  METHOD first_test.

    DATA(lo_app) = z2ui5_cl_app_startup=>factory( ) ##NEEDED.

  ENDMETHOD.
ENDCLASS.
