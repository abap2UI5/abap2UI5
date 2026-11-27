"! <p class="shorttext synchronized">abap2UI5 - language model transport</p>
"! The shipped z2ui5_if_ui5_llm_http: one POST through
"! z2ui5_cl_ui5_util_http=&gt;client_request( ), where the framework decides
"! between CL_HTTP_CLIENT (Standard - an SM59 destination or a URL) and
"! CL_WEB_HTTP_CLIENT_MANAGER (ABAP Cloud - a URL, a communication
"! arrangement or a BTP destination), both named dynamically. Nothing about
"! the platform is decided here, and nothing about a provider either - beyond
"! the two steps every HTTP provider takes alike: check_call before the body
"! is written, parse_answer on what came back.
CLASS z2ui5_cl_ui5_llm_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_llm_http.

    "! The checks of a chat call before its body is written: a model, at
    "! least one message and none without content or with a role other than
    "! cs_role-user / cs_role-assistant, and a temperature that is a JSON
    "! number. iv_api names the endpoint in the texts.
    CLASS-METHODS check_call
      IMPORTING
        iv_model       TYPE string
        it_message     TYPE z2ui5_if_ui5_llm=>ty_t_message
        iv_temperature TYPE string
        iv_api         TYPE string
      RAISING
        z2ui5_cx_ui5_llm.

    "! The answer of an HTTP provider as JSON, or the exception it stands
    "! for: a status other than 200 raises with the message of the error
    "! object (/error/message, or /error as a string - Ollama), retryable
    "! for 408, 429 and 5xx; a 200 that is no JSON raises as well.
    CLASS-METHODS parse_answer
      IMPORTING
        is_response   TYPE z2ui5_if_ui5_llm_http=>ty_s_response
        iv_api        TYPE string
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_if_ajson
      RAISING
        z2ui5_cx_ui5_llm.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_ui5_llm_http IMPLEMENTATION.

  METHOD check_call.

    IF iv_model IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = |no model is configured - { iv_api } needs a model id|.
    ENDIF.
    IF lines( it_message ) = 0.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = `a chat call needs at least one message`.
    ENDIF.
    LOOP AT it_message TRANSPORTING NO FIELDS WHERE content IS INITIAL. "#EC CI_SORTSEQ
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = |message { sy-tabix } has no content - { iv_api } refuses an empty message|.
    ENDLOOP.
    " The role goes out as it stands, and an app that binds its conversation
    " (to show it in a list) lets the browser write it: a row with the role
    " system is an instruction over the app's own system prompt on every
    " OpenAI-compatible endpoint. The interface allows user and assistant;
    " the system prompt is the parameter system. The value is not echoed -
    " it may come from the request.
    LOOP AT it_message TRANSPORTING NO FIELDS
         WHERE role <> z2ui5_if_ui5_llm=>cs_role-user
           AND role <> z2ui5_if_ui5_llm=>cs_role-assistant. "#EC CI_SORTSEQ
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = |message { sy-tabix } has a role other than user or assistant - the system prompt is the parameter system|.
    ENDLOOP.

    IF iv_temperature IS INITIAL.
      RETURN.
    ENDIF.
    " JSON wants a digit on both sides of the point - `.7` and `1.` are no
    " number there - and no leading zero in front of another digit: `01`
    " and `00.5` are no number either
    IF iv_temperature CN `0123456789.`
        OR count( val = iv_temperature
                  sub = `.` ) > 1
        OR iv_temperature CP `.*` OR iv_temperature CP `*.`
        OR ( strlen( iv_temperature ) > 1
             AND substring( val = iv_temperature
                            len = 1 ) = `0`
             AND substring( val = iv_temperature
                            off = 1
                            len = 1 ) <> `.` ).
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = |the temperature { iv_temperature } is no number|.
    ENDIF.

  ENDMETHOD.

  METHOD parse_answer.

    DATA lv_message TYPE string.

    TRY.
        result = z2ui5_cl_ajson=>parse( is_response-body ).
      CATCH cx_root.
        CLEAR result.
    ENDTRY.

    IF is_response-status <> 200.
      IF result IS BOUND.
        " {"error":{"message":...}} - Ollama: {"error":"..."}
        lv_message = result->get_string( `/error/message` ).
        IF lv_message IS INITIAL.
          lv_message = result->get_string( `/error` ).
        ENDIF.
      ENDIF.
      IF lv_message IS INITIAL.
        lv_message = z2ui5_cl_ui5_util_context=>c_truncate( val = is_response-body
                                                           max  = 200 ).
      ENDIF.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = |{ iv_api } answered HTTP { is_response-status } { is_response-reason } - { lv_message }|
          http_status = is_response-status
          retryable   = xsdbool( is_response-status = 408 OR is_response-status = 429 OR is_response-status >= 500 ).
    ENDIF.

    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = |{ iv_api } answered with no JSON|
          http_status = is_response-status.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_llm_http~post.

    DATA ls_req TYPE z2ui5_cl_ui5_util_http=>ty_s_client_req.
    DATA ls_res TYPE z2ui5_cl_ui5_util_http=>ty_s_http_res.

    ls_req-method      = `POST`.
    ls_req-url         = is_request-url.
    ls_req-destination = is_request-destination.
    ls_req-body        = is_request-body.
    ls_req-timeout     = is_request-timeout.
    LOOP AT is_request-t_header INTO DATA(ls_header).
      INSERT VALUE #( n = ls_header-name
                      v = ls_header-value ) INTO TABLE ls_req-t_header.
    ENDLOOP.

    TRY.
        ls_res = z2ui5_cl_ui5_util_http=>client_request( ls_req ).
      CATCH cx_root INTO DATA(lx).
        " no answer at all: the destination does not exist, the host cannot
        " be reached, the TLS handshake failed, the timeout ran out - the
        " cause stays in previous, the text is for the person who fixes the
        " setup. Only a failed SEND or RECEIVE is worth another try
        " (HTTP_COMMUNICATION_ERROR, somewhere in the chain): a destination
        " that is not there or not allowed, a client that could not be
        " created, a stack without the client class - "a missing
        " configuration never does" (z2ui5_cx_ui5_llm), and an app looping
        " on retryable retried a call that could never succeed
        DATA(lv_retryable) = abap_false.
        DATA(lx_walk) = lx.
        WHILE lx_walk IS BOUND.
          IF lx_walk->get_text( ) CS `HTTP_COMMUNICATION_ERROR`.
            lv_retryable = abap_true.
            EXIT.
          ENDIF.
          lx_walk = lx_walk->previous.
        ENDWHILE.
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
          EXPORTING
            text      = `the language model endpoint could not be reached - check the destination, the URL, the TLS trust and the proxy`
            retryable = lv_retryable
            previous  = lx.
    ENDTRY.

    result-status = ls_res-status_code.
    result-reason = ls_res-status_reason.
    result-body   = ls_res-body.

  ENDMETHOD.

ENDCLASS.
