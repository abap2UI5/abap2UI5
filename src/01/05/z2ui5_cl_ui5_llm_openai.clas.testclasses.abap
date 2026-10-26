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

    result = VALUE #( ( role = z2ui5_if_ui5_llm=>cs_role-user      content = `Hello` )
                      ( role = z2ui5_if_ui5_llm=>cs_role-assistant content = `Hi, how can I help?` )
                      ( role = z2ui5_if_ui5_llm=>cs_role-user      content = `What is abap2UI5?` ) ).

  ENDMETHOD.

  METHOD header.

    LOOP AT is_request-t_header INTO DATA(ls_header).
      IF ls_header-name = name.
        result = ls_header-value.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD test_request_body.

    DATA(lo_llm) = NEW z2ui5_cl_ui5_llm_openai( model   = `test-model`
                                                io_http = NEW ltd_http( ) ).

    DATA(ls_request) = lo_llm->build_request( system    = `Answer briefly.`
                                              t_message = conversation( ) ).

    DATA(lo_json) = z2ui5_cl_ajson=>parse( ls_request-body ).
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

    DATA(lo_llm) = NEW z2ui5_cl_ui5_llm_openai( model   = `test-model`
                                                api_key = `test-key`
                                                io_http = NEW ltd_http( ) ).

    DATA(ls_request) = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `Bearer test-key`
                                        act = header( is_request = ls_request
                                                      name       = `Authorization` ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `application/json*`
                                         act = header( is_request = ls_request
                                                       name       = `content-type` ) ).

  ENDMETHOD.

  METHOD test_request_azure.

    DATA(lo_llm) = NEW z2ui5_cl_ui5_llm_openai(
        model       = `my-deployment`
        api_key     = `test-key`
        url         = `https://example.openai.azure.com/openai/v1/chat/completions`
        auth_header = `api-key`
        io_http     = NEW ltd_http( ) ).

    DATA(ls_request) = lo_llm->build_request( conversation( ) ).

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

    DATA(lo_llm) = NEW z2ui5_cl_ui5_llm_openai( model   = `test-model`
                                                io_http = NEW ltd_http( ) ).
    DATA(ls_request) = lo_llm->build_request( t_message = conversation( )
                                              s_options = VALUE #( max_tokens  = 300
                                                                   temperature = `0.7` ) ).
    DATA(lo_json) = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = 300
                                        act = lo_json->get_integer( `/max_completion_tokens` ) ).
    cl_abap_unit_assert=>assert_char_cp( exp = `*"temperature":0.7*`
                                         act = ls_request-body ).

    " a server that only knows the older name
    lo_llm = NEW z2ui5_cl_ui5_llm_openai( model               = `test-model`
                                          check_legacy_tokens = abap_true
                                          io_http             = NEW ltd_http( ) ).
    ls_request = lo_llm->build_request( t_message = conversation( )
                                        s_options = VALUE #( max_tokens = 300 ) ).
    lo_json = z2ui5_cl_ajson=>parse( ls_request-body ).
    cl_abap_unit_assert=>assert_equals( exp = 300
                                        act = lo_json->get_integer( `/max_tokens` ) ).
    cl_abap_unit_assert=>assert_equals( exp = abap_false
                                        act = lo_json->exists( `/max_completion_tokens` ) ).

  ENDMETHOD.

  METHOD test_request_local_url.

    " a local Ollama: no key, no destination, a URL of its own
    DATA(lo_llm) = NEW z2ui5_cl_ui5_llm_openai( model   = `test-model`
                                                url     = `http://localhost:11434/v1/chat/completions`
                                                io_http = NEW ltd_http( ) ).

    DATA(ls_request) = lo_llm->build_request( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `http://localhost:11434/v1/chat/completions`
                                        act = ls_request-url ).
    cl_abap_unit_assert=>assert_equals( exp = ``
                                        act = header( is_request = ls_request
                                                      name       = `Authorization` ) ).

  ENDMETHOD.

  METHOD test_no_model.

    DATA(lo_llm) = NEW z2ui5_cl_ui5_llm_openai( model   = ``
                                                io_http = NEW ltd_http( ) ).
    TRY.
        lo_llm->build_request( conversation( ) ).
        cl_abap_unit_assert=>fail( `a request without a model must be refused` ).
      CATCH z2ui5_cx_ui5_llm INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp( exp = `*model*`
                                             act = lx->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_parse_answer.

    " the body as a plain statement first: inside VALUE #( ) the 702
    " downport joins the operands into one line over 255 characters
    DATA lv_body TYPE string.
    lv_body = `{"id":"chatcmpl-1","object":"chat.completion","model":"test-model",`
            && `"choices":[{"index":0,"message":{"role":"assistant","content":"abap2UI5 builds UI5 apps in ABAP."},`
            && `"finish_reason":"stop"}],"usage":{"prompt_tokens":25,"completion_tokens":8,"total_tokens":33}}`.
    DATA(ls_result) = z2ui5_cl_ui5_llm_openai=>parse_response( VALUE #( status = 200
                                                                        body   = lv_body ) ).

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

    DATA(ls_result) = z2ui5_cl_ui5_llm_openai=>parse_response( VALUE #(
        status = 200
        body   = `{"model":"test-model","choices":[{"message":{"role":"assistant","content":"abap2UI5 is"},`
              && `"finish_reason":"length"}],"usage":{"prompt_tokens":5,"completion_tokens":2}}` ) ).

    cl_abap_unit_assert=>assert_equals( exp = z2ui5_if_ui5_llm=>cs_stop-max_tokens
                                        act = ls_result-stop_reason ).
    cl_abap_unit_assert=>assert_equals( exp = `abap2UI5 is`
                                        act = ls_result-text ).

  ENDMETHOD.

  METHOD test_parse_refusal.

    " content null, message.refusal set: a declined answer, not a token
    " limit
    TRY.
        z2ui5_cl_ui5_llm_openai=>parse_response( VALUE #(
            status = 200
            body   = `{"model":"test-model","choices":[{"message":{"role":"assistant","content":null,`
                  && `"refusal":"I cannot help with that."},"finish_reason":"stop"}],`
                  && `"usage":{"prompt_tokens":5,"completion_tokens":2}}` ) ).
        cl_abap_unit_assert=>fail( `a refusal must raise` ).
      CATCH z2ui5_cx_ui5_llm INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp( exp = `*declined*I cannot help with that.*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 200
                                            act = lx->http_status ).
    ENDTRY.

  ENDMETHOD.

  METHOD test_parse_error.

    TRY.
        z2ui5_cl_ui5_llm_openai=>parse_response( VALUE #(
            status = 401
            reason = `Unauthorized`
            body   = `{"error":{"message":"Incorrect API key provided","type":"invalid_request_error"}}` ) ).
        cl_abap_unit_assert=>fail( `an error status must raise` ).
      CATCH z2ui5_cx_ui5_llm INTO DATA(lx).
        cl_abap_unit_assert=>assert_char_cp( exp = `*Incorrect API key provided*`
                                             act = lx->get_text( ) ).
        cl_abap_unit_assert=>assert_equals( exp = 401
                                            act = lx->http_status ).
        cl_abap_unit_assert=>assert_equals( exp = abap_false
                                            act = lx->retryable ).
    ENDTRY.

    " Ollama sends the error as a plain string
    TRY.
        z2ui5_cl_ui5_llm_openai=>parse_response( VALUE #(
            status = 503
            body   = `{"error":"model is loading"}` ) ).
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

    DATA(lo_http) = NEW ltd_http( ).
    lo_http->ms_response = VALUE #(
        status = 200
        body   = `{"model":"test-model","choices":[{"message":{"role":"assistant","content":"42"},`
              && `"finish_reason":"stop"}],"usage":{"prompt_tokens":3,"completion_tokens":1}}` ).
    li_llm = NEW z2ui5_cl_ui5_llm_openai( model   = `test-model`
                                          io_http = lo_http ).

    DATA(ls_result) = li_llm->chat( conversation( ) ).

    cl_abap_unit_assert=>assert_equals( exp = `42`
                                        act = ls_result-text ).
    cl_abap_unit_assert=>assert_equals( exp = 1
                                        act = lo_http->mv_calls ).

  ENDMETHOD.

ENDCLASS.
