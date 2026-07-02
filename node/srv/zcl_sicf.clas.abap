CLASS zcl_sicf DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_sicf IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

    DATA lo_server TYPE REF TO z2ui5_cl_http_handler.
    lo_server = z2ui5_cl_http_handler=>factory( server ).
    lo_server->main( ).

  ENDMETHOD.

ENDCLASS.
