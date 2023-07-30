CLASS ltcl_unit_02_app_start DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL harmless.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS test_index_html   FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_unit_02_app_start IMPLEMENTATION.

  METHOD test_index_html.

    DATA(lv_index_html) = z2ui5_cl_http_handler=>http_get( ).
    IF lv_index_html IS INITIAL.
      cl_abap_unit_assert=>fail( 'HTTP GET - index html initial' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
