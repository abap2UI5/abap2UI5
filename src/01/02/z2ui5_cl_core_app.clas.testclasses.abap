CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_instantiation     FOR TESTING RAISING cx_static_check.
    METHODS test_attri_initialized FOR TESTING RAISING cx_static_check.
    METHODS test_buffer_clear      FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS z2ui5_cl_core_app DEFINITION LOCAL FRIENDS ltcl_test.

CLASS ltcl_test IMPLEMENTATION.
  METHOD test_instantiation.

    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    lo_app = NEW #( ).

    cl_abap_unit_assert=>assert_bound( lo_app ).
    cl_abap_unit_assert=>assert_bound( lo_app->mt_attri ).

  ENDMETHOD.

  METHOD test_attri_initialized.

    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    lo_app = NEW #( ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( lo_app->mt_attri->* ) ).

  ENDMETHOD.

  METHOD test_buffer_clear.

    z2ui5_cl_core_app=>db_load_buffer_clear( ).

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = lines( z2ui5_cl_core_app=>mt_buffer ) ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test_db DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PUBLIC SECTION.

    DATA mv_value TYPE string.
    DATA mv_name  TYPE string.
    DATA mv_count TYPE i.

    INTERFACES z2ui5_if_app.

    METHODS constructor.

    METHODS test_db_save            FOR TESTING.
    METHODS test_db_roundtrip       FOR TESTING.
    METHODS test_db_save_complex    FOR TESTING.
    METHODS test_model_stringify    FOR TESTING.

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
    DATA temp1 TYPE REF TO ltcl_test_db.
    DATA lo_app_user_db LIKE temp1.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `my value`.


    lo_app = NEW #( ).
    lo_app->ms_draft-id = `TEST_ID`.
    lo_app->mo_app = lo_app_user.

    lo_app->db_save( ).

    z2ui5_cl_core_app=>db_load_buffer_clear( ).

    lo_app_db = z2ui5_cl_core_app=>db_load( `TEST_ID` ).

    temp1 ?= lo_app_db->mo_app.

    lo_app_user_db = temp1.

    cl_abap_unit_assert=>assert_equals( exp = lo_app_user->mv_value
                                        act = lo_app_user_db->mv_value ).

  ENDMETHOD.

  METHOD test_db_roundtrip.
    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lo_loaded TYPE REF TO z2ui5_cl_core_app.
    DATA temp2 TYPE REF TO ltcl_test_db.
    DATA lo_restored LIKE temp2.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `roundtrip value`.
    lo_app_user->mv_name  = `test name`.
    lo_app_user->mv_count = 42.


    lo_app = NEW #( ).
    lo_app->ms_draft-id = `TEST_ROUNDTRIP`.
    lo_app->mo_app = lo_app_user.

    lo_app->db_save( ).

    z2ui5_cl_core_app=>db_load_buffer_clear( ).

    lo_loaded = z2ui5_cl_core_app=>db_load( `TEST_ROUNDTRIP` ).

    temp2 ?= lo_loaded->mo_app.

    lo_restored = temp2.

    cl_abap_unit_assert=>assert_equals( exp = `roundtrip value`
                                        act = lo_restored->mv_value ).
    cl_abap_unit_assert=>assert_equals( exp = `test name`
                                        act = lo_restored->mv_name ).
    cl_abap_unit_assert=>assert_equals( exp = 42
                                        act = lo_restored->mv_count ).

  ENDMETHOD.

  METHOD test_db_save_complex.
    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA temp3 TYPE REF TO z2ui5_if_app.

    IF sy-sysid = `ABC`.
      RETURN.
    ENDIF.


    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `complex`.


    lo_app = NEW #( ).
    lo_app->ms_draft-id = `TEST_COMPLEX`.
    lo_app->mo_app = lo_app_user.
    lo_app->ms_draft-id_prev = `PREV_ID`.
    lo_app->ms_draft-id_prev_app = `PREV_APP`.

    lo_app->db_save( ).


    temp3 ?= lo_app->mo_app.
    cl_abap_unit_assert=>assert_equals( exp = abap_true
                                        act = temp3->check_initialized ).

  ENDMETHOD.

  METHOD test_model_stringify.

    DATA lo_app_user TYPE REF TO ltcl_test_db.
    DATA lo_app TYPE REF TO z2ui5_cl_core_app.
    DATA lv_json TYPE string.
    lo_app_user = NEW #( ).
    lo_app_user->mv_value = `json test`.


    lo_app = NEW #( ).
    lo_app->mo_app = lo_app_user.


    lv_json = lo_app->model_json_stringify( ).

    cl_abap_unit_assert=>assert_not_initial( lv_json ).

  ENDMETHOD.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.
ENDCLASS.
