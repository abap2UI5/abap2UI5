CLASS zcl_sicf DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_extension.
  PROTECTED SECTION.
ENDCLASS.



CLASS zcl_sicf IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

   data lo_server type ref to z2ui5_cl_http_handler.
   lo_server = z2ui5_cl_http_handler=>factory( server ).
   lo_server->main( ).

  ENDMETHOD.

ENDCLASS.
