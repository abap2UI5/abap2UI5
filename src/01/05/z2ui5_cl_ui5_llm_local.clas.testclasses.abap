CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_rule_matches     FOR TESTING RAISING cx_static_check.
    METHODS test_rule_order       FOR TESTING RAISING cx_static_check.
    METHODS test_last_user_asks   FOR TESTING RAISING cx_static_check.
    METHODS test_fallback         FOR TESTING RAISING cx_static_check.
    METHODS test_echo             FOR TESTING RAISING cx_static_check.
    METHODS test_usage            FOR TESTING RAISING cx_static_check.
    METHODS test_max_tokens       FOR TESTING RAISING cx_static_check.
    METHODS test_no_user_message  FOR TESTING RAISING cx_static_check.
    METHODS test_count_words      FOR TESTING RAISING cx_static_check.

    METHODS rules
      RETURNING
        VALUE(result) TYPE z2ui5_cl_ui5_llm=>ty_t_rule.

    METHODS ask
      IMPORTING
        question      TYPE string
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_llm=>ty_t_message.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD rules.

    DATA temp1 TYPE z2ui5_cl_ui5_llm=>ty_t_rule.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-contains = `invoice`.
    temp2-answer = `Invoices are in the billing app.`.
    INSERT temp2 INTO TABLE temp1.
    temp2-contains = `order`.
    temp2-answer = `Orders are in the sales app.`.
    INSERT temp2 INTO TABLE temp1.
    temp2-contains = ``.
    temp2-answer = `an empty rule never matches`.
    INSERT temp2 INTO TABLE temp1.
    result = temp1.

  ENDMETHOD.

  METHOD ask.

    DATA temp3 TYPE z2ui5_if_ui5_llm=>ty_t_message.
    DATA temp4 LIKE LINE OF temp3.
    CLEAR temp3.

    temp4-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp4-content = question.
    INSERT temp4 INTO TABLE temp3.
    result = temp3.

  ENDMETHOD.

  METHOD test_rule_matches.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local EXPORTING t_rule = rules( ).


    ls_result = li_llm->chat( ask( `Where do I find my INVOICE?` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Invoices are in the billing app.`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_local=>cv_model
                                        act = ls_result-model ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-end_turn
                                        act = ls_result-stop_reason ).

  ENDMETHOD.

  METHOD test_rule_order.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local EXPORTING t_rule = rules( ).

    " both rules match - the first one in the table answers

    ls_result = li_llm->chat( ask( `the order of an invoice` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Invoices are in the billing app.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_last_user_asks.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA temp5 TYPE z2ui5_if_ui5_llm=>ty_t_message.
    DATA temp6 LIKE LINE OF temp5.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local EXPORTING t_rule = rules( ).


    CLEAR temp5.

    temp6-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp6-content = `about an invoice`.
    INSERT temp6 INTO TABLE temp5.
    temp6-role = z2ui5_if_ui5_llm=>cs_role-assistant.
    temp6-content = `Invoices are in the billing app.`.
    INSERT temp6 INTO TABLE temp5.
    temp6-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp6-content = `and my order?`.
    INSERT temp6 INTO TABLE temp5.

    ls_result = li_llm->chat( temp5 ).

    cl_abap_unit_assert=>assert_equals( exp = `Orders are in the sales app.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_fallback.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local EXPORTING t_rule = rules( ) fallback = `I do not know.`.


    ls_result = li_llm->chat( ask( `What is the weather?` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `I do not know.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_echo.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local.


    ls_result = li_llm->chat( ask( `ping` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `ping`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_usage.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local EXPORTING t_rule = rules( ).


    ls_result = li_llm->chat( system    = `Be brief.`
                                    t_message = ask( `my invoice` ) ).

    " words of the system prompt and the conversation, words of the answer
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_result-s_usage-input_tokens ).
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = ls_result-s_usage-output_tokens ).

  ENDMETHOD.

  METHOD test_max_tokens.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    DATA temp7 TYPE z2ui5_if_ui5_llm=>ty_s_options.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local EXPORTING t_rule = rules( ).


    CLEAR temp7.
    temp7-max_tokens = 2.

    ls_result = li_llm->chat( t_message = ask( `my invoice` )
                                    s_options = temp7 ).

    cl_abap_unit_assert=>assert_equals( exp = `Invoices are`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-max_tokens
                                        act = ls_result-stop_reason ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_result-s_usage-output_tokens ).

  ENDMETHOD.

  METHOD test_no_user_message.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
        DATA temp8 TYPE z2ui5_if_ui5_llm=>ty_t_message.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_local.

    TRY.

        CLEAR temp8.
        li_llm->chat( temp8 ).
        cl_abap_unit_assert=>fail( `a call without a user message must raise` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*user message*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = abap_false
                                            act = lx->retryable ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_count_words.

    cl_abap_unit_assert=>assert_equals( exp = 0
                                        act = z2ui5_cl_ui5_llm_local=>count_words( `` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = z2ui5_cl_ui5_llm_local=>count_words(
                                                |  one{ z2ui5_cl_ui5_util_context=>cv_char_util_newline }two   three | ) ).

  ENDMETHOD.

ENDCLASS.
