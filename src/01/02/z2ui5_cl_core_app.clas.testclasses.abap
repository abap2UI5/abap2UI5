CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS first_test FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_app DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.
  METHOD first_test.

    DATA lo_action TYPE REF TO z2ui5_cl_core_app.
    CREATE OBJECT lo_action TYPE z2ui5_cl_core_app.

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
    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_app_db TYPE REF TO z2ui5_cl_core_app.
    DATA temp3 TYPE REF TO ltcl_test_db.
    DATA lo_app_user_db LIKE temp3.

    IF sy-sysid = 'ABC'.
      RETURN.
    ENDIF.

    
    CREATE OBJECT lo_app_user TYPE ltcl_test_db.
    lo_app_user->mv_value = `my value`.

    
    CREATE OBJECT lo_app TYPE z2ui5_cl_core_app.
    lo_app->ms_draft-id = `TEST_ID`.
    lo_app->mo_app = lo_app_user.

    lo_app->db_save( ).

    
    lo_app_db = z2ui5_cl_core_app=>db_load( `TEST_ID` ).
    
    temp3 ?= lo_app_db->mo_app.
    
    lo_app_user_db = temp3.

    cl_abap_unit_assert=>assert_equals( exp = lo_app_user->mv_value
                                        act = lo_app_user_db->mv_value ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.
ENDCLASS.
