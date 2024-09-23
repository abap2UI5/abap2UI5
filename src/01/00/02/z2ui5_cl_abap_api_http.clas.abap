CLASS z2ui5_cl_abap_api_http DEFINITION PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS factory
      IMPORTING
        server        TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_abap_api_http.

    CLASS-METHODS factory_cloud
      IMPORTING
        req           TYPE REF TO object
        res           TYPE REF TO object
      RETURNING
        VALUE(result) TYPE REF TO z2ui5_cl_abap_api_http.

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
        code   TYPE i
        reason TYPE clike.

    METHODS set_session_stateful
      IMPORTING
        val TYPE i.

    METHODS get_cookie
      IMPORTING
        val           TYPE clike
      RETURNING
        VALUE(result) TYPE string.

    METHODS delete_cookie
      IMPORTING
        val TYPE clike.

    METHODS set_header_field
      IMPORTING
        n TYPE clike
        v TYPE clike.

  PROTECTED SECTION.
    DATA mo_v1 TYPE REF TO object.
    DATA mo_v2 TYPE REF TO object.

  PRIVATE SECTION.
ENDCLASS.

CLASS z2ui5_cl_abap_api_http IMPLEMENTATION.

  METHOD delete_cookie.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('RESPONSE') TO <any>.
    object = <any>.

    CALL METHOD object->('DELETE_COOKIE')
      EXPORTING
        name = val.


  ENDMETHOD.

  METHOD get_cookie.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('REQUEST') TO <any>.
    object = <any>.

    CALL METHOD object->('GET_COOKIE')
      EXPORTING
        name  = val
      RECEIVING
        value = result.

  ENDMETHOD.

  METHOD get_header_field.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('REQUEST') TO <any>.
    object = <any>.

    CALL METHOD object->('GET_HEADER_FIELD')
      EXPORTING
        name  = val
      RECEIVING
        value = result.

  ENDMETHOD.

  METHOD set_header_field.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('RESPONSE') TO <any>.
    object = <any>.

    CALL METHOD object->('SET_HEADER_FIELD')
      EXPORTING
        name  = n
        value = v.

  ENDMETHOD.

  METHOD factory.

    result = NEW #( ).
    result->mo_v1 = server.

  ENDMETHOD.

  METHOD factory_cloud.

    result = NEW #( ).
    result->mo_v1 = req.
    result->mo_v2 = res.

  ENDMETHOD.

  METHOD get_cdata.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('REQUEST') TO <any>.
    object = <any>.

    CALL METHOD object->('GET_CDATA')
      RECEIVING
        data = result.

  ENDMETHOD.

  METHOD get_method.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('REQUEST') TO <any>.
    object = <any>.

    CALL METHOD object->('IF_HTTP_REQUEST~GET_METHOD')
      RECEIVING
        method = result.

  ENDMETHOD.

  METHOD set_cdata.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('RESPONSE') TO <any>.
    object = <any>.

    CALL METHOD object->('SET_CDATA')
      EXPORTING
        data = val.

  ENDMETHOD.

  METHOD set_status.

    DATA object TYPE REF TO object.
    FIELD-SYMBOLS <any> TYPE any.

    ASSIGN mo_v1->('RESPONSE') TO <any>.
    object = <any>.

    CALL METHOD object->('IF_HTTP_RESPONSE~SET_STATUS')
      EXPORTING
        code   = code
        reason = reason.

  ENDMETHOD.

  METHOD set_session_stateful.

    CALL METHOD mo_v1->('SET_SESSION_STATEFUL')
      EXPORTING
        stateful = val.

  ENDMETHOD.

ENDCLASS.
