"! <p class="shorttext synchronized">abap2UI5 - Claude Messages API provider</p>
"! z2ui5_if_ui5_llm for the Claude Messages API - raw HTTP, as ABAP has no SDK:
"!
"!   POST /v1/messages
"!   x-api-key: &lt;key&gt;          anthropic-version: 2023-06-01
"!   {"model": ..., "max_tokens": ..., "system": ..., "messages": [{"role": "user", "content": "..."}]}
"!
"! The answer is the first content block of type text - a thinking block may
"! come first, and that block has no text key. An error comes back as
"! {"type": "error", "error": {"type": ..., "message": ...}} with a 4xx/5xx
"! status, and its message is what the exception carries.
"!
"! Model, key, endpoint and token limit are handed in by the app - from a
"! destination, a configuration table, a user exit - and are never written
"! into this class; the model id in particular has no default, because which
"! model a system may use and pay for is the installation's decision.
"! Reference: https://platform.claude.com/docs/en/api/messages
CLASS z2ui5_cl_ui5_llm_claude DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_llm.

    "! the endpoint when the app names none
    CONSTANTS cv_default_url TYPE string VALUE `https://api.anthropic.com/v1/messages`.
    "! the path below a destination when the app names none
    CONSTANTS cv_default_path TYPE string VALUE `/v1/messages`.
    "! the API version this wire format is written against - a header the
    "! Messages API requires on every request
    CONSTANTS cv_api_version TYPE string VALUE `2023-06-01`.
    "! the token limit when the call names none - the Messages API requires
    "! one, and a model that thinks spends from it before the answer starts
    CONSTANTS cv_default_max_tokens TYPE i VALUE 4096.
    CONSTANTS cv_default_timeout TYPE i VALUE 300.

    "! @parameter model       | the model id, exactly as the provider spells it
    "! @parameter api_key     | sent as x-api-key; empty when the destination
    "!                          or a gateway in front of it adds the header
    "! @parameter url         | the full endpoint URL, or with destination the
    "!                          path below it - empty for the defaults above
    "! @parameter destination | Standard: an SM59 destination (type G); ABAP
    "!                          Cloud: SCENARIO/SERVICE_ID of a communication
    "!                          arrangement or a BTP destination name
    "! @parameter timeout     | seconds the call may take, 0 for cv_default_timeout
    "! @parameter io_http     | the transport - the shipped one when empty;
    "!                          a unit test passes a double
    METHODS constructor
      IMPORTING
        model        TYPE clike
        api_key      TYPE clike OPTIONAL
        url          TYPE clike OPTIONAL
        !destination TYPE clike OPTIONAL
        timeout      TYPE i OPTIONAL
        io_http      TYPE REF TO z2ui5_if_ui5_llm_http OPTIONAL.

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

    CLASS-METHODS read_text
      IMPORTING
        io_json       TYPE REF TO z2ui5_if_ajson
      RETURNING
        VALUE(result) TYPE string.

ENDCLASS.


CLASS z2ui5_cl_ui5_llm_claude IMPLEMENTATION.

  METHOD constructor.

    mv_model       = model.
    mv_api_key     = api_key.
    mv_url         = url.
    mv_destination = destination.
    mv_timeout     = COND #( WHEN timeout > 0 THEN timeout ELSE cv_default_timeout ).
    IF mv_url IS INITIAL.
      mv_url = COND #( WHEN mv_destination IS INITIAL THEN cv_default_url ELSE cv_default_path ).
    ENDIF.
    IF io_http IS BOUND.
      mi_http = io_http.
    ELSE.
      mi_http = NEW z2ui5_cl_ui5_llm_http( ).
    ENDIF.

  ENDMETHOD.

  METHOD build_body.

    DATA lv_model TYPE string.
    DATA lv_system TYPE string.
    DATA lv_max_tokens TYPE i.

    lv_model = s_options-model.
    IF lv_model IS INITIAL.
      lv_model = mv_model.
    ENDIF.
    IF lv_model IS INITIAL.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text = `no model is configured - the Messages API needs a model id`.
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

    lv_max_tokens = s_options-max_tokens.
    IF lv_max_tokens <= 0.
      lv_max_tokens = cv_default_max_tokens.
    ENDIF.
    lv_system = system.

    TRY.
        " the body through the framework's JSON writer - every value escaped
        " by it, the system prompt a top-level field (the Messages API has
        " no system role), each message a nested object
        DATA(lo_body) = z2ui5_cl_ajson=>create_empty( ).
        lo_body->set( iv_path = `/model`
                      iv_val  = lv_model ).
        lo_body->set_integer( iv_path = `/max_tokens`
                              iv_val  = lv_max_tokens ).
        IF lv_system IS NOT INITIAL.
          lo_body->set( iv_path = `/system`
                        iv_val  = lv_system ).
        ENDIF.
        IF s_options-temperature IS NOT INITIAL.
          lo_body->set( iv_path      = `/temperature`
                        iv_val       = s_options-temperature
                        iv_node_type = z2ui5_if_ajson_types=>node_type-number ).
        ENDIF.
        lo_body->touch_array( `/messages` ).
        LOOP AT t_message INTO DATA(ls_message).
          IF ls_message-content IS INITIAL.
            RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
              EXPORTING
                text = |message { sy-tabix } has no content - the Messages API refuses an empty message|.
          ENDIF.
          DATA(lo_item) = z2ui5_cl_ajson=>create_empty( ).
          lo_item->set( iv_path = `/role`
                        iv_val  = ls_message-role ).
          lo_item->set( iv_path = `/content`
                        iv_val  = ls_message-content ).
          lo_body->push( iv_path = `/messages`
                         iv_val  = lo_item ).
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
    INSERT VALUE #( name  = `anthropic-version`
                    value = cv_api_version ) INTO TABLE result-t_header.
    IF mv_api_key IS NOT INITIAL.
      INSERT VALUE #( name  = `x-api-key`
                      value = mv_api_key ) INTO TABLE result-t_header.
    ENDIF.

  ENDMETHOD.

  METHOD read_text.

    " the first text block - a thinking block may come first, and content
    " is an array, which ajson addresses 1-based
    " a counter of its own rather than sy-index, which a call inside the
    " loop may overwrite, and rather than the member names, which ajson
    " sorts as text (10 before 2)
    DATA lv_index TYPE i.
    DATA(lv_count) = lines( io_json->members( `/content` ) ).
    WHILE lv_index < lv_count.
      lv_index = lv_index + 1.
      IF io_json->get_string( |/content/{ lv_index }/type| ) = `text`.
        result = io_json->get_string( |/content/{ lv_index }/text| ).
        RETURN.
      ENDIF.
    ENDWHILE.

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
        lv_message = lo_json->get_string( `/error/message` ).
      ENDIF.
      IF lv_message IS INITIAL.
        lv_message = z2ui5_cl_ui5_util_context=>c_truncate( val = is_response-body
                                                           max  = 200 ).
      ENDIF.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = |the Messages API answered HTTP { is_response-status } { is_response-reason } - { lv_message }|
          http_status = is_response-status
          retryable   = xsdbool( is_response-status = 408 OR is_response-status = 429 OR is_response-status >= 500 ).
    ENDIF.

    IF lo_json IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = `the Messages API answered with no JSON`
          http_status = is_response-status.
    ENDIF.

    result-model                 = lo_json->get_string( `/model` ).
    result-stop_reason           = lo_json->get_string( `/stop_reason` ).
    result-s_usage-input_tokens  = lo_json->get_integer( `/usage/input_tokens` ).
    result-s_usage-output_tokens = lo_json->get_integer( `/usage/output_tokens` ).
    result-text                  = read_text( lo_json ).

    IF result-text IS INITIAL AND result-stop_reason = z2ui5_if_ui5_llm=>cs_stop-refusal.
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = `the model declined to answer (stop_reason refusal)`
          http_status = is_response-status.
    ENDIF.
    IF result-text IS INITIAL.
      " a 200 without a text block: the token limit ran out before the
      " answer started
      RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
        EXPORTING
          text        = |the model returned no text (stop_reason { result-stop_reason }) - raise max_tokens or change the prompt|
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
