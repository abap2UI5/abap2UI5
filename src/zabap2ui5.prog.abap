REPORT zabap2ui5 LINE-SIZE 100.

CLASS zcl_abap2ui5_standalone DEFINITION FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_extension.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_abap2ui5_standalone IMPLEMENTATION.

  METHOD if_http_extension~handle_request.

    z2ui5_cl_http_handler=>factory( server )->main( ).

  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

write `dummy`.
