CLASS ltcl_test_app DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.
    TYPES:
      BEGIN OF ty_row,
        title    TYPE string,
        value    TYPE string,
        descr    TYPE string,
        icon     TYPE string,
        info     TYPE string,
        selected TYPE abap_bool,
        checkbox TYPE abap_bool,
      END OF ty_row.

    CONSTANTS sv_status TYPE string VALUE `test`.

    CLASS-DATA sv_var TYPE string.
    CLASS-DATA ss_tab TYPE ty_row.
    CLASS-DATA st_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

    DATA mv_val TYPE string.
    DATA ms_tab TYPE ty_row.
    DATA mt_tab TYPE STANDARD TABLE OF ty_row WITH EMPTY KEY.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ltcl_test_app IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

  ENDMETHOD.

ENDCLASS.

CLASS ltcl_unit_01_json DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS test_create     FOR TESTING RAISING cx_static_check.
    METHODS test_create_app    FOR TESTING RAISING cx_static_check.

ENDCLASS.

CLASS ltcl_unit_01_json IMPLEMENTATION.

  METHOD test_create.

    z2ui5_cl_fw_db=>create(
      id = `UNIT_TEST`
      db = VALUE #( id_prev = 'UNIT_TEST_PREV' )
    ).

    DATA(ls_result) = z2ui5_cl_fw_db=>read( 'UNIT_TEST' ).

    IF ls_result-uuid_prev <> 'UNIT_TEST_PREV'.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

  METHOD test_create_app.

    DATA(lo_app) = NEW ltcl_test_app( ).
    lo_app->mv_val = 'test'.

    z2ui5_cl_fw_db=>create(
     id = `UNIT_TEST`
     db = VALUE #( app = lo_app )
   ).

    DATA(ls_result) = z2ui5_cl_fw_db=>read(
                        id             = 'UNIT_TEST'
                        check_load_app = abap_true
                      ).

    IF ls_result-data IS INITIAL.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    DATA(ls_result2) = z2ui5_cl_fw_db=>load_app( 'UNIT_TEST' ).
    IF ls_result2-app IS NOT BOUND.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

    DATA(lo_app_db) = CAST ltcl_test_app( ls_result2-app ).
    IF lo_app_db->mv_val <>  'test'.
      cl_abap_unit_assert=>fail( quit = 5 ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
