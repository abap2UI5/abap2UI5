CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_app DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.
  METHOD first_test.

    DATA(lo_action) = NEW z2ui5_cl_core_app( ) ##NEEDED.

  ENDMETHOD.
ENDCLASS.


CLASS ltcl_test_db DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    DATA mv_value TYPE string.

    INTERFACES z2ui5_if_app.

    METHODS constructor.

    METHODS test_db_save FOR TESTING.

  PROTECTED SECTION.

  PRIVATE SECTION.
ENDCLASS.


CLASS ltcl_test_db IMPLEMENTATION.
  METHOD constructor.

  ENDMETHOD.

  METHOD test_db_save.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    DATA(lo_app_user) = NEW ltcl_test_db( ).
    lo_app_user->mv_value = `my value`.

    DATA(lo_app) = NEW z2ui5_cl_core_app( ).
    lo_app->ms_draft-id = `TEST_ID`.
    lo_app->mo_app = lo_app_user.

    lo_app->db_save( ).

    DATA(lo_app_db) = z2ui5_cl_core_app=>db_load( `TEST_ID` ).
    DATA(lo_app_user_db) = CAST ltcl_test_db( lo_app_db->mo_app ).

    cl_abap_unit_assert=>assert_equals( exp = lo_app_user->mv_value
                                        act = lo_app_user_db->mv_value ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.
ENDCLASS.
