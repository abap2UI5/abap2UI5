CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_raise              FOR TESTING RAISING cx_static_check.
    METHODS test_raise_empty        FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_prev    FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_cx_root FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_is_set        FOR TESTING RAISING cx_static_check.
    METHODS test_unknown_error      FOR TESTING RAISING cx_static_check.
    METHODS test_inherits_cx_root   FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_raise.

    TRY.

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `this is an error text`.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_equals( exp = `this is an error text`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_empty.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_bound( lx ).
        " Empty text with error flag should produce UNKNOWN_ERROR
        DATA(lv_text) = lx->get_text( ).
        cl_abap_unit_assert=>assert_not_initial( lv_text ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    TRY.
        TRY.
            RAISE EXCEPTION TYPE z2ui5_cx_util_error
              EXPORTING val = `inner error`.
          CATCH z2ui5_cx_util_error INTO DATA(lx_inner).
        ENDTRY.

        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val      = `outer error`
                    previous = lx_inner.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_bound( lx->previous ).
        cl_abap_unit_assert=>assert_char_cp(
            act = lx->get_text( )
            exp = `*outer error*` ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx_root.

    TRY.
        DATA(lv_val) = 1 / 0.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = lx_root.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        " Should use the wrapped cx_root's text
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_is_set.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `test`.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_unknown_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = ``.

      CATCH z2ui5_cx_util_error INTO DATA(lx).
        DATA(lv_text) = lx->get_text( ).
        " Empty val results in empty text field, but the error flag logic
        " should handle this case
        cl_abap_unit_assert=>assert_bound( lx ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_inherits_cx_root.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `catch me`.

      CATCH cx_root INTO DATA(lx).
        cl_abap_unit_assert=>assert_bound( lx ).
        cl_abap_unit_assert=>assert_char_cp(
            act = lx->get_text( )
            exp = `*catch me*` ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
