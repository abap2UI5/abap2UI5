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

    METHODS test_request_body      FOR TESTING RAISING cx_static_check.
    METHODS test_request_headers   FOR TESTING RAISING cx_static_check.
    METHODS test_request_azure     FOR TESTING RAISING cx_static_check.
    METHODS test_request_tokens    FOR TESTING RAISING cx_static_check.
    METHODS test_request_local_url FOR TESTING RAISING cx_static_check.
    METHODS test_no_model          FOR TESTING RAISING cx_static_check.
    METHODS test_parse_answer      FOR TESTING RAISING cx_static_check.
    METHODS test_parse_length      FOR TESTING RAISING cx_static_check.
    METHODS test_parse_error       FOR TESTING RAISING cx_static_check.
    METHODS test_parse_refusal     FOR TESTING RAISING cx_static_check.
    METHODS test_chat_through_stub FOR TESTING RAISING cx_static_check.

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

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_openai.
    DATA temp1 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA lo_json TYPE REF TO z2ui5_cl_ajson.
    CREATE OBJECT temp1 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `test-model` io_http = temp1.


    ls_request = lo_llm->build_request( system    = `Answer briefly.`
                                              t_message = conversation( ) ).


    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = `test-model`
                                        act = lo_json->get_string( `/model` ) ).
    " the system prompt is the first message - this API has no field for it
    cl_abap_unit_assert=>assert_equals( exp = 4
                                        act = lines( lo_json->members( `/messages` ) ) ).
    cl_abap_unit_assert=>assert_equals( exp = `system`
                                        act = lo_json->get_string( `/messages/1/role` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `Answer briefly.`
                                        act = lo_json->get_string( `/messages/1/content` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `assistant`
                                        act = lo_json->get_string( `/messages/3/role` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `What is abap2UI5?`
                                        act = lo_json->get_string( `/messages/4/content` ) ).
    " no limit and no temperature unless the call asks for them
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_json->exists( `/max_completion_tokens` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_json->exists( `/temperature` ) ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_cl_ui5_llm_openai=>cv_default_url
                                        act = ls_request-url ).

  ENDMETHOD.

  METHOD test_request_headers.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_openai.
    DATA temp2 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    CREATE OBJECT temp2 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `test-model` api_key = `test-key` io_http = temp2.


    ls_request = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Bearer test-key`
                                        act = header( is_request = ls_request
                                                      name       = `Authorization` ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `application/json*`
                                         act = header( is_request = ls_request
                                                       name       = `content-type` ) ).

  ENDMETHOD.

  METHOD test_request_azure.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_openai.
    DATA temp3 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    CREATE OBJECT temp3 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `my-deployment` api_key = `test-key` url = `https://example.openai.azure.com/openai/v1/chat/completions` auth_header = `api-key` io_http = temp3.


    ls_request = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `test-key`
                                        act = header( is_request = ls_request
                                                      name       = `api-key` ) ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = header( is_request = ls_request
                                                      name       = `Authorization` ) ).
    cl_abap_unit_assert=>assert_equals( exp = `https://example.openai.azure.com/openai/v1/chat/completions`
                                        act = ls_request-url ).

  ENDMETHOD.

  METHOD test_request_tokens.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_openai.
    DATA temp5 TYPE REF TO ltd_http.
    DATA temp3 TYPE z2ui5_if_ui5_llm=>ty_s_options.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    DATA lo_json TYPE REF TO z2ui5_cl_ajson.
    DATA temp1 TYPE REF TO ltd_http.
    DATA temp4 TYPE z2ui5_if_ui5_llm=>ty_s_options.
    CREATE OBJECT temp5 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `test-model` io_http = temp5.

    CLEAR temp3.
    temp3-max_tokens = 300.
    temp3-temperature = `0.7`.

    ls_request = lo_llm->build_request( t_message = conversation( )
                                              s_options = temp3 ).

    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = 300
                                        act = lo_json->get_integer( `/max_completion_tokens` ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"temperature":0.7*`
                                         act = ls_request-body ).

    " a server that only knows the older name

    CREATE OBJECT temp1 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `test-model` check_legacy_tokens = abap_true io_http = temp1.

    CLEAR temp4.
    temp4-max_tokens = 300.
    ls_request = lo_llm->build_request( t_message = conversation( )
                                        s_options = temp4 ).
    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = 300
                                        act = lo_json->get_integer( `/max_tokens` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_json->exists( `/max_completion_tokens` ) ).

  ENDMETHOD.

  METHOD test_request_local_url.

    " a local Ollama: no key, no destination, a URL of its own
    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_openai.
    DATA temp6 TYPE REF TO ltd_http.
    DATA ls_request TYPE z2ui5_if_ui5_llm_http=>ty_s_request.
    CREATE OBJECT temp6 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `test-model` url = `http://localhost:11434/v1/chat/completions` io_http = temp6.


    ls_request = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `http://localhost:11434/v1/chat/completions`
                                        act = ls_request-url ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = header( is_request = ls_request
                                                      name       = `Authorization` ) ).

  ENDMETHOD.

  METHOD test_no_model.

    DATA lo_llm TYPE REF TO z2ui5_cl_ui5_llm_openai.
    DATA temp7 TYPE REF TO ltd_http.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
    CREATE OBJECT temp7 TYPE ltd_http.
    CREATE OBJECT lo_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `` io_http = temp7.
    TRY.
        lo_llm->build_request( conversation( ) ).
        cl_abap_unit_assert=>fail( `a request without a model must be refused` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*model*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_parse_answer.

    " the body as a plain statement first: inside VALUE #( ) the 702
    " downport joins the operands into one line over 255 characters
    DATA lv_body TYPE string.
    DATA temp5 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    lv_body = `{"id":"chatcmpl-1","object":"chat.completion","model":"test-model",`
            && `"choices":[{"index":0,"message":{"role":"assistant","content":"abap2UI5 builds UI5 apps in ABAP."},`
            && `"finish_reason":"stop"}],"usage":{"prompt_tokens":25,"completion_tokens":8,"total_tokens":33}}`.

    CLEAR temp5.
    temp5-status = 200.
    temp5-body = lv_body.

    ls_result = z2ui5_cl_ui5_llm_openai=>parse_response( temp5 ).

    cl_abap_unit_assert=>assert_equals( exp = `abap2UI5 builds UI5 apps in ABAP.`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = `test-model`
                                        act = ls_result-model ).
    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-end_turn
                                        act = ls_result-stop_reason ).
    cl_abap_unit_assert=>assert_equals( exp = 25
                                        act = ls_result-s_usage-input_tokens ).
    cl_abap_unit_assert=>assert_equals( exp = 8
                                        act = ls_result-s_usage-output_tokens ).

  ENDMETHOD.

  METHOD test_parse_length.

    DATA temp6 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CLEAR temp6.
    temp6-status = 200.
    temp6-body = `{"model":"test-model","choices":[{"message":{"role":"assistant","content":"abap2UI5 is"},` && `"finish_reason":"length"}],"usage":{"prompt_tokens":5,"completion_tokens":2}}`.

    ls_result = z2ui5_cl_ui5_llm_openai=>parse_response( temp6 ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-max_tokens
                                        act = ls_result-stop_reason ).
    cl_abap_unit_assert=>assert_equals( exp = `abap2UI5 is`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_parse_refusal.
        DATA temp7 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.

    " content null, message.refusal set: a declined answer, not a token
    " limit
    TRY.

        CLEAR temp7.
        temp7-status = 200.
        temp7-body = `{"model":"test-model","choices":[{"message":{"role":"assistant","content":null,` && `"refusal":"I cannot help with that."},"finish_reason":"stop"}],` && `"usage":{"prompt_tokens":5,"completion_tokens":2}}`.
        z2ui5_cl_ui5_llm_openai=>parse_response( temp7 ).
        cl_abap_unit_assert=>fail( `a refusal must raise` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*declined*I cannot help with that.*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 200
                                            act = lx->http_status ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_parse_error.
        DATA temp8 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.
        DATA lx TYPE REF TO z2ui5_cx_ui5_llm.
        DATA temp9 TYPE z2ui5_if_ui5_llm_http=>ty_s_response.

    TRY.

        CLEAR temp8.
        temp8-status = 401.
        temp8-reason = `Unauthorized`.
        temp8-body = `{"error":{"message":"Incorrect API key provided","type":"invalid_request_error"}}`.
        z2ui5_cl_ui5_llm_openai=>parse_response( temp8 ).
        cl_abap_unit_assert=>fail( `an error status must raise` ).

      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*Incorrect API key provided*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 401
                                            act = lx->http_status ).
        cl_abap_unit_assert=>assert_equals( exp = abap_false
                                            act = lx->retryable ).
    ENDTRY.

    " Ollama sends the error as a plain string
    TRY.

        CLEAR temp9.
        temp9-status = 503.
        temp9-body = `{"error":"model is loading"}`.
        z2ui5_cl_ui5_llm_openai=>parse_response( temp9 ).
        cl_abap_unit_assert=>fail( `an error status must raise` ).
      CATCH z2ui5_cx_ui5_llm INTO lx.
        cl_abap_unit_assert=>assert_char_cp( exp = `*model is loading*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = abap_true
                                            act = lx->retryable ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_chat_through_stub.

    DATA li_llm TYPE REF TO z2ui5_if_ui5_llm.

    DATA lo_http TYPE REF TO ltd_http.
    DATA ls_result TYPE z2ui5_if_ui5_llm=>ty_s_result.
    CREATE OBJECT lo_http TYPE ltd_http.
    CLEAR lo_http->ms_response.
    lo_http->ms_response-status = 200.
    lo_http->ms_response-body = `{"model":"test-model","choices":[{"message":{"role":"assistant","content":"42"},`
&& `"finish_reason":"stop"}],"usage":{"prompt_tokens":3,"completion_tokens":1}}`.
    CREATE OBJECT li_llm TYPE z2ui5_cl_ui5_llm_openai EXPORTING model = `test-model` io_http = lo_http.


    ls_result = li_llm->chat( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_http->mv_calls ).

  ENDMETHOD.

ENDCLASS.
