"! <p class="shorttext synchronized">abap2UI5 - language model error</p>
"! Everything that can go wrong between an app and a language model, as one
"! checked exception with a readable text: no endpoint, a connection that
"! fails, an error object the provider sent back (http_status carries its
"! status), an answer without text. retryable says whether the same call may
"! succeed later - a timeout, HTTP 408, 429 and 5xx do; a 4xx, a refusal or
"! a missing configuration never does. An app shows get_text( ) in a
"! MessageStrip; the cause chain stays in previous for the 500 body.
CLASS z2ui5_cx_ui5_llm DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    DATA text TYPE string READ-ONLY.
    DATA http_status TYPE i READ-ONLY.
    DATA retryable TYPE abap_bool READ-ONLY.

    METHODS constructor
      IMPORTING
        textid      LIKE textid OPTIONAL
        !previous   LIKE previous OPTIONAL
        text        TYPE clike OPTIONAL
        http_status TYPE i OPTIONAL
        retryable   TYPE abap_bool OPTIONAL.

    METHODS if_message~get_text REDEFINITION.

  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.


CLASS z2ui5_cx_ui5_llm IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    super->constructor( textid   = textid
                        previous = previous ).
    me->text        = text.
    me->http_status = http_status.
    me->retryable   = retryable.

  ENDMETHOD.

  METHOD if_message~get_text.

    result = text.
    IF result IS INITIAL AND previous IS BOUND.
      result = previous->get_text( ).
    ENDIF.
    IF result IS INITIAL.
      result = `the language model call failed`.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
