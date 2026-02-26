CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.

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
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    DATA(lx_prev) = NEW z2ui5_cx_util_error( val = `previous error` ).

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val      = `current error`
                    previous = lx_prev.
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        DATA(lv_text) = lx->get_text( ).
        cl_abap_unit_assert=>assert_true(
          xsdbool( lv_text CS `current error` ) ).
        cl_abap_unit_assert=>assert_true(
          xsdbool( lv_text CS `previous error` ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx.

    TRY.
        DATA(lv_val) = 1 / 0.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = lx_root.
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_populated.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_util_error
          EXPORTING val = `test`.
      CATCH z2ui5_cx_util_error INTO DATA(lx).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        cl_abap_unit_assert=>assert_equals( exp = 32
                                            act = strlen( lx->ms_error-uuid ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chain_texts.

    DATA(lx_inner) = NEW z2ui5_cx_util_error( val = `inner` ).
    DATA(lx_middle) = NEW z2ui5_cx_util_error( val      = `middle`
                                                previous = lx_inner ).
    DATA(lx_outer) = NEW z2ui5_cx_util_error( val      = `outer`
                                               previous = lx_middle ).

    DATA(lv_text) = lx_outer->get_text( ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `outer` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `middle` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `inner` ) ).

  ENDMETHOD.
ENDCLASS.
