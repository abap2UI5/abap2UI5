
CLASS ltcl_unit_test_log DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_create            FOR TESTING RAISING cx_static_check.
    METHODS test_to_msg_empty      FOR TESTING RAISING cx_static_check.
    METHODS test_add_string        FOR TESTING RAISING cx_static_check.
    METHODS test_add_multiple      FOR TESTING RAISING cx_static_check.
    METHODS test_to_csv            FOR TESTING RAISING cx_static_check.
    METHODS test_add_exception     FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_test_log IMPLEMENTATION.

  METHOD test_create.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    cl_abap_unit_assert=>assert_bound( lo_log ).

  ENDMETHOD.

  METHOD test_to_msg_empty.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_initial( lt_msg ).

  ENDMETHOD.

  METHOD test_add_string.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->add( `Test message` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Test message`
                                        act = lt_msg[ 1 ]-text ).

  ENDMETHOD.

  METHOD test_add_multiple.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->add( `First message` ).
    lo_log->add( `Second message` ).
    lo_log->add( `Third message` ).

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lt_msg ) ).

    cl_abap_unit_assert=>assert_equals( exp = `First message`
                                        act = lt_msg[ 1 ]-text ).

    cl_abap_unit_assert=>assert_equals( exp = `Third message`
                                        act = lt_msg[ 3 ]-text ).

  ENDMETHOD.

  METHOD test_to_csv.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).
    lo_log->add( `CSV test entry` ).

    DATA(lv_csv) = lo_log->to_csv( ).

    cl_abap_unit_assert=>assert_not_initial( lv_csv ).

    " CSV should contain the header row
    cl_abap_unit_assert=>assert_char_cp(
        act = lv_csv
        exp = `*TEXT*` ).

  ENDMETHOD.

  METHOD test_add_exception.

    DATA(lo_log) = NEW z2ui5_cl_util_log( ).

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `error in log`.
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        lo_log->add( lx ).
    ENDTRY.

    DATA(lt_msg) = lo_log->to_msg( ).

    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lines( lt_msg ) ).

    cl_abap_unit_assert=>assert_equals( exp = `E`
                                        act = lt_msg[ 1 ]-type ).

  ENDMETHOD.

ENDCLASS.
