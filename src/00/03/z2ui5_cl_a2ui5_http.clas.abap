CLASS z2ui5_cl_a2ui5_http DEFINITION PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_http_req,
        method   TYPE string,
        body     TYPE string,
        path     TYPE string,
        t_params TYPE z2ui5_cl_a2ui5_context=>ty_t_name_value,
      END OF ty_s_http_req.

    TYPES:
      BEGIN OF ty_s_http_res,
        body          TYPE string,
        status_code   TYPE i,
        status_reason TYPE string,
      END OF ty_s_http_res.

    CLASS-METHODS client_create
      IMPORTING
        !destination  TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE REF TO object.

    CLASS-METHODS client_call
      IMPORTING
        !method       TYPE clike
        body          TYPE clike OPTIONAL
        !destination  TYPE clike OPTIONAL
        url           TYPE clike OPTIONAL
      RETURNING
        VALUE(result) TYPE ty_s_http_res.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_a2ui5_http.

    CLASS-METHODS factory_cloud
      IMPORTING
        req           TYPE REF TO object
        res           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_a2ui5_http.

    METHODS get_req_info
      RETURNING
        VALUE(result) TYPE ty_s_http_req.

    METHODS get_header_field
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_cdata
      RETURNING
        VALUE(result) TYPE string.

    METHODS get_method
      RETURNING
        VALUE(result) TYPE string.

    METHODS set_cdata
      IMPORTING
        val TYPE clike.

    METHODS set_status
      IMPORTING
        !code  TYPE i
        reason TYPE clike.

    METHODS set_session_stateful
      IMPORTING
        val TYPE i.

    METHODS get_response_cookie
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    METHODS delete_response_cookie
      IMPORTING
        val TYPE clike.

    METHODS set_header_field
      IMPORTING
        !n TYPE clike
        v  TYPE clike.

    DATA mo_server_onprem  TYPE REF TO object.
    DATA mo_request_cloud  TYPE REF TO object.
    DATA mo_response_cloud TYPE REF TO object.

  PROTECTED SECTION.

  PRIVATE SECTION.

    " resolved once per instance - every accessor would otherwise repeat
    " the dynamic ASSIGN on the server object
    DATA mo_request_onprem  TYPE REF TO object.
    DATA mo_response_onprem TYPE REF TO object.

    METHODS get_request_onprem
      RETURNING
        VALUE(result) TYPE REF TO object.

    METHODS get_response_onprem
      RETURNING
        VALUE(result) TYPE REF TO object.

ENDCLASS.


CLASS z2ui5_cl_a2ui5_http IMPLEMENTATION.

  METHOD client_create.

    DATA lv_classname TYPE c LENGTH 14.
    lv_classname = `CL_HTTP_CLIENT`.

    DATA lv_destination TYPE c LENGTH 32.
    lv_destination = destination.
    DATA(lv_url) = CONV string( url ).

    TRY.

        IF lv_destination IS NOT INITIAL AND lv_destination <> `NONE`.

          CALL METHOD (lv_classname)=>create_by_destination
            EXPORTING
              destination              = lv_destination
            IMPORTING
              client                   = result
            EXCEPTIONS
              argument_not_found       = 1
              destination_not_found    = 2
              destination_no_authority = 3
              plugin_not_active        = 4
              internal_error           = 5
              OTHERS                   = 6.

        ELSE.

          CALL METHOD (lv_classname)=>create_by_url
            EXPORTING
              url                = lv_url
            IMPORTING
              client             = result
            EXCEPTIONS
              argument_not_found = 1
              plugin_not_active  = 2
              internal_error     = 3
              OTHERS             = 4.

        ENDIF.

        IF sy-subrc <> 0.
          CLEAR result.
        ENDIF.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = x.
    ENDTRY.

    IF result IS NOT BOUND.
      RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
        EXPORTING val = `HTTP_CLIENT_CREATE_ERROR - check the destination/url configuration`.
    ENDIF.

  ENDMETHOD.

  METHOD client_call.

    DATA lo_request  TYPE REF TO object.
    DATA lo_response TYPE REF TO object.
    DATA lv_message  TYPE string.
    FIELD-SYMBOLS <any> TYPE any.

    DATA(lo_client) = client_create( destination = destination
                                     url         = url ).

    TRY.

        ASSIGN lo_client->(`REQUEST`) TO <any>.
        ASSERT sy-subrc = 0.
        lo_request = <any>.

        DATA(lv_method) = CONV string( method ).
        CALL METHOD lo_request->(`SET_METHOD`)
          EXPORTING
            method = lv_method.

        DATA(lv_body) = CONV string( body ).
        CALL METHOD lo_request->(`SET_CDATA`)
          EXPORTING
            data = lv_body.

        CALL METHOD lo_client->(`SEND`)
          EXCEPTIONS
            http_communication_failure = 1
            http_invalid_state         = 2
            http_processing_failed     = 3
            http_invalid_timeout       = 4
            OTHERS                     = 5.

        IF sy-subrc = 0.
          CALL METHOD lo_client->(`RECEIVE`)
            EXCEPTIONS
              http_communication_failure = 1
              http_invalid_state         = 2
              http_processing_failed     = 3
              OTHERS                     = 4.
        ENDIF.

        IF sy-subrc <> 0.
          CALL METHOD lo_client->(`GET_LAST_ERROR`)
            IMPORTING
              message = lv_message.
          CALL METHOD lo_client->(`CLOSE`)
            EXCEPTIONS
              OTHERS = 1.
          RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
            EXPORTING val = |HTTP_COMMUNICATION_ERROR - { lv_message }|.
        ENDIF.

        ASSIGN lo_client->(`RESPONSE`) TO <any>.
        ASSERT sy-subrc = 0.
        lo_response = <any>.

        CALL METHOD lo_response->(`GET_CDATA`)
          RECEIVING
            data = result-body.

        CALL METHOD lo_response->(`GET_STATUS`)
          IMPORTING
            code   = result-status_code
            reason = result-status_reason.

        CALL METHOD lo_client->(`CLOSE`)
          EXCEPTIONS
            OTHERS = 1.

      CATCH cx_root INTO DATA(x).
        RAISE EXCEPTION TYPE z2ui5_cx_a2ui5_error
          EXPORTING val = x.
    ENDTRY.

  ENDMETHOD.

  METHOD delete_response_cookie.

    DATA(lv_val) = CONV string( val ).

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_response_onprem( ).

      CALL METHOD object->(`DELETE_COOKIE`)
        EXPORTING
          name = lv_val.

    ENDIF.

  ENDMETHOD.

  METHOD get_response_cookie.

    DATA(lv_val) = CONV string( val ).

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_response_onprem( ).

      CALL METHOD object->(`GET_COOKIE`)
        EXPORTING
          name  = lv_val
        IMPORTING
          value = result.

    ENDIF.

  ENDMETHOD.

  METHOD get_header_field.

    DATA(lv_val) = CONV string( val ).

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_request_onprem( ).

      CALL METHOD object->(`GET_HEADER_FIELD`)
        EXPORTING
          name  = lv_val
        RECEIVING
          value = result.

    ELSE.

      CALL METHOD mo_request_cloud->(`IF_WEB_HTTP_REQUEST~GET_HEADER_FIELD`)
        EXPORTING
          i_name  = lv_val
        RECEIVING
          r_value = result.

    ENDIF.

  ENDMETHOD.

  METHOD set_header_field.

    DATA(lv_n) = CONV string( n ).
    DATA(lv_v) = CONV string( v ).
    IF mo_server_onprem IS BOUND.

      DATA(object) = get_response_onprem( ).

      CALL METHOD object->(`SET_HEADER_FIELD`)
        EXPORTING
          name  = lv_n
          value = lv_v.

    ELSE.

      CALL METHOD mo_response_cloud->(`IF_WEB_HTTP_RESPONSE~SET_HEADER_FIELD`)
        EXPORTING
          i_name  = lv_n
          i_value = lv_v.

    ENDIF.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).
    result->mo_server_onprem = server.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
    result->mo_request_cloud  = req.
    result->mo_response_cloud = res.

  ENDMETHOD.

  METHOD get_cdata.

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_request_onprem( ).

      CALL METHOD object->(`GET_CDATA`)
        RECEIVING
          data = result.

    ELSE.

      CALL METHOD mo_request_cloud->(`IF_WEB_HTTP_REQUEST~GET_TEXT`)
        RECEIVING
          r_value = result.

    ENDIF.

  ENDMETHOD.

  METHOD get_method.

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_request_onprem( ).

      CALL METHOD object->(`IF_HTTP_REQUEST~GET_METHOD`)
        RECEIVING
          method = result.

    ELSE.

      CALL METHOD mo_request_cloud->(`IF_WEB_HTTP_REQUEST~GET_METHOD`)
        RECEIVING
          r_value = result.

    ENDIF.

  ENDMETHOD.

  METHOD set_cdata.

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_response_onprem( ).

      CALL METHOD object->(`SET_CDATA`)
        EXPORTING
          data = val.

    ELSE.

      CALL METHOD mo_response_cloud->(`IF_WEB_HTTP_RESPONSE~SET_TEXT`)
        EXPORTING
          i_text = val.

    ENDIF.

  ENDMETHOD.

  METHOD set_status.

    DATA(lv_reason) = CONV string( reason ).

    IF mo_server_onprem IS BOUND.

      DATA(object) = get_response_onprem( ).

      CALL METHOD object->(`IF_HTTP_RESPONSE~SET_STATUS`)
        EXPORTING
          code   = code
          reason = lv_reason.

    ELSE.

      CALL METHOD mo_response_cloud->(`IF_WEB_HTTP_RESPONSE~SET_STATUS`)
        EXPORTING
          i_code   = code
          i_reason = lv_reason.

    ENDIF.

  ENDMETHOD.

  METHOD set_session_stateful.

    IF mo_server_onprem IS BOUND.

      CALL METHOD mo_server_onprem->(`SET_SESSION_STATEFUL`)
        EXPORTING
          stateful = val.

      " stateful sessions are not released in ABAP Cloud - no-op there
    ENDIF.

  ENDMETHOD.

  METHOD get_request_onprem.

    IF mo_request_onprem IS NOT BOUND.
      FIELD-SYMBOLS <any> TYPE any.
      ASSIGN mo_server_onprem->(`REQUEST`) TO <any>.
      ASSERT sy-subrc = 0.
      mo_request_onprem = <any>.
    ENDIF.

    result = mo_request_onprem.

  ENDMETHOD.

  METHOD get_response_onprem.

    IF mo_response_onprem IS NOT BOUND.
      FIELD-SYMBOLS <any> TYPE any.
      ASSIGN mo_server_onprem->(`RESPONSE`) TO <any>.
      ASSERT sy-subrc = 0.
      mo_response_onprem = <any>.
    ENDIF.

    result = mo_response_onprem.

  ENDMETHOD.

  METHOD get_req_info.

    result-body     = get_cdata( ).
    result-method   = get_method( ).
    result-path     = get_header_field( `~path` ).
    result-t_params = z2ui5_cl_a2ui5_context=>url_param_get_tab( get_header_field( `~request_uri` ) ).

  ENDMETHOD.

ENDCLASS.
