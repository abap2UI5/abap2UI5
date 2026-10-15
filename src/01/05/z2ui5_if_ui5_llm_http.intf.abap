"! <p class="shorttext synchronized">abap2UI5 - language model transport</p>
"! How an HTTP provider reaches its endpoint: one POST with a JSON body. Split
"! off from the providers so that a unit test can stand in for the network -
"! the two HTTP providers take a transport in their constructor and build
"! the request and read the answer against it. The shipped implementation is
"! z2ui5_cl_ui5_llm_http, which goes through
"! z2ui5_cl_ui5_util_http=&gt;client_request( ) - the framework's one place for
"! outbound HTTP on Standard and on ABAP Cloud.
INTERFACE z2ui5_if_ui5_llm_http
  PUBLIC.

  TYPES:
    BEGIN OF ty_s_header,
      name  TYPE string,
      value TYPE string,
    END OF ty_s_header.
  TYPES ty_t_header TYPE STANDARD TABLE OF ty_s_header WITH EMPTY KEY.

  TYPES:
    "! url: the full URL, or with destination the path below it.
    "! destination: Standard an SM59 destination (type G); ABAP Cloud a
    "! communication arrangement SCENARIO/SERVICE_ID[/COMM_SYSTEM] or the
    "! name of a destination of the BTP destination service. timeout in
    "! seconds, 0 for the client's default
    BEGIN OF ty_s_request,
      url         TYPE string,
      destination TYPE string,
      t_header    TYPE ty_t_header,
      body        TYPE string,
      timeout     TYPE i,
    END OF ty_s_request.

  TYPES:
    "! status and body of the response, whatever the status - reading an
    "! error object is the provider's job
    BEGIN OF ty_s_response,
      status TYPE i,
      reason TYPE string,
      body   TYPE string,
    END OF ty_s_response.

  "! One POST. Raises z2ui5_cx_ui5_llm (retryable, http_status 0) when no
  "! answer came; an answer with any status is returned.
  METHODS post
    IMPORTING
      is_request    TYPE ty_s_request
    RETURNING
      VALUE(result) TYPE ty_s_response
    RAISING
      z2ui5_cx_ui5_llm.

ENDINTERFACE.
