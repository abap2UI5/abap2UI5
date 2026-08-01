CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_raise           FOR TESTING RAISING cx_static_check.
    METHODS test_raise_empty     FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_prev FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_cx   FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_populated  FOR TESTING RAISING cx_static_check.
    METHODS test_chain_texts     FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.
  METHOD test_raise.

    TRY.

        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = `this is an error text`.

      CATCH z2ui5_cx_a2ui5_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_equals( exp = `this is an error text`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_empty.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error.
      CATCH z2ui5_cx_a2ui5_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_bound( lx ).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        " never an empty text - it would end up as a blank 500 body
        cl_abap_unit_assert=>assert_equals( exp = `UNKNOWN_ERROR`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    DATA(lx_prev) = NEW z2ui5_cx_a2ui5_error( val = `previous error` ).

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val      = `current error`
                    previous = lx_prev.
      CATCH z2ui5_cx_a2ui5_error INTO DATA(lx).
        DATA(lv_text) = lx->get_text( ).
        cl_abap_unit_assert=>assert_true(
          xsdbool( lv_text CS `current error` ) ).
        cl_abap_unit_assert=>assert_true(
          xsdbool( lv_text CS `previous error` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx.

    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = lx_root.
      CATCH z2ui5_cx_a2ui5_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_populated.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = `test`.
      CATCH z2ui5_cx_a2ui5_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        cl_abap_unit_assert=>assert_equals( exp = 32
                                            act = strlen( lx->ms_error-uuid ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chain_texts.

    DATA(lx_inner) = NEW z2ui5_cx_a2ui5_error( val = `inner` ).
    DATA(lx_middle) = NEW z2ui5_cx_a2ui5_error( val   = `middle`
                                                previous = lx_inner ).
    DATA(lx_outer) = NEW z2ui5_cx_a2ui5_error( val   = `outer`
                                               previous = lx_middle ).

    DATA(lv_text) = lx_outer->get_text( ).
    DATA(lv_nl) = z2ui5_cl_a2ui5_context=>cv_char_util_newline.
    " exact match - each cause exactly once, no duplicated deeper causes
    cl_abap_unit_assert=>assert_equals( exp = |outer{ lv_nl }middle{ lv_nl }inner|
                                        act = lv_text ).

  ENDMETHOD.
ENDCLASS.
