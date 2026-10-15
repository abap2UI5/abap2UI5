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

    result = VALUE #( ( contains = `invoice` answer = `Invoices are in the billing app.` )
                      ( contains = `order`   answer = `Orders are in the sales app.` )
                      ( contains = ``        answer = `an empty rule never matches` ) ).

  ENDMETHOD.

  METHOD ask.

    result = VALUE #( ( role = z2ui5_if_ui5_llm=>cs_role-user content = question ) ).

  ENDMETHOD.

  METHOD test_rule_matches.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( t_rule = rules( ) ).

    DATA(ls_result) = li_llm->chat( ask( `Where do I find my INVOICE?` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Invoices are in the billing app.`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_local=>cv_model
                                        act = ls_result-model ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-end_turn
                                        act = ls_result-stop_reason ).

  ENDMETHOD.

  METHOD test_rule_order.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( t_rule = rules( ) ).

    " both rules match - the first one in the table answers
    DATA(ls_result) = li_llm->chat( ask( `the order of an invoice` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Invoices are in the billing app.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_last_user_asks.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( t_rule = rules( ) ).

    DATA(ls_result) = li_llm->chat( VALUE #(
        ( role = z2ui5_if_ui5_llm=>cs_role-user      content = `about an invoice` )
        ( role = z2ui5_if_ui5_llm=>cs_role-assistant content = `Invoices are in the billing app.` )
        ( role = z2ui5_if_ui5_llm=>cs_role-user      content = `and my order?` ) ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Orders are in the sales app.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_fallback.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( t_rule   = rules( )
                                         fallback = `I do not know.` ).

    DATA(ls_result) = li_llm->chat( ask( `What is the weather?` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `I do not know.`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_echo.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( ).

    DATA(ls_result) = li_llm->chat( ask( `ping` ) ).

    cl_abap_unit_assert=>assert_equals( exp = `ping`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_usage.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( t_rule = rules( ) ).

    DATA(ls_result) = li_llm->chat( system    = `Be brief.`
                                    t_message = ask( `my invoice` ) ).

    " words of the system prompt and the conversation, words of the answer
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = ls_result-s_usage-input_tokens ).
    cl_abap_unit_assert=>assert_equals( exp = 6
                                        act = ls_result-s_usage-output_tokens ).

  ENDMETHOD.

  METHOD test_max_tokens.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( t_rule = rules( ) ).

    DATA(ls_result) = li_llm->chat( t_message = ask( `my invoice` )
                                    s_options = VALUE #( max_tokens = 2 ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Invoices are`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-max_tokens
                                        act = ls_result-stop_reason ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = ls_result-s_usage-output_tokens ).

  ENDMETHOD.

  METHOD test_no_user_message.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.
    li_llm = NEW z2ui5_cl_ui5_llm_local( ).

    TRY.
        li_llm->chat( VALUE #( ) ).
        cl_abap_unit_assert=>fail( `a call without a user message must raise` ).
      CATCH z2ui5_cx_ui5_llm INTO DATA(lx).
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
