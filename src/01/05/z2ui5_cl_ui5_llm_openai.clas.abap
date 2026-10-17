"! <p class="shorttext synchronized">abap2UI5 - OpenAI-compatible provider</p>
"! z2ui5_if_ui5_llm for an OpenAI-compatible Chat Completions endpoint -
"! OpenAI itself, or any of the servers and gateways that speak the same
"! wire format: Azure OpenAI, a local Ollama (http://localhost:11434/v1/chat/completions),
"! LM Studio, vLLM, LiteLLM, a SAP AI Core proxy:
"!
"!   POST {url}            (default https://api.openai.com/v1/chat/completions)
"!   Authorization: Bearer &lt;key&gt;     (or the key under auth_header - Azure: api-key)
"!   {"model": ..., "max_completion_tokens": ..., "messages": [{"role": "system", ...}, {"role": "user", ...}]}
"!
"! The answer is choices[0].message.content, an error comes back as
"! {"error": {"message": ...}}. The system prompt travels as the first
"! message with role system - this API has no top-level field for it. The
"! token limit is sent as max_completion_tokens, the name OpenAI's current
"! models require; a server that only knows max_tokens gets that name when
"! the app says so (check_legacy_tokens). finish_reason is mapped onto
"! z2ui5_if_ui5_llm=&gt;cs_stop: stop to end_turn, length to max_tokens,
"! content_filter to refusal, anything else passes as it came.
"!
"! Model, key, endpoint and token limit are handed in by the app and never
"! written into this class - the model id has no default.
CLASS z2ui5_cl_ui5_llm_openai DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_llm.

    "! the endpoint when the app names none
    CONSTANTS cv_default_url TYPE string VALUE `https://api.openai.com/v1/chat/completions`.
    "! the path below a destination when the app names none
    CONSTANTS cv_default_path TYPE string VALUE `/v1/chat/completions`.
    CONSTANTS cv_default_timeout TYPE i VALUE 300.

    "! @parameter model              | the model id, exactly as the server spells it
    "! @parameter api_key            | sent as Authorization: Bearer; empty when
    "!                                 the destination or a gateway authenticates
    "!                                 (a local Ollama needs none)
    "! @parameter url                | the full endpoint URL, or with destination
    "!                                 the path below it - empty for the defaults
    "! @parameter destination        | Standard: an SM59 destination (type G);
    "!                                 ABAP Cloud: SCENARIO/SERVICE_ID of a
    "!                                 communication arrangement or a BTP
    "!                                 destination name
    "! @parameter timeout            | seconds the call may take, 0 for
    "!                                 cv_default_timeout
    "! @parameter auth_header        | the header the key travels in - empty
    "!                                 for Authorization: Bearer, any other
    "!                                 name carries the key as it is (Azure
    "!                                 OpenAI: api-key)
    "! @parameter check_legacy_tokens | send the token limit as max_tokens
    "!                                 (older servers) instead of
    "!                                 max_completion_tokens
    "! @parameter io_http            | the transport - the shipped one when
    "!                                 empty; a unit test passes a double
    METHODS constructor
      IMPORTING
        model               TYPE clike
        api_key             TYPE clike OPTIONAL
        url                 TYPE clike OPTIONAL
        !destination        TYPE clike OPTIONAL
        timeout             TYPE i OPTIONAL
        auth_header         TYPE clike OPTIONAL
        check_legacy_tokens TYPE abap_bool DEFAULT abap_false
        io_http             TYPE REF TO z2ui5_if_ui5_llm_http OPTIONAL.

    "! The HTTP request of a chat call - public for the unit tests.
    METHODS build_request
      IMPORTING
        system        TYPE clike OPTIONAL
        t_message     TYPE z2ui5_if_ui5_llm=>ty_t_message
        s_options     TYPE z2ui5_if_ui5_llm=>ty_s_options OPTIONAL
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_llm_http=>ty_s_request
      RAISING
        z2ui5_cx_ui5_llm.

    "! An HTTP answer as a chat answer, or the exception it stands for -
    "! public for the unit tests.
    CLASS-METHODS parse_response
      IMPORTING
        is_response   TYPE z2ui5_if_ui5_llm_http=>ty_s_response
      RETURNING
        VALUE(result) TYPE z2ui5_if_ui5_llm=>ty_s_result
      RAISING
        z2ui5_cx_ui5_llm.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA mv_model TYPE string.
    DATA mv_api_key TYPE string.
    DATA mv_url TYPE string.
    DATA mv_destination TYPE string.
    DATA mv_timeout TYPE i.
    DATA mv_auth_header TYPE string.
    DATA mv_check_legacy_tokens TYPE abap_bool.
    DATA mi_http TYPE REF TO z2ui5_if_ui5_llm_http.

    METHODS build_body
      IMPORTING
        system        TYPE clike
        t_message     TYPE z2ui5_if_ui5_llm=>ty_t_message
        s_options     TYPE z2ui5_if_ui5_llm=>ty_s_options
      RETURNING
        VALUE(result) TYPE string
      RAISING
        z2ui5_cx_ui5_llm.

    CLASS-METHODS message_push
      IMPORTING
        io_body TYPE REF TO z2ui5_if_ajson
        role    TYPE string
        content TYPE string
      RAISING
        z2ui5_cx_ajson_error.

    CLASS-METHODS map_stop_reason
      IMPORTING
        val           TYPE string
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5_llm_openai IMPLEMENTATION.

  METHOD constructor.

    mv_model               = model.
    mv_api_key             = api_key.
    mv_url                 = url.
    mv_destination         = destination.
    mv_timeout             = COND #( WHEN timeout > 0 THEN timeout ELSE cv_default_timeout ).
    mv_auth_header         = auth_header.
    mv_check_legacy_tokens = check_legacy_tokens.
    IF mv_url IS INITIAL.
      mv_url = COND #( WHEN mv_destination IS INITIAL THEN cv_default_url ELSE cv_default_path ).
    ENDIF.
    IF io_http IS BOUND.
      mi_http = io_http.
    ELSE.
      mi_http = NEW z2ui5_cl_ui5_llm_http( ).
    ENDIF.

  ENDMETHOD.

  METHOD message_push.

    DATA(lo_item) = z2ui5_cl_ajson=>create_empty( ).
    lo_item->set( iv_path = `/role`
                  iv_val  = role ).
    lo_item->set( iv_path = `/content`
                  iv_val  = content ).
    io_body->push( iv_path = `/messages`
                   iv_val  = lo_item ).

  ENDMETHOD.

  METHOD build_body.

    DATA lv_model TYPE string.
    DATA lv_system TYPE string.

    lv_model = s_options-model.
    IF lv_model IS INITIAL.
      lv_model = mv_model.
    ENDIF.
    IF lv_model IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = `no model is configured - a Chat Completions call needs a model id`.
    ENDIF.
    IF lines( t_message ) = 0.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = `a chat call needs at least one message`.
    ENDIF.
    IF s_options-temperature IS NOT INITIAL
        AND ( s_options-temperature CN `0123456789.` OR count( val = s_options-temperature
                                                               sub = `.` ) > 1
              " JSON wants a digit on both sides of the point - `.7` and `1.` are no number there
              OR s_options-temperature CP `.*` OR s_options-temperature CP `*.` ).
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = |the temperature { s_options-temperature } is no number|.
    ENDIF.
    lv_system = system.

    TRY.
        DATA(lo_body) = z2ui5_cl_ajson=>create_empty( ).
        lo_body->set( iv_path = `/model`
                      iv_val  = lv_model ).
        IF s_options-max_tokens > 0.
          lo_body->set_integer( iv_path = COND #( WHEN mv_check_legacy_tokens = abap_true
                                                   THEN `/max_tokens`
                                                   ELSE `/max_completion_tokens` )
                                iv_val  = s_options-max_tokens ).
        ENDIF.
        IF s_options-temperature IS NOT INITIAL.
          lo_body->set( iv_path      = `/temperature`
                        iv_val       = s_options-temperature
                        iv_node_type = z2ui5_if_ajson_types=>node_type-number ).
        ENDIF.
        lo_body->touch_array( `/messages` ).
        " the system prompt is the first message - this API has no field for it
        IF lv_system IS NOT INITIAL.
          message_push( io_body = lo_body
                        role    = `system`
                        content = lv_system ).
        ENDIF.
        LOOP AT t_message INTO DATA(ls_message).
          IF ls_message-content IS INITIAL.
            RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
              EXPORTING
                text = |message { sy-tabix } has no content|.
          ENDIF.
          message_push( io_body = lo_body
                        role    = ls_message-role
                        content = ls_message-content ).
        ENDLOOP.
        result = lo_body->stringify( ).
      CATCH z2ui5_cx_ajson_error INTO DATA(lx).
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
          EXPORTING
            text     = `the request body could not be written as JSON`
            previous = lx.
    ENDTRY.

  ENDMETHOD.

  METHOD build_request.

    result-body        = build_body( system    = system
                                     t_message = t_message
                                     s_options = s_options ).
    result-url         = mv_url.
    result-destination = mv_destination.
    result-timeout     = mv_timeout.

    INSERT VALUE #( name  = `content-type`
                    value = `application/json; charset=utf-8` ) INTO TABLE result-t_header.
    IF mv_api_key IS NOT INITIAL AND mv_auth_header IS INITIAL.
      INSERT VALUE #( name  = `Authorization`
                      value = |Bearer { mv_api_key }| ) INTO TABLE result-t_header.
    ELSEIF mv_api_key IS NOT INITIAL.
      INSERT VALUE #( name  = mv_auth_header
                      value = mv_api_key ) INTO TABLE result-t_header.
    ENDIF.

  ENDMETHOD.

  METHOD map_stop_reason.

    CASE val.
      WHEN `stop`.
        result = z2ui5_if_ui5_llm=>cs_stop-end_turn.
      WHEN `length`.
        result = z2ui5_if_ui5_llm=>cs_stop-max_tokens.
      WHEN `content_filter`.
        result = z2ui5_if_ui5_llm=>cs_stop-refusal.
      WHEN OTHERS.
        result = val.
    ENDCASE.

  ENDMETHOD.

  METHOD parse_response.

    DATA lo_json TYPE REF TO z2ui5_if_ajson.
    DATA lv_message TYPE string.

    TRY.
        lo_json = z2ui5_cl_ajson=>parse( is_response-body ).
      CATCH cx_root.
        CLEAR lo_json.
    ENDTRY.

    IF is_response-status <> 200.
      IF lo_json IS BOUND.
        " OpenAI: {"error":{"message":...}} - Ollama: {"error":"..."}
        lv_message = lo_json->get_string( `/error/message` ).
        IF lv_message IS INITIAL.
          lv_message = lo_json->get_string( `/error` ).
        ENDIF.
      ENDIF.
      IF lv_message IS INITIAL.
        lv_message = z2ui5_cl_ui5_util_context=>c_truncate( val = is_response-body
                                                           max  = 200 ).
      ENDIF.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = |the Chat Completions endpoint answered HTTP { is_response-status } { is_response-reason } - { lv_message }|
          http_status = is_response-status
          retryable   = xsdbool( is_response-status = 408 OR is_response-status = 429 OR is_response-status >= 500 ).
    ENDIF.

    IF lo_json IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = `the Chat Completions endpoint answered with no JSON`
          http_status = is_response-status.
    ENDIF.

    result-model                 = lo_json->get_string( `/model` ).
    result-stop_reason           = map_stop_reason( lo_json->get_string( `/choices/1/finish_reason` ) ).
    result-s_usage-input_tokens  = lo_json->get_integer( `/usage/prompt_tokens` ).
    result-s_usage-output_tokens = lo_json->get_integer( `/usage/completion_tokens` ).
    result-text                  = lo_json->get_string( `/choices/1/message/content` ).

    IF result-text IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = |the model returned no text (finish_reason { result-stop_reason }) - raise max_tokens or change the prompt|
          http_status = is_response-status.
    ENDIF.

  ENDMETHOD.

  METHOD z2ui5_if_ui5_llm~chat.

    DATA(ls_request) = build_request( system    = system
                                      t_message = t_message
                                      s_options = s_options ).
    DATA(ls_response) = mi_http->post( ls_request ).
    result = parse_response( ls_response ).

  ENDMETHOD.

ENDCLASS.
