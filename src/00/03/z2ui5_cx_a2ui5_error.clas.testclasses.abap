CLASS ltcl_unit_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    METHODS test_raise             FOR TESTING RAISING cx_static_check.
    METHODS test_raise_empty       FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_prev   FOR TESTING RAISING cx_static_check.
    METHODS test_raise_with_cx     FOR TESTING RAISING cx_static_check.
    METHODS test_uuid_populated    FOR TESTING RAISING cx_static_check.
    METHODS test_chain_texts       FOR TESTING RAISING cx_static_check.
    METHODS test_cause_kept_by_val FOR TESTING RAISING cx_static_check.
    METHODS test_no_duplicate_text FOR TESTING RAISING cx_static_check.
    METHODS test_text_full_chain   FOR TESTING RAISING cx_static_check.
    METHODS test_text_full_any_cx  FOR TESTING RAISING cx_static_check.
    METHODS test_text_full_unbound FOR TESTING RAISING cx_static_check.
    METHODS test_chain_bounded     FOR TESTING RAISING cx_static_check.
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

  METHOD test_cause_kept_by_val.

    " the framework's dominant pattern: the caught exception is handed over
    " as `val`, without a `previous`. Everything below it must survive - it
    " used to be dropped, leaving only the outermost message
    DATA(lx_inner) = NEW z2ui5_cx_a2ui5_error( val = `root cause` ).
    DATA(lx_middle) = NEW z2ui5_cx_a2ui5_error( val   = `middle layer`
                                                previous = lx_inner ).

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = lx_middle.
      CATCH z2ui5_cx_a2ui5_error INTO DATA(lx).
        DATA(lv_nl) = z2ui5_cl_a2ui5_context=>cv_char_util_newline.
        cl_abap_unit_assert=>assert_equals( exp = |middle layer{ lv_nl }root cause|
                                            act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->previous ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_no_duplicate_text.

    " a wrapper that only re-raises carries the same text as its cause -
    " it must appear once, not twice
    DATA(lx_inner) = NEW z2ui5_cx_a2ui5_error( val = `same text` ).
    DATA(lx_outer) = NEW z2ui5_cx_a2ui5_error( val      = `same text`
                                               previous = lx_inner ).

    cl_abap_unit_assert=>assert_equals( exp = `same text`
                                        act = lx_outer->get_text( ) ).

  ENDMETHOD.

  METHOD test_text_full_chain.

    DATA(lx_inner) = NEW z2ui5_cx_a2ui5_error( val = `root cause` ).
    DATA(lx_outer) = NEW z2ui5_cx_a2ui5_error( val      = `outer problem`
                                               previous = lx_inner ).

    DATA(lv_text) = z2ui5_cx_a2ui5_error=>get_text_full( lx_outer ).

    " headline (both messages), one detail block per chain entry, the class
    " name of every entry and the system context
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `outer problem` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `root cause` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `exception chain` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `[1] Z2UI5_CX_A2UI5_ERROR` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `[2] Z2UI5_CX_A2UI5_ERROR` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `context` ) ).

  ENDMETHOD.

  METHOD test_text_full_any_cx.

    " the top-level catch sees whatever was raised - a plain SAP exception
    " must be rendered as fully as a framework one
    TRY.
        DATA(lv_val) = 1 / 0 ##NEEDED.
      CATCH cx_root INTO DATA(lx_root).
    ENDTRY.

    DATA(lv_text) = z2ui5_cx_a2ui5_error=>get_text_full( lx_root ).

    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `[1] CX_SY_ZERODIVIDE` ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( lv_text CS `exception chain` ) ).

  ENDMETHOD.

  METHOD test_text_full_unbound.

    " the renderer runs while an error is being handled - it must answer
    " something for every input instead of raising on its own
    DATA lx_unbound TYPE REF TO cx_root.

    cl_abap_unit_assert=>assert_equals( exp = `UNKNOWN_ERROR`
                                        act = z2ui5_cx_a2ui5_error=>get_text_full( lx_unbound ) ).

  ENDMETHOD.

  METHOD test_chain_bounded.

    " the chain walk is capped so a self-referencing `previous` cannot hang
    " the one routine that must always answer - and the reader is told that
    " the output was cut, instead of silently seeing a shortened chain
    DATA(lx) = NEW z2ui5_cx_a2ui5_error( val = `level 0` ).

    DO 30 TIMES.
      lx = NEW z2ui5_cx_a2ui5_error( val      = |level { sy-index }|
                                     previous = lx ).
    ENDDO.

    cl_abap_unit_assert=>assert_true(
      xsdbool( z2ui5_cx_a2ui5_error=>get_text_full( lx ) CS `chain truncated` ) ).
    cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).

  ENDMETHOD.
ENDCLASS.
