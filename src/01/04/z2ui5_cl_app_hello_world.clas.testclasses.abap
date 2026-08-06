
CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create          FOR TESTING RAISING cx_static_check.
    METHODS test_implements_app  FOR TESTING RAISING cx_static_check.
    METHODS test_name_attribute  FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD test_create.

    DATA(lo_app) = NEW z2ui5_cl_app_hello_world( ).
    cl_abap_unit_assert=>assert_bound( lo_app ).

  ENDMETHOD.

  METHOD test_implements_app.

    DATA(lo_app) = NEW z2ui5_cl_app_hello_world( ).
    DATA li_app TYPE REF TO z2ui5_if_app.
    li_app ?= lo_app.
    cl_abap_unit_assert=>assert_bound( li_app ).

  ENDMETHOD.

  METHOD test_name_attribute.

    DATA(lo_app) = NEW z2ui5_cl_app_hello_world( ).
    lo_app->name = `Test Name`.
    cl_abap_unit_assert=>assert_equals( exp = `Test Name`
                                        act = lo_app->name ).

  ENDMETHOD.

ENDCLASS.
