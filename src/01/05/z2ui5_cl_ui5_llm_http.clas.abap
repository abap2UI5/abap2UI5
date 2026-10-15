"! <p class="shorttext synchronized">abap2UI5 - language model transport</p>
"! The shipped z2ui5_if_ui5_llm_http: one POST through
"! z2ui5_cl_ui5_util_http=&gt;client_request( ), where the framework decides
"! between CL_HTTP_CLIENT (Standard - an SM59 destination or a URL) and
"! CL_WEB_HTTP_CLIENT_MANAGER (ABAP Cloud - a URL, a communication
"! arrangement or a BTP destination), both named dynamically. Nothing about
"! the platform is decided here, and nothing about a provider either.
CLASS z2ui5_cl_ui5_llm_http DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_ui5_llm_http.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cl_ui5_llm_http IMPLEMENTATION.

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
        " setup
        RAISE EXCEPTION TYPE z2ui5_cx_ui5_llm
          EXPORTING
            text      = `the language model endpoint could not be reached - check the destination, the URL, the TLS trust and the proxy`
            retryable = abap_true
            previous  = lx.
    ENDTRY.

    result-status = ls_res-status_code.
    result-reason = ls_res-status_reason.
    result-body   = ls_res-body.

  ENDMETHOD.

ENDCLASS.
