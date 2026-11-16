CLASS ltd_http DEFINITION FINAL FOR TESTING.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_llm_http.

    DATA ms_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA ms_response TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
    DATA mv_calls TYPE i.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS ltd_http IMPLEMENTATION.

  METHOD z2ui5_if_ui5_llm_http~post.

    mv_calls   = mv_calls + 1.
    ms_request = is_request.
    result     = ms_response.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_test DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.

    METHODS test_request_body       FOR TESTING RAISING cx_static_check.
    METHODS test_request_headers    FOR TESTING RAISING cx_static_check.
    METHODS test_request_escaping   FOR TESTING RAISING cx_static_check.
    METHODS test_request_options    FOR TESTING RAISING cx_static_check.
    METHODS test_request_destination FOR TESTING RAISING cx_static_check.
    METHODS test_no_model           FOR TESTING RAISING cx_static_check.
    METHODS test_bad_temperature    FOR TESTING RAISING cx_static_check.
    METHODS test_parse_answer       FOR TESTING RAISING cx_static_check.
    METHODS test_parse_error        FOR TESTING RAISING cx_static_check.
    METHODS test_parse_no_text      FOR TESTING RAISING cx_static_check.
    METHODS test_chat_through_stub  FOR TESTING RAISING cx_static_check.

    METHODS conversation
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_llm=>ty_t_message.

    METHODS header
      IMPORTING
        is_request    TYPE z2ui5_if_ui5_llm_http=>ty_s_request
        name          TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD conversation.

    DATA temp1 TYPE z2ui5_if_ui5_llm=>ty_t_message.
    DATA temp2 LIKE LINE OF temp1.
    CLEAR temp1.

    temp2-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp2-content = `Hello`.
    INSERT temp2 INTO TABLE temp1.
    temp2-role = z2ui5_if_ui5_llm=>cs_role-assistant.
    temp2-content = `Hi, how can I help?`.
    INSERT temp2 INTO TABLE temp1.
    temp2-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp2-content = `What is abap2UI5?`.
    INSERT temp2 INTO TABLE temp1.
    result = temp1.

  ENDMETHOD.

  METHOD header.

    DATA ls_header LIKE LINE OF is_request-t_header.
    LOOP AT is_request-t_header INTO ls_header.
      IF ls_header-name = name.
        result = ls_header-value.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD test_request_body.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp1 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA lo_json TYPE REF TO z2ui5_cl_ajson.
    CREATE OBJECT temp1 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` api_key = `test-key` io_http = temp1.


    ls_request = lo_llm->build_request( system    = `Answer briefly.`
                                              t_message = conversation( ) ).


    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = `test-model`
                                        act = lo_json->get_string( `/model` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_claude=>cv_default_max_tokens
                                        act = lo_json->get_integer( `/max_tokens` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Answer briefly.`
                                        act = lo_json->get_string( `/system` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 3
                                        act = lines( lo_json->members( `/messages` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `assistant`
                                        act = lo_json->get_string( `/messages/2/role` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `What is abap2UI5?`
                                        act = lo_json->get_string( `/messages/3/content` ) ).
    " the Messages API has no system role, and no temperature unless asked
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_json->exists( `/temperature` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_claude=>cv_default_url
                                        act = ls_request-url ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_claude=>cv_default_timeout
                                        act = ls_request-timeout ).

  ENDMETHOD.

  METHOD test_request_headers.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp2 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA temp1 TYPE REF TO ltd_http.
    CREATE OBJECT temp2 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` api_key = `test-key` io_http = temp2.


    ls_request = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `test-key`
                                        act = header( is_request = ls_request
                                                      name       = `x-api-key` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_claude=>cv_api_version
                                        act = header( is_request = ls_request
                                                      name       = `anthropic-version` ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `application/json*`
                                         act = header( is_request = ls_request
                                                       name       = `content-type` ) ).

    " without a key no key header - the destination or a gateway adds it

    CREATE OBJECT temp1 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` io_http = temp1.
    ls_request = lo_llm->build_request( conversation( ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = header( is_request = ls_request
                                                      name       = `x-api-key` ) ).

  ENDMETHOD.

  METHOD test_request_escaping.

    DATA lv_text TYPE string.
    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp5 TYPE REF TO ltd_http.
    DATA temp3 TYPE z2ui5_if_ui5_llm=>ty_t_message.
    DATA temp4 LIKE LINE OF temp3.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA lo_json TYPE REF TO z2ui5_cl_ajson.
    lv_text = |say "hi"{ z2ui5_cl_ui5_util_context=>cv_char_util_newline }and \\ bye|.


    CREATE OBJECT temp5 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` io_http = temp5.


    CLEAR temp3.

    temp4-role = z2ui5_if_ui5_llm=>cs_role-user.
    temp4-content = lv_text.
    INSERT temp4 INTO TABLE temp3.

    ls_request = lo_llm->build_request(
        temp3 ).

    cl_abap_unit_assert=>assert_char_cp( exp = `*say \"hi\"\nand \\ bye*`
                                         act = ls_request-body ).

    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = lv_text
                                        act = lo_json->get_string( `/messages/1/content` ) ).

  ENDMETHOD.

  METHOD test_request_options.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp6 TYPE REF TO ltd_http.
    DATA temp5 TYPE z2ui5_if_ui5_llm=>ty_s_options.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA lo_json TYPE REF TO z2ui5_cl_ajson.
    CREATE OBJECT temp6 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` io_http = temp6.


    CLEAR temp5.
    temp5-model = `other-model`.
    temp5-max_tokens = 200.
    temp5-temperature = `0.2`.

    ls_request = lo_llm->build_request( t_message = conversation( )
                                              s_options = temp5 ).


    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = `other-model`
                                        act = lo_json->get_string( `/model` ) ).
    cl_abap_unit_assert=>assert_equals( exp = 200
                                        act = lo_json->get_integer( `/max_tokens` ) ).
    " a JSON number, not a string
    cl_abap_unit_assert=>assert_char_cp( exp = `*"temperature":0.2*`
                                         act = ls_request-body ).

  ENDMETHOD.

  METHOD test_request_destination.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp7 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    CREATE OBJECT temp7 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` destination = `Z_LLM` timeout = 30 io_http = temp7.


    ls_request = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Z_LLM`
                                        act = ls_request-destination ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_claude=>cv_default_path
                                        act = ls_request-url ).
    cl_abap_unit_assert=>assert_equals( exp = 30
                                        act = ls_request-timeout ).

  ENDMETHOD.

  METHOD test_no_model.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp8 TYPE REF TO ltd_http.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
    CREATE OBJECT temp8 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `` io_http = temp8.
    TRY.
        lo_llm->build_request( conversation( ) ).
        cl_abap_unit_assert=>fail( `a request without a model must be refused` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*model*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = abap_false
                                            act = lx->retryable ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_bad_temperature.

    DATA lt_bad TYPE string_table.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_claude.
    DATA temp9 TYPE REF TO ltd_http.
    DATA temp6 TYPE string_table.
    DATA lv_bad LIKE LINE OF lt_bad.
          DATA temp8 TYPE z2ui5_if_ui5_llm=>ty_s_options.
          DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
    CREATE OBJECT temp9 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` io_http = temp9.
    " `.7` and `1.` passed the character check and went out as invalid JSON

    CLEAR temp6.
    INSERT `1.2.3` INTO TABLE temp6.
    INSERT `.7` INTO TABLE temp6.
    INSERT `1.` INTO TABLE temp6.
    INSERT `.` INTO TABLE temp6.
    lt_bad = temp6.

    LOOP AT lt_bad INTO lv_bad.
      TRY.

          CLEAR temp8.
          temp8-temperature = lv_bad.
          lo_llm->build_request( t_message = conversation( )
                                 s_options = temp8 ).
          cl_abap_unit_assert=>fail( |the temperature { lv_bad } must be refused| ).

        CATCH z2ui5_cx_ui5_llm INTO lx.
          cl_abap_unit_assert=>assert_char_cp( exp = `*temperature*`
                                               act = lx->get_text( ) ).
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

  METHOD test_parse_answer.

    " a thinking block first, which carries no text - the answer is the
    " first block of type text
    " the body as a plain statement first: inside VALUE #( ) the 702
    " downport joins the operands into one line over 255 characters
    DATA lv_body TYPE string.
    DATA temp9 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    lv_body = `{"id":"msg_1","type":"message","role":"assistant","model":"test-model",`
            && `"content":[{"type":"thinking","thinking":"","signature":"x"},`
            && `{"type":"text","text":"abap2UI5 builds UI5 apps in ABAP."}],`
            && `"stop_reason":"end_turn","usage":{"input_tokens":21,"output_tokens":9}}`.

    CLEAR temp9.
    temp9-status = 200.
    temp9-body = lv_body.

    ls_result = z2ui5_cl_ui5_llm_claude=>parse_response( temp9 ).

    cl_abap_unit_assert=>assert_equals( exp = `abap2UI5 builds UI5 apps in ABAP.`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = `test-model`
                                        act = ls_result-model ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-end_turn
                                        act = ls_result-stop_reason ).
    cl_abap_unit_assert=>assert_equals( exp = 21
                                        act = ls_result-s_usage-input_tokens ).
    cl_abap_unit_assert=>assert_equals( exp = 9
                                        act = ls_result-s_usage-output_tokens ).

  ENDMETHOD.

  METHOD test_parse_error.
        DATA temp10 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
        DATA temp11 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.

    TRY.

        CLEAR temp10.
        temp10-status = 429.
        temp10-reason = `Too Many Requests`.
        temp10-body = `{"type":"error","error":{"type":"rate_limit_error","message":"Number of requests exceeded"}}`.
        z2ui5_cl_ui5_llm_claude=>parse_response( temp10 ).
        cl_abap_unit_assert=>fail( `an error status must raise` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*Number of requests exceeded*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 429
                                            act = lx->http_status ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true
                                            act = lx->retryable ).
    ENDTRY.

    TRY.

        CLEAR temp11.
        temp11-status = 401.
        temp11-body = `{"type":"error","error":{"type":"authentication_error","message":"invalid x-api-key"}}`.
        z2ui5_cl_ui5_llm_claude=>parse_response( temp11 ).
        cl_abap_unit_assert=>fail( `an error status must raise` ).
      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_equals( exp = abap_false
                                            act = lx->retryable ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_parse_no_text.
        DATA temp12 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
        DATA temp13 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.

    TRY.

        CLEAR temp12.
        temp12-status = 200.
        temp12-body = `{"model":"test-model","content":[],"stop_reason":"max_tokens",` && `"usage":{"input_tokens":5,"output_tokens":0}}`.
        z2ui5_cl_ui5_llm_claude=>parse_response( temp12 ).
        cl_abap_unit_assert=>fail( `an answer without text must raise` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*max_tokens*`
                                             act = lx->get_text( ) ).
    ENDTRY.

    TRY.

        CLEAR temp13.
        temp13-status = 200.
        temp13-body = `{"model":"test-model","content":[],"stop_reason":"refusal"}`.
        z2ui5_cl_ui5_llm_claude=>parse_response( temp13 ).
        cl_abap_unit_assert=>fail( `a refusal without text must raise` ).
      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*declined*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chat_through_stub.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.

    DATA lo_http TYPE REF TO ltd_http.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT lo_http TYPE ltd_http.
    CLEAR lo_http->ms_response.
    lo_http->ms_response-status = 200.
    lo_http->ms_response-body = `{"model":"test-model","content":[{"type":"text","text":"42"}],`
&& `"stop_reason":"end_turn","usage":{"input_tokens":3,"output_tokens":1}}`.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_claude EXPORTING model = `test-model` api_key = `test-key` io_http = lo_http.


    ls_result = li_llm->chat( system    = `Be brief.`
                                    t_message = conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_http->mv_calls ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"system":"Be brief."*`
                                         act = lo_http->ms_request-body ).

  ENDMETHOD.

ENDCLASS.
