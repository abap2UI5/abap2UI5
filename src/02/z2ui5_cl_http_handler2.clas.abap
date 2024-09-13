CLASS z2ui5_cl_http_handler2 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.

    CLASS-METHODS main
      IMPORTING
        body          TYPE string
        config        TYPE z2ui5_if_types=>ty_s_config_index_html OPTIONAL
      RETURNING
        VALUE(result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z2ui5_cl_http_handler2 IMPLEMENTATION.

  METHOD main.

    IF body IS INITIAL.
      DATA(lo_get) = NEW z2ui5_cl_core_http_get2( config ).
      result = lo_get->main(  ).
    ELSE.
      DATA(lo_post) = NEW z2ui5_cl_core_http_post( body ).
      result = lo_post->main( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
