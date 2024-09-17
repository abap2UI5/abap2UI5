CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-DATA so_sticky_handler TYPE REF TO z2ui5_cl_core_http_post.

    CLASS-METHODS main
      IMPORTING
        body          TYPE string
        config        TYPE z2ui5_if_types=>ty_s_http_request_get OPTIONAL
      EXPORTING
        attributes    TYPE z2ui5_if_types=>ty_s_http_handler_attributes
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS http_post
      IMPORTING
        val           TYPE string
      EXPORTING
        attributes    TYPE z2ui5_if_types=>ty_s_http_handler_attributes
      RETURNING
        VALUE(result) TYPE string.

    CLASS-METHODS http_get
      IMPORTING
        val           TYPE z2ui5_if_types=>ty_s_http_request_get OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_http_handler IMPLEMENTATION.


  METHOD http_get.

    DATA(lo_get) = NEW z2ui5_cl_core_http_get( val ).
    result = lo_get->main( ).

  ENDMETHOD.


  METHOD http_post.
    CLEAR attributes.

    IF so_sticky_handler IS NOT BOUND.
      DATA(lo_post) = NEW z2ui5_cl_core_http_post( val ).
    ELSE.
      so_sticky_handler = lo_post.
    ENDIF.
    result = lo_post->main(
      IMPORTING
        attributes = attributes ).

    so_sticky_handler = lo_post.

  ENDMETHOD.

  METHOD main.
    CLEAR attributes.

    IF body IS INITIAL.
      DATA(lo_get) = NEW z2ui5_cl_core_http_get( config ).
      result = lo_get->main( ).
    ELSE.
       IF so_sticky_handler IS NOT BOUND.
      DATA(lo_post) = NEW z2ui5_cl_core_http_post( body ).
    ELSE.
      lo_post = so_sticky_handler.
      lo_post->mv_request_json = body.
    ENDIF.
*      DATA(lo_post) = NEW z2ui5_cl_core_http_post( body ).
      result = lo_post->main(
        IMPORTING
          attributes = attributes ).
    ENDIF.

    so_sticky_handler = lo_post.

  ENDMETHOD.

ENDCLASS.
