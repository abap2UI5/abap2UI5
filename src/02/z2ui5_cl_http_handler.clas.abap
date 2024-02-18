CLASS z2ui5_cl_http_handler DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS http_post
      IMPORTING
        val           TYPE string
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

    DATA(lo_post) = NEW z2ui5_cl_core_http_post( val ).
    result = lo_post->main( ).

  ENDMETHOD.
ENDCLASS.
