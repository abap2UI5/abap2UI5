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
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.

        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = `this is an error text`.


      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = `this is an error text`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_empty.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error.

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_bound( lx ).
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        " never an empty text - it would end up as a blank 500 body
        cl_abap_unit_assert=>assert_equals( exp = `UNKNOWN_ERROR`
                                            act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_prev.

    DATA lx_prev TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA lv_text TYPE string.
        DATA temp1 TYPE xsdboolean.
        DATA temp2 TYPE xsdboolean.
    CREATE OBJECT lx_prev TYPE z2ui5_cx_ui5_util_error EXPORTING val = `previous error`.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val      = `current error`
                    previous = lx_prev.

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        lv_text = lx->get_text( ).

        temp1 = boolc( lv_text CS `current error` ).
        cl_abap_unit_assert=>assert_true(
          temp1 ).

        temp2 = boolc( lv_text CS `previous error` ).
        cl_abap_unit_assert=>assert_true(
          temp2 ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_raise_with_cx.
        DATA lv_val TYPE i.
        DATA lx_root TYPE REF TO cx_root.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.

        lv_val = 1 / 0 ##NEEDED.

      CATCH cx_root INTO lx_root.
    ENDTRY.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = lx_root.

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->ms_error-x_root ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_uuid_populated.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = `test`.

      CATCH z2ui5_cx_ui5_util_error INTO lx.
        cl_abap_unit_assert=>assert_not_initial( lx->ms_error-uuid ).
        cl_abap_unit_assert=>assert_equals( exp = 32
                                            act = strlen( lx->ms_error-uuid ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chain_texts.

    DATA lx_inner TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lx_middle TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lx_outer TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lv_text TYPE string.
    DATA lv_nl LIKE z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    CREATE OBJECT lx_inner TYPE z2ui5_cx_ui5_util_error EXPORTING val = `inner`.

    CREATE OBJECT lx_middle TYPE z2ui5_cx_ui5_util_error EXPORTING val = `middle` previous = lx_inner.

    CREATE OBJECT lx_outer TYPE z2ui5_cx_ui5_util_error EXPORTING val = `outer` previous = lx_middle.


    lv_text = lx_outer->get_text( ).

    lv_nl = z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    " exact match - each cause exactly once, no duplicated deeper causes
    cl_abap_unit_assert=>assert_equals( exp = |outer{ lv_nl }middle{ lv_nl }inner|
                                        act = lv_text ).

  ENDMETHOD.

  METHOD test_cause_kept_by_val.

    " the framework's dominant pattern: the caught exception is handed over
    " as `val`, without a `previous`. Everything below it must survive - it
    " used to be dropped, leaving only the outermost message
    DATA lx_inner TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lx_middle TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
        DATA lv_nl LIKE z2ui5_cl_ui5_util_context=>cv_char_util_newline.
    CREATE OBJECT lx_inner TYPE z2ui5_cx_ui5_util_error EXPORTING val = `root cause`.

    CREATE OBJECT lx_middle TYPE z2ui5_cx_ui5_util_error EXPORTING val = `middle layer` previous = lx_inner.

    TRY.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_util_error
          EXPORTING val = lx_middle.

      CATCH z2ui5_cx_ui5_util_error INTO lx.

        lv_nl = z2ui5_cl_ui5_util_context=>cv_char_util_newline.
        cl_abap_unit_assert=>assert_equals( exp = |middle layer{ lv_nl }root cause|
                                            act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_bound( lx->previous ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_no_duplicate_text.

    " a wrapper that only re-raises carries the same text as its cause -
    " it must appear once, not twice
    DATA lx_inner TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lx_outer TYPE REF TO z2ui5_cx_ui5_util_error.
    CREATE OBJECT lx_inner TYPE z2ui5_cx_ui5_util_error EXPORTING val = `same text`.

    CREATE OBJECT lx_outer TYPE z2ui5_cx_ui5_util_error EXPORTING val = `same text` previous = lx_inner.

    cl_abap_unit_assert=>assert_equals( exp = `same text`
                                        act = lx_outer->get_text( ) ).

  ENDMETHOD.

  METHOD test_text_full_chain.

    DATA lx_inner TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lx_outer TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA lv_text TYPE string.
    DATA temp3 TYPE xsdboolean.
    DATA temp4 TYPE xsdboolean.
    DATA temp5 TYPE xsdboolean.
    DATA temp6 TYPE xsdboolean.
    DATA temp7 TYPE xsdboolean.
    DATA temp8 TYPE xsdboolean.
    DATA temp9 TYPE xsdboolean.
    CREATE OBJECT lx_inner TYPE z2ui5_cx_ui5_util_error EXPORTING val = `root cause`.

    CREATE OBJECT lx_outer TYPE z2ui5_cx_ui5_util_error EXPORTING val = `outer problem` previous = lx_inner.


    lv_text = z2ui5_cx_ui5_util_error=>get_text_full( lx_outer ).

    " the message section (both messages), one detail block per chain entry,
    " the class name of every entry and the system context. The `--- error ---`
    " header is a contract with the frontend: app/webapp/core/ErrorView.js
    " lifts exactly that section into the error popup

    temp3 = boolc( lv_text CS `--- error ---` ).
    cl_abap_unit_assert=>assert_true( temp3 ).

    temp4 = boolc( lv_text CS `outer problem` ).
    cl_abap_unit_assert=>assert_true( temp4 ).

    temp5 = boolc( lv_text CS `root cause` ).
    cl_abap_unit_assert=>assert_true( temp5 ).

    temp6 = boolc( lv_text CS `exception chain` ).
    cl_abap_unit_assert=>assert_true( temp6 ).

    temp7 = boolc( lv_text CS `[1] Z2UI5_CX_UI5_UTIL_ERROR` ).
    cl_abap_unit_assert=>assert_true( temp7 ).

    temp8 = boolc( lv_text CS `[2] Z2UI5_CX_UI5_UTIL_ERROR` ).
    cl_abap_unit_assert=>assert_true( temp8 ).

    temp9 = boolc( lv_text CS `context` ).
    cl_abap_unit_assert=>assert_true( temp9 ).

  ENDMETHOD.

  METHOD test_text_full_any_cx.
        DATA lv_val TYPE i.
        DATA lx_root TYPE REF TO cx_root.
    DATA lv_text TYPE string.
    DATA temp10 TYPE xsdboolean.
    DATA temp11 TYPE xsdboolean.

    " the top-level catch sees whatever was raised - a plain SAP exception
    " must be rendered as fully as a framework one
    TRY.

        lv_val = 1 / 0 ##NEEDED.

      CATCH cx_root INTO lx_root.
    ENDTRY.


    lv_text = z2ui5_cx_ui5_util_error=>get_text_full( lx_root ).


    temp10 = boolc( lv_text CS `[1] CX_SY_ZERODIVIDE` ).
    cl_abap_unit_assert=>assert_true( temp10 ).

    temp11 = boolc( lv_text CS `exception chain` ).
    cl_abap_unit_assert=>assert_true( temp11 ).

  ENDMETHOD.

  METHOD test_text_full_unbound.

    " the renderer runs while an error is being handled - it must answer
    " something for every input instead of raising on its own
    DATA lx_unbound TYPE REF TO cx_root.

    cl_abap_unit_assert=>assert_equals( exp = `UNKNOWN_ERROR`
                                        act = z2ui5_cx_ui5_util_error=>get_text_full( lx_unbound ) ).

  ENDMETHOD.

  METHOD test_chain_bounded.

    " the chain walk is capped so a self-referencing `previous` cannot hang
    " the one routine that must always answer - and the reader is told that
    " the output was cut, instead of silently seeing a shortened chain
    DATA lx TYPE REF TO z2ui5_cx_ui5_util_error.
    DATA temp12 TYPE xsdboolean.
    CREATE OBJECT lx TYPE z2ui5_cx_ui5_util_error EXPORTING val = `level 0`.

    DO 30 TIMES.
      CREATE OBJECT lx TYPE z2ui5_cx_ui5_util_error EXPORTING val = |level { sy-index }| previous = lx.
    ENDDO.


    temp12 = boolc( z2ui5_cx_ui5_util_error=>get_text_full( lx ) CS `chain truncated` ).
    cl_abap_unit_assert=>assert_true(
      temp12 ).
    cl_abap_unit_assert=>assert_not_initial( lx->get_text( ) ).

  ENDMETHOD.
ENDCLASS.
