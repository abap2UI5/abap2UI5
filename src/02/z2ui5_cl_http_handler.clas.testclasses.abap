CLASS ltcl_unit_test DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
  PROTECTED SECTION.

  PRIVATE SECTION.
    METHODS test_get   FOR TESTING RAISING cx_static_check.
    METHODS test_post  FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_unit_test IMPLEMENTATION.

  METHOD test_get.

    DATA(lv_resp) = z2ui5_cl_http_handler=>http_get( ).
    IF lv_resp IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET' ).
    ENDIF.

  ENDMETHOD.

  METHOD test_post.

*    DATA(lv_resp) = z2ui5_cl_http_handler=>http_post( value #( ) ).
*    IF lv_resp IS INITIAL.
*      cl_abap_unit_assert=>fail( 'HTTP POST' ).
*    ENDIF.
  ENDMETHOD.

ENDCLASS.
