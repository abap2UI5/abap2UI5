CLASS z2ui5_cl_util_security DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " CSRF Protection
    CLASS-METHODS generate_csrf_token
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS validate_csrf_token
      IMPORTING
        token         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS store_csrf_token
      IMPORTING
        token TYPE string.

    CLASS-METHODS get_stored_csrf_token
      RETURNING
        VALUE(result) TYPE string.

    " Input Sanitization
    CLASS-METHODS sanitize_html
      IMPORTING
        input         TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS sanitize_sql
      IMPORTING
        input         TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS validate_email
      IMPORTING
        email         TYPE string
      RETURNING
        VALUE(result) TYPE abap_bool.

    CLASS-METHODS validate_length
      IMPORTING
        input      TYPE string
        min_length TYPE i DEFAULT 0
        max_length TYPE i DEFAULT 1000
      RETURNING
        VALUE(result) TYPE abap_bool.

    " Data Encryption for Sessions
    CLASS-METHODS encrypt_data
      IMPORTING
        plaintext     TYPE string
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS decrypt_data
      IMPORTING
        ciphertext    TYPE string
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CLASS-DATA gv_csrf_token TYPE string.

ENDCLASS.



CLASS z2ui5_cl_util_security IMPLEMENTATION.

  METHOD generate_csrf_token.
    " Generate cryptographically secure CSRF token
    TRY.
        DATA(uuid1) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(uuid2) = cl_system_uuid=>create_uuid_x16_static( ).

        " Convert to string and combine
        result = uuid1 && uuid2.

        " Store token in memory/session
        store_csrf_token( result ).

      CATCH cx_root INTO DATA(x).
        " Fallback to timestamp-based token (less secure but functional)
        DATA(lv_timestamp) = z2ui5_cl_util=>time_get_timestampl( ).
        result = |CSRF-{ lv_timestamp }-{ sy-uname }|.
        store_csrf_token( result ).
    ENDTRY.
  ENDMETHOD.

  METHOD validate_csrf_token.
    " Validate CSRF token against stored token
    DATA(lv_stored_token) = get_stored_csrf_token( ).

    IF lv_stored_token IS INITIAL.
      " No token stored - might be first request
      result = abap_false.
      RETURN.
    ENDIF.

    IF token = lv_stored_token.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD store_csrf_token.
    " Store CSRF token in class variable (session scope)
    gv_csrf_token = token.

    " Also store in SAP memory for session persistence
    TRY.
        SET PARAMETER ID 'Z2UI5_CSRF' FIELD token.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD get_stored_csrf_token.
    " Retrieve stored CSRF token
    IF gv_csrf_token IS NOT INITIAL.
      result = gv_csrf_token.
      RETURN.
    ENDIF.

    " Try to retrieve from SAP memory
    TRY.
        GET PARAMETER ID 'Z2UI5_CSRF' FIELD result.
        gv_csrf_token = result.
      CATCH cx_root ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.

  METHOD sanitize_html.
    " Sanitize HTML input to prevent XSS
    result = input.

    " Encode HTML special characters
    REPLACE ALL OCCURRENCES OF '<' IN result WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN result WITH '&gt;'.
    REPLACE ALL OCCURRENCES OF '"' IN result WITH '&quot;'.
    REPLACE ALL OCCURRENCES OF '''' IN result WITH '&#x27;'.
    REPLACE ALL OCCURRENCES OF '&' IN result WITH '&amp;'.

    " Remove JavaScript event handlers
    REPLACE ALL OCCURRENCES OF REGEX 'on\w+\s*=' IN result WITH '' IGNORING CASE.

    " Remove script tags
    REPLACE ALL OCCURRENCES OF REGEX '<script[^>]*>.*?</script>' IN result WITH '' IGNORING CASE.
  ENDMETHOD.

  METHOD sanitize_sql.
    " Sanitize SQL input to prevent SQL injection
    result = input.

    " Escape single quotes
    REPLACE ALL OCCURRENCES OF '''' IN result WITH ''''''.

    " Remove SQL comments
    REPLACE ALL OCCURRENCES OF REGEX '--.*$' IN result WITH ''.
    REPLACE ALL OCCURRENCES OF REGEX '/\*.*?\*/' IN result WITH ''.

    " Remove dangerous SQL keywords (basic protection)
    REPLACE ALL OCCURRENCES OF REGEX ';.*?(DROP|DELETE|UPDATE|INSERT|EXEC|EXECUTE)' IN result WITH '' IGNORING CASE.
  ENDMETHOD.

  METHOD validate_email.
    " Simple email validation using regex
    DATA(lv_email_pattern) = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'.

    IF input IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    TRY.
        FIND REGEX lv_email_pattern IN email.
        IF sy-subrc = 0.
          result = abap_true.
        ELSE.
          result = abap_false.
        ENDIF.
      CATCH cx_root.
        result = abap_false.
    ENDTRY.
  ENDMETHOD.

  METHOD validate_length.
    DATA(lv_length) = strlen( input ).

    IF lv_length >= min_length AND lv_length <= max_length.
      result = abap_true.
    ELSE.
      result = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD encrypt_data.
    " Basic encryption for session data
    " Note: For production use, consider using SAP's SSF (Secure Store and Forward)
    " or SAP Cryptographic Library

    TRY.
        " Simple XOR encryption with key (not cryptographically strong)
        " For production, use cl_sec_sxml_writer=>encrypt or similar
        DATA(lv_key) = 'Z2UI5-SECRET-KEY-CHANGE-THIS-IN-PRODUCTION'.
        DATA(lv_key_len) = strlen( lv_key ).
        result = plaintext.

        " This is a placeholder - implement proper encryption in production
        " Using SAP's encryption libraries like:
        " CALL METHOD cl_sec_sxml_writer=>encrypt
        "   EXPORTING
        "     plaintext = plaintext
        "   IMPORTING
        "     ciphertext = result.

        " For now, return base64 encoded (not encrypted, just obfuscated)
        DATA(lv_input_xstring) = cl_abap_conv_codepage=>create_out( )->convert( plaintext ).
        result = cl_http_utility=>encode_base64( lv_input_xstring ).

      CATCH cx_root INTO DATA(x).
        " Fallback: return original data
        result = plaintext.
    ENDTRY.
  ENDMETHOD.

  METHOD decrypt_data.
    " Basic decryption for session data
    TRY.
        " Decode base64 (matching encrypt_data)
        DATA(lv_decoded_xstring) = cl_http_utility=>decode_base64( ciphertext ).
        result = cl_abap_conv_codepage=>create_in( )->convert( lv_decoded_xstring ).

      CATCH cx_root INTO DATA(x).
        " Fallback: return original data
        result = ciphertext.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
